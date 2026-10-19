//! `fb contribute claim <id> [--dry-run] [--fork] [--no-worktree] [--offline]`: atomically claim a unit.
use super::{
    claimed_set, die, field, git, git_ok, git_out, load_worklist, repo_slug, unit_json, unit_state,
    usage, Ctx, Net,
};
use crate::proc::{capture, have};
use crate::{fail, Res};
use std::path::Path;
use std::process::{Command, ExitCode};

fn gh(args: &[&str]) -> Res<Option<String>> {
    let o = capture(Command::new("gh").args(args))?;
    Ok(o.status
        .success()
        .then(|| String::from_utf8_lossy(&o.stdout).trim().to_string()))
}

pub fn run(ctx: &Ctx, root: &Path, args: &[String]) -> Res<ExitCode> {
    let (mut id, mut dry, mut fork, mut wt, mut offline) =
        (String::new(), false, false, true, false);
    for a in args {
        match a.as_str() {
            "--dry-run" => dry = true,
            "--fork" => fork = true,
            "--no-worktree" => wt = false,
            "--offline" => offline = true,
            o if o.starts_with('-') => return Err(usage()),
            i => id = i.into(),
        }
    }
    if id.is_empty() {
        return Err(usage());
    }
    let net = if offline { Net::Offline } else { Net::Online };
    let wl = load_worklist(ctx, net)?;
    let u = unit_json(&wl, &id)
        .ok_or_else(|| die(format!("no such unit: {id} (not in data/worklist.json)")))?;
    let (al, cp, dt, kind) = (
        field(&u, "alias"),
        field(&u, "court_path"),
        field(&u, "doctype"),
        field(&u, "kind"),
    );
    git_ok(&["fetch", "-q", &ctx.remote, &ctx.base])?;
    if unit_state(&cp, &dt) == "complete" {
        return Err(die(format!(
            "{id} is already complete in this checkout; git pull and run: just contribute pick"
        )));
    }
    if claimed_set(ctx, net)?.is_claimed(&id, &al) {
        return Err(die(format!(
            "{id} is already claimed (a contrib/{id} or court/{al} branch, or an open PR, exists). Run: just contribute pick"
        )));
    }
    let br = format!("contrib/{id}");
    let sha = git_out(&["rev-parse", &ctx.remote_base()])?
        .map(|s| s.trim().to_string())
        .unwrap_or_default();
    let wt_dir = format!(".worktrees/{id}");
    if dry {
        println!("dry run: {id} is open and unclaimed.");
        println!("would run: git push --force-with-lease=refs/heads/{br}: {} {sha}:refs/heads/{br}   (atomic: fails if {br} exists)", ctx.remote);
        println!("would run: git worktree add {wt_dir} -b {br} {sha}");
        println!("no write access: would use the fork workflow instead (gh repo fork; draft PR {br} = the claim)");
        return Ok(ExitCode::SUCCESS);
    }
    let mut push_err = String::new();
    if !fork {
        let o = git(&[
            "push",
            "-q",
            &format!("--force-with-lease=refs/heads/{br}:"),
            &ctx.remote,
            &format!("{sha}:refs/heads/{br}"),
        ])?;
        if o.status.success() {
            println!(
                "claimed: {id}  (remote branch {br} created from {})",
                ctx.remote_base()
            );
            if wt {
                git_ok(&["fetch", "-q", &ctx.remote, &br])?;
                let remote_br = format!("{}/{br}", ctx.remote);
                if git_ok(&["worktree", "add", "-q", &wt_dir, "-B", &br, &remote_br])? {
                    git_ok(&[
                        "-C",
                        &wt_dir,
                        "branch",
                        "-q",
                        &format!("--set-upstream-to={remote_br}"),
                    ])?;
                }
                println!("worktree: {}/{wt_dir}   (work only there)", root.display());
            }
            println!("next: just contribute brief {id}");
            return Ok(ExitCode::SUCCESS);
        }
        push_err = String::from_utf8_lossy(&o.stderr).to_lowercase();
    }
    if !fork
        && ["already exists", "stale info", "rejected"]
            .iter()
            .any(|m| push_err.contains(m))
    {
        return Err(die(format!(
            "lost the race: {br} was created by someone else first. Run: just contribute pick"
        )));
    }
    // no write access: fork workflow. The claim is a draft PR whose head branch is contrib/<id>.
    if !have("gh") {
        return Err(die(format!(
            "no push access to {} and gh is not installed. Fork the repo on GitHub, add your fork as a remote, push {br} there, and open a draft PR titled 'claim({id})'.",
            ctx.remote
        )));
    }
    let login = gh(&["api", "user", "-q", ".login"])?
        .ok_or_else(|| die("gh is not logged in (gh auth login)"))?;
    let slug = repo_slug(ctx)?;
    let name = slug.split('/').nth(1).unwrap_or("").to_string();
    gh(&["repo", "fork", &slug, "--clone=false"])?;
    let url = gh(&[
        "repo",
        "view",
        &format!("{login}/{name}"),
        "--json",
        "url",
        "-q",
        ".url",
    ])?
    .ok_or_else(|| die("cannot read the fork URL"))?;
    if !git_ok(&["remote", "get-url", "fork"])? {
        git_ok(&["remote", "add", "fork", &format!("{url}.git")])?;
    }
    git_ok(&["fetch", "-q", "fork"])?;
    let must = |ok: bool, what: &str| {
        ok.then_some(())
            .ok_or_else(|| fail(1, format!("fb contribute: {what} failed")))
    };
    must(
        git_ok(&["worktree", "add", "-q", &wt_dir, "-B", &br, &sha])?,
        "git worktree add",
    )?;
    must(
        git_ok(&[
            "-C",
            &wt_dir,
            "commit",
            "-q",
            "--allow-empty",
            "-m",
            &format!("claim({id}): start {kind}"),
        ])?,
        "git commit",
    )?;
    must(
        git_ok(&["-C", &wt_dir, "push", "-q", "-u", "fork", &br])?,
        "git push",
    )?;
    let body = format!("Claim of work unit `{id}` (see CONTRIBUTING.md). Draft until the work is verified; `just contribute submit {id}` marks it ready.");
    must(
        gh(&[
            "pr",
            "create",
            "--repo",
            &slug,
            "--base",
            &ctx.base,
            "--head",
            &format!("{login}:{br}"),
            "--draft",
            "--title",
            &format!("claim({id}): {kind}"),
            "--body",
            &body,
        ])?
        .is_some(),
        "gh pr create",
    )?;
    println!("claimed via fork: {id}  (draft PR from {login}:{br})");
    println!("worktree: {}/{wt_dir}", root.display());
    println!("next: just contribute brief {id}");
    Ok(ExitCode::SUCCESS)
}
