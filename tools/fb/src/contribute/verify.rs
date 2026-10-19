//! `fb contribute verify <id> [--base REF]`: the mechanical floor a unit must clear before it is submitted:
//! layout, a warning-free render of every INPUT, committed OUTPUTs, exemplar sources, depth, no case-specific
//! text in typst/, and nothing changed outside the unit's folder.
use super::scan::{cut, dockets, leaked, probes};
use super::{field, git_out, load_worklist, min_pages, read_json, unit_json, usage, Ctx, Net};
use crate::proc::{capture, have, tail, TempDir};
use crate::worklist::files;
use crate::{fail, Res};
use std::collections::BTreeSet;
use std::path::Path;
use std::process::{Command, ExitCode};

/// PASS/FAIL accumulator that prints each line as the shell version did.
#[derive(Default)]
struct Tally {
    pass: usize,
    fail: usize,
}

/// The outcome of one predicate.
#[derive(Clone, Copy)]
enum Verdict {
    Pass,
    Fail,
}

// type-strength: allow(bool-param) the one place a boolean predicate becomes a Verdict
fn verdict(ok: bool) -> Verdict {
    if ok {
        Verdict::Pass
    } else {
        Verdict::Fail
    }
}

impl Tally {
    fn check(&mut self, v: Verdict, pass: impl Into<String>, bad: impl Into<String>) {
        match v {
            Verdict::Pass => self.ok(pass),
            Verdict::Fail => self.bad(bad),
        }
    }

    fn ok(&mut self, m: impl Into<String>) {
        self.pass += 1;
        println!("PASS  {}", m.into());
    }

    fn bad(&mut self, m: impl Into<String>) {
        self.fail += 1;
        println!("FAIL  {}", m.into());
    }

    fn result(&self) -> ExitCode {
        if self.fail == 0 {
            println!("RESULT: PASS ({} checks)", self.pass);
            ExitCode::SUCCESS
        } else {
            println!("RESULT: FAIL ({} failed, {} passed)", self.fail, self.pass);
            ExitCode::from(1)
        }
    }
}

fn count(dir: &Path, keep: impl Fn(&str) -> bool) -> usize {
    files(dir, keep).len()
}

/// Render one INPUT through `fb render --deny-warnings`; the log is what failed.
fn render_input(folder: &str, sid: &str, out: &Path) -> Res<Result<(), String>> {
    let exe = std::env::current_exe().map_err(|e| fail(2, format!("fb contribute: {e}")))?;
    let o = capture(
        Command::new(exe)
            .args([
                "render",
                "--deny-warnings",
                folder,
                &format!("usage/INPUT-{sid}.md"),
            ])
            .arg(out),
    )?;
    let log = format!(
        "{}{}",
        String::from_utf8_lossy(&o.stdout),
        String::from_utf8_lossy(&o.stderr)
    );
    Ok(if o.status.success() {
        Ok(())
    } else {
        Err(tail(&log, 3).replace('\n', " "))
    })
}

/// Files changed against `base` (committed, staged, unstaged and untracked), sorted and distinct.
fn changed_files(base: &str) -> Res<Vec<String>> {
    let mut all = BTreeSet::new();
    let range = format!("{base}...HEAD");
    let cmds: [&[&str]; 3] = [
        &["diff", "--name-only", &range],
        &["diff", "--name-only", "HEAD"],
        &["ls-files", "--others", "--exclude-standard"],
    ];
    for args in cmds {
        all.extend(
            git_out(args)?
                .unwrap_or_default()
                .lines()
                .filter(|l| !l.is_empty())
                .map(str::to_string),
        );
    }
    Ok(all.into_iter().collect())
}

fn verify_ref(ctx: &Ctx, vbase: &str) -> Res<String> {
    let exists =
        |r: &str| -> Res<bool> { Ok(git_out(&["rev-parse", "-q", "--verify", r])?.is_some()) };
    let found = if exists(&ctx.remote_base())? {
        ctx.remote_base()
    } else if exists(&ctx.base)? {
        ctx.base.clone()
    } else {
        String::new()
    };
    Ok(if vbase.is_empty() {
        found
    } else {
        vbase.to_string()
    })
}

