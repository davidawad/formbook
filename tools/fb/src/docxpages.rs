//! The page of every needle in a LibreOffice PDF (the multi-pass docx engine, see docxpass.rs).
//!
//! A docx filter cannot know pages, so it writes needles: one line per heading or citation,
//! `ID <TAB> KIND <TAB> NEEDLE <TAB> FALLBACK`, NEEDLE being the text (and what follows it) reduced to lower-case
//! letters and digits. It also declares how pages are labelled: `#section <TAB> ID <TAB> FORMAT <TAB> PREFIX`
//! starts a numbering (`lower-roman` or `decimal`, from 1, after PREFIX) at the page of needle ID. Pages before the
//! first section are labelled `-`.
//!
//! The text of every page (its page-number line dropped) is reduced the same way and the pages are joined into one
//! string. Body needles (kind `B`) are found in document order, each from where the one before it was found, so a
//! short citation ("Id.") is found after the text before it, not earlier on the page. A needle inside a footnote
//! (kind `N`) is searched from the start of the page the body has reached (footnotes are printed at the foot of the
//! page) and moves nothing. When NEEDLE runs over a page break with footnotes between, it is found by its halves: a
//! body needle's head on a page and its tail where the next page starts (the longest head first); failing that,
//! FALLBACK (the text alone) is tried.

/// The shortest tail of a needle that runs over a page end (docs in the module comment).
const MIN_TAIL: usize = 4;

/// Lower-case ASCII letters and digits only.
pub fn norm(s: &str) -> String {
    s.chars()
        .filter(char::is_ascii_alphanumeric)
        .map(|c| c.to_ascii_lowercase())
        .collect()
}

fn is_page_label(line: &str) -> bool {
    let t = line.trim();
    let t = t.strip_prefix("Add-").unwrap_or(t);
    !t.is_empty()
        && t.chars()
            .all(|c| c.is_ascii_digit() || "ivxlcdm".contains(c))
}

/// The pleading-paper line numbers of a page: N when lines holding only the numbers 1, 2, ... N (N >= 10) are on it,
/// else 0. Word line numbering (`w:lnNumType`) prints them in the text flow, one line each, where they would break a
/// needle that runs over a line.
fn pleading_lines(lines: &[&str]) -> usize {
    let nums: std::collections::BTreeSet<usize> = lines
        .iter()
        .filter_map(|l| l.trim().parse::<usize>().ok())
        .collect();
    let n = (1..).take_while(|i| nums.contains(i)).count();
    if n >= 10 {
        n
    } else {
        0
    }
}

/// The normalized text of each page of `pdftotext` output (pages split at form feeds), without its page-number line
/// and its pleading line numbers.
pub fn page_texts(text: &str) -> Vec<String> {
    let mut pages: Vec<&str> = text.split('\u{c}').collect();
    if pages.last().is_some_and(|p| p.trim().is_empty()) {
        pages.pop();
    }
    pages
        .iter()
        .map(|p| {
            let mut lines: Vec<&str> = p.lines().collect();
            while lines.last().is_some_and(|l| l.trim().is_empty()) {
                lines.pop();
            }
            if lines.last().is_some_and(|l| is_page_label(l)) {
                lines.pop();
            }
            let n = pleading_lines(&lines);
            lines.retain(|l| !l.trim().parse::<usize>().is_ok_and(|v| v >= 1 && v <= n));
            norm(&lines.join("\n"))
        })
        .collect()
}

fn roman(mut n: usize) -> String {
    let table = [
        (100, "c"),
        (90, "xc"),
        (50, "l"),
        (40, "xl"),
        (10, "x"),
        (9, "ix"),
        (5, "v"),
        (4, "iv"),
        (1, "i"),
    ];
    let mut out = String::new();
    for (v, s) in table {
        while n >= v {
            out.push_str(s);
            n -= v;
        }
    }
    out
}

/// A needle's id as the filter wrote it (`H:3`, `T:12`, `S:toc`).
#[derive(Debug, Clone, PartialEq)]
struct NeedleId(String);

