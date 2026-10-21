//! DEF-TOC-001, `toc_layout`: the layout of a table of contents or authorities, read back from the PDF.
//!
//! Engine-neutral: it reads the text runs (`runs.tsv`, pdf-runs.awk) and a raster of the page, never the template.
//! On every TABLE OF CONTENTS / TABLE OF AUTHORITIES page (and the leader-filled pages that continue it) it fails
//!   - a page reference ("1", "2, 3, 4", "passim") alone on a line, with no title text and no dot leaders: the
//!     reference wrapped off the entry's last line;
//!   - dot leaders with no page reference after them on the same line;
//!   - an entry whose ink comes within `MIN_CLEAR_PT` of the rule under the column heading ("Page(s)").
//! A short leader, even one dot, is accepted: \@dottedtocline sets one when a title nearly fills its line.
//!
//! `fb toc-layout [--footer-top PT] <pdf>...` (toclayout_cli.rs) runs the same analysis on any PDF.
use super::sh::io_fail;
use crate::{fail, Res};
use std::collections::BTreeSet;
use std::path::Path;
use std::process::{Command, Stdio};

/// Clear space required between the column heading's rule and the ink of the first entry below it.
pub const MIN_CLEAR_PT: f64 = 2.0;
/// Raster resolution of the rule probe, pixels per point (288 dpi).
const PX: f64 = 4.0;
const TITLES: &[&str] = &[
    "TABLE OF CONTENTS",
    "TABLE OF AUTHORITIES",
    "INDEX OF AUTHORITIES",
];

#[derive(Debug, Clone, PartialEq)]
pub struct Run {
    pub page: u32,
    pub top: f64,
    pub left: f64,
    pub width: f64,
    pub height: f64,
    pub text: String,
}

/// runs.tsv: PAGE TOP LEFT WIDTH HEIGHT ITALIC TEXT, in points.
pub fn parse_runs(tsv: &str) -> Vec<Run> {
    tsv.lines()
        .filter_map(|l| {
            let f: Vec<&str> = l.splitn(7, '\t').collect();
            let num = |i: usize| f.get(i)?.trim().parse::<f64>().ok();
            Some(Run {
                page: f.first()?.trim().parse().ok()?,
                top: num(1)?,
                left: num(2)?,
                width: num(3)?,
                height: num(4)?,
                text: f.get(6)?.to_string(),
            })
        })
        .collect()
}

#[derive(Debug)]
struct Line {
    page: u32,
    /// horizontal centre of the line
    mid: f64,
    text: String,
}

/// Runs on one page whose tops agree within a third of their height form one line, read left to right.
fn lines(runs: &[&Run]) -> Vec<Line> {
    let mut rs: Vec<&Run> = runs.to_vec();
    rs.sort_by(|a, b| (a.page, a.top).partial_cmp(&(b.page, b.top)).unwrap());
    let mut groups: Vec<Vec<&Run>> = Vec::new();
    for r in rs {
        match groups.last_mut() {
            Some(g)
                if g[0].page == r.page
                    && (r.top - g[0].top).abs() <= 0.35 * g[0].height.max(r.height) =>
            {
                g.push(r)
            }
            _ => groups.push(vec![r]),
        }
    }
    groups
        .into_iter()
        .map(|mut g| {
            g.sort_by(|a, b| a.left.partial_cmp(&b.left).unwrap());
            let mut text = String::new();
            let mut right = f64::MIN;
            let left = g[0].left;
            for r in &g {
                if !text.is_empty() && r.left > right + 1.0 {
                    text.push(' ');
                }
                text.push_str(&r.text);
                right = r.left + r.width;
            }
            Line {
                page: g[0].page,
                mid: (left + right) / 2.0,
                text,
            }
        })
        .collect()
}

