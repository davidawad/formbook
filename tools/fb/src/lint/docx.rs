//! `fb lint docx [file.docx ...]`: DEF-DOCX-OPEN (docxopen.rs) over every committed `courts/**/usage/OUTPUT-*.docx`
//! (or the files named). A .docx is a shipped deliverable; one that does not open is a broken download. Committed
//! `docx/reference.docx` files are also linted: a per-section footnote restart makes LibreOffice number notes
//! incorrectly. With no files it also runs `docx-rid` (docxrid.rs) over every docx folder: no filter names a
//! relationship id pandoc may renumber (`LINT docx-rid <file>:<line>: ..`).
//! Output: `LINT docx-open <file>: <problem>` per finding, then `RESULT: LINT DOCX PASS (<n> files)` or
//! `RESULT: LINT DOCX FAIL (<k> findings in <m> files)`; exit 1 on findings.
use crate::proc::TempDir;
use crate::{docxopen, repo_root, Res};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

/// Every usage/OUTPUT-*.docx under `dir`, sorted.
pub fn outputs(dir: &Path) -> Vec<PathBuf> {
    let mut out = Vec::new();
    let mut stack = vec![dir.to_path_buf()];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            let name = e.file_name().to_string_lossy().into_owned();
            if p.is_dir() && !name.starts_with('.') {
                stack.push(p);
            } else if is_output(&p) {
                out.push(p);
            }
        }
    }
    out.sort();
    out
}

fn is_output(p: &Path) -> bool {
    let name = p.file_name().map(|n| n.to_string_lossy().into_owned());
    let in_usage = p
        .parent()
        .and_then(Path::file_name)
        .is_some_and(|n| n == crate::layout::USAGE_DIR);
    in_usage && name.is_some_and(|n| n.starts_with("OUTPUT-") && n.ends_with(".docx"))
}

/// The findings for `files`, as (file, problem).
pub fn findings(files: &[PathBuf]) -> Res<Vec<(PathBuf, String)>> {
    let work = TempDir::new("lint-docx")?;
    let mut found = Vec::new();
    for f in files {
        for p in docxopen::package(f, work.path())? {
            found.push((f.clone(), p));
        }
    }
    let ok = docxopen::converts(files, work.path())?;
    for (f, converted) in files.iter().zip(ok) {
        if !converted {
            found.push((
                f.clone(),
                "LibreOffice cannot load it (soffice --headless --convert-to pdf wrote no PDF)"
                    .into(),
            ));
        }
    }
    found.sort();
    Ok(found)
}

fn references(dir: &Path) -> Vec<PathBuf> {
    let mut found = Vec::new();
    let mut stack = vec![dir.to_path_buf()];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                if e.file_name() == "docx" {
                    let reference = p.join("reference.docx");
                    if reference.is_file() {
                        found.push(reference);
                    }
                } else if !e.file_name().to_string_lossy().starts_with('.') {
                    stack.push(p);
                }
            }
        }
    }
    found.sort();
    found
}

fn restarts_each_section(settings: &str) -> bool {
    settings.contains("<w:numRestart w:val=\"eachSect\"")
        || settings.contains("<w:numRestart w:val='eachSect'")
}

fn reference_findings(files: &[PathBuf]) -> Res<Vec<(PathBuf, String)>> {
    let mut found = Vec::new();
    for f in files {
        let mut each_section = false;
        let mut unreadable = None;
        for part in ["word/settings.xml", "word/document.xml"] {
            let output = crate::proc::capture(
                std::process::Command::new("unzip")
                    .args(["-p"])
                    .arg(f)
                    .arg(part),
            )?;
            if !output.status.success() {
                unreadable = Some(part);
                continue;
            }
            each_section |= restarts_each_section(&String::from_utf8_lossy(&output.stdout));
        }
        if let Some(part) = unreadable {
            found.push((f.clone(), format!("cannot read {part} from reference.docx")));
        }
        if each_section {
            found.push((f.clone(), "reference.docx restarts footnote numbering each section (w:numRestart w:val=\"eachSect\"); remove w:numRestart".into()));
        }
    }
    Ok(found)
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let root = repo_root()?;
    let (files, refs, rids) = match args {
        [] => (
            outputs(&root.join("courts")),
            references(&root.join("courts")),
            super::docxrid::check_repo(&root)?,
        ),
        named => {
            let (refs, files): (Vec<_>, Vec<_>) = named
                .iter()
                .map(PathBuf::from)
                .partition(|f| f.file_name().is_some_and(|n| n == "reference.docx"));
            (files, refs, vec![])
        }
    };
    let mut found = findings(&files)?;
    found.extend(reference_findings(&refs)?);
    for (f, p) in &found {
        let shown = f.strip_prefix(&root).unwrap_or(f);
        let kind = if f.file_name().is_some_and(|n| n == "reference.docx") {
            "docx-reference"
        } else {
            "docx-open"
        };
        println!("LINT {kind} {}: {p}", shown.display());
    }
    rids.iter().for_each(|f| println!("{f}"));
    if !rids.is_empty() {
        println!(
            "RESULT: LINT DOCX FAIL ({} filters or references name a relationship id pandoc may renumber)",
            rids.len()
        );
        return Ok(ExitCode::from(1));
    }
    let bad: std::collections::BTreeSet<_> = found.iter().map(|(f, _)| f).collect();
    match found.len() {
        0 => {
            println!("RESULT: LINT DOCX PASS ({} files)", files.len());
            Ok(ExitCode::SUCCESS)
        }
        k => {
            println!(
                "RESULT: LINT DOCX FAIL ({k} findings in {} of {} files)",
                bad.len(),
                files.len()
            );
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn only_usage_outputs_count() {
        assert!(is_output(Path::new(
            "courts/x/usage/OUTPUT-opening-brief.docx"
        )));
        assert!(!is_output(Path::new("courts/x/docx/reference.docx")));
        assert!(!is_output(Path::new(
            "courts/x/usage/OUTPUT-opening-brief.docx.pdf"
        )));
        assert!(!is_output(Path::new(
            "courts/x/usage/FILED-EXAMPLE-opening-brief.docx"
        )));
    }

    #[test]
    fn catches_each_section_footnote_restart() {
        assert!(restarts_each_section(
            "<w:footnotePr><w:numRestart w:val=\"eachSect\"/></w:footnotePr>"
        ));
        assert!(restarts_each_section(
            "<w:footnotePr><w:numRestart w:val='eachSect'/></w:footnotePr>"
        ));
        assert!(restarts_each_section(
            "<w:sectPr><w:footnotePr><w:numRestart w:val=\"eachSect\"/></w:footnotePr></w:sectPr>"
        ));
        assert!(!restarts_each_section(
            "<w:footnotePr><w:numRestart w:val=\"eachPage\"/></w:footnotePr>"
        ));
        assert!(!restarts_each_section(
            "<w:footnotePr><w:footnote w:id=\"0\"/></w:footnotePr>"
        ));
    }
}
