//! `fb check-changed [--base <ref>]`: run `fb check --no-render` on every engine of every court doc folder a
//! branch touches, so a landing gate (the declared quality command) refuses a court change whose committed
//! outputs fail. A doc folder is the nearest ancestor (under courts/) of a changed path that holds `usage/`;
//! its engines are whichever of typst/, latex/ and docx/ it has. Folders the branch deleted are skipped.
//! When the branch touches tools/fb/, it also compiles the fb test suite (`cargo test --release --no-run`), so a
//! test file that does not compile can not reach master (fb-595.81: 785ba8ade landed gate0_tests.rs uncompiled);
//! no cargo means a failed gate, not a skipped one: a host that can not run cargo does not land tools/fb changes.
//! A diff that touches the shared document model (MODEL: lib/typst/xdoc*, lib/typst/xengine*, lib/pandoc, lib/latex,
//! lib/docx, tools/fb/src/enginegen) also checks every doc folder on the model, a folder with `typst/layout.yaml` or
//! an eval.yaml `params.cross_engine*` (fb-595.83): a folder that landed on the base after the branch forked was
//! rendered on the previous model, and only a full recheck shows whether its committed outputs still pass.
//! A change under tools/fb/src/enginegen does both. The RESULT line counts the folder/engine checks plus the fb test
//! build when it ran, and says when the shared model changed.
//! Exit 0 only when every check passes (or nothing under courts/, tools/fb/ or the model changed).

use crate::{fail, Res};
use std::collections::BTreeSet;
use std::path::Path;
use std::process::{Command, ExitCode};

const USAGE: &str = "usage: fb check-changed [--base <ref>]   (default base: origin/master)";
const ENGINES: [&str; 3] = ["typst", "latex", "docx"];

/// The path prefixes of the shared document model: a change under any of them can move every folder on the model.
pub const MODEL: [&str; 6] = [
    "lib/typst/xdoc",
    "lib/typst/xengine",
    "lib/pandoc/",
    "lib/latex/",
    "lib/docx/",
    "tools/fb/src/enginegen/",
];

/// Does the diff `paths` touch the shared document model.
pub fn touches_model(paths: &[String]) -> bool {
    paths.iter().any(|p| MODEL.iter().any(|m| p.starts_with(m)))
}

/// Does eval.yaml text set a `params.cross_engine` or `params.cross_engine_<engine>` mode.
pub fn has_cross_engine(eval_yaml: &str) -> bool {
    serde_yaml::from_str::<serde_yaml::Value>(eval_yaml)
        .ok()
        .and_then(|v| v.get("params").and_then(|p| p.as_mapping()).cloned())
        .is_some_and(|m| {
            m.keys()
                .filter_map(|k| k.as_str())
                .any(|k| k == "cross_engine" || k.starts_with("cross_engine_"))
        })
}

/// The doc folders on the model among the tracked `files` (repo-relative): the folder of each
/// `<folder>/typst/layout.yaml`, and each `<folder>/eval.yaml` for which `cross_engine(path)` holds; only folders
/// under courts/ for which `is_doc` holds.
pub fn model_folders<C: Fn(&str) -> bool, D: Fn(&str) -> bool>(
    files: &[String],
    cross_engine: C,
    is_doc: D,
) -> BTreeSet<String> {
    files
        .iter()
        .filter(|p| p.starts_with("courts/"))
        .filter_map(|p| {
            p.strip_suffix("/typst/layout.yaml")
                .map(str::to_string)
                .or_else(|| {
                    p.strip_suffix("/eval.yaml")
                        .filter(|_| cross_engine(p))
                        .map(str::to_string)
                })
        })
        .filter(|d| is_doc(d))
        .collect()
}

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

/// Does the branch touch the fb crate (its sources, tests, manifest or lockfile)?
pub fn touches_fb(paths: &[String]) -> bool {
    paths.iter().any(|p| p.starts_with("tools/fb/"))
}

/// Compile every fb test target without running it; false when cargo is missing or the build fails.
fn fb_tests_compile(root: &Path) -> bool {
    eprintln!("fb check-changed: cargo test --release --no-run (tools/fb)");
    Command::new("cargo")
        .current_dir(root)
        .args(["test", "--release", "--no-run"])
        .args(["--manifest-path", "tools/fb/Cargo.toml"])
        .status()
        .map_err(|e| {
            eprintln!(
                "fb check-changed: cargo: {e} (land tools/fb changes from a host that runs cargo)"
            )
        })
        .map(|s| s.success())
        .unwrap_or(false)
}

/// The RESULT line: folder/engine checks plus the fb test build when it ran (`fb`), and a note when the diff
/// touched the shared model (`model`), so every folder on it was checked.
pub fn result_line(
    jobs: usize,
    failed: usize,
    folders: usize,
    fb: bool,
    model: bool,
    base: &str,
) -> String {
    let total = jobs + usize::from(fb);
    format!(
        "RESULT: CHECK-CHANGED {} of {total} checks passed ({jobs} folder/engine in {folders} folders{} vs {base}{})",
        total - failed,
        if fb { " + tools/fb test build" } else { "" },
        if model { "; shared model changed: every folder on it" } else { "" },
    )
}

