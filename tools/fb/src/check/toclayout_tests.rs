use super::*;

fn run(page: u32, top: f64, left: f64, width: f64, text: &str) -> Run {
    Run {
        page,
        top,
        left,
        width,
        height: 12.5,
        text: text.into(),
    }
}

/// The ca5 reply-brief latex TOA before fb-595.53: the first entry filled its line, so its page number wrapped
/// alone onto the next line. A later entry kept a single dot of leader: short, but accepted.
fn broken_toa() -> Vec<Run> {
    vec![
        run(4, 76.5, 220.5, 170.5, "TABLE OF AUTHORITIES"),
        run(4, 165.5, 72.0, 38.5, "Cases:"),
        run(4, 165.5, 497.0, 43.0, "Page(s)"),
        run(
            4,
            183.0,
            72.0,
            294.0,
            "Dayton Indep. Sch. Dist. v. U.S. Mineral Prods. Co.",
        ),
        run(4, 183.0, 366.0, 174.0, ", 906 F.2d 1059 (5th Cir. 1990)"),
        run(4, 200.0, 97.0, 7.0, "1"),
        run(4, 226.5, 72.0, 85.5, "Ex parte Young"),
        run(
            4,
            226.5,
            157.5,
            382.5,
            ", 209 U.S. 123 (1908) . . . . . . . . . 2, 3, 4",
        ),
        run(
            4,
            296.5,
            72.0,
            278.5,
            "Green Valley Special Util. Dist. v. City of Schertz",
        ),
        run(4, 297.0, 350.5, 189.5, ", 969 F.3d 460 (5th Cir. 2020) . 2"),
        run(4, 740.5, 302.0, 8.0, "ii"),
    ]
}

#[test]
fn page_refs() {
    for ok in [
        "1",
        "2, 3, 4",
        "passim",
        "ii",
        "12-14",
        "5 n.2",
        "3–4",
        "Add-2",
        "ER-14, ER-20",
        "12a",
    ] {
        assert!(is_page_ref(ok), "{ok}");
    }
    for no in [
        "",
        "Cir. 1990)",
        "A.",
        "2026 LX",
        "Page(s)",
        "II",
        "Add-",
        "No. 5",
    ] {
        assert!(!is_page_ref(no), "{no}");
    }
}

#[test]
fn leaders() {
    assert_eq!(leader_end("ARGUMENT . . . . 1"), Some(16));
    assert_eq!(leader_end("Heading.......... 4"), Some(17));
    assert_eq!(leader_end("(5th Cir. 2020) . 2"), None);
    assert_eq!(leader_end("U.S. 123"), None);
}

#[test]
fn flags_the_wrapped_reference_not_the_one_dot_leader() {
    let (pages, found) = text_findings(&broken_toa(), 720.0);
    assert_eq!(pages.into_iter().collect::<Vec<_>>(), [4]);
    assert_eq!(found.len(), 1, "{found:?}");
    assert!(found[0].contains("\"1\" alone on a line"));
}

#[test]
fn passes_a_clean_table_and_ignores_other_pages() {
    let runs = vec![
        run(2, 76.5, 231.0, 149.5, "TABLE OF CONTENTS"),
        run(2, 146.5, 72.0, 436.0, "ARGUMENT . . . . . . . ."),
        run(2, 146.5, 533.0, 7.0, "1"),
        run(
            2,
            197.0,
            108.0,
            400.0,
            "The Fifth Circuit Has Already Held that",
        ),
        run(
            2,
            214.0,
            108.0,
            400.0,
            "Retraction May Be Ordered . . . . . .",
        ),
        run(2, 214.0, 533.0, 7.0, "1"),
        run(5, 100.0, 300.0, 7.0, "7"), // a body page: not a table page
    ];
    let (pages, found) = text_findings(&runs, 720.0);
    assert_eq!(pages.into_iter().collect::<Vec<_>>(), [2]);
    assert!(found.is_empty(), "{found:?}");
}

