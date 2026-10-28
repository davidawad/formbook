//! DEF-COVER-002, `cover_structure`: page 1 of the render has the structure of page 1 of its FILED-EXAMPLE.
//!
//! The INPUT of a sample is transcribed from the same-id FILED-EXAMPLE, so the two first pages carry largely the
//! same words; what must also agree is how they are set. Each line is cut into its column segments (a caption's
//! `Plaintiff, )  Case No. 1` is two), segments are paired by their words (multiset overlap, so a line broken
//! differently still pairs with its pieces), never by position, and then compared on structure only:
//!
//! - order: of two exemplar segments in one column, the upper one is not more than a line below the other in
//!   ours (a block moved above or below another fails; a paragraph re-broken does not);
//! - alignment: left, centered, right or indented to about the same place, per paired segment that is alone on
//!   its line on at least one side (segments nearly as wide as the text frame are not judged);
//! - horizontal rules: the same number of rules (a double rule is two) between the same paired segments;
//! - a date line: when the exemplar's page 1 has a short line carrying a date, the render's page 1 has a date.
//!
//! Fonts, sizes, leading and exact positions are not compared (tier 3; `fb diff` and the overlay show those).
//! The exemplar page compared is whichever of its first three our page 1 transcribes best (a filing may lead with a
//! notice); when none shares enough lines, that is a finding (our cover leaves most of it out, or the INPUT
//! transcribes another filing). The check passes, saying why, when the sample has no FILED-EXAMPLE or the exemplar
//! has no text layer.
//! `fb cover-structure <exemplar.pdf> <render.pdf>...` runs the same test on any pair.
use crate::measure::{self, Line, Page, Rect, Word};
use crate::{fail, Res};
use std::collections::BTreeMap;
use std::process::ExitCode;

/// Findings listed per sample (first ones first); the measured line gives the total.
const LIST: usize = 12;
/// A segment at least this share of the text frame wide is not judged for alignment.
const WIDE: f64 = 0.8;
/// Left or right edge within this of the frame's edge: aligned to it.
const EDGE_PT: f64 = 6.0;
/// Centre within this share of the frame width of the frame's or the page's centre: centered.
const CENTER: f64 = 0.06;
/// An indent up to this (1 in) is a paragraph or caption indent and still counts as left-aligned.
const PARA_INDENT_PT: f64 = 72.0;
/// Two indented segments start at about the same place when their indents differ by at most this share of the frame.
const INDENT: f64 = 0.12;
/// A gap between two words wider than this many line heights separates two columns of one line.
const COLUMN_GAP: f64 = 1.5;
/// A horizontal rule: at most RULE_PT thick and at least RULE_MIN_PT (1 in) long. A rule that starts at the frame's
/// left edge and is shorter than FOOTNOTE_RULE of the frame is a footnote separator, not part of the cover.
const RULE_PT: f64 = 3.0;
const RULE_MIN_PT: f64 = 72.0;
const FOOTNOTE_RULE: f64 = 0.45;
/// Fewer text lines than this on the exemplar's page 1: a scan, nothing to compare.
const MIN_LINES: usize = 3;
/// Fewer of the exemplar's segments than this share paired: our page 1 is not the same page (a finding).
const MIN_PAIRED: f64 = 0.4;
/// The exemplar pages searched for the one our page 1 transcribes (a filing may lead with a notice or docket sheet).
const EXEMPLAR_PAGES: usize = 3;
/// A date line has at most this many words (a date inside a paragraph is content, not a date line).
const DATE_WORDS: usize = 8;
/// Order is judged only on pairs this sure (dice), alignment on pairs SURE_ALIGN sure: a paragraph broken
/// differently pairs its lines loosely.
const SURE_ORDER: f64 = 0.6;
const SURE_ALIGN: f64 = 0.5;
/// Segments within this many line heights of each other, starting at one x, make a left-aligned block.
const BLOCK_LINES: f64 = 4.0;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Align {
    Left,
    Center,
    Right,
    /// Starting this far right of the frame's left edge, neither centered nor right-aligned.
    Indent(f64),
    /// Too wide to tell.
    Wide,
}

