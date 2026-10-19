//! Starting a filing from the library: `fb find`, `fb new-filing`, `fb render-filing` (were
//! skills/formbook/scripts/find.sh, new-filing.sh and render-filing.sh).
//!   fb find <alias|text> [doctype]               court folders and the doc types that have a typst template
//!   fb new-filing <alias> <doctype> <out-dir>    copy a doc type's first sample input to <out-dir>/filing.md
//!   fb render-filing <doctype-dir> <filing.md> [out.pdf]   render a markdown file that lives outside the court folder
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

/// alias, path, name of one court.
#[derive(Debug, Clone, PartialEq)]
pub struct Court {
    pub alias: String,
    // type-strength: allow(string-field) repo-relative path exactly as written in data/index.json, printed verbatim
    pub path: String,
    pub name: String,
}

fn text(v: &Value, k: &str) -> String {
    v[k].as_str().unwrap_or("").to_string()
}

fn read_json(p: &Path) -> Option<Value> {
    serde_json::from_slice(&std::fs::read(p).ok()?).ok()
}

/// Every court.json under `dir`, sorted.
fn court_jsons(dir: &Path, out: &mut Vec<PathBuf>) {
    for e in std::fs::read_dir(dir).into_iter().flatten().flatten() {
        let p = e.path();
        if p.is_dir() {
            court_jsons(&p, out);
        } else if p.file_name().is_some_and(|n| n == "court.json") {
            out.push(p);
        }
    }
    out.sort();
}

/// The courts matching `q`: the alias (a legacy alias maps to its current one), else a substring of the court
/// name or path, else a court.json in the tree whose alias matches (the index can lag the tree).
pub fn matches(root: &Path, index: &Value, q: &str) -> Vec<Court> {
    let list: Vec<Court> = index["courts"]
        .as_object()
        .into_iter()
        .flatten()
        .map(|(a, c)| Court {
            alias: a.clone(),
            path: text(c, "path"),
            name: text(c, "name"),
        })
        .collect();
    let q = index["legacy_aliases"][q]
        .as_str()
        .unwrap_or(q)
        .to_lowercase();
    let exact: Vec<Court> = list
        .iter()
        .filter(|c| c.alias.to_lowercase() == q)
        .cloned()
        .collect();
    if !exact.is_empty() {
        return exact;
    }
    let sub: Vec<Court> = list
        .iter()
        .filter(|c| format!("{} {}", c.path, c.name).to_lowercase().contains(&q))
        .cloned()
        .collect();
    if !sub.is_empty() {
        return sub;
    }
    let mut cjs = vec![];
    court_jsons(&root.join("courts"), &mut cjs);
    cjs.iter()
        .filter_map(|cj| {
            let v = read_json(cj)?;
            let alias = text(&v, "alias");
            let path = cj
                .parent()?
                .strip_prefix(root)
                .ok()?
                .to_string_lossy()
                .into_owned();
            (alias.to_lowercase() == q).then(|| Court {
                alias,
                path,
                name: text(&v, "name"),
            })
        })
        .collect()
}

/// Every `typst/` folder under `dir` (any depth), as sorted paths.
fn typst_dirs(dir: &Path, out: &mut Vec<PathBuf>) {
    for e in std::fs::read_dir(dir).into_iter().flatten().flatten() {
        let p = e.path();
        if p.is_dir() {
            if p.file_name().is_some_and(|n| n == "typst") {
                out.push(p.clone());
            }
            typst_dirs(&p, out);
        }
    }
    out.sort();
}

/// The doc type of a template folder relative to its court (`.` for a court-root template).
fn rel_doctype(court: &str, folder: &str) -> String {
    let rel = folder
        .strip_prefix(court)
        .unwrap_or(folder)
        .trim_start_matches('/');
    if rel.is_empty() {
        ".".into()
    } else {
        rel.into()
    }
}

fn wanted(rel: &str, dt: &str) -> bool {
    dt.is_empty() || rel == dt || rel.ends_with(&format!("/{dt}"))
}

/// The output lines of `fb find`: a court line, then one doctype line per template folder.
pub fn find_lines(root: &Path, index: &Value, q: &str, dt: &str) -> Vec<String> {
    let mut out = vec![];
    for c in matches(root, index, q) {
        out.push(format!("{}\t{}\t{}", c.alias, c.path, c.name));
        let mut ts = vec![];
        typst_dirs(&root.join(&c.path), &mut ts);
        for t in ts.iter().filter(|t| t.join("main.typ").is_file()) {
            let folder = t
                .parent()
                .and_then(|d| d.strip_prefix(root).ok())
                .map(|d| d.to_string_lossy().into_owned())
                .unwrap_or_default();
            let rel = rel_doctype(&c.path, &folder);
            if !wanted(&rel, dt) {
                continue;
            }
            let n = inputs(&root.join(&folder)).len();
            out.push(format!("  doctype: {rel}\t({n} sample inputs)\t{folder}"));
        }
    }
    out
}

