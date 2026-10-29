//! From poppler's raw output to measured pages: visual lines with baselines and styles, masks, frame,
//! drawings.
use super::poppler::{RawPage, Run, Seg};
use super::{mask, r2, stats, Frame, Line, MaskRegion, Page, Rect, Word};

pub fn pages(raw: Vec<RawPage>, regions: &[MaskRegion]) -> Vec<Page> {
    pages_pleading(raw, regions, 0)
}

/// `pages` of a PDF on pleading paper of `pleading` numbered lines a page (0: none): the line numbers are dropped
/// before the segments are merged into lines (unpleading).
pub fn pages_pleading(raw: Vec<RawPage>, regions: &[MaskRegion], pleading: usize) -> Vec<Page> {
    raw.into_iter()
        .map(|mut p| {
            unpleading(&mut p.segs, pleading);
            page(p, regions)
        })
        .collect()
}

/// `segs` without the pleading-paper line numbers 1 ..= `n`: a word that is such a number alone, left of every other
/// word of its page. Typst prints them in the page background and Word (`w:lnNumType`) beside the line, a little
/// higher and in a taller box; merged into the visual lines, a number would join the body line beside it (and through
/// its box the line above), so the engines' lines would differ in page furniture, not in body text.
fn unpleading(segs: &mut Vec<Seg>, n: usize) {
    if n == 0 {
        return;
    }
    let num = |t: &str| t.parse::<usize>().is_ok_and(|v| (1..=n).contains(&v));
    let body = segs
        .iter()
        .flat_map(|s| &s.words)
        .filter(|w| !num(&w.t))
        .map(|w| w.x0)
        .fold(f64::INFINITY, f64::min);
    for s in segs.iter_mut() {
        let before = s.words.len();
        s.words.retain(|w| !(num(&w.t) && w.x1 <= body));
        if s.words.len() != before && !s.words.is_empty() {
            let r = |w: &Word| Rect {
                x0: w.x0,
                y0: w.y0,
                x1: w.x1,
                y1: w.y1,
            };
            s.bbox = s.words[1..]
                .iter()
                .fold(r(&s.words[0]), |b, w| b.union(&r(w)));
        }
    }
    segs.retain(|s| !s.words.is_empty());
}

fn page(raw: RawPage, regions: &[MaskRegion]) -> Page {
    let mut glyphs = raw.svg.glyphs.clone();
    glyphs.sort_by(|a, b| a.1.total_cmp(&b.1));
    let mut lines: Vec<Line> = merge(raw.segs)
        .into_iter()
        .map(|(bbox, words)| line(bbox, words, &glyphs, &raw.runs))
        .collect();
    lines.sort_by(|a, b| {
        a.baseline
            .total_cmp(&b.baseline)
            .then(a.left.total_cmp(&b.left))
    });
    let images: Vec<Rect> = raw.svg.images.iter().map(Rect::rounded).collect();
    let (lines, masked) = mask::apply(lines, raw.n, raw.w, raw.h, &images, regions);
    let frame = frame(&lines);
    let stats = stats::of(&lines, frame.as_ref());
    let round = |v: &[Rect]| v.iter().map(Rect::rounded).collect::<Vec<_>>();
    Page {
        n: raw.n,
        w: r2(raw.w),
        h: r2(raw.h),
        frame,
        stats,
        lines,
        rules: round(&raw.svg.rules),
        boxes: round(&raw.svg.boxes),
        vectors: round(&raw.svg.vectors),
        images,
        masked,
    }
}

pub fn frame(lines: &[Line]) -> Option<Frame> {
    let first = lines.first()?;
    Some(lines.iter().fold(
        Frame {
            left: first.left,
            right: first.right,
            top: first.baseline,
            bottom: first.baseline,
        },
        |f, l| Frame {
            left: f.left.min(l.left),
            right: f.right.max(l.right),
            top: f.top.min(l.baseline),
            bottom: f.bottom.max(l.baseline),
        },
    ))
}