impl Align {
    fn name(&self) -> String {
        match self {
            Align::Left => "left".into(),
            Align::Center => "centered".into(),
            Align::Right => "right".into(),
            Align::Indent(dx) => format!("indented {dx:.0} pt"),
            Align::Wide => "full width".into(),
        }
    }
}

/// One column segment of a line.
#[derive(Debug, Clone)]
pub struct Seg {
    pub text: String,
    pub left: f64,
    pub right: f64,
    pub top: f64,
    pub bottom: f64,
    pub baseline: f64,
    /// The only segment of its line.
    pub alone: bool,
    /// One of three or more segments a few lines apart that start at the same x and end at different ones: a
    /// left-aligned block (an indented counsel block), whose short lines are not centered however they fall.
    pub flush: bool,
    pub words: Vec<String>,
}

impl Seg {
    fn mid(&self) -> f64 {
        (self.top + self.bottom) / 2.0
    }
    fn height(&self) -> f64 {
        (self.bottom - self.top).max(1.0)
    }
}

/// The page-1 facts the comparison needs.
pub struct Cover {
    pub segs: Vec<Seg>,
    /// Text frame: (left, right).
    pub frame: (f64, f64),
    pub width: f64,
    pub height: f64,
    pub rules: Vec<Rect>,
}

/// Lowercase alphanumeric words of a text (punctuation and case are template choices).
pub fn words(text: &str) -> Vec<String> {
    text.split_whitespace()
        .map(|w| {
            crate::diff::content::norm(w)
                .chars()
                .filter(|c| c.is_alphanumeric())
                .flat_map(char::to_lowercase)
                .collect::<String>()
        })
        .filter(|w| !w.is_empty())
        .collect()
}

/// A text that is only a number (a page number, a pleading line number): not part of the cover's structure.
fn numeral(t: &str) -> bool {
    let t = t
        .trim()
        .trim_matches(|c| matches!(c, '-' | '–' | '—' | ' '));
    super::coverpages::page_number(t).is_some()
}

/// The column segments of a line: its words cut where the gap to the next word exceeds COLUMN_GAP line heights.
/// Segments without a letter or digit (a caption's `)` column) and lone numbers are left out.
fn segments(l: &Line) -> Vec<Seg> {
    let gap = COLUMN_GAP * (l.bottom - l.top).max(1.0);
    let mut groups: Vec<Vec<&Word>> = Vec::new();
    for w in &l.words {
        match groups.last_mut() {
            Some(g) if w.x0 - g.last().unwrap().x1 <= gap => g.push(w),
            _ => groups.push(vec![w]),
        }
    }
    let segs: Vec<Seg> = groups
        .iter()
        .map(|g| {
            let text = g.iter().map(|w| w.t.as_str()).collect::<Vec<_>>().join(" ");
            Seg {
                words: words(&text),
                text,
                left: g[0].x0,
                right: g.last().unwrap().x1,
                top: l.top,
                bottom: l.bottom,
                baseline: l.baseline,
                alone: false,
                flush: false,
            }
        })
        .filter(|s| !s.words.is_empty() && !numeral(&s.text))
        .collect();
    let alone = segs.len() == 1;
    segs.into_iter().map(|s| Seg { alone, ..s }).collect()
}

