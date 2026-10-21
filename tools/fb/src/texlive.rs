//! The pinned, rootless TeX Live behind the latex engine (fb-595.45). `fb bootstrap` installs it with the official
//! install-tl from the frozen TeX Live 2025 archive (tlnet-final never changes, so the install is reproducible) into
//! $FORMBOOK_HOME/texlive: scheme-basic without docs or sources, then the packages the latex templates load. No
//! conda texlive-core (it ships pdflatex without a LaTeX tree) and no system TeX. Rerunning is a no-op once
//! pdflatex and every package file are found.
use crate::proc::{capture, TempDir};
use crate::{fail, Res};
use sha2::{Digest, Sha512};
use std::path::{Path, PathBuf};
use std::process::Command;

pub const YEAR: &str = "2025";
/// The frozen TeX Live 2025 repository; FORMBOOK_TL_REPO may name another mirror of the same tlnet-final.
pub const REPO: &str =
    "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final";
/// SHA-512 of tlnet-final/install-tl-unx.tar.gz (as published beside it in the frozen archive).
const INSTALLER_SHA512: &str = "a307d7d11bcbd1f054ad0b0d476f7f12bc1a40d07445020edef8713b44453831d18a2f1722c3d2b0ea2e4fe6c06183a79d1c4049495113f412a9f5a570a8614d";

/// Packages beyond scheme-basic, each with a file that proves it is installed. newtx and its dependencies give
/// the Times faces (newtxtext, newtxmath); the rest are what the ca9 latex template loads.
pub const PACKAGES: &[(&str, &str)] = &[
    ("newtx", "newtxtext.sty"),
    ("fontaxes", "fontaxes.sty"),
    ("kastrup", "binhex.tex"),
    ("xstring", "xstring.sty"),
    ("etoolbox", "etoolbox.sty"),
    ("xpatch", "xpatch.sty"),
    ("xkeyval", "xkeyval.sty"),
    ("carlisle", "scalefnt.sty"),
    ("xcolor", "xcolor.sty"),
    ("extsizes", "extarticle.cls"),
    ("needspace", "needspace.sty"),
    ("changepage", "changepage.sty"),
    ("enumitem", "enumitem.sty"),
];

/// $FORMBOOK_HOME, default $HOME/.local/share/formbook.
pub fn home() -> PathBuf {
    std::env::var_os("FORMBOOK_HOME").map_or_else(
        || PathBuf::from(std::env::var("HOME").unwrap_or_default()).join(".local/share/formbook"),
        PathBuf::from,
    )
}

/// The platform bin directory of the TeX Live under `base` (bin/x86_64-linux, ...), if installed.
pub fn bin_dir(base: &Path) -> Option<PathBuf> {
    let mut dirs: Vec<PathBuf> = std::fs::read_dir(base.join("texlive/bin"))
        .ok()?
        .filter_map(|e| e.ok().map(|e| e.path()))
        .filter(|p| p.join("pdflatex").is_file())
        .collect();
    dirs.sort();
    dirs.into_iter().next()
}

/// The pdflatex the latex engine runs: the formbook TeX Live when installed, else the first one on PATH.
pub fn pdflatex() -> PathBuf {
    bin_dir(&home()).map_or_else(|| PathBuf::from("pdflatex"), |d| d.join("pdflatex"))
}

/// PATH with `bin` first (tlmgr runs mktexlsr, updmap and fmtutil from its own tree).
fn path_with(bin: &Path) -> std::ffi::OsString {
    let mut v = vec![bin.to_path_buf()];
    v.extend(std::env::split_paths(
        &std::env::var_os("PATH").unwrap_or_default(),
    ));
    std::env::join_paths(v).unwrap_or_default()
}

fn repo() -> String {
    std::env::var("FORMBOOK_TL_REPO").unwrap_or_else(|_| REPO.to_string())
}

/// The install-tl profile: everything inside `tl`, scheme-basic, no docs, no sources, no PATH changes.
fn profile(tl: &Path) -> String {
    let t = tl.display();
    format!(
        "selected_scheme scheme-basic\nTEXDIR {t}\nTEXMFLOCAL {t}/texmf-local\nTEXMFSYSCONFIG {t}/texmf-config\n\
         TEXMFSYSVAR {t}/texmf-var\nTEXMFCONFIG {t}/texmf-config\nTEXMFVAR {t}/texmf-var\nTEXMFHOME {t}/texmf-home\n\
         instopt_adjustpath 0\ninstopt_adjustrepo 0\ninstopt_letter 1\ninstopt_portable 1\n\
         tlpdbopt_autobackup 0\ntlpdbopt_install_docfiles 0\ntlpdbopt_install_srcfiles 0\n"
    )
}

