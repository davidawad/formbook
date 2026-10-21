//! Gate 0 (gate0.awk, DEF-CONT-001) on small markdown/PDF-text pairs: the awk run on its own, no PDF needed.

/// DEF-CONT-001 on a one-page document: `blocks_missing` for `md` against PDF text `runs`.
fn g0_missing(md: &str, runs: &[&str]) -> String {
    let paged: Vec<(u32, &str)> = runs.iter().map(|t| (1, *t)).collect();
    g0_metric(md, &paged, "blocks_missing")
}

/// One metric of gate0 for `md` against PDF text runs given as (page, text).
fn g0_metric(md: &str, runs: &[(u32, &str)], metric: &str) -> String {
    let chk = format!("{}/../check", env!("CARGO_MANIFEST_DIR"));
    let dir = std::env::temp_dir().join(format!(
        "fb-g0-{}-{:x}",
        std::process::id(),
        md.len() * 31 + runs.len() * 7 + metric.len()
    ));
    std::fs::create_dir_all(&dir).unwrap();
    let (mdf, runsf, blocks) = (
        dir.join("a.md"),
        dir.join("runs.tsv"),
        dir.join("blocks.tsv"),
    );
    std::fs::write(&mdf, md).unwrap();
    let rows: String = runs
        .iter()
        .enumerate()
        .map(|(i, (pg, t))| format!("{pg}\t{}\t0\t0\t0\t0\t{t}\n", 100 + 20 * i))
        .collect();
    std::fs::write(&runsf, rows).unwrap();
    let b = std::process::Command::new("gawk")
        .args(["-v", "DEHYPHEN=1", "-f", &format!("{chk}/md-blocks.awk")])
        .arg(&mdf)
        .output()
        .unwrap();
    std::fs::write(&blocks, b.stdout).unwrap();
    let out = format!("out={}", dir.join("g0").display());
    let ok = std::process::Command::new("gawk")
        .env("LC_ALL", "C.UTF-8")
        .args(["-v", "DEHYPHEN=1", "-v", &out, "-v", "footer_top=720"])
        .args([
            "-f",
            &format!("{chk}/norm.awk"),
            "-f",
            &format!("{chk}/gate0.awk"),
        ])
        .arg(&runsf)
        .arg(&blocks)
        .status()
        .unwrap()
        .success();
    assert!(ok);
    let m = std::fs::read_to_string(dir.join("g0.metrics")).unwrap();
    m.lines()
        .find_map(|l| l.strip_prefix(&format!("{metric}=")).map(String::from))
        .unwrap()
}

#[test]
fn placeholder_is_a_wildcard_but_real_text_still_counts() {
    let md = "First paragraph.\n\nWord count: {{words}} words.\n\n{{toc}}\n\nLast paragraph.\n";
    let runs = [
        "First paragraph.",
        "Word count: 1,577 words.",
        "Last paragraph.",
    ];
    assert_eq!(g0_missing(md, &runs), "0");
    // a real sentence missing from the PDF still fails
    let runs = ["First paragraph.", "Word count: 1,577 words."];
    assert_eq!(g0_missing(md, &runs), "1");
    // the literal text around the placeholder is still required
    let runs = ["First paragraph.", "Word total: 1,577.", "Last paragraph."];
    assert_ne!(g0_missing(md, &runs), "0");
}

#[test]
fn a_dot_leader_matches_whatever_its_length() {
    let md = "Factual Overview ........................ 7\n\nInc. ..... 12\n";
    // the template sets its own leader, split over runs, longer or shorter than the markdown's
    let runs = [
        "Factual Overview . . . .",
        ". . . . . . . . . . . . . . . . . 7",
        "Inc. . . . . 12",
    ];
    assert_eq!(g0_missing(md, &runs), "0");
    // a leader is still four dots or more: three are not one, and the page reference still counts
    assert_eq!(
        g0_missing(md, &["Factual Overview ... 7", "Inc. . . . . 12"]),
        "1"
    );
    assert_eq!(
        g0_missing(md, &["Factual Overview ........ 8", "Inc. . . . . 12"]),
        "1"
    );
}

