//! DEF-COVER-001, `cover_pages`: the cover is exactly one page, and the first page after it carries the expected number.
//!
//! Engine-neutral: it reads the page numbers the PDF prints (`runs.tsv`, pdf-runs.awk), never the template. The
//! cover is the pages before the first page that prints a number. It must be `params.cover_pages` long (1 unless
//! an eval.yaml declares another), and that first numbered page must print 1 (or i, or C-1: numbering starts
//! after the cover) or its own physical page number (or the roman numeral of it: the cover was counted). A
//! document that numbers its first page passes when that number is 1. A cover that overflows onto a second page
//! fails either way: it is two pages long, and every page after it is numbered one too high or starts late.
//!
//! `fb cover-pages [--footer-top PT] [--cover N] <pdf>...` runs the same analysis on any PDF, for sweeps.
use super::toclayout::Run;
use crate::{fail, Res};
use std::process::ExitCode;

/// A printed page number: its value, and whether it was a roman numeral.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Num {
    pub value: u32,
    pub roman: bool,
}

/// A footer box may start a few points above the bottom margin line (glyph boxes include ascent and descent).
const FOOTER_SLACK_PT: f64 = 3.0;
/// Pleading-paper line numbers sit left of this (the 1 in left margin), as prepare.rs filters them.
const LINE_NUMBER_LEFT_PT: f64 = 72.0;

/// A text that is a page number and nothing else: "3", "iv", "- 3 -", "Page 3", "Page 3 of 12", "3 of 12",
/// or a lettered page ("C-1", the certificate of interested persons in the Eleventh Circuit).
pub fn page_number(text: &str) -> Option<Num> {
    let t: String = text
        .chars()
        .filter(|c| !matches!(c, '\u{2060}' | '\u{200b}' | '\u{feff}'))
        .collect();
    let t = t
        .trim()
        .trim_matches(|c| matches!(c, '-' | '–' | '—' | ' '));
    let lower = t.to_lowercase();
    let t = lower
        .strip_prefix("page")
        .map_or(lower.as_str(), str::trim_start);
    let t = match t.split_once(" of ") {
        Some((n, total)) if digits(total.trim(), 4) => n.trim(),
        _ => t,
    };
    let arabic = |s: &str| digits(s, 4).then(|| s.parse().ok()).flatten();
    if let Some(value) = arabic(t) {
        return Some(Num {
            value,
            roman: false,
        });
    }
    if let Some((letters, n)) = t.split_once('-') {
        if (1..=3).contains(&letters.len()) && letters.chars().all(|c| c.is_ascii_alphabetic()) {
            return arabic(n).map(|value| Num {
                value,
                roman: false,
            });
        }
    }
    let value = roman_value(t)?;
    (roman(value) == t).then_some(Num { value, roman: true })
}

/// A page number inside a titled footer line: "COMPLAINT - 2", "Page 2 - COMPLAINT", "MEMORANDUM Page 2 of 10",
/// "MEMORANDUM ISO MOTION 2".
fn footer_number(text: &str) -> Option<Num> {
    let words = text.split_whitespace().collect::<Vec<_>>();
    let line = words.join(" ");
    let parts = || {
        line.split(" - ")
            .flat_map(|p| p.split(" – "))
            .flat_map(|p| p.split(" — "))
    };
    page_number(&line)
        .or_else(|| parts().find_map(page_number))
        .or_else(|| {
            let at = words.iter().rposition(|w| w.eq_ignore_ascii_case("page"))?;
            page_number(&words[at..].join(" "))
        })
        .or_else(|| {
            // not a docket or panel number ("Panel No. 2")
            let [.., before, last] = words.as_slice() else {
                return None;
            };
            let numbered = ["no", "no.", "nos.", "#", "number", "panel"]
                .contains(&before.to_lowercase().as_str());
            (digits(last, 3) && !numbered)
                .then(|| page_number(last))
                .flatten()
        })
}

fn digits(s: &str, max: usize) -> bool {
    (1..=max).contains(&s.len()) && s.chars().all(|c| c.is_ascii_digit())
}

