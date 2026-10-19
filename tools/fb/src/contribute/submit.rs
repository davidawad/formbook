//! `fb contribute submit <id> [--dry-run] [--skip-verify] [--base REF] [--offline]`: verify, commit, push
//! contrib/<id> and open (or update and ready) the pull request.
use super::{die, field, git, git_ok, read_json, repo_slug, unit_json, usage, Ctx};
use crate::proc::{capture, have, TempDir};
use crate::{fail, Res};
use std::path::Path;
use std::process::{Command, ExitCode};

/// Lines of SOURCE.md that name a URL, filer, case or docket, at most 12.
fn source_excerpt(source: &str) -> Vec<&str> {
    source
        .lines()
        .filter(|l| {
            ["URL", "Filer", "Case", "Docket"]
                .iter()
                .any(|k| l.contains(k))
        })
        .take(12)
        .collect()
}

/// The pull request body.
pub fn body(id: &str, kind: &str, folder: &str, verify: &str, source: Option<&str>) -> String {
    let exemplars = match source {
        Some(s) if !s.is_empty() => source_excerpt(s).join("\n"),
        _ => "none recorded".into(),
    };
    format!(
        "Work unit: `{id}` ({kind}), folder `{folder}/`.\n\n## Verification\n```\n{verify}```\n\n## Exemplars (public court records)\n{exemplars}\n\n## Tier-2 findings left open / BLOCKED items\n(list by page, from the overlay review; or write: none)\n\n## Disclosure\nPrepared with AI assistance (agent: <name and model>). I reviewed every overlay page. Exemplars are public court records; no sealed or private documents.\n"
    )
}

fn gh(args: &[&str]) -> Res<Option<String>> {
    let o = capture(Command::new("gh").args(args))?;
    Ok(o.status
        .success()
        .then(|| String::from_utf8_lossy(&o.stdout).trim().to_string()))
}

