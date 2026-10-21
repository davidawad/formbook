//! Global word alignment for `fb diff --breaks`. G2's walk (content.rs) reports the first divergences
//! and gives up past a gap its window cannot bridge; counting breaks needs every shared word paired,
//! even when the exemplar carries pages the render does not (a motion bound in front of a brief).
//! Patience alignment: 4-word runs that occur exactly once on each side anchor the pairing (longest
//! increasing sequence), each anchor is grown in both directions, and the words between two anchors
//! are paired by a longest common subsequence.
use super::content::Tok;
use std::collections::HashMap;

const GRAM: usize = 4;
/// Largest gap (exemplar words x render words) paired by the quadratic LCS; larger gaps stay unpaired.
const GAP: usize = 400 * 400;

fn word(t: &Tok) -> &str {
    t.alt.as_deref().unwrap_or(&t.t)
}

fn unique_grams(t: &[Tok]) -> HashMap<Vec<&str>, Option<usize>> {
    let mut m: HashMap<Vec<&str>, Option<usize>> = HashMap::new();
    for k in 0..t.len().saturating_sub(GRAM - 1) {
        let g: Vec<&str> = t[k..k + GRAM].iter().map(word).collect();
        m.entry(g).and_modify(|e| *e = None).or_insert(Some(k));
    }
    m
}

/// Longest strictly increasing subsequence of `js` (by value), as indices into `js`.
fn lis(js: &[usize]) -> Vec<usize> {
    let mut tails: Vec<usize> = Vec::new();
    let mut prev = vec![usize::MAX; js.len()];
    for (k, &j) in js.iter().enumerate() {
        let p = tails.partition_point(|&t| js[t] < j);
        if p > 0 {
            prev[k] = tails[p - 1];
        }
        if p == tails.len() {
            tails.push(k);
        } else {
            tails[p] = k;
        }
    }
    let mut out = Vec::new();
    let mut k = tails.last().copied().unwrap_or(usize::MAX);
    while k != usize::MAX {
        out.push(k);
        k = prev[k];
    }
    out.reverse();
    out
}

/// LCS pairs of ex[i0..i1] and us[j0..j1].
fn lcs(
    ex: &[Tok],
    us: &[Tok],
    (i0, i1): (usize, usize),
    (j0, j1): (usize, usize),
    out: &mut [Option<usize>],
) {
    let (n, m) = (i1 - i0, j1 - j0);
    if n == 0 || m == 0 || n * m > GAP {
        return;
    }
    let mut t = vec![0u16; (n + 1) * (m + 1)];
    for a in (0..n).rev() {
        for b in (0..m).rev() {
            t[a * (m + 1) + b] = if ex[i0 + a].same(&us[j0 + b]) {
                t[(a + 1) * (m + 1) + b + 1] + 1
            } else {
                t[(a + 1) * (m + 1) + b].max(t[a * (m + 1) + b + 1])
            };
        }
    }
    let (mut a, mut b) = (0, 0);
    while a < n && b < m {
        if ex[i0 + a].same(&us[j0 + b]) {
            out[i0 + a] = Some(j0 + b);
            (a, b) = (a + 1, b + 1);
        } else if t[(a + 1) * (m + 1) + b] >= t[a * (m + 1) + b + 1] {
            a += 1;
        } else {
            b += 1;
        }
    }
}

/// For every exemplar token, the render token it pairs with (strictly increasing where present).
pub fn align(ex: &[Tok], us: &[Tok]) -> Vec<Option<usize>> {
    let (ge, gu) = (unique_grams(ex), unique_grams(us));
    let mut anchors: Vec<(usize, usize)> = ge
        .iter()
        .filter_map(|(g, i)| Some(((*i)?, (*gu.get(g)?)?)))
        .collect();
    anchors.sort_unstable();
    let js: Vec<usize> = anchors.iter().map(|a| a.1).collect();
    let chain: Vec<(usize, usize)> = lis(&js).into_iter().map(|k| anchors[k]).collect();
    let mut pair: Vec<Option<usize>> = vec![None; ex.len()];
    // grow every anchor into a maximal run of equal words, never past its neighbours
    let mut runs: Vec<(usize, usize, usize)> = Vec::new(); // (i, j, len)
    let (mut lo_i, mut lo_j) = (0, 0);
    for (k, &(i, j)) in chain.iter().enumerate() {
        if i < lo_i || j < lo_j {
            continue;
        }
        let (hi_i, hi_j) = chain
            .get(k + 1)
            .map_or((ex.len(), us.len()), |&(a, b)| (a, b));
        let (mut s, mut t) = (i, j);
        while s > lo_i && t > lo_j && ex[s - 1].same(&us[t - 1]) {
            (s, t) = (s - 1, t - 1);
        }
        let mut len = i - s;
        while s + len < hi_i && t + len < hi_j && ex[s + len].same(&us[t + len]) {
            len += 1;
        }
        runs.push((s, t, len));
        (lo_i, lo_j) = (s + len, t + len);
    }
    let (mut ci, mut cj) = (0, 0);
    for &(s, t, len) in &runs {
        lcs(ex, us, (ci, s), (cj, t), &mut pair);
        for d in 0..len {
            pair[s + d] = Some(t + d);
        }
        (ci, cj) = (s + len, t + len);
    }
    lcs(ex, us, (ci, ex.len()), (cj, us.len()), &mut pair);
    pair
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::diff::{content::tokens, tests::doc};

    #[test]
    fn pairs_past_a_leading_extra_document() {
        let a = tokens(&doc(&[
            &["MOTION FOR LEAVE the the the of of of and and and"],
            &[
                "the brief starts here and it goes on",
                "to the end of the brief",
            ],
        ]));
        let b = tokens(&doc(&[&[
            "COVER the brief starts here and it goes",
            "on to the end of the brief",
        ]]));
        let p = align(&a, &b);
        // 'the brief starts' (exemplar tokens 12..) pairs with render tokens 1..
        assert_eq!(p[12], Some(1));
        assert_eq!(p.last().copied().flatten(), Some(b.len() - 1));
        assert!(p[..12].iter().filter(|x| x.is_some()).count() <= 1, "{p:?}");
    }
}
