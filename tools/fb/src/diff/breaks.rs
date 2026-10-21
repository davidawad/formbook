//! `fb diff --breaks`: the line-break half of G3, counted over the words both streams share, so it runs
//! even when G0 to G2 fail on template residuals (caption, certificates, page numbers). This is the
//! calibration measure for the word-compat layer (docs/EVAL-LOOP.md): an exemplar line is *identical*
//! when every word of it is paired by align.rs, in one run, and ours breaks before its first word,
//! after its last, and nowhere in between. Page and line breaks count alike here (pagination is G0/G3).
use super::align;
use super::content::{tokens, Brk, Tok};
use crate::measure::{Line, Measured};

/// An identical line's position in ours against the exemplar's (ours minus exemplar, pt).
#[derive(Debug, Clone, PartialEq)]
pub struct Pos {
    pub page: usize,
    pub line: usize,
    /// Left edge, right edge and baseline differences.
    pub dl: f64,
    pub dr: f64,
    pub dy: f64,
    /// Both lines hold exactly the paired words (no other word on the visual line).
    pub whole: bool,
    pub text: String,
}

#[derive(Debug, Default, Clone, PartialEq)]
pub struct Breaks {
    /// Exemplar lines.
    pub lines: usize,
    /// Exemplar lines whose every word is matched in one run (the lines that can be compared).
    pub compared: usize,
    /// Compared lines that ours breaks identically.
    pub identical: usize,
    /// Compared lines that ours starts at the same word and left edge (within `GEOM` pt): with the
    /// same text width, only paragraph composition decides where such a line ends.
    pub same_start: usize,
    /// Of those, the ones ours ends at the same word; the rest fit more or fit less than Word.
    pub same_start_identical: usize,
    pub same_start_more: usize,
    pub same_start_less: usize,
    /// Per same-start identical line whose words map one to one: the largest left- or right-edge
    /// difference of any word (pt), the G3 position residual once the breaks agree.
    pub dev: Vec<f64>,
    /// First divergent compared lines, in exemplar order.
    pub first: Vec<String>,
    /// Page and line of the first exemplar line that is not identical (compared or not).
    pub first_at: Option<(usize, usize)>,
    /// First exemplar lines whose words are not all matched in one run, in exemplar order.
    pub unmatched: Vec<String>,
    /// Per identical line: where it is and how far ours sits from the exemplar's (fb diff --engines).
    pub pos: Vec<Pos>,
}

/// Break before token `k` (a break inside a word counts as before the next one: Word does not
/// hyphenate, so a split is itself a divergence the line test reports).
fn brk(t: &[Tok], k: usize) -> bool {
    k == 0 || t[k].start != Brk::None || t[k - 1].split != Brk::None
}

/// Left-edge agreement for a same-start line.
const GEOM: f64 = 0.5;

fn line_of<'a>(m: &'a Measured, t: &Tok) -> Option<&'a Line> {
    m.pages
        .get(t.page.checked_sub(1)?)?
        .lines
        .get(t.line.checked_sub(1)?)
}

