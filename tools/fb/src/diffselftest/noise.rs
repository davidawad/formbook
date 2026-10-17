//! Measurement noise between two builds of the same input: the largest coordinate difference over every
//! page, line, word and shape. A structural difference (page, line, word or shape counts) means the build
//! is not reproducible, which is an error, not noise.
use crate::measure::{Measured, Rect};

fn rect_d(a: &Rect, b: &Rect) -> f64 {
    [a.x0 - b.x0, a.y0 - b.y0, a.x1 - b.x1, a.y1 - b.y1]
        .iter()
        .fold(0.0, |m: f64, d| m.max(d.abs()))
}

/// The largest difference in points, or where the two builds differ in structure.
pub fn noise(a: &Measured, b: &Measured) -> Result<f64, String> {
    if a.pages.len() != b.pages.len() {
        return Err(format!("page count {} vs {}", a.pages.len(), b.pages.len()));
    }
    let mut max: f64 = 0.0;
    let mut see = |d: f64| max = max.max(d.abs());
    for (p, q) in a.pages.iter().zip(&b.pages) {
        see(p.w - q.w);
        see(p.h - q.h);
        if p.lines.len() != q.lines.len() {
            return Err(format!(
                "p{}: {} lines vs {}",
                p.n,
                p.lines.len(),
                q.lines.len()
            ));
        }
        for (i, (x, y)) in p.lines.iter().zip(&q.lines).enumerate() {
            if x.words.len() != y.words.len() || x.text != y.text {
                return Err(format!(
                    "p{} line {}: '{}' vs '{}'",
                    p.n,
                    i + 1,
                    x.text,
                    y.text
                ));
            }
            for d in [
                x.baseline - y.baseline,
                x.left - y.left,
                x.right - y.right,
                x.top - y.top,
                x.bottom - y.bottom,
                x.size - y.size,
            ] {
                see(d);
            }
            for (u, v) in x.words.iter().zip(&y.words) {
                for d in [u.x0 - v.x0, u.y0 - v.y0, u.x1 - v.x1, u.y1 - v.y1] {
                    see(d);
                }
            }
        }
        for (kind, r, s) in [
            ("rules", &p.rules, &q.rules),
            ("boxes", &p.boxes, &q.boxes),
            ("vectors", &p.vectors, &q.vectors),
        ] {
            if r.len() != s.len() {
                return Err(format!("p{}: {} {kind} vs {}", p.n, r.len(), s.len()));
            }
            for (u, v) in r.iter().zip(s) {
                see(rect_d(u, v));
            }
        }
    }
    Ok(crate::measure::r2(max))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::diff::tests::doc;

    #[test]
    fn zero_for_identical_and_max_of_shifts() {
        let a = doc(&[&["alpha beta", "gamma delta"]]);
        assert_eq!(noise(&a, &a), Ok(0.0));
        let mut b = a.clone();
        b.pages[0].lines[1].baseline += 0.03;
        b.pages[0].lines[0].words[0].x1 -= 0.05;
        assert_eq!(noise(&a, &b), Ok(0.05));
        let c = doc(&[&["alpha beta"]]);
        assert!(noise(&a, &c).is_err());
    }
}
