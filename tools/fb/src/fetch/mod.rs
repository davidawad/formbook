//! `fb fetch <doc-dir> [--all-missing-only] [--record]`: download the filed examples usage/SOURCE.md names
//! and verify every FILED-EXAMPLE's SHA-256 against SOURCE.md.
//!
//! A missing PDF is downloaded with curl (to a temporary name, kept only when it is a PDF and its hash
//! matches the recorded one; an unrecorded hash is written into SOURCE.md). A PDF on disk is checked:
//! OK, MISMATCH or UNRECORDED (`--record` writes the hash). `--all-missing-only` skips the PDFs already
//! on disk. One line per exemplar; exit 1 on any mismatch or failed download.
mod source;

use crate::check::stamp::sha256;
use crate::{fail, Res};
use source::Entry;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const USAGE: &str = "usage: fb fetch <doc-dir> [--all-missing-only] [--record]";

struct Opts {
    dir: PathBuf,
    missing_only: bool,
    record: bool,
}

fn parse_opts(args: &[String]) -> Res<Opts> {
    let mut dir = None;
    let mut o = Opts {
        dir: PathBuf::new(),
        missing_only: false,
        record: false,
    };
    for a in args {
        match a.as_str() {
            "--all-missing-only" | "--missing-only" => o.missing_only = true,
            "--record" => o.record = true,
            s if s.starts_with("--") => {
                return Err(fail(2, format!("fb fetch: unknown option {s}\n{USAGE}")))
            }
            s if dir.is_none() => dir = Some(PathBuf::from(s)),
            _ => return Err(fail(2, USAGE)),
        }
    }
    o.dir = dir.ok_or_else(|| fail(2, USAGE))?;
    Ok(o)
}

/// The outcome for one exemplar: the printed line and whether it is a failure.
struct Line {
    status: &'static str,
    name: String,
    detail: String,
}

impl Line {
    fn bad(&self) -> bool {
        matches!(self.status, "MISMATCH" | "FAILED" | "NOURL" | "EXCERPT")
    }
}

fn line(status: &'static str, name: &str, detail: impl Into<String>) -> Line {
    Line {
        status,
        name: name.to_string(),
        detail: detail.into(),
    }
}

/// curl the URL to `tmp`; Ok only for a PDF.
fn download(url: &str, tmp: &Path) -> Result<(), String> {
    let out = Command::new("curl")
        .args(["-fsSL", "--retry", "2", "-o"])
        .arg(tmp)
        .arg(url)
        .output()
        .map_err(|e| format!("curl: {e}"))?;
    if !out.status.success() {
        let msg = String::from_utf8_lossy(&out.stderr).trim().to_string();
        return Err(format!(
            "curl exit {}: {msg}",
            out.status.code().unwrap_or(-1)
        ));
    }
    let head = std::fs::read(tmp).map_err(|e| e.to_string())?;
    match head.starts_with(b"%PDF") {
        true => Ok(()),
        false => Err("not a PDF (no %PDF header)".into()),
    }
}

