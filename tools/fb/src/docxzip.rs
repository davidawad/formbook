//! Reproducible .docx archives: every docx `fb render` writes (one pandoc pass, the multi-pass build of docxpass.rs,
//! or a court's own docx/render.sh) is packed again with its parts dated SOURCE_DATE_EPOCH (fb render sets it), in
//! byte order, with no directory entries and the times in UTC, so a re-render gives the same bytes.
use crate::{fail, Res};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

fn io(path: &Path, e: std::io::Error) -> crate::Fail {
    fail(2, format!("fb render: {}: {e}", path.display()))
}

/// Every file under `dir`, relative, in byte order.
pub fn files(dir: &Path) -> Vec<PathBuf> {
    let mut stack = vec![dir.to_path_buf()];
    let mut out = vec![];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                stack.push(p);
            } else if let Ok(rel) = p.strip_prefix(dir) {
                out.push(rel.to_path_buf());
            }
        }
    }
    out.sort();
    out
}

/// SOURCE_DATE_EPOCH, or 0 when unset or not a number.
fn epoch() -> u64 {
    std::env::var("SOURCE_DATE_EPOCH")
        .ok()
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap_or(0)
}

/// Unpack `docx` into `dir` (which must not exist yet, or is replaced).
pub fn unpack(docx: &Path, dir: &Path) -> Res<()> {
    let _ = std::fs::remove_dir_all(dir);
    let o = crate::proc::capture(Command::new("unzip").arg("-q").arg(docx).arg("-d").arg(dir))?;
    if o.status.success() {
        return Ok(());
    }
    eprint!("{}", String::from_utf8_lossy(&o.stderr));
    Err(fail(1, "fb render: unzip failed"))
}

/// Write the files under `dir` to the archive `docx` (replaced): dated SOURCE_DATE_EPOCH, in byte order.
pub fn pack(dir: &Path, docx: &Path) -> Res<()> {
    pack_at(dir, docx, epoch())
}

fn pack_at(dir: &Path, docx: &Path, secs: u64) -> Res<()> {
    let when = std::time::UNIX_EPOCH + std::time::Duration::from_secs(secs);
    let list = files(dir);
    for f in &list {
        let p = dir.join(f);
        std::fs::File::options()
            .write(true)
            .open(&p)
            .and_then(|h| h.set_modified(when))
            .map_err(|e| io(&p, e))?;
    }
    let _ = std::fs::remove_file(docx);
    let mut zip = Command::new("zip")
        .current_dir(dir)
        .env("TZ", "UTC")
        .args(["-X", "-D", "-q"])
        .arg(docx)
        .arg("-@")
        .stdin(Stdio::piped())
        .spawn()
        .map_err(|e| fail(2, format!("fb render: cannot run zip: {e}")))?;
    let names: String = list.iter().map(|f| format!("{}\n", f.display())).collect();
    zip.stdin
        .take()
        .map(|mut s| s.write_all(names.as_bytes()))
        .transpose()
        .map_err(|e| fail(2, format!("fb render: zip: {e}")))?;
    let st = zip
        .wait()
        .map_err(|e| fail(2, format!("fb render: zip: {e}")))?;
    st.success()
        .then_some(())
        .ok_or_else(|| fail(1, "fb render: zip failed"))
}

/// `docx` packed again as a reproducible archive, in place (`work` is scratch space).
pub fn repack(docx: &Path, work: &Path) -> Res<()> {
    repack_at(docx, work, epoch())
}

fn repack_at(docx: &Path, work: &Path, secs: u64) -> Res<()> {
    let dir = work.join("repack");
    unpack(docx, &dir)?;
    pack_at(&dir, docx, secs)?;
    let _ = std::fs::remove_dir_all(&dir);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn lists_files_in_byte_order() {
        let t = crate::proc::TempDir::new("docxzip-test").unwrap();
        std::fs::create_dir_all(t.path().join("word/_rels")).unwrap();
        for f in [
            "word/document.xml",
            "[Content_Types].xml",
            "word/_rels/document.xml.rels",
        ] {
            std::fs::write(t.path().join(f), "").unwrap();
        }
        let got: Vec<String> = files(t.path())
            .iter()
            .map(|p| p.display().to_string())
            .collect();
        assert_eq!(
            got,
            [
                "[Content_Types].xml",
                "word/_rels/document.xml.rels",
                "word/document.xml"
            ]
        );
    }

    /// Repacking is stable: an archive written at another time (and repacked twice) gives the same bytes; skipped,
    /// and logged to TEST_SKIP_LOG, without zip or unzip.
    #[test]
    fn repack_is_byte_stable() {
        for tool in ["zip", "unzip"] {
            if !crate::proc::have(tool) {
                eprintln!("SKIP repack_is_byte_stable: {tool} not installed");
                if let Some(log) = std::env::var_os("TEST_SKIP_LOG") {
                    let mut f = std::fs::OpenOptions::new()
                        .create(true)
                        .append(true)
                        .open(log)
                        .unwrap();
                    writeln!(
                        f,
                        "docxzip::tests::repack_is_byte_stable: {tool} not installed"
                    )
                    .unwrap();
                }
                return;
            }
        }
        const EPOCH: u64 = 1767225600;
        let t = crate::proc::TempDir::new("docxzip-repack").unwrap();
        let make = |name: &str, order: &[&str]| {
            let src = t.path().join(format!("src-{name}"));
            std::fs::create_dir_all(src.join("word")).unwrap();
            for f in order {
                std::fs::write(src.join(f), format!("<{f}/>")).unwrap();
            }
            let out = t.path().join(format!("{name}.docx"));
            let st = Command::new("zip")
                .current_dir(&src)
                .arg("-q")
                .arg(&out)
                .args(order)
                .status()
                .unwrap();
            assert!(st.success());
            out
        };
        let a = make("a", &["word/document.xml", "[Content_Types].xml"]);
        std::thread::sleep(std::time::Duration::from_millis(2100));
        let b = make("b", &["[Content_Types].xml", "word/document.xml"]);
        repack_at(&a, t.path(), EPOCH).unwrap();
        repack_at(&b, t.path(), EPOCH).unwrap();
        let once = std::fs::read(&b).unwrap();
        repack_at(&b, t.path(), EPOCH).unwrap();
        assert_eq!(std::fs::read(&a).unwrap(), once);
        assert_eq!(std::fs::read(&b).unwrap(), once);
    }
}
