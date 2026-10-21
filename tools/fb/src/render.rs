//! Typst rendering with the one pinned, separately installed Times New Roman directory.
use crate::{fail, repo_root, Res};
use std::path::{Path, PathBuf};
use std::process::Command;

/// usage/OUTPUT-<id>.<engine>.pdf for usage/INPUT-<id>.md (the same id).
fn default_out(doc: &Path, sample: &Path, engine: &str) -> Res<PathBuf> {
    let d = crate::layout::Doc::open(doc)?;
    let file = sample
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_default();
    crate::layout::id_of(crate::layout::INPUT, &file)
        .filter(|id| d.accepts(id))
        .map(|id| d.output(id, engine))
        .ok_or_else(|| {
            fail(
                2,
                format!(
                    "fb render: {file} is not {}; name the output PDF",
                    crate::layout::input_name("<doctype>[-<n>]")
                ),
            )
        })
}

/// The creation date every engine stamps into its PDF (SOURCE_DATE_EPOCH for latex and docx).
pub(crate) const REPRO_EPOCH: &str = "1767225600";

/// Whether a typst warning is tolerated or fails the render.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Warnings {
    Allow,
    Deny,
}

/// Parsed `fb render` arguments.
#[derive(Debug, PartialEq)]
struct Opts {
    engine: String,
    warnings: Warnings,
    pos: Vec<String>,
}

fn parse_args(args: &[String]) -> Res<Opts> {
    const USAGE: &str = "usage: fb render [--engine typst|latex|docx] [--deny-warnings] <doc-dir> <usage/INPUT-<id>.md> [out.pdf]";
    let mut o = Opts {
        engine: "typst".into(),
        warnings: Warnings::Allow,
        pos: vec![],
    };
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--engine" => o.engine = it.next().ok_or_else(|| fail(2, USAGE))?.clone(),
            "--deny-warnings" => o.warnings = Warnings::Deny,
            _ => o.pos.push(a.clone()),
        }
    }
    if !matches!(o.engine.as_str(), "typst" | "latex" | "docx") {
        return Err(fail(2, format!("fb render: unknown engine {}", o.engine)));
    }
    if o.pos.len() < 2 || o.pos.len() > 3 {
        return Err(fail(2, USAGE));
    }
    Ok(o)
}

fn absolute(root: &Path, p: &str) -> PathBuf {
    let p = Path::new(p);
    if p.is_absolute() {
        p.to_path_buf()
    } else {
        root.join(p)
    }
}

/// Compile with typst; with `Warnings::Deny`, any typst warning on stderr is a failure.
fn typst(root: &Path, court: &Path, sample_rel: &Path, out: &Path, warnings: Warnings) -> Res<()> {
    crate::pin::check_typst(root)?;
    let mut command = Command::new("typst");
    command
        .current_dir(root)
        // Templates may import shared repository libraries (lib/typst). Keep the project root
        // at the repository while passing the sample path relative to that root.
        .args(["compile", "--root"])
        .arg(root)
        .arg("--font-path")
        .arg(root.join("fonts"));
    // A Times exemplar requires the pinned directory; otherwise it is added when present so scratch
    // copies (check-selftest mutants) that declare Times New Roman still find it.
    match crate::pin::tnr_dir(root) {
        Ok(dir) => {
            command.arg("--font-path").arg(dir);
        }
        Err(e) if crate::fonts::has_times_exemplar(root, court)? => return Err(e),
        Err(_) => {}
    }
    command
        .arg("--ignore-system-fonts")
        // reproducible output: a fixed creation date, so a re-render never changes the bytes that stamps and reviews hash
        .args(["--creation-timestamp", REPRO_EPOCH])
        .arg("--package-cache-path")
        .arg(root.join("vendor/typst-packages"))
        .arg("--input")
        .arg(format!(
            "sample={}",
            court
                .join(sample_rel)
                .strip_prefix(root)
                .unwrap_or(sample_rel)
                .display()
        ))
        .arg(court.join("typst/main.typ"))
        .arg(out);
    let spawn = |e: std::io::Error| fail(2, format!("fb render: cannot run typst: {e}"));
    if warnings == Warnings::Allow {
        let status = command.status().map_err(spawn)?;
        return status
            .success()
            .then_some(())
            .ok_or_else(|| fail(1, format!("fb render: typst failed with {status}")));
    }
    let o = command.output().map_err(spawn)?;
    let log = String::from_utf8_lossy(&o.stderr);
    eprint!("{log}");
    if !o.status.success() {
        return Err(fail(
            1,
            format!("fb render: typst failed with {}", o.status),
        ));
    }
    if log.trim().is_empty() {
        Ok(())
    } else {
        Err(fail(
            1,
            "fb render: typst emitted warnings; treating as failure",
        ))
    }
}

