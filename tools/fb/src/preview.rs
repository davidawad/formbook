//! `fb preview [--base REF] [--head REF] [--engine typst|latex|docx] [--pages N] [--out DIR] [--url-prefix URL]`:
//! page images of every committed `usage/OUTPUT-<id>.<engine>.pdf` the branch changes, for a pull request.
//! Each changed page is one row of four tiles:
//!   before  = the OUTPUT at the merge base of BASE and HEAD
//!   after   = the OUTPUT at HEAD
//!   diff    = red: before only, green: after only, black: both (red multiplied over green)
//!   filed   = the same-id FILED-EXAMPLE page sharing the most words with the after page (as `fb overlay` pairs)
//! Pages whose before and after rasters are identical are skipped; at most N changed pages (default 3) per OUTPUT.
//! PDFs are read from git (`git show <rev>:<path>`), not the working tree, so any two refs can be compared.
//! Writes `<out>/<doc path>/PREVIEW-<id>-p<page>.png`, `<out>/manifest.tsv` (doc, id, page, status, png) and
//! `<out>/comment.md` (a PR comment; image links are `<url-prefix>/<png>`). Default out: `.overlay/preview/`.
use crate::overlay::{all_words, best_page};
use crate::proc::{capture, pdf_pages, TempDir};
use crate::{fail, repo_root, Res};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const DPI: &str = "50";
const OLD: &str = "red";
const NEW: &str = "#00a000";
const MARKER: &str = "<!-- fb-preview -->";

const CLI: &str = "usage: fb preview [--base REF] [--head REF] [--engine typst|latex|docx] [--pages N] [--out DIR] [--url-prefix URL]";

struct Opts {
    base: String,
    head: String,
    engine: String,
    pages: usize,
    out: Option<PathBuf>,
    prefix: String,
}

fn opts(args: &[String]) -> Res<Opts> {
    let mut o = Opts {
        base: "origin/master".into(),
        head: "HEAD".into(),
        engine: "typst".into(),
        pages: 3,
        out: None,
        prefix: ".".into(),
    };
    let mut it = args.iter();
    while let Some(a) = it.next() {
        let mut v = || it.next().cloned().ok_or_else(|| fail(2, CLI));
        match a.as_str() {
            "--base" => o.base = v()?,
            "--head" => o.head = v()?,
            "--engine" => o.engine = v()?,
            "--pages" => o.pages = v()?.parse().map_err(|_| fail(2, CLI))?,
            "--out" => o.out = Some(v()?.into()),
            "--url-prefix" => o.prefix = v()?.trim_end_matches('/').to_string(),
            _ => return Err(fail(2, CLI)),
        }
    }
    match o.engine.as_str() {
        "typst" | "latex" | "docx" => Ok(o),
        _ => Err(fail(2, CLI)),
    }
}

/// The OUTPUT pdf suffix of an engine: the docx engine is compared through its LibreOffice pdf.
fn suffix(engine: &str) -> String {
    match engine {
        "docx" => ".docx.pdf".into(),
        e => format!(".{e}.pdf"),
    }
}

/// `(doc dir, id)` of a changed path that is a committed OUTPUT pdf of `engine`.
fn output_of(path: &str, engine: &str) -> Option<(String, String)> {
    let (usage, file) = path.rsplit_once('/')?;
    let doc = usage.strip_suffix("/usage")?;
    let id = file
        .strip_prefix("OUTPUT-")?
        .strip_suffix(&suffix(engine))?;
    (path.starts_with("courts/") && !id.is_empty()).then(|| (doc.to_string(), id.to_string()))
}

