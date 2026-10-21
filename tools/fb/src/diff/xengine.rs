//! Cross-engine comparison (fb-595.54): the typst render of an INPUT is the reference, and the latex and
//! docx renders of the same INPUT must lay it out the same way: the same page count, every page starting
//! and ending on the same word, and every typst line breaking after the same word in the other engine.
//! A break that differs is a failure, never a tolerance; the only tolerance is the glyph-advance drift of
//! a line whose breaks agree (docs/EVAL-LOOP.md, "Cross-engine gate"). Line breaks are counted by
//! breaks.rs with the typst render in the exemplar's seat.
use super::breaks;
use super::content::{tokens, Tok};
use crate::measure::Measured;

/// How many differing pages or lines are listed.
pub const LIST: usize = 8;
/// Baseline difference reported as the first vertical divergence (diagnostic only).
pub const VSLACK: f64 = 0.5;

#[derive(Debug, Clone, Default, PartialEq)]
pub struct Cross {
    /// Page counts: reference (typst), other engine.
    pub pages: (usize, usize),
    /// Pages whose first or last word differs (pages both renders have).
    pub ends: Vec<String>,
    /// Number of differing pages (`ends` lists the first LIST).
    pub ends_bad: usize,
    /// Reference lines, and the ones the other engine breaks identically.
    pub lines: usize,
    pub same: usize,
    /// Page and line of the first reference line that is not identical.
    pub first_at: Option<(usize, usize)>,
    /// The first differing lines, in reference order.
    pub first: Vec<String>,
    /// Largest left- or right-edge drift of a line that breaks identically (pt).
    pub drift: f64,
    /// Diagnostic, not gated: the largest baseline difference of an identical line (pt) and the first
    /// identical line whose baseline differs by more than VSLACK.
    pub vdrift: f64,
    pub vfirst: Option<String>,
}

impl Cross {
    pub fn pages_equal(&self) -> bool {
        self.pages.0 == self.pages.1
    }
    pub fn breaks_equal(&self) -> bool {
        self.same == self.lines
    }
    /// Share of reference lines broken identically, in percent (100 for an empty reference).
    pub fn pct(&self) -> f64 {
        match self.lines {
            0 => 100.0,
            n => 100.0 * self.same as f64 / n as f64,
        }
    }
    pub fn first_text(&self) -> String {
        self.first_at
            .map_or("-".into(), |(p, l)| format!("p{p} line {l}"))
    }
}

/// First and last token of every page, by page number.
fn ends(t: &[Tok]) -> Vec<(usize, &str, &str)> {
    let mut v: Vec<(usize, &str, &str)> = Vec::new();
    for k in t {
        match v.last_mut() {
            Some(e) if e.0 == k.page => e.2 = &k.t,
            _ => v.push((k.page, &k.t, &k.t)),
        }
    }
    v
}

fn word_of(e: &[(usize, &str, &str)], page: usize) -> (String, String) {
    e.iter()
        .find(|x| x.0 == page)
        .map_or(("(no text)".into(), "(no text)".into()), |x| {
            (x.1.to_string(), x.2.to_string())
        })
}

/// The word without dot leaders: runs of three or more dots go (Word's tab leader is one word of dots,
/// typst's and latex's are dots set apart), and a word of dots alone is dropped.
fn unleader(w: &str) -> String {
    let mut out = String::new();
    let mut dots = 0;
    for c in w.chars().chain(std::iter::once(' ')) {
        if c == '.' {
            dots += 1;
            continue;
        }
        if dots > 0 && dots < 3 {
            out.push_str(&".".repeat(dots));
        }
        dots = 0;
        if c != ' ' {
            out.push(c);
        }
    }
    match out.chars().all(|c| c == '.') {
        true => String::new(),
        false => out,
    }
}

/// `m` with leader dots taken out of its words (unleader), empty words and lines dropped.
fn without_leaders(m: &Measured) -> Measured {
    let mut m = m.clone();
    for p in &mut m.pages {
        for l in &mut p.lines {
            for w in &mut l.words {
                w.t = unleader(&w.t);
            }
            l.words.retain(|w| !w.t.is_empty());
        }
        p.lines.retain(|l| !l.words.is_empty());
    }
    m
}

