//! `fb diff <exemplar> <render>`: staged, localized comparison of two PDFs (or measured.json files).
//!
//!   G0 page count and page size
//!   G1 text frame of every page (left, right, first and last baseline)
//!   G2 content and order: the same words in the same order (masked regions out)
//!   G3 identical line and page breaks, then every line's baseline gap, left edge and width
//!   G4 rules, rectangles, other vectors; per-line weight, slant, size and font
//!
//! A gate runs only when every earlier gate passed. No scores: each finding is one place (page, line,
//! shape), signed (ours minus exemplar) and names the template parameter it points at; the first
//! divergence is printed first. Tolerance: `tools/fb/tolerance.json`, measured by `fb diff-selftest`
//! from rebuilding the same PDF twice (never below the 0.01 pt measurement resolution).
mod align;
mod breaks;
pub mod calibrate;
mod content;
mod geom;
pub mod xbaseline;
pub mod xengine;

use crate::measure::{self, Measured};
use crate::{fail, Res};
use serde::{Deserialize, Serialize};
use std::path::Path;
use std::process::ExitCode;

/// How many findings of one gate are listed (first ones first).
pub const LIST: usize = 25;

/// The outcome of one staged diff. `pass` is true only when G0 to G4 all pass; `findings` are the
/// localized, signed divergences of the first failing gate, first divergence first.
#[derive(Debug, Clone)]
pub struct Report {
    pub pass: bool,
    /// The last gate evaluated ("G0".."G4"); when `pass` is false this is the failing gate.
    pub gate: &'static str,
    pub findings: Vec<String>,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Tol {
    /// Largest difference in points that still counts as equal.
    pub pt: f64,
    /// Where the number came from.
    #[serde(default)]
    pub source: String,
}

impl Default for Tol {
    fn default() -> Self {
        Tol {
            pt: measure::RES,
            source: "measurement resolution (no tools/fb/tolerance.json)".into(),
        }
    }
}

impl Tol {
    pub fn off(&self, a: f64, b: f64) -> bool {
        (a - b).abs() > self.pt + 1e-9
    }
    pub fn close(&self, a: f64, b: f64) -> bool {
        !self.off(a, b)
    }
    /// `tools/fb/tolerance.json` under the repo root, else the measurement resolution.
    pub fn load() -> Tol {
        crate::repo_root()
            .ok()
            .and_then(|r| std::fs::read_to_string(r.join("tools/fb/tolerance.json")).ok())
            .and_then(|t| serde_json::from_str::<Tol>(&t).ok())
            .map(|t| Tol {
                pt: t.pt.max(measure::RES),
                ..t
            })
            .unwrap_or_default()
    }
}

/// The exemplar's mask-file regions apply to the render too: whatever the clerk's stamp covers is not
/// compared on either side.
fn mask_render(ex: &Measured, us: &mut Measured) {
    for (a, b) in ex.pages.iter().zip(us.pages.iter_mut()) {
        let regions: Vec<measure::Rect> = a
            .masked
            .iter()
            .filter(|m| m.kind.starts_with("region"))
            .map(|m| m.bbox)
            .collect();
        if regions.is_empty() {
            continue;
        }
        b.lines.retain(|l| {
            let (cx, cy) = ((l.left + l.right) / 2.0, (l.top + l.bottom) / 2.0);
            !regions.iter().any(|r| r.contains_pt(cx, cy))
        });
        b.frame = measure::frame_of(&b.lines);
    }
}

pub fn diff_measured(ex: &Measured, us: &Measured, tol: &Tol) -> Report {
    let mut us = us.clone();
    mask_render(ex, &mut us);
    let us = &us;
    let fail_at = |gate: &'static str, mut findings: Vec<String>| {
        findings.truncate(LIST);
        Report {
            pass: false,
            gate,
            findings,
        }
    };
    let f = geom::g0(ex, us, tol);
    if !f.is_empty() {
        return fail_at("G0", f);
    }
    let f = geom::g1(ex, us, tol);
    if !f.is_empty() {
        return fail_at("G1", f);
    }
    let (te, tu) = (content::tokens(ex), content::tokens(us));
    let f = content::g2(&te, &tu, LIST);
    if !f.is_empty() {
        return fail_at("G2", f);
    }
    let f = content::breaks(&te, &tu, LIST);
    if !f.is_empty() {
        return fail_at("G3", f);
    }
    let (f, worst) = geom::lines(ex, us, tol);
    if !f.is_empty() {
        let mut r = fail_at("G3", f);
        r.findings.extend(worst);
        return r;
    }
    let f = geom::g4(ex, us, tol);
    if !f.is_empty() {
        return fail_at("G4", f);
    }
    Report {
        pass: true,
        gate: "G4",
        findings: vec![],
    }
}

/// Diff two PDFs (or measured.json files) on disk.
pub fn diff_paths(exemplar: &Path, render: &Path) -> Res<Report> {
    let ex = measure::load(exemplar)?;
    let us = measure::load(render)?;
    Ok(diff_measured(&ex, &us, &Tol::load()))
}

