//! The manifest's flag characters: which artifacts a court or doc-type folder holds.
//!
//! Every flag keys on committed TEXT artifacts, never on whether a PDF is on disk, so a checkout without
//! the binaries (a box snapshot) produces the same manifest as a full one:
//!   sources    the filed SAMPLEs named in usage/SOURCE.md (`SAMPLE-<stem>-<id>.pdf`)
//!   inputs     usage/INPUT-<stem>-<id>.md
//!   render     the inputs of a render are committed: a template (typst/main.typ for doc types, any
//!              file in <engine>/ for courts) and at least one usage/INPUT-<stem>-<id>.md
//!   pass       a valid stamp usage/.check-<engine>.txt (see `stamp`)
//!   review     reviews/*.md
//! Overlays are generated into the gitignored .overlay/ and are not a flag.
use super::files::{bit, digit, is_file, matching, parse_sum_line, sha256_file, visible};
use crate::layout::{self, Doc, INPUT, OUTPUT, USAGE_DIR};
use std::collections::BTreeSet;
use std::fs;
use std::path::Path;

pub const ENGINES: [&str; 3] = layout::ENGINES;

/// Distinct `SAMPLE-<name>.pdf` names in a SOURCE.md, skipping ones that are part of a longer name or
/// path (`.../other-court/usage/SAMPLE-x.pdf` names another folder's SAMPLE).
pub fn source_samples(text: &str) -> BTreeSet<String> {
    const P: &str = "SAMPLE-";
    let name_char = |c: char| c.is_ascii_alphanumeric() || "._-".contains(c);
    text.match_indices(P)
        .filter(|(i, _)| !text[..*i].ends_with(|c: char| c == '/' || name_char(c)))
        .filter_map(|(i, _)| {
            let run: String = text[i + P.len()..]
                .chars()
                .take_while(|c| name_char(*c))
                .collect();
            run.rfind(".pdf")
                .map(|end| format!("{P}{}.pdf", &run[..end]))
        })
        .collect()
}

fn sources(dir: &Path) -> char {
    let text = fs::read_to_string(dir.join(USAGE_DIR).join("SOURCE.md")).unwrap_or_default();
    digit(source_samples(&text).len())
}

/// The INPUT ids of the folder (none when its stem cannot be resolved).
fn input_ids(dir: &Path) -> Vec<String> {
    Doc::open(dir).map(|d| d.ids(INPUT)).unwrap_or_default()
}

/// The sample id a stamp entry belongs to: `usage/OUTPUT-<stem>-<id>{.typst.pdf,.latex.pdf,.docx.pdf,.docx}`.
pub fn stamp_entry_id<'a>(stem: &str, path: &'a str) -> Option<&'a str> {
    let file = path.strip_prefix(USAGE_DIR)?.strip_prefix('/')?;
    layout::id_of(OUTPUT, stem, file)
}

/// A stamp is valid while its first line is PASS, it has more than one line, it lists at least one
/// file, and every listed file belongs to a committed sample input (usage/INPUT-<stem>-<id>.md). A
/// listed file that is on disk must still match its hash; one that is absent (no binaries checked out)
/// is judged by the text alone.
pub fn stamp_ok(
    text: &str,
    stem: &str,
    has_input: impl Fn(&str) -> bool,
    hash_of: impl Fn(&str) -> Option<String>,
) -> bool {
    let mut lines = text.split('\n');
    let first_pass = lines.next() == Some("PASS");
    let entries: Vec<(String, &str)> = lines.filter_map(parse_sum_line).collect();
    first_pass
        && text.matches('\n').count() > 1
        && !entries.is_empty()
        && entries.iter().all(|(h, p)| {
            stamp_entry_id(stem, p).is_some_and(&has_input)
                && hash_of(p).is_none_or(|got| &got == h)
        })
}

fn stamp(dir: &Path, engine: &str) -> bool {
    let Ok(doc) = Doc::open(dir) else {
        return false;
    };
    fs::read(doc.usage().join(format!(".check-{engine}.txt")))
        .map(|b| {
            stamp_ok(
                &String::from_utf8_lossy(&b),
                &doc.stem,
                |id| doc.input(id).is_file(),
                |p| sha256_file(&dir.join(p)),
            )
        })
        .unwrap_or(false)
}

/// 0 the render's inputs are not committed, 1 they are, 2 they are and the stamp is valid.
fn render_state(dir: &Path, template: bool, engine: &str) -> char {
    match (template && !input_ids(dir).is_empty(), stamp(dir, engine)) {
        (false, _) => '0',
        (true, true) => '2',
        (true, false) => '1',
    }
}