fn roman_value(s: &str) -> Option<u32> {
    let digit = |c| match c {
        'i' => Some(1),
        'v' => Some(5),
        'x' => Some(10),
        'l' => Some(50),
        'c' => Some(100),
        _ => None,
    };
    let ds: Vec<u32> = s.chars().map(digit).collect::<Option<_>>()?;
    let mut n = 0i64;
    for (i, d) in ds.iter().enumerate() {
        match ds.get(i + 1) {
            Some(next) if next > d => n -= *d as i64,
            _ => n += *d as i64,
        }
    }
    (n > 0).then_some(n as u32)
}

/// Lower-case roman numeral of `n` (n < 400).
fn roman(mut n: u32) -> String {
    let mut s = String::new();
    for (v, r) in [
        (100, "c"),
        (90, "xc"),
        (50, "l"),
        (40, "xl"),
        (10, "x"),
        (9, "ix"),
        (5, "v"),
        (4, "iv"),
        (1, "i"),
    ] {
        while n >= v {
            s.push_str(r);
            n -= v;
        }
    }
    s
}

/// The runs of each page in lines (tops within a third of the height), top to bottom, pleading line numbers left out.
fn page_lines(runs: &[Run]) -> Vec<Vec<Vec<&Run>>> {
    let line_number = |r: &Run| r.left < LINE_NUMBER_LEFT_PT && digits(r.text.trim(), 3);
    let mut rs: Vec<&Run> = runs.iter().filter(|r| !line_number(r)).collect();
    rs.sort_by(|a, b| {
        (a.page, a.top, a.left)
            .partial_cmp(&(b.page, b.top, b.left))
            .unwrap()
    });
    let mut pages: Vec<Vec<Vec<&Run>>> = Vec::new();
    for r in rs {
        let same_page = pages
            .last()
            .and_then(|p| p.last())
            .is_some_and(|l| l[0].page == r.page);
        if !same_page {
            pages.push(vec![vec![r]]);
            continue;
        }
        let lines = pages.last_mut().unwrap();
        let line = lines.last_mut().unwrap();
        if (r.top - line[0].top).abs() <= 0.35 * line[0].height.max(r.height) {
            line.push(r);
        } else {
            lines.push(vec![r]);
        }
    }
    pages
}

/// The number each page prints: in a line of the bottom margin (centre at or below `ftop`, less FOOTER_SLACK_PT),
/// as the whole line, a run of it or a part of a titled footer; else one of the page's last two lines or its first
/// line (a number set above a footer, or in the header) when the whole line is a page number and nothing else.
pub fn printed(runs: &[Run], ftop: f64) -> Vec<(u32, Num)> {
    let text = |l: &[&Run]| {
        l.iter()
            .map(|r| r.text.as_str())
            .collect::<Vec<_>>()
            .join(" ")
    };
    let alone = |l: &Vec<&Run>| page_number(&text(l));
    let in_footer = |l: &Vec<&Run>| {
        alone(l)
            .or_else(|| l.iter().find_map(|r| page_number(&r.text)))
            .or_else(|| footer_number(&text(l)))
            .or_else(|| l.iter().find_map(|r| footer_number(&r.text)))
    };
    page_lines(runs)
        .iter()
        .filter_map(|lines| {
            let mut foot = lines
                .iter()
                .filter(|l| l[0].top + l[0].height / 2.0 >= ftop - FOOTER_SLACK_PT);
            let num = foot
                .find_map(in_footer)
                .or_else(|| lines.iter().rev().take(2).find_map(alone))
                .or_else(|| lines.first().and_then(alone))?;
            Some((lines[0][0].page, num))
        })
        .collect()
}

