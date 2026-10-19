//! `fb eval [DIR] [--jobs N] [--no-tracker]`: run `fb check` over every doc folder with an INPUT under DIR
//! (default `courts`), then regenerate the tracker so newly passing folders become "up for review".
//! Folders with their own checks.yaml are left to their own loop (`just check`). Exit 0 whatever the verdicts are.
use crate::layout::{Doc, INPUT};
use crate::{fail, repo_root, Res};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Mutex;

/// Subfolders that are never doc folders.
const SKIP: [&str; 5] = ["typst", "latex", "docx", "usage", "reviews"];

/// Every folder under `dir` (itself included) that holds a usage/INPUT-<id>.md, sorted.
fn doc_folders(dir: &Path) -> Vec<PathBuf> {
    let here = Doc::open(dir)
        .map(|d| !d.ids(INPUT).is_empty())
        .unwrap_or(false)
        .then(|| dir.to_path_buf());
    let mut subs: Vec<PathBuf> = std::fs::read_dir(dir)
        .map(|rd| {
            rd.filter_map(Result::ok)
                .filter(|e| e.file_type().is_ok_and(|t| t.is_dir()))
                .filter(|e| {
                    let n = e.file_name().to_string_lossy().into_owned();
                    !n.starts_with('.') && !SKIP.contains(&n.as_str())
                })
                .map(|e| e.path())
                .collect()
        })
        .unwrap_or_default();
    subs.sort();
    here.into_iter()
        .chain(subs.iter().flat_map(|s| doc_folders(s)))
        .collect()
}

/// The check ids a run printed as FAIL (a failed run that printed none is an error, with its last stderr line).
fn failures(stdout: &str, stderr: &str) -> Vec<String> {
    let ids: Vec<String> = stdout
        .lines()
        .filter_map(|l| l.strip_prefix("  FAIL "))
        .filter_map(|l| l.split_whitespace().next())
        .map(|id| id.trim_end_matches(':').to_string())
        .collect();
    match ids.is_empty() {
        false => ids,
        true => vec![format!(
            "ERROR: {}",
            stderr.lines().last().unwrap_or("fb check exited non-zero")
        )],
    }
}

/// (folder, failed check ids; empty = pass)
type Verdict = (PathBuf, Vec<String>);

fn run_one(exe: &Path, root: &Path, dir: &Path) -> Verdict {
    let o = Command::new(exe)
        .arg("check")
        .arg(dir)
        .env("FB_ROOT", root)
        .output();
    let ids = match o {
        Ok(o) if o.status.success() => vec![],
        Ok(o) => failures(
            &String::from_utf8_lossy(&o.stdout),
            &String::from_utf8_lossy(&o.stderr),
        ),
        Err(e) => vec![format!("ERROR: {e}")],
    };
    (dir.to_path_buf(), ids)
}

/// Failing folders per check id, most common first.
pub fn breakdown(verdicts: &[Verdict]) -> Vec<(String, usize)> {
    let m = verdicts
        .iter()
        .flat_map(|(_, ids)| {
            let mut u = ids.clone();
            u.sort();
            u.dedup();
            u
        })
        .fold(BTreeMap::<String, usize>::new(), |mut m, id| {
            *m.entry(id).or_default() += 1;
            m
        });
    let mut v: Vec<_> = m.into_iter().collect();
    v.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    v
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let usage = "usage: fb eval [DIR] [--jobs N] [--no-tracker]";
    let (mut jobs, mut tracker, mut dir) = (4usize, true, None);
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--jobs" => {
                jobs = it
                    .next()
                    .and_then(|n| n.parse().ok())
                    .filter(|n| *n > 0)
                    .ok_or_else(|| fail(2, usage))?
            }
            "--no-tracker" => tracker = false,
            d if dir.is_none() && !d.starts_with("--") => dir = Some(d.to_string()),
            _ => return Err(fail(2, usage)),
        }
    }
    let root = repo_root()?;
    let start = dir.map_or_else(|| root.join("courts"), |d| root.join(d));
    let start = std::fs::canonicalize(&start)
        .map_err(|e| fail(2, format!("fb eval: {}: {e}", start.display())))?;
    let (own, folders): (Vec<_>, Vec<_>) = doc_folders(&start)
        .into_iter()
        .partition(|d| d.join("checks.yaml").is_file());
    let exe = std::env::current_exe().map_err(|e| fail(2, format!("fb eval: {e}")))?;
    let next = AtomicUsize::new(0);
    let done: Mutex<Vec<Verdict>> = Mutex::new(vec![]);
    std::thread::scope(|s| {
        (0..jobs).for_each(|_| {
            s.spawn(|| {
                while let Some(d) = folders.get(next.fetch_add(1, Ordering::SeqCst)) {
                    let v = run_one(&exe, &root, d);
                    let rel =
                        v.0.strip_prefix(&root)
                            .unwrap_or(&v.0)
                            .display()
                            .to_string();
                    let mut g = done.lock().unwrap_or_else(|e| e.into_inner());
                    let verdict = match v.1.is_empty() {
                        true => "PASS".to_string(),
                        false => format!("FAIL {}", v.1.join(" ")),
                    };
                    println!("{verdict}  {rel}");
                    g.push(v);
                }
            });
        });
    });
    let mut verdicts = done.into_inner().unwrap_or_else(|e| e.into_inner());
    verdicts.sort();
    let passed = verdicts.iter().filter(|(_, f)| f.is_empty()).count();
    println!(
        "\neval: {} folders evaluated, {passed} passed, {} failed; {} skipped (own checks.yaml: run `just check`)",
        verdicts.len(),
        verdicts.len() - passed,
        own.len()
    );
    breakdown(&verdicts)
        .iter()
        .for_each(|(id, n)| println!("  {n:4} folders fail {id}"));
    match tracker {
        true => crate::track::main(&[]),
        false => Ok(ExitCode::SUCCESS),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fail_ids() {
        let out = "x\n  FAIL  DEF-FORM-001   every page\n          measured: a\n  FAIL  DEF-CONT-001 y\n  PASS  DEF-FONT-001 z\n";
        assert_eq!(failures(out, ""), ["DEF-FORM-001", "DEF-CONT-001"]);
        assert_eq!(failures("", "a\nboom"), ["ERROR: boom"]);
    }

    #[test]
    fn counts() {
        let v = vec![
            (PathBuf::from("a"), vec!["B".to_string(), "A".to_string()]),
            (PathBuf::from("b"), vec!["A".to_string(), "A".to_string()]),
            (PathBuf::from("c"), vec![]),
        ];
        assert_eq!(breakdown(&v), [("A".to_string(), 2), ("B".to_string(), 1)]);
    }
}
