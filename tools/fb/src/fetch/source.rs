//! usage/SOURCE.md: which FILED-EXAMPLE-*.pdf each record names, its download URL and its recorded
//! SHA-256, and writing a missing SHA-256 back in the record's own style.
//!
//! SOURCE.md files are hand-written in several styles: key/value tables (`| File | `x.pdf` |` then
//! `| URL | https://... |`), one wide table with a row per exemplar, `- File:` / `- Fetched from:` lists
//! (optionally bold labels), and `### FILED-EXAMPLE-x.pdf` headings. A record starts at a heading naming
//! a file, a `File`-like label naming a file, a wide-table row naming a file, or the first mention of a
//! file when no record is open; it ends at the next record or heading.

/// One exemplar as SOURCE.md describes it.
#[derive(Debug, Clone, PartialEq)]
pub struct Entry {
    pub name: String,
    pub url: Option<String>,
    pub sha: Option<String>,
    /// Every hash the record gives (an extract may record both the fetched file's and its own).
    pub shas: Vec<String>,
    /// 0-based line of the URL (or of the record start when there is no URL): where a hash goes.
    pub anchor: usize,
    /// False for a file only mentioned in passing (no record of its own).
    pub listed: bool,
    /// The record says the exemplar is an excerpt of the fetched file (pages cut from it), so a
    /// download cannot reproduce it.
    pub excerpt: bool,
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Style {
    Heading,
    KeyValue,
    Wide,
    Item,
    Text,
}

/// The cells of a markdown table row, or None for a non-table line.
fn cells(line: &str) -> Option<Vec<String>> {
    let t = line.trim();
    let inner = t.strip_prefix('|')?;
    let inner = inner.strip_suffix('|').unwrap_or(inner);
    Some(inner.split('|').map(|c| c.trim().to_string()).collect())
}

fn is_separator(c: &[String]) -> bool {
    c.iter()
        .all(|x| !x.is_empty() && x.chars().all(|ch| matches!(ch, '-' | ':' | ' ')))
}

/// Every FILED-EXAMPLE-*.pdf name on a line, in order (not one inside a longer name such as `NO-FILED-EXAMPLE-x.pdf`).
pub fn names(line: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut rest = line;
    while let Some(i) = rest.find("FILED-EXAMPLE-") {
        let tail = &rest[i..];
        let end = tail
            .find(|c: char| !(c.is_ascii_alphanumeric() || matches!(c, '-' | '_' | '.')))
            .unwrap_or(tail.len());
        let cand = tail[..end].trim_end_matches('.');
        // a path (`../../usage/FILED-EXAMPLE-x.pdf`) points at another folder
        let elsewhere = rest[..i].ends_with(|c: char| {
            c == '/' || c.is_ascii_alphanumeric() || matches!(c, '-' | '_' | '.')
        });
        if cand.to_ascii_lowercase().ends_with(".pdf") && !elsewhere {
            out.push(cand.to_string());
        }
        rest = &tail[end.max(1)..];
    }
    out
}

/// A list item `- label: value` (bullets - * +, bold labels allowed): (label, bold).
fn item_label(line: &str) -> Option<(String, bool)> {
    let t = line.trim_start();
    let body = t
        .strip_prefix("- ")
        .or_else(|| t.strip_prefix("* "))
        .or_else(|| t.strip_prefix("+ "))?;
    let colon = body.find(':')?;
    let label = &body[..colon];
    if label.contains("http") || label.len() > 60 {
        return None;
    }
    let bold = label.starts_with("**");
    Some((label.replace(['*', '`'], "").trim().to_string(), bold))
}

fn file_label(label: &str) -> bool {
    let l = label.to_ascii_lowercase();
    let l = l.replace("filed-example", "");
    ["file", "exemplar", "name", "saved", "local", "pdf"]
        .iter()
        .any(|k| l.contains(k))
}

/// Every http(s) URL on a line with the text before it (for scoring), trailing punctuation trimmed.
fn urls(line: &str) -> Vec<(String, String)> {
    let mut out = Vec::new();
    let mut from = 0;
    while let Some(i) = line[from..].find("http").map(|i| i + from) {
        let tail = &line[i..];
        if !(tail.starts_with("http://") || tail.starts_with("https://")) {
            from = i + 4;
            continue;
        }
        let end = tail
            .find(|c: char| {
                c.is_whitespace() || matches!(c, '|' | ')' | '>' | '`' | '"' | '\'' | ']')
            })
            .unwrap_or(tail.len());
        let url = tail[..end].trim_end_matches(['.', ',', ';', ':']);
        out.push((url.to_string(), line[from..i].to_string()));
        from = i + end.max(1);
    }
    out
}

/// How likely a URL is the exemplar's download link, from its label/context and its shape.
fn score(url: &str, context: &str) -> i32 {
    let c = context.to_ascii_lowercase();
    let u = url.to_ascii_lowercase();
    let good = [
        "url", "fetch", "source", "pdf", "download", "retriev", "link", "file",
    ]
    .iter()
    .any(|k| c.contains(k));
    let bad = ["docket", "search", "rule"].iter().any(|k| c.contains(k))
        || ["/docket/", "/api/", "search"]
            .iter()
            .any(|k| u.contains(k));
    let path = u.split(['?', '#']).next().unwrap_or("");
    2 * i32::from(good) + i32::from(path.ends_with(".pdf")) - 4 * i32::from(bad)
}

/// The 64-hex-digit words of a line.
fn hexes(line: &str) -> Vec<String> {
    line.split(|c: char| !c.is_ascii_hexdigit())
        .filter(|w| w.len() == 64)
        .map(|w| w.to_ascii_lowercase())
        .collect()
}

fn hex64(line: &str) -> Option<String> {
    hexes(line).into_iter().next()
}

/// A line saying the exemplar is cut from the fetched file: "excerpt", "extracted from",
/// "(extract)", "pages 1-19 of 42".
fn excerpt_hint(line: &str) -> bool {
    let l = line.to_ascii_lowercase();
    let pages_of = l.match_indices("pages ").any(|(i, _)| {
        let rest = &l[i + 6..];
        let range = rest
            .find(|c: char| !(c.is_ascii_digit() || c == '-'))
            .unwrap_or(rest.len());
        range > 2 && rest[..range].contains('-') && rest[range..].starts_with(" of ")
    });
    pages_of
        || ["excerpt", "extracted from", "(extract)", "extract of"]
            .iter()
            .any(|k| l.contains(k))
}

struct Rec {
    name: String,
    start: usize,
    end: usize,
}

/// Split SOURCE.md into records.
fn records(lines: &[&str]) -> Vec<Rec> {
    let mut recs: Vec<Rec> = Vec::new();
    let mut open = false;
    let mut header: Vec<String> = Vec::new();
    let mut prev_table = false;
    for (i, line) in lines.iter().enumerate() {
        let ns = names(line);
        let row = cells(line);
        let close = |recs: &mut Vec<Rec>, open: &mut bool| {
            if *open {
                if let Some(r) = recs.last_mut() {
                    r.end = i;
                }
            }
            *open = false;
        };
        let header_row = row.is_some() && !prev_table;
        prev_table = row.is_some();
        if header_row {
            header = row.clone().unwrap_or_default();
        }
        let starts = match (&row, line.trim_start().starts_with('#')) {
            (_, true) => {
                close(&mut recs, &mut open);
                ns.len() == 1
            }
            (Some(c), _) if header_row || is_separator(c) => false,
            (Some(c), _) if c.len() > 2 || header.len() > 2 => {
                c.first().is_some_and(|c0| !names(c0).is_empty()) || (!ns.is_empty() && !open)
            }
            (Some(c), _) => {
                let label = c.first().map(String::as_str).unwrap_or("");
                !ns.is_empty() && (file_label(label) || !open)
            }
            (None, _) => match item_label(line) {
                Some((label, _)) => !ns.is_empty() && (file_label(&label) || !open),
                None => {
                    let t = line
                        .trim_start()
                        .trim_start_matches(['-', '*', '+', ' ', '`']);
                    !ns.is_empty() && (t.starts_with("FILED-EXAMPLE-") || !open)
                }
            },
        };
        if starts {
            close(&mut recs, &mut open);
            recs.push(Rec {
                name: ns[0].clone(),
                start: i,
                end: lines.len(),
            });
            open = true;
            let wide = row
                .as_ref()
                .is_some_and(|c| c.len() > 2 || header.len() > 2);
            if wide {
                close(&mut recs, &mut open);
                if let Some(r) = recs.last_mut() {
                    r.end = i + 1;
                }
            }
        }
    }
    recs
}

/// Every exemplar SOURCE.md describes, in order of first appearance; repeated records are merged.
pub fn parse(text: &str) -> Vec<Entry> {
    let lines: Vec<&str> = text.split('\n').collect();
    let mut out: Vec<Entry> = Vec::new();
    for r in records(&lines) {
        let best = (r.start..r.end)
            .flat_map(|i| {
                let label = cells(lines[i])
                    .and_then(|c| c.first().cloned())
                    .or_else(|| item_label(lines[i]).map(|l| l.0))
                    .unwrap_or_default();
                urls(lines[i])
                    .into_iter()
                    .map(move |(u, ctx)| (score(&u, &format!("{label} {ctx}")), i, u))
            })
            .fold(None::<(i32, usize, String)>, |acc, c| match &acc {
                Some(a) if a.0 >= c.0 => acc,
                _ => Some(c),
            });
        // a line naming another file carries that file's hash, not this record's
        let shas: Vec<String> = (r.start..r.end)
            .filter(|&i| names(lines[i]).iter().all(|n| *n == r.name))
            .flat_map(|i| hexes(lines[i]))
            .collect();
        let sha = shas.first().cloned();
        let excerpt = (r.start..r.end)
            .filter(|&i| names(lines[i]).iter().all(|n| *n == r.name))
            .any(|i| excerpt_hint(lines[i]));
        let anchor = best.as_ref().map_or(r.start, |b| b.1);
        let e = Entry {
            name: r.name,
            url: best.map(|b| b.2),
            sha,
            shas,
            anchor,
            listed: true,
            excerpt,
        };
        match out.iter_mut().find(|x| x.name == e.name) {
            Some(x) => {
                if x.url.is_none() && e.url.is_some() {
                    x.url = e.url;
                    x.anchor = e.anchor;
                }
                x.sha = x.sha.take().or(e.sha);
                x.shas.extend(e.shas);
                x.excerpt |= e.excerpt;
            }
            None => out.push(e),
        }
    }
    for (i, line) in lines.iter().enumerate() {
        for n in names(line) {
            if !out.iter().any(|e| e.name == n) {
                out.push(Entry {
                    name: n,
                    url: None,
                    sha: None,
                    shas: Vec::new(),
                    anchor: i,
                    listed: false,
                    excerpt: false,
                });
            }
        }
    }
    for e in out.iter_mut().filter(|e| e.sha.is_none()) {
        e.sha = lines
            .iter()
            .filter(|l| l.contains(e.name.as_str()))
            .find_map(|l| hex64(&l[l.find(e.name.as_str()).unwrap_or(0)..]));
        e.shas.extend(e.sha.clone());
    }
    out
}

/// The style of the line a hash is written next to.
fn style(lines: &[&str], i: usize) -> Style {
    let header_wide = (0..i)
        .rev()
        .take_while(|&j| cells(lines[j]).is_some())
        .last()
        .and_then(|j| cells(lines[j]))
        .is_some_and(|c| c.len() > 2);
    match (cells(lines[i]), item_label(lines[i])) {
        (Some(c), _) if c.len() > 2 || header_wide => Style::Wide,
        (Some(_), _) => Style::KeyValue,
        (None, Some(_)) => Style::Item,
        _ if lines[i].trim_start().starts_with('#') => Style::Heading,
        _ => Style::Text,
    }
}

/// SOURCE.md with `sha` recorded for `e`, in the style of the record's URL line.
pub fn record_sha(text: &str, e: &Entry, sha: &str) -> String {
    let lines: Vec<&str> = text.split('\n').collect();
    let i = e.anchor.min(lines.len().saturating_sub(1));
    let block_end = |from: usize| {
        (from + 1..lines.len())
            .find(|&j| lines[j].trim().is_empty())
            .unwrap_or(lines.len())
    };
    let (at, new): (usize, Vec<String>) = match style(&lines, i) {
        Style::KeyValue => (i + 1, vec![format!("| SHA-256 | `{sha}` |")]),
        Style::Item => {
            let t = lines[i].trim_start();
            let indent = &lines[i][..lines[i].len() - t.len()];
            let bullet = &t[..2];
            let bold = item_label(lines[i]).is_some_and(|l| l.1);
            let label = match bold {
                true => "**SHA-256:**",
                false => "SHA-256:",
            };
            let cont = (i + 1..lines.len())
                .find(|&j| {
                    let l = lines[j];
                    l.trim().is_empty() || !l.starts_with(' ') || item_label(l).is_some()
                })
                .unwrap_or(lines.len());
            (cont, vec![format!("{indent}{bullet}{label} `{sha}`")])
        }
        Style::Wide | Style::Text | Style::Heading => {
            let at = match style(&lines, i) {
                Style::Heading => block_end(i + 1),
                _ => block_end(i),
            };
            (
                at,
                vec![String::new(), format!("SHA-256 of `{}`: `{sha}`", e.name)],
            )
        }
    };
    let mut out: Vec<String> = lines.iter().map(|s| s.to_string()).collect();
    let at = at.min(out.len());
    // never leave the new line glued to a following non-blank line
    let glue = new.len() > 1 && out.get(at).is_some_and(|l| !l.trim().is_empty());
    let mut ins = new;
    if glue {
        ins.push(String::new());
    }
    out.splice(at..at, ins);
    out.join("\n")
}

#[cfg(test)]
#[path = "source_tests.rs"]
mod tests;
