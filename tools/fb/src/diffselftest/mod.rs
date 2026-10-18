//! `fb diff-selftest <doc-dir> [--engine typst|latex] [--sample <id>] [--write-tolerance]`: is `fb diff`
//! blind to anything? Builds a sample twice (the difference is the measurement noise the tolerance is made
//! of), checks the two builds diff clean, then makes one deliberate break at a time and requires the diff
//! to fail:
//!
//!   margin+0.05in      every page shifted right by 3.6 pt
//!   spacing-x1.02      every page stretched vertically by 2% from the first baseline
//!   size+0.5pt         every page scaled by (s + 0.5) / s, s the most common type size
//!   size-0.5pt         the same, smaller
//!   drop-paragraph     a body paragraph deleted from the markdown, re-rendered by the template
//!   swap-paragraphs    two body paragraphs exchanged in the markdown, re-rendered
//!   forced-line-break  a hard line break (backslash) inserted in a paragraph, re-rendered
//!
//! The page-level breaks redraw the built PDF's pages inside a typst wrapper; an identity wrap must diff
//! clean (control), so whatever the mutants trip on is the mutation. `--write-tolerance` records the
//! measured noise in tools/fb/tolerance.json (tolerance = largest noise of any engine, never below the
//! 0.01 pt measurement resolution).
mod mutate;
mod noise;

use crate::diff::{diff_measured, Report, Tol};
use crate::layout::{self, Doc};
use crate::measure::{self, Measured};
use crate::{fail, Res};
use mutate::{Block, Warp};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

struct Opts {
    doc: PathBuf,
    engine: String,
    sample: Option<String>,
    write_tol: bool,
}

fn opts(args: &[String]) -> Res<Opts> {
    let usage = "usage: fb diff-selftest <doc-dir> [--engine typst|latex] [--sample <id>] [--write-tolerance]";
    let mut o = Opts {
        doc: PathBuf::new(),
        engine: "typst".into(),
        sample: None,
        write_tol: false,
    };
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--engine" => o.engine = it.next().ok_or_else(|| fail(2, usage))?.clone(),
            "--sample" => o.sample = it.next().cloned(),
            "--write-tolerance" => o.write_tol = true,
            s if !s.starts_with('-') && o.doc.as_os_str().is_empty() => o.doc = PathBuf::from(s),
            _ => return Err(fail(2, usage)),
        }
    }
    if o.doc.as_os_str().is_empty() || !["typst", "latex"].contains(&o.engine.as_str()) {
        return Err(fail(2, usage));
    }
    o.doc = std::fs::canonicalize(&o.doc)
        .map_err(|e| fail(2, format!("fb: {}: {e}", o.doc.display())))?;
    Ok(o)
}

fn io(p: &Path, e: std::io::Error) -> crate::Fail {
    fail(2, format!("fb: {}: {e}", p.display()))
}

/// Render `md` (relative to the doc dir) with the engine through tools/render.sh.
fn render(root: &Path, o: &Opts, md: &str, out: &Path) -> Res<()> {
    let mut c = Command::new("sh");
    c.arg(root.join("tools/render.sh"))
        .args(["--engine", &o.engine])
        .arg(&o.doc)
        .arg(md)
        .arg(out);
    let r = c
        .output()
        .map_err(|e| fail(2, format!("fb: render.sh: {e}")))?;
    if !r.status.success() || !out.is_file() {
        return Err(fail(
            2,
            format!(
                "fb: render of {md} failed: {}",
                String::from_utf8_lossy(&r.stderr).trim()
            ),
        ));
    }
    Ok(())
}

/// A mutated markdown written into usage/ next to the inputs (the template's root is the doc dir) and removed again.
struct TempMd(PathBuf);
impl Drop for TempMd {
    fn drop(&mut self) {
        let _ = std::fs::remove_file(&self.0);
    }
}