pub fn compare(reference: &Measured, other: &Measured) -> Cross {
    let (reference, other) = (&without_leaders(reference), &without_leaders(other));
    let (tr, to) = (tokens(reference), tokens(other));
    let (er, eo) = (ends(&tr), ends(&to));
    let mut c = Cross {
        pages: (reference.pages.len(), other.pages.len()),
        ..Cross::default()
    };
    for p in 1..=c.pages.0.min(c.pages.1) {
        let (a, b) = (word_of(&er, p), word_of(&eo, p));
        if a != b {
            c.ends_bad += 1;
            if c.ends.len() < LIST {
                c.ends.push(format!(
                    "p{p}: typst runs '{}' .. '{}', this engine '{}' .. '{}'",
                    a.0, a.1, b.0, b.1
                ));
            }
        }
    }
    let b = breaks::count(reference, other, LIST);
    c.lines = b.lines;
    c.same = b.identical;
    c.first_at = b.first_at;
    let mut first: Vec<(usize, usize, String)> = b
        .first
        .iter()
        .chain(&b.unmatched)
        .map(|f| (at(f), f.clone()))
        .map(|((p, l), f)| (p, l, f))
        .collect();
    first.sort();
    c.first = first
        .into_iter()
        .take(LIST)
        .map(|(_, _, f)| f.replace("exemplar", "typst"))
        .collect();
    c.drift = b.drift.iter().copied().fold(0.0, f64::max);
    c.vdrift = b.vdrift.iter().map(|v| v.2.abs()).fold(0.0, f64::max);
    c.vfirst = b
        .vdrift
        .iter()
        .find(|v| v.2.abs() > VSLACK)
        .map(|(p, l, d)| format!("p{p} line {l}: baseline {d:+.2} pt"));
    c
}

/// (page, line) of a breaks.rs finding "p<page> line <line>: ...".
fn at(f: &str) -> (usize, usize) {
    let mut it = f
        .split(|c: char| !c.is_ascii_digit())
        .filter(|s| !s.is_empty())
        .map(|s| s.parse().unwrap_or(0));
    (it.next().unwrap_or(0), it.next().unwrap_or(0))
}

/// The printed comparison of `fb diff --engines`.
pub fn render(c: &Cross) -> String {
    let mut s = format!(
        "pages: typst {}, this engine {} ({})\n",
        c.pages.0,
        c.pages.1,
        if c.pages_equal() { "equal" } else { "DIFFER" }
    );
    s.push_str(&format!(
        "page ends: {} of {} shared pages differ\n",
        c.ends_bad,
        c.pages.0.min(c.pages.1)
    ));
    for f in &c.ends {
        s.push_str(&format!("  {f}\n"));
    }
    s.push_str(&format!(
        "line breaks: {}/{} typst lines identical ({:.1}%), first differing {}\n",
        c.same,
        c.lines,
        c.pct(),
        c.first_text()
    ));
    for f in &c.first {
        s.push_str(&format!("  {f}\n"));
    }
    s.push_str(&format!(
        "drift: largest edge difference of an identical line {:.2} pt\n",
        c.drift
    ));
    s.push_str(&format!(
        "baselines (diagnostic): largest difference of an identical line {:.2} pt; first over {VSLACK} pt: {}\n",
        c.vdrift,
        c.vfirst.as_deref().unwrap_or("none")
    ));
    let ok = c.pages_equal() && c.ends_bad == 0 && c.breaks_equal();
    s.push_str(&format!(
        "RESULT: CROSS-ENGINE {}\n",
        if ok { "PASS" } else { "FAIL" }
    ));
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::diff::tests::doc;

    #[test]
    fn identical_renders_pass() {
        let a = doc(&[&["a b c", "d e f"], &["g h"]]);
        let c = compare(&a, &a);
        assert!(
            c.pages_equal() && c.breaks_equal() && c.ends_bad == 0,
            "{c:?}"
        );
        assert_eq!((c.lines, c.same, c.first_at), (3, 3, None));
        assert!(render(&c).ends_with("RESULT: CROSS-ENGINE PASS\n"));
    }

    #[test]
    fn a_moved_break_is_found_at_its_line() {
        let a = doc(&[&["a b c", "d e f"], &["g h"]]);
        let b = doc(&[&["a b c", "d e"], &["f g h"]]);
        let c = compare(&a, &b);
        assert!(c.pages_equal());
        assert_eq!(c.ends_bad, 2, "{c:?}");
        assert_eq!(c.first_at, Some((1, 2)));
        assert_eq!(c.same, 1);
        assert!(c.first[0].starts_with("p1 line 2: typst ends the line after 'f'"));
        assert!(render(&c).ends_with("RESULT: CROSS-ENGINE FAIL\n"));
    }

    #[test]
    fn page_count_and_altered_words_fail() {
        let a = doc(&[&["a b c"], &["d e f"]]);
        let b = doc(&[&["a b c", "d x f"]]);
        let c = compare(&a, &b);
        assert!(!c.pages_equal());
        assert_eq!((c.lines, c.same), (2, 1));
        assert!(c.first[0].contains("word for word"), "{:?}", c.first);
        assert_eq!(at("p12 line 3: x 4"), (12, 3));
    }

    #[test]
    fn leaders_are_not_words() {
        assert_eq!(unleader("........15"), "15");
        assert_eq!(unleader("Background......"), "Background");
        assert_eq!(unleader("."), "");
        assert_eq!(unleader("U.S."), "U.S.");
        assert_eq!(unleader("Inc.."), "Inc..");
        let a = doc(&[&["INTRODUCTION . . . . . 1", "Body text here"]]);
        let b = doc(&[&["INTRODUCTION ..........1", "Body text here"]]);
        let c = compare(&a, &b);
        assert!(c.breaks_equal() && c.ends_bad == 0, "{c:?}");
    }
}
