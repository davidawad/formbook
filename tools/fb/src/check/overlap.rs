//! DEF-FORM-004, `text_overlap`: no two lines of text closer than solid, and no two words printed over each other.
//!
//! Engine-neutral: it reads the PDF's words (`pdftotext -bbox`: each word's box, unrounded and without the spaces
//! around it) and their font sizes (the `fontspec` of the `pdftohtml -xml` run the word sits in, as pdf-runs.awk
//! reads runs), never the template. The case it was written for (fb-595.79): a counsel block of single lines that ran
//! past the numbered line the court title stands on, so its last line sat 10.3 pt above the title's baseline in
//! 12 pt type, the two touching.
//!
//! The text box of a word is its em: one type size tall, `EM_UP` of it above the baseline and `EM_DOWN` below. Two
//! lines whose ems intersect are set closer than solid (baseline to baseline less than the type size), tighter than
//! the single spacing that is the least any court rule allows (headings, quotations, footnotes); two words of one line
//! whose boxes intersect are printed over each other. poppler's own box of a word (the font descriptor's ascent to
//! descent, clamped to 1.05 and 0.4 of the size) runs from 0.9 of the size (Times as typst embeds it) to 1.45 (TeX
//! Gyre Schola), so it is used only to place the baseline: a quarter of the box height above its bottom. Two words fail
//! when their ems intersect by more than `EPS_V_PT` vertically and their boxes by more than `EPS_H_PT` horizontally.
//! A word less than 0.8 the size of the other on another line (a footnote mark, raised above its own line's em) is
//! not compared with it. One finding is reported per pair of lines.
//!
//! `fb text-overlap <pdf>...` runs the same test on any PDF, for sweeps.
use super::sh::io_fail;
use crate::{fail, Res};
use std::collections::{BTreeSet, HashMap};
use std::process::{Command, ExitCode, Stdio};

/// The em above the baseline, as a fraction of the size (Times: ascent 0.891 of an ascent-to-descent of 1.107).
pub const EM_UP: f64 = 0.78;
/// The em below the baseline.
pub const EM_DOWN: f64 = 0.22;
/// Vertical intersection that counts: more than the error of the baseline estimate between two faces.
pub const EPS_V_PT: f64 = 0.5;
/// Horizontal intersection that counts: more than the kerning between two words of one line (a small-caps word and
/// the full-size hyphen after it overlap by 1.1 pt).
pub const EPS_H_PT: f64 = 2.0;

/// A box on a page, in points from the top left.
#[derive(Debug, Clone, PartialEq)]
pub struct Word {
    pub page: u32,
    pub x0: f64,
    pub y0: f64,
    pub x1: f64,
    pub y1: f64,
    /// font size, pt (0 until `sized` sets it)
    pub size: f64,
    pub text: String,
}

impl Word {
    fn em(&self) -> (f64, f64) {
        let base = self.y1 - 0.25 * (self.y1 - self.y0);
        (base - EM_UP * self.size, base + EM_DOWN * self.size)
    }
}

fn attr<'a>(line: &'a str, name: &str) -> Option<&'a str> {
    let key = format!(" {name}=\"");
    let at = line.find(&key)? + key.len();
    line[at..].split('"').next()
}

fn num(line: &str, name: &str) -> Option<f64> {
    attr(line, name)?.parse().ok()
}

/// The text of an element's body: tags dropped, entities resolved.
fn body_text(line: &str) -> String {
    let body = line.split_once('>').map(|x| x.1).unwrap_or("");
    let body = body.rsplit_once("</").map(|x| x.0).unwrap_or(body);
    let mut text = String::new();
    let mut tag = false;
    for c in body.chars() {
        match c {
            '<' => tag = true,
            '>' => tag = false,
            _ if !tag => text.push(c),
            _ => {}
        }
    }
    text.replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", "\"")
        .replace("&apos;", "'")
        .replace("&#39;", "'")
        .replace("&#34;", "\"")
        .replace("&amp;", "&")
}

/// The runs of `pdftohtml -xml -zoom 2 -i` output as boxes in points, each with its fontspec's size.
pub fn parse_runs(xml: &str) -> Vec<Word> {
    let mut sizes = HashMap::<String, f64>::new();
    let mut page = 0u32;
    let mut out = Vec::new();
    for line in xml.lines().map(str::trim_start) {
        if line.starts_with("<page ") {
            page = attr(line, "number")
                .and_then(|v| v.parse().ok())
                .unwrap_or(0);
        } else if line.starts_with("<fontspec ") {
            if let (Some(id), Some(size)) = (attr(line, "id"), num(line, "size")) {
                sizes.insert(id.to_string(), size / 2.0);
            }
        } else if line.starts_with("<text ") {
            let size = attr(line, "font").and_then(|f| sizes.get(f)).copied();
            let v = ["top", "left", "width", "height"].map(|k| num(line, k).map(|v| v / 2.0));
            if let ([Some(top), Some(left), Some(width), Some(height)], Some(size)) = (v, size) {
                out.push(Word {
                    page,
                    x0: left,
                    y0: top,
                    x1: left + width,
                    y1: top + height,
                    size,
                    text: body_text(line),
                });
            }
        }
    }
    out
}

