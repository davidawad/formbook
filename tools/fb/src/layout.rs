//! The usage/ layout of a doc folder (a court folder, or a doc-type folder under a court): one folder
//! `<doc>/usage/` holding
//!   SOURCE.md, MASKS.json, .gitkeep, the stamps `.check-<engine>.txt` / `.match-<engine>.txt`,
//!   FILED-EXAMPLE-<id>.pdf   a filed example (a real filing)
//!   INPUT-<id>.md            a sample input
//!   OUTPUT-<id>.typst.pdf    its renders: .typst.pdf, .latex.pdf, .docx, .docx.pdf
//! `<id>` is `<doctype>[-<n>]`: `<doctype>` is the doc-type folder's own name (in a court-root folder,
//! any doc-type slug: court roots hold exemplars of several doc types), `<n>` an integer >= 2 (absent
//! means 1). Files pair by identical id: INPUT-x.md renders to OUTPUT-x.<engine>.pdf and was
//! transcribed from FILED-EXAMPLE-x.pdf when that exists. Overlays are generated, never committed,
//! into `<repo>/.overlay/<doc path>/OVERLAY-<id>.{pdf,txt}`.
//!
//! `fb usage <subcommand> <doc-dir> ...` prints these names for the shell side (see `main`).
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

pub const USAGE_DIR: &str = "usage";
pub const FILED: &str = "FILED-EXAMPLE";
pub const INPUT: &str = "INPUT";
pub const OUTPUT: &str = "OUTPUT";
pub const ENGINES: [&str; 3] = ["typst", "latex", "docx"];

/// The suffixes a file kind may carry, longest first so `.docx.pdf` is not read as `.pdf`.
fn suffixes(kind: &str) -> &'static [&'static str] {
    match kind {
        FILED => &[".pdf"],
        INPUT => &[".md"],
        OUTPUT => &[".typst.pdf", ".latex.pdf", ".docx.pdf", ".docx"],
        _ => &[],
    }
}

/// A doc-type slug: `[a-z0-9]+` words joined by single hyphens.
pub fn valid_slug(s: &str) -> bool {
    !s.is_empty()
        && s.split('-').all(|w| {
            !w.is_empty()
                && w.bytes()
                    .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit())
        })
}

/// `n` of a `-<n>` copy suffix: an integer >= 2 without a leading zero.
fn copy_number(s: &str) -> Option<u32> {
    (!s.starts_with('0') && s.bytes().all(|b| b.is_ascii_digit()))
        .then(|| s.parse().ok())
        .flatten()
        .filter(|n| *n >= 2)
}

/// `(doctype, n)` of an id `<doctype>[-<n>]` (n = 1 when absent), or None for an invalid id.
pub fn split_id(id: &str) -> Option<(&str, u32)> {
    let numbered = id
        .rsplit_once('-')
        .and_then(|(d, n)| copy_number(n).map(|n| (d, n)))
        .filter(|(d, _)| valid_slug(d));
    numbered.or_else(|| valid_slug(id).then_some((id, 1)))
}

/// `<KIND>-<id><suffix>`.
pub fn name(kind: &str, id: &str, suffix: &str) -> String {
    format!("{kind}-{id}{suffix}")
}

pub fn filed_name(id: &str) -> String {
    name(FILED, id, ".pdf")
}

pub fn input_name(id: &str) -> String {
    name(INPUT, id, ".md")
}

/// The render PDF of an engine: `.typst.pdf`, `.latex.pdf` or `.docx.pdf`.
pub fn output_name(id: &str, engine: &str) -> String {
    name(OUTPUT, id, &format!(".{engine}.pdf"))
}

/// The Word render itself (`.docx`; its PDF conversion is `output_name(.., "docx")`).
pub fn output_docx_name(id: &str) -> String {
    name(OUTPUT, id, ".docx")
}

/// `OVERLAY-<id>.<ext>` (ext pdf or txt).
pub fn overlay_name(id: &str, ext: &str) -> String {
    name("OVERLAY", id, &format!(".{ext}"))
}

/// `(id, suffix)` of a `<kind>-<id><suffix>` file name: the id runs up to the first '.', and must be
/// a valid id with an allowed suffix for the kind.
pub fn parse<'a>(kind: &str, file: &'a str) -> Option<(&'a str, &'a str)> {
    let rest = file.strip_prefix(kind)?.strip_prefix('-')?;
    let dot = rest.find('.')?;
    let (id, suffix) = rest.split_at(dot);
    (split_id(id).is_some() && suffixes(kind).contains(&suffix)).then_some((id, suffix))
}