fn warp(scratch: &Path, base: &Measured, name: &str, w: Warp) -> Res<PathBuf> {
    let sizes: Vec<(f64, f64)> = base.pages.iter().map(|p| (p.w, p.h)).collect();
    let typ = scratch.join(format!("{name}.typ"));
    let out = scratch.join(format!("{name}.pdf"));
    std::fs::write(&typ, mutate::wrapper("base-a.pdf", &sizes, w)).map_err(|e| io(&typ, e))?;
    let r = Command::new("typst")
        .arg("compile")
        .arg("--root")
        .arg(scratch)
        .arg("--ignore-system-fonts")
        .arg(&typ)
        .arg(&out)
        .output()
        .map_err(|e| fail(2, format!("fb: typst: {e}")))?;
    if !r.status.success() {
        return Err(fail(
            2,
            format!(
                "fb: wrap {name}: {}",
                String::from_utf8_lossy(&r.stderr).trim()
            ),
        ));
    }
    Ok(out)
}

/// Most common type size of the document's lines (by line count).
fn body_size(m: &Measured) -> f64 {
    measure::mode_of(
        m.pages
            .iter()
            .flat_map(|p| p.lines.iter())
            .filter(|l| l.size > 0.0)
            .map(|l| (l.size, 1.0)),
    )
    .unwrap_or(12.0)
}

fn verdict(name: &str, r: &Report, want_pass: bool) -> bool {
    let first = r.findings.first().map_or("", String::as_str);
    match (r.pass, want_pass) {
        (true, true) => println!("clean    {name}  (G0-G4 pass)"),
        (false, false) => println!("caught   {name}  at {}: {first}", r.gate),
        (true, false) => println!("MISSED   {name}  (diff passed)"),
        (false, true) => println!("FALSE    {name}  failed at {}: {first}", r.gate),
    }
    r.pass == want_pass
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let o = opts(args)?;
    let root = crate::repo_root()?;
    let rel = o
        .doc
        .strip_prefix(&root)
        .unwrap_or(&o.doc)
        .to_string_lossy()
        .replace('/', "_");
    let scratch = root.join("out/diff-selftest").join(rel).join(&o.engine);
    std::fs::create_dir_all(&scratch).map_err(|e| io(&scratch, e))?;
    let doc = Doc::open(&o.doc)?;
    let sample = match &o.sample {
        Some(s) => s.clone(),
        None => first_sample(&doc)?,
    };
    let md = Doc::rel(&layout::input_name(&sample));
    let src = std::fs::read_to_string(o.doc.join(&md)).map_err(|e| io(&o.doc.join(&md), e))?;
    println!(
        "diff-selftest {} sample {sample} engine {}",
        o.doc.display(),
        o.engine
    );

    // Noise: the same input built twice.
    let (pa, pb) = (scratch.join("base-a.pdf"), scratch.join("base-b.pdf"));
    render(&root, &o, &md, &pa)?;
    render(&root, &o, &md, &pb)?;
    let a = measure::measure(&pa, &[])?;
    let b = measure::measure(&pb, &[])?;
    let n = noise::noise(&a, &b).map_err(|e| {
        fail(
            1,
            format!("fb: two builds of {sample} differ in structure: {e}"),
        )
    })?;
    println!("noise    rebuild of {sample}: {n} pt");
    if o.write_tol {
        write_tolerance(&root, &o, &sample, n)?;
    }
    let tol = Tol::load();
    if n > tol.pt {
        return Err(fail(1, format!("fb: measured noise {n} pt exceeds the tolerance {} pt; rerun with --write-tolerance", tol.pt)));
    }
    println!("tolerance {} pt ({})", tol.pt, tol.source);
    let mut ok = verdict("rebuild", &diff_measured(&a, &b, &tol), true);

    // Page-level mutants, after the identity-wrap control.
    let f = a
        .pages
        .iter()
        .find_map(|p| p.frame)
        .ok_or_else(|| fail(1, "fb: the sample has no text"))?;
    let s = body_size(&a);
    let about = |k: f64| Warp {
        sx: k,
        sy: k,
        ox: f.left,
        oy: f.top,
        ..Warp::IDENTITY
    };
    let warps = [
        ("identity-wrap", Warp::IDENTITY, true),
        (
            "margin+0.05in",
            Warp {
                dx: 3.6,
                ..Warp::IDENTITY
            },
            false,
        ),
        (
            "spacing-x1.02",
            Warp {
                sy: 1.02,
                oy: f.top,
                ..Warp::IDENTITY
            },
            false,
        ),
        ("size+0.5pt", about((s + 0.5) / s), false),
        ("size-0.5pt", about((s - 0.5) / s), false),
    ];
    for (name, w, want) in warps {
        let p = warp(&scratch, &a, name, w)?;
        ok &= verdict(
            name,
            &diff_measured(&a, &measure::measure(&p, &[])?, &tol),
            want,
        );
    }

    // Content mutants, rendered by the court's template.
    let paras: Vec<Block> = mutate::paragraphs(&src, 25);
    let mid = paras.len() / 2;
    let (Some(&p1), Some(&p2)) = (paras.get(mid), paras.get(mid + 1)) else {
        return Err(fail(
            1,
            format!("fb: {md} has fewer than two body paragraphs of 25+ words"),
        ));
    };
    let content = [
        ("drop-paragraph", mutate::drop(&src, p1)),
        ("swap-paragraphs", mutate::swap(&src, p1, p2)),
        ("forced-line-break", mutate::force_break(&src, p1, 6)),
    ];
    for (name, text) in content {
        let rel_md = Doc::rel(&format!(".diff-selftest-{name}.md"));
        let tmp = TempMd(o.doc.join(&rel_md));
        std::fs::write(&tmp.0, text).map_err(|e| io(&tmp.0, e))?;
        let out = scratch.join(format!("{name}.pdf"));
        render(&root, &o, &rel_md, &out)?;
        drop(tmp);
        ok &= verdict(
            name,
            &diff_measured(&a, &measure::measure(&out, &[])?, &tol),
            false,
        );
    }
    println!();
    if ok {
        println!("SELFTEST OK: every mutant was caught and the controls diff clean");
        Ok(ExitCode::SUCCESS)
    } else {
        println!("SELFTEST FAILED");
        Ok(ExitCode::from(1))
    }
}

