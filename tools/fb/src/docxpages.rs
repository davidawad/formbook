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
//! (kind `N`) is searched from where the body has reached (its mark comes after that, and footnotes are printed at the
//! foot of the page, after its body text), else from the start of that page, and moves nothing. When NEEDLE runs over
//! a page break with footnotes between, it is found by its halves: a body needle's head on a page and its tail where
//! the next page starts (the longest head first), also when its whole text comes again later (the halves, when they
//! come first, win); failing both, FALLBACK (the text alone) is tried. An authority's needle (id `a..`) that runs over
//! a page end is on the page its FALLBACK (the find) ends on (typst marks a citation before its last character); its
//! find, not the words before the find in NEEDLE, is searched from where the body has reached.
//!
//! A position needle (kind `T` or `Y`, lib/docx/xdoc.lua's fills) asks where a line is, not its page: NEEDLE is found in
//! the words of the PDF's lines (`pdftotext -bbox-layout`, bbox_lines), on the page the body has reached or a later
//! one, and its label is the yMax of the line (points from the page top) that holds the needle's first character
//! (`T`: the topmost such line on the page) or its last (`Y`: the lowest). It moves nothing. A destination needle (kind
//! `D`) names a Word bookmark, which LibreOffice exports as a named destination: its label is the top of the line the
//! bookmark stands in (dests).

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
    /// a line's place: the line of the needle's first character
    Top,
    /// a line's place: the line of the needle's last character
    Bottom,
    /// a named destination's place: NEEDLE is its name
    Dest,
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

/// One page of a PDF as lines (bbox_lines): the reduced text of its words, and for every byte of it the yMax of its
/// line (points from the page top).
#[derive(Debug, Default)]
pub struct PageLines {
    pub text: String,
    pub ymax: Vec<f64>,
}

/// Whether the needles ask for a line's place (kind T or Y): the pages are then read as lines too.
pub fn wants_lines(needles: &str) -> bool {
    needles
        .lines()
        .any(|l| matches!(l.split('\t').nth(1), Some("T" | "Y")))
}

fn unescape(s: &str) -> String {
    s.replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", "\"")
        .replace("&#39;", "'")
        .replace("&amp;", "&")
}

/// The pages of `pdftotext -bbox-layout` output (XHTML: page, line with yMin/yMax, word), each as its lines' words
/// reduced as `norm` reduces them.
pub fn bbox_lines(xhtml: &str) -> Vec<PageLines> {
    let mut pages: Vec<PageLines> = vec![];
    let mut y = 0.0;
    let mut rest = xhtml;
    while let Some(i) = rest.find('<') {
        rest = &rest[i..];
        if rest.starts_with("<page ") {
            pages.push(PageLines::default());
        } else if rest.starts_with("<line ") {
            let tag = &rest[..rest.find('>').unwrap_or(rest.len())];
            y = tag
                .split("yMax=\"")
                .nth(1)
                .and_then(|v| v.split('"').next())
                .and_then(|v| v.parse().ok())
                .unwrap_or(0.0);
        } else if rest.starts_with("<word ") {
            let open = rest.find('>').map_or(rest.len(), |j| j + 1);
            let close = rest[open..]
                .find("</word>")
                .map_or(rest.len(), |j| open + j);
            let w = norm(&unescape(&rest[open..close]));
            if let Some(p) = pages.last_mut() {
                p.ymax.extend(std::iter::repeat_n(y, w.len()));
                p.text.push_str(&w);
            }
            rest = &rest[close..];
            continue;
        }
        rest = &rest[1..];
    }
    pages
}

/// The place of a position needle on the first page from `from` (1-based) whose lines hold it: (page, yMax).
fn place(lines: &[PageLines], from: usize, needle: &str, top: bool) -> Option<(usize, f64)> {
    if needle.is_empty() {
        return None;
    }
    for (i, p) in lines.iter().enumerate().skip(from.saturating_sub(1)) {
        let ys = p.text.match_indices(needle).map(|(at, _)| {
            if top {
                p.ymax[at]
            } else {
                p.ymax[at + needle.len() - 1]
            }
        });
        let y = if top {
            ys.reduce(f64::min)
        } else {
            ys.reduce(f64::max)
        };
        if let Some(y) = y {
            return Some((i + 1, y));
        }
    }
    None
}

