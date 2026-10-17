//! `pdftocairo -svg` of one page: glyph origins (for baselines), rules, boxes, other vectors and images.
//! Cairo writes glyphs as `<use xlink:href="#glyph-F-G" x= y=>` at the glyph origin, so `y` is the
//! baseline; paths outside `<defs>` are the page's drawings; images sit in `<image>`, `<use>` of a
//! `#source-N`/`#image-N`, or a `mask=` group clipped to the image's area.
use super::Rect;
use crate::{fail, Res};
use quick_xml::events::Event;
use quick_xml::Reader;
use std::collections::HashMap;

/// Thicker than this in both directions, a drawn shape is not a rule.
pub const RULE_MAX: f64 = 3.0;

#[derive(Debug, Default, Clone)]
pub struct SvgPage {
    /// Glyph origins (x, baseline y).
    pub glyphs: Vec<(f64, f64)>,
    pub rules: Vec<Rect>,
    pub boxes: Vec<Rect>,
    pub vectors: Vec<Rect>,
    pub images: Vec<Rect>,
}

type M = [f64; 6];
const ID: M = [1.0, 0.0, 0.0, 1.0, 0.0, 0.0];

fn mul(p: &M, c: &M) -> M {
    [
        p[0] * c[0] + p[2] * c[1],
        p[1] * c[0] + p[3] * c[1],
        p[0] * c[2] + p[2] * c[3],
        p[1] * c[2] + p[3] * c[3],
        p[0] * c[4] + p[2] * c[5] + p[4],
        p[1] * c[4] + p[3] * c[5] + p[5],
    ]
}

fn apply(m: &M, x: f64, y: f64) -> (f64, f64) {
    (m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5])
}

fn nums(s: &str) -> Vec<f64> {
    s.split(|c: char| c == ',' || c.is_whitespace())
        .filter_map(|t| t.parse().ok())
        .collect()
}

pub fn parse_transform(s: &str) -> M {
    let mut m = ID;
    for part in s.split(')') {
        let Some((name, args)) = part.split_once('(') else {
            continue;
        };
        let v = nums(args);
        let t = match (name.trim(), v.as_slice()) {
            ("matrix", [a, b, c, d, e, f]) => [*a, *b, *c, *d, *e, *f],
            ("translate", [x]) => [1.0, 0.0, 0.0, 1.0, *x, 0.0],
            ("translate", [x, y]) => [1.0, 0.0, 0.0, 1.0, *x, *y],
            ("scale", [s]) => [*s, 0.0, 0.0, *s, 0.0, 0.0],
            ("scale", [sx, sy]) => [*sx, 0.0, 0.0, *sy, 0.0, 0.0],
            _ => ID,
        };
        m = mul(&m, &t);
    }
    m
}

/// The points of a path's `d` (end and control points, absolute), for its bounding box.
pub fn path_points(d: &str) -> Vec<(f64, f64)> {
    let mut pts = Vec::new();
    let (mut cx, mut cy, mut sx, mut sy) = (0.0, 0.0, 0.0, 0.0);
    let mut cmd = 'M';
    let mut buf: Vec<f64> = Vec::new();
    let mut flush =
        |cmd: char, buf: &mut Vec<f64>, cx: &mut f64, cy: &mut f64, sx: &mut f64, sy: &mut f64| {
            let rel = cmd.is_ascii_lowercase();
            let (bx, by) = if rel { (*cx, *cy) } else { (0.0, 0.0) };
            let step = match cmd.to_ascii_uppercase() {
                'M' | 'L' | 'T' => 2,
                'H' | 'V' => 1,
                'C' => 6,
                'S' | 'Q' => 4,
                'A' => 7,
                _ => 0,
            };
            if step == 0 {
                (*cx, *cy) = (*sx, *sy);
                buf.clear();
                return;
            }
            let mut first = true;
            for ch in buf.chunks(step).filter(|c| c.len() == step) {
                let (bx, by) = if rel { (*cx, *cy) } else { (bx, by) };
                match cmd.to_ascii_uppercase() {
                    'H' => *cx = bx + ch[0],
                    'V' => *cy = by + ch[0],
                    'A' => (*cx, *cy) = (bx + ch[5], by + ch[6]),
                    _ => {
                        for xy in ch.chunks(2) {
                            pts.push((bx + xy[0], by + xy[1]));
                        }
                        (*cx, *cy) = (bx + ch[step - 2], by + ch[step - 1]);
                    }
                }
                if matches!(cmd.to_ascii_uppercase(), 'H' | 'V' | 'A') {
                    pts.push((*cx, *cy));
                }
                if cmd.eq_ignore_ascii_case(&'M') && first {
                    (*sx, *sy) = (*cx, *cy);
                }
                first = false;
            }
            buf.clear();
        };
    let mut num = String::new();
    for c in d.chars().chain(std::iter::once(' ')) {
        let starts_new = c == '-' && !num.is_empty() && !num.ends_with('e');
        if c.is_ascii_digit() || c == '.' || c == 'e' || (c == '-' && !starts_new) {
            num.push(c);
            continue;
        }
        if let Ok(v) = num.parse() {
            buf.push(v);
        }
        num.clear();
        if starts_new {
            num.push(c);
        } else if c.is_ascii_alphabetic() {
            flush(cmd, &mut buf, &mut cx, &mut cy, &mut sx, &mut sy);
            cmd = c;
        }
    }
    flush(cmd, &mut buf, &mut cx, &mut cy, &mut sx, &mut sy);
    pts
}