fn first_sample(doc: &Doc) -> Res<String> {
    doc.ids(layout::INPUT).into_iter().next().ok_or_else(|| {
        fail(
            2,
            format!(
                "fb: no {} in {}",
                Doc::rel(&layout::input_name("*")),
                doc.dir.display()
            ),
        )
    })
}

/// Civil date (UTC) of now, for the tolerance record.
fn today() -> String {
    let secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |d| d.as_secs()) as i64;
    let z = secs.div_euclid(86_400) + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = yoe + era * 400 + i64::from(m <= 2);
    format!("{y:04}-{m:02}-{d:02}")
}

fn write_tolerance(root: &Path, o: &Opts, sample: &str, n: f64) -> Res<()> {
    let file = root.join("tools/fb/tolerance.json");
    let mut v: serde_json::Value = std::fs::read_to_string(&file)
        .ok()
        .and_then(|t| serde_json::from_str(&t).ok())
        .unwrap_or_else(|| serde_json::json!({}));
    let doc = o
        .doc
        .strip_prefix(root)
        .unwrap_or(&o.doc)
        .display()
        .to_string();
    v["noise"][&o.engine] =
        serde_json::json!({"pt": n, "doc": doc, "sample": sample, "date": today()});
    let worst = v["noise"]
        .as_object()
        .map(|m| {
            m.values()
                .filter_map(|e| e["pt"].as_f64())
                .fold(0.0, f64::max)
        })
        .unwrap_or(n);
    v["pt"] = serde_json::json!(measure::r2(worst.max(measure::RES)));
    v["source"] = serde_json::json!(
        "fb diff-selftest --write-tolerance: largest coordinate difference between two builds of the same sample, per engine (see noise), never below the 0.01 pt measurement resolution"
    );
    let text = serde_json::to_string_pretty(&v).map_err(|e| fail(2, format!("fb: {e}")))? + "\n";
    std::fs::write(&file, text).map_err(|e| io(&file, e))?;
    println!("wrote    {} (pt {})", file.display(), v["pt"]);
    Ok(())
}

#[cfg(test)]
mod tests {
    #[test]
    fn today_is_a_date() {
        let d = super::today();
        assert_eq!(d.len(), 10);
        assert!(d.starts_with("20"));
    }
}
