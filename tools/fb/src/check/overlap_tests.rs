use super::{find, parse_runs, parse_words, sized, Word};

/// A word on page 1: its pdftotext box (top, left, width, box height) and its size.
fn w(top: f64, left: f64, width: f64, height: f64, size: f64, text: &str) -> Word {
    Word {
        page: 1,
        x0: left,
        y0: top,
        x1: left + width,
        y1: top + height,
        size,
        text: text.into(),
    }
}

#[test]
fn counsel_block_into_court_title_is_found() {
    // the N.D. Cal. complaint before e77401a3d (fb-595.79): the last counsel line ran into the court title
    // (pdftotext boxes of that render; Times New Roman 12 pt, regular and bold)
    let words = [
        w(215.02, 108.0, 50.0, 10.91, 12.0, "Attorneys"),
        w(229.52, 171.66, 41.99, 10.91, 12.0, "Platform"),
        w(229.52, 216.65, 18.32, 10.91, 12.0, "Inc."),
        w(240.0, 223.68, 46.68, 10.72, 12.0, "UNITED"),
    ];
    let found = find(&words);
    assert_eq!(found.len(), 1, "{found:?}");
    assert!(
        found[0].starts_with("p.1: \"Inc.\" (top 229.5) prints into \"UNITED\""),
        "{found:?}"
    );
}

#[test]
fn lines_set_solid_do_not_overlap() {
    let words = [
        // 12 pt Times single lines 12 pt apart (the N.D. Cal. complaint now)
        w(83.0, 108.0, 100.0, 10.91, 12.0, "JOSHUA"),
        w(95.0, 108.0, 100.0, 10.91, 12.0, "CHRISTINE"),
        // 13 pt Schola 13 pt apart (LibreOffice), boxes of 1.45 of the size
        w(488.5, 306.1, 35.6, 21.49, 13.0, "Kaiya"),
        w(501.5, 306.1, 35.6, 21.49, 13.0, "SBN"),
    ];
    assert_eq!(find(&words), Vec::<String>::new());
}

#[test]
fn lines_closer_than_solid_are_found() {
    // 14 pt Times 12.5 pt apart (the Massachusetts petition-for-writ cover): descenders touch the caps below
    let words = [
        w(300.0, 108.0, 100.0, 12.73, 14.0, "Benjamin"),
        w(312.5, 108.0, 100.0, 12.73, 14.0, "Rebecca"),
    ];
    assert_eq!(find(&words).len(), 1);
}

#[test]
fn footnote_marker_does_not_reach_the_line_above() {
    // a superscript 8 pt marker raised at the start of a 12 pt footnote line, the line above 12 pt up
    let words = [
        w(600.0, 108.0, 300.0, 10.91, 12.0, "reviewed"),
        w(609.0, 108.0, 4.0, 7.27, 8.0, "2"),
        w(612.0, 113.0, 300.0, 10.91, 12.0, "Minn."),
    ];
    assert_eq!(find(&words), Vec::<String>::new());
}

#[test]
fn abutting_words_of_one_line_do_not_overlap() {
    let words = [
        w(300.0, 108.0, 100.0, 10.91, 12.0, "case."),
        w(300.0, 211.0, 15.0, 10.91, 12.0, "Id."),
        w(300.0, 226.0, 15.0, 10.91, 12.0, ","),
    ];
    assert_eq!(find(&words), Vec::<String>::new());
}

#[test]
fn words_printed_over_each_other_on_one_line_are_found() {
    // a table of authorities whose page list runs over the title (Alabama court-of-civil-appeals, before the fix)
    let words = [
        w(239.0, 72.0, 30.0, 10.91, 12.0, "ADOC"),
        w(239.0, 96.0, 10.0, 10.91, 12.0, "7,"),
    ];
    assert_eq!(find(&words).len(), 1);
}

#[test]
fn one_finding_per_pair_of_lines() {
    let words = [
        w(100.0, 108.0, 50.0, 10.91, 12.0, "one"),
        w(100.0, 160.0, 50.0, 10.91, 12.0, "two"),
        w(106.0, 108.0, 50.0, 10.91, 12.0, "three"),
        w(106.0, 160.0, 50.0, 10.91, 12.0, "four"),
    ];
    assert_eq!(find(&words).len(), 1);
}

#[test]
fn the_same_box_on_another_page_is_not_an_overlap() {
    let mut other = w(300.0, 108.0, 100.0, 10.91, 12.0, "b");
    other.page = 2;
    assert_eq!(
        find(&[w(300.0, 108.0, 100.0, 10.91, 12.0, "a"), other]),
        Vec::<String>::new()
    );
}

#[test]
fn words_take_the_size_of_their_run() {
    let runs = parse_runs(
        "<page number=\"1\" position=\"absolute\" top=\"0\" left=\"0\" height=\"1584\" width=\"1224\">\n\
         \t<fontspec id=\"0\" size=\"24\" family=\"A+TimesNewRomanPSMT\" color=\"#000000\"/>\n\
         \t<fontspec id=\"1\" size=\"16\" family=\"A+TimesNewRomanPSMT\" color=\"#000000\"/>\n\
         <text top=\"600\" left=\"216\" width=\"400\" height=\"22\" font=\"0\"><a href=\"x.html#3\">A</a> &amp; B</text>\n\
         <text top=\"640\" left=\"216\" width=\"8\" height=\"15\" font=\"1\">2</text>\n\
         </page>\n",
    );
    assert_eq!(runs.len(), 2);
    assert_eq!(
        (runs[0].y0, runs[0].size, runs[0].text.as_str()),
        (300.0, 12.0, "A & B")
    );
    let words = parse_words(
        "<doc>\n  <page width=\"612.000000\" height=\"792.000000\">\n\
         \x20   <word xMin=\"110.0\" yMin=\"300.1\" xMax=\"120.0\" yMax=\"311.0\">A&amp;B</word>\n\
         \x20   <word xMin=\"108.2\" yMin=\"320.1\" xMax=\"111.8\" yMax=\"327.4\">2</word>\n\
         \x20   <word xMin=\"400.0\" yMin=\"500.0\" xMax=\"420.0\" yMax=\"510.9\">alone</word>\n\
         </page>\n</doc>\n",
    );
    let sizes: Vec<_> = sized(words, &runs)
        .iter()
        .map(|w| (w.text.clone(), w.size))
        .collect();
    assert_eq!(
        sizes,
        [
            ("A&B".into(), 12.0),
            ("2".into(), 8.0),
            ("alone".into(), 10.899999999999977)
        ]
    );
}
