//! `fb lint rules`: the format of every `courts/**/rules.md`, offline (no URL is fetched).
//!   - a Sources table (a table under a heading that names sources) with at least one http(s) URL;
//!   - requirement tables (first column `ID` or `Stable ID`): every ID matches `^[A-Z0-9]+(-[A-Z0-9]+)+-[0-9]{3}$`
//!     and is unique in the file; the Kind cell starts with one of M, C, T, A (a qualifier may follow:
//!     `M (conditional)`); a row of Kind M has a non-empty source cell (the first column whose header
//!     names a source, else a rule);
//!   - a line `Verified against <what> on YYYY-MM-DD`.
//!
//! Output: `LINT rules <path>:<line>: <detail>`; exit 1 on findings.
use crate::{repo_root, Res};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

/// The cells of a markdown table row, or None when the line is not one.
fn cells(line: &str) -> Option<Vec<String>> {
    let inner = line.trim().strip_prefix('|')?;
    let inner = inner.strip_suffix('|').unwrap_or(inner);
    Some(inner.split('|').map(|c| c.trim().to_string()).collect())
}

fn is_separator(c: &[String]) -> bool {
    c.iter()
        .all(|x| x.chars().all(|ch| matches!(ch, '-' | ':' | ' ')))
}

/// `^[A-Z0-9]+(-[A-Z0-9]+)+-[0-9]{3}$`: a court prefix, one or more scope segments (`FORM`, or `OB-CONT` for a
/// doc type), and a three-digit number.
pub fn valid_id(id: &str) -> bool {
    let parts: Vec<&str> = id.split('-').collect();
    let [head @ .., last] = parts.as_slice() else {
        return false;
    };
    head.len() >= 2
        && head.iter().all(|p| {
            !p.is_empty()
                && p.chars()
                    .all(|ch| ch.is_ascii_uppercase() || ch.is_ascii_digit())
        })
        && last.len() == 3
        && last.chars().all(|ch| ch.is_ascii_digit())
}

/// The Kind letter of a cell: `M`, `C`, `T` or `A`, optionally followed by a qualifier.
pub fn kind_of(cell: &str) -> Option<char> {
    let mut it = cell.chars();
    let k = it.next().filter(|k| matches!(k, 'M' | 'C' | 'T' | 'A'))?;
    it.next().is_none_or(|n| !n.is_alphanumeric()).then_some(k)
}

fn is_date(s: &str) -> bool {
    s.len() == 10
        && s.char_indices().all(|(i, c)| match i {
            4 | 7 => c == '-',
            _ => c.is_ascii_digit(),
        })
}

/// `Verified against ... on YYYY-MM-DD` on one line.
fn verified_line(line: &str) -> bool {
    line.find("Verified against ").is_some_and(|at| {
        let rest = &line[at..];
        rest.match_indices(" on ")
            .any(|(i, _)| rest.get(i + 4..i + 14).is_some_and(is_date))
    })
}

pub fn check_text(name: &str, text: &str) -> Vec<String> {
    let f = |line: usize, why: String| format!("LINT rules {name}:{line}: {why}");
    let mut found = Vec::new();
    let lines: Vec<&str> = text.lines().collect();
    if !lines.iter().any(|l| verified_line(l)) {
        found.push(f(
            1,
            "no line `Verified against <sources> on YYYY-MM-DD`".into(),
        ));
    }
    let (mut sources_url, mut req_tables) = (false, 0usize);
    let mut heading = String::new();
    let mut seen: HashMap<String, usize> = HashMap::new();
    let mut i = 0;
    while i < lines.len() {
        let line = lines[i];
        if line.starts_with('#') {
            heading = line.trim_start_matches('#').trim().to_lowercase();
        }
        let Some(head) = cells(line) else {
            i += 1;
            continue;
        };
        let start = i;
        let mut rows = Vec::new();
        i += 1;
        while let Some(c) = lines.get(i).and_then(|l| cells(l)) {
            rows.push((i + 1, c));
            i += 1;
        }
        let rows: Vec<_> = rows.into_iter().filter(|(_, c)| !is_separator(c)).collect();
        if heading.contains("source")
            && rows.iter().any(|(_, c)| {
                c.iter()
                    .any(|x| x.contains("http://") || x.contains("https://"))
            })
        {
            sources_url = true;
        }
        let h: Vec<String> = head.iter().map(|x| x.to_lowercase()).collect();
        if !matches!(h.first().map(String::as_str), Some("id" | "stable id")) {
            continue;
        }
        req_tables += 1;
        let kind_col = h.iter().position(|x| x == "kind");
        let src_col = h
            .iter()
            .position(|x| x.contains("source"))
            .or_else(|| h.iter().position(|x| x.contains("rule")));
        if kind_col.is_none() {
            found.push(f(start + 1, "requirement table has no Kind column".into()));
        }
        for (n, c) in rows {
            let id = c.first().map(String::as_str).unwrap_or("");
            if !valid_id(id) {
                found.push(f(
                    n,
                    format!("ID `{id}` does not match ^[A-Z0-9]+(-[A-Z0-9]+)+-[0-9]{{3}}$"),
                ));
            }
            if let Some(first) = seen.insert(id.to_string(), n) {
                found.push(f(n, format!("ID `{id}` repeats the one on line {first}")));
            }
            let kind = kind_col.and_then(|k| c.get(k)).map(String::as_str);
            match kind.and_then(kind_of) {
                None if kind_col.is_some() => found.push(f(
                    n,
                    format!(
                        "{id}: Kind `{}` is not one of M, C, T, A",
                        kind.unwrap_or("")
                    ),
                )),
                Some('M') if src_col.and_then(|s| c.get(s)).is_none_or(|s| s.is_empty()) => {
                    found.push(f(n, format!("{id}: Kind M needs a non-empty source cell")))
                }
                _ => {}
            }
        }
    }
    if !sources_url {
        found.push(f(
            1,
            "no Sources table with an http(s) URL (a table under a heading that names sources)"
                .into(),
        ));
    }
    if req_tables == 0 {
        found.push(f(
            1,
            "no requirement table (first column `ID` or `Stable ID`)".into(),
        ));
    }
    found
}