pub fn run(ctx: &Ctx, args: &[String]) -> Res<ExitCode> {
    let (mut id, mut dry, mut skip, mut sbase) = (String::new(), false, false, String::new());
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--dry-run" => dry = true,
            "--skip-verify" => skip = true,
            "--base" => sbase = it.next().ok_or_else(usage)?.clone(),
            "--offline" => {}
            o if o.starts_with('-') => return Err(usage()),
            i => id = i.into(),
        }
    }
    if id.is_empty() {
        return Err(usage());
    }
    let (al, dt) = id.split_once('.').unwrap_or((&id, ""));
    let cp = read_json("data/index.json")["courts"][al]["path"]
        .as_str()
        .map(str::to_string)
        .filter(|p| !p.is_empty());
    let cp = cp.ok_or_else(|| die(format!("unknown court alias in {id}")))?;
    let f = format!("{cp}/{dt}");
    let br = format!("contrib/{id}");
    let slug = repo_slug(ctx)?;
    let wl = read_json("data/worklist.json");
    let kind = unit_json(&wl, &id)
        .map(|u| field(&u, "kind"))
        .filter(|k| !k.is_empty())
        .unwrap_or_else(|| "work".into());

    let verify_text = if skip {
        "verify skipped by --skip-verify\n".to_string()
    } else {
        let exe = std::env::current_exe().map_err(|e| fail(2, format!("fb contribute: {e}")))?;
        let mut c = Command::new(exe);
        c.args(["contribute", "verify", &id]);
        if !sbase.is_empty() {
            c.args(["--base", &sbase]);
        }
        let o = capture(&mut c)?;
        let text = format!(
            "{}{}",
            String::from_utf8_lossy(&o.stdout),
            String::from_utf8_lossy(&o.stderr)
        );
        if !o.status.success() {
            print!("{text}");
            return Err(die("verify failed; fix and rerun (or --skip-verify, which maintainers will see in the PR)"));
        }
        text
    };
    let source = std::fs::read_to_string(Path::new(&f).join("usage/SOURCE.md")).ok();
    let body = body(&id, &kind, &f, &verify_text, source.as_deref());
    let title = format!("feat({al}/{dt}): {kind}");

    if dry {
        println!("dry run: would run: git add {f} && git commit -m '{title}' (if dirty)");
        println!("dry run: would run: git push -u {} HEAD:refs/heads/{br}  (fork remote if no write access)", ctx.remote);
        println!("dry run: would run: gh pr create --repo {slug} --base {} --head {br} --title '{title}' --body-file <body>   (or gh pr ready + edit if a draft claim PR exists)", ctx.base);
        println!(
            "compare URL: https://github.com/{slug}/compare/{}...{br}?expand=1",
            ctx.base
        );
        println!("---- PR body ----");
        print!("{body}");
        return Ok(ExitCode::SUCCESS);
    }

    git_ok(&["add", "--", &f])?;
    if !git_ok(&["diff", "--cached", "--quiet"])? && !git_ok(&["commit", "-q", "-m", &title])? {
        return Err(fail(1, "fb contribute: git commit failed"));
    }
    let mut pushed_to = ctx.remote.as_str();
    let spec = format!("HEAD:refs/heads/{br}");
    let first = git(&["push", "-q", "-u", &ctx.remote, &spec])?;
    if !first.status.success() {
        if git_ok(&["remote", "get-url", "fork"])? && git_ok(&["push", "-q", "-u", "fork", &spec])?
        {
            pushed_to = "fork";
        } else {
            eprint!("{}", String::from_utf8_lossy(&first.stderr));
            return Err(die(format!(
                "push failed (no write access? run: just contribute claim {id} --fork first)"
            )));
        }
    }
    let head_ref = if pushed_to == "fork" {
        format!(
            "{}:{br}",
            gh(&["api", "user", "-q", ".login"])?.unwrap_or_default()
        )
    } else {
        br.clone()
    };
    if have("gh") {
        let tmp = TempDir::new("submit")?;
        let bf = tmp.path().join("body.md");
        std::fs::write(&bf, &body)
            .map_err(|e| fail(2, format!("fb contribute: {}: {e}", bf.display())))?;
        let bf = bf.to_string_lossy().into_owned();
        let existing = gh(&[
            "pr",
            "list",
            "--repo",
            &slug,
            "--state",
            "open",
            "--head",
            &br,
            "--json",
            "number",
            "-q",
            ".[0].number",
        ])?
        .filter(|n| !n.is_empty());
        if let Some(n) = existing {
            gh(&[
                "pr",
                "edit",
                &n,
                "--repo",
                &slug,
                "--title",
                &title,
                "--body-file",
                &bf,
            ])?
            .ok_or_else(|| fail(1, "fb contribute: gh pr edit failed"))?;
            gh(&["pr", "ready", &n, "--repo", &slug])?;
            println!("updated and marked ready: PR #{n}");
        } else {
            let o = Command::new("gh")
                .args([
                    "pr",
                    "create",
                    "--repo",
                    &slug,
                    "--base",
                    &ctx.base,
                    "--head",
                    &head_ref,
                    "--title",
                    &title,
                    "--body-file",
                    &bf,
                ])
                .status()
                .map_err(|e| fail(2, format!("fb contribute: cannot run gh: {e}")))?;
            if !o.success() {
                return Err(fail(1, "fb contribute: gh pr create failed"));
            }
        }
    } else {
        println!(
            "gh not installed. Open: https://github.com/{slug}/compare/{}...{head_ref}?expand=1",
            ctx.base
        );
        println!("title: {title}");
        println!("---- paste as the PR body ----");
        print!("{body}");
    }
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn excerpt_picks_source_lines_up_to_twelve() {
        let src: String = (0..20).map(|i| format!("Filer {i}\nplain\n")).collect();
        let e = source_excerpt(&src);
        assert_eq!(e.len(), 12);
        assert_eq!(e[0], "Filer 0");
    }

    #[test]
    fn body_has_every_section() {
        let b = body(
            "ca1.x",
            "deepen",
            "courts/c1/x",
            "RESULT: PASS (3 checks)\n",
            Some("URL: https://e.org\nnote\n"),
        );
        assert!(b.starts_with("Work unit: `ca1.x` (deepen), folder `courts/c1/x/`."));
        assert!(b.contains("```\nRESULT: PASS (3 checks)\n```"));
        assert!(b.contains("(public court records)\nURL: https://e.org\n\n## Tier-2"));
        assert!(b.contains("## Disclosure"));
    }

    #[test]
    fn body_without_source_says_none() {
        assert!(body("a.b", "work", "c/b", "", None).contains("none recorded"));
        assert!(body("a.b", "work", "c/b", "", Some("")).contains("none recorded"));
    }
}