/// Render one sample (`sample` is relative to `court`, or absolute) with the engine into `out`.
pub fn render_one(
    root: &Path,
    engine: &str,
    court: &Path,
    sample: &Path,
    out: &Path,
    warnings: Warnings,
) -> Res<()> {
    std::env::set_var("SOURCE_DATE_EPOCH", REPRO_EPOCH);
    std::env::set_var("FORCE_SOURCE_DATE", "1");
    // court filters load the shared Lua modules of lib/ (lib/docx/xengine.lua: `require("docx.xengine")`)
    let lua = crate::sharedlib::lua_path(root, std::env::var("LUA_PATH").ok().as_deref());
    std::env::set_var("LUA_PATH", lua);
    let sample_arg = if sample.is_absolute() {
        sample.to_path_buf()
    } else {
        court.join(sample)
    };
    let sample_rel = sample_arg.strip_prefix(court).unwrap_or(&sample_arg);
    match engine {
        "latex" => crate::engines::latex(root, court, &sample_rel.to_string_lossy(), out),
        "docx" => crate::engines::docx(court, &sample_rel.to_string_lossy(), out),
        _ => typst(root, court, sample_rel, out, warnings),
    }
}

/// `fb render [--engine E] [--deny-warnings] <doc-dir> <usage/INPUT-<id>.md> [out.pdf]`; the default
/// output is usage/OUTPUT-<id>.<engine>.pdf.
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    let o = parse_args(args)?;
    let root = repo_root()?;
    let court = absolute(&root, &o.pos[0]);
    let sample = Path::new(&o.pos[1]);
    let out = match o.pos.get(2) {
        Some(p) => absolute(&root, p),
        None => default_out(&court, sample, &o.engine)?,
    };
    render_one(&root, &o.engine, &court, sample, &out, o.warnings)?;
    println!("{}", out.display());
    Ok(std::process::ExitCode::SUCCESS)
}

