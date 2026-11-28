//! `fb build <alias> <doctype> <brief.md> [out.pdf] --judge <slug> [--paper P] [--engine E] [--allow-unverified]`:
//! a filing rendered on the court's layout under one judge's standing order (docs/JUDGES.md).
//!
//! No court folder and no shared library changes. The court's resolved layout, with the judge's facts applied
//! (apply.rs), is written as a doc folder of its own under the gitignored `out/judges/<alias>/<slug>/<doctype>/`:
//! its `typst/layout.yaml`, a `typst/main.typ` on the shared document model with the court template's face, and the
//! latex and docx engines `fb engines gen` generates from them. The filing is then rendered there by the usual
//! renderer, so all three engines set the judge's layout the way they set a court's.
use super::apply::{self, CourtLayer, Ctx, Outcome};
use super::{profile_path, read_profile, Profile};
use crate::{fail, Res};
use serde_yaml::Value;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

/// What `fb build` was asked for besides its positional arguments.
#[derive(Debug, Default, PartialEq)]
pub struct Opts {
    pub judge: Option<String>,
    pub paper: Option<String>,
    pub engine: Option<String>,
    pub allow_unverified: bool,
}

/// The options of `fb build` split from its positional arguments.
pub fn split_args(args: &[String]) -> Res<(Vec<String>, Opts)> {
    let mut pos = Vec::new();
    let mut o = Opts::default();
    let mut it = args.iter();
    while let Some(a) = it.next() {
        let mut value = |name: &str| {
            it.next()
                .cloned()
                .ok_or_else(|| fail(2, format!("fb build: {name} needs a value")))
        };
        match a.as_str() {
            "--judge" => o.judge = Some(value("--judge")?),
            "--paper" => o.paper = Some(value("--paper")?),
            "--engine" => o.engine = Some(value("--engine")?),
            "--allow-unverified" => o.allow_unverified = true,
            s if s.starts_with("--") => {
                return Err(fail(2, format!("fb build: unknown option {s}")))
            }
            _ => pos.push(a.clone()),
        }
    }
    Ok((pos, o))
}

/// The YAML frontmatter of a markdown filing.
pub fn frontmatter(md: &str) -> Option<Value> {
    let rest = md.strip_prefix("---")?.trim_start_matches([' ', '\t']);
    let rest = rest
        .strip_prefix("\r\n")
        .or_else(|| rest.strip_prefix('\n'))?;
    let end = rest.find("\n---")?;
    serde_yaml::from_str(&rest[..end]).ok()
}

fn meta_str(meta: Option<&Value>, key: &str) -> Option<String> {
    meta?
        .get(key)?
        .as_str()
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .map(str::to_string)
}

/// The judge a filing's frontmatter names (`judge_profile: <slug>`; `judge` is a display name in some courts' inputs).
pub fn judge_named(md: &str) -> Option<String> {
    meta_str(
        frontmatter(&std::fs::read_to_string(md).ok()?).as_ref(),
        "judge_profile",
    )
}

/// The paper a filing is: `memorandum` (a motion's memorandum, the default), `opposition` or `reply`.
pub fn paper_of(name: &str) -> Res<&'static str> {
    match name.trim().to_lowercase().as_str() {
        "memorandum" | "motion" | "" => Ok("memorandum"),
        "opposition" => Ok("opposition"),
        "reply" => Ok("reply"),
        other => Err(fail(
            2,
            format!("fb build: paper `{other}`: memorandum, opposition or reply"),
        )),
    }
}

/// The court folder of a doc folder: its nearest ancestor with a court.json.
fn court_of(folder: &Path) -> Res<PathBuf> {
    folder
        .ancestors()
        .find(|d| d.join("court.json").is_file())
        .map(Path::to_path_buf)
        .ok_or_else(|| {
            fail(
                2,
                format!("fb build: {} is under no court.json", folder.display()),
            )
        })
}

/// The court's own settings for the judge layer (`<court>/judges/_court.yaml`), if it has any.
fn court_layer(court: &Path) -> Res<CourtLayer> {
    let p = court.join("judges/_court.yaml");
    match std::fs::read_to_string(&p) {
        Ok(t) => serde_yaml::from_str(&t)
            .map_err(|e| fail(2, format!("fb judges: {}: {e}", p.display()))),
        Err(_) => Ok(CourtLayer::default()),
    }
}

/// The court's resolved layout of a doc folder on the shared document model.
fn resolved_layout(root: &Path, folder: &Path) -> Res<Value> {
    let p = folder.join("typst/layout.yaml");
    let text = std::fs::read_to_string(&p).map_err(|_| {
        fail(1, format!("fb judges: {} has no typst/layout.yaml: a judge's layer needs a doc type on the shared document model", folder.display()))
    })?;
    let l: Value = serde_yaml::from_str(&text)
        .map_err(|e| fail(2, format!("fb judges: {}: {e}", p.display())))?;
    crate::enginegen::base::resolve(l, &crate::enginegen::base::reader(root))
        .map_err(|e| fail(2, format!("fb judges: {}: {e}", p.display())))
}

