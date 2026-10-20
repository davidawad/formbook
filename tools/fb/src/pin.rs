//! Render-environment pins (data/render-pin.json): the typst version and the exact Times New Roman files.
//! Renders must not depend on the machine, so a differing typst or TNR file is an error, never a silent fallback.
use crate::{fail, Res};
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::path::{Path, PathBuf};
use std::process::Command;

fn load(root: &Path) -> Res<Value> {
    let p = root.join("data/render-pin.json");
    let s =
        std::fs::read_to_string(&p).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
    serde_json::from_str(&s).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))
}

/// True when `version_line` (the output of `typst --version`) is the pinned release.
pub fn typst_matches(version_line: &str, pinned: &str) -> bool {
    version_line.split_whitespace().nth(1) == Some(pinned)
}

/// Fail unless `typst --version` is the pinned release.
pub fn check_typst(root: &Path) -> Res<()> {
    let pin = load(root)?;
    let want = pin["typst"].as_str().unwrap_or_default();
    let out = Command::new("typst")
        .arg("--version")
        .output()
        .map_err(|e| fail(2, format!("fb: cannot run typst: {e}")))?;
    let got = String::from_utf8_lossy(&out.stdout);
    if typst_matches(&got, want) {
        Ok(())
    } else {
        Err(fail(
            2,
            format!(
                "fb: typst {want} is pinned in data/render-pin.json but `typst --version` says {:?}",
                got.trim()
            ),
        ))
    }
}

fn sha_of(p: &Path) -> Option<String> {
    let b = std::fs::read(p).ok()?;
    Some(
        Sha256::digest(b)
            .iter()
            .map(|x| format!("{x:02x}"))
            .collect(),
    )
}

/// The files in `dir` whose SHA-256 is missing or differs from the pin.
pub fn mismatches(dir: &Path, pins: &[(String, String)]) -> Vec<String> {
    pins.iter()
        .filter(|(f, h)| sha_of(&dir.join(f)).as_deref() != Some(h.as_str()))
        .map(|(f, _)| f.clone())
        .collect()
}

fn candidates() -> Vec<PathBuf> {
    let home = std::env::var_os("HOME")
        .map(PathBuf::from)
        .unwrap_or_default();
    std::env::var_os("FB_TNR_DIR")
        .map(PathBuf::from)
        .into_iter()
        .chain([
            PathBuf::from("/usr/share/fonts/truetype/msttcorefonts"),
            home.join(".local/share/formbook/msttcorefonts"),
        ])
        .collect()
}

/// A directory holding only the four pinned Times New Roman files (staged copies), or an error naming what is wrong.
pub fn tnr_dir(root: &Path) -> Res<PathBuf> {
    let pin = load(root)?;
    let pins: Vec<(String, String)> = pin["tnr_sha256"]
        .as_object()
        .map(|m| {
            m.iter()
                .map(|(k, v)| (k.clone(), v.as_str().unwrap_or_default().to_string()))
                .collect()
        })
        .unwrap_or_default();
    let src = candidates()
        .into_iter()
        .find(|d| mismatches(d, &pins).is_empty())
        .ok_or_else(|| {
            fail(
                2,
                "fb render: no directory holds the pinned Times New Roman files (data/render-pin.json). On Linux install ttf-mscorefonts-installer; on macOS the system Times New Roman (5.01) differs, so copy the four Times_New_Roman*.ttf files from a box into ~/.local/share/formbook/msttcorefonts or point FB_TNR_DIR at them.",
            )
        })?;
    // Stage only the pinned files so no other font in the directory (Arial, ...) can be picked up.
    let stage = std::env::temp_dir().join(format!("fb-tnr-{}", &pins[0].1[..12]));
    if !mismatches(&stage, &pins).is_empty() {
        let tmp = std::env::temp_dir().join(format!("fb-tnr-tmp-{}", std::process::id()));
        std::fs::create_dir_all(&tmp).map_err(|e| fail(2, format!("fb: {e}")))?;
        std::fs::create_dir_all(&stage).map_err(|e| fail(2, format!("fb: {e}")))?;
        for (f, _) in &pins {
            std::fs::copy(src.join(f), tmp.join(f)).map_err(|e| fail(2, format!("fb: {e}")))?;
            std::fs::rename(tmp.join(f), stage.join(f)).map_err(|e| fail(2, format!("fb: {e}")))?;
        }
    }
    Ok(stage)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn typst_version_is_matched_exactly() {
        assert!(typst_matches("typst 0.15.1 (9dfd3a08)", "0.15.1"));
        assert!(typst_matches("typst 0.15.1 (unknown commit)", "0.15.1"));
        assert!(!typst_matches("typst 0.15.10 (x)", "0.15.1"));
        assert!(!typst_matches("typst 0.14.0", "0.15.1"));
        assert!(!typst_matches("", "0.15.1"));
    }

    #[test]
    fn hash_mismatch_and_missing_files_are_reported() {
        let d = std::env::temp_dir().join(format!("fb-pin-test-{}", std::process::id()));
        std::fs::create_dir_all(&d).unwrap();
        std::fs::write(d.join("a.ttf"), b"abc").unwrap();
        let abc = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad".to_string();
        let pins = vec![
            ("a.ttf".to_string(), abc.clone()),
            ("b.ttf".to_string(), abc.clone()),
        ];
        assert_eq!(mismatches(&d, &pins), vec!["b.ttf".to_string()]);
        std::fs::write(d.join("a.ttf"), b"abd").unwrap();
        assert_eq!(mismatches(&d, &pins).len(), 2);
    }
}
