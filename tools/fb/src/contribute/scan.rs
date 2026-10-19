//! Scans of a sample and a template for case-specific text: what `fb contribute verify` checks so a
//! template never carries one filing's parties, facts or docket numbers.
use std::collections::BTreeSet;

/// The value of a frontmatter line `key: "value"[,]` or a list item `- "value"`.
fn quoted_value(line: &str) -> Option<String> {
    let inner = |s: &str| -> Option<String> {
        let t = s.trim_end_matches([' ', '\t']);
        let t = t
            .strip_suffix(',')
            .unwrap_or(t)
            .trim_end_matches([' ', '\t']);
        let body = t.strip_prefix('"')?.strip_suffix('"')?;
        Some(body.to_string())
    };
    let kv = line
        .split_once(':')
        .filter(|(k, _)| !k.contains(':'))
        .and_then(|(_, v)| inner(v.trim_start_matches([' ', '\t'])));
    let item = line
        .trim_start_matches([' ', '\t'])
        .strip_prefix('-')
        .and_then(|r| inner(r.trim_start_matches([' ', '\t'])));
    kv.or(item)
}

/// An ALL-CAPS party name such as `ACME HOLDINGS, INC.`.
fn all_caps_name(s: &str) -> bool {
    let t = s.strip_suffix(',').unwrap_or(s);
    let t = t.strip_suffix('.').unwrap_or(t);
    let mut cs = t.chars();
    let (first, last) = (cs.next(), t.chars().last());
    t.chars().count() >= 2
        && first.is_some_and(|c| c.is_ascii_uppercase())
        && last.is_some_and(|c| c.is_ascii_uppercase())
        && t.chars()
            .all(|c| c.is_ascii_uppercase() || " .,&-".contains(c))
}

/// Strings of a sample that would identify its case if they appeared in a template: frontmatter values that
/// carry a digit or are an ALL-CAPS name (at least 8 chars), and every 8-word run opening a prose line of 10+ words.
pub fn probes(md: &str) -> Vec<String> {
    let lines: Vec<&str> = md.lines().collect();
    let fm = lines.first() == Some(&"---");
    let end = if fm {
        lines
            .iter()
            .skip(1)
            .position(|l| *l == "---")
            .map(|i| i + 1)
    } else {
        None
    };
    let (front, body): (&[&str], &[&str]) = match (fm, end) {
        (true, Some(e)) => (&lines[1..e], &lines[e + 1..]),
        (true, None) => (&lines[1..], &[]),
        _ => (&[], &lines[..]),
    };
    let mut out: Vec<String> = front
        .iter()
        .filter_map(|l| quoted_value(l))
        .filter(|v| {
            v.chars().count() >= 8 && (v.chars().any(|c| c.is_ascii_digit()) || all_caps_name(v))
        })
        .collect();
    out.extend(body.iter().filter_map(|l| {
        let w: Vec<&str> = l.split_whitespace().collect();
        (w.len() >= 10).then(|| w[..8].join(" "))
    }));
    out
}

fn is_court_no(b: &[u8]) -> bool {
    // "No. " DD "-" DDD+
    b.len() >= 10
        && b.starts_with(b"No. ")
        && b[4..6].iter().all(u8::is_ascii_digit)
        && b[6] == b'-'
        && b[7..].iter().take_while(|c| c.is_ascii_digit()).count() >= 3
}

fn is_case_no(b: &[u8]) -> bool {
    // D{1,2} ":" DD "-" (cv|cr|bk|ap|mc) "-" D+
    let d = b.iter().take_while(|c| c.is_ascii_digit()).count();
    (1..=2).contains(&d)
        && b.get(d) == Some(&b':')
        && b.len() > d + 7
        && b[d + 1..d + 3].iter().all(u8::is_ascii_digit)
        && b[d + 3] == b'-'
        && [b"cv", b"cr", b"bk", b"ap", b"mc"]
            .iter()
            .any(|k| &b[d + 4..d + 6] == *k)
        && b[d + 6] == b'-'
        && b[d + 7].is_ascii_digit()
}

/// Whether `line` holds a docket number in either form.
pub fn has_docket(line: &str) -> bool {
    let b = line.as_bytes();
    (0..b.len()).any(|i| is_court_no(&b[i..]) || is_case_no(&b[i..]))
}

/// The first `n` lines of the concatenated template text that contain any probe.
pub fn leaked(text: &str, probes: &BTreeSet<String>, n: usize) -> Vec<String> {
    text.lines()
        .filter(|l| probes.iter().any(|p| l.contains(p.as_str())))
        .take(n)
        .map(str::to_string)
        .collect()
}

/// The first `n` lines (numbered like `grep -n`) of the text holding a docket number.
pub fn dockets(text: &str, n: usize) -> Vec<String> {
    text.lines()
        .enumerate()
        .filter(|(_, l)| has_docket(l))
        .take(n)
        .map(|(i, l)| format!("{}:{l}", i + 1))
        .collect()
}

pub fn cut(s: &str, n: usize) -> String {
    s.chars().take(n).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn quoted_values_of_frontmatter() {
        assert_eq!(
            quoted_value("court: \"U.S. District Court\"").as_deref(),
            Some("U.S. District Court")
        );
        assert_eq!(
            quoted_value("docket: \"1:24-cv-00123\",").as_deref(),
            Some("1:24-cv-00123")
        );
        assert_eq!(
            quoted_value("  - \"ACME HOLDINGS, INC.\"  ").as_deref(),
            Some("ACME HOLDINGS, INC.")
        );
        assert_eq!(quoted_value("title: plain"), None);
        assert_eq!(quoted_value("a: \"x\" y"), None);
    }

    #[test]
    fn all_caps_names() {
        assert!(all_caps_name("ACME HOLDINGS, INC."));
        assert!(all_caps_name("SMITH & JONES"));
        assert!(!all_caps_name("Acme Holdings"));
        assert!(!all_caps_name("A"));
        assert!(!all_caps_name("ACME 2"));
    }

    #[test]
    fn probes_from_frontmatter_and_body() {
        let md = "---\ncase: \"1:24-cv-00123\"\nshort: \"abc1\"\nparty: \"ACME HOLDINGS, INC.\"\nfiler: \"Jane Roe\"\n---\n# Heading\none two three four five six seven eight nine ten\nshort line\n";
        let p = probes(md);
        assert_eq!(
            p,
            [
                "1:24-cv-00123",
                "ACME HOLDINGS, INC.",
                "one two three four five six seven eight"
            ]
        );
    }

    #[test]
    fn probes_without_frontmatter_use_whole_file() {
        assert_eq!(probes("a b c d e f g h i j\n"), ["a b c d e f g h"]);
    }

    #[test]
    fn docket_numbers() {
        assert!(has_docket("see 1:24-cv-00123 here"));
        assert!(has_docket("12:05-bk-9"));
        assert!(has_docket("No. 23-1234"));
        assert!(!has_docket("No. 23-12"));
        assert!(
            has_docket("123:24-cv-1"),
            "unanchored, like the grep it replaces"
        );
        assert!(!has_docket("1:24-xx-1"));
        assert!(!has_docket("nothing"));
    }

    #[test]
    fn leak_and_docket_scans() {
        let probes: BTreeSet<String> = ["secret phrase"].map(String::from).into();
        let text = "ok\nhas secret phrase inside\nNo. 12-345\n";
        assert_eq!(leaked(text, &probes, 3), ["has secret phrase inside"]);
        assert_eq!(dockets(text, 3), ["3:No. 12-345"]);
    }
}