#[test]
fn footnote_continued_on_the_next_page_is_reassembled() {
    let md = "Body one.[^1] More body.\n\nBody two.\n\n[^1]: The note begins here and then it continues onto the next page.\n";
    // the note's first part is at the foot of page 1, its rest at the foot of page 2
    let split = [
        (1, "Body one.1 More body."),
        (1, "1 The note begins here and then"),
        (2, "Body two."),
        (2, "it continues onto the next page."),
    ];
    assert_eq!(g0_metric(md, &split, "footnotes_bad"), "0");
    assert_eq!(g0_metric(md, &split, "blocks_missing"), "0");
    // a missing tail still fails
    let cut = [
        (1, "Body one.1 More body."),
        (1, "1 The note begins here and then"),
        (2, "Body two."),
    ];
    assert_eq!(g0_metric(md, &cut, "footnotes_bad"), "1");
}

#[test]
fn blank_underscores_are_literal_text() {
    // "Br. __" is a fill-in blank, not emphasis: pandoc prints the underscores and so must the markdown side
    let md = "Body one.[^1] More body.\n\n[^1]: “Appx__” is the appendix; “Br. __” is the brief.\n";
    let runs = [
        (1, "Body one.1 More body."),
        (1, "1 “Appx__” is the appendix; “Br. __” is the brief."),
    ];
    assert_eq!(g0_metric(md, &runs, "footnotes_bad"), "0");
    assert_eq!(g0_metric(md, &runs, "blocks_missing"), "0");
    // emphasis with underscores still opens and closes
    assert_eq!(g0_missing("A _word_ here.\n", &["A word here."]), "0");
}

#[test]
fn frontmatter_footnote_is_checked_by_its_key() {
    let md = "---\nlead: Intro.[^1]\nfootnotes:\n  \"1\": >-\n    Note text that wraps\n    over two lines.\nother: x\n---\n\nBody.\n";
    let ok = [
        (1, "Intro.1"),
        (1, "Body."),
        (1, "1 Note text that wraps over two lines."),
    ];
    assert_eq!(g0_metric(md, &ok, "footnotes_bad"), "0");
    assert_eq!(g0_metric(md, &ok, "footnotes"), "1");
    let bad = [(1, "Intro.1"), (1, "Body."), (1, "1 Note text that wraps")];
    assert_eq!(g0_metric(md, &bad, "footnotes_bad"), "1");
}

#[test]
fn table_cells_may_interleave_lines_but_must_all_be_present() {
    let md = "Intro.\n\n| Term | Summary | Ref |\n|---|---|---|\n| Alpha | The first long summary that wraps | \u{b6} 6 |\n| Beta | Second summary | \u{b6} 7 |\n\nAfter.\n";
    // the PDF reads each row line by line: the short third cell comes before the wrapped second line of the middle cell
    let ok = [
        "Intro.",
        "Term Summary Ref",
        "Alpha The first long \u{b6} 6",
        "summary that wraps",
        "Beta Second summary \u{b6} 7",
        "After.",
    ];
    assert_eq!(g0_missing(md, &ok), "0");
    // a cell that is not in the PDF at all still fails
    let bad = [
        "Intro.",
        "Term Summary Ref",
        "Alpha The first long \u{b6} 6",
        "Beta Second summary \u{b6} 7",
        "After.",
    ];
    assert_ne!(g0_missing(md, &bad), "0");
    // rows still have to come in order
    let swapped = [
        "Intro.",
        "Term Summary Ref",
        "Beta Second summary \u{b6} 7",
        "Alpha The first long \u{b6} 6",
        "summary that wraps",
        "After.",
    ];
    assert_ne!(g0_missing(md, &swapped), "0");
}
