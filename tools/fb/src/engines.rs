//! The LaTeX and Word render engines of `fb render --engine latex|docx` (were tools/render-latex.sh and
//! tools/render-docx.sh).
//!
//! Contract (docs/EVAL-LOOP.md, "Engines"):
//!   <court>/latex/render.sh     if present it owns the build: sh render.sh <court-dir> <sample.md> <out.pdf>
//!   <court>/latex/template.tex  otherwise pandoc --template plus every latex/*.lua filter, then pdflatex
//!                               (default; passes until doc.aux settles, then the stock check: the .tex alone
//!                               compiles in an empty directory with TEXINPUTS unset), or LATEX_ENGINE=tectonic or
//!                               xelatex; a template that loads fontspec stays on tectonic until it migrates
//!   <court>/docx/render.sh      if present it owns the .docx: sh render.sh <court-dir> <sample.md> <out.docx>
//!   <court>/docx/reference.docx otherwise pandoc --reference-doc plus every docx/*.lua filter, in passes when
//!                               the filters need page numbers (docxpass.rs)
//! Every docx is then packed again as a reproducible archive (docxzip.rs), checked (valid zip, well-formed XML
//! parts) and converted to PDF with LibreOffice.
use crate::proc::{capture, tail, which, TempDir};
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::Command;

/// Every `*.lua` file directly in `dir`, sorted, as `--lua-filter=` arguments.
fn lua_filters(dir: &Path) -> Vec<String> {
    let mut v: Vec<PathBuf> = std::fs::read_dir(dir)
        .map(|rd| {
            rd.filter_map(|e| e.ok())
                .map(|e| e.path())
                .filter(|p| p.extension().is_some_and(|x| x == "lua"))
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    v.iter()
        .map(|p| format!("--lua-filter={}", p.display()))
        .collect()
}

/// Run `sh <script> <court> <sample> <out>` with its stdout sent to our stderr; false on failure. With `lo_work`
/// (a docx script) the script sees the vendored fonts as LibreOffice will (FONTCONFIG_FILE, as `convert` sets it),
/// so a page it measures with its own soffice pass is the page of the final PDF.
fn run_owner(
    script: &Path,
    court: &Path,
    sample: &str,
    out: &Path,
    lo_work: Option<&Path>,
) -> Res<bool> {
    let mut cmd = Command::new("sh");
    if let (Some(work), Ok(root)) = (lo_work, crate::repo_root()) {
        let conf = crate::lofonts::fontconfig(&root, work)
            .map_err(|e| fail(2, format!("fb render: {}: {e}", work.display())))?;
        cmd.env("FONTCONFIG_FILE", conf);
    }
    let o = capture(cmd.arg(script).arg(court).arg(sample).arg(out))?;
    eprint!("{}", String::from_utf8_lossy(&o.stdout));
    eprint!("{}", String::from_utf8_lossy(&o.stderr));
    Ok(o.status.success())
}

/// Run a pandoc conversion in the court folder (the sample path is relative to it).
fn pandoc(court: &Path, args: &[String]) -> Res<()> {
    let st = Command::new("pandoc")
        .current_dir(court)
        .args(["--from", "markdown+smart"])
        .args(args)
        .status()
        .map_err(|e| fail(2, format!("fb render: cannot run pandoc: {e}")))?;
    st.success()
        .then_some(())
        .ok_or_else(|| fail(1, "fb render: pandoc failed"))
}

/// Render `sample` (relative to `court`) with the court's LaTeX template to `out`.
pub fn latex(root: &Path, court: &Path, sample: &str, out: &Path) -> Res<()> {
    let l = court.join("latex");
    if l.join("render.sh").is_file() {
        if !run_owner(&l.join("render.sh"), court, sample, out, None)? {
            return Err(fail(1, "fb render: latex/render.sh failed"));
        }
        return out.is_file().then_some(()).ok_or_else(|| {
            fail(
                1,
                format!(
                    "fb render: {} did not write {}",
                    l.join("render.sh").display(),
                    out.display()
                ),
            )
        });
    }
    let template = l.join("template.tex");
    if !template.is_file() {
        return Err(fail(
            1,
            format!(
                "fb render: no latex template ({} or {})",
                template.display(),
                l.join("render.sh").display()
            ),
        ));
    }
    let work = TempDir::new("latex")?;
    let tex = work.path().join("doc.tex");
    let mut args = vec![
        "--to".to_string(),
        "latex".into(),
        "--standalone".into(),
        format!("--template={}", template.display()),
        "-V".into(),
        format!("fontdir={}/", root.join("fonts").display()),
    ];
    args.extend(lua_filters(&l));
    args.extend([sample.to_string(), "-o".into(), tex.display().to_string()]);
    pandoc(court, &args)?;
    let src = std::fs::read_to_string(&tex)
        .map_err(|e| fail(2, format!("fb render: {}: {e}", tex.display())))?;
    let set = std::env::var("LATEX_ENGINE").ok();
    match latex_engine(set.as_deref(), &src) {
        "pdflatex" => {
            let pdflatex = crate::texlive::pdflatex();
            settle(work.path(), &pdflatex)?;
            stock_check(root, &tex, &src, &pdflatex)?
        }
        "tectonic" => build(
            work.path(),
            &[&["tectonic", "-X", "compile", "--keep-logs", "doc.tex"]],
            usize::MAX,
        )?,
        "xelatex" => {
            let pass = [
                "xelatex",
                "-interaction=nonstopmode",
                "-halt-on-error",
                "doc.tex",
            ];
            build(work.path(), &[&pass, &pass], 40)?
        }
        _ => {
            return Err(fail(
                2,
                "fb render: unknown LATEX_ENGINE (pdflatex, tectonic, xelatex)",
            ))
        }
    }
    std::fs::copy(work.path().join("doc.pdf"), out)
        .map(|_| ())
        .map_err(|e| fail(2, format!("fb render: cannot write {}: {e}", out.display())))
}

/// The TeX engine for a generated `src`: LATEX_ENGINE when set; otherwise pdflatex, the formbook LaTeX target
/// (fb-595.45), except that a template still loading fontspec (XeTeX or LuaTeX only) stays on tectonic until it
/// migrates to stock-pdflatex fonts.
fn latex_engine<'a>(set: Option<&'a str>, src: &str) -> &'a str {
    match set {
        Some(e) if !e.is_empty() => e,
        _ if src.contains("{fontspec}") => "tectonic",
        _ => "pdflatex",
    }
}

