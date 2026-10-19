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
}
