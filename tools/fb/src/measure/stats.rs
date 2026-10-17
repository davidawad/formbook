//! Derived layout numbers of a page: common left edge, line pitch, first-line and hanging indents.
//! Diagnostic only (they name the parameter a divergence points at); the gates compare lines.
use super::build::mode;
use super::{r2, Frame, Line, Stats};

/// Lines `a` then `b` are one paragraph when `b` follows at tighter than the page's pitch (single-spaced
/// wraps in a double-spaced page), or at the pitch after a line that runs to the right edge and is not a
/// dot-leader entry.
pub fn continues(a: &Line, b: &Line, pitch: f64, frame: &Frame) -> bool {
    let d = b.baseline - a.baseline;
    let em = if a.size > 0.0 { a.size } else { 12.0 };
    // A dot-leader line (table of contents or authorities) ends its entry.
    let leader = a.text.contains("....");
    d > 0.0
        && !leader
        && (d < pitch - 1.0 || (d < pitch + 1.0 && a.right >= frame.right - 2.0 * em))
}

pub fn of(lines: &[Line], frame: Option<&Frame>) -> Stats {
    let Some(frame) = frame else {
        return Stats::default();
    };
    let left = mode(lines.iter().map(|l| (l.left, 1.0)));
    let pitch = mode(
        lines
            .windows(2)
            .map(|w| (w[1].baseline - w[0].baseline, 1.0))
            .filter(|d| d.0 > 0.5),
    );
    let mut lefts: Vec<(f64, usize)> = Vec::new();
    for l in lines {
        let x = (l.left * 10.0).round() / 10.0;
        match lefts.iter_mut().find(|(v, _)| (*v - x).abs() < 0.05) {
            Some(e) => e.1 += 1,
            None => lefts.push((x, 1)),
        }
    }
    lefts.sort_by(|a, b| a.0.total_cmp(&b.0));
    // Paragraphs: first line and the left of their second line.
    let mut firsts: Vec<(f64, f64)> = Vec::new();
    let mut start = true;
    for (i, w) in lines.windows(2).enumerate() {
        let cont = pitch.is_some_and(|p| continues(&w[0], &w[1], p, frame));
        if cont && (start || i == 0) {
            firsts.push((w[0].left, w[1].left));
        }
        start = !cont;
    }
    let first_line_indent = mode(
        firsts
            .iter()
            .filter(|(f, s)| f - s > 0.5)
            .map(|(f, s)| (f - s, 1.0)),
    );
    let hanging = mode(
        firsts
            .iter()
            .filter(|(f, s)| s - f > 0.5)
            .map(|(_, s)| (*s, 1.0)),
    );
    Stats {
        left: left.map(r2),
        pitch: pitch.map(r2),
        first_line_indent: first_line_indent.map(r2),
        hanging: hanging.map(r2),
        lefts,
    }
}
