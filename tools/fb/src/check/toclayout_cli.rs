//! `fb toc-layout [--footer-top PT] <pdf>...`: the DEF-TOC-001 analysis (toclayout.rs) on any PDF, for sweeps.
use super::{analyze, parse_runs, Run};
use crate::check::sh::io_fail;
use crate::{fail, repo_root, Res};
use std::process::{Command, ExitCode, Stdio};

/// runs.tsv of a PDF, as `fb check` prepares it (pdftohtml -xml -zoom 2 | pdf-runs.awk).
fn runs_of(pdf: &str) -> Res<Vec<Run>> {
    let awk = repo_root()?.join("tools/check/pdf-runs.awk");
    let tmp = crate::proc::TempDir::new("toc-runs")?;
    let xml = tmp.path().join("runs.xml");
    let run = |c: &mut Command, what: &str| {
        c.stdin(Stdio::null())
            .output()
            .map_err(|e| fail(2, format!("fb: cannot run {what}: {e}")))
    };
    let html = run(
        Command::new("pdftohtml").args(["-xml", "-zoom", "2", "-i", "-q", "-stdout", pdf]),
        "pdftohtml",
    )?;
    std::fs::write(&xml, &html.stdout).map_err(|e| io_fail(&xml.display().to_string(), e))?;
    let o = run(Command::new("gawk").arg("-f").arg(&awk).arg(&xml), "gawk")?;
    Ok(parse_runs(&String::from_utf8_lossy(&o.stdout)))
}

/// The default footer line of `fb toc-layout`: 720 pt on a letter page (1 in bottom margin), in proportion on
/// any other page height (pdfinfo's first page).
fn footer_top(pdf: &str) -> f64 {
    let info = Command::new("pdfinfo")
        .arg(pdf)
        .stdin(Stdio::null())
        .output();
    let height = info.ok().and_then(|o| {
        let text = String::from_utf8_lossy(&o.stdout).into_owned();
        let size = text
            .lines()
            .find_map(|l| l.strip_prefix("Page size:"))?
            .to_string();
        size.split_whitespace().nth(2)?.parse::<f64>().ok()
    });
    height.unwrap_or(792.0) * 720.0 / 792.0
}

/// `fb toc-layout [--footer-top PT] <pdf>...`: one line per PDF (OK, FAIL or NONE when it has no table), then
/// the findings. Exit 1 when any PDF fails.
pub fn main(args: &[String]) -> Res<ExitCode> {
    let mut ftop: Option<f64> = None;
    let mut pdfs = Vec::new();
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--footer-top" => {
                ftop = it
                    .next()
                    .and_then(|v| v.parse().ok())
                    .map(Some)
                    .ok_or_else(|| fail(2, "fb toc-layout: --footer-top PT"))?
            }
            _ => pdfs.push(a.clone()),
        }
    }
    if pdfs.is_empty() {
        return Err(fail(2, "usage: fb toc-layout [--footer-top PT] <pdf>..."));
    }
    let mut bad = false;
    for pdf in &pdfs {
        let ftop = ftop.unwrap_or_else(|| footer_top(pdf));
        let (pages, found) = analyze(pdf, &runs_of(pdf)?, ftop)?;
        let st = if pages.is_empty() {
            "NONE"
        } else if found.is_empty() {
            "OK"
        } else {
            "FAIL"
        };
        println!(
            "{st}\t{pdf}\t{} table pages, {} findings",
            pages.len(),
            found.len()
        );
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
