//! The usage/ layout of a doc folder (a court folder, or a doc-type folder under a court): one folder
//! `<doc>/usage/` holding
//!   SOURCE.md, MASKS.json, .gitkeep, the stamps `.check-<engine>.txt` / `.match-<engine>.txt`,
//!   SAMPLE-<stem>-<id>.pdf        a filed example
//!   INPUT-<stem>-<id>.md          a sample input
//!   OUTPUT-<stem>-<id>.typst.pdf  its renders: .typst.pdf, .latex.pdf, .docx, .docx.pdf
//! `<stem>` is the alias of the nearest court.json at or above the folder, followed by `-<folder name>`
//! for a doc-type folder. `<id>` is `[a-z0-9]+`. Overlays are generated, never committed, into
//! `<repo>/.overlay/<doc path>/OVERLAY-<stem>-<id>.{pdf,txt}`.
//!
//! `fb usage <subcommand> <doc-dir> ...` prints these names for the shell side (see `main`).
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

pub const USAGE_DIR: &str = "usage";
pub const SAMPLE: &str = "SAMPLE";
pub const INPUT: &str = "INPUT";
pub const OUTPUT: &str = "OUTPUT";
pub const ENGINES: [&str; 3] = ["typst", "latex", "docx"];

/// The suffixes a file kind may carry, longest first so `.docx.pdf` is not read as `.pdf`.
fn suffixes(kind: &str) -> &'static [&'static str] {
    match kind {
        SAMPLE => &[".pdf"],
        INPUT => &[".md"],
        OUTPUT => &[".typst.pdf", ".latex.pdf", ".docx.pdf", ".docx"],
        _ => &[],
    }
}

/// An id is lowercase ASCII letters and digits, at least one.
pub fn valid_id(id: &str) -> bool {
    !id.is_empty()
        && id
            .bytes()
            .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit())
}

/// `<alias>` for a court folder, `<alias>-<doctype>` for a doc-type folder.
pub fn stem_of(alias: &str, doctype: Option<&str>) -> String {
    match doctype {
        Some(d) => format!("{alias}-{d}"),
        None => alias.to_string(),
    }
}

/// `<KIND>-<stem>-<id><suffix>`.
pub fn name(kind: &str, stem: &str, id: &str, suffix: &str) -> String {
    format!("{kind}-{stem}-{id}{suffix}")
}

pub fn sample_name(stem: &str, id: &str) -> String {
    name(SAMPLE, stem, id, ".pdf")
}

pub fn input_name(stem: &str, id: &str) -> String {
    name(INPUT, stem, id, ".md")
}

/// The render PDF of an engine: `.typst.pdf`, `.latex.pdf` or `.docx.pdf`.
pub fn output_name(stem: &str, id: &str, engine: &str) -> String {
    name(OUTPUT, stem, id, &format!(".{engine}.pdf"))
}

/// The Word render itself (`.docx`; its PDF conversion is `output_name(.., "docx")`).
pub fn output_docx_name(stem: &str, id: &str) -> String {
    name(OUTPUT, stem, id, ".docx")
}

/// `OVERLAY-<stem>-<id>.<ext>` (ext pdf or txt).
pub fn overlay_name(stem: &str, id: &str, ext: &str) -> String {
    name("OVERLAY", stem, id, &format!(".{ext}"))
}

/// `(id, suffix)` of a `<kind>-<stem>-<id><suffix>` file name: the id runs up to the first '.', and
/// must be a valid id with an allowed suffix for the kind.
pub fn parse<'a>(kind: &str, stem: &str, file: &'a str) -> Option<(&'a str, &'a str)> {
    let rest = file
        .strip_prefix(kind)?
        .strip_prefix('-')?
        .strip_prefix(stem)?
        .strip_prefix('-')?;
    let dot = rest.find('.')?;
    let (id, suffix) = rest.split_at(dot);
    (valid_id(id) && suffixes(kind).contains(&suffix)).then_some((id, suffix))
}

/// The id of a `<kind>-<stem>-<id>...` name, or None.
pub fn id_of<'a>(kind: &str, stem: &str, file: &'a str) -> Option<&'a str> {
    parse(kind, stem, file).map(|(id, _)| id)
}