impl Cover {
    pub fn of(page: &Page) -> Cover {
        let mut segs: Vec<Seg> = page.lines.iter().flat_map(segments).collect();
        let flush: Vec<bool> = segs
            .iter()
            .map(|s| {
                let near: Vec<&Seg> = segs
                    .iter()
                    .filter(|o| {
                        (o.top - s.top).abs() <= BLOCK_LINES * s.height()
                            && (o.left - s.left).abs() <= 1.5
                    })
                    .collect();
                near.len() >= 3 && near.iter().any(|o| (o.right - s.right).abs() > EDGE_PT)
            })
            .collect();
        for (s, f) in segs.iter_mut().zip(flush) {
            s.flush = f;
        }
        let frame = segs
            .iter()
            .fold(None, |f: Option<(f64, f64)>, s| {
                Some(f.map_or((s.left, s.right), |(a, b)| (a.min(s.left), b.max(s.right))))
            })
            .unwrap_or((0.0, page.w));
        let fw = (frame.1 - frame.0).max(1.0);
        let masked: Vec<Rect> = page
            .masked
            .iter()
            .filter(|m| m.kind.starts_with("region"))
            .map(|m| m.bbox)
            .collect();
        let underline = |r: &Rect| {
            segs.iter().any(|s| {
                r.x0 >= s.left - EDGE_PT
                    && r.x1 <= s.right + EDGE_PT
                    && r.y0 >= s.baseline - 2.0
                    && r.y0 <= s.bottom + 4.0
            })
        };
        // a rule typed as a row of underscores is a rule too
        let typed = page.lines.iter().flat_map(|l| {
            l.words
                .iter()
                .filter(|w| w.t.chars().count() >= 3 && w.t.chars().all(|c| c == '_'))
                .map(|w| Rect {
                    x0: w.x0,
                    y0: w.y1 - 1.0,
                    x1: w.x1,
                    y1: w.y1,
                })
        });
        let all = page
            .rules
            .iter()
            .copied()
            .chain(typed)
            .filter(|r| r.h() <= RULE_PT && r.w() >= RULE_MIN_PT)
            .filter(|r| !((r.x0 - frame.0).abs() <= EDGE_PT && r.w() < FOOTNOTE_RULE * fw))
            .filter(|r| {
                let (cx, cy) = ((r.x0 + r.x1) / 2.0, (r.y0 + r.y1) / 2.0);
                !masked.iter().any(|m| m.contains_pt(cx, cy))
            })
            .filter(|r| !underline(r))
            .collect::<Vec<Rect>>();
        // one rule drawn twice (LibreOffice paints a paragraph border as two identical rectangles) is one rule
        let mut rules: Vec<Rect> = Vec::new();
        for r in all {
            let same = |q: &Rect| {
                (q.y0 - r.y0).abs() < 0.5 && (q.x0 - r.x0).abs() < 0.5 && (q.x1 - r.x1).abs() < 0.5
            };
            if !rules.iter().any(same) {
                rules.push(r);
            }
        }
        Cover {
            segs,
            frame,
            width: page.w,
            height: page.h,
            rules,
        }
    }

    pub fn align(&self, s: &Seg) -> Align {
        let (fl, fr) = self.frame;
        let fw = self.fw();
        if s.right - s.left >= WIDE * fw {
            return Align::Wide;
        }
        let c = (s.left + s.right) / 2.0;
        if (s.left - fl).abs() <= EDGE_PT {
            Align::Left
        } else if (fr - s.right).abs() <= EDGE_PT {
            Align::Right
        } else if !s.flush
            && [(fl + fr) / 2.0, self.width / 2.0]
                .iter()
                .any(|m| (c - m).abs() <= CENTER * fw)
        {
            Align::Center
        } else {
            Align::Indent(s.left - fl)
        }
    }

    fn fw(&self) -> f64 {
        (self.frame.1 - self.frame.0).max(1.0)
    }
}

/// Two alignments that a reader sees as the same placement; `lefts` are the two segments' offsets from their
/// frames' left edges and `fa`, `fb` the frame widths.
fn same_place(a: Align, fa: f64, b: Align, fb: f64, lefts: (f64, f64)) -> bool {
    use Align::*;
    let left = |x: Align| matches!(x, Left) || matches!(x, Indent(dx) if dx <= PARA_INDENT_PT);
    match (a, b) {
        (Wide, _) | (_, Wide) => true,
        _ if left(a) && left(b) => true,
        (Indent(x), Indent(y)) => (x / fa - y / fb).abs() <= INDENT,
        // a block indented to the middle whose longest line happens to reach the frame's right edge
        (Right, Indent(_)) | (Indent(_), Right) => (lefts.0 / fa - lefts.1 / fb).abs() <= INDENT,
        _ => a == b,
    }
}

const MONTHS: [&str; 12] = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
];