/// Merge pdftotext line segments that share a vertical band (overlap of at least half the smaller
/// height) and do not overlap horizontally: tab-separated columns of one line, superscripts.
fn merge(mut segs: Vec<Seg>) -> Vec<(Rect, Vec<Word>)> {
    segs.retain(|s| !s.words.is_empty());
    segs.sort_by(|a, b| a.bbox.y1.total_cmp(&b.bbox.y1));
    let mut out: Vec<(Rect, Vec<Word>, Vec<Rect>)> = Vec::new();
    for s in segs {
        let hit = out.iter_mut().rev().take(8).find(|(_, _, parts)| {
            parts
                .iter()
                .all(|p| p.x1 <= s.bbox.x0 + 0.5 || s.bbox.x1 <= p.x0 + 0.5)
                && parts.iter().any(|p| {
                    let ov = p.y1.min(s.bbox.y1) - p.y0.max(s.bbox.y0);
                    ov >= 0.5 * p.h().min(s.bbox.h())
                })
        });
        match hit {
            Some((r, w, parts)) => {
                *r = r.union(&s.bbox);
                w.extend(s.words);
                parts.push(s.bbox);
            }
            None => out.push((s.bbox, s.words, vec![s.bbox])),
        }
    }
    out.into_iter()
        .map(|(r, mut w, _)| {
            w.sort_by(|a, b| a.x0.total_cmp(&b.x0));
            (r, w)
        })
        .collect()
}

/// Most common value (at 0.01 resolution) of `vals` weighted by `w`; ties go to the larger value.
pub fn mode(vals: impl Iterator<Item = (f64, f64)>) -> Option<f64> {
    let mut counts: Vec<(i64, f64)> = Vec::new();
    for (v, w) in vals {
        let k = (v * 100.0).round() as i64;
        match counts.iter_mut().find(|(c, _)| *c == k) {
            Some(e) => e.1 += w,
            None => counts.push((k, w)),
        }
    }
    counts
        .into_iter()
        .max_by(|a, b| a.1.total_cmp(&b.1).then(a.0.cmp(&b.0)))
        .map(|(k, _)| k as f64 / 100.0)
}

/// The value carried by the most characters (the first one seen wins a tie).
fn majority<'a>(vals: impl Iterator<Item = (&'a str, usize)>) -> String {
    let mut counts: Vec<(&str, usize)> = Vec::new();
    for (v, n) in vals {
        match counts.iter_mut().find(|(c, _)| *c == v) {
            Some(e) => e.1 += n,
            None => counts.push((v, n)),
        }
    }
    counts
        .iter()
        .rev()
        .max_by_key(|c| c.1)
        .map_or(String::new(), |c| c.0.to_string())
}

