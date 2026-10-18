//! `fb lint paths`: the usage/ layout rule (see crate::layout). Every file in a usage/ folder is
//! SOURCE.md, MASKS.json, .gitkeep, a stamp (.check-*.txt, .match-*.txt) or
//! `(SAMPLE|INPUT|OUTPUT)-<stem>-<id><suffix>` with the folder's own stem (SAMPLE .pdf, INPUT .md,
//! OUTPUT .typst.pdf/.latex.pdf/.docx/.docx.pdf). Anywhere under courts/, a samples/ or exemplars/
//! folder, an OVERLAY-* file or a FILED-EXAMPLE-* file is a finding. macOS .DS_Store files are ignored.
use crate::layout::{allowed, Doc, USAGE_DIR};
use crate::{repo_root, Res};
use std::path::Path;
use std::process::ExitCode;

/// Findings for `dir` and everything under it, paths shown relative to `base`; also the number of
/// usage/ files checked.
pub fn check_tree(base: &Path, dir: &Path) -> (usize, Vec<String>) {
    let mut found = Vec::new();
    let mut n = 0;
    walk(base, dir, &mut n, &mut found);
    found.sort();
    (n, found)
}

/// The rule over `<root>/courts`.
pub fn check(root: &Path) -> (usize, Vec<String>) {
    check_tree(root, &root.join("courts"))
}

fn finding(base: &Path, p: &Path, why: &str) -> String {
    format!(
        "LINT path {}: {why}",
        p.strip_prefix(base).unwrap_or(p).display()
    )
}

fn walk(base: &Path, dir: &Path, n: &mut usize, found: &mut Vec<String>) {
    let mut entries: Vec<_> = std::fs::read_dir(dir)
        .map(|rd| rd.filter_map(|e| e.ok()).collect())
        .unwrap_or_default();
    entries.sort_by_key(|e| e.file_name());
    for e in entries {
        let p = e.path();
        let name = e.file_name().to_string_lossy().into_owned();
        let is_dir = e.file_type().is_ok_and(|t| t.is_dir());
        match (is_dir, name.as_str()) {
            (true, "samples" | "exemplars") => found.push(finding(
                base,
                &p,
                "old layout folder (samples/ and exemplars/ are now usage/)",
            )),
            (true, USAGE_DIR) => usage(base, dir, &p, n, found),
            (true, _) => walk(base, &p, n, found),
            (false, f) if f.starts_with("OVERLAY-") => found.push(finding(
                base,
                &p,
                "overlays are generated into .overlay/, never committed",
            )),
            (false, f) if f.starts_with("FILED-EXAMPLE-") => found.push(finding(
                base,
                &p,
                "old exemplar name (now usage/SAMPLE-<stem>-<id>.pdf)",
            )),
            _ => {}
        }
    }
}

fn usage(base: &Path, doc: &Path, dir: &Path, n: &mut usize, found: &mut Vec<String>) {
    let stem = match Doc::open(doc) {
        Ok(d) => d.stem,
        Err(e) => return found.push(finding(base, dir, &e.msg)),
    };
    let mut entries: Vec<_> = std::fs::read_dir(dir)
        .map(|rd| rd.filter_map(|e| e.ok()).collect())
        .unwrap_or_default();
    entries.sort_by_key(|e| e.file_name());
    for e in entries {
        let p = e.path();
        let name = e.file_name().to_string_lossy().into_owned();
        *n += 1;
        let ok = match e.file_type().is_ok_and(|t| t.is_dir()) {
            true => false,
            false => name == ".DS_Store" || allowed(&stem, &name),
        };
        if !ok {
            found.push(finding(
                base,
                &p,
                &format!("not a usage/ name for stem {stem} (SAMPLE|INPUT|OUTPUT-{stem}-<[a-z0-9]+>.<ext>, SOURCE.md, MASKS.json, .gitkeep, .check-*.txt, .match-*.txt)"),
            ));
        }
    }
}

pub fn main() -> Res<ExitCode> {
    let root = repo_root()?;
    let (n, found) = check(&root);
    found.iter().for_each(|f| println!("{f}"));
    match found.len() {
        0 => {
            println!("RESULT: LINT PATHS PASS ({n} files)");
            Ok(ExitCode::SUCCESS)
        }
        k => {
            println!("RESULT: LINT PATHS FAIL ({k} findings)");
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tree_rule() {
        let t = std::env::temp_dir().join(format!("fb-lint-paths-{}", std::process::id()));
        let court = t.join("courts/x");
        let dt = court.join("opening-brief");
        for d in [court.join("usage"), dt.join("usage"), dt.join("samples")] {
            std::fs::create_dir_all(d).unwrap();
        }
        std::fs::write(court.join("court.json"), r#"{"alias":"ca9"}"#).unwrap();
        let touch = |p: &Path| std::fs::write(p, "").unwrap();
        touch(&court.join("usage/SAMPLE-ca9-a1.pdf"));
        touch(&court.join("usage/SOURCE.md"));
        touch(&dt.join("usage/INPUT-ca9-opening-brief-a1.md"));
        touch(&dt.join("usage/OUTPUT-ca9-opening-brief-a1.typst.pdf"));
        touch(&dt.join("usage/.check-typst.txt"));
        let (n, f) = check(&t);
        assert_eq!(n, 5);
        assert_eq!(
            f,
            [
                "LINT path courts/x/opening-brief/samples: old layout folder (samples/ and exemplars/ are now usage/)"
            ]
        );
        std::fs::remove_dir(dt.join("samples")).unwrap();
        touch(&dt.join("usage/INPUT-ca9-a1.md"));
        touch(&dt.join("OVERLAY-ca9-opening-brief-a1.pdf"));
        let (_, f) = check(&t);
        assert_eq!(f.len(), 2);
        assert!(f[0].starts_with("LINT path courts/x/opening-brief/OVERLAY-"));
        assert!(f[1].starts_with("LINT path courts/x/opening-brief/usage/INPUT-ca9-a1.md: not a usage/ name for stem ca9-opening-brief"));
        let _ = std::fs::remove_dir_all(&t);
    }
}