#[test]
fn flags_leaders_with_nothing_after_them() {
    let runs = vec![
        run(2, 76.5, 231.0, 149.5, "TABLE OF CONTENTS"),
        run(2, 146.5, 72.0, 468.0, "ARGUMENT . . . . . . . ."),
    ];
    let (_, found) = text_findings(&runs, 720.0);
    assert!(found[0].contains("no page reference"), "{found:?}");
}

#[test]
fn continuation_pages_count() {
    let mut runs = broken_toa();
    runs.retain(|r| r.top < 190.0);
    runs.extend([
        run(5, 100.0, 72.0, 468.0, "A v. B . . . . . 3"),
        run(5, 120.0, 72.0, 468.0, "C v. D . . . . . 4"),
        run(5, 140.0, 300.0, 7.0, "9"),
    ]);
    let (pages, found) = text_findings(&runs, 720.0);
    assert_eq!(pages.into_iter().collect::<Vec<_>>(), [4, 5]);
    assert!(
        found
            .iter()
            .any(|f| f.starts_with("p.5: page reference \"9\"")),
        "{found:?}"
    );
}

/// A 60 x 30 pt raster: a 1 pt rule under the heading at y = 20 pt, and ink starting `ink_at` pt.
fn page(ink_at: f64) -> Gray {
    let (w, h) = ((60.0 * PX) as usize, (30.0 * PX) as usize);
    let mut px = vec![255u8; w * h];
    let mut fill = |y0: f64, y1: f64, x0: f64, x1: f64| {
        for y in (y0 * PX) as usize..(y1 * PX) as usize {
            for x in (x0 * PX) as usize..(x1 * PX) as usize {
                px[y * w + x] = 0;
            }
        }
    };
    fill(20.0, 21.0, 10.0, 50.0);
    fill(ink_at, 29.0, 30.0, 34.0);
    Gray { w, h, px }
}

#[test]
fn rule_clearance_needs_two_points() {
    let head = Run {
        page: 1,
        top: 8.0,
        left: 10.0,
        width: 40.0,
        height: 12.5,
        text: "Page(s)".into(),
    };
    assert_eq!(rule_clearance(&page(22.0), &head), Some(1.0));
    assert_eq!(rule_clearance(&page(21.0), &head), Some(0.0));
    assert_eq!(rule_clearance(&page(23.5), &head), None);
    let mut pgm = format!("P5\n{} {}\n255\n", 60.0 * PX, 30.0 * PX).into_bytes();
    pgm.extend(page(22.0).px);
    let g = Gray::parse(&pgm).unwrap();
    assert_eq!((g.w, g.h), (240, 120));
}

#[test]
fn wrapped_page_lists_and_ellipses_pass() {
    let runs = vec![
        run(3, 76.5, 220.5, 170.5, "TABLE OF AUTHORITIES"),
        run(
            3,
            100.0,
            72.0,
            468.0,
            "Annual Report . . . . . . . . 11, 12, 14,",
        ),
        run(3, 117.0, 480.0, 60.0, "15, 18"),
        run(
            3,
            140.0,
            72.0,
            468.0,
            "A v. B (\"no . . . likely\") . . . . . . . . 6",
        ),
        run(
            3,
            160.0,
            72.0,
            468.0,
            "Pace v. City, 367 S.W.3d 137 . . . . . . . –",
        ),
    ];
    let (_, found) = text_findings(&runs, 720.0);
    assert!(found.is_empty(), "{found:?}");
}

#[test]
fn dot_runs() {
    assert_eq!(last_dots("Record. .  32"), Some((1, 9)));
    assert_eq!(last_dots("w.o.j.) .  .  .  .  4"), Some((4, 18)));
    assert_eq!(last_dots("case law. . . ."), Some((3, 15)));
    assert_eq!(last_dots("U.S. 123 (1908)"), None);
}
