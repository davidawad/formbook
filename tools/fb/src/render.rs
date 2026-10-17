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

/// `fb render <court-dir> <sample.md> [out.pdf]` (Typst engine).
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    if args.len() < 2 || args.len() > 3 {
        return Err(fail(
            2,
            "usage: fb render <court-dir> <sample.md> [out.pdf]",
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
    let out = args.get(2).map_or_else(
        || {
            let id = sample
                .file_stem()
                .and_then(|s| s.to_str())
                .unwrap_or("sample")
                .strip_prefix("INPUT-")
                .unwrap_or("sample");
            court.join("samples").join(format!("OUTPUT-{id}.pdf"))
        },
        |p| {
            let p = Path::new(p);
            if p.is_absolute() {
                p.to_path_buf()
            } else {
                root.join(p)
            }
        },
    );
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
    if crate::fonts::has_times_exemplar(&root, &court)? {
        command.arg("--font-path").arg(pinned_tnr_dir()?);
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