pub fn run(ctx: &Ctx, args: &[String]) -> Res<ExitCode> {
    let (mut id, mut vbase) = (String::new(), String::new());
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--base" => vbase = it.next().ok_or_else(usage)?.clone(),
            o if o.starts_with('-') => return Err(usage()),
            i => id = i.into(),
        }
    }
    if id.is_empty() {
        return Err(usage());
    }
    let wl = load_worklist(ctx, Net::Offline)?;
    let unit = unit_json(&wl, &id);
    let (cp, dt) = match &unit {
        Some(u) => (field(u, "court_path"), field(u, "doctype")),
        None => {
            // a finished unit leaves the worklist; fall back to parsing "<alias>.<doctype>" against the index
            let (al, dt) = id.split_once('.').unwrap_or((&id, ""));
            let cp = read_json("data/index.json")["courts"][al]["path"]
                .as_str()
                .map(str::to_string);
            (
                cp.ok_or_else(|| super::die(format!("unknown unit or court alias: {id}")))?,
                dt.to_string(),
            )
        }
    };
    let f = format!("{cp}/{dt}");
    let fp = Path::new(&f);
    let min = min_pages(&dt);
    let mut t = Tally::default();
    println!("verify {id}  ({f}/)");

    // 1. layout
    if !fp.is_dir() {
        t.bad(format!("layout: folder {f}/ does not exist"));
        println!("RESULT: FAIL ({} failed)", t.fail);
        return Ok(ExitCode::from(1));
    }
    let nonempty = |p: &str| std::fs::metadata(fp.join(p)).is_ok_and(|m| m.len() > 0);
    t.check(
        verdict(nonempty("README.md")),
        "layout: README.md",
        "layout: README.md missing or empty",
    );
    t.check(
        verdict(nonempty("typst/main.typ")),
        "layout: typst/main.typ",
        "layout: typst/main.typ missing",
    );
    let nt = count(&fp.join("typst"), |n| n.ends_with(".typ"));
    t.check(
        verdict(nt >= 2),
        "layout: typst template file(s) beside main.typ",
        format!("layout: expected typst/main.typ plus a template file (found {nt} .typ files)"),
    );
    let exemplars = files(fp.join("usage"), |n| {
        n.starts_with("FILED-EXAMPLE-") && n.ends_with(".pdf")
    });
    let ne = exemplars.len();
    t.check(
        verdict(ne >= 1),
        format!("layout: {ne} FILED-EXAMPLE pdf(s)"),
        "layout: no usage/FILED-EXAMPLE-*.pdf (a template without a filed exemplar is BLOCKED, not done)",
    );
    if nonempty("usage/SOURCE.md") {
        t.ok("layout: usage/SOURCE.md");
        let source = std::fs::read_to_string(fp.join("usage/SOURCE.md")).unwrap_or_default();
        for e in &exemplars {
            let b = e
                .file_name()
                .map(|n| n.to_string_lossy().into_owned())
                .unwrap_or_default();
            if !source.contains(&b) {
                t.bad(format!("source: {b} is not described in usage/SOURCE.md"));
            }
        }
        t.check(
            verdict(source.contains("http://") || source.contains("https://")),
            "source: SOURCE.md records a URL",
            "source: SOURCE.md has no http(s) URL for the FILED-EXAMPLE",
        );
    } else if ne >= 1 {
        t.bad("layout: usage/SOURCE.md missing (every FILED-EXAMPLE needs its public source URL)");
    }
    let inputs = files(fp.join("usage"), |n| {
        n.starts_with("INPUT-") && n.ends_with(".md")
    });
    t.check(
        verdict(!inputs.is_empty()),
        format!("layout: {} usage/INPUT-*.md", inputs.len()),
        "layout: no usage/INPUT-*.md",
    );

    // 2. render each INPUT; OUTPUT committed (overlays are generated into the gitignored .overlay/)
    if have("typst") {
        let tmp = TempDir::new("verify")?;
        for inp in &inputs {
            let name = inp
                .file_name()
                .map(|n| n.to_string_lossy().into_owned())
                .unwrap_or_default();
            let sid = name.trim_start_matches("INPUT-").trim_end_matches(".md");
            match render_input(&f, sid, &tmp.path().join(format!("out-{sid}.pdf")))? {
                Ok(()) => t.ok(format!(
                    "render: INPUT-{sid}.md compiles with no typst warnings"
                )),
                Err(log) => t.bad(format!("render: INPUT-{sid}.md failed: {log}")),
            }
            t.check(
                verdict(nonempty(&format!("usage/OUTPUT-{sid}.typst.pdf"))),
                format!("layout: OUTPUT-{sid}.typst.pdf committed"),
                format!("layout: usage/OUTPUT-{sid}.typst.pdf missing for INPUT-{sid}.md"),
            );
        }
    } else {
        t.bad("render: typst not on PATH (run tools/bootstrap.sh and add its bin/ to PATH)");
    }

    // 3. deepen: page count
    let pages = crate::worklist::max_pages(fp);
    if have("pdfinfo") {
        let kind = unit.as_ref().map(|u| field(u, "kind")).unwrap_or_default();
        let minp = min as u32;
        if f64::from(pages) >= min {
            t.ok(format!(
                "depth: longest OUTPUT is {pages} pages (>= {minp})"
            ));
        } else if kind == "deepen" {
            t.bad(format!(
                "depth: longest OUTPUT is {pages} pages; a deepen unit must reach {minp}+"
            ));
        } else {
            let k = if kind.is_empty() { "this unit" } else { &kind };
            println!("NOTE  depth: longest OUTPUT is {pages} pages; a realistic {dt} is {minp}+ (not required for kind {k})");
        }
    }

    // 4. no case-specific text in typst/
    let probe_set: BTreeSet<String> = inputs
        .iter()
        .flat_map(|i| probes(&std::fs::read_to_string(i).unwrap_or_default()))
        .filter(|p| !p.is_empty())
        .collect();
    let typ_text: String = files(fp.join("typst"), |n| n.ends_with(".typ"))
        .iter()
        .map(|p| std::fs::read_to_string(p).unwrap_or_default())
        .collect();
    let hits = leaked(&typ_text, &probe_set, 3);
    let dks = dockets(&typ_text, 3);
    if hits.is_empty() && dks.is_empty() {
        t.ok("content: no case-specific text found in typst/");
    }
    if let Some(h) = hits.first() {
        t.bad(format!(
            "content: typst/ contains text copied from a sample: {}",
            cut(h, 120)
        ));
    }
    if let Some(d) = dks.first() {
        t.bad(format!(
            "content: typst/ contains a docket number: {}",
            cut(d, 120)
        ));
    }

    // 5. scope: nothing changed outside the unit's folder
    let b = verify_ref(ctx, &vbase)?;
    if b.is_empty() {
        t.bad(format!(
            "scope: cannot find {} or {} to diff against (pass --base REF)",
            ctx.remote_base(),
            ctx.base
        ));
    } else {
        let changed = changed_files(&b)?;
        let stray: Vec<&str> = changed
            .iter()
            .filter(|c| !c.starts_with(&format!("{f}/")))
            .take(5)
            .map(String::as_str)
            .collect();
        if stray.is_empty() {
            t.ok(format!(
                "scope: only {f}/ changed vs {b} ({} files)",
                changed.len()
            ));
        } else {
            t.bad(format!(
                "scope: files outside {f}/ changed: {}",
                stray.join(" ")
            ));
        }
        if changed.iter().any(|c| c.ends_with("court.json")) {
            t.bad("scope: a court.json changed (status done is set by the maintainer only)");
        }
    }
    Ok(t.result())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tally_counts() {
        let mut t = Tally::default();
        t.ok("a");
        t.bad("b");
        assert_eq!((t.pass, t.fail), (1, 1));
    }
}