/// A text that carries a calendar date: a month name (or its abbreviation) followed by a year, or d/m/yyyy.
pub fn is_date(text: &str) -> bool {
    let ws: Vec<String> = text
        .split_whitespace()
        .map(|w| {
            w.trim_matches(|c: char| !c.is_alphanumeric() && c != '/')
                .to_lowercase()
        })
        .collect();
    let year = |w: &str| {
        w.len() == 4
            && w.chars().all(|c| c.is_ascii_digit())
            && (w.starts_with("19") || w.starts_with("20"))
    };
    let month = |w: &str| {
        MONTHS.iter().any(|m| {
            w == *m || ((w.len() == 3 || w == "sept") && m.starts_with(w.trim_end_matches('.')))
        })
    };
    let slash = |w: &str| {
        let p: Vec<&str> = w.split('/').collect();
        p.len() == 3
            && p.iter()
                .all(|x| !x.is_empty() && x.chars().all(|c| c.is_ascii_digit()))
            && p[0].len() <= 2
            && p[1].len() <= 2
            && matches!(p[2].len(), 2 | 4)
    };
    ws.iter()
        .enumerate()
        .any(|(i, w)| slash(w) || (month(w) && ws[i + 1..].iter().take(3).any(|y| year(y))))
}

/// How much of their words two segments share: 2 x common / (both word counts).
fn dice(a: &Seg, b: &Seg) -> f64 {
    2.0 * common(&a.words, &b.words) as f64 / (a.words.len() + b.words.len()).max(1) as f64
}

/// Multiset intersection size of two word lists.
fn common(a: &[String], b: &[String]) -> usize {
    let mut m: BTreeMap<&str, i32> = BTreeMap::new();
    for w in a {
        *m.entry(w).or_default() += 1;
    }
    b.iter()
        .filter(|w| {
            m.get_mut(w.as_str())
                .filter(|n| **n > 0)
                .map(|n| *n -= 1)
                .is_some()
        })
        .count()
}

/// For every exemplar segment, the render segment that shares most of its words (None when none does); ties go
/// to the one at the nearest relative height. A render segment's words are claimed once: when several exemplar
/// segments pick the same one, the best match takes its words first and a segment left without enough of them is
/// unpaired (an exemplar repeating a party's name in its counsel block does not pair twice with the one caption line).
pub fn pair(ex: &Cover, us: &Cover) -> Vec<Option<usize>> {
    let rel = |c: &Cover, s: &Seg| s.mid() / c.height.max(1.0);
    let enough = |n: usize, a: &Seg, b: &Seg| {
        n > 0 && n as f64 >= 0.6 * a.words.len().min(b.words.len()) as f64
    };
    let best: Vec<Option<(usize, f64, f64)>> = ex
        .segs
        .iter()
        .map(|e| {
            let ye = rel(ex, e);
            us.segs
                .iter()
                .enumerate()
                .filter_map(|(j, u)| {
                    let dice = dice(e, u);
                    (enough(common(&e.words, &u.words), e, u) && dice >= 0.3)
                        .then(|| (j, (dice * 20.0).round(), (ye - rel(us, u)).abs()))
                })
                .max_by(|a, b| a.1.total_cmp(&b.1).then(b.2.total_cmp(&a.2)))
        })
        .collect();
    let mut order: Vec<usize> = (0..ex.segs.len()).filter(|&i| best[i].is_some()).collect();
    order.sort_by(|&a, &b| {
        let (a, b) = (best[a].unwrap(), best[b].unwrap());
        b.1.total_cmp(&a.1).then(a.2.total_cmp(&b.2))
    });
    let mut left: Vec<Vec<String>> = us.segs.iter().map(|u| u.words.clone()).collect();
    let mut map = vec![None; ex.segs.len()];
    for i in order {
        let j = best[i].unwrap().0;
        let e = &ex.segs[i];
        if enough(common(&e.words, &left[j]), e, &us.segs[j]) {
            for w in &e.words {
                if let Some(k) = left[j].iter().position(|x| x == w) {
                    left[j].swap_remove(k);
                }
            }
            map[i] = Some(j);
        }
    }
    map
}

fn quote(text: &str) -> String {
    let t: String = text.split_whitespace().collect::<Vec<_>>().join(" ");
    match t.char_indices().nth(48) {
        Some((i, _)) => format!("\"{}...\"", &t[..i]),
        None => format!("\"{t}\""),
    }
}