/// The lines git prints for `args` in `root`.
fn git_lines(root: &Path, args: &[&str]) -> Res<Vec<String>> {
    let out = Command::new("git")
        .current_dir(root)
        .args(args)
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
                    "fb check-changed: git {} failed: {}",
                    args.join(" "),
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
    let paths = git_lines(&root, &["diff", "--name-only", &format!("{base}...HEAD")])?;
    let is_doc = |d: &str| root.join(d).join("usage").is_dir();
    let mut folders = doc_folders(&paths, is_doc);
    let model = touches_model(&paths);
    if model {
        let tracked = git_lines(&root, &["ls-files", "--", "courts"])?;
        let on_model = model_folders(
            &tracked,
            |p| std::fs::read_to_string(root.join(p)).is_ok_and(|t| has_cross_engine(&t)),
            is_doc,
        );
        eprintln!(
            "fb check-changed: the diff touches the shared model; checking all {} folders on it",
            on_model.len()
        );
        folders.extend(on_model);
    }
    let todo = jobs(&folders, |d| root.join(d).is_dir());
    let exe = std::env::current_exe().map_err(|e| fail(2, format!("fb check-changed: {e}")))?;
    let fb_job = touches_fb(&paths);
    let fb_failed = fb_job && !fb_tests_compile(&root);
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
        .chain(fb_failed.then(|| "tools/fb: cargo test --release --no-run".to_string()))
        .collect();
    println!(
        "{}",
        result_line(
            todo.len(),
            failed.len(),
            folders.len(),
            fb_job,
            model,
            &base
        )
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
    fn a_tools_fb_change_and_only_that_compiles_the_fb_tests() {
        assert!(touches_fb(&s(&[
            "docs/x.md",
            "tools/fb/src/check/gate0_tests.rs"
        ])));
        assert!(touches_fb(&s(&["tools/fb/Cargo.lock"])));
        assert!(!touches_fb(&s(&[
            "courts/c/rules.md",
            "tools/check.sh",
            "tools/fbx/a"
        ])));
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
    #[test]
    fn only_a_shared_model_path_counts_as_a_model_change() {
        for p in [
            "lib/typst/xdoc.typ",
            "lib/typst/xengine.typ",
            "lib/pandoc/xdoc.lua",
            "lib/latex/xdoc.sty",
            "lib/docx/xengine.lua",
            "tools/fb/src/enginegen/gen.rs",
        ] {
            assert!(touches_model(&s(&["README.md", p])), "{p}");
        }
        assert!(!touches_model(&s(&[
            "lib/typst/toa.typ",
            "tools/fb/src/checkchanged.rs",
            "courts/c/typst/layout.yaml",
            "docs/EVAL-LOOP.md",
        ])));
    }

    #[test]
    fn eval_yaml_cross_engine_params_put_a_folder_on_the_model() {
        assert!(has_cross_engine("params:\n  cross_engine: gate\n"));
        assert!(has_cross_engine("params:\n  cross_engine_docx: report\n"));
        assert!(!has_cross_engine("params:\n  max_pages: 30\n"));
        assert!(!has_cross_engine("cross_engine: gate\n"));
        assert!(!has_cross_engine(": not yaml: ["));
    }

    #[test]
    fn a_model_change_checks_every_folder_on_the_model() {
        // the bead's case: a folder that landed on the base after the fork is outside the branch's diff
        let tracked = s(&[
            "courts/a/brief/typst/layout.yaml",
            "courts/a/brief/usage/INPUT-brief.md",
            "courts/b/eval.yaml",
            "courts/b/motion/eval.yaml",
            "courts/c/eval.yaml",
            "courts/d/typst/layout.yaml",
            "lib/x/typst/layout.yaml",
            "courts/e/typst/sub/typst/layout.yaml.bak",
        ]);
        let cross = ["courts/b/motion/eval.yaml", "courts/c/eval.yaml"];
        let docs = ["courts/a/brief", "courts/b/motion", "courts/b", "courts/c"];
        let got = model_folders(&tracked, |p| cross.contains(&p), |d| docs.contains(&d));
        assert_eq!(
            got,
            ["courts/a/brief", "courts/b/motion", "courts/c"]
                .iter()
                .map(|x| x.to_string())
                .collect()
        );
    }

    #[test]
    fn an_enginegen_change_builds_the_fb_tests_and_checks_every_model_folder() {
        let paths = s(&["tools/fb/src/enginegen/gen.rs"]);
        assert!(touches_fb(&paths));
        assert!(touches_model(&paths));
        assert_eq!(
            result_line(4, 1, 2, true, true, "origin/master"),
            "RESULT: CHECK-CHANGED 4 of 5 checks passed (4 folder/engine in 2 folders + tools/fb test build \
             vs origin/master; shared model changed: every folder on it)"
        );
    }

    #[test]
    fn the_result_line_names_only_what_ran() {
        assert_eq!(
            result_line(3, 0, 1, false, false, "b"),
            "RESULT: CHECK-CHANGED 3 of 3 checks passed (3 folder/engine in 1 folders vs b)"
        );
        assert_eq!(
            result_line(0, 1, 0, true, false, "b"),
            "RESULT: CHECK-CHANGED 0 of 1 checks passed (0 folder/engine in 0 folders + tools/fb test build vs b)"
        );
        assert_eq!(
            result_line(2, 0, 1, false, true, "b"),
            "RESULT: CHECK-CHANGED 2 of 2 checks passed (2 folder/engine in 1 folders vs b; \
             shared model changed: every folder on it)"
        );
    }
}