fn bbox(pts: &[(f64, f64)]) -> Option<Rect> {
    let (x, y) = *pts.first()?;
    Some(pts.iter().fold(
        Rect {
            x0: x,
            y0: y,
            x1: x,
            y1: y,
        },
        |r, &(x, y)| Rect {
            x0: r.x0.min(x),
            y0: r.y0.min(y),
            x1: r.x1.max(x),
            y1: r.y1.max(y),
        },
    ))
}

fn is_axis_rect(pts: &[(f64, f64)], r: &Rect) -> bool {
    let near = |a: f64, b: f64| (a - b).abs() < 0.05;
    pts.len() <= 6
        && pts
            .iter()
            .all(|&(x, y)| (near(x, r.x0) || near(x, r.x1)) && (near(y, r.y0) || near(y, r.y1)))
}

fn clip(r: Rect, c: Option<Rect>) -> Option<Rect> {
    let Some(c) = c else { return Some(r) };
    let o = Rect {
        x0: r.x0.max(c.x0),
        y0: r.y0.max(c.y0),
        x1: r.x1.min(c.x1),
        y1: r.y1.min(c.y1),
    };
    (o.x0 <= o.x1 && o.y0 <= o.y1).then_some(o)
}

fn is_white(fill: &str) -> bool {
    let f = fill.replace(' ', "");
    f == "rgb(100%,100%,100%)" || f.eq_ignore_ascii_case("#ffffff") || f == "white"
}

/// One element of the parsed SVG.
#[derive(Debug, Default)]
struct Node {
    name: String,
    attrs: Vec<(String, String)>,
    kids: Vec<usize>,
}

impl Node {
    fn attr(&self, key: &str) -> Option<&str> {
        self.attrs
            .iter()
            .find(|(k, _)| k == key)
            .map(|(_, v)| v.as_str())
    }
    fn num(&self, key: &str) -> f64 {
        self.attr(key).and_then(|v| v.parse().ok()).unwrap_or(0.0)
    }
    fn style(&self, key: &str) -> Option<String> {
        self.attr(key).map(str::to_string).or_else(|| {
            self.attr("style")?.split(';').find_map(|kv| {
                let (k, v) = kv.split_once(':')?;
                (k.trim() == key).then(|| v.trim().to_string())
            })
        })
    }
    fn href(&self) -> Option<&str> {
        self.attr("xlink:href")
            .or_else(|| self.attr("href"))
            .and_then(|h| h.strip_prefix('#'))
    }
}