/// Exemplar segment `i` is paired, sharing at least `min` (dice) of its words with its partner.
fn sure(ex: &Cover, us: &Cover, map: &[Option<usize>], i: usize, min: f64) -> bool {
    map[i].is_some_and(|j| dice(&ex.segs[i], &us.segs[j]) >= min)
}

fn overlap(a: &Seg, b: &Seg) -> bool {
    a.left < b.right && b.left < a.right
}

/// Exemplar segments `(i, k)`, `i` above `k` in one column, whose render segments are the other way round by
/// more than a line. Only segments of two words or more (a lone "v." or "and" pairs too easily).
fn inversions(ex: &Cover, us: &Cover, map: &[Option<usize>]) -> Vec<(usize, usize)> {
    let judged: Vec<usize> = (0..ex.segs.len())
        .filter(|&i| sure(ex, us, map, i, SURE_ORDER) && ex.segs[i].words.len() >= 2)
        .collect();
    let mut out = Vec::new();
    for &i in &judged {
        for &k in &judged {
            let (a, b) = (&ex.segs[i], &ex.segs[k]);
            if !(a.bottom <= b.top + 0.5 && overlap(a, b)) {
                continue;
            }
            let (ua, ub) = (&us.segs[map[i].unwrap()], &us.segs[map[k].unwrap()]);
            if ua.top > ub.bottom + ub.height() && overlap(ua, ub) {
                out.push((i, k));
            }
        }
    }
    out
}