/// The id of a `<kind>-<id>...` name, or None.
pub fn id_of<'a>(kind: &str, file: &'a str) -> Option<&'a str> {
    parse(kind, file).map(|(id, _)| id)
}

/// The fixed (non-role) names a usage/ folder may hold.
pub fn fixed_name(file: &str) -> bool {
    let fixed = matches!(file, "SOURCE.md" | "MASKS.json" | ".gitkeep");
    let stamp = [".check-", ".match-"]
        .iter()
        .any(|p| file.strip_prefix(p).is_some_and(|r| r.ends_with(".txt")));
    fixed || stamp
}

/// The nearest folder at or above `dir` that holds a court.json.
pub fn court_dir(dir: &Path) -> Option<PathBuf> {
    let abs = std::fs::canonicalize(dir).unwrap_or_else(|_| dir.to_path_buf());
    abs.ancestors()
        .find(|d| d.join("court.json").is_file())
        .map(Path::to_path_buf)
}

/// A doc folder: its doc type is its own name, or None for a court root.
#[derive(Clone, Debug, PartialEq)]
pub struct Doc {
    pub dir: PathBuf,
    pub doctype: Option<String>,
}

impl Doc {
    /// Resolve whether `dir` is a court root or a doc-type folder from the nearest court.json.
    pub fn open(dir: &Path) -> Res<Doc> {
        let court = court_dir(dir).ok_or_else(|| {
            fail(
                2,
                format!("fb: no court.json at or above {}", dir.display()),
            )
        })?;
        let abs = std::fs::canonicalize(dir).unwrap_or_else(|_| dir.to_path_buf());
        let doctype = abs
            .file_name()
            .filter(|_| abs != court)
            .map(|n| n.to_string_lossy().into_owned());
        Ok(Doc {
            dir: dir.to_path_buf(),
            doctype,
        })
    }

    /// Whether `id` belongs here: its doc type is this folder's (any slug in a court root).
    pub fn accepts(&self, id: &str) -> bool {
        split_id(id).is_some_and(|(d, _)| self.doctype.as_deref().is_none_or(|own| own == d))
    }

    /// The id a usage/ file name carries when it is a FILED-EXAMPLE, INPUT or OUTPUT name of this folder.
    pub fn file_id<'a>(&self, file: &'a str) -> Option<(&'static str, &'a str)> {
        [FILED, INPUT, OUTPUT]
            .into_iter()
            .find_map(|k| id_of(k, file).map(|id| (k, id)))
            .filter(|(_, id)| self.accepts(id))
    }

    pub fn usage(&self) -> PathBuf {
        self.dir.join(USAGE_DIR)
    }

    /// `usage/<file>`, relative to the doc folder (the form stamps and SOURCE paths use).
    pub fn rel(file: &str) -> String {
        format!("{USAGE_DIR}/{file}")
    }

    pub fn input(&self, id: &str) -> PathBuf {
        self.usage().join(input_name(id))
    }

    pub fn filed(&self, id: &str) -> PathBuf {
        self.usage().join(filed_name(id))
    }

    pub fn output(&self, id: &str, engine: &str) -> PathBuf {
        self.usage().join(output_name(id, engine))
    }

    /// Sorted, distinct ids of this folder's usage/ files of a kind (INPUT ids, FILED-EXAMPLE ids).
    pub fn ids(&self, kind: &str) -> Vec<String> {
        let mut v: Vec<String> = std::fs::read_dir(self.usage())
            .map(|rd| {
                rd.filter_map(|d| d.ok())
                    .filter_map(|d| {
                        id_of(kind, &d.file_name().to_string_lossy()).map(str::to_string)
                    })
                    .filter(|id| self.accepts(id))
                    .collect()
            })
            .unwrap_or_default();
        v.sort();
        v.dedup();
        v
    }

    /// `<root>/.overlay/<doc path relative to root>`.
    pub fn overlay_dir(&self, root: &Path) -> PathBuf {
        let abs = std::fs::canonicalize(&self.dir).unwrap_or_else(|_| self.dir.clone());
        let root = std::fs::canonicalize(root).unwrap_or_else(|_| root.to_path_buf());
        root.join(".overlay")
            .join(abs.strip_prefix(&root).unwrap_or(&abs))
    }
}

/// The FILED-EXAMPLE id paired with an INPUT id: the identical id, when that exemplar exists.
pub fn pair(input_id: &str, filed_ids: &[String]) -> Option<String> {
    filed_ids.iter().find(|s| *s == input_id).cloned()
}

