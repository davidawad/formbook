//! Hashes, the engine stamp (usage/.check-<engine>.txt) and the template anchor lookup.
use sha2::{Digest, Sha256};
use std::path::Path;

/// `shasum -a 256 FILE | cut -d' ' -f1`: the hex digest, or "" (with shasum's message on stderr).
pub fn sha256(path: &str) -> String {
    match std::fs::read(path) {
        Ok(b) => Sha256::digest(&b)
            .iter()
            .map(|x| format!("{x:02x}"))
            .collect(),
        Err(e) => {
            let msg = e.to_string();
            let msg = msg.split(" (os error").next().unwrap_or(&msg);
            eprintln!("shasum: {path}: {msg}");
            String::new()
        }
    }
}

/// The key of `sort -k2` (no -b, no -t): from the end of field 1 (leading blanks plus the first
/// non-blank run) to the end of the line.
fn key2(line: &str) -> &str {
    let blank = |c: char| c == ' ' || c == '\t';
    let start = line.trim_start_matches(blank);
    let rest = start.trim_start_matches(|c| !blank(c));
    &line[line.len() - rest.len()..]
}

/// `sort -k2` in the C locale (this box has no en_US.UTF-8, so check.sh sorted by bytes):
/// key 2 first, then the whole line as the last resort.
pub fn sort_k2(lines: &[String]) -> Vec<String> {
    let mut v = lines.to_vec();
    v.sort_by(|a, b| key2(a).cmp(key2(b)).then_with(|| a.cmp(b)));
    v
}

/// The stamp: PASS, then the "sha256  path" lines sorted by path.
pub fn stamp_text(shas: &[String]) -> String {
    let body: String = sort_k2(shas).iter().map(|l| format!("{l}\n")).collect();
    format!("PASS\n{body}")
}

/// 1-based number of the first line of `text` containing `anchor` (grep -F), or None.
pub fn line_of(text: &[u8], anchor: &[u8]) -> Option<usize> {
    let body = text.strip_suffix(b"\n").unwrap_or(text);
    match text.is_empty() {
        true => None,
        false => body
            .split(|&b| b == b'\n')
            .position(|l| anchor.is_empty() || l.windows(anchor.len()).any(|w| w == anchor))
            .map(|i| i + 1),
    }
}

/// grep's view of one file: binary files (a NUL byte) never print a matching line.
fn file_line(path: &Path, anchor: &[u8]) -> Option<usize> {
    let text = std::fs::read(path).ok()?;
    match text.contains(&0) {
        true => None,
        false => line_of(&text, anchor),
    }
}

/// grep -r order: depth first, directory entries in readdir order, symlinks below the top skipped.
fn walk(path: &Path, anchor: &[u8], top: bool) -> Option<usize> {
    let meta = match top {
        true => std::fs::metadata(path),
        false => std::fs::symlink_metadata(path),
    }
    .ok()?;
    match (meta.is_dir(), meta.is_file()) {
        (true, _) => std::fs::read_dir(path)
            .ok()?
            .filter_map(|e| e.ok())
            .find_map(|e| walk(&e.path(), anchor, false)),
        (false, true) => file_line(path, anchor),
        _ => None,
    }
}

/// `grep -rnH -F -- "$anchor" "$DOC/$TEMPLATE" | head -1`'s line number.
pub fn anchor_line(target: &str, anchor: &str) -> Option<usize> {
    walk(Path::new(target), anchor.as_bytes(), true)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stamp_order() {
        let shas = vec![
            "bb  usage/OUTPUT-opening-brief.typst.pdf".to_string(),
            "aa  usage/OUTPUT-opening-brief-2.typst.pdf".to_string(),
            "cc  usage/OUTPUT-opening-brief-2.docx".to_string(),
        ];
        assert_eq!(
            stamp_text(&shas),
            "PASS\ncc  usage/OUTPUT-opening-brief-2.docx\naa  usage/OUTPUT-opening-brief-2.typst.pdf\nbb  usage/OUTPUT-opening-brief.typst.pdf\n"
        );
        assert_eq!(key2("  ab  cd"), "  cd");
        assert_eq!(key2("ab"), "");
        // equal keys fall back to the whole line
        let v = sort_k2(&["b  x".to_string(), "a  x".to_string()]);
        assert_eq!(v, vec!["a  x", "b  x"]);
    }

    #[test]
    fn sha() {
        let d = std::env::temp_dir().join(format!("fb-check-sha-{}", std::process::id()));
        std::fs::write(&d, b"abc").unwrap();
        assert_eq!(
            sha256(d.to_str().unwrap()),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
        let _ = std::fs::remove_file(&d);
    }

    #[test]
    fn anchors() {
        assert_eq!(line_of(b"a\nset page(\nset page(\n", b"set page("), Some(2));
        assert_eq!(line_of(b"a\nb", b"b"), Some(2));
        assert_eq!(line_of(b"a\n", b"x"), None);
        assert_eq!(line_of(b"", b""), None);
        assert_eq!(line_of(b"\n", b""), Some(1));
        assert_eq!(anchor_line("/nonexistent/x", "a"), None);
    }
}