impl std::fmt::Display for NeedleId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&self.0)
    }
}

/// Where a needle sits: the body text (found in order) or a footnote (found from the body's page).
#[derive(Debug, Clone, Copy, PartialEq)]
enum Place {
    Body,
    Note,
}

/// How a section numbers its pages.
#[derive(Debug, Clone, Copy, PartialEq)]
enum Numbering {
    LowerRoman,
    Decimal,
}

struct Needle {
    id: NeedleId,
    place: Place,
    needle: String,
    fallback: String,
}

struct Section {
    id: NeedleId,
    numbering: Numbering,
    prefix: String,
}

/// `id <TAB> page <TAB> label` for every needle of `needles` (the file the filter wrote) in the pages `pages`;
/// Err names the needles that were not found.
pub fn lookup(needles: &str, pages: &[String]) -> Result<String, String> {
    let mut ns = vec![];
    let mut secs = vec![];
    for line in needles.lines().filter(|l| !l.is_empty()) {
        let f: Vec<&str> = line.split('\t').collect();
        let at = |i: usize| f.get(i).copied().unwrap_or("").to_string();
        if f[0] == "#section" {
            secs.push(Section {
                id: NeedleId(at(1)),
                numbering: if at(2) == "lower-roman" {
                    Numbering::LowerRoman
                } else {
                    Numbering::Decimal
                },
                prefix: at(3),
            });
        } else {
            ns.push(Needle {
                id: NeedleId(at(0)),
                place: if at(1) == "N" {
                    Place::Note
                } else {
                    Place::Body
                },
                needle: at(2),
                fallback: at(3),
            });
        }
    }
    let mut starts = vec![];
    let mut all = String::new();
    for p in pages {
        starts.push(all.len());
        all.push_str(p);
    }
    // the page (1-based) holding byte offset `pos`
    let page_at = |pos: usize| starts.iter().rposition(|&s| s <= pos).map_or(0, |i| i + 1);
    let find = |s: &str, from: usize| -> Option<usize> {
        (!s.is_empty())
            .then(|| {
                all.get(from..)
                    .and_then(|rest| rest.find(s))
                    .map(|i| from + i)
            })
            .flatten()
    };
    // a body needle that runs over a page end, with the footnotes and the page number between its halves: its head on
    // a page (from `from`), its tail (MIN_TAIL characters or more) where the next page starts
    let split = |s: &str, from: usize| -> Option<usize> {
        for q in page_at(from)..starts.len() {
            let (b, a) = (starts[q], starts[q - 1].max(from));
            if b <= a {
                continue;
            }
            for k in (1..=s.len().saturating_sub(MIN_TAIL)).rev() {
                let (head, tail) = s.split_at(k);
                if all[b..].starts_with(tail) {
                    if let Some(i) = all[a..b].find(head) {
                        return Some(a + i);
                    }
                }
            }
        }
        None
    };
    let mut cur = 0;
    let mut found = vec![];
    for n in &ns {
        let from = if n.place == Place::Body {
            cur
        } else {
            starts
                .get(page_at(cur).saturating_sub(1))
                .copied()
                .unwrap_or(0)
        };
        let pos = find(&n.needle, from)
            .or_else(|| (n.place == Place::Body).then(|| split(&n.needle, from)).flatten())
            .or_else(|| find(&n.fallback, from));
        if let (Some(p), true) = (pos, n.place == Place::Body) {
            cur = p + 1;
        }
        found.push(pos.map_or(0, page_at));
    }
    let page_of = |id: &NeedleId| ns.iter().position(|n| n.id == *id).map_or(0, |i| found[i]);
    let mut bounds: Vec<(usize, &Section)> = secs.iter().map(|s| (page_of(&s.id), s)).collect();
    bounds.sort_by_key(|b| b.0);
    let label = |p: usize| -> String {
        if p == 0 {
            return "??".into();
        }
        match bounds
            .iter()
            .rev()
            .find(|(start, _)| *start > 0 && *start <= p)
        {
            Some((start, s)) if s.numbering == Numbering::LowerRoman => {
                format!("{}{}", s.prefix, roman(p - start + 1))
            }
            Some((start, s)) => format!("{}{}", s.prefix, p - start + 1),
            None => "-".into(),
        }
    };
    let mut out = String::new();
    let mut missing = vec![];
    for (n, &p) in ns.iter().zip(&found) {
        if p == 0 {
            missing.push(n.id.to_string());
        }
        out.push_str(&format!("{}\t{}\t{}\n", n.id, p, label(p)));
    }
    if missing.is_empty() {
        Ok(out)
    } else {
        Err(format!(
            "fb render: not found in the PDF: {}",
            missing.join(", ")
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn pages() -> Vec<String> {
        let pdf = "No. 1\nCover\n\u{c}TABLE OF CONTENTS\nPage\n\ni\n\u{c}INTRODUCTION\nSee Id. at 4. Smith v. Jones\n1\n\u{c}did more. Id. at 5 and so on\nfootnote: Smith v. Jones cited\n2\n\u{c}ADDENDUM\nTABLE OF CONTENTS\nAdd-1\n\u{c}";
        page_texts(pdf)
    }

    #[test]
    fn drops_page_numbers_and_normalizes() {
        let p = pages();
        assert_eq!(p.len(), 5);
        assert_eq!(p[1], "tableofcontentspage");
        assert_eq!(p[4], "addendumtableofcontents");
    }

    #[test]
    fn drops_pleading_line_numbers_only_on_pleading_pages() {
        let numbered: String = (1..=12)
            .map(|i| format!("{i}\nline {i} of Twombly, 550\n"))
            .collect();
        let p = page_texts(&format!("{numbered}3\n\u{c}See 2\nnotes\n7\n\u{c}"));
        let want: String = (1..=12).map(|i| format!("line{i}oftwombly550")).collect();
        assert_eq!(p[0], want);
        assert_eq!(p[1], "see2notes");
    }

    #[test]
    fn finds_in_order_and_labels_by_section() {
        let needles = "S:toc\tB\ttableofcontentspage\ttableofcontents\nH:1\tB\tintroductionsee\tintroduction\n\
            T:1\tB\tidat4\tid\nT:2\tB\tidat5\tid\nT:3\tN\tsmithvjonescited\tsmithvjones\n\
            S:add\tB\taddendumtable\taddendum\n#section\tS:toc\tlower-roman\t\n#section\tH:1\tdecimal\t\n\
            #section\tS:add\tdecimal\tAdd-\n";
        let got = lookup(needles, &pages()).unwrap();
        assert_eq!(
            got,
            "S:toc\t2\ti\nH:1\t3\t1\nT:1\t3\t1\nT:2\t4\t2\nT:3\t4\t2\nS:add\t5\tAdd-1\n"
        );
    }

    #[test]
    fn a_body_needle_over_a_page_end_is_found_by_its_halves() {
        let pdf = "Intro\nsee Smith, 18\n1 Footnote text 2026\n4\n\u{c}U.S.C. 2710. Only a person\nmore 18 U.S.C. 2710 here\n5\n\u{c}";
        let p = page_texts(pdf);
        let needles = "T:1\tB\t18usc2710onlyaperson\t18usc2710\nT:2\tB\tmore18usc\tmore\n";
        assert_eq!(lookup(needles, &p).unwrap(), "T:1\t1\t-\nT:2\t2\t-\n");
        // a footnote needle is not split; its fallback still finds it
        let notes = "T:1\tN\t18usc2710onlyaperson\t18usc2710\n";
        assert_eq!(lookup(notes, &p).unwrap(), "T:1\t2\t-\n");
    }

    #[test]
    fn a_missing_needle_is_an_error() {
        let e = lookup("H:1\tB\tnowhere\tnowhere\n", &pages()).unwrap_err();
        assert!(e.contains("H:1"));
    }
}