/// `id <TAB> page <TAB> label` for every needle of `needles` (the file the filter wrote) in the pages `pages`;
/// Err names the needles that were not found.
#[cfg(test)]
pub fn lookup(needles: &str, pages: &[String]) -> Result<String, String> {
    lookup_lines(needles, pages, &[])
}

/// Whether the needles ask for a named destination's place (kind D): the PDF is then made with them.
pub fn wants_dests(needles: &str) -> bool {
    needles.lines().any(|l| l.split('\t').nth(1) == Some("D"))
}

/// The named destinations of a PDF (LibreOffice exports Word bookmarks as them): name -> (page, the top of the line
/// they stand in, in points from the page top). `listing` is `pdfinfo -dests` (the page of each name; its places are
/// rounded), `raw` the PDF itself, whose entries `/name[<page> 0 R/XYZ x y z]` (or `(name)[..]`) give the place exactly, `height` the
/// page height.
pub fn dests(
    listing: &str,
    raw: &[u8],
    height: f64,
) -> std::collections::HashMap<String, (usize, f64)> {
    let raw = String::from_utf8_lossy(raw);
    let mut out = std::collections::HashMap::new();
    for line in listing.lines() {
        let (Some(page), Some(name)) = (
            line.split_whitespace()
                .next()
                .and_then(|p| p.parse::<usize>().ok()),
            line.rsplit_once('"')
                .and_then(|(a, _)| a.rsplit_once('"'))
                .map(|(_, n)| n),
        ) else {
            continue;
        };
        let y = [format!("/{name}["), format!("({name})[")]
            .iter()
            .find_map(|k| raw.split(k.as_str()).nth(1))
            .and_then(|r| r.split("/XYZ").nth(1))
            .and_then(|r| r.split_whitespace().nth(1))
            .and_then(|y| y.parse::<f64>().ok());
        if let Some(y) = y {
            out.insert(name.to_string(), (page, height - y));
        }
    }
    out
}

/// `lookup`, with the pages also as lines (bbox_lines) for the position needles.
#[cfg(test)]
pub fn lookup_lines(
    needles: &str,
    pages: &[String],
    lines: &[PageLines],
) -> Result<String, String> {
    lookup_all(needles, pages, lines, &Default::default())
}

