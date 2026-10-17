//! Geometry gates: G0 page count and size, G1 text frame per page, G3 per-line baseline/left/right,
//! G4 rules, boxes, vectors and line styles (weight, slant, size, font). Every finding names its page and
//! line, carries the signed difference (ours minus exemplar) and the template parameter it points at.
use super::Tol;
use crate::measure::{Line, Measured, Page, Rect};

fn s(d: f64) -> String {
    format!("{d:+.2}")
}

fn q(t: &str) -> String {
    let short: String = t.chars().take(40).collect();
    format!(
        "'{short}{}'",
        if t.chars().count() > 40 { "..." } else { "" }
    )
}

pub fn g0(ex: &Measured, us: &Measured, tol: &Tol) -> Vec<String> {
    let mut out = Vec::new();
    if ex.pages.len() != us.pages.len() {
        out.push(format!(
            "page count: exemplar {}, ours {} ({:+})",
            ex.pages.len(),
            us.pages.len(),
            us.pages.len() as i64 - ex.pages.len() as i64
        ));
    }
    for (a, b) in ex.pages.iter().zip(&us.pages) {
        if tol.off(a.w, b.w) || tol.off(a.h, b.h) {
            out.push(format!(
                "p{} size: exemplar {}x{}, ours {}x{} (dw={} dh={}) -> param page size",
                a.n,
                a.w,
                a.h,
                b.w,
                b.h,
                s(b.w - a.w),
                s(b.h - a.h)
            ));
        }
    }
    out
}

pub fn g1(ex: &Measured, us: &Measured, tol: &Tol) -> Vec<String> {
    let mut out = Vec::new();
    for (a, b) in ex.pages.iter().zip(&us.pages) {
        match (a.frame, b.frame) {
            (None, None) => {}
            (Some(_), None) => out.push(format!("p{}: ours has no text, the exemplar has", a.n)),
            (None, Some(_)) => out.push(format!("p{}: ours has text, the exemplar has none", a.n)),
            (Some(fa), Some(fb)) => {
                let parts: Vec<String> = [
                    ("left", fa.left, fb.left, "margin_left"),
                    ("right", fa.right, fb.right, "margin_right / text width"),
                    ("top baseline", fa.top, fb.top, "margin_top"),
                    (
                        "bottom baseline",
                        fa.bottom,
                        fb.bottom,
                        "page fill: leading / margin_bottom",
                    ),
                ]
                .iter()
                .filter(|(_, x, y, _)| tol.off(*x, *y))
                .map(|(k, x, y, p)| {
                    format!("{k} {} (exemplar {x}, ours {y}) -> param {p}", s(y - x))
                })
                .collect();
                if !parts.is_empty() {
                    out.push(format!("p{} frame: {}", a.n, parts.join("; ")));
                }
            }
        }
    }
    out
}

/// Is line `i` of `p` the first line of a paragraph (or entry)?
fn starts_par(p: &Page, i: usize) -> bool {
    let Some(prev) = i.checked_sub(1).and_then(|k| p.lines.get(k)) else {
        return true;
    };
    let (pitch, frame) = (p.stats.pitch, p.frame);
    match (pitch, frame) {
        (Some(pitch), Some(f)) => !crate::measure::continues(prev, &p.lines[i], pitch, &f),
        _ => true,
    }
}

fn is_centered(l: &Line, p: &Page) -> bool {
    p.frame.is_some_and(|f| {
        let c = (f.left + f.right) / 2.0;
        ((l.left + l.right) / 2.0 - c).abs() < 1.5 && l.left > f.left + 18.0
    })
}

/// The template parameter a left-edge difference on line `i` points at.
fn left_param(a: &Page, b: &Page, i: usize, tol: &Tol) -> &'static str {
    let d = b.lines[i].left - a.lines[i].left;
    let page_wide = a
        .lines
        .iter()
        .zip(&b.lines)
        .all(|(x, y)| !tol.off(y.left - x.left, d));
    let l = &a.lines[i];
    let common = a.stats.left.unwrap_or(l.left);
    if page_wide {
        "margin_left"
    } else if is_centered(l, a) {
        "heading size / alignment"
    } else if l.left > common + 0.5 && starts_par(a, i) {
        "indent_first"
    } else if l.left > common + 0.5 {
        "indent_hanging / block indent"
    } else {
        "margin_left / alignment"
    }
}

