//! Typst rendering with the one pinned, separately installed Times New Roman directory.
use crate::{fail, repo_root, Res};
use std::path::{Path, PathBuf};
use std::process::Command;

fn pinned_tnr_dir() -> Res<PathBuf> {
    let p = if cfg!(target_os = "macos") {
        "/System/Library/Fonts/Supplemental"
    } else if cfg!(target_os = "linux") {
        "/usr/share/fonts/truetype/msttcorefonts"
    } else {
        return Err(fail(
            2,
            "fb render: Times New Roman font directory is pinned only for macOS and Linux",
        ));
    };
    if !Path::new(p).is_dir() {
        return Err(fail(2, format!("fb render: pinned Times New Roman font directory is missing: {p}; install ttf-mscorefonts-installer on Linux")));
    }
    Ok(PathBuf::from(p))
}

/// usage/OUTPUT-<id>.typst.pdf for usage/INPUT-<id>.md (the same id).
fn default_out(doc: &Path, sample: &Path) -> Res<PathBuf> {
    let d = crate::layout::Doc::open(doc)?;
    let file = sample
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_default();
    crate::layout::id_of(crate::layout::INPUT, &file)
        .filter(|id| d.accepts(id))
        .map(|id| d.output(id, "typst"))
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

/// `fb render <doc-dir> <usage/INPUT-<id>.md> [out.pdf]` (Typst engine); the default output is
/// usage/OUTPUT-<id>.typst.pdf.
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    if args.len() < 2 || args.len() > 3 {
        return Err(fail(
            2,
            "usage: fb render <doc-dir> <usage/INPUT-<id>.md> [out.pdf]",
        ));
    }
    let root = repo_root()?;
    let court = Path::new(&args[0]);
    let court = if court.is_absolute() {
        court.to_path_buf()
    } else {
        root.join(court)
    };
    let sample = Path::new(&args[1]);
    let out = match args.get(2) {
        Some(p) if Path::new(p).is_absolute() => PathBuf::from(p),
        Some(p) => root.join(p),
        None => default_out(&court, sample)?,
    };
    let sample_arg = if sample.is_absolute() {
        sample.to_path_buf()
    } else {
        court.join(sample)
    };
    let sample_rel = sample_arg.strip_prefix(&court).unwrap_or(&sample_arg);
    let fonts = root.join("fonts");
    let mut command = Command::new("typst");
    command
        .current_dir(&root)
        .args(["compile", "--root"])
        .arg(&court)
        .arg("--font-path")
        .arg(&fonts);
    // A Times exemplar requires the pinned directory; otherwise it is added when present so scratch
    // copies (check-selftest mutants) that declare Times New Roman still find it.
    match pinned_tnr_dir() {
        Ok(dir) => {
            command.arg("--font-path").arg(dir);
        }
        Err(e) if crate::fonts::has_times_exemplar(&root, &court)? => return Err(e),
        Err(_) => {}
    }
    let status = command
        .arg("--ignore-system-fonts")
        .arg("--package-cache-path")
        .arg(root.join("vendor/typst-packages"))
        .arg("--input")
        .arg(format!("sample={}", sample_rel.display()))
        .arg(court.join("typst/main.typ"))
        .arg(&out)
        .status()
        .map_err(|e| fail(2, format!("fb render: cannot run typst: {e}")))?;
    if !status.success() {
        return Err(fail(1, format!("fb render: typst failed with {status}")));
    }
    println!("{}", out.display());
    Ok(std::process::ExitCode::SUCCESS)
}
