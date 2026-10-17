//! Per-folder READMEs and the top README index block (tools/gen_readmes.py, fed by the tracker's out/ files).
use crate::{fail, Res};
use std::path::Path;
use std::process::{Command, ExitCode};

pub fn main(_args: &[String]) -> Res<ExitCode> {
    let root = crate::repo_root()?;
    let man = crate::manifest::court_lines(&root)?;
    let dts = crate::manifest::doctype_lines(&root)?;
    let rows = crate::tracker::compute(&man, &dts).rows;
    println!("{}", write_all(&root, &man, &rows)?);
    Ok(ExitCode::SUCCESS)
}

/// Writes every README from the manifest and the tracker rows; returns the summary line.
pub fn write_all(root: &Path, manifest: &str, rows: &str) -> Res<String> {
    let out = root.join("out");
    crate::track::write(&out.join("manifest.txt"), manifest)?;
    crate::track::write(&out.join("rows.txt"), rows)?;
    let run = Command::new("python3")
        .arg(root.join("tools/gen_readmes.py"))
        .arg(out.join("manifest.txt"))
        .arg(out.join("rows.txt"))
        .output()
        .map_err(|e| fail(1, format!("python3: {e}")))?;
    eprint!("{}", String::from_utf8_lossy(&run.stderr));
    match run.status.success() {
        true => Ok(String::from_utf8_lossy(&run.stdout)
            .trim_end_matches('\n')
            .to_string()),
        false => Err(fail(1, "tools/gen_readmes.py failed")),
    }
}