/// Whether a file name may sit in the usage/ folder of a doc folder with this stem.
pub fn allowed(stem: &str, file: &str) -> bool {
    let fixed = matches!(file, "SOURCE.md" | "MASKS.json" | ".gitkeep");
    let stamp = [".check-", ".match-"]
        .iter()
        .any(|p| file.strip_prefix(p).is_some_and(|r| r.ends_with(".txt")));
    fixed
        || stamp
        || [SAMPLE, INPUT, OUTPUT]
            .iter()
            .any(|k| parse(k, stem, file).is_some())
}

/// The nearest folder at or above `dir` that holds a court.json.
pub fn court_dir(dir: &Path) -> Option<PathBuf> {
    let abs = std::fs::canonicalize(dir).unwrap_or_else(|_| dir.to_path_buf());
    abs.ancestors()
        .find(|d| d.join("court.json").is_file())
        .map(Path::to_path_buf)
}

/// The `alias` field of `<court>/court.json`.
pub fn alias(court: &Path) -> Res<String> {
    let p = court.join("court.json");
    let text =
        std::fs::read_to_string(&p).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
    let v: serde_json::Value =
        serde_json::from_str(&text).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
    v.get("alias")
        .and_then(serde_json::Value::as_str)
        .filter(|a| !a.is_empty())
        .map(str::to_string)
        .ok_or_else(|| fail(2, format!("fb: {} has no alias", p.display())))
}

/// A doc folder with its stem resolved.
#[derive(Clone, Debug, PartialEq)]
pub struct Doc {
    pub dir: PathBuf,
    pub stem: String,
}

impl Doc {
    /// Resolve the stem of `dir` from the nearest court.json.
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
            stem: stem_of(&alias(&court)?, doctype.as_deref()),
        })
    }

    pub fn usage(&self) -> PathBuf {
        self.dir.join(USAGE_DIR)
    }

    /// `usage/<file>`, relative to the doc folder (the form stamps and SOURCE paths use).
    pub fn rel(file: &str) -> String {
        format!("{USAGE_DIR}/{file}")
    }

    pub fn input(&self, id: &str) -> PathBuf {
        self.usage().join(input_name(&self.stem, id))
    }

    pub fn sample(&self, id: &str) -> PathBuf {
        self.usage().join(sample_name(&self.stem, id))
    }

    pub fn output(&self, id: &str, engine: &str) -> PathBuf {
        self.usage().join(output_name(&self.stem, id, engine))
    }

    /// Sorted ids of the usage/ files of a kind (INPUT ids, SAMPLE ids).
    pub fn ids(&self, kind: &str) -> Vec<String> {
        ids_in(&self.usage(), kind, &self.stem)
    }

    /// `<root>/.overlay/<doc path relative to root>`.
    pub fn overlay_dir(&self, root: &Path) -> PathBuf {
        let abs = std::fs::canonicalize(&self.dir).unwrap_or_else(|_| self.dir.clone());
        let root = std::fs::canonicalize(root).unwrap_or_else(|_| root.to_path_buf());
        root.join(".overlay")
            .join(abs.strip_prefix(&root).unwrap_or(&abs))
    }
}