const GATES: [(&str, &str); 5] = [
    ("G0", "page count and size"),
    ("G1", "text frame per page"),
    ("G2", "content and order"),
    ("G3", "line breaks and line positions"),
    ("G4", "rules, rectangles, vectors, line styles"),
];

/// The printed report: one status line per gate (later gates NOT RUN after a failure), the findings,
/// and a RESULT line.
pub fn render_report(r: &Report, tol: &Tol) -> String {
    let mut s = String::new();
    let mut failed = false;
    for (g, what) in GATES {
        let status = match (failed, r.pass || g < r.gate, g == r.gate) {
            (true, _, _) => "NOT RUN",
            (_, true, _) => "PASS",
            (_, _, true) => {
                failed = true;
                "FAIL"
            }
            _ => "NOT RUN",
        };
        s.push_str(&format!("{g} {status:<7} {what}\n"));
        if status == "FAIL" {
            for f in &r.findings {
                s.push_str(&format!("  {f}\n"));
            }
        }
    }
    s.push_str(&format!("tolerance: {} pt ({})\n", tol.pt, tol.source));
    match (r.pass, r.findings.first()) {
        (true, _) => s.push_str("RESULT: DIFF PASS (G0-G4)\n"),
        (false, Some(first)) => s.push_str(&format!("RESULT: DIFF FAIL at {}: {first}\n", r.gate)),
        (false, None) => s.push_str(&format!("RESULT: DIFF FAIL at {}\n", r.gate)),
    }
    s
}

/// `--content`: G0 and G2 only, each run whatever the other says (G1, G3, G4 are not run). This checks
/// a transcription (every word, in order, page count and size) before the layout can match.
pub fn diff_content(ex: &Measured, us: &Measured, tol: &Tol) -> (Vec<String>, Vec<String>) {
    let mut us = us.clone();
    mask_render(ex, &mut us);
    let mut g0 = geom::g0(ex, &us, tol);
    g0.truncate(LIST);
    let g2 = content::g2(&content::tokens(ex), &content::tokens(&us), LIST);
    (g0, g2)
}

fn content_main(ex: &Path, us: &Path) -> Res<ExitCode> {
    let tol = Tol::load();
    let (g0, g2) = diff_content(&measure::load(ex)?, &measure::load(us)?, &tol);
    for (g, what, f) in [
        ("G0", "page count and size", &g0),
        ("G2", "content and order", &g2),
    ] {
        println!(
            "{g} {:<7} {what}",
            if f.is_empty() { "PASS" } else { "FAIL" }
        );
        for x in f {
            println!("  {x}");
        }
    }
    let first = g0
        .first()
        .map(|f| ("G0", f))
        .or(g2.first().map(|f| ("G2", f)));
    match first {
        None => println!("RESULT: CONTENT PASS (G0, G2)"),
        Some((g, f)) => println!("RESULT: CONTENT FAIL at {g}: {f}"),
    }
    Ok(if first.is_none() {
        ExitCode::SUCCESS
    } else {
        ExitCode::from(1)
    })
}

/// `--breaks`: identical line breaks over the shared words (breaks.rs), whatever G0 to G2 say. Exit 0
/// only when every compared line is identical.
fn breaks_main(ex: &Path, us: &Path) -> Res<ExitCode> {
    let (ex, mut us) = (measure::load(ex)?, measure::load(us)?);
    mask_render(&ex, &mut us);
    let b = breaks::count(&ex, &us, usize::MAX);
    print!("{}", breaks::render(&b));
    Ok(if b.identical == b.compared {
        ExitCode::SUCCESS
    } else {
        ExitCode::from(1)
    })
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    if let [flag, ex, us] = args {
        if flag == "--content" {
            return content_main(Path::new(ex), Path::new(us));
        }
        if flag == "--breaks" {
            return breaks_main(Path::new(ex), Path::new(us));
        }
        if flag == "--engines" {
            let c = xengine::compare(
                &measure::load(Path::new(ex))?,
                &measure::load(Path::new(us))?,
            );
            print!("{}", xengine::render(&c));
            let ok = c.pages_equal() && c.ends_bad == 0 && c.breaks_equal();
            return Ok(if ok {
                ExitCode::SUCCESS
            } else {
                ExitCode::from(1)
            });
        }
    }
    let [ex, us] = args else {
        return Err(fail(
            2,
            "usage: fb diff [--content|--breaks|--engines] <exemplar.pdf|typst.pdf|measured.json> <render.pdf|measured.json>",
        ));
    };
    let r = diff_paths(Path::new(ex), Path::new(us))?;
    print!("{}", render_report(&r, &Tol::load()));
    Ok(if r.pass {
        ExitCode::SUCCESS
    } else {
        ExitCode::from(1)
    })
}

#[cfg(test)]
pub mod tests;
