//! Mutations for `fb diff-selftest`: markdown edits (drop or swap a paragraph, force a line break) that
//! are rendered by the court's own template, and page-level geometry edits (shift, scale) applied to the
//! rendered PDF by placing its pages in a typst wrapper.

/// A plain paragraph of the markdown: line range of the block (end exclusive).
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Block {
    pub start: usize,
    pub end: usize,
}

/// Paragraph blocks of body text (no frontmatter, fences, headings, lists, tables, quotes), at least
/// `min_words` long.
pub fn paragraphs(md: &str, min_words: usize) -> Vec<Block> {
    let lines: Vec<&str> = md.lines().collect();
    let mut i = 0;
    // YAML frontmatter.
    if lines.first().is_some_and(|l| l.trim() == "---") {
        i = lines
            .iter()
            .skip(1)
            .position(|l| l.trim() == "---" || l.trim() == "...")
            .map_or(0, |p| p + 2);
    }
    let mut out = Vec::new();
    let mut fence = false;
    while i < lines.len() {
        let l = lines[i];
        if l.trim_start().starts_with("```") || l.trim_start().starts_with("~~~") {
            fence = !fence;
            i += 1;
            continue;
        }
        if fence || l.trim().is_empty() {
            i += 1;
            continue;
        }
        let start = i;
        while i < lines.len() && !lines[i].trim().is_empty() {
            i += 1;
        }
        let first = lines[start].trim_start();
        let plain = first
            .chars()
            .next()
            .is_some_and(|c| c.is_alphabetic() || c == '“' || c == '"')
            && lines[start] == first;
        let words: usize = lines[start..i]
            .iter()
            .map(|l| l.split_whitespace().count())
            .sum();
        if plain && words >= min_words && lines[start..i].iter().all(|l| !l.contains('|')) {
            out.push(Block { start, end: i });
        }
    }
    out
}

fn join(lines: &[&str]) -> String {
    let mut s = lines.join("\n");
    s.push('\n');
    s
}

/// The markdown without block `b`.
pub fn drop(md: &str, b: Block) -> String {
    let lines: Vec<&str> = md.lines().collect();
    join(&[&lines[..b.start], &lines[b.end..]].concat())
}

/// The markdown with blocks `a` and `b` (a before b) exchanged.
pub fn swap(md: &str, a: Block, b: Block) -> String {
    let l: Vec<&str> = md.lines().collect();
    join(
        &[
            &l[..a.start],
            &l[b.start..b.end],
            &l[a.end..b.start],
            &l[a.start..a.end],
            &l[b.end..],
        ]
        .concat(),
    )
}

/// The markdown with a hard line break (backslash at the end of a line) after the `after`-th word of
/// block `b`.
pub fn force_break(md: &str, b: Block, after: usize) -> String {
    let lines: Vec<&str> = md.lines().collect();
    let para = lines[b.start..b.end].join(" ");
    let words: Vec<&str> = para.split_whitespace().collect();
    let k = after.min(words.len().saturating_sub(1)).max(1);
    let broken = format!("{}\\\n{}", words[..k].join(" "), words[k..].join(" "));
    join(&[&lines[..b.start], &[broken.as_str()][..], &lines[b.end..]].concat())
}

/// A page-level transform of the rendered PDF: every page placed at (dx, dy) and scaled by (sx, sy)
/// about the point (ox, oy) (points, from the top left).
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Warp {
    pub dx: f64,
    pub dy: f64,
    pub sx: f64,
    pub sy: f64,
    pub ox: f64,
    pub oy: f64,
}

impl Warp {
    pub const IDENTITY: Warp = Warp {
        dx: 0.0,
        dy: 0.0,
        sx: 1.0,
        sy: 1.0,
        ox: 0.0,
        oy: 0.0,
    };
}

/// Typst source that redraws `pdf` (a file name next to the .typ) page by page with `w` applied.
/// Each page is placed as a vector image, so text, fonts and drawings survive for measuring.
pub fn wrapper(pdf: &str, sizes: &[(f64, f64)], w: Warp) -> String {
    let mut s = String::from("#set page(margin: 0pt)\n");
    for (i, (pw, ph)) in sizes.iter().enumerate() {
        // Scaling about (ox, oy): move the origin there, scale, move back.
        let (tx, ty) = (w.dx + w.ox * (1.0 - w.sx), w.dy + w.oy * (1.0 - w.sy));
        s.push_str(&format!(
            "#page(width: {pw}pt, height: {ph}pt)[#place(top + left, dx: {tx}pt, dy: {ty}pt, scale(x: {}%, y: {}%, origin: top + left, reflow: false, image(\"{pdf}\", page: {}, width: {pw}pt, height: {ph}pt)))]\n",
            w.sx * 100.0,
            w.sy * 100.0,
            i + 1
        ));
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    const MD: &str = "---\ntitle: x\n---\n\n# Heading\n\nAlpha beta gamma delta epsilon\nzeta eta theta.\n\n- a list item with many words in it\n\nIota kappa lambda mu nu xi omicron pi.\n\n| a | b |\n";

    #[test]
    fn finds_plain_paragraphs_only() {
        let p = paragraphs(MD, 5);
        assert_eq!(
            p,
            vec![Block { start: 6, end: 8 }, Block { start: 11, end: 12 }]
        );
    }

    #[test]
    fn drop_swap_break() {
        let p = paragraphs(MD, 5);
        let d = drop(MD, p[0]);
        assert!(!d.contains("Alpha") && d.contains("Iota"));
        let s = swap(MD, p[0], p[1]);
        assert!(s.find("Iota").unwrap() < s.find("Alpha").unwrap());
        assert!(s.contains("- a list item"));
        let b = force_break(MD, p[0], 3);
        assert!(
            b.contains("Alpha beta gamma\\\ndelta epsilon zeta eta theta."),
            "{b}"
        );
    }

    #[test]
    fn wrapper_pages() {
        let w = wrapper(
            "base.pdf",
            &[(612.0, 792.0)],
            Warp {
                dx: 3.6,
                ..Warp::IDENTITY
            },
        );
        assert!(w.contains("dx: 3.6pt"), "{w}");
        assert!(w.contains("image(\"base.pdf\", page: 1"), "{w}");
        let w = wrapper(
            "b.pdf",
            &[(612.0, 792.0)],
            Warp {
                sx: 1.02,
                sy: 1.02,
                ox: 72.0,
                oy: 72.0,
                ..Warp::IDENTITY
            },
        );
        assert!(w.contains("dx: -1.44"), "{w}");
    }
}