/// The verdict: (pass, measured, findings), one finding per segment, block or gap that differs.
pub fn compare(ex: &Cover, us: &Cover) -> (bool, String, Vec<String>) {
    if ex.segs.len() < MIN_LINES {
        return (
            true,
            format!(
                "exemplar page 1 has {} text lines (no text layer): nothing to compare",
                ex.segs.len()
            ),
            vec![],
        );
    }
    let map = pair(ex, us);
    let paired = map.iter().filter(|m| m.is_some()).count();
    if (paired as f64) < MIN_PAIRED * ex.segs.len() as f64 {
        return (
            false,
            format!("{paired}/{} exemplar lines paired", ex.segs.len()),
            vec![format!(
                "page: only {paired} of the exemplar's {} cover lines are on our page 1: our cover leaves most of them \
                 out, or the INPUT transcribes another filing (or the exemplar's text layer is unreadable)",
                ex.segs.len()
            )],
        );
    }
    let mut findings = Vec::new();
    // order: report the segment in most inversions, drop its inversions, repeat
    let mut inv = inversions(ex, us, &map);
    let mut moved: Vec<usize> = Vec::new();
    while !inv.is_empty() {
        let mut n: BTreeMap<usize, usize> = BTreeMap::new();
        for &(i, k) in &inv {
            *n.entry(i).or_default() += 1;
            *n.entry(k).or_default() += 1;
        }
        let worst = *n
            .iter()
            .max_by_key(|(i, c)| (**c, usize::MAX - **i))
            .unwrap()
            .0;
        let (&(i, k), up) = inv
            .iter()
            .find(|(i, _)| *i == worst)
            .map(|p| (p, false))
            .unwrap_or_else(|| (inv.iter().find(|(_, k)| *k == worst).unwrap(), true));
        let other = if up { i } else { k };
        findings.push(format!(
            "order: {} is {} {} in ours; the exemplar has it {}",
            quote(&ex.segs[worst].text),
            if up { "above" } else { "below" },
            quote(&ex.segs[other].text),
            if up { "below" } else { "above" },
        ));
        moved.push(worst);
        inv.retain(|&(a, b)| a != worst && b != worst);
    }
    // alignment, on every paired segment that kept its place and is alone on its line on one side at least; a run of
    // consecutive exemplar segments that differ the same way (a counsel block) is one finding
    struct Run<'a> {
        first: usize,
        n: usize,
        kinds: (String, String),
        names: (String, String),
        ours: &'a Seg,
    }
    let kind = |a: Align| match a {
        Align::Indent(_) => "indented".to_string(),
        a => a.name(),
    };
    let flush = |r: Option<Run>, findings: &mut Vec<String>| {
        if let Some(r) = r {
            let (lines, verb) = match r.n {
                1 => (String::new(), "is"),
                n => (format!(" and the {} lines after it", n - 1), "are"),
            };
            findings.push(format!(
                "alignment: {}{lines} {verb} {} in the exemplar, {} in ours (x {:.1}-{:.1})",
                quote(&ex.segs[r.first].text),
                r.names.0,
                r.names.1,
                r.ours.left,
                r.ours.right
            ));
        }
    };
    let mut run: Option<Run> = None;
    let mut prev: Option<usize> = None;
    for i in (0..ex.segs.len()).filter(|i| sure(ex, us, &map, *i, SURE_ALIGN) && !moved.contains(i))
    {
        let (e, u) = (&ex.segs[i], &us.segs[map[i].unwrap()]);
        if !e.alone && !u.alone {
            continue;
        }
        let (ae, au) = (ex.align(e), us.align(u));
        let lefts = (e.left - ex.frame.0, u.left - us.frame.0);
        let next = prev == Some(i.wrapping_sub(1));
        prev = Some(i);
        if same_place(ae, ex.fw(), au, us.fw(), lefts) {
            flush(run.take(), &mut findings);
            continue;
        }
        let kinds = (kind(ae), kind(au));
        match run.as_mut() {
            Some(r) if next && r.kinds == kinds => r.n += 1,
            _ => {
                flush(run.take(), &mut findings);
                run = Some(Run {
                    first: i,
                    n: 1,
                    kinds,
                    names: (ae.name(), au.name()),
                    ours: u,
                });
            }
        }
    }
    flush(run.take(), &mut findings);
    // rules, by the gap between anchors (paired segments of two words or more that kept their place)
    let anchors: Vec<usize> = (0..ex.segs.len())
        .filter(|i| {
            sure(ex, us, &map, *i, SURE_ORDER) && ex.segs[*i].words.len() >= 2 && !moved.contains(i)
        })
        .collect();
    let gaps = |c: &Cover, ys: &[f64]| {
        let mut m: BTreeMap<usize, usize> = BTreeMap::new();
        for r in &c.rules {
            let y = (r.y0 + r.y1) / 2.0;
            *m.entry(ys.iter().filter(|&&t| t < y).count()).or_default() += 1;
        }
        m
    };
    let mut ey: Vec<(f64, usize)> = anchors.iter().map(|&i| (ex.segs[i].mid(), i)).collect();
    ey.sort_by(|a, b| a.0.total_cmp(&b.0));
    let ys: Vec<f64> = ey.iter().map(|p| p.0).collect();
    let mut uy: Vec<f64> = anchors
        .iter()
        .map(|&i| us.segs[map[i].unwrap()].mid())
        .collect();
    uy.sort_by(f64::total_cmp);
    let (ge, gu) = (gaps(ex, &ys), gaps(us, &uy));
    let mut at: Vec<usize> = ge.keys().chain(gu.keys()).copied().collect();
    at.sort_unstable();
    at.dedup();
    let name = |g: usize| {
        let text = |k: usize| quote(&ex.segs[ey[k].1].text);
        match (g.checked_sub(1), (g < ey.len()).then_some(g)) {
            (Some(a), Some(b)) => format!("between {} and {}", text(a), text(b)),
            (Some(a), None) => format!("below {}", text(a)),
            (None, Some(b)) => format!("above {}", text(b)),
            (None, None) => "on the page".into(),
        }
    };
    for g in at {
        let (n, m) = (
            ge.get(&g).copied().unwrap_or(0),
            gu.get(&g).copied().unwrap_or(0),
        );
        if n != m {
            findings.push(format!(
                "rules: {}: the exemplar has {n} horizontal rule{}, ours {m}",
                name(g),
                if n == 1 { "" } else { "s" }
            ));
        }
    }
    // the date line
    let date_line = ex
        .segs
        .iter()
        .find(|s| s.words.len() <= DATE_WORDS && is_date(&s.text));
    if let Some(d) = date_line.filter(|_| !us.segs.iter().any(|s| is_date(&s.text))) {
        findings.push(format!(
            "date line: the exemplar's page 1 has {}, ours has no date",
            quote(&d.text)
        ));
    }
    let meas = format!(
        "{paired}/{} exemplar lines paired, {} rules vs {}; {} differences",
        ex.segs.len(),
        ex.rules.len(),
        us.rules.len(),
        findings.len()
    );
    (findings.is_empty(), meas, findings)
}

