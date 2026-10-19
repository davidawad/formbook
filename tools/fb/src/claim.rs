//! `fb claim <alias> | --next | --random [--dry-run]`: claim one court for an agent without colliding with others.
//!
//! A claim is the atomic creation of the remote branch court/<alias> from origin/master. The push uses
//! --force-with-lease=<ref>: (expect "does not exist"), so it fails if anyone created the branch first, and the
//! next candidate is tried. A court is unclaimed when no remote court/<alias> branch exists, its court.json on
//! origin/master is not "done", and it is not already up for review on origin/master (rules.md + typst template +
//! usage/.check-typst.txt). Courts under "reference" in data/priority.json are never picked by --next/--random.
//! CLAIM_REMOTE and CLAIM_BASE override origin and master.
//! Prints: alias: <alias> / path: <court folder> / branch: court/<alias>
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::path::Path;
use std::process::{Command, ExitCode};

#[derive(Debug, Clone, PartialEq)]
enum Mode {
    Alias(String),
    Next,
    Random,
}

fn parse(args: &[String]) -> Res<(Mode, bool)> {
    let mut mode = None;
    let mut dry = false;
    for a in args {
        match a.as_str() {
            "--next" => mode = Some(Mode::Next),
            "--random" => mode = Some(Mode::Random),
            "--dry-run" => dry = true,
            o if o.starts_with('-') => {
                return Err(fail(2, format!("fb claim: unknown option {o}")))
            }
            alias => mode = Some(Mode::Alias(alias.into())),
        }
    }
    mode.map(|m| (m, dry))
        .ok_or_else(|| fail(2, "usage: fb claim <alias> | --next | --random [--dry-run]"))
}

fn path_of(index: &Value, alias: &str) -> Option<String> {
    index["courts"][alias]["path"].as_str().map(str::to_string)
}

/// What the remote says: claimed aliases, the files of courts/ on the base, and a court.json reader.
struct Remote<'a> {
    claimed: Vec<String>,
    tree: Vec<String>,
    status: &'a dyn Fn(&str) -> String,
}

/// None if `alias` is claimable, else the reason it is not.
fn ineligible(alias: &str, index: &Value, r: &Remote, remote: &str, base: &str) -> Option<String> {
    let Some(p) = path_of(index, alias) else {
        return Some(format!("no such court alias: {alias}"));
    };
    if r.claimed.iter().any(|c| c == alias) {
        return Some(format!(
            "{alias} is already claimed (remote branch court/{alias} exists)"
        ));
    }
    let has = |f: String| r.tree.contains(&f);
    if !has(format!("{p}/court.json")) {
        return Some(format!("{alias}: {p}/court.json is not on {remote}/{base}"));
    }
    if (r.status)(&p) == "done" {
        return Some(format!("{alias} is done"));
    }
    let typ = format!("{p}/typst/");
    if has(format!("{p}/rules.md"))
        && has(format!("{p}/usage/.check-typst.txt"))
        && r.tree
            .iter()
            .any(|t| t.starts_with(&typ) && t.ends_with(".typ"))
    {
        return Some(format!("{alias} is already up for review on {base}"));
    }
    None
}

/// Candidate aliases in try order: the alias itself, or priority.json order minus the reference courts
/// (shuffled for --random with `seed`).
fn candidates(mode: &Mode, priority: &Value, seed: u64) -> Vec<String> {
    let strs = |v: &Value| -> Vec<String> {
        v.as_array()
            .map(|a| {
                a.iter()
                    .filter_map(|x| x.as_str().map(str::to_string))
                    .collect()
            })
            .unwrap_or_default()
    };
    let reference = strs(&priority["reference"]);
    let mut order: Vec<String> = strs(&priority["order"])
        .into_iter()
        .filter(|a| !reference.contains(a))
        .collect();
    match mode {
        Mode::Alias(a) => vec![a.clone()],
        Mode::Next => order,
        Mode::Random => {
            // xorshift Fisher-Yates: only the independence of picks matters, not the generator.
            let mut x = seed | 1;
            for i in (1..order.len()).rev() {
                x ^= x << 13;
                x ^= x >> 7;
                x ^= x << 17;
                order.swap(i, (x % (i as u64 + 1)) as usize);
            }
            order
        }
    }
}

fn git(root: &Path, args: &[&str]) -> Res<std::process::Output> {
    crate::proc::capture(Command::new("git").current_dir(root).args(args))
}