/// `lookup`, with the pages as lines (bbox_lines) for the position needles and the PDF's named destinations (dests)
/// for the destination needles.
pub fn lookup_all(
    needles: &str,
    pages: &[String],
    lines: &[PageLines],
    dests: &std::collections::HashMap<String, (usize, f64)>,
) -> Result<String, String> {
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
                place: match at(1).as_str() {
                    "N" => Place::Note,
                    "T" => Place::Top,
                    "Y" => Place::Bottom,
                    "D" => Place::Dest,
                    _ => Place::Body,
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
    // a page (from `from`), its tail (MIN_TAIL characters or more) where the next page starts; the position of the
    // head, or where the tail starts when the find (`text`, an authority's fallback) ends in the tail: typst marks a
    // citation before its last character, so one that runs over a page end is on the next page. Only a head that starts
    // before `until`, of `min_head` characters or more (a split before a whole match, below)
    let split =
        |s: &str, text: &str, from: usize, until: usize, min_head: usize| -> Option<usize> {
            for q in page_at(from)..starts.len() {
                let (b, a) = (starts[q], starts[q - 1].max(from));
                if a >= until {
                    break;
                }
                if b <= a {
                    continue;
                }
                for k in (min_head.max(1)..=s.len().saturating_sub(MIN_TAIL)).rev() {
                    let (head, tail) = s.split_at(k);
                    if all[b..].starts_with(tail) {
                        if let Some(i) = all[a..b].find(head).filter(|i| a + i < until) {
                            let ends_in_tail = !text.is_empty()
                                && s.find(text).is_some_and(|t| t + text.len() > k);
                            return Some(if ends_in_tail { b } else { a + i });
                        }
                    }
                }
            }
            None
        };
    let mut cur = 0;
    // the last body needle found, where, and its id: a needle equal to it is found at the same place, not after it,
    // when the two are two authorities' (their finds mark the same word) or the last one a section's start (the
    // tables' numbering starts at the first text after the cover, a heading's); the same authority's next mark is
    // another occurrence, searched after it. An authority's needle is compared from its find on, and its place is its
    // find's: the words before the find (lib/pandoc/xdoc.lua mark) differ from one needle to the next
    let anchored = |n: &Needle| -> (usize, String) {
        let k = if n.id.0.starts_with('a') && !n.fallback.is_empty() {
            n.needle.find(&n.fallback).unwrap_or(0)
        } else {
            0
        };
        (k, n.needle[k..].to_string())
    };
    let authority = |id: &str| {
        id.strip_prefix('a')
            .and_then(|r| r.split_once('.'))
            .map(|(k, _)| k.to_string())
    };
    let section = |id: &str| id == "front" || id == "start";
    let mut last: Option<(String, usize, &str)> = None;
    // just after the last footnote needle found
    let mut note = 0;
    let mut last_note: Option<(String, usize, &str)> = None;
    // the end of the last heading's own text: a heading is searched from there (below)
    let mut past_heading = 0;
    let mut found = vec![];
    let mut ys: Vec<Option<f64>> = vec![];
    for n in &ns {
        if n.place == Place::Dest {
            let at = dests.get(&n.needle);
            found.push(at.map_or(0, |a| a.0));
            ys.push(at.map(|a| a.1));
            continue;
        }
        if matches!(n.place, Place::Top | Place::Bottom) {
            let at = place(lines, page_at(cur).max(1), &n.needle, n.place == Place::Top);
            found.push(at.map_or(0, |a| a.0));
            ys.push(at.map(|a| a.1));
            continue;
        }
        ys.push(None);
        let heading = n.id.0.starts_with('h') || n.id.0.starts_with('H');
        let (k, at) = anchored(n);
        let from = if n.place == Place::Body {
            match &last {
                Some((t, p, id))
                    if *t == at
                        && (section(id)
                            || authority(id)
                                .zip(authority(&n.id.0))
                                .is_some_and(|(a, b)| a != b)) =>
                {
                    p.saturating_sub(k)
                }
                _ if heading => cur.max(past_heading),
                // an authority's find from `cur` on, the words before it in its needle earlier (they may be the text
                // of the needle found before, a heading's "MCL" before "14.102")
                _ => cur.saturating_sub(k),
            }
        } else {
            cur
        };
        let pos = if n.place == Place::Body {
            let find_text = if n.id.0.starts_with('a') {
                n.fallback.as_str()
            } else {
                ""
            };
            // the first occurrence from `from`, whole or over a page end: a needle whose whole text is found pages
            // later (the same words again, "protest-filing requirements in section 163-182.9") is the one split
            // before it, when that split's head is MIN_TAIL characters or more
            match find(&n.needle, from) {
                Some(p) => split(&n.needle, find_text, from, p, MIN_TAIL).or(Some(p)),
                None => split(&n.needle, find_text, from, usize::MAX, 1),
            }
            .or_else(|| find(&n.fallback, from))
        } else {
            // a footnote's needle from where the body is (the note's mark is after it, and the note is printed at the
            // foot of this page or a later one, after its body text), else from the start of the body's page, and after
            // the last note's needle found (notes are printed in document order: a note that repeats an earlier one's
            // text is found after it, not on the earlier note's page)
            // (an equal needle of another authority, the same note's: where the last note needle was found)
            let note = match &last_note {
                Some((t, p, id))
                    if *t == at
                        && authority(id)
                            .zip(authority(&n.id.0))
                            .is_some_and(|(a, b)| a != b) =>
                {
                    *p
                }
                _ => note,
            };
            let page = starts
                .get(page_at(cur).saturating_sub(1))
                .copied()
                .unwrap_or(0)
                .max(note);
            let from = from.max(note);
            find(&n.needle, from)
                .or_else(|| find(&n.fallback, from))
                .or_else(|| find(&n.needle, page))
                .or_else(|| find(&n.fallback, page))
        };
        if let (Some(p), Place::Note) = (pos, n.place) {
            note = p + 1;
            last_note = Some((at.clone(), p, &n.id.0));
        }
        if let (Some(p), true) = (pos, n.place == Place::Body) {
            // past the start of an authority's find, not of the words before it in its needle: the same authority's next
            // needle is the find's next occurrence ("statevjones", then "jones"); another authority's equal one, the same
            // (above)
            let skip = if all[p..].starts_with(&n.needle) {
                k
            } else {
                0
            };
            cur = cur.max(p + skip + 1);
            last = Some((at, p + skip, &n.id.0));
            // the next heading is searched past this one's own text (its fallback), not past what follows it: its
            // needle "argument" + the next paragraph is found again inside "summary of argument" + the same words
            // otherwise; any other needle (an authority cited in the heading) is searched from the next character
            if heading {
                past_heading = p + n.fallback.len().min(n.needle.len()).max(1);
            }
        }
        // an authority's mark is where its find ends (its fallback, the find alone), as LaTeX writes it and typst sets it:
        // a citation over a page end counts on the later page
        // (the find inside the needle: the words before it come first when few follow it, lib/pandoc/xdoc.lua mark)
        let end = |p: usize| {
            if !n.id.0.starts_with('a') || n.fallback.is_empty() {
                p
            } else if all[p..].starts_with(&n.needle) {
                p + n.needle.find(&n.fallback).unwrap_or(0) + n.fallback.len() - 1
            } else if all[p..].starts_with(&n.fallback) {
                p + n.fallback.len() - 1
            } else {
                p
            }
        };
        found.push(pos.map_or(0, |p| page_at(end(p))));
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
    for ((n, &p), y) in ns.iter().zip(&found).zip(&ys) {
        if p == 0 {
            missing.push(n.id.to_string());
        }
        let l = y.map_or_else(|| label(p), |y| format!("{y:.3}"));
        out.push_str(&format!("{}\t{}\t{}\n", n.id, p, l));
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
        // an authority's citation that ends on page 2 is on page 2 (typst marks it before its last character)
        let cite = "a1.1\tB\t18usc2710onlyaperson\t18usc2710\n";
        assert_eq!(lookup(cite, &p).unwrap(), "a1.1\t2\t-\n");
    }

    #[test]
    fn an_authority_needle_with_the_words_before_it_counts_where_its_find_ends() {
        // "see Iowa Code" ends page 1, "§ 17A.19(10)(i), (j)" starts page 2: the needle holds the words before the find
        let pdf = "relevant evidence. see iowa code\n5\n\u{c}17A.19(10)(i), (j). More\n6\n\u{c}";
        let p = page_texts(pdf);
        let needles = "a1.1\tB\tevidenceseeiowacode17a1910ij\t17a1910i\n";
        assert_eq!(lookup(needles, &p).unwrap(), "a1.1\t2\t-\n");
        // the next needle, the same find alone, is its next occurrence, not the one inside the needle before
        let pdf = "held in state v jones that\n6\n\u{c}and jones again\n7\n\u{c}";
        let p = page_texts(pdf);
        let needles = "a7.1\tB\tstatevjones\tjones\na7.2\tB\tjones\tjones\n";
        assert_eq!(lookup(needles, &p).unwrap(), "a7.1\t1\t-\na7.2\t2\t-\n");
        // two authorities marking the same word, the first needle with the words before its find
        let pdf =
            "closed pursuant to 84.344.8 and 610.021(13) here\n6\n\u{c}610.021(13) again\n7\n\u{c}";
        let p = page_texts(pdf);
        let needles = "a30.1\tB\tand61002113\t610021\na28.1\tB\t61002113\t61002113\n";
        assert_eq!(lookup(needles, &p).unwrap(), "a30.1\t1\t-\na28.1\t1\t-\n");
    }

    #[test]
    fn a_note_that_repeats_an_earlier_one_is_found_after_it() {
        let pdf = "Body one.1\n1 Smith, A Book 2011 at 4.\n1\n\u{c}Body two.2\n2 Smith, A Book 2011 at 9.\n2\n\u{c}";
        let p = page_texts(pdf);
        let notes = "a:1\tN\tsmithabook2011\tsmith\na:2\tN\tsmithabook2011\tsmith\n";
        assert_eq!(lookup(notes, &p).unwrap(), "a:1\t1\t-\na:2\t2\t-\n");
        // two authorities' equal needles in one note are found in that note; the next note that repeats it, after
        // another needle, in the next note
        let pdf = "Body one.1\n1 Smith, A Book 2011 at 4, and Jones.\n1\n\u{c}Body two.2\n2 Smith, A Book 2011 at 9, and Jones.\n2\n\u{c}";
        let p = page_texts(pdf);
        let notes = "a30.2\tN\tsmithabook2011\tsmith\na28.2\tN\tsmithabook2011\tsmith\na5.1\tN\tjones\tjones\na30.7\tN\tsmithabook2011\tsmith\n";
        assert_eq!(
            lookup(notes, &p).unwrap(),
            "a30.2\t1\t-\na28.2\t1\t-\na5.1\t1\t-\na30.7\t2\t-\n"
        );
    }

    #[test]
    fn a_footnote_needle_is_found_after_the_body() {
        // the body cites Town of Delavan on page 1; the note that cites it again has its mark on page 2
        let pdf =
            "in Town of Delavan the Court\n1\n\u{c}held more\n1 Despite Town of Delavan\n2\n\u{c}";
        let p = page_texts(pdf);
        let needles = "a1.1\tB\ttownofdelavanthecourt\tdelavan\nP:1\tB\theldmore\theld\na1.2\tN\ttownofdelavan\tdelavan\n";
        assert_eq!(
            lookup(needles, &p).unwrap(),
            "a1.1\t1\t-\nP:1\t2\t-\na1.2\t2\t-\n"
        );
    }

    #[test]
    fn a_needle_over_a_page_end_is_found_before_its_words_again() {
        // "protest-filing" ends page 1 above a footnote, "requirements in section 163-182.9" starts page 2; the same
        // words come again whole on page 3: the citation is the one over the page end, on page 2
        let pdf = "the protest filing\n3 See note.\n6\n\u{c}requirements in section 163-182.9. Id. more\n7\n\u{c}failed the protest filing requirements in section 163-182.9 again\n8\n\u{c}";
        let p = page_texts(pdf);
        let needles =
            "a38.3\tB\tprotestfilingrequirementsinsection1631829\t1631829\nh6\tB\tmore\tmore\n";
        assert_eq!(lookup(needles, &p).unwrap(), "a38.3\t2\t-\nh6\t2\t-\n");
    }

    #[test]
    fn an_authority_needle_starts_in_the_heading_before_it() {
        // the heading "MCL 14.102" and the authority it cites: the authority's needle holds "MCL" before its find, the
        // heading's text the search is past
        let pdf = "mcl 14.102 any action at law\n4\n\u{c}see mcl 14.102 later\n5\n\u{c}";
        let p = page_texts(pdf);
        let needles = "h4\tB\tmcl14102anyactionatlaw\tmcl14102\na32.1\tB\tmcl14102\t14102\nh5\tB\tanyaction\tanyaction\n";
        assert_eq!(
            lookup(needles, &p).unwrap(),
            "h4\t1\t-\na32.1\t1\t-\nh5\t1\t-\n"
        );
    }

    #[test]
    fn a_position_needle_reads_the_line_of_its_text() {
        let x = r#"<doc><page width="612" height="792"><flow><block>
<line xMin="1" yMin="84.3" xMax="9" yMax="98.708"><word xMin="1" yMin="1" xMax="2" yMax="2">STATE</word><word xMin="1" yMin="1" xMax="2" yMax="2">OF</word></line>
<line xMin="1" yMin="1" xMax="9" yMax="128.6"><word xMin="1" yMin="1" xMax="2" yMax="2">A&amp;B</word></line>
<line xMin="1" yMin="1" xMax="9" yMax="700.5"><word xMin="1" yMin="1" xMax="2" yMax="2">Counsel</word><word xMin="1" yMin="1" xMax="2" yMax="2">for</word></line>
<line xMin="1" yMin="1" xMax="9" yMax="714"><word xMin="1" yMin="1" xMax="2" yMax="2">Appellant</word></line>
</block></flow></page><page width="612" height="792"><line xMin="1" yMin="1" xMax="9" yMax="90"><word xMin="1" yMin="1" xMax="2" yMax="2">Body</word></line></page></doc>"#;
        let lines = bbox_lines(x);
        assert_eq!(lines.len(), 2);
        assert_eq!(lines[0].text, "stateofabcounselforappellant");
        let pages = vec![lines[0].text.clone(), lines[1].text.clone()];
        let needles = "T1\tT\tstateof\t\nY1.1:20\tY\tforappellant\t\nH\tB\tbody\tbody\n";
        assert!(wants_lines(needles) && !wants_lines("H\tB\tbody\tbody\n"));
        // T: the line of the needle's first character; Y: the line of its last (here the needle runs over two)
        assert_eq!(
            lookup_lines(needles, &pages, &lines).unwrap(),
            "T1\t1\t98.708\nY1.1:20\t1\t714.000\nH\t2\t-\n"
        );
        assert!(lookup_lines("Y1\tY\tnowhere\t\n", &pages, &lines).is_err());
    }

    #[test]
    fn two_finds_of_the_same_word_are_found_at_the_same_place() {
        // "RCW 10.77" and "RCW 10.77.010" both mark the word "10.77.010": two needles alike; the later citations
        // are still found after them
        let pages = page_texts("See RCW 10.77.010 for it. Later RCW 10.77 again.\n1\n\u{c}");
        let needles = "a1.1\tB\t1077010forit\t1077\na2.1\tB\t1077010forit\t1077010\na1.2\tB\t1077again\t1077\n";
        assert_eq!(
            lookup(needles, &pages).unwrap(),
            "a1.1\t1\t-\na2.1\t1\t-\na1.2\t1\t-\n"
        );
        // the same authority marked twice where its needle reads alike: two occurrences, the second on its own page
        let pages = page_texts(
            "Weiss v. Cent, 326 Ark. 685.\n8\n\u{c}Weiss v. Cent, 326 Ark. 685.\n9\n\u{c}",
        );
        let needles = "a1.1\tB\tweissvcent326ark685\tweiss\na1.2\tB\tweissvcent326ark685\tweiss\n";
        assert_eq!(lookup(needles, &pages).unwrap(), "a1.1\t1\t-\na1.2\t2\t-\n");
    }

    #[test]
    fn an_authority_over_a_page_end_counts_on_the_later_page() {
        // the citation "Doe v. Roe" runs from page 1 onto page 2: its mark is where it ends, as in LaTeX and typst
        let p = page_texts("See Doe v.\n1\n\u{c}Roe holds it.\n2\n\u{c}");
        let needles = "a1.1\tB\tdoevroeholdsit\tdoevroe\n";
        assert_eq!(lookup(needles, &p).unwrap(), "a1.1\t2\t-\n");
    }

    #[test]
    fn a_heading_that_starts_a_section_is_found_where_the_section_starts() {
        // the tables' numbering starts at the first text after the cover, which is a heading's: both needles alike
        let p = page_texts("COURT\n\u{c}DISCLOSURE STATEMENT\nNone.\ni\n\u{c}CONTENTS\nDisclosure Statement i\nii\n\u{c}");
        let needles = "front\tB\tdisclosurestatement\tdisclosurestatement\nh1\tB\tdisclosurestatement\tdisclosurestatement\n";
        assert_eq!(lookup(needles, &p).unwrap(), "front\t2\t-\nh1\t2\t-\n");
    }

    #[test]
    fn a_needle_is_not_found_again_inside_the_one_before() {
        // "argument" + the paragraph after it also reads inside "summary of argument" + the same words
        let p = page_texts("SUMMARY OF ARGUMENT\nThe injunction holds\n1\n\u{c}ARGUMENT\nThe injunction allows\n2\n\u{c}");
        let needles = "H:1\tB\tsummaryofargumenttheinjunction\tsummaryofargument\nH:2\tB\targumenttheinjunction\targument\n";
        assert_eq!(lookup(needles, &p).unwrap(), "H:1\t1\t-\nH:2\t2\t-\n");
    }

    #[test]
    fn a_missing_needle_is_an_error() {
        let e = lookup("H:1\tB\tnowhere\tnowhere\n", &pages()).unwrap_err();
        assert!(e.contains("H:1"));
    }
}