/// usage/INPUT-*.md of a doc folder, sorted.
fn inputs(folder: &Path) -> Vec<PathBuf> {
    crate::worklist::files(folder.join("usage"), |n| {
        n.starts_with("INPUT-") && n.ends_with(".md")
    })
}

fn load_index(root: &Path) -> Res<Value> {
    read_json(&root.join("data/index.json")).ok_or_else(|| {
        fail(
            2,
            "fb find: run from the formbook repo root (no data/index.json)",
        )
    })
}

pub fn find(args: &[String]) -> Res<ExitCode> {
    let (q, dt) = match args {
        [q] => (q, ""),
        [q, d] => (q, d.as_str()),
        _ => return Err(fail(2, "usage: fb find <alias|text> [doctype]")),
    };
    let root = repo_root()?;
    let lines = find_lines(&root, &load_index(&root)?, q, dt);
    if lines.is_empty() {
        return Err(fail(1, format!("fb find: no court matches '{q}'")));
    }
    lines.iter().for_each(|l| println!("{l}"));
    Ok(ExitCode::SUCCESS)
}

/// The template folders in `fb find` output lines.
pub fn folders(lines: &[String]) -> Vec<String> {
    lines
        .iter()
        .filter(|l| l.starts_with("  doctype:"))
        .filter_map(|l| l.split('\t').nth(2).map(str::to_string))
        .collect()
}

pub fn new_filing(args: &[String]) -> Res<ExitCode> {
    let [alias, dt, out] = args else {
        return Err(fail(2, "usage: fb new-filing <alias> <doctype> <out-dir>"));
    };
    let root = repo_root()?;
    let lines = find_lines(&root, &load_index(&root)?, alias, dt);
    if lines.is_empty() {
        eprintln!("fb find: no court matches '{alias}'");
    }
    let sel = folders(&lines);
    match sel.as_slice() {
        [] => Err(fail(
            1,
            format!("fb new-filing: no doc type '{dt}' for '{alias}' (run: just find {alias})"),
        )),
        [one] => {
            let src = inputs(&root.join(one)).into_iter().next().ok_or_else(|| {
                fail(1, format!("fb new-filing: {one} has no usage/INPUT-*.md"))
            })?;
            let src_rel = src.strip_prefix(&root).unwrap_or(&src).to_string_lossy().into_owned();
            std::fs::create_dir_all(out).map_err(|e| fail(2, format!("fb new-filing: {out}: {e}")))?;
            std::fs::copy(&src, Path::new(out).join("filing.md"))
                .map_err(|e| fail(2, format!("fb new-filing: {e}")))?;
            let abs = std::fs::canonicalize(out)
                .map_err(|e| fail(2, format!("fb new-filing: {out}: {e}")))?;
            println!("template : {one}");
            println!("starting : {src_rel} -> {out}/filing.md");
            println!(
                "render   : just render-filing {one} {0}/filing.md {0}/filing.pdf",
                abs.display()
            );
            println!("note     : the sample is a real filing excerpt; replace every party, fact and cite. Contract: skills/formbook/reference/input-contract.md");
            Ok(ExitCode::SUCCESS)
        }
        many => Err(fail(
            1,
            format!(
                "fb new-filing: '{dt}' matches several doc types for '{alias}'; pass the exact name:\n{}",
                many.join("\n")
            ),
        )),
    }
}

/// A staged copy of the filing inside the doc folder, removed on drop.
struct Staged(PathBuf);
impl Drop for Staged {
    fn drop(&mut self) {
        let _ = std::fs::remove_file(&self.0);
    }
}

/// `<src>.pdf` for `<src>.md`.
fn default_pdf(src: &Path) -> PathBuf {
    let s = src.to_string_lossy();
    PathBuf::from(format!("{}.pdf", s.strip_suffix(".md").unwrap_or(&s)))
}