/// The parameter a baseline-gap difference before line `i` points at.
fn gap_param(a: &Page, i: usize) -> &'static str {
    let l = &a.lines[i];
    if i == 0 {
        "margin_top"
    } else if l.bold || is_centered(l, a) || a.lines[i - 1].bold {
        "heading_spacing"
    } else if starts_par(a, i) {
        "par_spacing"
    } else {
        "leading"
    }
}

/// G3 positions, once line breaks agree: lines pair one to one on every page.
pub fn lines(ex: &Measured, us: &Measured, tol: &Tol) -> (Vec<String>, Option<String>) {
    let mut out = Vec::new();
    let mut worst: Option<(f64, String)> = None;
    let mut note = |d: f64, what: String| {
        if worst.as_ref().is_none_or(|w| d.abs() > w.0) {
            worst = Some((d.abs(), what));
        }
    };
    for (a, b) in ex.pages.iter().zip(&us.pages) {
        for (i, (x, y)) in a.lines.iter().zip(&b.lines).enumerate() {
            let at = format!("p{} line {} {}", a.n, i + 1, q(&x.text));
            let mut parts = Vec::new();
            // Vertical: report the line whose own gap to the previous line differs (the cause), not every
            // line it shifts.
            let gap = |p: &Page, l: &Line| {
                i.checked_sub(1)
                    .map_or(l.baseline, |k| l.baseline - p.lines[k].baseline)
            };
            let dg = gap(b, y) - gap(a, x);
            if tol.off(gap(a, x), gap(b, y)) {
                let what = if i == 0 {
                    "baseline"
                } else {
                    "gap to previous baseline"
                };
                parts.push(format!("{what} dy={} -> param {}", s(dg), gap_param(a, i)));
                note(dg, format!("{at} dy={}", s(dg)));
            }
            let dl = y.left - x.left;
            if tol.off(x.left, y.left) {
                parts.push(format!(
                    "indent dx={} -> param {}",
                    s(dl),
                    left_param(a, b, i, tol)
                ));
                note(dl, format!("{at} dx={}", s(dl)));
            }
            // Width: the right edge moved more than the left one.
            let dw = (y.right - y.left) - (x.right - x.left);
            if tol.off(x.right - x.left, y.right - y.left) {
                let full =
                    a.frame.is_some_and(|f| tol.close(x.right, f.right)) && !starts_par(a, i + 1);
                let p = if full {
                    "text width / margin_right (justified line)"
                } else {
                    "font_size / letter or word spacing"
                };
                parts.push(format!("width dw={} -> param {p}", s(dw)));
                note(dw, format!("{at} dw={}", s(dw)));
            }
            if !parts.is_empty() {
                out.push(format!("{at}: {}", parts.join("; ")));
            }
        }
    }
    (out, worst.map(|w| format!("worst instance: {}", w.1)))
}

fn rect(r: &Rect) -> String {
    format!("({:.2},{:.2})-({:.2},{:.2})", r.x0, r.y0, r.x1, r.y1)
}

fn dist(a: &Rect, b: &Rect) -> f64 {
    [(a.x0 - b.x0), (a.y0 - b.y0), (a.x1 - b.x1), (a.y1 - b.y1)]
        .iter()
        .fold(0.0_f64, |m, d| m.max(d.abs()))
}

/// Shapes of one kind on one page: each exemplar shape needs an unused one of ours within tolerance in
/// every coordinate, and ours may have nothing extra.
fn shapes(n: usize, kind: &str, a: &[Rect], b: &[Rect], tol: &Tol, out: &mut Vec<String>) {
    let mut used = vec![false; b.len()];
    for r in a {
        let best = b
            .iter()
            .enumerate()
            .filter(|(k, _)| !used[*k])
            .min_by(|x, y| dist(r, x.1).total_cmp(&dist(r, y.1)));
        match best {
            Some((k, o)) if dist(r, o) <= tol.pt + 1e-9 => used[k] = true,
            Some((_, o)) => out.push(format!(
                "p{n} {kind} {}: nearest of ours {} (dx0={} dy0={} dx1={} dy1={}) -> param {kind} geometry",
                rect(r),
                rect(o),
                s(o.x0 - r.x0),
                s(o.y0 - r.y0),
                s(o.x1 - r.x1),
                s(o.y1 - r.y1)
            )),
            None => out.push(format!("p{n} {kind} {}: missing in ours", rect(r))),
        }
    }
    for (k, o) in b.iter().enumerate().filter(|(k, _)| !used[*k]) {
        if a.iter().all(|r| dist(r, o) > tol.pt + 1e-9) && !out.iter().any(|f| f.contains(&rect(o)))
        {
            out.push(format!(
                "p{n} {kind} {}: extra in ours (#{})",
                rect(o),
                k + 1
            ));
        }
    }
}