pub fn count(exm: &Measured, usm: &Measured, max: usize) -> Breaks {
    let (ex, us) = (&tokens(exm)[..], &tokens(usm)[..]);
    // pair[i] = the render token paired with exemplar token i
    let pair = align::align(ex, us);
    let mut b = Breaks::default();
    let mut s = 0;
    while s < ex.len() {
        let mut e = s + 1;
        while e < ex.len() && !brk(ex, e) {
            e += 1;
        }
        // exemplar line = tokens s..e
        b.lines += 1;
        let run = (s..e).all(|k| pair[k].is_some())
            && (s + 1..e).all(|k| pair[k] == pair[k - 1].map(|j| j + 1));
        if run {
            b.compared += 1;
            let (js, je) = (pair[s].unwrap(), pair[e - 1].unwrap() + 1);
            let same = brk(us, js)
                && (je == us.len() || brk(us, je))
                && (js + 1..je).all(|k| !brk(us, k))
                && (ex[e - 1].split == Brk::None) == (us[je - 1].split == Brk::None);
            let geom = match (line_of(exm, &ex[s]), line_of(usm, &us[js])) {
                (Some(a), Some(u)) => (a.left - u.left).abs() <= GEOM,
                _ => false,
            };
            if brk(us, js) && geom {
                b.same_start += 1;
                match (same, (js + 1..je).any(|k| brk(us, k))) {
                    (true, _) => {
                        b.same_start_identical += 1;
                        if let (Some(a), Some(u)) = (line_of(exm, &ex[s]), line_of(usm, &us[js])) {
                            if a.words.len() == e - s && u.words.len() == je - js {
                                let d = a.words.iter().zip(&u.words).fold(0.0f64, |m, (p, q)| {
                                    m.max((p.x0 - q.x0).abs()).max((p.x1 - q.x1).abs())
                                });
                                b.dev.push(d);
                            }
                        }
                    }
                    (false, true) => b.same_start_less += 1,
                    (false, false) => b.same_start_more += 1,
                }
            }
            if same {
                b.identical += 1;
                if let (Some(a), Some(u)) = (line_of(exm, &ex[s]), line_of(usm, &us[js])) {
                    b.pos.push(Pos {
                        page: ex[s].page,
                        line: ex[s].line,
                        dl: u.left - a.left,
                        dr: u.right - a.right,
                        dy: u.baseline - a.baseline,
                        whole: a.words.len() == e - s && u.words.len() == je - js,
                        text: a.text.clone(),
                    });
                }
            } else if b.first.len() < max {
                let last = ex[e - 1].t.as_str();
                let inner = (js + 1..je).find(|&k| brk(us, k));
                let what = match inner {
                    _ if !brk(us, js) => "ours does not break before the line's first word".into(),
                    Some(k) => format!(
                        "ours breaks earlier, after '{}' (ours fits less)",
                        us[k - 1].t
                    ),
                    None => {
                        let k = (je + 1..=us.len()).find(|&k| k == us.len() || brk(us, k));
                        let w = k.map_or("?", |k| us[k - 1].t.as_str());
                        format!("ours breaks later, after '{w}' (ours fits more)")
                    }
                };
                b.first.push(format!(
                    "p{} line {}: exemplar ends the line after '{last}', {what}",
                    ex[s].page, ex[s].line
                ));
            }
            if !same {
                b.first_at.get_or_insert((ex[s].page, ex[s].line));
            }
        } else {
            b.first_at.get_or_insert((ex[s].page, ex[s].line));
            if b.unmatched.len() < max {
                let words: Vec<&str> = ex[s..e].iter().map(|t| t.t.as_str()).collect();
                b.unmatched.push(format!(
                    "p{} line {}: ours does not carry the line '{}' word for word",
                    ex[s].page,
                    ex[s].line,
                    words.join(" ")
                ));
            }
        }
        s = e;
    }
    b
}

pub fn render(b: &Breaks) -> String {
    let mut s = String::new();
    for f in &b.first {
        s.push_str(&format!("  {f}\n"));
    }
    s.push_str(&format!(
        "RESULT: BREAKS {}/{} compared lines identical ({} exemplar lines, {} not comparable)\n",
        b.identical,
        b.compared,
        b.lines,
        b.lines - b.compared
    ));
    s.push_str(&format!(
        "SAME-START: {}/{} lines that start alike end alike (ours fits more on {}, less on {})\n",
        b.same_start_identical, b.same_start, b.same_start_more, b.same_start_less
    ));
    let mut d = b.dev.clone();
    d.sort_by(f64::total_cmp);
    let le = |x: f64| d.iter().filter(|&&v| v <= x + 1e-9).count();
    s.push_str(&format!(
        "POSITIONS: {} identical same-start lines; largest word-edge difference <= 0.05 pt on {}, <= 0.25 on {}, <= 1 on {}, median {:.2} pt\n",
        d.len(),
        le(0.05),
        le(0.25),
        le(1.0),
        d.get(d.len() / 2).copied().unwrap_or(0.0)
    ));
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::diff::tests::doc;

    #[test]
    fn identical_and_divergent_lines() {
        let a = doc(&[&["a b c", "d e f", "g h"], &["long common line here"]]);
        let b = doc(&[&["a b c", "d e f g", "h"], &["long common line here"]]);
        let r = count(&a, &b, 5);
        assert_eq!((r.lines, r.compared, r.identical), (4, 4, 2), "{r:?}");
        assert_eq!(
            (
                r.same_start,
                r.same_start_identical,
                r.same_start_more,
                r.same_start_less
            ),
            (3, 2, 1, 0),
            "{r:?}"
        );
        assert!(
            r.first[0].contains("ours breaks later, after 'g'"),
            "{:?}",
            r.first
        );
        assert!(
            r.first[1].contains("does not break before"),
            "{:?}",
            r.first
        );
        let r = count(&b, &a, 5);
        assert!(
            r.first[0].contains("ours breaks earlier, after 'f'"),
            "{:?}",
            r.first
        );
        assert_eq!(count(&a, &a, 5).identical, 4);
    }

    #[test]
    fn unmatched_words_are_not_compared() {
        let a = doc(&[&["CAPTION ONLY HERE", "one two three", "four five six"]]);
        let b = doc(&[&["other caption text", "one two three", "four five six"]]);
        let r = count(&a, &b, 5);
        assert_eq!((r.lines, r.compared, r.identical), (3, 2, 2), "{r:?}");
        // page breaks count as line breaks
        let c = doc(&[&["one two three"], &["four five six"]]);
        let d = doc(&[&["one two three", "four five six"]]);
        assert_eq!(count(&c, &d, 5).identical, 2);
    }
}
