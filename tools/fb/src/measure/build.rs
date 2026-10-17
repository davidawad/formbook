//! From poppler's raw output to measured pages: visual lines with baselines and styles, masks, frame,
//! drawings.
use super::poppler::{RawPage, Run, Seg};
use super::{mask, r2, stats, Frame, Line, MaskRegion, Page, Rect, Word};

pub fn pages(raw: Vec<RawPage>, regions: &[MaskRegion]) -> Vec<Page> {
    raw.into_iter().map(|p| page(p, regions)).collect()
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
    let baseline = mode(
        glyphs[lo..hi]
            .iter()
            .filter(|g| g.0 >= bbox.x0 - 1.0 && g.0 <= bbox.x1 + 1.0)
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
}