/// `TimesNewRomanPS-BoldMT` -> `timesnewroman`: family without style, foundry or encoding suffixes.
pub fn family(name: &str) -> String {
    let base = name.split(['-', ',']).next().unwrap_or(name).to_lowercase();
    let base: String = base.chars().filter(|c| c.is_ascii_alphanumeric()).collect();
    ["psmt", "mt", "ps"].iter().fold(base, |b, suf| {
        b.strip_suffix(suf).map_or(b.clone(), str::to_string)
    })
}

pub fn g4(ex: &Measured, us: &Measured, tol: &Tol) -> Vec<String> {
    let mut out = Vec::new();
    for (a, b) in ex.pages.iter().zip(&us.pages) {
        shapes(a.n, "rule", &a.rules, &b.rules, tol, &mut out);
        shapes(a.n, "box", &a.boxes, &b.boxes, tol, &mut out);
        shapes(a.n, "vector", &a.vectors, &b.vectors, tol, &mut out);
        for (i, (x, y)) in a.lines.iter().zip(&b.lines).enumerate() {
            let mut parts = Vec::new();
            if x.bold != y.bold {
                parts.push(format!(
                    "bold: exemplar {}, ours {} -> param heading/strong weight",
                    x.bold, y.bold
                ));
            }
            if x.italic != y.italic {
                parts.push(format!(
                    "italic: exemplar {}, ours {} -> param emphasis style",
                    x.italic, y.italic
                ));
            }
            if tol.off(x.size, y.size) && x.size > 0.0 && y.size > 0.0 {
                let p = if x.bold || is_centered(x, a) {
                    "heading size"
                } else {
                    "font_size"
                };
                parts.push(format!(
                    "size: exemplar {}pt, ours {}pt ({}) -> param {p}",
                    x.size,
                    y.size,
                    s(y.size - x.size)
                ));
            }
            if !x.font.is_empty() && !y.font.is_empty() && family(&x.font) != family(&y.font) {
                parts.push(format!(
                    "font: exemplar {}, ours {} -> param font family",
                    x.font, y.font
                ));
            }
            if !parts.is_empty() {
                out.push(format!(
                    "p{} line {} {}: {}",
                    a.n,
                    i + 1,
                    q(&x.text),
                    parts.join("; ")
                ));
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn families() {
        assert_eq!(family("TimesNewRomanPS-BoldMT"), "timesnewroman");
        assert_eq!(family("TimesNewRomanPSMT"), "timesnewroman");
        assert_eq!(family("EBGaramond-Regular-Identity-H"), "ebgaramond");
        assert_eq!(family("Times New Roman,Bold"), "timesnewroman");
        assert_ne!(family("Garamond"), family("EBGaramond-Bold"));
    }

    #[test]
    fn shapes_match_within_tolerance_and_name_the_miss() {
        let tol = Tol {
            pt: 0.01,
            source: String::new(),
        };
        let r = |x0, y0, x1, y1| Rect { x0, y0, x1, y1 };
        let mut out = vec![];
        shapes(
            2,
            "rule",
            &[r(72.0, 100.0, 540.0, 101.0)],
            &[r(72.0, 100.005, 540.0, 101.0)],
            &tol,
            &mut out,
        );
        assert!(out.is_empty(), "{out:?}");
        shapes(
            2,
            "rule",
            &[r(72.0, 100.0, 540.0, 101.0)],
            &[r(75.6, 100.0, 540.0, 101.0)],
            &tol,
            &mut out,
        );
        assert_eq!(out.len(), 1);
        assert!(out[0].contains("dx0=+3.60"), "{}", out[0]);
        out.clear();
        shapes(2, "box", &[], &[r(1.0, 1.0, 9.0, 9.0)], &tol, &mut out);
        assert!(out[0].contains("extra in ours"));
    }
}