/// The last run of dots on a line: dot-only words (" . . .", typst and latex leaders, or an ellipsis), led by
/// a word's own trailing dots when there are three or more ("Heading....", Word's leader tab). Returns the
/// number of dots and the byte offset just after the run. A word's single period ("Cir.", "law.") is not a dot.
fn last_dots(t: &str) -> Option<(usize, usize)> {
    let mut words = Vec::new();
    let mut start = None;
    for (i, c) in t.char_indices().chain([(t.len(), ' ')]) {
        match (c.is_whitespace(), start) {
            (true, Some(s)) => {
                words.push((s, &t[s..i]));
                start = None;
            }
            (false, None) => start = Some(i),
            _ => {}
        }
    }
    let (mut last, mut run) = (None, 0);
    for (s, w) in words {
        let trailing = w.len() - w.trim_end_matches('.').len();
        run = match (trailing == w.len(), trailing >= 3) {
            (true, _) => run + trailing,
            (false, true) => trailing,
            _ => 0,
        };
        if run > 0 {
            last = Some((run, s + w.len()));
        }
    }
    last
}

/// Leaders need at least this many dots; fewer is an ellipsis, or a leader squeezed out of its line.
const MIN_LEADER_DOTS: usize = 4;

/// The line's leader: the end of its last run of `MIN_LEADER_DOTS` or more dots.
fn leader_end(t: &str) -> Option<usize> {
    last_dots(t).and_then(|(n, e)| (n >= MIN_LEADER_DOTS).then_some(e))
}

/// A page reference: "passim", a dash for an authority with no page, or a comma list of pages: arabic (ranges,
/// "5 n.2", "12a"), roman, or a labelled page of an addendum or record ("Add-2", "ER-14"). A trailing comma
/// (the list continues on the next line) is allowed.
pub fn is_page_ref(s: &str) -> bool {
    let s = clean(s);
    let s = s.strip_suffix(',').unwrap_or(&s).trim();
    matches!(s, "–" | "—" | "-")
        || s.eq_ignore_ascii_case("passim")
        || (!s.is_empty() && s.split(',').all(page_token))
}

/// The text without zero-width characters (typst sets a word joiner before a page number).
fn clean(s: &str) -> String {
    s.chars()
        .filter(|c| !matches!(c, '\u{2060}' | '\u{200b}' | '\u{feff}'))
        .collect::<String>()
        .trim()
        .to_string()
}

fn page_token(t: &str) -> bool {
    let t = t.trim();
    if !t.is_empty() && t.chars().all(|c| "ivxlcdm".contains(c)) {
        return true;
    }
    let t = match t.split_once(" n") {
        Some((a, n)) => match n.trim_start_matches(['.', 'n']).trim() {
            n if !n.is_empty() && n.chars().all(|c| c.is_ascii_digit()) => a,
            _ => return false,
        },
        None => t,
    };
    let t = match t.split_once('-') {
        Some((pre, rest)) if !pre.is_empty() && pre.chars().all(|c| c.is_ascii_alphabetic()) => {
            rest
        }
        _ => t,
    };
    t.split(['-', '–']).all(|p| {
        let p = p.trim();
        let p = p.strip_suffix('a').unwrap_or(p);
        !p.is_empty() && p.chars().all(|c| c.is_ascii_digit())
    })
}

fn is_title(t: &str) -> bool {
    let t = t.trim();
    TITLES.iter().any(|x| t.eq_ignore_ascii_case(x))
}

/// The pages of every table: a page headed by a table title, and each following page that still holds two or
/// more entries ending in leaders and a page reference (a table that runs on).
fn table_pages(ls: &[Line]) -> BTreeSet<u32> {
    let entry = |l: &Line| {
        let t = clean(&l.text);
        leader_end(&t).is_some_and(|e| is_page_ref(&t[e..]))
    };
    let leaders = |p: u32| ls.iter().filter(|l| l.page == p && entry(l)).count();
    let mut pages = BTreeSet::new();
    for start in ls.iter().filter(|l| is_title(&l.text)).map(|l| l.page) {
        let mut p = start;
        pages.insert(p);
        while leaders(p + 1) >= 2 && !ls.iter().any(|l| l.page == p + 1 && is_title(&l.text)) {
            p += 1;
            pages.insert(p);
        }
    }
    pages
}

/// The runs that can belong to a table: not a running header (centre within 54 pt of the top, the narrowest
/// margin courts allow), not the footer (centre at or below `ftop`), not pleading line numbers.
fn body_runs(runs: &[Run], ftop: f64) -> Vec<&Run> {
    // a run belongs where its centre is: a footer page number may start just above the bottom margin
    let mid = |r: &&Run| r.top + r.height / 2.0;
    runs.iter()
        .filter(|r| mid(r) < ftop && mid(r) > 54.0)
        .filter(|r| !(r.left < 72.0 && r.text.trim().chars().all(|c| c.is_ascii_digit())))
        .collect()
}