fn dom(xml: &str) -> Res<Vec<Node>> {
    let mut rd = Reader::from_str(xml);
    rd.config_mut().check_end_names = false;
    let mut nodes = vec![Node {
        name: "#root".into(),
        ..Node::default()
    }];
    let mut stack = vec![0usize];
    loop {
        let ev = rd
            .read_event()
            .map_err(|e| fail(2, format!("fb: cannot parse svg: {e}")))?;
        let (e, empty) = match ev {
            Event::Start(e) => (e, false),
            Event::Empty(e) => (e, true),
            Event::End(_) => {
                if stack.len() > 1 {
                    stack.pop();
                }
                continue;
            }
            Event::Eof => break,
            _ => continue,
        };
        let attrs = e
            .attributes()
            .flatten()
            .filter(|a| a.key.as_ref() != b"xlink:href" || !a.value.starts_with(b"data:"))
            .filter_map(|a| {
                let v = a.unescape_value().ok()?.into_owned();
                Some((String::from_utf8_lossy(a.key.as_ref()).into_owned(), v))
            })
            .collect();
        let id = nodes.len();
        nodes.push(Node {
            name: String::from_utf8_lossy(e.name().as_ref()).into_owned(),
            attrs,
            kids: vec![],
        });
        let parent = *stack.last().unwrap_or(&0);
        nodes[parent].kids.push(id);
        if !empty {
            stack.push(id);
        }
    }
    Ok(nodes)
}

#[derive(Clone, Copy)]
struct Ctx {
    m: M,
    clip: Option<Rect>,
}

/// The transformed bounding box and points of an element's own shape (path, rect or image).
fn shape_box(n: &Node, m: &M) -> Option<(Rect, Vec<(f64, f64)>)> {
    let local: Vec<(f64, f64)> = match n.name.as_str() {
        "path" => path_points(n.attr("d")?),
        _ => {
            let (x, y, w, h) = (n.num("x"), n.num("y"), n.num("width"), n.num("height"));
            vec![(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
        }
    };
    let pts: Vec<(f64, f64)> = local.iter().map(|&(x, y)| apply(m, x, y)).collect();
    Some((bbox(&pts)?, pts))
}

const HIDDEN: [&str; 6] = ["defs", "clipPath", "mask", "symbol", "pattern", "filter"];

struct Walker<'a> {
    nodes: &'a [Node],
    ids: HashMap<&'a str, usize>,
    page: SvgPage,
}

impl Walker<'_> {
    /// The bounding box of a clip path's shapes, in the coordinates of `m`.
    fn clip_box(&self, id: &str, m: &M) -> Option<Rect> {
        let n = &self.nodes[*self.ids.get(id)?];
        let mut acc: Option<Rect> = None;
        let mut todo: Vec<(usize, M)> = n.kids.iter().map(|&k| (k, *m)).collect();
        while let Some((k, pm)) = todo.pop() {
            let c = &self.nodes[k];
            let cm = c
                .attr("transform")
                .map_or(pm, |t| mul(&pm, &parse_transform(t)));
            if let Some((r, _)) = matches!(c.name.as_str(), "path" | "rect")
                .then(|| shape_box(c, &cm))
                .flatten()
            {
                acc = Some(acc.map_or(r, |a| a.union(&r)));
            }
            todo.extend(c.kids.iter().map(|&g| (g, cm)));
        }
        acc
    }

    fn walk(&mut self, k: usize, parent: Ctx, depth: usize) {
        let n = &self.nodes[k];
        if depth > 64 || HIDDEN.contains(&n.name.as_str()) {
            return;
        }
        let m = n
            .attr("transform")
            .map_or(parent.m, |t| mul(&parent.m, &parse_transform(t)));
        let own_clip = n
            .attr("clip-path")
            .and_then(|c| c.strip_prefix("url(#"))
            .and_then(|id| self.clip_box(id.trim_end_matches(')'), &m));
        let clip_now = match (parent.clip, own_clip) {
            (Some(a), Some(b)) => Some(clip(a, Some(b)).unwrap_or(Rect {
                x0: a.x0,
                y0: a.y0,
                x1: a.x0,
                y1: a.y0,
            })),
            (a, b) => b.or(a),
        };
        if n.attr("mask").is_some() {
            // A masked group or shape paints an image (stencil, soft mask) inside its clip.
            if let Some(r) = clip_now.or_else(|| shape_box(n, &m).map(|s| s.0)) {
                self.page.images.push(r);
            }
            return;
        }
        let ctx = Ctx { m, clip: clip_now };
        match n.name.as_str() {
            "use" => {
                let (x, y) = (n.num("x"), n.num("y"));
                let Some(target) = n.href() else { return };
                if target.starts_with("glyph") {
                    self.page.glyphs.push(apply(&m, x, y));
                    return;
                }
                let Some(&t) = self.ids.get(target) else {
                    return;
                };
                let moved = Ctx {
                    m: mul(&m, &[1.0, 0.0, 0.0, 1.0, x, y]),
                    clip: clip_now,
                };
                if self.nodes[t].name == "image" {
                    if let Some(r) =
                        shape_box(&self.nodes[t], &moved.m).and_then(|(r, _)| clip(r, clip_now))
                    {
                        self.page.images.push(r);
                    }
                } else {
                    self.walk_inside(t, moved, depth + 1);
                }
            }
            "image" => {
                if let Some(r) = shape_box(n, &m).and_then(|(r, _)| clip(r, clip_now)) {
                    self.page.images.push(r);
                }
            }
            "path" | "rect" => drawing(n, &m, clip_now, &mut self.page),
            _ => {
                for &c in &n.kids {
                    self.walk(c, ctx, depth + 1);
                }
            }
        }
    }

    /// Draw a referenced element even though it lives in `<defs>`.
    fn walk_inside(&mut self, t: usize, ctx: Ctx, depth: usize) {
        let n = &self.nodes[t];
        if n.name == "symbol" || n.name == "defs" {
            for &c in &n.kids {
                self.walk(c, ctx, depth + 1);
            }
        } else {
            self.walk(t, ctx, depth);
        }
    }
}

