//! Gate tests on synthetic measured documents.
use super::*;
use crate::measure::{Line, Page, Rect, Word};

/// A measured document: one string per line, words 6 pt wide per character, lines 20 pt apart.
pub fn doc(pages: &[&[&str]]) -> Measured {
    let pages = pages
        .iter()
        .enumerate()
        .map(|(pi, lines)| {
            let lines: Vec<Line> = lines
                .iter()
                .enumerate()
                .map(|(li, text)| line(text, 72.0, 100.0 + 20.0 * li as f64))
                .collect();
            Page {
                n: pi + 1,
                w: 612.0,
                h: 792.0,
                frame: measure::frame_of(&lines),
                stats: Default::default(),
                lines,
                rules: vec![],
                boxes: vec![],
                vectors: vec![],
                images: vec![],
                masked: vec![],
            }
        })
        .collect();
    Measured {
        schema: 0,
        source: String::new(),
        sha256: String::new(),
        fonts: vec![],
        pages,
    }
}

pub fn line(text: &str, left: f64, baseline: f64) -> Line {
    let mut x = left;
    let words: Vec<Word> = text
        .split_whitespace()
        .map(|w| {
            let x0 = x;
            x += 6.0 * w.chars().count() as f64;
            let r = Word {
                t: w.into(),
                x0,
                y0: baseline - 10.0,
                x1: x,
                y1: baseline + 3.0,
            };
            x += 3.0;
            r
        })
        .collect();
    Line {
        text: text.to_string(),
        baseline,
        baseline_est: false,
        left,
        right: words.last().map_or(left, |w| w.x1),
        top: baseline - 10.0,
        bottom: baseline + 3.0,
        size: 12.0,
        font: "TimesNewRomanPSMT".into(),
        bold: false,
        italic: false,
        words,
    }
}

fn tol() -> Tol {
    Tol {
        pt: 0.01,
        source: "test".into(),
    }
}

const BODY: &[&str] = &[
    "alpha beta gamma delta",
    "epsilon zeta eta theta",
    "iota kappa lambda mu",
];

fn refresh(m: &mut Measured) {
    for p in &mut m.pages {
        p.frame = measure::frame_of(&p.lines);
    }
}

#[test]
fn identical_passes_all_gates() {
    let r = diff_measured(&doc(&[BODY, BODY]), &doc(&[BODY, BODY]), &tol());
    assert!(r.pass, "{r:?}");
    let text = render_report(&r, &tol());
    assert!(text.contains("RESULT: DIFF PASS"), "{text}");
}

#[test]
fn g0_page_count_then_nothing_else() {
    let r = diff_measured(&doc(&[BODY, BODY]), &doc(&[BODY]), &tol());
    assert_eq!((r.pass, r.gate), (false, "G0"));
    assert_eq!(r.findings[0], "page count: exemplar 2, ours 1 (-1)");
    let text = render_report(&r, &tol());
    assert!(text.contains("G1 NOT RUN"), "{text}");
    assert!(text.contains("G4 NOT RUN"), "{text}");
}

#[test]
fn g1_margin_shift_is_signed_and_named() {
    let ex = doc(&[BODY]);
    let mut us = doc(&[BODY]);
    for l in &mut us.pages[0].lines {
        l.left += 3.6;
        l.right += 3.6;
    }
    refresh(&mut us);
    let r = diff_measured(&ex, &us, &tol());
    assert_eq!(r.gate, "G1");
    assert!(
        r.findings[0]
            .starts_with("p1 frame: left +3.60 (exemplar 72, ours 75.6) -> param margin_left"),
        "{:?}",
        r.findings
    );
}

