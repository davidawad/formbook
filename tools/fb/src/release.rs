//! `fb release`: numbered releases (fb-595.102). Tags are `vMAJOR.MINOR.PATCH` on master; a pushed tag makes the
//! GitHub release (.github/workflows/release.yml), its notes the tag's annotation.
//!   fb release next [major|minor|patch]          the next version after the latest v-tag (default minor)
//!   fb release notes [--from TAG] [--to REF]     release notes, markdown: the courts and doc types whose
//!                                                templates, rules or outputs changed, then tool changes
//!   fb release cut <vX.Y.Z|major|minor|patch> [--dry-run]
//!                                                tag origin/master with the notes and push the tag to origin
//! `--from` defaults to the latest v-tag, `--to` to origin/master. A version must be greater than the latest tag.
use crate::preview::{court_of, git};
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};
use std::path::Path;
use std::process::ExitCode;

const CLI: &str = "usage: fb release next [major|minor|patch]\n       fb release notes [--from TAG] [--to REF]\n       fb release cut <vX.Y.Z|major|minor|patch> [--dry-run]";
const FOLDER_PARTS: [&str; 5] = ["typst", "latex", "docx", "usage", "reviews"];

type Version = (u32, u32, u32);

fn parse(v: &str) -> Option<Version> {
    let mut it = v
        .strip_prefix('v')?
        .split('.')
        .map(|n| n.parse::<u32>().ok());
    let (a, b, c) = (it.next()??, it.next()??, it.next()??);
    it.next().is_none().then_some((a, b, c))
}

fn show((a, b, c): Version) -> String {
    format!("v{a}.{b}.{c}")
}

fn bump((a, b, c): Version, part: &str) -> Option<Version> {
    match part {
        "major" => Some((a + 1, 0, 0)),
        "minor" => Some((a, b + 1, 0)),
        "patch" => Some((a, b, c + 1)),
        _ => None,
    }
}

/// The greatest `vX.Y.Z` among `tags` (one per line).
fn latest(tags: &str) -> Option<Version> {
    tags.lines().filter_map(parse).max()
}

/// The doc folder a changed path under courts/ belongs to: the path above its first engine/usage/reviews
/// segment, else the file's own directory.
fn doc_folder(path: &str) -> Option<String> {
    let rest = path.strip_prefix("courts/")?;
    let parts: Vec<&str> = rest.split('/').collect();
    let cut = parts
        .iter()
        .position(|p| FOLDER_PARTS.contains(p))
        .unwrap_or(parts.len().saturating_sub(1));
    (cut > 0).then(|| format!("courts/{}", parts[..cut].join("/")))
}

/// Court name -> doc types (the folder's last segment; `(court folder)` for the court root) touched by `changed`.
fn courts_changed(
    changed: &str,
    court: &dyn Fn(&str) -> (String, String),
) -> BTreeMap<String, BTreeSet<String>> {
    changed
        .lines()
        .filter_map(doc_folder)
        .fold(BTreeMap::new(), |mut m, doc| {
            let (name, path) = court(&doc);
            let kind = match doc == path {
                true => "(court folder)".to_string(),
                false => doc.rsplit('/').next().unwrap_or(&doc).to_string(),
            };
            m.entry(name).or_insert_with(BTreeSet::new).insert(kind);
            m
        })
}

/// The notes: header, the courts changed, the tool commits (subjects of commits touching tools/, lib/, docs/,
/// data/ or .github/, oldest first, without duplicates), and the disclaimer.
fn notes(
    from: &str,
    to: &str,
    commits: usize,
    courts: &BTreeMap<String, BTreeSet<String>>,
    tools: &[String],
) -> String {
    let court_lines: String = courts
        .iter()
        .map(|(c, kinds)| {
            format!(
                "- {c}: {}\n",
                kinds.iter().cloned().collect::<Vec<_>>().join(", ")
            )
        })
        .collect();
    let tool_lines: String = tools.iter().map(|s| format!("- {s}\n")).collect();
    let or_none = |s: String| match s.is_empty() {
        true => "- none\n".to_string(),
        false => s,
    };
    format!(
        "Changes since {from} ({commits} commits, to {to}).\n\n**Courts changed ({})**\n{}\n**Tools and shared code**\n{}\n\
         Not legal advice. Verify every output against the court's current rules before filing.\n",
        courts.len(),
        or_none(court_lines),
        or_none(tool_lines)
    )
}

fn text(root: &Path, args: &[&str]) -> Res<String> {
    git(root, args).map(|b| String::from_utf8_lossy(&b).trim().to_string())
}

fn latest_tag(root: &Path) -> Res<Version> {
    latest(&text(root, &["tag", "-l", "v*"])?).ok_or_else(|| fail(1, "fb release: no vX.Y.Z tag"))
}

