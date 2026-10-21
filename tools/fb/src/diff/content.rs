//! G2 (same words in the same order) and the line-break half of G3 (every line and page breaks after the
//! same word). Words come from the measured lines in reading order; a word hyphenated across a line end
//! is one token that also matches its unhyphenated form, so a break inside a word is still a break.
use crate::measure::Measured;

/// What separates a token from the one before it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Brk {
    None,
    Line,
    Page,
}

#[derive(Debug, Clone)]
pub struct Tok {
    pub t: String,
    /// The token without its line-end hyphen, when it was joined across a break.
    pub alt: Option<String>,
    pub page: usize,
    /// 1-based line on the page, counting unmasked lines.
    pub line: usize,
    /// Break before the token.
    pub start: Brk,
    /// Break inside the token (after its hyphen).
    pub split: Brk,
    /// Byte length of the part before a break inside the token.
    pub cut: Option<usize>,
}

impl Tok {
    pub fn same(&self, o: &Tok) -> bool {
        let a = [Some(&self.t), self.alt.as_ref()];
        let b = [Some(&o.t), o.alt.as_ref()];
        a.iter()
            .flatten()
            .any(|x| b.iter().flatten().any(|y| x == y))
    }
    /// The token up to a break inside it (its first part, ending in the hyphen), else the whole token.
    fn shown(&self) -> String {
        self.t[..self.cut.unwrap_or(self.t.len())].to_string()
    }
}

/// Text normal form of one word: ligatures expanded, soft hyphens and invisible spaces dropped, hyphen
/// variants made ASCII.
pub fn norm(w: &str) -> String {
    let w = crate::unicode::nfc(w);
    let mut s = String::with_capacity(w.len());
    for c in w.chars() {
        match c {
            '\u{FB00}' => s.push_str("ff"),
            '\u{FB01}' => s.push_str("fi"),
            '\u{FB02}' => s.push_str("fl"),
            '\u{FB03}' => s.push_str("ffi"),
            '\u{FB04}' => s.push_str("ffl"),
            '\u{00AD}' | '\u{200B}' | '\u{FEFF}' => {}
            '\u{2010}' | '\u{2011}' => s.push('-'),
            _ => s.push(c),
        }
    }
    s
}

pub fn tokens(m: &Measured) -> Vec<Tok> {
    let mut out: Vec<Tok> = Vec::new();
    let mut pending: Brk = Brk::None;
    for p in &m.pages {
        for (li, l) in p.lines.iter().enumerate() {
            for (wi, w) in l.words.iter().enumerate() {
                let t = norm(&w.t);
                if t.is_empty() {
                    continue;
                }
                let brk = if wi == 0 { pending } else { Brk::None };
                let joinable = brk != Brk::None
                    && t.starts_with(|c: char| c.is_lowercase())
                    && out
                        .last()
                        .is_some_and(|p| p.t.len() > 1 && p.t.ends_with('-') && p.alt.is_none());
                match out.last_mut().filter(|_| joinable) {
                    Some(prev) => {
                        prev.alt = Some(format!("{}{t}", prev.t.trim_end_matches('-')));
                        prev.t.push_str(&t);
                        prev.split = brk;
                        prev.cut = Some(prev.t.len() - t.len());
                    }
                    None => out.push(Tok {
                        t,
                        alt: None,
                        page: p.n,
                        line: li + 1,
                        start: brk,
                        split: Brk::None,
                        cut: None,
                    }),
                }
            }
            pending = Brk::Line;
        }
        pending = Brk::Page;
    }
    if let Some(first) = out.first_mut() {
        first.start = Brk::None;
    }
    out
}

fn snippet(t: &[Tok]) -> String {
    let s: Vec<&str> = t.iter().take(8).map(|t| t.t.as_str()).collect();
    format!("'{}{}'", s.join(" "), if t.len() > 8 { " ..." } else { "" })
}

fn at(t: Option<&Tok>) -> String {
    t.map_or("at the end".to_string(), |t| {
        format!("p{} line {}", t.page, t.line)
    })
}

/// G2: the first divergences of the word streams (at most `max`), each resynchronised before the next.
pub fn g2(ex: &[Tok], us: &[Tok], max: usize) -> Vec<String> {
    const WIN: usize = 60;
    const RUN: usize = 3;
    let agree = |i: usize, j: usize| {
        (0..RUN).all(|k| match (ex.get(i + k), us.get(j + k)) {
            (Some(a), Some(b)) => a.same(b),
            (None, None) => true,
            _ => false,
        })
    };
    let mut out = Vec::new();
    let (mut i, mut j) = (0, 0);
    while out.len() < max && (i < ex.len() || j < us.len()) {
        if i < ex.len() && j < us.len() && ex[i].same(&us[j]) {
            i += 1;
            j += 1;
            continue;
        }
        let resync = (0..=2 * WIN)
            .flat_map(|s| (0..=s).map(move |a| (a, s - a)))
            .find(|&(a, b)| (a > 0 || b > 0) && agree(i + a, j + b));
        let here = format!("{} (ours {})", at(ex.get(i)), at(us.get(j)));
        match resync {
            Some((a, 0)) => out.push(format!(
                "{here}: ours is missing {}",
                snippet(&ex[i..i + a])
            )),
            Some((0, b)) => out.push(format!("{here}: ours has extra {}", snippet(&us[j..j + b]))),
            Some((a, b)) => out.push(format!(
                "{here}: exemplar has {}, ours has {}",
                snippet(&ex[i..i + a]),
                snippet(&us[j..j + b])
            )),
            None => {
                out.push(format!(
                    "{here}: exemplar continues {}, ours {} (no resync within {WIN} words)",
                    snippet(&ex[i.min(ex.len())..]),
                    snippet(&us[j.min(us.len())..])
                ));
                break;
            }
        }
        let (a, b) = resync.unwrap_or((0, 0));
        i += a;
        j += b;
    }
    out
}