const CLI: &str = "usage: fb usage doctype|dir|inputs|examples|pairs <doc-dir>\n       fb usage input|example|pair <doc-dir> <id>\n       fb usage output <doc-dir> <id> [typst|latex|docx|docx.pdf]\n       fb usage overlay <doc-dir> <id> [pdf|txt]";

/// `fb usage ...`: print a layout name for the shell side. Paths are printed as the doc dir was given.
/// `pairs` prints `<FILED-EXAMPLE.pdf> <OUTPUT.typst.pdf>` once per INPUT id with a same-id exemplar.
pub fn main(args: &[String]) -> Res<ExitCode> {
    let a: Vec<&str> = args.iter().map(String::as_str).collect();
    let (cmd, dir, rest) = match a.as_slice() {
        [c, d, rest @ ..] => (*c, Doc::open(Path::new(d))?, rest),
        _ => return Err(fail(2, CLI)),
    };
    let show = |p: PathBuf| p.to_string_lossy().into_owned();
    let lines: Vec<String> = match (cmd, rest) {
        ("doctype", []) => dir.doctype.iter().cloned().collect(),
        ("dir", []) => vec![show(dir.usage())],
        ("inputs", []) => dir.ids(INPUT),
        ("examples", []) => dir.ids(FILED),
        ("pairs", []) => {
            let filed = dir.ids(FILED);
            dir.ids(INPUT)
                .iter()
                .filter_map(|id| {
                    pair(id, &filed).map(|s| {
                        format!("{} {}", show(dir.filed(&s)), show(dir.output(id, "typst")))
                    })
                })
                .collect()
        }
        ("input", [id]) => vec![show(dir.input(id))],
        ("example", [id]) => vec![show(dir.filed(id))],
        ("pair", [id]) => {
            let s = pair(id, &dir.ids(FILED))
                .ok_or_else(|| fail(1, format!("fb usage: no {} for {id}", filed_name(id))))?;
            vec![show(dir.filed(&s))]
        }
        ("output", [id]) => vec![show(dir.output(id, "typst"))],
        ("output", [id, "docx"]) => vec![show(dir.usage().join(output_docx_name(id)))],
        ("output", [id, "docx.pdf"]) => vec![show(dir.output(id, "docx"))],
        ("output", [id, e]) if ENGINES.contains(e) => vec![show(dir.output(id, e))],
        ("overlay", [id]) => vec![show(overlay(&dir, id, "pdf")?)],
        ("overlay", [id, e @ ("pdf" | "txt")]) => vec![show(overlay(&dir, id, e)?)],
        _ => return Err(fail(2, CLI)),
    };
    lines.iter().for_each(|l| println!("{l}"));
    Ok(ExitCode::SUCCESS)
}

