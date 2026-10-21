//! `fb calibrate [--engine typst|latex] [--no-render] [dir-substring]`: the word-compat calibration
//! run (fb-w0vj, docs/EVAL-LOOP.md "Word compatibility"). Renders every entry of
//! data/calibration-set.json with one engine and prints, per entry and in total, G0 and G2
//! (`fb diff --content`), identical and same-start line breaks and word positions (`fb diff --breaks`).
//! Nothing is written but the OUTPUT files the render already writes.
use super::{breaks, diff_content, Tol};
use crate::measure;
use crate::render::{render_one, Warnings};
use crate::{fail, repo_root, Res};
use std::path::Path;
use std::process::ExitCode;

const USAGE: &str = "usage: fb calibrate [--engine typst|latex] [--no-render] [dir-substring]";

/// Whether the run renders each entry before diffing it.
#[derive(Clone, Copy, PartialEq)]
enum Render {
    Yes,
    No,
}

/// A usage id, `<doctype>[-<n>]` (INPUT-<id>.md, OUTPUT-<id>.<engine>.pdf).
#[derive(serde::Deserialize)]
#[serde(transparent)]
struct UsageId(String);

impl std::fmt::Display for UsageId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&self.0)
    }
}

/// One entry of data/calibration-set.json (the fields this run reads).
#[derive(serde::Deserialize)]
struct Entry {
    dir: String,
    id: UsageId,
    exemplar: String,
}

#[derive(serde::Deserialize)]
struct Set {
    entries: Vec<Entry>,
}

#[derive(Default)]
struct Totals {
    n: usize,
    g0: usize,
    identical: usize,
    compared: usize,
    lines: usize,
    ss: usize,
    ss_identical: usize,
    more: usize,
    less: usize,
    pos: [usize; 4],
}

fn status(f: &[String]) -> &'static str {
    if f.is_empty() {
        "PASS"
    } else {
        "FAIL"
    }
}

/// One entry: render (unless `Render::No`), diff, print its row, add to the totals.
fn entry(root: &Path, e: &Entry, engine: &str, render: Render, t: &mut Totals) -> Res<()> {
    let (dir, id, exemplar) = (&e.dir, &e.id, &e.exemplar);
    let d = root.join(dir);
    let out = d.join(format!("usage/OUTPUT-{id}.{engine}.pdf"));
    if render == Render::Yes {
        let input = Path::new("usage").join(format!("INPUT-{id}.md"));
        if let Err(err) = render_one(root, engine, &d, &input, &out, Warnings::Deny) {
            println!("{:<70} RENDER FAILED: {}", format!("{dir}:{id}"), err.msg);
            return Ok(());
        }
    }
    let ex = measure::load(&d.join(exemplar))?;
    let us = measure::load(&out)?;
    let (g0, g2) = diff_content(&ex, &us, &Tol::load());
    let b = breaks::count(&ex, &us, 0);
    let d = &b.dev;
    let le = |x: f64| d.iter().filter(|&&v| v <= x + 1e-9).count();
    t.n += 1;
    t.g0 += usize::from(g0.is_empty());
    t.identical += b.identical;
    t.compared += b.compared;
    t.lines += b.lines;
    t.ss += b.same_start;
    t.ss_identical += b.same_start_identical;
    t.more += b.same_start_more;
    t.less += b.same_start_less;
    for (slot, n) in t.pos.iter_mut().zip([d.len(), le(0.05), le(0.25), le(1.0)]) {
        *slot += n;
    }
    println!(
        "{:<70} {:<5} {:<5} {:<22} {}/{} ({}, {})",
        format!("{dir}:{id}"),
        status(&g0),
        status(&g2),
        format!("{}/{} ({})", b.identical, b.compared, b.lines),
        b.same_start_identical,
        b.same_start,
        b.same_start_more,
        b.same_start_less
    );
    Ok(())
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let (mut engine, mut render, mut only) = ("typst".to_string(), Render::Yes, String::new());
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--engine" => engine = it.next().ok_or_else(|| fail(2, USAGE))?.clone(),
            "--no-render" => render = Render::No,
            s if s.starts_with("--") => return Err(fail(2, USAGE)),
            s => only = s.to_string(),
        }
    }
    let root = repo_root()?;
    let set = std::fs::read_to_string(root.join("data/calibration-set.json"))
        .map_err(|e| fail(2, format!("fb calibrate: data/calibration-set.json: {e}")))?;
    let set: Set = serde_json::from_str(&set).map_err(|e| fail(2, format!("fb calibrate: {e}")))?;
    println!(
        "{:<70} {:<5} {:<5} {:<22} same-start: identical/n (more, less)",
        "entry", "G0", "G2", "identical/compared(ex)"
    );
    let mut t = Totals::default();
    for e in set.entries.iter().filter(|e| e.dir.contains(&only)) {
        entry(&root, e, &engine, render, &mut t)?;
    }
    println!(
        "TOTAL {} entries, engine {engine}: G0 pass {}/{}; identical line breaks {}/{} compared lines ({} exemplar lines)",
        t.n, t.g0, t.n, t.identical, t.compared, t.lines
    );
    println!(
        "TOTAL same-start lines (composition only): {}/{} end alike; ours fits more on {}, less on {}",
        t.ss_identical, t.ss, t.more, t.less
    );
    println!(
        "TOTAL positions on identical same-start lines: {} lines; largest word-edge difference <= 0.05 pt on {}, <= 0.25 pt on {}, <= 1 pt on {}",
        t.pos[0], t.pos[1], t.pos[2], t.pos[3]
    );
    Ok(ExitCode::SUCCESS)
}
