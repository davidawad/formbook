//! The LaTeX and Word render engines of `fb render --engine latex|docx` (were tools/render-latex.sh and
//! tools/render-docx.sh).
//!
//! Contract (docs/EVAL-LOOP.md, "Engines"):
//!   <court>/latex/render.sh     if present it owns the build: sh render.sh <court-dir> <sample.md> <out.pdf>
//!   <court>/latex/template.tex  otherwise pandoc --template plus every latex/*.lua filter, then tectonic
//!                               (default), xelatex (LATEX_ENGINE=xelatex), or LuaLaTeX (LATEX_ENGINE=lualatex)
//!   <court>/docx/render.sh      if present it owns the .docx: sh render.sh <court-dir> <sample.md> <out.docx>
//!   <court>/docx/reference.docx otherwise pandoc --reference-doc plus every docx/*.lua filter
//! The docx is then checked (valid zip, well-formed XML parts) and converted to PDF with LibreOffice.
use crate::proc::{capture, have, tail, which, TempDir};
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

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

/// Run `sh <script> <court> <sample> <out>` with its stdout sent to our stderr; false on failure.
fn run_owner(script: &Path, court: &Path, sample: &str, out: &Path) -> Res<bool> {
    let o = capture(
        Command::new("sh")
            .arg(script)
            .arg(court)
            .arg(sample)
            .arg(out),
    )?;
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
        if !run_owner(&l.join("render.sh"), court, sample, out)? {
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
    match std::env::var("LATEX_ENGINE")
        .as_deref()
        .unwrap_or("tectonic")
    {
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
        "lualatex" => {
            let pass = [
                "lualatex",
                "-interaction=nonstopmode",
                "-halt-on-error",
                "doc.tex",
            ];
            let latex_lib = root.join("lib/latex");
            build_with_tex_path(work.path(), &[&pass, &pass], 40, &latex_lib)?
        }
        _ => return Err(fail(2, "fb render: unknown LATEX_ENGINE")),
    }
    std::fs::copy(work.path().join("doc.pdf"), out)
        .map(|_| ())
        .map_err(|e| fail(2, format!("fb render: cannot write {}: {e}", out.display())))
}

/// Run each command in `dir`, logging to build.log; on failure print the last `keep` log lines.
fn build(dir: &Path, passes: &[&[&str]], keep: usize) -> Res<()> {
    build_with_tex_path(dir, passes, keep, Path::new(""))
}

fn build_with_tex_path(dir: &Path, passes: &[&[&str]], keep: usize, tex_lib: &Path) -> Res<()> {
    let mut log = String::new();
    for p in passes {
        let mut cmd = Command::new(p[0]);
        cmd.args(&p[1..]).current_dir(dir);
        if !tex_lib.as_os_str().is_empty() {
            let tex_path = format!("{}//:", tex_lib.display());
            cmd.env("TEXINPUTS", &tex_path).env("LUAINPUTS", tex_path);
        }
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
    if d.join("render.sh").is_file() {
        if !run_owner(&d.join("render.sh"), court, sample, &temp_docx)? {
            return Err(fail(1, "fb render: docx/render.sh failed"));
        }
    } else if d.join("reference.docx").is_file() {
        let mut args = vec![
            "--to".to_string(),
            "docx".into(),
            format!("--reference-doc={}", d.join("reference.docx").display()),
        ];
        args.extend(lua_filters(&d));
        args.extend([
            sample.to_string(),
            "-o".into(),
            temp_docx.display().to_string(),
        ]);
        pandoc(court, &args)?;
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
    let work = TempDir::new("docx")?;
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

/// Integrity: a valid zip whose XML parts are well-formed (the XML check needs xmllint).
fn check_docx(docx: &Path, work: &Path) -> Res<()> {
    let zip = Command::new("unzip")
        .arg("-tq")
        .arg(docx)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map_err(|e| fail(2, format!("fb render: cannot run unzip: {e}")))?;
    if !zip.success() {
        return Err(fail(
            1,
            format!("fb render: {} is not a valid zip", docx.display()),
        ));
    }
    if !have("xmllint") {
        return Ok(());
    }
    let parts = work.join("docx-parts");
    capture(
        Command::new("unzip")
            .arg("-q")
            .arg(docx)
            .arg("-d")
            .arg(&parts),
    )?;
    let mut stack = vec![parts.clone()];
    let mut files = vec![];
    while let Some(dir) = stack.pop() {
        for e in std::fs::read_dir(&dir).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                stack.push(p);
            } else if p.extension().is_some_and(|x| x == "xml" || x == "rels") {
                files.push(p);
            }
        }
    }
    files.sort();
    for part in files {
        let ok = Command::new("xmllint")
            .arg("--noout")
            .arg(&part)
            .stderr(Stdio::null())
            .status()
            .map_err(|e| fail(2, format!("fb render: cannot run xmllint: {e}")))?
            .success();
        if !ok {
            let rel = part.strip_prefix(&parts).unwrap_or(&part);
            return Err(fail(
                1,
                format!("fb render: {} is not well-formed XML", rel.display()),
            ));
        }
    }
    Ok(())
}

/// LibreOffice headless conversion of the docx to `out_pdf`.
fn convert(docx: &Path, out_pdf: &Path, work: &Path) -> Res<()> {
    let soffice = std::env::var_os("SOFFICE")
        .map(PathBuf::from)
        .or_else(|| which("soffice"))
        .unwrap_or_else(|| PathBuf::from("/opt/homebrew/bin/soffice"));
    let o = capture(
        Command::new(&soffice)
            .arg(format!(
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
    std::fs::copy(&made, out_pdf).map(|_| ()).map_err(|e| {
        fail(
            1,
            format!("fb render: no PDF from soffice ({}): {e}", made.display()),
        )
    })
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
    fn owner_script_must_write_the_output() {
        let t = TempDir::new("owner-test").unwrap();
        std::fs::create_dir(t.path().join("latex")).unwrap();
        std::fs::write(t.path().join("latex/render.sh"), "exit 0\n").unwrap();
        let e = latex(t.path(), t.path(), "x.md", &t.path().join("o.pdf")).unwrap_err();
        assert!(e.msg.contains("did not write"));
    }
}