/// The verdict: (pass, measured, detail) for a document of `npages` pages whose cover should be `cover` pages long.
pub fn judge(nums: &[(u32, Num)], npages: u32, cover: u32) -> (bool, String, String) {
    let show = |n: &Num| {
        if n.roman {
            roman(n.value)
        } else {
            n.value.to_string()
        }
    };
    let Some((k, n)) = nums.first() else {
        return match npages {
            0 | 1 => (
                true,
                format!(
                    "{npages} page{}, no page number",
                    if npages == 1 { "" } else { "s" }
                ),
                String::new(),
            ),
            _ => (
                false,
                format!("{npages} pages, none prints a page number in the bottom margin"),
                "no page number found, so the cover cannot be told from the body".into(),
            ),
        };
    };
    let (k, got) = (*k, show(n));
    if k == 1 {
        let meas = format!("no unnumbered cover; page 1 prints \"{got}\"");
        let ok = n.value == 1;
        let detail = if ok {
            String::new()
        } else {
            format!("page 1 prints \"{got}\", expected \"1\"")
        };
        return (ok, meas, detail);
    }
    let len = k - 1;
    let meas = format!(
        "cover {} ({len} page{}); page {k} prints \"{got}\"",
        match len {
            1 => "page 1".to_string(),
            _ => format!("pages 1-{len}"),
        },
        if len == 1 { "" } else { "s" }
    );
    let mut detail = Vec::new();
    if len != cover {
        detail.push(format!("the cover is {len} pages long, expected {cover}: the pages before the first page number"));
    }
    if n.value != 1 && n.value != k {
        let want = if n.roman {
            format!("\"i\" or \"{}\"", roman(k))
        } else {
            format!("\"1\" or \"{k}\"")
        };
        detail.push(format!(
            "page {k}, the first after the cover, prints \"{got}\", expected {want}"
        ));
    }
    (detail.is_empty(), meas, detail.join("\n"))
}

/// `fb cover-pages [--footer-top PT] [--cover N] <pdf>...`: one line per PDF (OK or FAIL), then the findings.
/// Exit 1 when any PDF fails.
pub fn main(args: &[String]) -> Res<ExitCode> {
    let (mut ftop, mut cover, mut pdfs) = (None::<f64>, 1u32, Vec::new());
    let mut it = args.iter();
    let usage = || {
        fail(
            2,
            "usage: fb cover-pages [--footer-top PT] [--cover N] <pdf>...",
        )
    };
    while let Some(a) = it.next() {
        match a.as_str() {
            "--footer-top" => {
                ftop = Some(it.next().and_then(|v| v.parse().ok()).ok_or_else(usage)?)
            }
            "--cover" => cover = it.next().and_then(|v| v.parse().ok()).ok_or_else(usage)?,
            _ => pdfs.push(a.clone()),
        }
    }
    if pdfs.is_empty() {
        return Err(usage());
    }
    let mut bad = false;
    for pdf in &pdfs {
        if !std::path::Path::new(pdf).is_file() {
            return Err(fail(2, format!("fb cover-pages: no such PDF: {pdf}")));
        }
        let ftop = ftop.unwrap_or_else(|| super::toclayout::footer_top(pdf));
        let runs = super::toclayout::runs_of(pdf)?;
        let npages = runs
            .iter()
            .map(|r| r.page)
            .max()
            .unwrap_or(0)
            .max(pdf_pages(pdf));
        let (ok, meas, detail) = judge(&printed(&runs, ftop), npages, cover);
        println!("{}\t{pdf}\t{meas}", if ok { "OK" } else { "FAIL" });
        for d in detail.lines() {
            println!("\t{d}");
        }
        bad |= !ok;
    }
    Ok(if bad {
        ExitCode::from(1)
    } else {
        ExitCode::SUCCESS
    })
}

fn pdf_pages(pdf: &str) -> u32 {
    std::process::Command::new("pdfinfo")
        .arg(pdf)
        .output()
        .ok()
        .and_then(|o| {
            let text = String::from_utf8_lossy(&o.stdout).into_owned();
            text.lines()
                .find_map(|l| l.strip_prefix("Pages:")?.trim().parse().ok())
        })
        .unwrap_or(0)
}

#[cfg(test)]
#[path = "coverpages_tests.rs"]
mod tests;