fn line(bbox: Rect, words: Vec<Word>, glyphs: &[(f64, f64)], runs: &[Run]) -> Line {
    let lo = glyphs.partition_point(|g| g.1 < bbox.y0);
    let hi = glyphs.partition_point(|g| g.1 <= bbox.y1 + 0.5);
    // the glyphs of the line's own words: a line merged from two columns spans the band of both, and LibreOffice's
    // tall word boxes reach the next line's glyphs in the other column, which may outnumber its own
    let baseline = mode(
        glyphs[lo..hi]
            .iter()
            .filter(|g| g.0 >= bbox.x0 - 1.0 && g.0 <= bbox.x1 + 1.0)
            .filter(|g| {
                words.is_empty()
                    || words.iter().any(|w| {
                        g.0 >= w.x0 - 1.0 && g.0 <= w.x1 + 1.0 && g.1 >= w.y0 && g.1 <= w.y1 + 0.5
                    })
            })
            .map(|g| (g.1, 1.0)),
    );
    let mid = |r: &Rect| (r.y0 + r.y1) / 2.0;
    let mine: Vec<&Run> = runs
        .iter()
        .filter(|r| {
            mid(&r.bbox) >= bbox.y0 - 1.0
                && mid(&r.bbox) <= bbox.y1 + 1.0
                && r.bbox.x1 > bbox.x0
                && r.bbox.x0 < bbox.x1
        })
        .collect();
    let chars: usize = mine.iter().map(|r| r.chars).sum();
    let half = |n: usize| chars > 0 && 2 * n > chars;
    Line {
        text: words
            .iter()
            .map(|w| w.t.as_str())
            .collect::<Vec<_>>()
            .join(" "),
        baseline: r2(baseline.unwrap_or(bbox.y1)),
        baseline_est: baseline.is_none(),
        left: r2(bbox.x0),
        right: r2(bbox.x1),
        top: r2(bbox.y0),
        bottom: r2(bbox.y1),
        size: mode(mine.iter().map(|r| (r.size, r.chars as f64))).unwrap_or(0.0),
        font: majority(mine.iter().map(|r| (r.family.as_str(), r.chars))),
        bold: half(mine.iter().map(|r| r.bold).sum()),
        italic: half(mine.iter().map(|r| r.italic).sum()),
        words: words
            .into_iter()
            .map(|w| Word {
                x0: r2(w.x0),
                y0: r2(w.y0),
                x1: r2(w.x1),
                y1: r2(w.y1),
                t: w.t,
            })
            .collect(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn seg(x0: f64, y0: f64, x1: f64, y1: f64, t: &str) -> Seg {
        Seg {
            bbox: Rect { x0, y0, x1, y1 },
            words: vec![Word {
                t: t.into(),
                x0,
                y0,
                x1,
                y1,
            }],
        }
    }

    #[test]
    fn merges_tab_columns_and_superscripts_not_next_line() {
        let segs = vec![
            seg(108.0, 282.0, 120.5, 297.8, "A."),
            seg(144.0, 282.0, 539.7, 297.8, "Legal"),
            seg(540.0, 280.0, 545.0, 289.0, "1"),
            seg(72.0, 311.8, 539.0, 327.5, "next"),
        ];
        let m = merge(segs);
        assert_eq!(m.len(), 2);
        let t: Vec<&str> = m[0].1.iter().map(|w| w.t.as_str()).collect();
        assert_eq!(t, ["A.", "Legal", "1"]);
    }

    #[test]
    fn pleading_line_numbers_do_not_join_body_lines() {
        // Word's number 13, in its taller box, overlaps both the right column's line above and the left column's
        // line beside it: merged, the two become one line. Without the numbers they stay apart; a body word that
        // is a number (12, at the text's left edge) stays.
        let segs = || {
            vec![
                seg(338.0, 350.5, 470.0, 363.8, "ALTERNATIVE,"),
                seg(59.0, 350.5, 72.0, 372.2, "13"),
                seg(108.0, 362.5, 250.0, 375.8, "UNITED"),
                seg(59.0, 374.5, 72.0, 396.2, "14"),
                seg(108.0, 386.5, 120.0, 399.8, "12"),
            ]
        };
        let mut s = segs();
        unpleading(&mut s, 0);
        assert_eq!(merge(s).len(), 2);
        let mut s = segs();
        unpleading(&mut s, 28);
        let t: Vec<Vec<String>> = merge(s)
            .into_iter()
            .map(|(_, w)| w.into_iter().map(|w| w.t).collect())
            .collect();
        assert_eq!(t, [["ALTERNATIVE,"], ["UNITED"], ["12"]]);
    }

    #[test]
    fn baseline_is_glyph_mode() {
        let glyphs = vec![
            (73.0, 80.0),
            (80.0, 84.12),
            (90.0, 84.12),
            (95.0, 84.12),
            (600.0, 84.0),
        ];
        let l = line(
            Rect {
                x0: 72.0,
                y0: 72.0,
                x1: 100.0,
                y1: 87.8,
            },
            vec![],
            &glyphs,
            &[],
        );
        assert_eq!(l.baseline, 84.12);
        assert!(!l.baseline_est);
        let l = line(
            Rect {
                x0: 200.0,
                y0: 72.0,
                x1: 300.0,
                y1: 87.8,
            },
            vec![],
            &glyphs,
            &[],
        );
        assert!(l.baseline_est);
        assert_eq!(l.baseline, 87.8);
    }

    #[test]
    fn baseline_counts_only_the_lines_own_glyphs() {
        // "v." (left column) and "CAUSE" (right) merged into one line whose band reaches the line above in the
        // right column ("SHOW", baseline 253.2, more glyphs): the baseline is the line's own, 265.2
        let w = |t: &str, x0: f64, y0: f64, x1: f64, y1: f64| Word {
            t: t.into(),
            x0,
            y0,
            x1,
            y1,
        };
        let words = vec![
            w("v.", 204.0, 250.9, 213.0, 264.2),
            w("CAUSE", 338.0, 254.5, 379.0, 267.8),
        ];
        let mut glyphs: Vec<(f64, f64)> = vec![(205.0, 265.2), (209.0, 265.2)];
        glyphs.extend((0..5).map(|i| (340.0 + 8.0 * i as f64, 265.2)));
        glyphs.extend((0..8).map(|i| (338.0 + 22.0 * i as f64, 253.2)));
        glyphs.sort_by(|a, b| a.1.total_cmp(&b.1));
        let bbox = Rect {
            x0: 204.0,
            y0: 250.9,
            x1: 379.0,
            y1: 267.8,
        };
        assert_eq!(line(bbox, words, &glyphs, &[]).baseline, 265.2);
    }
}
