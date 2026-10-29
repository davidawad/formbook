//! `fb engines`: latex and docx engines generated from a state folder's typst template and the shared
//! cross-engine libraries (fb-595.54.12).
//!
//!   fb engines families [--threshold T] [--top N] [--json FILE]
//!       cluster the state typst templates into families (families.rs) and print the table
//!   fb engines gen <doc-folder> [--check]
//!       write latex/template.tex and docx/reference.xml (+ the docx filter) for a folder whose typst template is
//!       on the shared model (gen.rs); --check writes nothing and exits 1 when a generated file differs
pub mod base;
pub mod families;
pub mod gen;
mod tex;
mod word;

use crate::{fail, Res};
use families::{cluster, state_templates, Template};
use std::path::Path;

pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    match args.first().map(String::as_str) {
        Some("families") => families_main(&args[1..]).map(|_| std::process::ExitCode::SUCCESS),
        Some("gen") => gen::main(&args[1..]),
        _ => Err(fail(
            2,
            "usage: fb engines families [--threshold T] [--top N] [--json FILE] | gen <doc-folder>... [--check]",
        )),
    }
}

fn opt<'a>(args: &'a [String], name: &str) -> Option<&'a str> {
    args.iter()
        .position(|a| a == name)
        .and_then(|i| args.get(i + 1))
        .map(String::as_str)
}

/// The engines a folder has besides typst: `latex` (latex/template.tex or render.sh), `docx`, `docx-sh` (a
/// docx/*.sh, owned by fb-595.68 step 2).
pub fn engines_of(folder: &Path) -> Vec<&'static str> {
    let mut v = Vec::new();
    if folder.join("latex/template.tex").is_file() || folder.join("latex/render.sh").is_file() {
        v.push("latex");
    }
    let docx = folder.join("docx");
    if docx.is_dir() && std::fs::read_dir(&docx).is_ok_and(|mut r| r.next().is_some()) {
        v.push("docx");
        let sh = std::fs::read_dir(&docx).is_ok_and(|r| {
            r.filter_map(|e| e.ok())
                .any(|e| e.path().extension().is_some_and(|x| x == "sh"))
        });
        if sh {
            v.push("docx-sh");
        }
    }
    v
}

/// The size histogram of a clustering: (family size, count), largest first.
pub fn histogram(fams: &[Vec<usize>]) -> Vec<(usize, usize)> {
    let mut h: std::collections::BTreeMap<usize, usize> = Default::default();
    for f in fams {
        *h.entry(f.len()).or_default() += 1;
    }
    h.into_iter().rev().collect()
}

fn families_main(args: &[String]) -> Res<()> {
    let root = crate::repo_root()?;
    let th: f64 = opt(args, "--threshold")
        .map(|s| {
            s.parse()
                .map_err(|_| fail(2, "fb engines families: bad --threshold"))
        })
        .transpose()?
        .unwrap_or(0.9);
    let top: usize = opt(args, "--top")
        .and_then(|s| s.parse().ok())
        .unwrap_or(15);
    let ts = state_templates(&root);
    let mut by_eng: std::collections::BTreeMap<String, usize> = Default::default();
    for t in &ts {
        let e = engines_of(&root.join(&t.folder));
        *by_eng.entry(format!("typst+{}", e.join("+"))).or_default() += 1;
    }
    println!("state doc folders with a typst template: {}", ts.len());
    for (k, n) in &by_eng {
        println!("  {}: {n}", k.trim_end_matches('+'));
    }
    let exact = cluster(&ts, None);
    let single = |f: &[Vec<usize>]| f.iter().filter(|g| g.len() == 1).count();
    println!(
        "exact families (same code modulo strings, numbers and the template name): {} ({} of one folder)",
        exact.len(),
        single(&exact)
    );
    let mut levels = Vec::new();
    for t in [0.95, 0.9, 0.8, 0.7, 0.6, 0.5] {
        let f = cluster(&ts, Some(t));
        println!(
            "near families, 5-token shingle Jaccard >= {t}: {} ({} of one folder; largest {})",
            f.len(),
            single(&f),
            f.first().map_or(0, |g| g.len())
        );
        levels.push((t, f));
    }
    let fams = cluster(&ts, Some(th));
    println!(
        "\nfamilies at {th}, size histogram (size x count): {:?}",
        histogram(&fams)
    );
    println!("\n| family | size | doc types | states | representative |\n|---|---|---|---|---|");
    for (i, f) in fams.iter().take(top).enumerate() {
        println!("{}", row(i + 1, f, &ts));
    }
    if let Some(out) = opt(args, "--json") {
        let j = serde_json::json!({
            "templates": ts.len(),
            "engines": by_eng,
            "exact": exact.len(),
            "levels": levels.iter().map(|(t, f)| serde_json::json!({
                "threshold": t, "families": f.len(), "singletons": single(f),
                "histogram": histogram(f),
            })).collect::<Vec<_>>(),
            "threshold": th,
            "families": fams.iter().map(|f| f.iter().map(|&i| ts[i].folder.display().to_string())
                .collect::<Vec<_>>()).collect::<Vec<_>>(),
        });
        std::fs::write(out, serde_json::to_string_pretty(&j).unwrap() + "\n")
            .map_err(|e| fail(2, format!("fb engines families: {out}: {e}")))?;
    }
    Ok(())
}

/// The state of a folder (the path component before `state`) and its doc type (the last component).
pub fn state_and_type(folder: &Path) -> (String, String) {
    let c: Vec<String> = folder
        .components()
        .map(|c| c.as_os_str().to_string_lossy().to_string())
        .collect();
    let st = c
        .iter()
        .position(|x| x == "state")
        .and_then(|i| i.checked_sub(1));
    (
        st.map(|i| c[i].clone()).unwrap_or_default(),
        c.last().cloned().unwrap_or_default(),
    )
}

fn row(n: usize, f: &[usize], ts: &[Template]) -> String {
    let mut types = std::collections::BTreeSet::new();
    let mut states = std::collections::BTreeSet::new();
    for &i in f {
        let (s, t) = state_and_type(&ts[i].folder);
        states.insert(s);
        types.insert(t);
    }
    let cut = |s: std::collections::BTreeSet<String>| {
        let v: Vec<String> = s.into_iter().collect();
        if v.len() > 4 {
            format!("{} (+{})", v[..4].join(", "), v.len() - 4)
        } else {
            v.join(", ")
        }
    };
    format!(
        "| {n} | {} | {} | {} | {} |",
        f.len(),
        cut(types),
        cut(states),
        ts[f[0]].folder.display()
    )
}

#[cfg(test)]
pub mod model_tests;
#[cfg(test)]
mod tests;
