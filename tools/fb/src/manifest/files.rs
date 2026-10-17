//! Filesystem predicates with the semantics of the shell globs and tests they replace.
use sha2::{Digest, Sha256};
use std::fs;
use std::path::Path;

/// Names of the visible entries of `dir` (a shell `*` never matches a leading dot), sorted bytewise.
pub fn visible(dir: &Path) -> Vec<String> {
    let mut names: Vec<String> = fs::read_dir(dir)
        .map(|rd| {
            rd.filter_map(Result::ok)
                .map(|e| e.file_name().to_string_lossy().into_owned())
                .filter(|n| !n.starts_with('.'))
                .collect()
        })
        .unwrap_or_default();
    names.sort();
    names
}

/// Entries of `dir` matching `<prefix>*<suffix>` that exist (`[ -e ]`: a dangling symlink does not).
pub fn matching(dir: &Path, prefix: &str, suffix: &str) -> Vec<String> {
    visible(dir)
        .into_iter()
        .filter(|n| glob_match(n, prefix, suffix))
        .filter(|n| dir.join(n).exists())
        .collect()
}

/// `<prefix>*<suffix>` with `*` matching any (possibly empty) run.
pub fn glob_match(name: &str, prefix: &str, suffix: &str) -> bool {
    name.len() >= prefix.len() + suffix.len() && name.starts_with(prefix) && name.ends_with(suffix)
}

pub fn digit(n: usize) -> char {
    char::from_digit(n.min(9) as u32, 10).unwrap_or('9')
}

/// Presence as '0'/'1' (a count squashed by `sed 's/[2-9]/1/'`).
pub fn bit(b: bool) -> char {
    if b {
        '1'
    } else {
        '0'
    }
}

pub fn is_file(p: &Path) -> bool {
    p.is_file()
}

/// A `shasum -c` line: 64 hex digits, then two spaces or " *", then the path. Other lines are ignored.
pub fn parse_sum_line(line: &str) -> Option<(String, &str)> {
    let (hex, rest) = (line.get(..64)?, line.get(64..)?);
    let path = rest
        .strip_prefix("  ")
        .or_else(|| rest.strip_prefix(" *"))?;
    (hex.chars().all(|c| c.is_ascii_hexdigit()) && !path.is_empty())
        .then(|| (hex.to_ascii_lowercase(), path))
}

pub fn sha256_file(p: &Path) -> Option<String> {
    fs::read(p).ok().map(|b| hex(&Sha256::digest(&b)))
}

pub fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    const H: &str = "98ea6e4f216f2fb4b69fff9b3a44842c38686ca685f3f55dc48c5d3fb1107be4";

    #[test]
    fn glob() {
        assert!(glob_match("OUTPUT-.pdf", "OUTPUT-", ".pdf"));
        assert!(glob_match("OUTPUT-x.latex.pdf", "OUTPUT-", ".pdf"));
        assert!(!glob_match("OUTPUT.pdf", "OUTPUT-", ".pdf"));
        assert!(!glob_match("x.pd", "", ".pdf"));
    }

    #[test]
    fn digits_cap_at_nine() {
        assert_eq!(digit(0), '0');
        assert_eq!(digit(9), '9');
        assert_eq!(digit(42), '9');
    }

    #[test]
    fn sum_lines_like_shasum() {
        assert_eq!(
            parse_sum_line(&format!("{H}  a")),
            Some((H.to_string(), "a"))
        );
        assert_eq!(
            parse_sum_line(&format!("{H} *a")),
            Some((H.to_string(), "a"))
        );
        assert_eq!(parse_sum_line(&format!("{H} a")), None);
        assert_eq!(parse_sum_line("junk"), None);
        let upper = H.to_ascii_uppercase();
        assert_eq!(
            parse_sum_line(&format!("{upper}  a")),
            Some((H.to_string(), "a"))
        );
    }
}
