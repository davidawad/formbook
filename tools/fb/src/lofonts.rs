//! The fonts LibreOffice sees when `fb render --engine docx` converts a .docx to PDF.
//!
//! soffice finds fonts only through fontconfig, so a family the repo vendors (fonts/, e.g. TeX Gyre Schola)
//! but the host lacks would silently fall back to another face. `fontconfig` writes a configuration that
//! keeps the host's and adds the vendored directory and the pinned Times New Roman directory; `convert`
//! points soffice at it with FONTCONFIG_FILE.
use std::path::{Path, PathBuf};

fn xml_escape(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
}

/// The fonts.conf text: the host configuration (`system`, when it exists), then `dirs`, with a cache in `cache`.
fn conf_text(system: Option<&Path>, dirs: &[PathBuf], cache: &Path) -> String {
    let mut s = String::from(
        "<?xml version=\"1.0\"?>\n<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n<fontconfig>\n",
    );
    if let Some(sys) = system {
        s.push_str(&format!(
            "  <include ignore_missing=\"yes\">{}</include>\n",
            xml_escape(&sys.to_string_lossy())
        ));
    }
    for d in dirs {
        s.push_str(&format!(
            "  <dir>{}</dir>\n",
            xml_escape(&d.to_string_lossy())
        ));
    }
    s.push_str(&format!(
        "  <cachedir>{}</cachedir>\n</fontconfig>\n",
        xml_escape(&cache.to_string_lossy())
    ));
    s
}

/// Write `work/fonts.conf` exposing the repo's vendored fonts (and the pinned Times New Roman, when staged).
pub fn fontconfig(root: &Path, work: &Path) -> std::io::Result<PathBuf> {
    let mut dirs = vec![root.join("fonts")];
    dirs.extend(crate::pin::tnr_dir(root).ok());
    let system = std::env::var_os("FONTCONFIG_FILE")
        .map(PathBuf::from)
        .or_else(|| Some(PathBuf::from("/etc/fonts/fonts.conf")))
        .filter(|p| p.is_file());
    let conf = work.join("fonts.conf");
    std::fs::write(
        &conf,
        conf_text(system.as_deref(), &dirs, &work.join("fc-cache")),
    )?;
    Ok(conf)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn conf_adds_vendored_dirs_after_the_host_config() {
        let t = conf_text(
            Some(Path::new("/etc/fonts/fonts.conf")),
            &[PathBuf::from("/r/fonts"), PathBuf::from("/a&b")],
            Path::new("/w/fc-cache"),
        );
        let inc = t.find("<include ignore_missing=\"yes\">/etc/fonts/fonts.conf</include>");
        let dir = t.find("<dir>/r/fonts</dir>");
        assert!(inc.is_some() && dir.is_some() && inc < dir);
        assert!(t.contains("<dir>/a&amp;b</dir>"));
        assert!(t.contains("<cachedir>/w/fc-cache</cachedir>"));
        assert!(!conf_text(None, &[], Path::new("/c")).contains("<include"));
    }

    /// The vendored Schola is visible through the written configuration (needs fc-match).
    #[test]
    fn vendored_schola_resolves_through_the_conf() {
        let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
        if !crate::proc::have("fc-match") {
            if let Some(log) = std::env::var_os("TEST_SKIP_LOG") {
                let line = "SKIP lofonts::vendored_schola_resolves_through_the_conf: fc-match not on PATH\n";
                let mut f = std::fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(log)
                    .unwrap();
                std::io::Write::write_all(&mut f, line.as_bytes()).unwrap();
            }
            return;
        }
        let work = crate::proc::TempDir::new("lofonts").unwrap();
        let conf = fontconfig(&root, work.path()).unwrap();
        let o = std::process::Command::new("fc-match")
            .env("FONTCONFIG_FILE", &conf)
            .args(["-f", "%{family}|%{file}", "TeX Gyre Schola:bold"])
            .output()
            .unwrap();
        let got = String::from_utf8_lossy(&o.stdout);
        assert!(got.starts_with("TeX Gyre Schola"), "{got}");
        assert!(got.contains("fonts/tex-gyre-schola/"), "{got}");
    }
}
