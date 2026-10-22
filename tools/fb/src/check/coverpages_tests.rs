//! DEF-COVER-001 (coverpages.rs) on hand-made footer runs.
use super::{footer_number, judge, page_number, printed, Num};
use crate::check::toclayout::Run;

fn run(page: u32, top: f64, left: f64, text: &str) -> Run {
    Run {
        page,
        top,
        left,
        width: 20.0,
        height: 12.0,
        text: text.into(),
    }
}

fn arabic(value: u32) -> Option<Num> {
    Some(Num {
        value,
        roman: false,
    })
}

#[test]
fn page_numbers_in_their_usual_spellings() {
    assert_eq!(page_number("3"), arabic(3));
    assert_eq!(page_number("\u{2060}12"), arabic(12));
    assert_eq!(page_number("- 3 -"), arabic(3));
    assert_eq!(page_number("Page 3 of 12"), arabic(3));
    assert_eq!(page_number("3 of 12"), arabic(3));
    assert_eq!(page_number("C-1"), arabic(1));
    assert_eq!(
        page_number("iv"),
        Some(Num {
            value: 4,
            roman: true
        })
    );
    assert_eq!(
        page_number("XIV"),
        Some(Num {
            value: 14,
            roman: true
        })
    );
    for not in [
        "July 31, 2019",
        "civil",
        "iiii",
        "Case No. 19-1234",
        "",
        "COMPLAINT - 2",
        "12345",
        "No. 24-CA-557",
    ] {
        assert_eq!(page_number(not), None, "{not}");
    }
}

#[test]
fn page_numbers_in_titled_footers() {
    assert_eq!(footer_number("COMPLAINT - 2"), arabic(2));
    assert_eq!(footer_number("Page 2 - COMPLAINT"), arabic(2));
    assert_eq!(
        footer_number("OMNIBUS MEMORANDUM OF LAW Page 2 of 10"),
        arabic(2)
    );
    assert_eq!(
        footer_number("MEMORANDUM ISO MOTION TO DISMISS 2"),
        arabic(2)
    );
    for not in [
        "COMPLAINT",
        "CASE NO. 1:25-bk-00001",
        "Dated July 31, 2019",
        "Panel No. 2",
    ] {
        assert_eq!(footer_number(not), None, "{not}");
    }
}

#[test]
fn printed_reads_the_footer_then_the_last_or_first_line() {
    let runs = vec![
        run(1, 100.0, 300.0, "No. 24-1234"),
        run(1, 700.0, 300.0, "July 31, 2019"),
        run(2, 300.0, 300.0, "7"),
        run(2, 740.0, 300.0, "i"),
        run(3, 740.0, 72.0, "Page"),
        run(3, 740.0, 100.0, "2"),
        run(4, 740.0, 72.0, "BRIEF OF APPELLANT"),
        run(4, 740.0, 400.0, "1"),
        // a pleading line number in the left margin, and a page number 1 pt above the margin line
        run(5, 740.0, 63.5, "28"),
        run(5, 712.0, 300.0, "2"),
        // a page number above a footer line that has none
        run(6, 690.0, 300.0, "3"),
        run(6, 707.0, 93.0, "COMPLAINT"),
        // a page number in the header
        run(7, 36.0, 300.0, "4"),
        run(7, 300.0, 72.0, "body text"),
        // a TOC page: the last entry's page reference is not the page number; the footer is a titled run
        run(8, 680.0, 72.0, "CONCLUSION . . . . ."),
        run(8, 680.0, 500.0, "14"),
        run(8, 736.0, 108.0, "VALIDITY OF LIENS - 5"),
        run(8, 736.0, 492.0, "Suite 3500"),
        run(9, 680.0, 72.0, "CONCLUSION . . . . ."),
        run(9, 680.0, 500.0, "14"),
    ];
    let got: Vec<(u32, u32)> = printed(&runs, 720.0)
        .iter()
        .map(|(p, n)| (*p, n.value))
        .collect();
    assert_eq!(
        got,
        [(2, 1), (3, 2), (4, 1), (5, 2), (6, 3), (7, 4), (8, 5)]
    );
}

fn nums(list: &[(u32, u32, bool)]) -> Vec<(u32, Num)> {
    list.iter()
        .map(|&(p, value, roman)| (p, Num { value, roman }))
        .collect()
}

#[test]
fn one_page_cover_then_i_or_counted_passes() {
    assert!(judge(&nums(&[(2, 1, true), (3, 2, true)]), 3, 1).0);
    assert!(judge(&nums(&[(2, 2, false)]), 3, 1).0);
    assert!(judge(&nums(&[(2, 2, true)]), 3, 1).0);
    assert!(judge(&nums(&[(1, 1, false)]), 3, 1).0);
    assert!(judge(&[], 1, 1).0);
}

#[test]
fn a_cover_that_overflows_fails() {
    // the bap6 typst opening brief: the cover spills onto page 2, so "i" lands on page 3
    let (ok, meas, detail) = judge(&nums(&[(3, 1, true), (4, 2, true)]), 14, 1);
    assert!(!ok);
    assert_eq!(meas, "cover pages 1-2 (2 pages); page 3 prints \"i\"");
    assert!(detail.contains("2 pages long, expected 1"), "{detail}");
    // counted from the cover: page 3 prints 3, the cover is still two pages
    assert!(!judge(&nums(&[(3, 3, false)]), 9, 1).0);
    // a declared two-page cover passes
    assert!(judge(&nums(&[(3, 1, true)]), 9, 2).0);
}

#[test]
fn a_wrong_first_number_fails() {
    assert!(!judge(&nums(&[(2, 3, false)]), 9, 1).0);
    assert!(!judge(&nums(&[(1, 2, false)]), 9, 1).0);
    assert!(!judge(&[], 9, 1).0);
}
