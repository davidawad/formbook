//! `fb lint paths`: the usage/ layout rule (see crate::layout). Every file in a usage/ folder is
//! SOURCE.md, MASKS.json, .gitkeep, a stamp (.check-*.txt, .match-*.txt) or
//! `(FILED-EXAMPLE|INPUT|OUTPUT)-<doctype>[-<n>]<suffix>` (FILED-EXAMPLE .pdf, INPUT .md, OUTPUT
//! .typst.pdf/.latex.pdf/.docx/.docx.pdf; n >= 2). In a doc-type folder `<doctype>` is the folder's own
//! name; in a court root it is a known doc type (a key of data/doctypes.json "doctypes" or the name of
//! any doc-type folder under courts/). Every OUTPUT needs the INPUT with its id. Anywhere under
//! courts/, a samples/ or exemplars/ folder, an OVERLAY-* file or a SAMPLE-* file is a finding. macOS
//! .DS_Store files are ignored.
use crate::layout::{court_dir, fixed_name, input_name, split_id, Doc, OUTPUT, USAGE_DIR};
use crate::{repo_root, Res};
use std::collections::BTreeSet;
use std::path::Path;
use std::process::ExitCode;

/// Folders under a court root that are never a doc type.
const NOT_DOCTYPES: [&str; 8] = [
    USAGE_DIR,
    "typst",
    "latex",
    "docx",
    "reviews",
    "samples",
    "exemplars",
    "out",
];

/// The doc types a court-root usage/ may name: data/doctypes.json "doctypes" keys plus every doc-type
/// folder (a non-court child of a court folder) under `<root>/courts`.
pub fn known_doctypes(root: &Path) -> BTreeSet<String> {
    let listed = std::fs::read_to_string(root.join("data/doctypes.json"))
        .ok()
        .and_then(|t| serde_json::from_str::<serde_json::Value>(&t).ok())
        .and_then(|v| {
            v.get("doctypes")
                .and_then(serde_json::Value::as_object)
                .map(|m| m.keys().cloned().collect::<Vec<_>>())
        })
        .unwrap_or_default();
    let mut known: BTreeSet<String> = listed.into_iter().collect();
    folders(&root.join("courts"), &mut known);
    known
}

fn subdirs(dir: &Path) -> Vec<std::path::PathBuf> {
    let mut v: Vec<_> = std::fs::read_dir(dir)
        .map(|rd| {
            rd.filter_map(|e| e.ok())
                .filter(|e| e.file_type().is_ok_and(|t| t.is_dir()))
                .map(|e| e.path())
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    v
}

fn folders(dir: &Path, known: &mut BTreeSet<String>) {
    let court = dir.join("court.json").is_file();
    for d in subdirs(dir) {
        let name = d
            .file_name()
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_default();
        let doctype =
            court && !d.join("court.json").is_file() && !NOT_DOCTYPES.contains(&name.as_str());
        if doctype {
            known.insert(name);
        } else {
            folders(&d, known);
        }
    }
}

/// Findings for `dir` and everything under it, paths shown relative to `base`; also the number of
/// usage/ files checked. `known` is the court-root doc-type vocabulary (`known_doctypes`).
pub fn check_tree(base: &Path, dir: &Path, known: &BTreeSet<String>) -> (usize, Vec<String>) {
    let mut found = Vec::new();
    let mut n = 0;
    walk(base, dir, known, &mut n, &mut found);
    found.sort();
    (n, found)
}

/// The rule over `<root>/courts`.
pub fn check(root: &Path) -> (usize, Vec<String>) {
    check_tree(root, &root.join("courts"), &known_doctypes(root))
}

fn finding(base: &Path, p: &Path, why: &str) -> String {
    format!(
        "LINT path {}: {why}",
        p.strip_prefix(base).unwrap_or(p).display()
    )
}

fn walk(base: &Path, dir: &Path, known: &BTreeSet<String>, n: &mut usize, found: &mut Vec<String>) {
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
            (true, USAGE_DIR) => usage(base, dir, &p, known, n, found),
            (true, _) => walk(base, &p, known, n, found),
            (false, f) if f.starts_with("OVERLAY-") => found.push(finding(
                base,
                &p,
                "overlays are generated into .overlay/, never committed",
            )),
            (false, f) if f.starts_with("SAMPLE-") => found.push(finding(
                base,
                &p,
                "old exemplar name (now usage/FILED-EXAMPLE-<doctype>[-<n>].pdf)",
            )),
            _ => {}
        }
    }
}