fn git_ok(root: &Path, args: &[&str]) -> Res<String> {
    let o = git(root, args)?;
    if o.status.success() {
        Ok(String::from_utf8_lossy(&o.stdout).into_owned())
    } else {
        Err(fail(
            1,
            format!(
                "fb claim: git {} failed: {}",
                args.join(" "),
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        ))
    }
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let (mode, dry) = parse(args)?;
    let root = repo_root()?;
    let remote = std::env::var("CLAIM_REMOTE").unwrap_or_else(|_| "origin".into());
    let base = std::env::var("CLAIM_BASE").unwrap_or_else(|_| "master".into());
    git_ok(&root, &["fetch", "-q", &remote, &base])?;
    let sha = git_ok(&root, &["rev-parse", &format!("{remote}/{base}")])?
        .trim()
        .to_string();
    let index: Value = serde_json::from_slice(
        &std::fs::read(root.join("data/index.json"))
            .map_err(|e| fail(2, format!("fb claim: data/index.json: {e}")))?,
    )
    .map_err(|e| fail(2, format!("fb claim: data/index.json: {e}")))?;
    let priority: Value = std::fs::read(root.join("data/priority.json"))
        .ok()
        .and_then(|b| serde_json::from_slice(&b).ok())
        .unwrap_or(Value::Null);
    let claimed = git_ok(
        &root,
        &["ls-remote", "--heads", &remote, "refs/heads/court/*"],
    )?
    .lines()
    .filter_map(|l| {
        l.split_once("refs/heads/court/")
            .map(|(_, a)| a.to_string())
    })
    .collect();
    let tree = git_ok(
        &root,
        &[
            "ls-tree",
            "-r",
            "--name-only",
            &format!("{remote}/{base}"),
            "--",
            "courts",
        ],
    )?
    .lines()
    .map(str::to_string)
    .collect();
    let status = |p: &str| -> String {
        git_ok(&root, &["show", &format!("{remote}/{base}:{p}/court.json")])
            .ok()
            .and_then(|t| serde_json::from_str::<Value>(&t).ok())
            .and_then(|v| v["status"].as_str().map(str::to_string))
            .unwrap_or_else(|| "todo".into())
    };
    let r = Remote {
        claimed,
        tree,
        status: &status,
    };
    let seed = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(1, |d| d.as_nanos() as u64 ^ u64::from(std::process::id()));
    let mut last = String::new();
    for a in candidates(&mode, &priority, seed) {
        match ineligible(&a, &index, &r, &remote, &base) {
            None => {
                let path = path_of(&index, &a).unwrap_or_default();
                let report = || println!("alias: {a}\npath: {path}\nbranch: court/{a}");
                if dry {
                    report();
                    println!("(dry run: nothing pushed)");
                    return Ok(ExitCode::SUCCESS);
                }
                let refspec = format!("{sha}:refs/heads/court/{a}");
                let lease = format!("--force-with-lease=refs/heads/court/{a}:");
                let o = git(&root, &["push", "-q", &lease, &remote, &refspec])?;
                if o.status.success() {
                    report();
                    eprintln!("next: git fetch {remote} court/{a} && git worktree add .worktrees/{a} court/{a}");
                    return Ok(ExitCode::SUCCESS);
                }
                let err = String::from_utf8_lossy(&o.stderr);
                last = format!(
                    "lost the race for {a}: {}",
                    err.lines().last().unwrap_or("")
                );
                eprintln!("fb claim: {last}; trying the next court");
            }
            Some(why) => {
                last = why;
                if matches!(mode, Mode::Alias(_)) {
                    break;
                }
            }
        }
    }
    let last = if last.is_empty() {
        "no candidates"
    } else {
        last.as_str()
    };
    Err(fail(1, format!("fb claim: nothing claimed. {last}")))
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn s(a: &[&str]) -> Vec<String> {
        a.iter().map(|x| x.to_string()).collect()
    }

    #[test]
    fn parses_modes_and_flags() {
        assert_eq!(
            parse(&s(&["--next", "--dry-run"])).unwrap(),
            (Mode::Next, true)
        );
        assert_eq!(
            parse(&s(&["ca1"])).unwrap(),
            (Mode::Alias("ca1".into()), false)
        );
        assert_eq!(parse(&s(&["--next", "--random"])).unwrap().0, Mode::Random);
        assert!(parse(&s(&[])).is_err());
        assert!(parse(&s(&["--bogus"])).is_err());
    }

    /// `ineligible("ca1", ...)` for court c1 with the given remote tree, claimed aliases and court.json status.
    fn verdict(tree: &[&str], claimed: &[&str], status: &str) -> Option<String> {
        let index = json!({"courts": {"ca1": {"path": "courts/c1"}}});
        let st = |_: &str| status.to_string();
        let r = Remote {
            claimed: s(claimed),
            tree: s(tree),
            status: &st,
        };
        ineligible("ca1", &index, &r, "origin", "master")
    }

    #[test]
    fn eligibility_reasons() {
        let tree = ["courts/c1/court.json"];
        assert_eq!(verdict(&tree, &[], "todo"), None);
        let index = json!({"courts": {}});
        let st = |_: &str| "todo".to_string();
        let r = Remote {
            claimed: vec![],
            tree: vec![],
            status: &st,
        };
        assert_eq!(
            ineligible("zz", &index, &r, "origin", "master").unwrap(),
            "no such court alias: zz"
        );
        assert!(verdict(&tree, &["ca1"], "todo")
            .unwrap()
            .contains("already claimed"));
        assert!(verdict(&[], &[], "todo")
            .unwrap()
            .contains("is not on origin/master"));
        assert_eq!(verdict(&tree, &[], "done").unwrap(), "ca1 is done");
        let review = [
            "courts/c1/court.json",
            "courts/c1/rules.md",
            "courts/c1/usage/.check-typst.txt",
            "courts/c1/typst/x.typ",
        ];
        assert!(verdict(&review, &[], "todo")
            .unwrap()
            .contains("up for review"));
    }

    #[test]
    fn candidates_skip_reference_courts() {
        let p = json!({"order": ["a", "b", "c"], "reference": ["b"]});
        assert_eq!(candidates(&Mode::Next, &p, 1), s(&["a", "c"]));
        let mut r = candidates(&Mode::Random, &p, 7);
        r.sort();
        assert_eq!(r, s(&["a", "c"]));
        assert_eq!(candidates(&Mode::Alias("zz".into()), &p, 1), s(&["zz"]));
    }
}