fn rules_files(dir: &Path, out: &mut Vec<PathBuf>) {
    let mut entries: Vec<_> = std::fs::read_dir(dir)
        .map(|rd| rd.filter_map(|e| e.ok()).map(|e| e.path()).collect())
        .unwrap_or_default();
    entries.sort();
    for p in entries {
        if p.is_dir() {
            rules_files(&p, out);
        } else if p.file_name().is_some_and(|n| n == "rules.md") {
            out.push(p);
        }
    }
}

/// Findings over every `<root>/courts/**/rules.md`, and the number of files checked.
pub fn check(root: &Path) -> (usize, Vec<String>) {
    let mut files = Vec::new();
    rules_files(&root.join("courts"), &mut files);
    let mut found = Vec::new();
    for p in &files {
        let name = p.strip_prefix(root).unwrap_or(p).display().to_string();
        match std::fs::read_to_string(p) {
            Ok(t) => found.extend(check_text(&name, &t)),
            Err(e) => found.push(format!("LINT rules {name}:1: unreadable: {e}")),
        }
    }
    (files.len(), found)
}

pub fn main() -> Res<ExitCode> {
    let (n, found) = check(&repo_root()?);
    found.iter().for_each(|x| println!("{x}"));
    match found.len() {
        0 => {
            println!("RESULT: LINT RULES PASS ({n} files)");
            Ok(ExitCode::SUCCESS)
        }
        k => {
            println!("RESULT: LINT RULES FAIL ({k} findings in {n} files)");
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const GOOD: &str = "# T\n\nVerified against the sources below on 2026-10-17.\n\n## Sources\n\n| Tag | Source | URL |\n|---|---|---|\n| A | Rules | https://example.gov/r.pdf |\n\n## Requirements\n\n| ID | Requirement | Source | Kind |\n|---|---|---|---|\n| AB1-FORM-001 | x | FRAP 32 | M |\n| AB1-FORM-002 | y | | C (open) |\n| AB1-CONT-001 | z | | A |\n";

    #[test]
    fn ids_and_kinds() {
        assert!(valid_id("CA9-FORM-001") && valid_id("A-B-123") && valid_id("CAFC-OB-LEN-001"));
        for bad in [
            "CAFC-OB-LEN-1",
            "ca9-FORM-001",
            "CA9-FORM-01",
            "CA9--001",
            "CA9-001",
            "",
        ] {
            assert!(!valid_id(bad), "{bad}");
        }
        assert_eq!(kind_of("M"), Some('M'));
        assert_eq!(kind_of("M (conditional)"), Some('M'));
        assert_eq!(kind_of("C; A"), Some('C'));
        assert_eq!(kind_of("(none)"), None);
        assert_eq!(kind_of("tier 3"), None);
        assert_eq!(kind_of("Mx"), None);
    }

    #[test]
    fn a_conforming_file_passes() {
        assert_eq!(check_text("r.md", GOOD), Vec::<String>::new());
    }

    #[test]
    fn each_defect_is_reported() {
        let no_ver = GOOD.replace(
            "Verified against the sources below on 2026-10-17.",
            "Checked.",
        );
        assert!(check_text("r.md", &no_ver)[0].contains("Verified against"));
        let no_url = GOOD.replace("https://example.gov/r.pdf", "see the court site");
        assert!(check_text("r.md", &no_url)[0].contains("no Sources table"));
        let bad_id = GOOD.replace("AB1-FORM-002", "AB1-form-002");
        assert!(check_text("r.md", &bad_id)[0].contains("does not match"));
        let dup = GOOD.replace("AB1-CONT-001", "AB1-FORM-001");
        assert!(check_text("r.md", &dup)[0].contains("repeats"));
        let bad_kind = GOOD.replace("| A |\n", "| X |\n");
        assert!(check_text("r.md", &bad_kind)[0].contains("not one of"));
        let m_no_src = GOOD.replace("| FRAP 32 | M |", "|  | M |");
        assert!(check_text("r.md", &m_no_src)[0].contains("non-empty source"));
        let no_tbl = "# T\n\nVerified against x on 2026-01-01.\n\n## Sources\n\n| a | b |\n|--|--|\n| x | http://y |\n";
        assert!(check_text("r.md", no_tbl)[0].contains("no requirement table"));
    }
}
