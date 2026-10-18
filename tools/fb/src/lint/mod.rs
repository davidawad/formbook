//! `fb lint <doc-dir> [--engine typst|latex|all]` checks a doc dir; `fb lint fonts` checks audited faces
//! globally; `fb lint paths` checks the usage/ layout under courts/ (see paths.rs).
//!   (a) ngram      a template file shares a run of 5+ words with a FILED-EXAMPLE's text, and the run
//!                  is not rule text (rules.md of the doc dir or an enclosing court folder);
//!   (b) break/vspace  forced line breaks or literal vertical space outside the parameter block
//!                  (typst/*.typ; the body of latex/*.tex);
//!   (c) hardbreak/raw-typst/raw-latex  in usage/INPUT-<id>.md;
//!   (d) path       the layout rule of `fb lint paths`, for the doc dir and the folders under it.
//! Output: `LINT <kind> <file>:<line>: <detail>` per finding, then `RESULT: LINT PASS` or
//! `RESULT: LINT FAIL (<n> findings)`; exit 1 on findings.
pub(crate) mod fonts;
mod input;
mod ngram;
pub(crate) mod paths;
mod tex;
mod typst;

use crate::{fail, Res};
use std::collections::HashSet;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const USAGE: &str = "usage: fb lint <doc-dir> [--engine typst|latex|all]";

#[derive(Debug, Clone, PartialEq)]
pub struct Finding {
    pub kind: &'static str,
    pub file: String,
    pub line: usize,
    pub detail: String,
}

impl std::fmt::Display for Finding {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "LINT {} {}:{}: {}",
            self.kind, self.file, self.line, self.detail
        )
    }
}

fn parse_opts(args: &[String]) -> Res<(PathBuf, String)> {
    let mut dir = None;
    let mut engine = "all".to_string();
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--engine" => engine = it.next().cloned().ok_or_else(|| fail(2, USAGE))?,
            s if s.starts_with("--") => {
                return Err(fail(2, format!("unknown option {s}\n{USAGE}")))
            }
            s if dir.is_none() => dir = Some(PathBuf::from(s)),
            _ => return Err(fail(2, USAGE)),
        }
    }
    match engine.as_str() {
        "typst" | "latex" | "all" => Ok((dir.ok_or_else(|| fail(2, USAGE))?, engine)),
        e => Err(fail(2, format!("unknown engine {e} (typst, latex, all)"))),
    }
}

/// Files of `dir` with one of the extensions, sorted.
fn files(dir: &Path, exts: &[&str]) -> Vec<PathBuf> {
    let mut v: Vec<PathBuf> = std::fs::read_dir(dir)
        .map(|rd| {
            rd.filter_map(|d| d.ok())
                .map(|d| d.path())
                .filter(|p| p.is_file())
                .filter(|p| p.extension().is_some_and(|e| exts.iter().any(|x| e == *x)))
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    v
}

/// The template files an engine choice covers.
fn templates(dir: &Path, engine: &str) -> Vec<PathBuf> {
    let mut v = Vec::new();
    if matches!(engine, "typst" | "all") {
        v.extend(files(&dir.join("typst"), &["typ"]));
    }
    if matches!(engine, "latex" | "all") {
        v.extend(files(&dir.join("latex"), &["tex", "lua"]));
    }
    if engine == "all" {
        v.extend(files(&dir.join("docx"), &["lua"]));
    }
    v
}

/// The doc dir and its ancestors up to (not including) the `courts` folder.
fn court_chain(dir: &Path) -> Vec<PathBuf> {
    let abs = std::fs::canonicalize(dir).unwrap_or_else(|_| dir.to_path_buf());
    abs.ancestors()
        .take_while(|d| {
            d.file_name().is_some_and(|n| n != "courts") && !d.join("data/index.json").is_file()
        })
        .map(Path::to_path_buf)
        .collect()
}

fn pdftotext(pdf: &Path) -> Res<String> {
    let out = Command::new("pdftotext")
        .arg("-layout")
        .arg(pdf)
        .arg("-")
        .output()
        .map_err(|e| fail(2, format!("fb lint: pdftotext: {e}")))?;
    match out.status.success() {
        true => Ok(String::from_utf8_lossy(&out.stdout).into_owned()),
        false => Err(fail(
            2,
            format!("fb lint: pdftotext failed on {}", pdf.display()),
        )),
    }
}

fn rel(dir: &Path, p: &Path) -> String {
    p.strip_prefix(dir)
        .unwrap_or(p)
        .to_string_lossy()
        .into_owned()
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    match args {
        [a] if a == "fonts" => return fonts::main(),
        [a] if a == "paths" => return paths::main(),
        _ => {}
    }
    let (dir, engine) = parse_opts(args)?;
    if !dir.is_dir() {
        return Err(fail(
            2,
            format!("fb lint: {} is not a directory", dir.display()),
        ));
    }
    let chain = court_chain(&dir);
    let mut exemplar = ngram::Corpus::default();
    let mut rules: HashSet<String> = HashSet::new();
    for d in &chain {
        let usage = d.join(crate::layout::USAGE_DIR);
        for pdf in crate::fetch::filed_pdfs(&usage) {
            exemplar.add(&pdftotext(&usage.join(pdf))?);
        }
        if let Ok(t) = std::fs::read_to_string(d.join("rules.md")) {
            rules.extend(ngram::grams(&t));
        }
    }
    let mut found: Vec<Finding> = Vec::new();
    for p in templates(&dir, &engine) {
        let text = std::fs::read_to_string(&p)
            .map_err(|e| fail(2, format!("fb lint: {}: {e}", p.display())))?;
        let name = rel(&dir, &p);
        found.extend(ngram::check(&name, &text, &exemplar, &rules));
        match p.extension().and_then(|e| e.to_str()) {
            Some("typ") => found.extend(typst::check(&name, &text)),
            Some("tex") => found.extend(tex::check(&name, &text)),
            _ => {}
        }
    }
    let doc = crate::layout::Doc::open(&dir)?;
    for id in doc.ids(crate::layout::INPUT) {
        let p = doc.input(&id);
        let text = std::fs::read_to_string(&p)
            .map_err(|e| fail(2, format!("fb lint: {}: {e}", p.display())))?;
        found.extend(input::check(&rel(&dir, &p), &text));
    }
    found.iter().for_each(|f| println!("{f}"));
    let (_, path_findings) =
        paths::check_tree(&dir, &dir, &paths::known_doctypes(&crate::repo_root()?));
    path_findings.iter().for_each(|f| println!("{f}"));
    let total = found.len() + path_findings.len();
    match total {
        0 => {
            println!("RESULT: LINT PASS");
            Ok(ExitCode::SUCCESS)
        }
        n => {
            println!("RESULT: LINT FAIL ({n} findings)");
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn options_and_format() {
        let a = |v: &[&str]| v.iter().map(|s| s.to_string()).collect::<Vec<_>>();
        assert_eq!(
            parse_opts(&a(&["d"])).unwrap(),
            (PathBuf::from("d"), "all".into())
        );
        assert_eq!(
            parse_opts(&a(&["d", "--engine", "latex"])).unwrap().1,
            "latex"
        );
        assert!(parse_opts(&a(&["d", "--engine", "docx"])).is_err());
        assert!(parse_opts(&a(&[])).is_err());
        let f = Finding {
            kind: "vspace",
            file: "typst/a.typ".into(),
            line: 3,
            detail: "x".into(),
        };
        assert_eq!(f.to_string(), "LINT vspace typst/a.typ:3: x");
    }
}