pub fn parse(xml: &str) -> Res<SvgPage> {
    let nodes = dom(xml)?;
    let ids: HashMap<&str, usize> = nodes
        .iter()
        .enumerate()
        .filter_map(|(i, n)| Some((n.attr("id")?, i)))
        .collect();
    let mut w = Walker {
        nodes: &nodes,
        ids,
        page: SvgPage::default(),
    };
    // Nothing outside the page box is visible: a rule drawn past the edge ends at the edge.
    let clip = nodes.iter().find(|n| n.name == "svg").and_then(page_box);
    w.walk(0, Ctx { m: ID, clip }, 0);
    Ok(w.page)
}

/// The page box of the root `<svg>`: its viewBox, else its width and height (in pt).
fn page_box(svg: &Node) -> Option<Rect> {
    let v = match svg.attr("viewBox") {
        Some(b) => nums(b),
        None => vec![
            0.0,
            0.0,
            nums(svg.attr("width")?).first().copied()?,
            nums(svg.attr("height")?).first().copied()?,
        ],
    };
    match v[..] {
        [x, y, w, h] if w > 0.0 && h > 0.0 => Some(Rect {
            x0: x,
            y0: y,
            x1: x + w,
            y1: y + h,
        }),
        _ => None,
    }
}

/// A path or rect outside defs: a rule, a box or another vector (white fills and invisible shapes skipped).
fn drawing(e: &Node, m: &M, clip_now: Option<Rect>, page: &mut SvgPage) {
    let fill = e.style("fill").unwrap_or_else(|| "black".into());
    let stroke = e.style("stroke").unwrap_or_else(|| "none".into());
    let filled = fill != "none" && !is_white(&fill);
    let stroked = stroke != "none" && !is_white(&stroke);
    if !filled && !stroked {
        return;
    }
    let Some((mut r, pts)) = shape_box(e, m) else {
        return;
    };
    if stroked {
        let sw = e
            .style("stroke-width")
            .and_then(|v| v.parse::<f64>().ok())
            .unwrap_or(1.0);
        let scale = (m[0] * m[3] - m[1] * m[2]).abs().sqrt();
        let half = sw * scale / 2.0;
        r = Rect {
            x0: r.x0 - half,
            y0: r.y0 - half,
            x1: r.x1 + half,
            y1: r.y1 + half,
        };
    }
    let Some(r) = clip(r, clip_now) else { return };
    if r.w().min(r.h()) <= RULE_MAX && r.w().max(r.h()) > RULE_MAX {
        page.rules.push(r);
    } else if r.w() > RULE_MAX && r.h() > RULE_MAX && is_axis_rect(&pts, &bbox(&pts).unwrap_or(r)) {
        page.boxes.push(r);
    } else {
        page.vectors.push(r);
    }
}

#[cfg(test)]
#[path = "svg_tests.rs"]
mod tests;