/// Why a usage/ file name is wrong for this folder, or None when it is fine.
fn verdict(
    doc: &Doc,
    known: &BTreeSet<String>,
    names: &BTreeSet<String>,
    name: &str,
) -> Option<String> {
    let scope = match &doc.doctype {
        Some(d) => format!("<doctype> {d}"),
        None => "<doctype> a known doc type (court root)".to_string(),
    };
    let shape = format!("not a usage/ name here (FILED-EXAMPLE|INPUT|OUTPUT-<doctype>[-<n>].<ext> with {scope}, n >= 2; SOURCE.md, MASKS.json, .gitkeep, .check-*.txt, .match-*.txt)");
    match (name == ".DS_Store" || fixed_name(name), doc.file_id(name)) {
        (true, _) => None,
        _ if name.starts_with("SAMPLE-") => {
            Some("old exemplar name (now usage/FILED-EXAMPLE-<doctype>[-<n>].pdf)".to_string())
        }
        _ if name.starts_with("OVERLAY-") => {
            Some("overlays are generated into .overlay/, never committed".to_string())
        }
        (false, None) => Some(shape),
        (false, Some((_, id)))
            if doc.doctype.is_none() && !split_id(id).is_some_and(|(d, _)| known.contains(d)) =>
        {
            Some(format!("{shape}: unknown doc type in a court root"))
        }
        (false, Some((OUTPUT, id))) if !names.contains(&input_name(id)) => {
            Some(format!("OUTPUT without its INPUT ({})", input_name(id)))
        }
        _ => None,
    }
}

fn usage(
    base: &Path,
    doc: &Path,
    dir: &Path,
    known: &BTreeSet<String>,
    n: &mut usize,
    found: &mut Vec<String>,
) {
    let d = match court_dir(doc).map(|_| Doc::open(doc)) {
        Some(Ok(d)) => d,
        Some(Err(e)) => return found.push(finding(base, dir, &e.msg)),
        None => return found.push(finding(base, dir, "no court.json at or above this usage/")),
    };
    let mut entries: Vec<_> = std::fs::read_dir(dir)
        .map(|rd| rd.filter_map(|e| e.ok()).collect())
        .unwrap_or_default();
    entries.sort_by_key(|e| e.file_name());
    let names: BTreeSet<String> = entries
        .iter()
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .collect();
    for e in entries {
        let p = e.path();
        let name = e.file_name().to_string_lossy().into_owned();
        *n += 1;
        let why = match e.file_type().is_ok_and(|t| t.is_dir()) {
            true => Some("a folder inside usage/".to_string()),
            false => verdict(&d, known, &names, &name),
        };
        if let Some(why) = why {
            found.push(finding(base, &p, &why));
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
        for d in [
            court.join("usage"),
            dt.join("usage"),
            dt.join("samples"),
            court.join("typst"),
            t.join("data"),
        ] {
            std::fs::create_dir_all(d).unwrap();
        }
        std::fs::write(court.join("court.json"), r#"{"alias":"ca9"}"#).unwrap();
        std::fs::write(
            t.join("data/doctypes.json"),
            r#"{"doctypes":{"amicus-brief":{}}}"#,
        )
        .unwrap();
        let known = known_doctypes(&t);
        assert_eq!(
            known.iter().collect::<Vec<_>>(),
            ["amicus-brief", "opening-brief"]
        );
        let touch = |p: &Path| std::fs::write(p, "").unwrap();
        touch(&court.join("usage/FILED-EXAMPLE-amicus-brief-2.pdf"));
        touch(&court.join("usage/FILED-EXAMPLE-opening-brief.pdf"));
        touch(&court.join("usage/SOURCE.md"));
        touch(&dt.join("usage/INPUT-opening-brief.md"));
        touch(&dt.join("usage/OUTPUT-opening-brief.typst.pdf"));
        touch(&dt.join("usage/.check-typst.txt"));
        let (n, f) = check(&t);
        assert_eq!(n, 6);
        assert_eq!(
            f,
            [
                "LINT path courts/x/opening-brief/samples: old layout folder (samples/ and exemplars/ are now usage/)"
            ]
        );
        std::fs::remove_dir(dt.join("samples")).unwrap();
        touch(&dt.join("usage/INPUT-amicus-brief.md"));
        touch(&dt.join("usage/OUTPUT-opening-brief-2.latex.pdf"));
        touch(&dt.join("OVERLAY-opening-brief.pdf"));
        touch(&dt.join("usage/SAMPLE-opening-brief.pdf"));
        touch(&court.join("usage/FILED-EXAMPLE-answer.pdf"));
        let (_, f) = check(&t);
        assert_eq!(f.len(), 5, "{f:?}");
        assert!(f[0].starts_with("LINT path courts/x/opening-brief/OVERLAY-"));
        assert!(f[1].starts_with(
            "LINT path courts/x/opening-brief/usage/INPUT-amicus-brief.md: not a usage/ name here"
        ));
        assert!(f[2].starts_with("LINT path courts/x/opening-brief/usage/OUTPUT-opening-brief-2.latex.pdf: OUTPUT without its INPUT (INPUT-opening-brief-2.md)"));
        assert!(f[3].starts_with(
            "LINT path courts/x/opening-brief/usage/SAMPLE-opening-brief.pdf: old exemplar name"
        ));
        assert!(
            f[4].starts_with("LINT path courts/x/usage/FILED-EXAMPLE-answer.pdf:")
                && f[4].ends_with("unknown doc type in a court root")
        );
        let _ = std::fs::remove_dir_all(&t);
    }
}