/// The doc folders and engines that failed the check when it was introduced (fb-595.78), one `<doc folder>
/// <engine>` per line, repo-relative and sorted. They print the verdict as REPORTED until their cover is fixed and
/// the line removed; every other folder fails on a difference.
pub const BASELINE: &str = "data/cover-structure-baseline.txt";

/// The (doc folder, engine) pairs of the baseline text; `#` comments and blank lines skipped.
pub fn parse_baseline(text: &str) -> Vec<(String, String)> {
    text.lines()
        .map(str::trim)
        .filter(|l| !l.is_empty() && !l.starts_with('#'))
        .filter_map(|l| {
            let (d, e) = l.split_once(char::is_whitespace)?;
            Some((d.to_string(), e.trim().to_string()))
        })
        .collect()
}

/// The mode of the check for a doc folder (repo-relative) and engine: `params.cover_structure` when the folder
/// sets it (`gate` or `report`), else `report` for a baseline entry and `gate` for every other folder.
pub fn gated_by(param: &str, baseline: &[(String, String)], doc: &str, engine: &str) -> bool {
    match param.trim() {
        "gate" => true,
        "report" => false,
        _ => !baseline.iter().any(|(d, e)| d == doc && e == engine),
    }
}

/// True when this run fails on a difference; false when it only reports it.
pub fn gated(c: &super::Ctx) -> Res<bool> {
    let param = super::sh::cfg(&c.env, &c.checks, ".params.cover_structure // \"\"")?;
    let root = c.root.trim_end_matches('/');
    let doc = c
        .doc
        .strip_prefix(root)
        .map_or(c.doc.as_str(), |d| d.trim_start_matches('/'));
    let text = std::fs::read_to_string(format!("{root}/{BASELINE}")).unwrap_or_default();
    Ok(gated_by(&param, &parse_baseline(&text), doc, &c.engine))
}

/// The first `n` pages of `pdf`, measured with its mask file regions.
pub fn first_pages(pdf: &std::path::Path, n: usize) -> Res<Vec<Cover>> {
    Ok(measure::measure_first(pdf, n)?
        .pages
        .iter()
        .map(Cover::of)
        .collect())
}

/// Of the exemplar's first pages, the one our page 1 transcribes: the most of its lines paired (a filing may lead
/// with a notice or a docket sheet). Its number (1-based) and cover; None when no page has a text layer.
pub fn exemplar_cover(pages: Vec<Cover>, us: &Cover) -> Option<(usize, Cover)> {
    pages
        .into_iter()
        .enumerate()
        .filter(|(_, c)| c.segs.len() >= MIN_LINES)
        .map(|(k, c)| {
            let share =
                pair(&c, us).iter().filter(|m| m.is_some()).count() as f64 / c.segs.len() as f64;
            (k + 1, c, share)
        })
        .fold(None, |best: Option<(usize, Cover, f64)>, x| match best {
            Some(b) if b.2 >= x.2 => Some(b),
            _ => Some(x),
        })
        .map(|(k, c, _)| (k, c))
}

/// A difference from the exemplar accepted as one filer's style (tier 3), from `params.cover_structure_accepted` in
/// eval.yaml: every finding that starts with `finding` is printed as ACCEPTED with `reason` and not counted.
#[derive(Debug, Clone, PartialEq, serde::Deserialize)]
pub struct Accepted {
    pub finding: String,
    pub reason: String,
}