/// `fb render-latex <doc-dir> <usage/INPUT-<id>.md> [out.pdf]`, the focused LaTeX renderer entry point.
pub fn latex_main(args: &[String]) -> Res<std::process::ExitCode> {
    let mut full = vec!["--engine".to_string(), "latex".to_string()];
    full.extend_from_slice(args);
    let o = parse_args(&full)?;
    if o.engine != "latex" {
        return Err(fail(2, "fb render-latex: engine is fixed to latex"));
    }
    let root = repo_root()?;
    let court = absolute(&root, &o.pos[0]);
    let sample = Path::new(&o.pos[1]);
    let out = match o.pos.get(2) {
        Some(p) => absolute(&root, p),
        None => default_out(&court, sample, "latex")?,
    };
    render_one(&root, "latex", &court, sample, &out, Warnings::Allow)?;
    println!("{}", out.display());
    Ok(std::process::ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn v(a: &[&str]) -> Vec<String> {
        a.iter().map(|s| s.to_string()).collect()
    }

    /// Two renders of the same sample are byte-identical (skipped where typst is not installed).
    #[test]
    fn typst_render_is_reproducible() {
        let Ok(root) = repo_root() else { return };
        let court = root.join("courts/supreme-court-of-the-united-states/cert-petition");
        let have_typst = Command::new("typst").arg("--version").output().is_ok();
        if !have_typst || !court.is_dir() {
            return;
        }
        let tmp = std::env::temp_dir().join(format!("fb-repro-{}", std::process::id()));
        std::fs::create_dir_all(&tmp).unwrap();
        let sample = Path::new("usage/INPUT-cert-petition.md");
        let go = |n: &str| {
            let out = tmp.join(n);
            render_one(&root, "typst", &court, sample, &out, Warnings::Allow).unwrap();
            std::fs::read(out).unwrap()
        };
        let (a, b) = (go("a.pdf"), go("b.pdf"));
        std::thread::sleep(std::time::Duration::from_millis(1100));
        let c = go("c.pdf");
        let _ = std::fs::remove_dir_all(&tmp);
        assert!(a == b && b == c);
    }

    /// Two docx renders (the SCOTUS cert-petition, multi-pass, packed again by docxzip.rs) are byte-identical,
    /// across a zip time tick (2 s); skipped, and logged to TEST_SKIP_LOG, without pandoc, zip or LibreOffice.
    #[test]
    fn docx_render_is_reproducible() {
        let skip = |why: &str| {
            eprintln!("SKIP docx_render_is_reproducible: {why}");
            if let Some(log) = std::env::var_os("TEST_SKIP_LOG") {
                use std::io::Write;
                let mut f = std::fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(log)
                    .unwrap();
                writeln!(f, "render::tests::docx_render_is_reproducible: {why}").unwrap();
            }
        };
        let Ok(root) = repo_root() else {
            return skip("no repo root");
        };
        let court = root.join("courts/supreme-court-of-the-united-states/cert-petition");
        if !court.join("docx/reference.docx").is_file() {
            return skip("no cert-petition docx/reference.docx");
        }
        for tool in ["pandoc", "zip", "xmllint", "pdftotext"] {
            if !crate::proc::have(tool) {
                return skip(&format!("{tool} not installed"));
            }
        }
        if !crate::proc::have("soffice") && std::env::var_os("SOFFICE").is_none() {
            return skip("soffice not installed");
        }
        let tmp = std::env::temp_dir().join(format!("fb-docx-repro-{}", std::process::id()));
        std::fs::create_dir_all(&tmp).unwrap();
        let sample = Path::new("usage/INPUT-cert-petition.md");
        let go = |n: &str| {
            let out = tmp.join(format!("{n}.docx.pdf"));
            render_one(&root, "docx", &court, sample, &out, Warnings::Allow).unwrap();
            std::fs::read(tmp.join(format!("{n}.docx"))).unwrap()
        };
        let a = go("a");
        std::thread::sleep(std::time::Duration::from_millis(2100));
        let b = go("b");
        let _ = std::fs::remove_dir_all(&tmp);
        assert!(a == b, "two docx renders differ");
    }

    #[test]
    fn engine_and_flags_come_before_positionals() {
        let o = parse_args(&v(&["--engine", "docx", "--deny-warnings", "d", "s.md"])).unwrap();
        assert_eq!(o.engine, "docx");
        assert_eq!(o.warnings, Warnings::Deny);
        assert_eq!(o.pos, v(&["d", "s.md"]));
    }

    #[test]
    fn defaults_to_typst_and_rejects_bad_shapes() {
        assert_eq!(parse_args(&v(&["d", "s.md"])).unwrap().engine, "typst");
        assert!(parse_args(&v(&["d"])).is_err());
        assert!(parse_args(&v(&["a", "b", "c", "d"])).is_err());
        assert!(parse_args(&v(&["--engine", "tex", "d", "s"])).is_err());
        assert!(parse_args(&v(&["--engine"])).is_err());
    }
}