#[test]
fn g2_dropped_and_swapped_paragraphs() {
    let ex = doc(&[&[
        "alpha beta gamma delta",
        "epsilon zeta eta theta",
        "iota kappa lambda mu",
    ]]);
    let us = doc(&[&[
        "alpha beta gamma delta",
        "epsilon zeta theta omega",
        "iota kappa lambda mu",
    ]]);
    let mut us = us;
    us.pages[0].frame = ex.pages[0].frame;
    let r = diff_measured(&ex, &us, &tol());
    assert_eq!(r.gate, "G2", "{r:?}");
    assert!(
        r.findings[0].starts_with("p1 line 2 (ours p1 line 2):"),
        "{:?}",
        r.findings
    );
    let us = doc(&[&[
        "epsilon zeta eta theta",
        "alpha beta gamma delta",
        "iota kappa lambda mu",
    ]]);
    let r = diff_measured(&ex, &us, &tol());
    assert_eq!(r.gate, "G2", "{r:?}");
}

#[test]
fn g3_line_break_then_positions() {
    let ex = doc(&[&["alpha beta gamma delta", "epsilon zeta eta theta"]]);
    let us = doc(&[&["alpha beta gamma", "delta epsilon zeta eta theta"]]);
    let mut us = us;
    // Same frame so G1 passes: the break is what differs.
    us.pages[0].lines[0].right = ex.pages[0].lines[0].right;
    refresh(&mut us);
    let mut us2 = us.clone();
    us2.pages[0].lines[1].right = ex.pages[0].frame.unwrap().right;
    refresh(&mut us2);
    let r = diff_measured(&ex, &us2, &tol());
    assert_eq!(r.gate, "G3", "{r:?}");
    assert!(
        r.findings[0].contains("exemplar breaks after 'delta', ours after 'gamma'"),
        "{:?}",
        r.findings
    );

    let mut us = doc(&[BODY]);
    let ex = doc(&[BODY]);
    us.pages[0].lines[1].baseline += 0.4;
    us.pages[0].lines[2].baseline += 0.4;
    us.pages[0].lines[1].left += 36.0;
    us.pages[0].lines[1].right += 36.0;
    let r = diff_measured(&ex, &us, &tol());
    assert_eq!(r.gate, "G3", "{r:?}");
    assert!(
        r.findings[0]
            .starts_with("p1 line 2 'epsilon zeta eta theta': gap to previous baseline dy=+0.40"),
        "{:?}",
        r.findings
    );
    assert!(
        r.findings[0].contains("indent dx=+36.00 -> param"),
        "{:?}",
        r.findings
    );
    assert_eq!(
        r.findings.len(),
        2,
        "line 3 only inherits the shift: {:?}",
        r.findings
    );
    assert!(
        r.findings[1].starts_with("worst instance: p1 line 2"),
        "{:?}",
        r.findings
    );
}

#[test]
fn g4_rules_and_styles() {
    let ex = doc(&[BODY]);
    let mut us = doc(&[BODY]);
    us.pages[0].rules.push(Rect {
        x0: 72.0,
        y0: 700.0,
        x1: 300.0,
        y1: 701.0,
    });
    us.pages[0].lines[0].bold = true;
    let r = diff_measured(&ex, &us, &tol());
    assert_eq!(r.gate, "G4", "{r:?}");
    assert!(
        r.findings
            .iter()
            .any(|f| f.contains("rule (72.00,700.00)-(300.00,701.00): extra in ours")),
        "{:?}",
        r.findings
    );
    assert!(
        r.findings.iter().any(|f| f
            .starts_with("p1 line 1 'alpha beta gamma delta': bold: exemplar false, ours true")),
        "{:?}",
        r.findings
    );
}

#[test]
fn region_masks_apply_to_the_render() {
    let mut ex = doc(&[BODY]);
    ex.pages[0].masked.push(measure::Masked {
        kind: "region: clerk stamp".into(),
        bbox: Rect {
            x0: 400.0,
            y0: 20.0,
            x1: 600.0,
            y1: 60.0,
        },
        text: "FILED".into(),
    });
    let mut us = doc(&[BODY]);
    us.pages[0].lines.insert(0, line("FILED", 450.0, 40.0));
    refresh(&mut us);
    assert!(diff_measured(&ex, &us, &tol()).pass);
}