/// The accepted list of the merged checks file (`[]` when there is none).
pub fn accepted(c: &super::Ctx) -> Res<Vec<Accepted>> {
    let json = super::sh::cfg(
        &c.env,
        &c.checks,
        "(.params.cover_structure_accepted // []) | @json",
    )?;
    let list: Vec<Accepted> = serde_json::from_str(json.trim()).map_err(|e| {
        fail(
            2,
            format!(
                "params.cover_structure_accepted: a list of {{finding, reason}} is expected: {e}"
            ),
        )
    })?;
    match list
        .iter()
        .find(|a| a.finding.trim().is_empty() || a.reason.trim().is_empty())
    {
        Some(a) => Err(fail(
            2,
            format!(
                "params.cover_structure_accepted: an entry needs a finding and a reason: {a:?}"
            ),
        )),
        None => Ok(list),
    }
}

/// The check of one sample: `exemplar` None (or missing) when the sample has no FILED-EXAMPLE. Findings in
/// `accept` are listed as ACCEPTED and do not fail it.
pub fn judge(
    exemplar: Option<&std::path::Path>,
    render: &std::path::Path,
    accept: &[Accepted],
) -> Res<(bool, String, String)> {
    let Some(ex) = exemplar.filter(|p| p.is_file()) else {
        return Ok((
            true,
            "no same-id FILED-EXAMPLE: nothing to compare".into(),
            String::new(),
        ));
    };
    let Some(u) = first_pages(render, 1)?.into_iter().next() else {
        return Ok((false, "the render has no page 1".into(), String::new()));
    };
    // poppler cannot read a damaged exemplar's text: nothing to compare, as with a scan
    let pages = first_pages(ex, EXEMPLAR_PAGES).unwrap_or_default();
    let Some((k, e)) = exemplar_cover(pages, &u) else {
        return Ok((
            true,
            format!("the exemplar's first {EXEMPLAR_PAGES} pages have no text layer: nothing to compare"),
            String::new(),
        ));
    };
    let (_, meas, found) = compare(&e, &u);
    let meas = match k {
        1 => meas,
        k => format!("exemplar page {k} (the cover): {meas}"),
    };
    let (ok, detail) = verdict(&found, accept);
    let taken = found.len() - found.iter().filter(|f| why(f, accept).is_none()).count();
    let meas = match taken {
        0 => meas,
        n => format!("{meas} ({n} accepted)"),
    };
    Ok((ok, meas, detail))
}

fn why<'a>(finding: &str, accept: &'a [Accepted]) -> Option<&'a str> {
    accept
        .iter()
        .find(|a| finding.starts_with(a.finding.as_str()))
        .map(|a| a.reason.as_str())
}

/// (pass, detail): failing findings first (at most LIST), then the accepted ones with their reasons.
pub fn verdict(found: &[String], accept: &[Accepted]) -> (bool, String) {
    let (open, taken): (Vec<&String>, Vec<&String>) =
        found.iter().partition(|f| why(f, accept).is_none());
    let mut detail: Vec<String> = open.iter().take(LIST).map(|f| f.to_string()).collect();
    if open.len() > LIST {
        detail.push(format!("... and {} more", open.len() - LIST));
    }
    detail.extend(
        taken
            .iter()
            .map(|f| format!("ACCEPTED {f} ({})", why(f, accept).unwrap_or_default())),
    );
    (open.is_empty(), detail.join("\n"))
}

/// `fb cover-structure <exemplar.pdf> <render.pdf>...`: each render against the exemplar, OK or FAIL, then the
/// findings. Exit 1 when any render fails.
pub fn main(args: &[String]) -> Res<ExitCode> {
    let usage = || {
        fail(
            2,
            "usage: fb cover-structure <exemplar.pdf> <render.pdf>...",
        )
    };
    let [ex, renders @ ..] = args else {
        return Err(usage());
    };
    if renders.is_empty() {
        return Err(usage());
    }
    let mut bad = false;
    for r in renders {
        for p in [ex, r] {
            if !std::path::Path::new(p).is_file() {
                return Err(fail(2, format!("fb cover-structure: no such PDF: {p}")));
            }
        }
        let (ok, meas, detail) =
            judge(Some(std::path::Path::new(ex)), std::path::Path::new(r), &[])?;
        println!("{}\t{r}\t{meas}", if ok { "OK" } else { "FAIL" });
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

#[cfg(test)]
#[path = "coverstruct_tests.rs"]
mod tests;