/// A court-level template directory counts when it holds anything visible.
fn has_template(dir: &Path) -> bool {
    visible(dir).iter().any(|n| dir.join(n).exists())
}

fn present(dir: &Path, prefix: &str, suffix: &str) -> char {
    bit(!matching(dir, prefix, suffix).is_empty())
}

/// Seven characters: rules, sources, inputs, typst, latex, docx, review.
pub fn court_flags(dir: &Path) -> String {
    let head = [
        bit(is_file(&dir.join("rules.md"))),
        sources(dir),
        digit(input_ids(dir).len()),
    ];
    let engines = ENGINES.map(|e| render_state(dir, has_template(&dir.join(e)), e));
    let tail = [present(&dir.join("reviews"), "", ".md")];
    head.iter().chain(&engines).chain(&tail).collect()
}

/// Five characters: template, inputs, typst render, sources, review.
pub fn doctype_flags(dir: &Path) -> String {
    let template = is_file(&dir.join("typst").join("main.typ"));
    [
        bit(template),
        digit(input_ids(dir).len()),
        render_state(dir, template, "typst"),
        sources(dir),
        present(&dir.join("reviews"), "", ".md"),
    ]
    .iter()
    .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    const H: &str = "98ea6e4f216f2fb4b69fff9b3a44842c38686ca685f3f55dc48c5d3fb1107be4";

    #[test]
    fn samples_named_in_source() {
        let src = "## SAMPLE-ca9-avb.pdf\n| File | `SAMPLE-ca9-c1.pdf` (11 pages) |\nagain SAMPLE-ca9-avb.pdf\n\
                   - `courts/x/usage/SAMPLE-other.pdf`: another folder\nSAMPLE-notapdf.txt\nNO-SAMPLE-x.pdf\n";
        let got: Vec<String> = source_samples(src).into_iter().collect();
        assert_eq!(got, ["SAMPLE-ca9-avb.pdf", "SAMPLE-ca9-c1.pdf"]);
        assert!(source_samples("").is_empty());
    }

    #[test]
    fn entry_ids() {
        let s = "ca9-opening-brief";
        assert_eq!(
            stamp_entry_id(s, "usage/OUTPUT-ca9-opening-brief-a1.typst.pdf"),
            Some("a1")
        );
        assert_eq!(
            stamp_entry_id(s, "usage/OUTPUT-ca9-opening-brief-a.latex.pdf"),
            Some("a")
        );
        assert_eq!(
            stamp_entry_id(s, "usage/OUTPUT-ca9-opening-brief-a.docx.pdf"),
            Some("a")
        );
        assert_eq!(
            stamp_entry_id(s, "usage/OUTPUT-ca9-opening-brief-a.docx"),
            Some("a")
        );
        assert_eq!(stamp_entry_id(s, "usage/OUTPUT-ca9-opening-brief-a.pdf"), None);
        assert_eq!(stamp_entry_id(s, "usage/OUTPUT-ca9-a.typst.pdf"), None);
        assert_eq!(stamp_entry_id(s, "samples/OUTPUT-ca9-opening-brief-a.typst.pdf"), None);
        assert_eq!(stamp_entry_id(s, "usage/OUTPUT-ca9-opening-brief-.typst.pdf"), None);
    }

    #[test]
    fn stamps_judged_without_binaries() {
        let text = format!("PASS\n{H}  usage/OUTPUT-ca9-a.typst.pdf\n");
        let input_a = |id: &str| id == "a";
        let ok = |t: &str, i: &dyn Fn(&str) -> bool, h: &dyn Fn(&str) -> Option<String>| {
            stamp_ok(t, "ca9", i, h)
        };
        // absent file: the text decides
        assert!(ok(&text, &input_a, &|_| None));
        // present and matching, present and stale
        assert!(ok(&text, &input_a, &|_| Some(H.to_string())));
        assert!(!ok(&text, &input_a, &|_| Some("0".repeat(64))));
        // the sample input is gone
        assert!(!ok(&text, &|_| false, &|_| None));
        // another folder's stem
        assert!(!stamp_ok(&text, "ca1", input_a, |_| None));
        assert!(!ok(
            &format!("FAIL\n{H}  usage/OUTPUT-ca9-a.typst.pdf\n"),
            &input_a,
            &|_| None
        ));
        assert!(!ok("PASS\njunk\n", &input_a, &|_| None));
        assert!(!ok(
            &format!("PASS\n{H}  usage/OUTPUT-ca9-a.typst.pdf"),
            &input_a,
            &|_| None
        ));
    }
}