/// Fetch or verify one exemplar; a newly learned hash is written into `text`.
fn one(o: &Opts, ex: &Path, e: &Entry, text: &mut String) -> Line {
    let path = ex.join(&e.name);
    let present = path.is_file();
    if present && o.missing_only {
        return line("PRESENT", &e.name, "skipped (--all-missing-only)");
    }
    if present {
        let got = sha256(&path.to_string_lossy());
        return match (&e.sha, o.record) {
            (Some(_), _) if e.shas.contains(&got) => line("OK", &e.name, got),
            (Some(_), _) => line(
                "MISMATCH",
                &e.name,
                format!("on disk {got}, SOURCE.md {}", e.shas.join(" or ")),
            ),
            (None, true) => {
                *text = source::record_sha(text, e, &got);
                line("RECORDED", &e.name, got)
            }
            (None, false) => line("UNRECORDED", &e.name, format!("{got} (--record writes it)")),
        };
    }
    if !e.listed {
        return line(
            "ABSENT",
            &e.name,
            "mentioned in SOURCE.md without a record of its own; not on disk",
        );
    }
    let Some(url) = &e.url else {
        return line(
            "NOURL",
            &e.name,
            "missing on disk and SOURCE.md gives no URL",
        );
    };
    let tmp = ex.join(format!(".fetch-{}.part", e.name));
    let res = download(url, &tmp).and_then(|()| {
        let got = sha256(&tmp.to_string_lossy());
        match &e.sha {
            Some(_) if !e.shas.contains(&got) => {
                Err(format!("MISMATCH downloaded {got}, SOURCE.md {}", e.shas.join(" or ")))
            }
            None if e.excerpt => Err(format!(
                "EXCERPT SOURCE.md describes an excerpt; the download ({got}) is the whole filing: cut the pages as SOURCE.md says"
            )),
            _ => std::fs::rename(&tmp, &path)
                .map(|()| got)
                .map_err(|err| format!("rename: {err}")),
        }
    });
    let _ = std::fs::remove_file(&tmp);
    match (res, &e.sha) {
        (Ok(got), Some(_)) if e.shas.len() > 1 => line(
            "FETCHED",
            &e.name,
            format!(
                "{got} OK {url} (SOURCE.md records {} hashes: is the exemplar an extract?)",
                e.shas.len()
            ),
        ),
        (Ok(got), Some(_)) => line("FETCHED", &e.name, format!("{got} OK {url}")),
        (Ok(got), None) => {
            *text = source::record_sha(text, e, &got);
            line("FETCHED", &e.name, format!("{got} RECORDED {url}"))
        }
        (Err(m), _) if m.starts_with("MISMATCH") => {
            line("MISMATCH", &e.name, format!("{} ({url})", &m[9..]))
        }
        (Err(m), _) if m.starts_with("EXCERPT") => {
            line("EXCERPT", &e.name, format!("{} ({url})", &m[8..]))
        }
        (Err(m), _) => line("FAILED", &e.name, format!("{m} ({url})")),
    }
}

/// FILED-EXAMPLE-*.pdf files in a usage/ directory, sorted.
pub fn filed_pdfs(ex: &Path) -> Vec<String> {
    let mut v: Vec<String> = std::fs::read_dir(ex)
        .map(|rd| {
            rd.filter_map(|d| d.ok())
                .map(|d| d.file_name().to_string_lossy().into_owned())
                .filter(|n| n.starts_with("FILED-EXAMPLE-") && n.ends_with(".pdf"))
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    v
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let o = parse_opts(args)?;
    let ex = o.dir.join(crate::layout::USAGE_DIR);
    let src = ex.join("SOURCE.md");
    let orig = std::fs::read_to_string(&src)
        .map_err(|e| fail(2, format!("fb fetch: {}: {e}", src.display())))?;
    let entries = source::parse(&orig);
    if entries.is_empty() {
        println!(
            "{} names no FILED-EXAMPLE-*.pdf: nothing to fetch",
            src.display()
        );
    }
    let mut text = orig.clone();
    let mut lines: Vec<Line> = Vec::new();
    for e in &entries {
        // reparse so a hash written for an earlier entry does not shift this entry's anchor
        let cur = source::parse(&text)
            .into_iter()
            .find(|x| x.name == e.name)
            .unwrap_or_else(|| e.clone());
        lines.push(one(&o, &ex, &cur, &mut text));
    }
    for n in filed_pdfs(&ex) {
        if !entries.iter().any(|e| e.name == n) {
            lines.push(line("UNLISTED", &n, "on disk but not named in SOURCE.md"));
        }
    }
    if text != orig {
        std::fs::write(&src, &text)
            .map_err(|e| fail(2, format!("fb fetch: {}: {e}", src.display())))?;
    }
    for l in &lines {
        println!("{:<10} {}  {}", l.status, l.name, l.detail);
    }
    let bad = lines.iter().filter(|l| l.bad()).count();
    match bad {
        0 => {
            println!("RESULT: FETCH PASS ({} exemplars)", entries.len());
            Ok(ExitCode::SUCCESS)
        }
        n => {
            println!("RESULT: FETCH FAIL ({n} of {} exemplars)", entries.len());
            Ok(ExitCode::from(1))
        }
    }
}