/// The end of a line, where its page reference belongs.
fn short(t: &str) -> String {
    let t = t.trim();
    let n = t.chars().count();
    match t.char_indices().nth(n.saturating_sub(60)) {
        Some((i, _)) if i > 0 => format!("...{}", &t[i..]),
        _ => t.to_string(),
    }
}

/// The findings that the text alone shows, and the table pages.
pub fn text_findings(runs: &[Run], ftop: f64) -> (BTreeSet<u32>, Vec<String>) {
    let ls = lines(&body_runs(runs, ftop));
    let pages = table_pages(&ls);
    let mut out = Vec::new();
    // The folio: a page number centred under a table's title, on the last line of the page. Templates with
    // margins wider than the footer line `ftop` assumes put it above that line (`fb toc-layout` guesses `ftop`).
    let title_mid: Vec<f64> = ls
        .iter()
        .filter(|l| is_title(&l.text))
        .map(|l| l.mid)
        .collect();
    let folio = |i: usize| {
        let l = &ls[i];
        ls.get(i + 1).is_none_or(|n| n.page != l.page)
            && title_mid.iter().any(|m| (l.mid - m).abs() < 12.0)
    };
    let mut list_open = false; // the previous line ended in a page list that continues ("11, 12,")
    for (i, l) in ls
        .iter()
        .enumerate()
        .filter(|(_, l)| pages.contains(&l.page))
    {
        let t = clean(&l.text);
        let p = l.page;
        let continues = list_open;
        list_open = false;
        if is_page_ref(&t) {
            if !continues && !folio(i) {
                out.push(format!(
                    "p.{p}: page reference \"{t}\" alone on a line (wrapped off its entry, no leaders)"
                ));
            }
            list_open = t.ends_with(',');
            continue;
        }
        let Some((dots, e)) = last_dots(&t) else {
            continue;
        };
        let rest = t[e..].trim();
        if is_page_ref(rest) {
            list_open = rest.ends_with(',');
        } else if rest.is_empty() && dots >= MIN_LEADER_DOTS {
            out.push(format!(
                "p.{p}: dot leaders with no page reference after them: \"{}\"",
                short(&t)
            ));
        }
    }
    (pages, out)
}

/// An 8-bit grayscale raster (binary PGM, as `pdftoppm -gray` writes it).
pub struct Gray {
    pub w: usize,
    pub h: usize,
    pub px: Vec<u8>,
}

impl Gray {
    pub fn parse(b: &[u8]) -> Option<Gray> {
        let mut fields = Vec::new();
        let mut i = 0;
        while fields.len() < 4 {
            while i < b.len() && b[i].is_ascii_whitespace() {
                i += 1;
            }
            let s = i;
            while i < b.len() && !b[i].is_ascii_whitespace() {
                i += 1;
            }
            fields.push(std::str::from_utf8(b.get(s..i)?).ok()?.to_string());
        }
        let (w, h): (usize, usize) = (fields[1].parse().ok()?, fields[2].parse().ok()?);
        let px = b.get(i + 1..i + 1 + w * h)?.to_vec();
        (fields[0] == "P5").then_some(Gray { w, h, px })
    }
    fn dark(&self, x: usize, y: usize) -> bool {
        x < self.w && y < self.h && self.px[y * self.w + x] < 128
    }
    /// Whether the ink at (x, y) is the end of a stroke that runs unbroken up to row `top - 1`, above a rule
    /// that starts at `top`: a descender of the heading crossing an underline that evades it ("g", "(s)"),
    /// followed row by row as it slants. A run wider than 3 pt is the rule itself: ink that touches the rule
    /// from below is not a stroke from above.
    fn stroke_from_above(&self, x: usize, y: usize, top: usize) -> bool {
        let (mut lo, mut hi) = (x, x);
        for yy in (top.saturating_sub(1)..y).rev() {
            let Some(l) = (lo.saturating_sub(1)..=hi + 1).find(|&xx| self.dark(xx, yy)) else {
                return false;
            };
            let h = (l..=hi + 1)
                .rev()
                .find(|&xx| self.dark(xx, yy))
                .unwrap_or(l);
            (lo, hi) = (l, h);
            while lo > 0 && self.dark(lo - 1, yy) {
                lo -= 1;
            }
            while self.dark(hi + 1, yy) {
                hi += 1;
            }
            if hi - lo > (3.0 * PX) as usize {
                return false;
            }
        }
        top > 0
    }
}