fn sha512_hex(bytes: &[u8]) -> String {
    Sha512::digest(bytes)
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect()
}

fn run(cmd: &mut Command, what: &str) -> Res<()> {
    let st = cmd
        .status()
        .map_err(|e| fail(2, format!("fb bootstrap: cannot run {what}: {e}")))?;
    st.success()
        .then_some(())
        .ok_or_else(|| fail(1, format!("fb bootstrap: {what} failed with {st}")))
}

/// The packages whose proof file kpsewhich cannot find.
fn missing(bin: &Path) -> Res<Vec<&'static str>> {
    let mut out = vec![];
    for (pkg, file) in PACKAGES {
        let o = capture(Command::new(bin.join("kpsewhich")).arg(file))?;
        if !o.status.success() || o.stdout.is_empty() {
            out.push(*pkg);
        }
    }
    Ok(out)
}

/// Install (or repair) the TeX Live under `base`/texlive. Idempotent.
pub fn install(base: &Path) -> Res<()> {
    let tl = base.join("texlive");
    let repo = repo();
    if bin_dir(base).is_none() {
        let tmp = TempDir::new("install-tl")?;
        let tarball = tmp.path().join("install-tl-unx.tar.gz");
        let url = format!("{repo}/install-tl-unx.tar.gz");
        run(
            Command::new("curl")
                .args(["-fsSL", "-o"])
                .arg(&tarball)
                .arg(&url),
            &format!("curl {url}"),
        )?;
        let bytes = std::fs::read(&tarball).map_err(|e| fail(2, format!("fb bootstrap: {e}")))?;
        if sha512_hex(&bytes) != INSTALLER_SHA512 {
            return Err(fail(
                1,
                format!("bootstrap: install-tl-unx.tar.gz from {repo} does not match the TeX Live {YEAR} pin"),
            ));
        }
        let src = tmp.path().join("install-tl");
        std::fs::create_dir_all(&src).map_err(|e| fail(2, format!("fb bootstrap: {e}")))?;
        run(
            Command::new("tar")
                .arg("-xzf")
                .arg(&tarball)
                .arg("-C")
                .arg(&src)
                .arg("--strip-components=1"),
            "tar install-tl",
        )?;
        let prof = tmp.path().join("formbook.profile");
        std::fs::write(&prof, profile(&tl)).map_err(|e| fail(2, format!("fb bootstrap: {e}")))?;
        run(
            Command::new("perl")
                .arg(src.join("install-tl"))
                .arg("--no-interaction")
                .arg(format!("--profile={}", prof.display()))
                .arg(format!("--repository={repo}")),
            "install-tl",
        )?;
    }
    let bin = bin_dir(base).ok_or_else(|| {
        fail(
            1,
            format!(
                "bootstrap: install-tl wrote no pdflatex under {}",
                tl.display()
            ),
        )
    })?;
    let need = missing(&bin)?;
    if need.is_empty() {
        return Ok(());
    }
    run(
        Command::new(bin.join("tlmgr"))
            .env("PATH", path_with(&bin))
            .arg("--repository")
            .arg(&repo)
            .arg("install")
            .args(&need),
        "tlmgr install",
    )?;
    match missing(&bin)?.as_slice() {
        [] => Ok(()),
        left => Err(fail(
            1,
            format!("bootstrap: tlmgr did not install {}", left.join(" ")),
        )),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn profile_keeps_everything_inside_the_tree() {
        let p = profile(Path::new("/x/texlive"));
        assert!(p.starts_with("selected_scheme scheme-basic\nTEXDIR /x/texlive\n"));
        assert!(
            p.contains("tlpdbopt_install_docfiles 0\n")
                && p.contains("tlpdbopt_install_srcfiles 0\n")
        );
        assert!(p.contains("instopt_adjustpath 0\n"));
        assert!(p
            .lines()
            .filter(|l| l.starts_with("TEXMF"))
            .all(|l| l.contains(" /x/texlive/")));
    }

    #[test]
    fn repo_is_the_frozen_2025_archive() {
        assert!(REPO.ends_with("/2025/tlnet-final") && REPO.contains("/historic/"));
        assert!(PACKAGES.iter().any(|(p, _)| *p == "newtx"));
    }

    #[test]
    fn bin_dir_needs_a_pdflatex() {
        let t = TempDir::new("tl-test").unwrap();
        assert!(bin_dir(t.path()).is_none());
        let b = t.path().join("texlive/bin/x86_64-linux");
        std::fs::create_dir_all(&b).unwrap();
        assert!(bin_dir(t.path()).is_none());
        std::fs::write(b.join("pdflatex"), "").unwrap();
        assert_eq!(bin_dir(t.path()), Some(b));
    }
}
