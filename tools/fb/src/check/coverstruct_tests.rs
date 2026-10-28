use super::*;
use crate::measure::{Masked, Stats};

/// A line of `text` starting at `left`, its top at `top`: 6 pt per character, 3 pt spaces, 12 pt high.
fn line(text: &str, left: f64, top: f64) -> Line {
    let mut x = left;
    let words: Vec<Word> = text
        .split(' ')
        .filter(|w| !w.is_empty())
        .map(|w| {
            let x0 = x;
            x += 6.0 * w.chars().count() as f64;
            let word = Word {
                t: w.into(),
                x0,
                y0: top,
                x1: x,
                y1: top + 12.0,
            };
            x += 3.0;
            word
        })
        .collect();
    // a run of spaces in `text` is a column gap of 60 pt
    let mut gapped = Vec::new();
    let mut shift = 0.0;
    for (k, part) in text.split("   ").enumerate() {
        if k > 0 {
            shift += 60.0;
        }
        for w in part.split(' ').filter(|w| !w.is_empty()) {
            let src = &words[gapped.len()];
            debug_assert_eq!(src.t, w);
            gapped.push(Word {
                x0: src.x0 + shift,
                x1: src.x1 + shift,
                ..src.clone()
            });
        }
    }
    Line {
        text: text.split_whitespace().collect::<Vec<_>>().join(" "),
        baseline: top + 10.0,
        baseline_est: false,
        left: gapped.first().map_or(left, |w| w.x0),
        right: gapped.last().map_or(left, |w| w.x1),
        top,
        bottom: top + 12.0,
        size: 12.0,
        font: String::new(),
        bold: false,
        italic: false,
        words: gapped,
    }
}

/// `text` centered on the 612 pt page.
fn centered(text: &str, top: f64) -> Line {
    let w = line(text, 0.0, top).right;
    line(text, 306.0 - w / 2.0, top)
}

fn rule(y: f64) -> Rect {
    Rect {
        x0: 72.0,
        y0: y,
        x1: 540.0,
        y1: y + 1.0,
    }
}

fn page(lines: Vec<Line>, rules: Vec<Rect>) -> Page {
    Page {
        n: 1,
        w: 612.0,
        h: 792.0,
        frame: None,
        stats: Stats::default(),
        lines,
        rules,
        boxes: vec![],
        vectors: vec![],
        images: vec![],
        masked: Vec::<Masked>::new(),
    }
}

const WIDE_LINE: &str =
    "Appeal from the United States District Court for the Eastern District of Pennsylvania";

/// A third-circuit style cover: centered caption, counsel at the left margin, a date line, a rule under the parties.
fn cover(counsel_left: f64, rules: Vec<Rect>, date: bool) -> Page {
    let mut l = vec![
        centered("No. 26-1367", 72.0),
        centered("UNITED STATES COURT OF APPEALS", 100.0),
        centered("FOR THE THIRD CIRCUIT", 114.0),
        centered("Lisa Tresslar, Appellant", 150.0),
        centered("v.", 170.0),
        centered("Craig A. Dally, Appellee", 190.0),
        line(WIDE_LINE, 72.0, 240.0),
        centered("BRIEF OF APPELLANT", 280.0),
        line("Brian C. Farrell, Esquire", counsel_left, 330.0),
        line("The Gold Law Firm, P.C.", counsel_left, 344.0),
        line("Counsel for Appellant Lisa Tresslar", counsel_left, 358.0),
    ];
    if date {
        l.push(line("Date: July 27, 2026", 72.0, 400.0));
    }
    page(l, rules)
}

fn run(ex: &Page, us: &Page) -> (bool, Vec<String>) {
    let (ok, _, found) = compare(&Cover::of(ex), &Cover::of(us));
    (ok, found)
}

#[test]
fn the_same_cover_passes() {
    let c = cover(72.0, vec![rule(215.0)], true);
    assert_eq!(run(&c, &c), (true, vec![]));
}

#[test]
fn counsel_moved_to_the_middle_fails_per_line() {
    let (ok, found) = run(
        &cover(72.0, vec![rule(215.0)], true),
        &cover(306.0, vec![rule(215.0)], true),
    );
    assert!(!ok);
    assert_eq!(found.len(), 3, "{found:?}");
    assert!(found[0]
        .starts_with("alignment: \"Brian C. Farrell, Esquire\" is left in the exemplar, indented"));
}

#[test]
fn a_centered_title_set_left_fails() {
    let ex = cover(72.0, vec![], false);
    let mut us = cover(72.0, vec![], false);
    us.lines[7] = line("BRIEF OF APPELLANT", 72.0, 280.0);
    let (ok, found) = run(&ex, &us);
    assert!(!ok);
    assert_eq!(found, vec!["alignment: \"BRIEF OF APPELLANT\" is centered in the exemplar, left in ours (x 72.0-174.0)"]);
}

#[test]
fn a_paragraph_indent_or_a_full_width_line_is_not_an_alignment_difference() {
    let ex = cover(72.0, vec![], false);
    let mut us = cover(108.0, vec![], false);
    us.lines[6] = centered(WIDE_LINE, 240.0);
    assert_eq!(run(&ex, &us), (true, vec![]));
}

#[test]
fn a_block_moved_above_another_fails() {
    let ex = cover(72.0, vec![], false);
    let mut us = cover(72.0, vec![], false);
    // the docket number moves from the top to below the court's name
    us.lines[0] = centered("No. 26-1367", 130.0);
    let (ok, found) = run(&ex, &us);
    assert!(!ok);
    assert_eq!(found.len(), 1, "{found:?}");
    assert!(
        found[0].starts_with("order: \"No. 26-1367\" is below"),
        "{found:?}"
    );
}