fn overlay(dir: &Doc, id: &str, ext: &str) -> Res<PathBuf> {
    let root = crate::repo_root()?;
    Ok(dir.overlay_dir(&root).join(overlay_name(id, ext)))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn names() {
        assert_eq!(filed_name("complaint"), "FILED-EXAMPLE-complaint.pdf");
        assert_eq!(input_name("complaint-2"), "INPUT-complaint-2.md");
        assert_eq!(
            output_name("complaint", "typst"),
            "OUTPUT-complaint.typst.pdf"
        );
        assert_eq!(
            output_name("complaint", "docx"),
            "OUTPUT-complaint.docx.pdf"
        );
        assert_eq!(output_docx_name("complaint"), "OUTPUT-complaint.docx");
        assert_eq!(
            overlay_name("complaint-3", "txt"),
            "OVERLAY-complaint-3.txt"
        );
    }

    #[test]
    fn ids() {
        assert_eq!(split_id("amicus-brief"), Some(("amicus-brief", 1)));
        assert_eq!(split_id("amicus-brief-2"), Some(("amicus-brief", 2)));
        assert_eq!(split_id("amicus-brief-10"), Some(("amicus-brief", 10)));
        assert_eq!(split_id("chapter-13-plan"), Some(("chapter-13-plan", 1)));
        // -1, -0, -02 are not copy numbers, so they stay part of the doc type
        assert_eq!(split_id("complaint-1"), Some(("complaint-1", 1)));
        assert_eq!(split_id("complaint-02"), Some(("complaint-02", 1)));
        assert_eq!(split_id("2"), Some(("2", 1)));
        for bad in ["", "-2", "a--b", "a-", "A", "a_b", "complaint.x"] {
            assert_eq!(split_id(bad), None, "{bad}");
        }
    }

    #[test]
    fn parsing() {
        assert_eq!(
            parse(OUTPUT, "OUTPUT-amicus-brief-2.docx.pdf"),
            Some(("amicus-brief-2", ".docx.pdf"))
        );
        assert_eq!(
            parse(OUTPUT, "OUTPUT-amicus-brief.docx"),
            Some(("amicus-brief", ".docx"))
        );
        assert_eq!(parse(OUTPUT, "OUTPUT-amicus-brief.pdf"), None);
        assert_eq!(
            parse(FILED, "FILED-EXAMPLE-complaint.pdf"),
            Some(("complaint", ".pdf"))
        );
        assert_eq!(parse(FILED, "FILED-EXAMPLE-complaint.typst.pdf"), None);
        assert_eq!(parse(INPUT, "INPUT-Complaint.md"), None);
        assert_eq!(parse(INPUT, "INPUT-.md"), None);
        assert_eq!(parse(INPUT, "INPUT-complaint"), None);
        assert_eq!(parse(INPUT, "SAMPLE-complaint.md"), None);
        assert_eq!(id_of(INPUT, "INPUT-complaint-2.md"), Some("complaint-2"));
    }

    /// Whether a file name may sit in this folder's usage/ (lint::paths adds the court-root vocabulary).
    fn allowed(d: &Doc, file: &str) -> bool {
        fixed_name(file) || d.file_id(file).is_some()
    }

    fn doc(doctype: Option<&str>) -> Doc {
        Doc {
            dir: PathBuf::from("d"),
            doctype: doctype.map(String::from),
        }
    }

    #[test]
    fn allowed_names() {
        let d = doc(Some("complaint"));
        for ok in [
            "SOURCE.md",
            "MASKS.json",
            ".gitkeep",
            ".check-typst.txt",
            ".match-latex.txt",
            "FILED-EXAMPLE-complaint.pdf",
            "FILED-EXAMPLE-complaint-3.pdf",
            "INPUT-complaint.md",
            "INPUT-complaint-2.md",
            "OUTPUT-complaint.typst.pdf",
            "OUTPUT-complaint-2.latex.pdf",
            "OUTPUT-complaint.docx",
            "OUTPUT-complaint.docx.pdf",
        ] {
            assert!(allowed(&d, ok), "{ok}");
        }
        for bad in [
            "OUTPUT-complaint.pdf",
            "INPUT-complaint.pdf",
            "FILED-EXAMPLE-complaint.md",
            "OVERLAY-complaint.pdf",
            "SAMPLE-complaint.pdf",
            "INPUT-complaint-1.md",
            "INPUT-answer.md",
            "INPUT-complaint-sweet.md",
            "notes.txt",
            ".diff-selftest-x.md",
        ] {
            assert!(!allowed(&d, bad), "{bad}");
        }
        let root = doc(None);
        assert!(allowed(&root, "FILED-EXAMPLE-amicus-brief-2.pdf"));
        assert!(allowed(&root, "INPUT-opening-brief.md"));
        assert!(!allowed(&root, "FILED-EXAMPLE-Amicus.pdf"));
    }

    #[test]
    fn pairing() {
        let s: Vec<String> = ["complaint", "complaint-3"].map(String::from).to_vec();
        assert_eq!(pair("complaint", &s).as_deref(), Some("complaint"));
        assert_eq!(pair("complaint-3", &s).as_deref(), Some("complaint-3"));
        assert_eq!(pair("complaint-2", &s), None);
        assert_eq!(pair("x", &[]), None);
    }

    #[test]
    fn open_resolves_doctype() {
        let t = std::env::temp_dir().join(format!("fb-layout-{}", std::process::id()));
        let dt = t.join("court/amicus-brief");
        std::fs::create_dir_all(&dt).unwrap();
        std::fs::write(t.join("court/court.json"), r#"{"alias":"x"}"#).unwrap();
        assert_eq!(Doc::open(&t.join("court")).unwrap().doctype, None);
        let d = Doc::open(&dt).unwrap();
        assert_eq!(d.doctype.as_deref(), Some("amicus-brief"));
        assert_eq!(
            d.input("amicus-brief"),
            dt.join("usage/INPUT-amicus-brief.md")
        );
        std::fs::create_dir_all(d.usage()).unwrap();
        std::fs::write(d.input("amicus-brief-2"), "").unwrap();
        std::fs::write(d.input("amicus-brief"), "").unwrap();
        std::fs::write(d.usage().join("INPUT-other.md"), "").unwrap();
        assert_eq!(d.ids(INPUT), ["amicus-brief", "amicus-brief-2"]);
        assert!(Doc::open(&t).is_err());
        let _ = std::fs::remove_dir_all(&t);
    }
}