const PDFLATEX_ARGS: [&str; 4] = [
    "-interaction=nonstopmode",
    "-halt-on-error",
    "-no-shell-escape",
    "doc.tex",
];

/// pdflatex passes in `dir` until doc.aux and the other files read back (doc.toc, a template's own lists such as
/// doc.adt: every doc.* but the .tex, .pdf and .log) stop changing (the contents and authorities read their pages
/// back from them), at most 5.
fn settle(dir: &Path, pdflatex: &Path) -> Res<()> {
    let mut prev = None;
    for _ in 0..5 {
        let o = capture(Command::new(pdflatex).args(PDFLATEX_ARGS).current_dir(dir))?;
        if !o.status.success() {
            eprintln!("{}", tail(&String::from_utf8_lossy(&o.stdout), 40));
            return Err(fail(1, "fb render: pdflatex failed"));
        }
        let aux = read_back(dir);
        if prev.as_ref() == Some(&aux) {
            return Ok(());
        }
        prev = Some(aux);
    }
    Err(fail(
        1,
        "fb render: doc.aux did not settle in 5 pdflatex passes",
    ))
}

/// The files of `dir` a pdflatex pass writes and the next one reads: every doc.* but the .tex, .pdf and .log,
/// by name.
fn read_back(dir: &Path) -> Vec<(String, Vec<u8>)> {
    let mut files: Vec<_> = std::fs::read_dir(dir)
        .into_iter()
        .flatten()
        .flatten()
        .filter_map(|e| {
            let name = e.file_name().to_string_lossy().into_owned();
            let ext = name.strip_prefix("doc.")?;
            (!["tex", "pdf", "log"].contains(&ext))
                .then(|| (name.clone(), std::fs::read(e.path()).unwrap_or_default()))
        })
        .collect();
    files.sort();
    files
}

/// Search-path variables a build could use to reach repo-local files; the stock check runs without them.
const LOCAL_PATH_VARS: [&str; 9] = [
    "TEXINPUTS",
    "TEXMFHOME",
    "TEXFONTMAPS",
    "TFMFONTS",
    "T1FONTS",
    "ENCFONTS",
    "VFFONTS",
    "TTFONTS",
    "OPENTYPEFONTS",
];

