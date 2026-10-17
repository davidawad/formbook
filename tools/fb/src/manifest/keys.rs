//! The manifest's flag characters: which artifacts a court or doc-type folder holds.
//!
//! Every flag keys on committed TEXT artifacts, never on whether a PDF is on disk, so a checkout without
//! the binaries (a box snapshot) produces the same manifest as a full one:
//!   exemplars  the filed examples named in exemplars/SOURCE.md (`FILED-EXAMPLE-*.pdf`)
//!   samples    samples/*.md (court) or samples/INPUT-*.md (doc type)
//!   render     the inputs of a render are committed: a template (typst/main.typ for doc types, any
//!              file in <engine>/ for courts) and at least one samples/INPUT-*.md
//!   pass       a valid stamp samples/.check-<engine>.txt (see `stamp`)
//!   overlay    samples/OVERLAY-*.txt (the page map tools/overlay.sh writes beside the overlay PDF)
//!   review     reviews/*.md
use super::files::{bit, digit, is_file, matching, parse_sum_line, sha256_file, visible};
use std::collections::BTreeSet;
use std::fs;
use std::path::Path;

pub const ENGINES: [&str; 3] = ["typst", "latex", "docx"];

/// Distinct `FILED-EXAMPLE-<name>.pdf` names in a SOURCE.md, skipping ones that are part of a longer
/// path (`.../other-court/exemplars/FILED-EXAMPLE-x.pdf` names another folder's exemplar).
pub fn source_exemplars(text: &str) -> BTreeSet<String> {
    const P: &str = "FILED-EXAMPLE-";
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

fn exemplars(dir: &Path) -> char {
    let text = fs::read_to_string(dir.join("exemplars").join("SOURCE.md")).unwrap_or_default();
    digit(source_exemplars(&text).len())
}

fn inputs(dir: &Path) -> bool {
    !matching(&dir.join("samples"), "INPUT-", ".md").is_empty()
}

/// The sample id a stamp entry belongs to: `samples/OUTPUT-<id>{.pdf,.latex.pdf,.docx.pdf,.docx}`.
pub fn stamp_entry_id(path: &str) -> Option<&str> {
    let rest = path.strip_prefix("samples/OUTPUT-")?;
    [".latex.pdf", ".docx.pdf", ".docx", ".pdf"]
        .iter()
        .find_map(|s| rest.strip_suffix(s))
        .filter(|id| !id.is_empty())
}

/// A stamp is valid while its first line is PASS, it has more than one line, it lists at least one
/// file, and every listed file belongs to a committed sample input (samples/INPUT-<id>.md). A listed
/// file that is on disk must still match its hash; one that is absent (no binaries checked out) is
/// judged by the text alone.
pub fn stamp_ok(
    text: &str,
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
            stamp_entry_id(p).is_some_and(&has_input) && hash_of(p).is_none_or(|got| &got == h)
        })
}

fn stamp(dir: &Path, engine: &str) -> bool {
    let samples = dir.join("samples");
    fs::read(samples.join(format!(".check-{engine}.txt")))
        .map(|b| {
            stamp_ok(
                &String::from_utf8_lossy(&b),
                |id| samples.join(format!("INPUT-{id}.md")).is_file(),
                |p| sha256_file(&dir.join(p)),
            )
        })
        .unwrap_or(false)
}

/// 0 the render's inputs are not committed, 1 they are, 2 they are and the stamp is valid.
fn render_state(dir: &Path, template: bool, engine: &str) -> char {
    match (template && inputs(dir), stamp(dir, engine)) {
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

/// Eight characters: rules, exemplars, samples, typst, latex, docx, overlay, review.
pub fn court_flags(dir: &Path) -> String {
    let head = [
        bit(is_file(&dir.join("rules.md"))),
        exemplars(dir),
        digit(matching(&dir.join("samples"), "", ".md").len()),
    ];
    let engines = ENGINES.map(|e| render_state(dir, has_template(&dir.join(e)), e));
    let tail = [
        present(&dir.join("samples"), "OVERLAY-", ".txt"),
        present(&dir.join("reviews"), "", ".md"),
    ];
    head.iter().chain(&engines).chain(&tail).collect()
}

/// Six characters: template, samples, typst render, exemplars, overlay, review.
pub fn doctype_flags(dir: &Path) -> String {
    let template = is_file(&dir.join("typst").join("main.typ"));
    [
        bit(template),
        digit(matching(&dir.join("samples"), "INPUT-", ".md").len()),
        render_state(dir, template, "typst"),
        exemplars(dir),
        present(&dir.join("samples"), "OVERLAY-", ".txt"),
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
    fn exemplars_named_in_source() {
        let src = "## FILED-EXAMPLE-a-v-b.pdf\n| File | `FILED-EXAMPLE-c.1.pdf` (11 pages) |\nagain FILED-EXAMPLE-a-v-b.pdf\n\
                   - `courts/x/exemplars/FILED-EXAMPLE-other.pdf`: another folder\nFILED-EXAMPLE-notapdf.txt\n";
        let got: Vec<String> = source_exemplars(src).into_iter().collect();
        assert_eq!(got, ["FILED-EXAMPLE-a-v-b.pdf", "FILED-EXAMPLE-c.1.pdf"]);
        assert!(source_exemplars("").is_empty());
    }

    #[test]
    fn entry_ids() {
        assert_eq!(stamp_entry_id("samples/OUTPUT-a-b.pdf"), Some("a-b"));
        assert_eq!(stamp_entry_id("samples/OUTPUT-a.latex.pdf"), Some("a"));
        assert_eq!(stamp_entry_id("samples/OUTPUT-a.docx.pdf"), Some("a"));
        assert_eq!(stamp_entry_id("samples/OUTPUT-a.docx"), Some("a"));
        assert_eq!(stamp_entry_id("samples/a.pdf"), None);
        assert_eq!(stamp_entry_id("samples/OUTPUT-.pdf"), None);
    }

    #[test]
    fn stamps_judged_without_binaries() {
        let text = format!("PASS\n{H}  samples/OUTPUT-a.pdf\n");
        let input_a = |id: &str| id == "a";
        // absent file: the text decides
        assert!(stamp_ok(&text, input_a, |_| None));
        // present and matching, present and stale
        assert!(stamp_ok(&text, input_a, |_| Some(H.to_string())));
        assert!(!stamp_ok(&text, input_a, |_| Some("0".repeat(64))));
        // the sample input is gone
        assert!(!stamp_ok(&text, |_| false, |_| None));
        assert!(!stamp_ok(
            &format!("FAIL\n{H}  samples/OUTPUT-a.pdf\n"),
            input_a,
            |_| None
        ));
        assert!(!stamp_ok("PASS\njunk\n", input_a, |_| None));
        assert!(!stamp_ok(
            &format!("PASS\n{H}  samples/OUTPUT-a.pdf"),
            input_a,
            |_| None
        ));
    }
}