fn make_notes(root: &Path, from: &str, to: &str) -> Res<String> {
    let range = format!("{from}..{to}");
    let changed = text(root, &["diff", "--name-only", from, to])?;
    let index: Value = git(root, &["show", &format!("{to}:data/index.json")])
        .ok()
        .and_then(|b| serde_json::from_slice(&b).ok())
        .unwrap_or(Value::Null);
    let court = |doc: &str| -> (String, String) {
        let name = court_of(&index, doc);
        let path = index["courts"]
            .as_object()
            .into_iter()
            .flatten()
            .find(|(_, c)| c["name"].as_str() == Some(&name))
            .and_then(|(_, c)| c["path"].as_str())
            .unwrap_or(doc)
            .to_string();
        (name, path)
    };
    let commits = text(root, &["rev-list", "--count", &range])?
        .parse()
        .unwrap_or(0);
    let subjects = text(
        root,
        &[
            "log",
            "--no-merges",
            "--reverse",
            "--format=%s",
            &range,
            "--",
            "tools",
            "lib",
            "docs",
            "data",
            ".github",
        ],
    )?;
    let tools: Vec<String> = subjects
        .lines()
        .filter(|s| !s.starts_with("chore: regenerate"))
        .fold(Vec::new(), |mut v, s| {
            if !v.iter().any(|x: &String| x == s) {
                v.push(s.to_string());
            }
            v
        });
    Ok(notes(
        from,
        &text(root, &["rev-parse", "--short=10", to])?,
        commits,
        &courts_changed(&changed, &court),
        &tools,
    ))
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let root = repo_root()?;
    let a: Vec<&str> = args.iter().map(String::as_str).collect();
    match a.as_slice() {
        ["next"] | ["next", _] => {
            let part = a.get(1).copied().unwrap_or("minor");
            let v = bump(latest_tag(&root)?, part).ok_or_else(|| fail(2, CLI))?;
            println!("{}", show(v));
        }
        ["notes", rest @ ..] => {
            let opt = |k: &str| {
                rest.iter()
                    .position(|x| *x == k)
                    .and_then(|i| rest.get(i + 1))
                    .map(|s| s.to_string())
            };
            let from = opt("--from").unwrap_or(show(latest_tag(&root)?));
            let to = opt("--to").unwrap_or_else(|| "origin/master".into());
            print!("{}", make_notes(&root, &from, &to)?);
        }
        ["cut", v, rest @ ..] => {
            let dry = rest.contains(&"--dry-run");
            let have = latest_tag(&root)?;
            let want = parse(v).or_else(|| bump(have, v)).ok_or_else(|| {
                fail(
                    2,
                    format!("fb release: {v} is not vX.Y.Z or major|minor|patch"),
                )
            })?;
            let v = &show(want);
            if want <= have {
                return Err(fail(
                    1,
                    format!("fb release: {v} is not after {}", show(have)),
                ));
            }
            git(&root, &["fetch", "-q", "origin", "master", "--tags"])?;
            let body = make_notes(&root, &show(have), "origin/master")?;
            let msg = format!("formbook {v}\n\n{body}");
            print!("{msg}");
            if dry {
                println!("\n(dry run: no tag made)");
                return Ok(ExitCode::SUCCESS);
            }
            git(&root, &["tag", "-a", v, "-m", &msg, "origin/master"])?;
            git(&root, &["push", "-q", "origin", v])?;
            println!(
                "\ntagged {v} at origin/master and pushed it; the release workflow publishes it"
            );
        }
        _ => return Err(fail(2, CLI)),
    }
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn versions_parse_compare_and_bump() {
        assert_eq!(parse("v0.3.0"), Some((0, 3, 0)));
        assert_eq!(parse("v1.2"), None);
        assert_eq!(parse("v1.2.3.4"), None);
        assert_eq!(parse("1.2.3"), None);
        assert_eq!(
            latest("v0.2.0\nv0.10.0\nv0.3.0\nbackup/x\n"),
            Some((0, 10, 0))
        );
        assert_eq!(show(bump((0, 3, 0), "minor").unwrap()), "v0.4.0");
        assert_eq!(show(bump((0, 3, 1), "major").unwrap()), "v1.0.0");
        assert_eq!(show(bump((0, 3, 1), "patch").unwrap()), "v0.3.2");
        assert_eq!(bump((0, 3, 1), "huge"), None);
    }

    #[test]
    fn doc_folder_is_above_the_engine_segment() {
        assert_eq!(
            doc_folder("courts/a/b/motion-brief/typst/x.typ").as_deref(),
            Some("courts/a/b/motion-brief")
        );
        assert_eq!(
            doc_folder("courts/a/b/rules.md").as_deref(),
            Some("courts/a/b")
        );
        assert_eq!(
            doc_folder("courts/a/usage/OUTPUT-x.typst.pdf").as_deref(),
            Some("courts/a")
        );
        assert_eq!(doc_folder("lib/typst/x.typ"), None);
    }

    #[test]
    fn notes_group_doc_types_by_court() {
        let changed = "courts/x/motion-brief/typst/a.typ\ncourts/x/rules.md\ncourts/x/complaint/usage/OUTPUT-complaint.typst.pdf\ncourts/y/z/answer/docx/r.xml\n";
        let court = |d: &str| match d.starts_with("courts/x") {
            true => ("Court X".to_string(), "courts/x".to_string()),
            false => ("Court Y".to_string(), "courts/y/z".to_string()),
        };
        let m = courts_changed(changed, &court);
        assert_eq!(
            m["Court X"].iter().cloned().collect::<Vec<_>>(),
            vec!["(court folder)", "complaint", "motion-brief"]
        );
        let n = notes("v0.3.0", "abc", 5, &m, &["feat(fb): x".to_string()]);
        assert!(n.starts_with("Changes since v0.3.0 (5 commits, to abc)."));
        assert!(n.contains("**Courts changed (2)**\n- Court X: (court folder), complaint, motion-brief\n- Court Y: answer\n"));
        assert!(n.contains("**Tools and shared code**\n- feat(fb): x\n"));
        assert!(
            notes("a", "b", 0, &BTreeMap::new(), &[]).contains("**Courts changed (0)**\n- none\n")
        );
    }
}