/// The judge's facts over the court's layout of `folder`, for one paper.
pub fn outcome(
    root: &Path,
    folder: &Path,
    p: &Profile,
    paper: &str,
    order_date: Option<&str>,
    allow_unverified: bool,
) -> Res<Outcome> {
    let layout = resolved_layout(root, folder)?;
    let face = crate::typstface::face(folder).ok_or_else(|| {
        fail(
            2,
            format!(
                "fb judges: {}: the typst template names no face",
                folder.display()
            ),
        )
    })?;
    let court = court_layer(&court_of(folder)?)?;
    Ok(apply::apply(
        &layout,
        p,
        &Ctx {
            paper,
            face: &face,
            order_date,
            allow_unverified,
            court: &court,
        },
    ))
}

/// The court template's `#let font-family = ..` line: the judge's folder sets the same faces.
fn face_binding(folder: &Path) -> Res<String> {
    let mut files: Vec<PathBuf> = std::fs::read_dir(folder.join("typst"))
        .into_iter()
        .flatten()
        .flatten()
        .map(|e| e.path())
        .filter(|p| p.extension().is_some_and(|x| x == "typ"))
        .collect();
    files.sort();
    for f in files {
        let text = std::fs::read_to_string(&f).unwrap_or_default();
        if !text.contains("xdoc(yaml(\"layout.yaml\") + (font: font-family), meta, body)") {
            continue;
        }
        if let Some(l) = text.lines().find(|l| l.starts_with("#let font-family =")) {
            return Ok(l.to_string());
        }
    }
    Err(fail(1, format!("fb judges: {}: its typst template is not `xdoc(yaml(\"layout.yaml\") + (font: font-family), meta, body)`: a judge's layer needs the shared document model", folder.display())))
}

/// The judge's doc folder under out/: the layout, the typst entry point and the generated engines.
fn materialize(
    root: &Path,
    folder: &Path,
    alias: &str,
    slug: &str,
    layout: &Value,
) -> Res<PathBuf> {
    let name = folder.file_name().unwrap_or_default();
    let dir = root.join("out/judges").join(alias).join(slug).join(name);
    let bad = |e: std::io::Error| fail(2, format!("fb build: {}: {e}", dir.display()));
    if dir.exists() {
        std::fs::remove_dir_all(&dir).map_err(bad)?;
    }
    std::fs::create_dir_all(dir.join("typst")).map_err(bad)?;
    let rel = folder
        .strip_prefix(root)
        .unwrap_or(folder)
        .display()
        .to_string();
    let yaml = serde_yaml::to_string(layout).map_err(|e| fail(2, format!("fb build: {e}")))?;
    std::fs::write(
        dir.join("typst/layout.yaml"),
        format!("# Generated by `fb build --judge {slug}`: the resolved layout of {rel} under the judge's standing order\n# (docs/JUDGES.md). Do not edit, do not commit.\n{yaml}"),
    )
    .map_err(bad)?;
    // the court template's shape: main.typ reads the filing, the template it imports names the face
    // (typstface.rs reads the face from main.typ's imports)
    std::fs::write(
        dir.join("typst/judge-layer.typ"),
        format!(
            "// Generated by `fb build --judge {slug}` (tools/fb/src/judges/build.rs): {rel} under the judge's standing order.\n#import \"/lib/typst/xdoc.typ\": xdoc, split-frontmatter\n{}\n#let judge-layer(meta, body) = xdoc(yaml(\"layout.yaml\") + (font: font-family), meta, body)\n",
            face_binding(folder)?
        ),
    )
    .map_err(bad)?;
    std::fs::write(
        dir.join("typst/main.typ"),
        "#import \"judge-layer.typ\": judge-layer, split-frontmatter\n#let src = read(\"/\" + sys.inputs.at(\"sample\"))\n#let (meta, body) = split-frontmatter(src)\n#judge-layer(meta, body)\n",
    )
    .map_err(bad)?;
    for (rel, text) in crate::enginegen::gen::for_folder(&dir)? {
        let p = dir.join(rel);
        if let Some(d) = p.parent() {
            std::fs::create_dir_all(d).map_err(bad)?;
        }
        std::fs::write(&p, text).map_err(bad)?;
    }
    Ok(dir)
}