/// The words of `pdftotext -bbox` output (pages numbered from 1), size 0.
pub fn parse_words(xhtml: &str) -> Vec<Word> {
    let mut page = 0u32;
    let mut out = Vec::new();
    for line in xhtml.lines().map(str::trim_start) {
        if line.starts_with("<page ") {
            page += 1;
        } else if line.starts_with("<word ") {
            let v = ["xMin", "yMin", "xMax", "yMax"].map(|k| num(line, k));
            if let [Some(x0), Some(y0), Some(x1), Some(y1)] = v {
                out.push(Word {
                    page,
                    x0,
                    y0,
                    x1,
                    y1,
                    size: 0.0,
                    text: body_text(line),
                });
            }
        }
    }
    out
}

/// Each word takes the size of the run its centre lies in (runs are on a 0.5 pt grid, hence the 1 pt slack), held to
/// what its own box allows: the box is 0.85 (cap height and descender) to 1.45 (poppler's clamp) of the size, so a
/// word under a run of another size (a check box glyph in a line of text) cannot take that size. A word in no run
/// takes its box height.
pub fn sized(mut words: Vec<Word>, runs: &[Word]) -> Vec<Word> {
    for w in &mut words {
        let (cx, cy) = ((w.x0 + w.x1) / 2.0, (w.y0 + w.y1) / 2.0);
        let h = w.y1 - w.y0;
        w.size = runs
            .iter()
            .find(|r| {
                r.page == w.page
                    && r.x0 - 1.0 <= cx
                    && cx <= r.x1 + 1.0
                    && r.y0 - 1.0 <= cy
                    && cy <= r.y1 + 1.0
            })
            .map(|r| r.size)
            .unwrap_or(h)
            .clamp(h / 1.45, h / 0.85);
    }
    words
}

fn output(prog: &str, args: &[&str]) -> Res<String> {
    let o = Command::new(prog)
        .args(args)
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .map_err(|e| io_fail(prog, e))?;
    if !o.status.success() {
        let pdf = args.last().copied().unwrap_or_default();
        return Err(fail(2, format!("fb: {prog} failed on {pdf}")));
    }
    Ok(String::from_utf8_lossy(&o.stdout).into_owned())
}

/// The sized words of a PDF.
pub fn words_of(pdf: &str) -> Res<Vec<Word>> {
    let runs = parse_runs(&output(
        "pdftohtml",
        &["-xml", "-zoom", "2", "-i", "-q", "-stdout", pdf],
    )?);
    let words = parse_words(&output("pdftotext", &["-bbox", pdf, "-"])?);
    Ok(sized(words, &runs))
}

fn inter(a: (f64, f64), b: (f64, f64)) -> f64 {
    a.1.min(b.1) - a.0.max(b.0)
}

/// Every pair of lines on one page with words whose ems intersect, as
/// `p.N: "a" (top T) prints into "b" (top T) by H x V pt`, naming the first such pair of words.
pub fn find(words: &[Word]) -> Vec<String> {
    let mut out = Vec::new();
    let mut seen = BTreeSet::new();
    let mut on: Vec<&Word> = words.iter().filter(|w| !w.text.trim().is_empty()).collect();
    on.sort_by(|a, b| {
        (a.page, a.y0, a.x0)
            .partial_cmp(&(b.page, b.y0, b.x0))
            .unwrap_or(std::cmp::Ordering::Equal)
    });
    for (i, a) in on.iter().enumerate() {
        let ea = a.em();
        for b in &on[i + 1..] {
            if b.page != a.page || b.em().0 >= ea.1 + 2.0 * b.size {
                break;
            }
            let v = inter(ea, b.em());
            let (small, big) = (a.size.min(b.size), a.size.max(b.size));
            if small < 0.8 * big && (a.y1 - b.y1).abs() > 0.3 * big {
                continue;
            }
            let h = inter((a.x0, a.x1), (b.x0, b.x1));
            let line = |w: &Word| (w.y0 * 10.0).round() as i64;
            if v > EPS_V_PT && h > EPS_H_PT && seen.insert((a.page, line(a), line(b))) {
                out.push(format!(
                    "p.{}: \"{}\" (top {:.1}) prints into \"{}\" (top {:.1}) by {h:.1} x {v:.1} pt",
                    a.page, a.text, a.y0, b.text, b.y0
                ));
            }
        }
    }
    out
}

/// `fb text-overlap <pdf>...`: one line per PDF (OK or FAIL and the number of findings), then the findings.
/// Exit 1 when any PDF fails.
pub fn main(args: &[String]) -> Res<ExitCode> {
    if args.is_empty() {
        return Err(fail(2, "usage: fb text-overlap <pdf>..."));
    }
    let mut bad = false;
    for pdf in args {
        let found = find(&words_of(pdf)?);
        let st = if found.is_empty() { "OK" } else { "FAIL" };
        println!("{st}\t{pdf}\t{} overlaps", found.len());
        for f in &found {
            println!("\t{f}");
        }
        bad |= !found.is_empty();
    }
    Ok(if bad {
        ExitCode::from(1)
    } else {
        ExitCode::SUCCESS
    })
}

#[cfg(test)]
#[path = "overlap_tests.rs"]
mod tests;
