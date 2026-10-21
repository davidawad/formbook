//! `fb diff --breaks`: the line-break half of G3, counted over the words both streams share, so it runs
//! even when G0 to G2 fail on template residuals (caption, certificates, page numbers). This is the
//! calibration measure for the word-compat layer (docs/EVAL-LOOP.md): an exemplar line is *identical*
//! when every word of it is paired by align.rs, in one run, and ours breaks before its first word,
//! after its last, and nowhere in between. Page and line breaks count alike here (pagination is G0/G3).
use super::align;
use super::content::{Brk, Tok};

#[derive(Debug, Default, Clone, PartialEq)]
pub struct Breaks {
    /// Exemplar lines.
    pub lines: usize,
    /// Exemplar lines whose every word is matched in one run (the lines that can be compared).
    pub compared: usize,
    /// Compared lines that ours breaks identically.
    pub identical: usize,
    /// First divergent compared lines, in exemplar order.
    pub first: Vec<String>,
}

/// Break before token `k` (a break inside a word counts as before the next one: Word does not
/// hyphenate, so a split is itself a divergence the line test reports).
fn brk(t: &[Tok], k: usize) -> bool {
    k == 0 || t[k].start != Brk::None || t[k - 1].split != Brk::None
}

pub fn count(ex: &[Tok], us: &[Tok], max: usize) -> Breaks {
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
            if same {
                b.identical += 1;
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
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::diff::{content::tokens, tests::doc};

    #[test]
    fn identical_and_divergent_lines() {
        let a = tokens(&doc(&[&["a b c", "d e f", "g h"]]));
        let b = tokens(&doc(&[&["a b c", "d e f g", "h"]]));
        let r = count(&a, &b, 5);
        assert_eq!((r.lines, r.compared, r.identical), (3, 3, 1), "{r:?}");
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
        assert_eq!(count(&a, &a, 5).identical, 3);
    }

    #[test]
    fn unmatched_words_are_not_compared() {
        let a = tokens(&doc(&[&[
            "CAPTION ONLY HERE",
            "one two three",
            "four five six",
        ]]));
        let b = tokens(&doc(&[&[
            "other caption text",
            "one two three",
            "four five six",
        ]]));
        let r = count(&a, &b, 5);
        assert_eq!((r.lines, r.compared, r.identical), (3, 2, 2), "{r:?}");
        // page breaks count as line breaks
        let c = tokens(&doc(&[&["one two three"], &["four five six"]]));
        let d = tokens(&doc(&[&["one two three", "four five six"]]));
        assert_eq!(count(&c, &d, 5).identical, 2);
    }
}
