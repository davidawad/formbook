//! Font calibration and the per-sample derived files in out/check/<alias>/<doc>/<sample>/.
use super::sh::{awk_cmp, awk_num, awk_rows, capture, cfg, cmd, io_fail, pipe_to_file, to_file};
use super::Ctx;
use crate::Res;
use std::process::Stdio;

/// The smallest word height per point among the level-5 rows of pdftotext -tsv: the calibration text is set in
/// regular, bold and italic, and a bold or italic face can report a shorter line box than the regular one.
pub fn calib_of(tsv: &str) -> String {
    awk_rows(tsv)
        .iter()
        .filter(|r| awk_cmp(r[0], 5.0, "5").is_eq())
        .map(|r| awk_num(r.get(9).copied().unwrap_or("")) / 100.0)
        .reduce(f64::min)
        .map_or(String::new(), |h| format!("{h:.5}"))
}

/// How tall a word of the declared font is at 1 pt, as pdftotext reports it ("" when typst fails,
/// as in check.sh, whose `exit 2` only left the command substitution).
pub fn calibrate(c: &Ctx) -> Res<String> {
    let d = format!("{}/calib", c.out);
    std::fs::create_dir_all(&d).map_err(|e| io_fail(&d, e))?;
    let fam = cfg(&c.env, &c.checks, ".font.typst_family")?;
    let typ = format!("#set page(width: 1000pt, height: 220pt, margin: 20pt)\n#set text(font: \"{fam}\", size: 100pt, top-edge: \"ascender\", bottom-edge: \"descender\")\nHxg #strong[Hxg] #emph[Hxg]\n");
    let (ctyp, cpdf, err) = (
        format!("{d}/c.typ"),
        format!("{d}/c.pdf"),
        format!("{d}/err"),
    );
    std::fs::write(&ctyp, typ).map_err(|e| io_fail(&ctyp, e))?;
    let fonts = format!("{}/fonts", c.root);
    crate::pin::check_typst(std::path::Path::new(&c.root))?;
    let tnr_fonts = match crate::pin::tnr_dir(std::path::Path::new(&c.root)) {
        Ok(d) => d.to_string_lossy().into_owned(),
        Err(e) if fam == "Times New Roman" => return Err(e),
        Err(_) => fonts.clone(),
    };
    let mut t = cmd(
        &c.env,
        "typst",
        &[
            "compile",
            "--font-path",
            &fonts,
            "--font-path",
            &tnr_fonts,
            "--ignore-system-fonts",
            &ctyp,
            &cpdf,
        ],
    );
    let ef = std::fs::File::create(&err).map_err(|e| io_fail(&err, e))?;
    t.stderr(ef);
    super::sh::flush();
    let o = t.output().map_err(|e| io_fail("typst", e))?;
    let typst_out = String::from_utf8_lossy(&o.stdout).into_owned();
    match o.status.success() {
        false => {
            let msg = std::fs::read_to_string(&err).unwrap_or_default();
            eprint!("{msg}");
            eprintln!("calibration failed");
            Ok(super::sh::strip_nl(&typst_out).to_string())
        }
        true => {
            let (tsv, _) = capture(cmd(&c.env, "pdftotext", &["-tsv", &cpdf, "-"]))?;
            Ok(super::sh::strip_nl(&format!("{typst_out}{}", calib_of(&tsv))).to_string())
        }
    }
}

/// `sed -n 's/^Pages: *//p'`.
pub fn npages(info: &str) -> String {
    let v: Vec<&str> = info
        .lines()
        .filter_map(|l| l.strip_prefix("Pages:"))
        .map(|l| l.trim_start_matches(' '))
        .collect();
    super::sh::strip_nl(&v.join("\n")).to_string()
}

/// `awk -F'\t' -v t=FTOP '$3 >= t { print $1 "\t" $7 }' words.tsv`: the bottom-margin words.
pub fn labels(words: &str, ftop: i64) -> String {
    let t = ftop.to_string();
    awk_rows(words)
        .iter()
        .filter(|r| awk_cmp(r.get(2).copied().unwrap_or(""), ftop as f64, &t).is_ge())
        .map(|r| format!("{}\t{}\n", r[0], r.get(6).copied().unwrap_or("")))
        .collect()
}

pub struct Prepared {
    pub npages: String,
}

