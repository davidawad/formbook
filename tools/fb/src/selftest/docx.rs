//! Docx mutants: the .docx a render wrote is broken after the fact (a package defect, which no one-line template
//! change makes reliably), and `fb check --engine docx --no-render` must FAIL DEF-DOCX-OPEN.
use super::sed;
use crate::proc::{capture, TempDir};
use crate::{fail, Res};
use std::path::Path;
use std::process::Command;

fn io(p: &Path, e: std::io::Error) -> crate::Fail {
    fail(2, format!("fb selftest: {}: {e}", p.display()))
}

/// Break `docx` in place: `part` None cuts the archive in half (a corrupted download); Some(part) applies the sed
/// program `expr` to that part and zips the package again. Err when the sed changed nothing.
pub fn mutate(docx: &Path, part: Option<&str>, expr: &str) -> Res<()> {
    let Some(part) = part else {
        let bytes = std::fs::read(docx).map_err(|e| io(docx, e))?;
        return std::fs::write(docx, &bytes[..bytes.len() / 2]).map_err(|e| io(docx, e));
    };
    let t = TempDir::new("selftest-docx")?;
    let x = t.path().join("pkg");
    let ok = |o: std::process::Output, what: &str| {
        o.status.success().then_some(()).ok_or_else(|| {
            fail(
                2,
                format!("fb selftest: {what} failed on {}", docx.display()),
            )
        })
    };
    ok(
        capture(Command::new("unzip").arg("-q").arg(docx).arg("-d").arg(&x))?,
        "unzip",
    )?;
    let p = x.join(part);
    let changed = sed(expr, &p)?;
    if changed == std::fs::read(&p).map_err(|e| io(&p, e))? {
        return Err(fail(
            1,
            format!("the sed expression changed nothing in {part}"),
        ));
    }
    std::fs::write(&p, changed).map_err(|e| io(&p, e))?;
    std::fs::remove_file(docx).map_err(|e| io(docx, e))?;
    let abs = std::path::absolute(docx).map_err(|e| io(docx, e))?;
    ok(
        capture(
            Command::new("zip")
                .current_dir(&x)
                .args(["-q", "-X", "-r"])
                .arg(&abs)
                .arg("."),
        )?,
        "zip",
    )
}