/// The interop promise of the latex engine: a stranger compiles our .tex with stock pdflatex on stock TeX Live.
/// `src` (the generated doc.tex) must not name the repo, and must compile alone in an empty directory with
/// TEXINPUTS (and the other search-path variables) unset.
fn stock_check(root: &Path, tex: &Path, src: &str, pdflatex: &Path) -> Res<()> {
    let r = root.display().to_string();
    if !r.is_empty() && r != "/" && src.contains(&r) {
        return Err(fail(
            1,
            format!("fb render: stock pdflatex check: the .tex names a repo path ({r})"),
        ));
    }
    let dir = TempDir::new("stock-tex")?;
    std::fs::copy(tex, dir.path().join("doc.tex"))
        .map_err(|e| fail(2, format!("fb render: stock pdflatex check: {e}")))?;
    let mut cmd = Command::new(pdflatex);
    cmd.args(PDFLATEX_ARGS).current_dir(dir.path());
    for v in LOCAL_PATH_VARS {
        cmd.env_remove(v);
    }
    let o = capture(&mut cmd)?;
    if o.status.success() && dir.path().join("doc.pdf").is_file() {
        return Ok(());
    }
    eprintln!("{}", tail(&String::from_utf8_lossy(&o.stdout), 20));
    Err(fail(
        1,
        "fb render: stock pdflatex check: doc.tex does not compile alone in an empty directory with TEXINPUTS unset",
    ))
}

/// Run each command in `dir`, logging to build.log; on failure print the last `keep` log lines.
fn build(dir: &Path, passes: &[&[&str]], keep: usize) -> Res<()> {
    let mut log = String::new();
    for p in passes {
        let mut cmd = Command::new(p[0]);
        cmd.args(&p[1..]).current_dir(dir);
        let o = capture(&mut cmd)?;
        log.push_str(&String::from_utf8_lossy(&o.stdout));
        log.push_str(&String::from_utf8_lossy(&o.stderr));
        if !o.status.success() {
            eprintln!("{}", tail(&log, keep));
            return Err(fail(1, format!("fb render: {} failed", p[0])));
        }
    }
    Ok(())
}

/// Render `sample` to a .docx and its LibreOffice PDF `out_pdf` (which must end in `.docx.pdf`).
pub fn docx(court: &Path, sample: &str, out_pdf: &Path) -> Res<()> {
    let name = out_pdf.to_string_lossy();
    let docx = name
        .strip_suffix(".pdf")
        .filter(|d| d.ends_with(".docx"))
        .map(PathBuf::from)
        .ok_or_else(|| fail(2, "fb render: docx output must end in .docx.pdf"))?;
    let d = court.join("docx");
    let parent = docx.parent().unwrap_or_else(|| Path::new("."));
    std::fs::create_dir_all(parent)
        .map_err(|e| fail(2, format!("fb render: {}: {e}", parent.display())))?;
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |d| d.as_nanos());
    let temp_docx = docx.with_file_name(format!(".fb-docx-{}-{nanos}.docx", std::process::id()));
    let _cleanup = RemoveOnDrop(temp_docx.clone());
    let work = TempDir::new("docx")?;
    if d.join("render.sh").is_file() {
        if !run_owner(
            &d.join("render.sh"),
            court,
            sample,
            &temp_docx,
            Some(work.path()),
        )? {
            return Err(fail(1, "fb render: docx/render.sh failed"));
        }
        crate::docxdedupe::package(&temp_docx, work.path())?;
    } else if d.join("reference.docx").is_file() {
        let mut args = vec![
            "--to".to_string(),
            "docx".into(),
            format!("--reference-doc={}", d.join("reference.docx").display()),
        ];
        args.extend(lua_filters(&d));
        crate::docxpass::render(court, &args[2..], sample, &temp_docx, work.path())?;
    } else {
        return Err(fail(
            1,
            format!(
                "fb render: no docx template ({} or {})",
                d.join("reference.docx").display(),
                d.join("render.sh").display()
            ),
        ));
    }
    if !temp_docx.is_file() {
        return Err(fail(
            1,
            format!("fb render: {} was not written", temp_docx.display()),
        ));
    }
    crate::docxzip::repack(&temp_docx, work.path())?;
    check_docx(&temp_docx, work.path())?;
    std::fs::rename(&temp_docx, &docx).map_err(|e| {
        fail(
            2,
            format!("fb render: cannot replace {}: {e}", docx.display()),
        )
    })?;
    convert(&docx, out_pdf, work.path())
}

/// Remove an incomplete sibling render while preserving any previous completed DOCX.
struct RemoveOnDrop(PathBuf);

impl Drop for RemoveOnDrop {
    fn drop(&mut self) {
        let _ = std::fs::remove_file(&self.0);
    }
}

/// Integrity: the package checks of DEF-DOCX-OPEN (docxopen.rs); the conversion follows.
fn check_docx(docx: &Path, work: &Path) -> Res<()> {
    let found = crate::docxopen::package(docx, work)?;
    if found.is_empty() {
        return Ok(());
    }
    found.iter().for_each(|f| eprintln!("  {f}"));
    Err(fail(
        1,
        format!(
            "fb render: {} would not open ({})",
            docx.display(),
            crate::docxopen::ID
        ),
    ))
}

