//! `fb check-changed [--base <ref>]`: run `fb check --no-render` on every engine of every court doc folder a
//! branch touches, so a landing gate (the declared quality command) refuses a court change whose committed
//! outputs fail. A doc folder is the nearest ancestor (under courts/) of a changed path that holds `usage/`;
//! its engines are whichever of typst/, latex/ and docx/ it has. Folders the branch deleted are skipped.
//! Exit 0 only when every check passes (or nothing under courts/ changed).

use crate::{fail, Res};
use std::collections::BTreeSet;
use std::path::Path;
use std::process::{Command, ExitCode};

const USAGE: &str = "usage: fb check-changed [--base <ref>]   (default base: origin/master)";
const ENGINES: [&str; 3] = ["typst", "latex", "docx"];

/// The doc folders of `paths` (repo-relative), given `is_doc(dir)`: does `dir` hold a usage/ folder.
pub fn doc_folders<F: Fn(&str) -> bool>(paths: &[String], is_doc: F) -> BTreeSet<String> {
    paths
        .iter()
        .filter(|p| p.starts_with("courts/"))
        .filter_map(|p| {
            Path::new(p)
                .ancestors()
                .skip(1)
                .map(|a| a.to_string_lossy().into_owned())
                .take_while(|a| a.starts_with("courts/"))
                .find(|a| is_doc(a))
        })
        .collect()
}

/// The (folder, engine) pairs to check: every engine directory the folder has.
pub fn jobs<F: Fn(&str) -> bool>(
    folders: &BTreeSet<String>,
    has_dir: F,
) -> Vec<(String, &'static str)> {
    let has_dir = &has_dir;
    folders
        .iter()
        .flat_map(|f| {
            ENGINES
                .iter()
                .filter(move |e| has_dir(&format!("{f}/{e}")))
                .map(move |e| (f.clone(), *e))
        })
        .collect()
}

fn changed(root: &Path, base: &str) -> Res<Vec<String>> {
    let out = Command::new("git")
        .current_dir(root)
        .args(["diff", "--name-only", &format!("{base}...HEAD")])
        .output()
        .map_err(|e| fail(2, format!("fb check-changed: git: {e}")))?;
    out.status
        .success()
        .then(|| {
            String::from_utf8_lossy(&out.stdout)
                .lines()
                .map(str::to_string)
                .collect()
        })
        .ok_or_else(|| {
            fail(
                2,
                format!(
                    "fb check-changed: git diff {base}...HEAD failed: {}",
                    String::from_utf8_lossy(&out.stderr).trim()
                ),
            )
        })
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let base = match args {
        [] => "origin/master".to_string(),
        [flag, b] if flag == "--base" => b.clone(),
        _ => return Err(fail(2, USAGE)),
    };
    let root = crate::repo_root()?;
    let paths = changed(&root, &base)?;
    let folders = doc_folders(&paths, |d| root.join(d).join("usage").is_dir());
    let todo = jobs(&folders, |d| root.join(d).is_dir());
    let exe = std::env::current_exe().map_err(|e| fail(2, format!("fb check-changed: {e}")))?;
    let failed: Vec<String> = todo
        .iter()
        .filter(|(folder, engine)| {
            eprintln!("fb check-changed: {folder} --engine {engine}");
            !Command::new(&exe)
                .current_dir(&root)
                .env("FB_ROOT", &root)
                .args(["check", folder, "--engine", engine, "--no-render"])
                .status()
                .map(|s| s.success())
                .unwrap_or(false)
        })
        .map(|(folder, engine)| format!("{folder} --engine {engine}"))
        .collect();
    println!(
        "RESULT: CHECK-CHANGED {} of {} folder/engine checks passed ({} folders vs {base})",
        todo.len() - failed.len(),
        todo.len(),
        folders.len()
    );
    failed.iter().for_each(|f| println!("FAILED: {f}"));
    Ok(match failed.is_empty() {
        true => ExitCode::SUCCESS,
        false => ExitCode::from(1),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn s(v: &[&str]) -> Vec<String> {
        v.iter().map(|x| x.to_string()).collect()
    }

    #[test]
    fn a_changed_file_maps_to_its_nearest_usage_folder() {
        let docs = ["courts/c/x/brief", "courts/c"];
        let got = doc_folders(
            &s(&[
                "courts/c/x/brief/typst/t.typ",
                "courts/c/x/brief/usage/OUTPUT-brief.typst.pdf",
                "courts/c/rules.md",
                "tools/fb/src/main.rs",
                "courts/c/x/other/README.md",
            ]),
            |d| docs.contains(&d),
        );
        assert_eq!(
            got,
            ["courts/c", "courts/c/x/brief"]
                .iter()
                .map(|x| x.to_string())
                .collect()
        );
    }

    #[test]
    fn a_path_outside_any_doc_folder_and_non_court_paths_check_nothing() {
        assert!(
            doc_folders(&s(&["docs/EVAL-LOOP.md", "courts/z/README.md"]), |_| false).is_empty()
        );
    }

    #[test]
    fn every_engine_directory_of_a_folder_is_checked_and_only_those() {
        let dirs = ["courts/a/typst", "courts/a/docx", "courts/b/typst"];
        let folders: BTreeSet<String> = ["courts/a", "courts/b"]
            .iter()
            .map(|x| x.to_string())
            .collect();
        assert_eq!(
            jobs(&folders, |d| dirs.contains(&d)),
            vec![
                ("courts/a".to_string(), "typst"),
                ("courts/a".to_string(), "docx"),
                ("courts/b".to_string(), "typst")
            ]
        );
    }
}