/// Clearance, in points, between the rule under heading run `r` and the first ink below it, when that ink is
/// closer than `MIN_CLEAR_PT`; None when there is no rule or the space below it is clear.
pub fn rule_clearance(img: &Gray, r: &Run) -> Option<f64> {
    let px = |v: f64| (v * PX).round().max(0.0) as usize;
    let (xa, xb) = (px(r.left), px(r.left + r.width));
    // A rule row holds a dark run of a quarter of the heading's width or more (an underline may skip descenders,
    // as typst's does around the "g" of "Page(s)"); a row of letters holds only glyph-wide runs.
    let rule = |y: usize| {
        let (mut best, mut cur) = (0, 0);
        for x in xa..xb {
            cur = if img.dark(x, y) { cur + 1 } else { 0 };
            best = best.max(cur);
        }
        xb > xa && best * 4 >= xb - xa
    };
    let first = (px(r.top + 0.5 * r.height)..px(r.top + r.height + 6.0)).find(|&y| rule(y))?;
    let last = (first..).take_while(|&y| rule(y)).last()?;
    let reach = px(MIN_CLEAR_PT);
    let from = (last + 1).max(px(r.top + r.height));
    (from..=last + reach)
        .find(|&y| (xa..xb).any(|x| img.dark(x, y) && !img.stroke_from_above(x, y, first)))
        .map(|y| (y - last - 1) as f64 / PX)
}

fn is_column_heading(t: &str) -> bool {
    matches!(
        t.trim().to_ascii_lowercase().as_str(),
        "page" | "pages" | "page(s)"
    )
}

fn raster(pdf: &str, page: u32, dir: &Path) -> Res<Gray> {
    let base = dir.join(format!("p{page}"));
    let p = page.to_string();
    let dpi = (PX * 72.0).to_string();
    let o = Command::new("pdftoppm")
        .args(["-r", &dpi, "-gray", "-f", &p, "-l", &p, "-singlefile", pdf])
        .arg(&base)
        .stdin(Stdio::null())
        .output()
        .map_err(|e| fail(2, format!("fb: cannot run pdftoppm: {e}")))?;
    let path = base.with_extension("pgm");
    let bytes = std::fs::read(&path).map_err(|e| io_fail(&path.display().to_string(), e))?;
    if !o.status.success() {
        return Err(fail(2, format!("fb: pdftoppm failed on {pdf} page {page}")));
    }
    Gray::parse(&bytes)
        .ok_or_else(|| fail(2, format!("fb: unreadable raster of {pdf} page {page}")))
}

/// Every finding for `pdf`, given its runs and the top of the footer zone.
pub fn analyze(pdf: &str, runs: &[Run], ftop: f64) -> Res<(BTreeSet<u32>, Vec<String>)> {
    let (pages, mut out) = text_findings(runs, ftop);
    let heads: Vec<&Run> = runs
        .iter()
        .filter(|r| pages.contains(&r.page) && is_column_heading(&r.text))
        .collect();
    if heads.is_empty() {
        return Ok((pages, out));
    }
    let tmp = crate::proc::TempDir::new("toc-layout")?;
    let mut img: Option<(u32, Gray)> = None;
    for h in heads {
        if img.as_ref().map(|(p, _)| *p) != Some(h.page) {
            img = Some((h.page, raster(pdf, h.page, tmp.path())?));
        }
        if let Some(gap) = rule_clearance(&img.as_ref().unwrap().1, h) {
            out.push(format!(
                "p.{}: entry ink {gap:.2} pt below the rule under \"{}\" (needs {MIN_CLEAR_PT} pt clear)",
                h.page,
                h.text.trim()
            ));
        }
    }
    Ok((pages, out))
}

#[path = "toclayout_cli.rs"]
mod cli;
pub use cli::main;

#[cfg(test)]
#[path = "toclayout_tests.rs"]
mod tests;
