//! Rendering tests; expected strings were taken from the real bend tracker (tools/tracker.bend at
//! fb-r53u) and the full-tree parity is recorded in the fb-nack run artifacts.
use super::compute;
use super::render::{cell, num, pct1, verdict};

#[test]
fn pct1_truncates() {
    let got: Vec<String> = [(0, 0), (1, 3), (2, 3), (1, 8), (376, 376), (8, 376), (3, 1)]
        .iter()
        .map(|&(n, d)| pct1(n, d))
        .collect();
    assert_eq!(
        got,
        ["0.0", "33.3", "66.6", "12.5", "100.0", "2.1", "300.0"]
    );
    // Bend's U32 wraps: n * 1000 past 2^32 wraps before the division
    assert_eq!(pct1(4_300_000, 4_300_000), "0.1");
}

#[test]
fn cells() {
    assert_eq!(
        [cell('0'), cell('1'), cell('2'), cell('3')],
        ["—", "built", "pass", "—"]
    );
    let ns: Vec<String> = ['0', '1', '2', '9', 'x', 'é'].map(num).to_vec();
    assert_eq!(ns, ["—", "1", "2", "9+", "x", "é"]);
    assert_eq!(verdict(&[1, 1, 1, 1, 1, 0]), "**complete**");
    assert_eq!(verdict(&[0, 1, 1, 1, 0, 1]), "missing template, overlay");
    assert_eq!(
        verdict(&[0, 0, 0, 0, 0, 0]),
        "missing template, sample, render, exemplar, overlay"
    );
}

#[test]
fn empty_input() {
    let s = compute("", "");
    assert_eq!(s.rows, "");
    assert!(s
        .summary
        .ends_with("---:|\n| **Total** | 0 | 0 | 0 | 0 | 0 | 0.0% | 0.0% | 0 | 0 | 0 | 0.0% |\n"));
    assert_eq!(
        s.doctypes,
        "| Alias | Doc type | Template | Samples | Render | Exemplars | Overlay | Gates | Typst |\n\
         |---|---|---|---:|---|---:|---|---|---|\n"
    );
    assert!(s
        .dsummary
        .ends_with("| **Total** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0.0% | 0 |\n"));
}

/// Groups are runs: "G" reappearing after "" opens a new group (from bend on cases/malformed).
#[test]
fn malformed_and_runs() {
    let m = "m1|G|l|Short flags|p|done|1992221\nm2|G|l|Six fields|p|todo\n\
             m3|G|l|Extra|p|todo|00020000|zzz|yy\n\n\nm4|G|l|Empty flags|p|todo|\n\
             m5|G|l|Long flags|p|todo|1002000012345\nm6\n|||||||\n\
             m7|G|l|Letters|p|todo|xyzabcde\nm8|G|l|nine chars|p|todo|000000001\n\
             m9|G|l|Empty manual|p||00000000\nmA|G|l|No newline at end|p|done|1\n\
             mB|G|l|Last|p|todo|11111111";
    let s = compute(m, "d6|G|dt|p|abcde\nd7|G||p|00000\n||||\nd3|G|dt|p");
    let summary: Vec<&str> = s.summary.lines().skip(2).collect();
    assert_eq!(
        summary,
        [
            "| G | 4 | 0 | 1 | 1 | 2 | 0.0% | 25.0% | 2 | 0 | 0 | 9.5% |",
            "|  | 1 | 0 | 0 | 0 | 1 | 0.0% | 0.0% | 0 | 0 | 0 | 0.0% |",
            "| G | 5 | 0 | 0 | 2 | 3 | 0.0% | 0.0% | 0 | 0 | 0 | 12.6% |",
            "| **Total** | 10 | 0 | 1 | 3 | 6 | 0.0% | 10.0% | 2 | 0 | 0 | 10.1% |",
        ]
    );
    let rows: Vec<&str> = s.rows.lines().collect();
    assert_eq!(
        rows,
        [
            "m1|todo|0|—|—|—|",
            "m3|in progress|13|pass|—|—|00010000",
            "m4|todo|0|—|—|—|",
            "m5|up for review|25|pass|—|—|10010000",
            "|todo|0|—|—|—|",
            "m7|in progress|25|—|—|—|01100000",
            "m8|todo|0|—|—|—|00000000",
            "m9|todo|0|—|—|—|00000000",
            "mA|todo|0|—|—|—|",
            "mB|in progress|38|built|built|built|10000011",
        ]
    );
    assert!(s.status.contains("\n| []() |  | todo | — | — | — | 0 |\n"));
    let dt: Vec<&str> = s.doctypes.lines().skip(2).collect();
    assert_eq!(
        dt,
        [
            "| d6 | [dt](p) | — | b | yes | d | — | — | missing template, overlay |",
            "| d7 | [](p) | — | — | — | — | — | — | missing template, sample, render, exemplar, overlay |",
        ]
    );
}

/// Flags are Unicode characters, as in bend (from cases/unicode).
#[test]
fn unicode_flags() {
    let m = "u4|G|l|Multibyte flag|p|todo|é0000000\nu5|G|l|Multibyte all|p|todo|ééééééé\n\
             u6|G|l|Multibyte eight|p|todo|éééééééé\nu7|G|l|Em dash flags|p|todo|1—2—2—1—";
    let rows: Vec<String> = compute(m, "").rows.lines().map(String::from).collect();
    assert_eq!(
        rows,
        [
            "u4|in progress|0|—|—|—|00000000",
            "u5|todo|0|—|—|—|",
            "u6|in progress|25|—|—|—|01100000",
            "u7|in progress|63|—|pass|—|11101010",
        ]
    );
    let d = compute("", "u1|Q — é|brief—x|courts/é|1é1é1é\nu3|G|dt|p|éééé").dsummary;
    assert!(d.contains("\n| Q — é | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 100.0% | 0 |\n"));
    assert!(d.ends_with("| **Total** | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 100.0% | 0 |\n"));
}