/// Every break of a stream as (position, kind): position `2k` is before token `k`, `2k + 1` inside it.
fn events(t: &[Tok]) -> Vec<(usize, Brk)> {
    let mut out = Vec::new();
    for (k, tok) in t.iter().enumerate() {
        if tok.start != Brk::None {
            out.push((2 * k, tok.start));
        }
        if tok.split != Brk::None {
            out.push((2 * k + 1, tok.split));
        }
    }
    out
}

/// The words a break at `pos` follows, and the token that holds them.
fn after(t: &[Tok], pos: usize) -> (String, Option<&Tok>) {
    let k = pos / 2;
    match pos % 2 {
        1 => (t[k].shown(), t.get(k)),
        _ => {
            let tok = k.checked_sub(1).and_then(|k| t.get(k));
            (tok.map_or(String::new(), |t| t.t.clone()), tok)
        }
    }
}

fn name(b: Brk) -> &'static str {
    if b == Brk::Page {
        "page"
    } else {
        "line"
    }
}

/// G3 line breaks: the first divergences (at most `max`), each followed to the next shared break.
/// Assumes G2 passed (same words, so token positions correspond).
pub fn breaks(ex: &[Tok], us: &[Tok], max: usize) -> Vec<String> {
    let (ea, ua) = (events(ex), events(us));
    let mut out = Vec::new();
    let (mut i, mut j) = (0, 0);
    while i < ea.len() && j < ua.len() && out.len() < max {
        let ((pe, ke), (pu, ku)) = (ea[i], ua[j]);
        if (pe, ke) == (pu, ku) {
            i += 1;
            j += 1;
            continue;
        }
        let (we, te) = after(ex, pe);
        let (wu, _) = after(us, pu);
        let at = te.map_or("p? line ?".to_string(), |t| {
            format!("p{} line {}", t.page, t.line)
        });
        out.push(if pe == pu {
            let (more, less) = if ku == Brk::Page { ("exemplar", "ours") } else { ("ours", "exemplar") };
            format!(
                "{at}: exemplar has a {} break after '{we}', ours a {} break ({more} puts more lines on the page than {less}) -> param margin_bottom / leading",
                name(ke),
                name(ku)
            )
        } else {
            let fit = if pu > pe { "more" } else { "less" };
            let kind = if ke == Brk::Page || ku == Brk::Page { "page" } else { "line" };
            format!(
                "{at}: {kind} break: exemplar breaks after '{we}', ours after '{wu}' (ours fits {fit} on the line) -> param font_size / text width / word spacing"
            )
        });
        // Resume at the next break both share.
        loop {
            match (ea.get(i), ua.get(j)) {
                (Some(a), Some(b)) if a == b => break,
                (Some(a), Some(b)) if a.0 == b.0 => (i, j) = (i + 1, j + 1),
                (Some(a), Some(b)) if a.0 < b.0 => i += 1,
                (Some(_), Some(_)) => j += 1,
                _ => break,
            }
        }
    }
    if out.is_empty() && (i < ea.len()) != (j < ua.len()) {
        out.push(
            "the break sequences end differently (one side has breaks after the other's last)"
                .into(),
        );
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::diff::tests::doc;

    #[test]
    fn hyphen_join_matches_unbroken() {
        let a = tokens(&doc(&[&["the adminis-", "trative record is"]]));
        let b = tokens(&doc(&[&["the administrative", "record is"]]));
        assert!(g2(&a, &b, 5).is_empty());
        let br = breaks(&a, &b, 5);
        assert_eq!(br.len(), 1, "{br:?}");
        assert!(
            br[0].contains("exemplar breaks after 'adminis-', ours after 'administrative'"),
            "{}",
            br[0]
        );
    }

    #[test]
    fn missing_extra_swapped() {
        let a = tokens(&doc(&[&[
            "one two three four five six seven eight nine ten",
        ]]));
        let b = tokens(&doc(&[&["one two six seven eight nine ten"]]));
        let d = g2(&a, &b, 5);
        assert_eq!(
            d,
            vec!["p1 line 1 (ours p1 line 1): ours is missing 'three four five'"]
        );
        let d = g2(&b, &a, 5);
        assert_eq!(
            d,
            vec!["p1 line 1 (ours p1 line 1): ours has extra 'three four five'"]
        );
        let c = tokens(&doc(&[
            &["alpha beta gamma", "delta epsilon zeta"],
            &["eta theta iota kappa"],
        ]));
        let s = tokens(&doc(&[
            &["delta epsilon zeta", "alpha beta gamma"],
            &["eta theta iota kappa"],
        ]));
        assert!(!g2(&c, &s, 5).is_empty());
    }

    #[test]
    fn page_break_and_line_break_divergence() {
        let a = tokens(&doc(&[&["a b c", "d e f"], &["g h"]]));
        let b = tokens(&doc(&[&["a b c d", "e f"], &["g h"]]));
        let br = breaks(&a, &b, 5);
        assert_eq!(br.len(), 1, "{br:?}");
        assert!(
            br[0].starts_with("p1 line 1: line break: exemplar breaks after 'c', ours after 'd'"),
            "{}",
            br[0]
        );
        let c = tokens(&doc(&[&["a b c", "d e f", "g h"]]));
        let br = breaks(&a, &c, 5);
        assert!(br[0].contains("page break"), "{br:?}");
        assert!(breaks(&a, &a, 5).is_empty());
    }
}