#[test]
fn double_rules_where_the_exemplar_has_one_fail() {
    let (ok, found) = run(
        &cover(72.0, vec![rule(215.0)], false),
        &cover(72.0, vec![rule(214.0), rule(218.0)], false),
    );
    assert!(!ok);
    assert_eq!(
        found,
        vec!["rules: between \"Craig A. Dally, Appellee\" and \"Appeal from the United States District Court for...\": the exemplar has 1 horizontal rule, ours 2"]
    );
}

#[test]
fn a_typed_underscore_rule_is_a_rule() {
    let mut ex = cover(72.0, vec![], false);
    ex.lines
        .push(centered("______________________________", 205.0));
    ex.lines.sort_by(|a, b| a.top.total_cmp(&b.top));
    assert_eq!(
        run(&ex, &cover(72.0, vec![rule(215.0)], false)),
        (true, vec![])
    );
}

#[test]
fn an_underline_or_a_footnote_separator_is_not_a_rule() {
    let mut us = cover(72.0, vec![], false);
    let title = us.lines[7].clone();
    us.rules.push(Rect {
        x0: title.left,
        y0: title.bottom,
        x1: title.right,
        y1: title.bottom + 0.5,
    });
    us.rules.push(Rect {
        x0: 72.0,
        y0: 700.0,
        x1: 216.0,
        y1: 700.5,
    });
    assert_eq!(run(&cover(72.0, vec![], false), &us), (true, vec![]));
}

#[test]
fn a_missing_date_line_fails() {
    let (ok, found) = run(&cover(72.0, vec![], true), &cover(72.0, vec![], false));
    assert!(!ok);
    assert_eq!(
        found,
        vec!["date line: the exemplar's page 1 has \"Date: July 27, 2026\", ours has no date"]
    );
}

#[test]
fn caption_columns_are_segments_of_their_own() {
    let l = line("JANE DOE, Plaintiff,   )   Case No. 1:26-cv-1", 72.0, 100.0);
    let s = segments(&l);
    let texts: Vec<&str> = s.iter().map(|s| s.text.as_str()).collect();
    assert_eq!(texts, vec!["JANE DOE, Plaintiff,", "Case No. 1:26-cv-1"]);
    assert!(s.iter().all(|s| !s.alone));
    assert!(segments(&line("BRIEF OF APPELLANT", 72.0, 0.0))[0].alone);
}

#[test]
fn nothing_to_compare_passes_and_says_why() {
    let scan = page(vec![line("RECEIVED", 72.0, 72.0)], vec![]);
    let (ok, meas, _) = compare(&Cover::of(&scan), &Cover::of(&cover(72.0, vec![], false)));
    assert!(ok && meas.contains("no text layer"), "{meas}");
    let other = page(
        (0..10)
            .map(|k| {
                line(
                    &format!("unrelated notice line {k} alpha beta"),
                    72.0,
                    72.0 + 14.0 * k as f64,
                )
            })
            .collect(),
        vec![],
    );
    let (ok, meas, _) = compare(&Cover::of(&other), &Cover::of(&cover(72.0, vec![], false)));
    assert!(ok && meas.contains("not the same page"), "{meas}");
    let (ok, meas, _) = judge(None, std::path::Path::new("/nonexistent.pdf")).unwrap();
    assert!(ok && meas.contains("no same-id FILED-EXAMPLE"), "{meas}");
}

#[test]
fn dates() {
    for d in [
        "July 27, 2026",
        "Dated: Sept. 3, 2024",
        "Filed 03/04/2025",
        "DECEMBER 1, 1999",
        "Jan. 5, 2021",
    ] {
        assert!(is_date(d), "{d}");
    }
    for d in [
        "May it please the Court",
        "No. 26-1367",
        "Suite 2026",
        "March Madness LLC",
    ] {
        assert!(!is_date(d), "{d}");
    }
}

#[test]
fn the_baseline_reports_and_a_param_overrides_it() {
    let b = parse_baseline("# comment\n\ncourts/a/b typst\ncourts/a/b docx\n");
    assert_eq!(b.len(), 2);
    assert!(!gated_by("", &b, "courts/a/b", "typst"));
    assert!(gated_by("", &b, "courts/a/b", "latex"));
    assert!(gated_by("", &b, "courts/a/c", "typst"));
    assert!(gated_by("gate", &b, "courts/a/b", "typst"));
    assert!(!gated_by("report", &b, "courts/a/c", "typst"));
}

/// The committed baseline only names doc folders that exist, with an engine they have, once each, sorted: a
/// stale line (a folder moved or deleted) would silently stop gating whatever takes its path.
#[test]
fn the_committed_baseline_is_well_formed() {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let text = std::fs::read_to_string(root.join(BASELINE)).unwrap();
    let lines: Vec<&str> = text
        .lines()
        .filter(|l| !l.trim().is_empty() && !l.starts_with('#'))
        .collect();
    let mut sorted = lines.clone();
    sorted.sort_unstable();
    sorted.dedup();
    assert_eq!(
        lines, sorted,
        "{BASELINE}: lines must be sorted (LC_ALL=C sort) and unique"
    );
    for (doc, engine) in parse_baseline(&text) {
        assert!(
            ["typst", "latex", "docx"].contains(&engine.as_str()),
            "{BASELINE}: {doc}: unknown engine {engine}"
        );
        assert!(
            root.join(&doc).join("usage").is_dir(),
            "{BASELINE}: {doc} is not a doc folder (no usage/)"
        );
    }
}