/// Render a filing that lives outside the court folder: typst reads the sample relative to the doc-type folder
/// (its --root), so a temporary copy is staged at `<doctype-dir>/.staged-<pid>.md` (outside usage/, so
/// `fb lint paths` never sees it), rendered with vendored fonts and warnings failing, then removed.
pub fn render_filing(args: &[String]) -> Res<ExitCode> {
    if args.len() < 2 || args.len() > 3 {
        return Err(fail(
            2,
            "usage: fb render-filing <doctype-dir> <filing.md> [out.pdf]",
        ));
    }
    let root = repo_root()?;
    let dir = std::fs::canonicalize(&args[0])
        .map_err(|e| fail(2, format!("fb render-filing: {}: {e}", args[0])))?;
    let src = std::fs::canonicalize(&args[1])
        .map_err(|e| fail(2, format!("fb render-filing: {}: {e}", args[1])))?;
    let out = args.get(2).map_or_else(|| default_pdf(&src), PathBuf::from);
    let out = if out.is_absolute() {
        out
    } else {
        std::env::current_dir()
            .map_err(|e| fail(2, format!("fb render-filing: {e}")))?
            .join(out)
    };
    if !dir.join("typst/main.typ").is_file() {
        return Err(fail(
            2,
            format!("fb render-filing: {} has no typst/main.typ", args[0]),
        ));
    }
    let name = format!(".staged-{}.md", std::process::id());
    let stage = Staged(dir.join(&name));
    std::fs::copy(&src, &stage.0).map_err(|e| fail(2, format!("fb render-filing: {e}")))?;
    crate::render::render_one(
        &root,
        "typst",
        &dir,
        Path::new(&name),
        &out,
        crate::render::Warnings::Deny,
    )?;
    println!("{}", out.display());
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proc::TempDir;
    use serde_json::json;

    fn tree() -> (TempDir, Value) {
        let t = TempDir::new("filing-test").unwrap();
        let r = t.path();
        for d in [
            "courts/c1/opening-brief/typst",
            "courts/c1/opening-brief/usage",
            "courts/c1/typst",
            "courts/c1/usage",
            "courts/c2/x/typst",
        ] {
            std::fs::create_dir_all(r.join(d)).unwrap();
        }
        for f in [
            "courts/c1/opening-brief/typst/main.typ",
            "courts/c1/typst/main.typ",
            "courts/c1/opening-brief/usage/INPUT-opening-brief.md",
            "courts/c1/opening-brief/usage/INPUT-opening-brief-2.md",
            "courts/c1/usage/INPUT-a.md",
        ] {
            std::fs::write(r.join(f), "x").unwrap();
        }
        let idx = json!({"courts": {"ca1": {"path": "courts/c1", "name": "Court of Appeals One"},
                                    "ca2": {"path": "courts/c2", "name": "Two"}},
                         "legacy_aliases": {"old1": "ca1"}});
        (t, idx)
    }

    #[test]
    fn lists_doctypes_with_input_counts() {
        let (t, idx) = tree();
        let l = find_lines(t.path(), &idx, "CA1", "");
        assert_eq!(l[0], "ca1\tcourts/c1\tCourt of Appeals One");
        assert_eq!(
            l[1],
            "  doctype: opening-brief\t(2 sample inputs)\tcourts/c1/opening-brief"
        );
        assert_eq!(l[2], "  doctype: .\t(1 sample inputs)\tcourts/c1");
        assert_eq!(l.len(), 3);
    }

    #[test]
    fn legacy_alias_substring_and_doctype_filter() {
        let (t, idx) = tree();
        assert_eq!(find_lines(t.path(), &idx, "old1", "").len(), 3);
        assert_eq!(
            find_lines(t.path(), &idx, "appeals one", "opening-brief").len(),
            2
        );
        assert_eq!(find_lines(t.path(), &idx, "ca1", ".").len(), 2);
        assert!(find_lines(t.path(), &idx, "zzz", "").is_empty());
        // c2/x has typst/ but no main.typ
        assert_eq!(find_lines(t.path(), &idx, "ca2", "").len(), 1);
    }

    #[test]
    fn index_lag_falls_back_to_court_json() {
        let (t, idx) = tree();
        std::fs::create_dir_all(t.path().join("courts/c3")).unwrap();
        std::fs::write(
            t.path().join("courts/c3/court.json"),
            r#"{"alias": "NEW3", "name": "Three"}"#,
        )
        .unwrap();
        let m = matches(t.path(), &idx, "new3");
        assert_eq!(
            m,
            [Court {
                alias: "NEW3".into(),
                path: "courts/c3".into(),
                name: "Three".into()
            }]
        );
    }

    #[test]
    fn folders_come_from_the_third_column() {
        let (t, idx) = tree();
        let l = find_lines(t.path(), &idx, "ca1", "opening-brief");
        assert_eq!(folders(&l), ["courts/c1/opening-brief"]);
    }

    #[test]
    fn default_pdf_swaps_the_extension() {
        assert_eq!(default_pdf(Path::new("/a/f.md")), Path::new("/a/f.pdf"));
        assert_eq!(default_pdf(Path::new("/a/f")), Path::new("/a/f.pdf"));
        assert!(wanted("a/b", "b") && wanted("b", "b") && !wanted("ab", "b"));
    }
}
