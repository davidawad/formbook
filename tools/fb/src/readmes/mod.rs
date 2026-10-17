//! `fb readmes`: every court and folder README.md plus the index block of the top README.md, from the
//! manifest and the tracker rows. Court and folder READMEs are written only between the
//! `<!-- fb:generated:start/end -->` markers (see markers.rs); everything outside them is kept.
mod gen;
mod markers;

use crate::track::{io_fail, write};
use crate::{fail, Res};
use std::fs;
use std::path::Path;
use std::process::ExitCode;

pub fn main(args: &[String]) -> Res<ExitCode> {
    match args {
        [] => {
            let root = crate::repo_root()?;
            let man = crate::manifest::court_lines(&root)?;
            let dts = crate::manifest::doctype_lines(&root)?;
            let rows = crate::tracker::compute(&man, &dts).rows;
            println!("{}", write_all(&root, &man, &rows)?);
            Ok(ExitCode::SUCCESS)
        }
        _ => Err(fail(2, "usage: fb readmes")),
    }
}

/// Text as Python's text mode reads it (universal newlines).
fn read_text(p: &Path) -> Res<String> {
    fs::read_to_string(p)
        .map(|s| s.replace("\r\n", "\n").replace('\r', "\n"))
        .map_err(|e| io_fail(p, e))
}

fn read_if_present(p: &Path) -> Res<Option<String>> {
    match p.is_file() {
        true => read_text(p).map(Some),
        false => Ok(None),
    }
}

/// Writes `generated` into the README at `p`, keeping what lies outside the markers.
fn put(p: &Path, generated: &str) -> Res<()> {
    let current = read_if_present(p)?;
    let text = markers::place(current.as_deref(), generated)
        .map_err(|e| fail(1, format!("{}: {e}", p.display())))?;
    match current.as_deref() == Some(text.as_str()) {
        true => Ok(()),
        false => write(p, &text),
    }
}

/// Writes every README from the manifest and the tracker rows; returns the summary line.
pub fn write_all(root: &Path, manifest: &str, rows: &str) -> Res<String> {
    let idx = crate::manifest::read_json(&root.join("data/index.json"))?;
    let empty = serde_json::Map::new();
    let inputs = gen::Inputs {
        courts: idx["courts"].as_object().unwrap_or(&empty),
        legacy: idx["legacy_aliases"].as_object().unwrap_or(&empty),
        unplaced: idx["unplaced"].as_array().map_or(&[][..], Vec::as_slice),
        manual: gen::manual(manifest),
        rows: gen::rows(rows),
    };
    let e1 = |e: String| fail(1, format!("fb readmes: {e}"));
    inputs.courts.iter().try_for_each(|(a, c)| {
        let dir = root.join(gen::py_str(&c["path"]));
        let extra = read_if_present(&dir.join("README.extra.md"))?;
        put(
            &dir.join("README.md"),
            &inputs.leaf(a, extra.as_deref()).map_err(e1)?,
        )
    })?;
    let folders = inputs.folders();
    folders.iter().try_for_each(|d| {
        put(
            &root.join(d).join("README.md"),
            &inputs.folder(d).map_err(e1)?,
        )
    })?;
    let top = root.join("README.md");
    let s = read_text(&top)?;
    let [a, b] = ["<!-- index:start -->", "<!-- index:end -->"].map(|m| s.find(m));
    let (a, b) = a
        .zip(b)
        .ok_or_else(|| fail(1, "README.md: no <!-- index:start/end --> markers"))?;
    let block = inputs.index_block().map_err(e1)?;
    write(
        &top,
        &format!("{}<!-- index:start -->\n{block}\n{}", &s[..a], &s[b..]),
    )?;
    Ok(format!(
        "readmes written for {} leaves, {} folders",
        inputs.courts.len(),
        folders.len()
    ))
}