/// Sorted, distinct ids of the `<kind>-<stem>-<id>...` files in `usage`.
pub fn ids_in(usage: &Path, kind: &str, stem: &str) -> Vec<String> {
    let mut v: Vec<String> = std::fs::read_dir(usage)
        .map(|rd| {
            rd.filter_map(|d| d.ok())
                .filter_map(|d| {
                    id_of(kind, stem, &d.file_name().to_string_lossy()).map(str::to_string)
                })
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    v.dedup();
    v
}

fn common_prefix(a: &str, b: &str) -> usize {
    a.bytes().zip(b.bytes()).take_while(|(x, y)| x == y).count()
}

fn common_suffix(a: &str, b: &str) -> usize {
    a.bytes()
        .rev()
        .zip(b.bytes().rev())
        .take_while(|(x, y)| x == y)
        .count()
}

/// The SAMPLE id paired with an INPUT id. Ids carry no hyphens, so the token-overlap heuristic
/// works on characters: an equal id wins; else the SAMPLE ids sharing the INPUT id's leading run
/// (its first "token": at least 3 characters of common prefix) compete, the longest common prefix
/// first, then the longest common suffix (the shared trailing tokens, e.g. `openingbrief`).
/// None unless the best is unique.
pub fn pair(input_id: &str, sample_ids: &[String]) -> Option<String> {
    if sample_ids.iter().any(|s| s == input_id) {
        return Some(input_id.to_string());
    }
    let scored: Vec<((usize, usize), &String)> = sample_ids
        .iter()
        .map(|s| ((common_prefix(input_id, s), common_suffix(input_id, s)), s))
        .filter(|((p, _), _)| *p >= 3)
        .collect();
    let best = scored.iter().map(|s| s.0).max()?;
    match scored
        .iter()
        .filter(|s| s.0 == best)
        .collect::<Vec<_>>()
        .as_slice()
    {
        [one] => Some(one.1.clone()),
        _ => None,
    }
}

const CLI: &str = "usage: fb usage stem|dir|inputs|samples|pairs <doc-dir>\n       fb usage input|sample|pair <doc-dir> <id>\n       fb usage output <doc-dir> <id> [typst|latex|docx|docx.pdf]\n       fb usage overlay <doc-dir> <id> [pdf|txt]";

/// `fb usage ...`: print a layout name for the shell side. Paths are printed as the doc dir was given.
/// `pairs` prints `<SAMPLE.pdf> <OUTPUT.typst.pdf>` once per INPUT id that `pair` matches uniquely.
pub fn main(args: &[String]) -> Res<ExitCode> {
    let a: Vec<&str> = args.iter().map(String::as_str).collect();
    let (cmd, dir, rest) = match a.as_slice() {
        [c, d, rest @ ..] => (*c, Doc::open(Path::new(d))?, rest),
        _ => return Err(fail(2, CLI)),
    };
    let show = |p: PathBuf| p.to_string_lossy().into_owned();
    let lines: Vec<String> = match (cmd, rest) {
        ("stem", []) => vec![dir.stem.clone()],
        ("dir", []) => vec![show(dir.usage())],
        ("inputs", []) => dir.ids(INPUT),
        ("samples", []) => dir.ids(SAMPLE),
        ("pairs", []) => {
            let samples = dir.ids(SAMPLE);
            dir.ids(INPUT)
                .iter()
                .filter_map(|id| {
                    pair(id, &samples).map(|s| {
                        format!("{} {}", show(dir.sample(&s)), show(dir.output(id, "typst")))
                    })
                })
                .collect()
        }
        ("input", [id]) => vec![show(dir.input(id))],
        ("sample", [id]) => vec![show(dir.sample(id))],
        ("pair", [id]) => {
            let s = pair(id, &dir.ids(SAMPLE))
                .ok_or_else(|| fail(1, format!("fb usage: no unique SAMPLE for {id}")))?;
            vec![show(dir.sample(&s))]
        }
        ("output", [id]) => vec![show(dir.output(id, "typst"))],
        ("output", [id, "docx"]) => vec![show(dir.usage().join(output_docx_name(&dir.stem, id)))],
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
    Ok(dir
        .overlay_dir(&root)
        .join(overlay_name(&dir.stem, id, ext)))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn names() {
        assert_eq!(stem_of("ca9", None), "ca9");
        assert_eq!(
            stem_of("calsuperct-sandiego", Some("amicus-brief")),
            "calsuperct-sandiego-amicus-brief"
        );
        assert_eq!(sample_name("ca9", "x1"), "SAMPLE-ca9-x1.pdf");
        assert_eq!(input_name("ca9", "x1"), "INPUT-ca9-x1.md");
        assert_eq!(output_name("ca9", "x1", "typst"), "OUTPUT-ca9-x1.typst.pdf");
        assert_eq!(output_name("ca9", "x1", "docx"), "OUTPUT-ca9-x1.docx.pdf");
        assert_eq!(output_docx_name("ca9", "x1"), "OUTPUT-ca9-x1.docx");
        assert_eq!(overlay_name("ca9", "x1", "txt"), "OVERLAY-ca9-x1.txt");
    }

    #[test]
    fn parsing() {
        let s = "calsuperct-sandiego-amicus-brief";
        assert_eq!(
            parse(
                OUTPUT,
                s,
                "OUTPUT-calsuperct-sandiego-amicus-brief-a1.docx.pdf"
            ),
            Some(("a1", ".docx.pdf"))
        );
        assert_eq!(
            parse(OUTPUT, s, "OUTPUT-calsuperct-sandiego-amicus-brief-a1.docx"),
            Some(("a1", ".docx"))
        );
        assert_eq!(
            parse(OUTPUT, s, "OUTPUT-calsuperct-sandiego-amicus-brief-a1.pdf"),
            None
        );
        assert_eq!(
            parse(SAMPLE, "ca9", "SAMPLE-ca9-x.pdf"),
            Some(("x", ".pdf"))
        );
        assert_eq!(parse(SAMPLE, "ca9", "SAMPLE-ca9-x.typst.pdf"), None);
        assert_eq!(parse(INPUT, "ca9", "INPUT-ca9-a-b.md"), None);
        assert_eq!(parse(INPUT, "ca9", "INPUT-ca9-A.md"), None);
        assert_eq!(parse(INPUT, "ca9", "INPUT-ca9-.md"), None);
        assert_eq!(parse(INPUT, "ca9", "INPUT-ca1-x.md"), None);
        assert_eq!(parse(INPUT, "ca9", "INPUT-ca9-x"), None);
        assert_eq!(id_of(INPUT, "ca9", "INPUT-ca9-x2.md"), Some("x2"));
    }

    #[test]
    fn allowed_names() {
        for ok in [
            "SOURCE.md",
            "MASKS.json",
            ".gitkeep",
            ".check-typst.txt",
            ".match-latex.txt",
            "SAMPLE-ca9-a1.pdf",
            "INPUT-ca9-a1.md",
            "OUTPUT-ca9-a1.typst.pdf",
            "OUTPUT-ca9-a1.latex.pdf",
            "OUTPUT-ca9-a1.docx",
            "OUTPUT-ca9-a1.docx.pdf",
        ] {
            assert!(allowed("ca9", ok), "{ok}");
        }
        for bad in [
            "OUTPUT-ca9-a1.pdf",
            "INPUT-ca9-a1.pdf",
            "SAMPLE-ca9-a1.md",
            "OVERLAY-ca9-a1.pdf",
            "FILED-EXAMPLE-x.pdf",
            "INPUT-ca9-a-1.md",
            "INPUT-ca1-a1.md",
            "notes.txt",
            ".diff-selftest-x.md",
        ] {
            assert!(!allowed("ca9", bad), "{bad}");
        }
    }

    #[test]
    fn pairing() {
        let s: Vec<String> = [
            "sweetvmcmahon261136openingbrief",
            "acaconnects2115430openingbrief",
            "rooks1604003motion",
            "rooks1604003reply",
        ]
        .map(String::from)
        .to_vec();
        assert_eq!(
            pair("sweetopeningbrief", &s).as_deref(),
            Some(s[0].as_str())
        );
        assert_eq!(pair("genericopeningbrief", &s), None);
        assert_eq!(pair("rooks", &s), None);
        assert_eq!(pair("rooksreply", &s).as_deref(), Some(s[3].as_str()));
        assert_eq!(
            pair("rooks1604003motion", &s).as_deref(),
            Some(s[2].as_str())
        );
        assert_eq!(pair("x", &[]), None);
    }

    #[test]
    fn open_resolves_stem() {
        let t = std::env::temp_dir().join(format!("fb-layout-{}", std::process::id()));
        let dt = t.join("court/amicus-brief");
        std::fs::create_dir_all(&dt).unwrap();
        std::fs::write(
            t.join("court/court.json"),
            r#"{"alias":"calsuperct-sandiego"}"#,
        )
        .unwrap();
        assert_eq!(
            Doc::open(&t.join("court")).unwrap().stem,
            "calsuperct-sandiego"
        );
        let d = Doc::open(&dt).unwrap();
        assert_eq!(d.stem, "calsuperct-sandiego-amicus-brief");
        assert_eq!(
            d.input("a1"),
            dt.join("usage/INPUT-calsuperct-sandiego-amicus-brief-a1.md")
        );
        std::fs::create_dir_all(d.usage()).unwrap();
        std::fs::write(d.input("b2"), "").unwrap();
        std::fs::write(d.input("a1"), "").unwrap();
        std::fs::write(d.usage().join("INPUT-other-z.md"), "").unwrap();
        assert_eq!(d.ids(INPUT), ["a1", "b2"]);
        assert!(Doc::open(&t).is_err());
        let _ = std::fs::remove_dir_all(&t);
    }
}