/// LibreOffice headless conversion of the docx to `out_pdf`.
pub(crate) fn convert(docx: &Path, out_pdf: &Path, work: &Path) -> Res<()> {
    let soffice = std::env::var_os("SOFFICE")
        .map(PathBuf::from)
        .or_else(|| which("soffice"))
        .unwrap_or_else(|| PathBuf::from("/opt/homebrew/bin/soffice"));
    let mut cmd = Command::new(&soffice);
    if let Ok(root) = crate::repo_root() {
        let conf = crate::lofonts::fontconfig(&root, work)
            .map_err(|e| fail(2, format!("fb render: {}: {e}", work.display())))?;
        cmd.env("FONTCONFIG_FILE", conf);
    }
    let o = capture(
        cmd.arg(format!(
            "-env:UserInstallation=file://{}/profile",
            work.display()
        ))
        .args(["--headless", "--convert-to", "pdf", "--outdir"])
        .arg(work)
        .arg(docx),
    )?;
    if !o.status.success() {
        eprint!("{}", String::from_utf8_lossy(&o.stdout));
        eprint!("{}", String::from_utf8_lossy(&o.stderr));
        return Err(fail(1, "fb render: soffice failed"));
    }
    let stem = docx.file_stem().map(|s| s.to_string_lossy().into_owned());
    let made = work.join(format!("{}.pdf", stem.unwrap_or_default()));
    std::fs::copy(&made, out_pdf).map_err(|e| {
        fail(
            1,
            format!("fb render: no PDF from soffice ({}): {e}", made.display()),
        )
    })?;
    // LibreOffice stamps the wall-clock time into the Info dictionary and the file identifier
    crate::pdfrepro::normalize_file(out_pdf)
        .map_err(|e| fail(2, format!("fb render: {}: {e}", out_pdf.display())))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn lua_filters_are_sorted_and_only_lua() {
        let t = TempDir::new("lua-test").unwrap();
        for f in ["b.lua", "a.lua", "c.txt"] {
            std::fs::write(t.path().join(f), "").unwrap();
        }
        let got = lua_filters(t.path());
        assert_eq!(got.len(), 2);
        assert!(got[0].ends_with("a.lua") && got[1].ends_with("b.lua"));
    }

    #[test]
    fn docx_output_must_end_in_docx_pdf() {
        let e = docx(Path::new("/nonexistent"), "x.md", Path::new("/tmp/out.pdf")).unwrap_err();
        assert_eq!(e.code, 2);
        assert!(e.msg.contains(".docx.pdf"));
    }

    #[test]
    fn latex_without_template_fails() {
        let t = TempDir::new("latex-test").unwrap();
        let e = latex(t.path(), t.path(), "x.md", &t.path().join("o.pdf")).unwrap_err();
        assert!(e.msg.contains("no latex template"));
    }

    #[test]
    fn pdflatex_is_the_default_and_fontspec_templates_stay_on_tectonic() {
        assert_eq!(latex_engine(None, "\\usepackage{newtxtext}"), "pdflatex");
        assert_eq!(latex_engine(Some(""), "x"), "pdflatex");
        assert_eq!(latex_engine(None, "\\usepackage{fontspec}"), "tectonic");
        assert_eq!(latex_engine(Some("xelatex"), "x"), "xelatex");
        assert_eq!(
            latex_engine(Some("pdflatex"), "\\usepackage{fontspec}"),
            "pdflatex"
        );
    }

    #[test]
    fn stock_check_rejects_a_tex_that_names_the_repo() {
        let t = TempDir::new("stock-test").unwrap();
        let src = format!("\\input{{{}/lib/x.tex}}", t.path().display());
        let e = stock_check(
            t.path(),
            &t.path().join("doc.tex"),
            &src,
            Path::new("pdflatex"),
        )
        .unwrap_err();
        assert!(e.msg.contains("names a repo path"));
    }

    #[test]
    fn read_back_holds_the_lists_but_not_the_output() {
        let t = TempDir::new("readback-test").unwrap();
        for f in [
            "doc.aux", "doc.toc", "doc.adt", "doc.tex", "doc.pdf", "doc.log", "x.aux",
        ] {
            std::fs::write(t.path().join(f), f).unwrap();
        }
        let names: Vec<_> = read_back(t.path()).into_iter().map(|(n, _)| n).collect();
        assert_eq!(names, ["doc.adt", "doc.aux", "doc.toc"]);
    }

    #[test]
    fn owner_script_must_write_the_output() {
        let t = TempDir::new("owner-test").unwrap();
        std::fs::create_dir(t.path().join("latex")).unwrap();
        std::fs::write(t.path().join("latex/render.sh"), "exit 0\n").unwrap();
        let e = latex(t.path(), t.path(), "x.md", &t.path().join("o.pdf")).unwrap_err();
        assert!(e.msg.contains("did not write"));
    }
}