fn git(root: &Path, args: &[&str]) -> Res<Vec<u8>> {
    let o = capture(Command::new("git").arg("-C").arg(root).args(args))?;
    o.status.success().then_some(o.stdout).ok_or_else(|| {
        fail(
            1,
            format!(
                "fb preview: git {} failed: {}",
                args.join(" "),
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        )
    })
}

/// `rev:path` written to `dst`, or None when the path does not exist at `rev`.
fn blob(root: &Path, rev: &str, path: &str, dst: &Path) -> Res<Option<PathBuf>> {
    match git(root, &["show", &format!("{rev}:{path}")]) {
        Ok(b) => std::fs::write(dst, b)
            .map(|_| Some(dst.to_path_buf()))
            .map_err(|e| fail(2, format!("fb preview: {}: {e}", dst.display()))),
        Err(_) => Ok(None),
    }
}

fn run(cmd: &mut Command, what: &str) -> Res<()> {
    let o = capture(cmd)?;
    o.status.success().then_some(()).ok_or_else(|| {
        fail(
            1,
            format!(
                "fb preview: {what} failed: {}",
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        )
    })
}

/// Page `page` of `pdf` as a grayscale png at `stem`.png.
fn raster(pdf: &Path, page: usize, stem: &Path) -> Res<PathBuf> {
    let p = page.to_string();
    run(
        Command::new("pdftoppm")
            .args([
                "-r",
                DPI,
                "-gray",
                "-png",
                "-singlefile",
                "-f",
                &p,
                "-l",
                &p,
            ])
            .arg(pdf)
            .arg(stem),
        "pdftoppm",
    )?;
    Ok(stem.with_extension("png"))
}

/// A tile: `img` (or a blank page of `geo` when absent) under a caption.
fn tile(img: Option<&Path>, geo: &str, caption: &str, font: &Path, dst: &Path) -> Res<()> {
    let mut c = Command::new("magick");
    match img {
        Some(i) => c.arg(i),
        None => c.args(["-size", geo, "xc:#eeeeee"]),
    };
    run(
        c.args(["-bordercolor", "gray70", "-border", "1"])
            .args([
                "-gravity",
                "north",
                "-background",
                "white",
                "-splice",
                "0x22",
            ])
            .arg("-font")
            .arg(font)
            .args([
                "-pointsize",
                "14",
                "-fill",
                "gray20",
                "-annotate",
                "+0+3",
                caption,
            ])
            .arg(dst),
        "magick",
    )
}

/// The red/green tile: `old` tinted red multiplied over `new` tinted green, both at the geometry of `new` (or `old`).
fn diff_tile(old: Option<&Path>, new: Option<&Path>, geo: &str, t: &Path) -> Res<PathBuf> {
    let tint = |src: Option<&Path>, color: &str, dst: &Path| -> Res<()> {
        let mut c = Command::new("magick");
        match src {
            Some(s) => c.arg(s).args(["-resize", &format!("{geo}!")]),
            None => c.args(["-size", geo, "xc:white"]),
        };
        run(
            c.args(["+level-colors", &format!("{color},white")])
                .arg(dst),
            "magick",
        )
    };
    let (r, g, d) = (t.join("r.png"), t.join("g.png"), t.join("d.png"));
    tint(old, OLD, &r)?;
    tint(new, NEW, &g)?;
    run(
        Command::new("magick")
            .arg(&g)
            .arg(&r)
            .args(["-compose", "multiply", "-composite"])
            .arg(&d),
        "magick",
    )?;
    Ok(d)
}

fn geometry(img: &Path) -> Res<String> {
    let o = capture(
        Command::new("magick")
            .args(["identify", "-format", "%wx%h"])
            .arg(img),
    )?;
    Ok(String::from_utf8_lossy(&o.stdout).into_owned())
}

fn same_file(a: &Path, b: &Path) -> bool {
    matches!((std::fs::read(a), std::fs::read(b)), (Ok(x), Ok(y)) if x == y)
}

/// One manifest row: doc, id, page, status (`changed`, `new`, `deleted`, `unchanged`), png relative to out.
struct Row {
    doc: String,
    id: String,
    page: usize,
    status: &'static str,
    png: String,
}

/// The rows for one OUTPUT: its changed pages (at most `limit`), or one `unchanged` row.
fn preview_one(
    root: &Path,
    o: &Opts,
    mb: &str,
    doc: &str,
    id: &str,
    out: &Path,
    font: &Path,
) -> Res<Vec<Row>> {
    let tmp = TempDir::new("preview")?;
    let t = tmp.path();
    let rel = format!("{doc}/usage/OUTPUT-{id}{}", suffix(&o.engine));
    let before = blob(root, mb, &rel, &t.join("before.pdf"))?;
    let after = blob(root, &o.head, &rel, &t.join("after.pdf"))?;
    let filed = blob(
        root,
        &o.head,
        &format!("{doc}/usage/FILED-EXAMPLE-{id}.pdf"),
        &t.join("filed.pdf"),
    )?;
    let pages = |p: &Option<PathBuf>| p.as_deref().map_or(0, pdf_pages) as usize;
    let (nb, na) = (pages(&before), pages(&after));
    let filed_words = filed.as_deref().map(all_words).transpose()?;
    let after_words = after.as_deref().map(all_words).transpose()?;
    let status = match (&before, &after) {
        (None, _) => "new",
        (_, None) => "deleted",
        _ => "changed",
    };
    let dir = out.join(doc);
    std::fs::create_dir_all(&dir)
        .map_err(|e| fail(2, format!("fb preview: {}: {e}", dir.display())))?;
    let mut rows = vec![];
    for page in 1..=nb.max(na) {
        if rows.len() == o.pages {
            break;
        }
        let shot = |pdf: &Option<PathBuf>, n: usize, name: &str| -> Res<Option<PathBuf>> {
            match pdf {
                Some(p) if page <= n => {
                    raster(p, page, &t.join(format!("{name}-{page}"))).map(Some)
                }
                _ => Ok(None),
            }
        };
        let (b, a) = (shot(&before, nb, "b")?, shot(&after, na, "a")?);
        if let (Some(x), Some(y)) = (&b, &a) {
            if same_file(x, y) {
                continue;
            }
        }
        let geo = geometry(
            a.as_deref()
                .or(b.as_deref())
                .expect("a page exists on one side"),
        )?;
        let filed_page = match (&filed_words, &after_words) {
            (Some(fw), Some(aw)) => aw.get(page - 1).map_or(0, |w| best_page(w, fw).1),
            (Some(fw), None) => page.min(fw.len()),
            _ => 0,
        };
        let f = match (&filed, filed_page) {
            (Some(p), n) if n > 0 => Some(raster(p, n, &t.join(format!("f-{page}")))?),
            _ => None,
        };
        let d = diff_tile(b.as_deref(), a.as_deref(), &geo, t)?;
        let caps = [
            (b.as_deref(), format!("before p.{page}")),
            (a.as_deref(), format!("after p.{page}")),
            (Some(d.as_path()), "red = before, green = after".to_string()),
            (
                f.as_deref(),
                match filed_page {
                    0 => "no FILED-EXAMPLE".to_string(),
                    n => format!("filed p.{n}"),
                },
            ),
        ];
        let tiles: Vec<PathBuf> = caps
            .iter()
            .enumerate()
            .map(|(k, (img, cap))| {
                let dst = t.join(format!("tile-{page}-{k}.png"));
                tile(*img, &geo, cap, font, &dst).map(|_| dst)
            })
            .collect::<Res<_>>()?;
        let png = format!("{doc}/PREVIEW-{id}-p{page}.png");
        run(
            Command::new("magick")
                .args(&tiles)
                .args([
                    "-background",
                    "white",
                    "-gravity",
                    "north",
                    "-splice",
                    "8x0",
                    "+append",
                ])
                .args(["-bordercolor", "white", "-border", "6"])
                .arg(out.join(&png)),
            "magick",
        )?;
        rows.push(Row {
            doc: doc.into(),
            id: id.into(),
            page,
            status,
            png,
        });
    }
    Ok(match rows.is_empty() {
        true => vec![Row {
            doc: doc.into(),
            id: id.into(),
            page: 0,
            status: "unchanged",
            png: String::new(),
        }],
        false => rows,
    })
}

/// The PR comment for `rows`, grouped by OUTPUT, images linked under `prefix`.
fn comment(rows: &[Row], engine: &str, prefix: &str) -> String {
    let head = format!(
        "{MARKER}\n## Template previews ({engine})\n\nEach row: before | after | red = before only, green = after only, \
         black = both | the FILED-EXAMPLE page it is modelled on. Pages that did not change are omitted.\n"
    );
    let body: String = rows
        .iter()
        .fold((String::new(), String::new()), |(acc, last), r| {
            let key = format!("{}/usage/OUTPUT-{}", r.doc, r.id);
            let title = (key != last)
                .then(|| format!("\n### `{key}` ({})\n\n", r.status))
                .unwrap_or_default();
            let line = match r.status {
                "unchanged" => "No visual change.\n".to_string(),
                _ => format!("![p.{}]({prefix}/{})\n", r.page, r.png),
            };
            (acc + &title + &line, key)
        })
        .0;
    match rows.is_empty() {
        true => head + "\nNo committed OUTPUT pdf changed.\n",
        false => head + &body,
    }
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let o = opts(args)?;
    let root = repo_root()?;
    let out = o
        .out
        .clone()
        .unwrap_or_else(|| root.join(".overlay/preview"));
    let font = root.join("fonts/eb-garamond/EBGaramond-Regular.otf");
    let mb = String::from_utf8_lossy(&git(&root, &["merge-base", &o.base, &o.head])?)
        .trim()
        .to_string();
    let changed =
        String::from_utf8_lossy(&git(&root, &["diff", "--name-only", &mb, &o.head])?).into_owned();
    let outputs: Vec<(String, String)> = changed
        .lines()
        .filter_map(|p| output_of(p, &o.engine))
        .collect();
    if out.exists() {
        std::fs::remove_dir_all(&out)
            .map_err(|e| fail(2, format!("fb preview: {}: {e}", out.display())))?;
    }
    std::fs::create_dir_all(&out)
        .map_err(|e| fail(2, format!("fb preview: {}: {e}", out.display())))?;
    let rows: Vec<Row> = outputs
        .iter()
        .map(|(doc, id)| preview_one(&root, &o, &mb, doc, id, &out, &font))
        .collect::<Res<Vec<_>>>()?
        .into_iter()
        .flatten()
        .collect();
    let tsv: String = rows
        .iter()
        .map(|r| format!("{}\t{}\t{}\t{}\t{}\n", r.doc, r.id, r.page, r.status, r.png))
        .collect();
    let write = |name: &str, s: &str| {
        std::fs::write(out.join(name), s).map_err(|e| fail(2, format!("fb preview: {name}: {e}")))
    };
    write("manifest.tsv", &tsv)?;
    write("comment.md", &comment(&rows, &o.engine, &o.prefix))?;
    println!(
        "fb preview: {} OUTPUT pdf(s), {} image(s) in {}",
        outputs.len(),
        rows.iter().filter(|r| !r.png.is_empty()).count(),
        out.display()
    );
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn output_paths_are_matched_by_engine() {
        let p = "courts/dc-circuit/court-of-appeals/answering-brief/usage/OUTPUT-answering-brief-2.typst.pdf";
        assert_eq!(
            output_of(p, "typst"),
            Some((
                "courts/dc-circuit/court-of-appeals/answering-brief".into(),
                "answering-brief-2".into()
            ))
        );
        assert_eq!(output_of(p, "latex"), None);
        let d = "courts/x/usage/OUTPUT-complaint.docx.pdf";
        assert_eq!(
            output_of(d, "docx"),
            Some(("courts/x".into(), "complaint".into()))
        );
        assert_eq!(
            output_of("courts/x/usage/OUTPUT-complaint.docx", "docx"),
            None
        );
        assert_eq!(
            output_of("courts/x/usage/FILED-EXAMPLE-complaint.pdf", "typst"),
            None
        );
        assert_eq!(
            output_of("docs/usage/OUTPUT-complaint.typst.pdf", "typst"),
            None
        );
    }

    #[test]
    fn comment_groups_rows_and_links_under_prefix() {
        let rows = vec![
            Row {
                doc: "courts/a".into(),
                id: "complaint".into(),
                page: 1,
                status: "changed",
                png: "courts/a/PREVIEW-complaint-p1.png".into(),
            },
            Row {
                doc: "courts/a".into(),
                id: "complaint".into(),
                page: 3,
                status: "changed",
                png: "courts/a/PREVIEW-complaint-p3.png".into(),
            },
            Row {
                doc: "courts/b".into(),
                id: "answer".into(),
                page: 0,
                status: "unchanged",
                png: String::new(),
            },
        ];
        let c = comment(&rows, "typst", "https://x/y");
        assert!(c.starts_with(MARKER));
        assert_eq!(
            c.matches("### `courts/a/usage/OUTPUT-complaint` (changed)")
                .count(),
            1
        );
        assert!(c.contains("![p.3](https://x/y/courts/a/PREVIEW-complaint-p3.png)"));
        assert!(c.contains("### `courts/b/usage/OUTPUT-answer` (unchanged)\n\nNo visual change."));
        assert!(comment(&[], "typst", ".").contains("No committed OUTPUT pdf changed."));
    }
}