/// check.sh's prepare(): render (unless --no-render), then the poppler and awk pipelines.
/// None when the sample cannot be prepared.
pub fn prepare(c: &Ctx, sid: &str, md: &str, pdf: &str, w: &str) -> Res<Option<Prepared>> {
    std::fs::create_dir_all(w).map_err(|e| io_fail(w, e))?;
    let rendered = match c.render {
        false => true,
        true => {
            let mdrel = c.md_rel(sid)?;
            let mut r =
                std::process::Command::new(std::env::current_exe().map_err(|e| io_fail("fb", e))?);
            r.envs(c.env.iter().map(|(k, v)| (k.as_str(), v.as_str())));
            let deny = ["--deny-warnings"].into_iter().filter(|_| c.default);
            r.current_dir(&c.root)
                .args(["render", "--engine", &c.engine])
                .args(deny)
                .args([c.doc.as_str(), mdrel.as_str(), pdf]);
            r.stdout(Stdio::null());
            super::sh::flush();
            r.status().map_err(|e| io_fail("sh", e))?.success()
        }
    };
    let have_pdf = rendered && std::path::Path::new(pdf).is_file();
    match (rendered, have_pdf) {
        (false, _) => return Ok(None),
        (true, false) => {
            eprintln!("no PDF at {pdf}");
            return Ok(None);
        }
        _ => {}
    }
    let chk = format!("{}/tools/check", c.root);
    let f = |n: &str| format!("{w}/{n}");
    let quiet = |prog: &str, args: &[&str]| {
        let mut x = cmd(&c.env, prog, args);
        x.stderr(Stdio::null());
        x
    };
    to_file(
        quiet("pdfinfo", &["-f", "1", "-l", "9999", pdf]),
        &f("info.txt"),
    )?;
    let info = std::fs::read_to_string(f("info.txt")).unwrap_or_default();
    to_file(quiet("pdffonts", &[pdf]), &f("fonts.txt"))?;
    let gawk = |args: &[&str]| cmd(&c.env, "gawk", args);
    let words_awk = format!("{chk}/words.awk");
    pipe_to_file(
        quiet("pdftotext", &["-tsv", pdf, "-"]),
        gawk(&["-f", &words_awk]),
        &f("words.tsv"),
    )?;
    let runs_awk = format!("{chk}/pdf-runs.awk");
    let html = quiet(
        "pdftohtml",
        &["-xml", "-zoom", "2", "-i", "-q", "-stdout", pdf],
    );
    pipe_to_file(html, gawk(&["-f", &runs_awk]), &f("runs.tsv"))?;
    if c.default {
        // pleading-paper line numbers (digit-only runs left of the 1 in margin) are decoration, not content
        let (raw, kept) = (f("runs-all.tsv"), f("runs.tsv"));
        std::fs::rename(&kept, &raw).map_err(|e| io_fail(&raw, e))?;
        to_file(
            gawk(&[
                "-F",
                "\t",
                "-v",
                "OFS=\t",
                "!($3 + 0 < 72 && $7 ~ /^[0-9]+$/)",
                &raw,
            ]),
            &kept,
        )?;
    }
    let dehyphen = format!(
        "DEHYPHEN={}",
        ["1"].into_iter().filter(|_| c.default).collect::<String>()
    );
    to_file(
        gawk(&["-v", &dehyphen, "-f", &format!("{chk}/md-blocks.awk"), md]),
        &f("blocks.tsv"),
    )?;
    let (g0, ft) = (format!("out={}", f("g0")), format!("footer_top={}", c.ftop));
    let (norm, gate0) = (format!("{chk}/norm.awk"), format!("{chk}/gate0.awk"));
    let mut g = gawk(&[
        "-v",
        &dehyphen,
        "-v",
        &g0,
        "-v",
        &ft,
        "-f",
        &norm,
        "-f",
        &gate0,
        &f("runs.tsv"),
        &f("blocks.tsv"),
    ]);
    super::sh::flush();
    g.status().map_err(|e| io_fail("gawk", e))?;
    let size = cfg(&c.env, &c.checks, ".font.size_pt")?;
    let hmin = format!("hmin={:.2}", awk_num(&c.calib) * awk_num(&size) * 0.8);
    let lines = gawk(&[
        "-v",
        &hmin,
        "-f",
        &format!("{chk}/lines.awk"),
        &f("g0.tags"),
        &f("runs.tsv"),
        &f("words.tsv"),
    ]);
    let sort = cmd(&c.env, "sort", &["-t", "\t", "-k1,1n", "-k2,2n"]);
    pipe_to_file(lines, sort, &f("lines.tsv"))?;
    let words = std::fs::read_to_string(f("words.tsv")).unwrap_or_default();
    let lab = f("labels.tsv");
    std::fs::write(&lab, labels(&words, c.ftop)).map_err(|e| io_fail(&lab, e))?;
    Ok(Some(Prepared {
        npages: npages(&info),
    }))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn calibration_row() {
        let tsv = "level\tpage_num\tpar_num\tblock_num\tline_num\tword_num\tleft\ttop\twidth\theight\ttext\n5\t1\t0\t0\t0\t0\t20\t20\t200\t113.4\tHxg\n5\t1\t0\t0\t0\t1\t220\t20\t200\t111.2\tHxg\n";
        assert_eq!(calib_of(tsv), "1.11200");
        assert_eq!(calib_of("level\n"), "");
    }

    #[test]
    fn pages_and_labels() {
        assert_eq!(
            npages("Title: x\nPages:          12\nPage    1 size: 612\n"),
            "12"
        );
        assert_eq!(npages(""), "");
        let words =
            "1\t300\t730.5\t310\t740\tx\ti\n1\t72\t72\t80\t86\tx\tword\n2\t300\t720\t1\t1\tx\t1\n";
        assert_eq!(labels(words, 720), "1\ti\n2\t1\n");
    }

    /// DEF-CONT-001 on a one-page document: `blocks_missing` for `md` against PDF text `runs`.
    fn g0_missing(md: &str, runs: &[&str]) -> String {
        let chk = format!("{}/../check", env!("CARGO_MANIFEST_DIR"));
        let dir = std::env::temp_dir().join(format!("fb-g0-{}-{}", std::process::id(), md.len()));
        std::fs::create_dir_all(&dir).unwrap();
        let (mdf, runsf, blocks) = (
            dir.join("a.md"),
            dir.join("runs.tsv"),
            dir.join("blocks.tsv"),
        );
        std::fs::write(&mdf, md).unwrap();
        let rows: String = runs
            .iter()
            .enumerate()
            .map(|(i, t)| format!("1\t{}\t0\t0\t0\t0\t{t}\n", 100 + 20 * i))
            .collect();
        std::fs::write(&runsf, rows).unwrap();
        let b = std::process::Command::new("gawk")
            .args(["-v", "DEHYPHEN=1", "-f", &format!("{chk}/md-blocks.awk")])
            .arg(&mdf)
            .output()
            .unwrap();
        std::fs::write(&blocks, b.stdout).unwrap();
        let out = format!("out={}", dir.join("g0").display());
        let ok = std::process::Command::new("gawk")
            .env("LC_ALL", "en_US.UTF-8")
            .args(["-v", "DEHYPHEN=1", "-v", &out, "-v", "footer_top=720"])
            .args([
                "-f",
                &format!("{chk}/norm.awk"),
                "-f",
                &format!("{chk}/gate0.awk"),
            ])
            .arg(&runsf)
            .arg(&blocks)
            .status()
            .unwrap()
            .success();
        assert!(ok);
        let m = std::fs::read_to_string(dir.join("g0.metrics")).unwrap();
        m.lines()
            .find_map(|l| l.strip_prefix("blocks_missing=").map(String::from))
            .unwrap()
    }

    #[test]
    fn placeholder_is_a_wildcard_but_real_text_still_counts() {
        let md = "First paragraph.\n\nWord count: {{words}} words.\n\n{{toc}}\n\nLast paragraph.\n";
        let runs = [
            "First paragraph.",
            "Word count: 1,577 words.",
            "Last paragraph.",
        ];
        assert_eq!(g0_missing(md, &runs), "0");
        // a real sentence missing from the PDF still fails
        let runs = ["First paragraph.", "Word count: 1,577 words."];
        assert_eq!(g0_missing(md, &runs), "1");
        // the literal text around the placeholder is still required
        let runs = ["First paragraph.", "Word total: 1,577.", "Last paragraph."];
        assert_ne!(g0_missing(md, &runs), "0");
    }
}