/// `fb build` with a judge: `folder` is the court's doc folder (from the repo root), `md` the filing.
pub fn build(
    root: &Path,
    alias: &str,
    folder: &str,
    md: &str,
    out: Option<&str>,
    o: &Opts,
    slug: &str,
) -> Res<ExitCode> {
    let folder = root.join(folder);
    let court = court_of(&folder)?;
    let profile = read_profile(&profile_path(&court, slug)).map_err(|e| {
        fail(1, format!("{}\nfb build: no profile for judge '{slug}' of {alias} (fb judges list {alias}; fb judges sync {alias})", e.msg))
    })?;
    let src = std::fs::canonicalize(md).map_err(|e| fail(2, format!("fb build: {md}: {e}")))?;
    let text =
        std::fs::read_to_string(&src).map_err(|e| fail(2, format!("fb build: {md}: {e}")))?;
    let meta = frontmatter(&text);
    let paper = paper_of(
        &o.paper
            .clone()
            .or_else(|| meta_str(meta.as_ref(), "paper"))
            .unwrap_or_default(),
    )?;
    let date = meta_str(meta.as_ref(), "word_limit_order_date");
    let engine = o.engine.as_deref().unwrap_or("typst");
    if !matches!(engine, "typst" | "latex" | "docx") {
        return Err(fail(2, format!("fb build: unknown engine {engine}")));
    }
    let res = outcome(
        root,
        &folder,
        &profile,
        paper,
        date.as_deref(),
        o.allow_unverified,
    )?;
    println!(
        "judge    : {} ({alias}); the paper: {paper}",
        profile.judge.name
    );
    for l in &res.lines {
        println!("  {l}");
    }
    if res.blocked() {
        return Err(fail(1, format!("fb build: not rendered: the judge's order and the layout disagree above (fb judges show {alias} {slug})")));
    }
    // the court folder's exemplar decides whether the pinned Times New Roman is needed, as it does for the court's own
    // renders (render.rs): the judge's folder under out/ has no exemplar of its own
    if engine == "typst" && crate::fonts::has_times_exemplar(root, &folder)? {
        crate::pin::tnr_dir(root)?;
    }
    let dir = materialize(root, &folder, alias, slug, &res.layout)?;
    let out = match out {
        Some(p) => PathBuf::from(p),
        None => {
            let s = src.to_string_lossy();
            PathBuf::from(format!("{}.pdf", s.strip_suffix(".md").unwrap_or(&s)))
        }
    };
    let out = if out.is_absolute() {
        out
    } else {
        std::env::current_dir()
            .map_err(|e| fail(2, format!("fb build: {e}")))?
            .join(out)
    };
    std::fs::copy(&src, dir.join("filing.md")).map_err(|e| fail(2, format!("fb build: {e}")))?;
    crate::render::render_one(
        root,
        engine,
        &dir,
        Path::new("filing.md"),
        &out,
        crate::render::Warnings::Deny,
    )?;
    println!("{}", out.display());
    let open: Vec<&super::Item> = profile.checklist.iter().collect();
    if !open.is_empty() {
        println!(
            "before you file (the render does not enforce these; fb judges show {alias} {slug}):"
        );
        for i in open {
            println!(
                "  - {}{}",
                i.topic,
                i.url.as_ref().map(|u| format!(": {u}")).unwrap_or_default()
            );
        }
    }
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn s(v: &[&str]) -> Vec<String> {
        v.iter().map(|x| x.to_string()).collect()
    }

    #[test]
    fn options_are_split_from_positionals() {
        let (pos, o) = split_args(&s(&[
            "cacd",
            "motion-brief",
            "b.md",
            "--judge",
            "doe-jane",
            "o.pdf",
            "--paper",
            "reply",
            "--allow-unverified",
        ]))
        .unwrap();
        assert_eq!(pos, s(&["cacd", "motion-brief", "b.md", "o.pdf"]));
        assert_eq!(
            o,
            Opts {
                judge: Some("doe-jane".into()),
                paper: Some("reply".into()),
                engine: None,
                allow_unverified: true
            }
        );
        assert!(split_args(&s(&["a", "--judge"])).is_err());
        assert!(split_args(&s(&["a", "--nope"])).is_err());
    }

    #[test]
    fn frontmatter_names_the_judge_the_paper_and_the_order() {
        let m = frontmatter("---\njudge_profile: doe-jane\npaper: Reply\nword_limit_order_date: \"March 3, 2026\"\n---\n# I\n");
        assert_eq!(
            meta_str(m.as_ref(), "judge_profile").as_deref(),
            Some("doe-jane")
        );
        assert_eq!(
            paper_of(&meta_str(m.as_ref(), "paper").unwrap()).unwrap(),
            "reply"
        );
        assert_eq!(
            meta_str(m.as_ref(), "word_limit_order_date").as_deref(),
            Some("March 3, 2026")
        );
        assert_eq!(paper_of("").unwrap(), "memorandum");
        assert_eq!(paper_of("motion").unwrap(), "memorandum");
        assert!(paper_of("sur-reply").is_err());
        assert!(frontmatter("# no frontmatter\n").is_none());
    }
}
