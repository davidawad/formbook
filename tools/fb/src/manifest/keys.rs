//! The manifest's flag characters: which artifacts a court or doc-type folder holds.
use super::files::{bit, count, is_file, matching, stamp_valid, visible};
use std::path::Path;

pub const ENGINES: [&str; 3] = ["typst", "latex", "docx"];

/// Rendered PDFs of an engine in `dir`: typst = every samples/OUTPUT-*.pdf that is not another engine's.
fn pdfs(dir: &Path, engine: &str) -> Vec<String> {
    let samples = dir.join("samples");
    match engine {
        "typst" => matching(&samples, "OUTPUT-", ".pdf")
            .into_iter()
            .filter(|n| !n.ends_with(".latex.pdf") && !n.ends_with(".docx.pdf"))
            .collect(),
        other => matching(&samples, "OUTPUT-", &format!(".{other}.pdf")),
    }
}

/// A template directory counts when it holds anything visible.
fn has_template(dir: &Path) -> bool {
    visible(dir).iter().any(|n| dir.join(n).exists())
}

/// 0 none, 1 rendered, 2 rendered with a valid stamp.
fn render_state(dir: &Path, engine: &str) -> char {
    match (pdfs(dir, engine).is_empty(), stamp_valid(dir, engine)) {
        (true, _) => '0',
        (false, true) => '2',
        (false, false) => '1',
    }
}

/// 0 no template or no render, 1 built, 2 pass.
fn engine_state(dir: &Path, engine: &str) -> char {
    if has_template(&dir.join(engine)) {
        render_state(dir, engine)
    } else {
        '0'
    }
}

fn present(dir: &Path, prefix: &str, suffix: &str) -> char {
    bit(!matching(dir, prefix, suffix).is_empty())
}

/// Eight characters: rules, exemplars, samples, typst, latex, docx, overlay, review.
pub fn court_flags(dir: &Path) -> String {
    let head = [
        bit(is_file(&dir.join("rules.md"))),
        count(&dir.join("exemplars"), "", ".pdf"),
        count(&dir.join("samples"), "", ".md"),
    ];
    let engines = ENGINES.map(|e| engine_state(dir, e));
    let tail = [
        present(&dir.join("samples"), "OVERLAY-", ".pdf"),
        present(&dir.join("reviews"), "", ".md"),
    ];
    head.iter().chain(&engines).chain(&tail).collect()
}

/// Six characters: template, samples, typst render, exemplars, overlay, review.
pub fn doctype_flags(dir: &Path) -> String {
    [
        bit(is_file(&dir.join("typst").join("main.typ"))),
        count(&dir.join("samples"), "INPUT-", ".md"),
        render_state(dir, "typst"),
        count(&dir.join("exemplars"), "", ".pdf"),
        present(&dir.join("samples"), "OVERLAY-", ".pdf"),
        present(&dir.join("reviews"), "", ".md"),
    ]
    .iter()
    .collect()
}
