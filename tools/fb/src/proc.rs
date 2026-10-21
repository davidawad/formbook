//! Small process and scratch-directory helpers shared by the verbs that drive external tools.
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::{Command, Output, Stdio};

/// Whether `tool` is an executable file on PATH.
pub fn have(tool: &str) -> bool {
    which(tool).is_some()
}

/// The first executable named `tool` on PATH.
pub fn which(tool: &str) -> Option<PathBuf> {
    std::env::var_os("PATH").and_then(|p| {
        std::env::split_paths(&p)
            .map(|d| d.join(tool))
            .find(|f| f.is_file())
    })
}

/// A scratch directory, removed with its contents when dropped.
pub struct TempDir(PathBuf);

impl TempDir {
    pub fn new(label: &str) -> Res<TempDir> {
        let nanos = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_or(0, |d| d.as_nanos());
        let dir = std::env::temp_dir().join(format!("fb-{label}-{}-{nanos}", std::process::id()));
        std::fs::create_dir_all(&dir)
            .map_err(|e| fail(2, format!("fb: cannot create {}: {e}", dir.display())))?;
        Ok(TempDir(dir))
    }

    pub fn path(&self) -> &Path {
        &self.0
    }
}

impl Drop for TempDir {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

/// Run a command to completion capturing both streams; a spawn failure is a usage-class error.
pub fn capture(cmd: &mut Command) -> Res<Output> {
    let name = cmd.get_program().to_string_lossy().into_owned();
    cmd.stdin(Stdio::null())
        .output()
        .map_err(|e| fail(2, format!("fb: cannot run {name}: {e}")))
}

/// The final `n` lines of `text`, joined with newlines.
pub fn tail(text: &str, n: usize) -> String {
    let lines: Vec<&str> = text.lines().collect();
    lines[lines.len().saturating_sub(n)..].join("\n")
}

/// Pages of a PDF via `pdfinfo`; 0 when pdfinfo is absent or fails.
pub fn pdf_pages(pdf: &Path) -> u32 {
    if !have("pdfinfo") {
        return 0;
    }
    Command::new("pdfinfo")
        .arg(pdf)
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| {
            String::from_utf8_lossy(&o.stdout)
                .lines()
                .find_map(|l| l.strip_prefix("Pages:").and_then(|n| n.trim().parse().ok()))
        })
        .unwrap_or(0)
}

/// Move `src` to `dst` like `std::fs::rename`, but across filesystems too: when the rename fails with EXDEV
/// (scratch space under a TMPDIR on another mount than the repo, fb-595.51), copy to a hidden sibling of `dst`,
/// rename that into place, and remove `src`.
pub fn move_file(src: &Path, dst: &Path) -> std::io::Result<()> {
    move_with(src, dst, |a, b| std::fs::rename(a, b))
}

fn move_with(
    src: &Path,
    dst: &Path,
    rename: impl Fn(&Path, &Path) -> std::io::Result<()>,
) -> std::io::Result<()> {
    match rename(src, dst) {
        Err(e) if e.kind() == std::io::ErrorKind::CrossesDevices => {
            let name = dst.file_name().unwrap_or_default().to_string_lossy();
            let part = dst.with_file_name(format!(".{name}.fb-move-{}", std::process::id()));
            let copied = std::fs::copy(src, &part).and_then(|_| std::fs::rename(&part, dst));
            if copied.is_err() {
                let _ = std::fs::remove_file(&part);
            }
            copied?;
            std::fs::remove_file(src)
        }
        r => r,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tail_keeps_last_lines() {
        assert_eq!(tail("a\nb\nc\nd", 2), "c\nd");
        assert_eq!(tail("a", 5), "a");
    }

    #[test]
    fn tempdir_is_removed_on_drop() {
        let p = {
            let t = TempDir::new("proc-test").unwrap();
            assert!(t.path().is_dir());
            t.path().to_path_buf()
        };
        assert!(!p.exists());
    }

    #[test]
    fn missing_tool_is_absent() {
        assert!(!have("fb-no-such-tool-xyz"));
        assert_eq!(pdf_pages(Path::new("/nonexistent.pdf")), 0);
    }

    fn scratch(label: &str) -> PathBuf {
        let d = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("target")
            .join(format!("move-{label}-{}", std::process::id()));
        std::fs::create_dir_all(&d).unwrap();
        d
    }

    #[test]
    fn move_falls_back_to_copy_on_exdev() {
        let d = scratch("exdev");
        let (src, dst) = (d.join("a.docx"), d.join("b.docx"));
        std::fs::write(&src, b"docx").unwrap();
        std::fs::write(&dst, b"old").unwrap();
        let exdev =
            |_: &Path, _: &Path| Err(std::io::Error::from(std::io::ErrorKind::CrossesDevices));
        move_with(&src, &dst, exdev).unwrap();
        assert_eq!(std::fs::read(&dst).unwrap(), b"docx");
        assert!(!src.exists());
        assert_eq!(
            std::fs::read_dir(&d).unwrap().count(),
            1,
            "no .fb-move part left behind"
        );
        let other =
            |_: &Path, _: &Path| Err(std::io::Error::from(std::io::ErrorKind::PermissionDenied));
        std::fs::write(&src, b"x").unwrap();
        assert!(move_with(&src, &dst, other).is_err());
        assert!(src.exists(), "other rename errors are not swallowed");
        std::fs::remove_dir_all(&d).unwrap();
    }

    #[test]
    fn move_crosses_a_real_tmpfs() {
        use std::os::unix::fs::MetadataExt;
        let shm = Path::new("/dev/shm");
        let d = scratch("tmpfs");
        let skip = |why: &str| {
            let _ = std::fs::remove_dir_all(&d);
            eprintln!("SKIP move_crosses_a_real_tmpfs: {why}");
            if let Some(log) = std::env::var_os("TEST_SKIP_LOG") {
                use std::io::Write;
                let mut f = std::fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(log)
                    .unwrap();
                writeln!(f, "proc::tests::move_crosses_a_real_tmpfs: {why}").unwrap();
            }
        };
        let (Ok(a), Ok(b)) = (shm.metadata(), d.metadata()) else {
            return skip("/dev/shm absent");
        };
        if a.dev() == b.dev() {
            return skip("/dev/shm is on the same filesystem as target/");
        }
        let src = shm.join(format!("fb-move-test-{}.docx", std::process::id()));
        std::fs::write(&src, b"docx").unwrap();
        let dst = d.join("out.docx");
        let raw = std::fs::rename(&src, &dst).unwrap_err();
        assert_eq!(
            raw.kind(),
            std::io::ErrorKind::CrossesDevices,
            "plain rename reproduces EXDEV"
        );
        move_file(&src, &dst).unwrap();
        assert_eq!(std::fs::read(&dst).unwrap(), b"docx");
        assert!(!src.exists());
        std::fs::remove_dir_all(&d).unwrap();
    }
}
