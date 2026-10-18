//! Rule (c): usage/INPUT-<stem>-<id>.md is plain markdown. No hard line breaks inside a paragraph (two
//! trailing spaces or a trailing backslash), no raw typst (`#name(`, `#name[`, `#name.`, a typst
//! keyword such as `#set ` or a break such as `#pagebreak`; a ```{=typst} block) and no raw LaTeX
//! (`\command`, a ```{=latex} block). Markdown escapes (`\.`, `\-`, `\\`), `# Heading` lines,
//! hashtags and numbers (`#ad`, `#MO-61088`), code spans and code blocks are fine. The YAML
//! frontmatter is checked for raw markup only: its comment lines are skipped and its double-quoted
//! escapes (`\n`, ` `, `\\`) are decoded first.
use super::Finding;

/// Typst words that are markup when written `#word` even without a following `(` or `[`.
const TYPST_WORDS: &[&str] = &[
    "set",
    "show",
    "let",
    "import",
    "include",
    "if",
    "for",
    "while",
    "context",
    "linebreak",
    "pagebreak",
    "parbreak",
    "colbreak",
    "v",
    "h",
];

/// The line with `code spans` removed (a backslash-escaped backtick is text, not a span).
fn without_code(line: &str) -> String {
    let c: Vec<char> = line.chars().collect();
    let mut out = String::new();
    let mut j = 0;
    while j < c.len() {
        match c[j] {
            '\\' => {
                out.extend(&c[j..(j + 2).min(c.len())]);
                j += 2;
            }
            '`' => {
                let run = c[j..].iter().take_while(|&&x| x == '`').count();
                let close = (j + run..c.len()).find(|&k| {
                    c[k..].iter().take_while(|&&x| x == '`').count() == run
                        && (k == 0 || c[k - 1] != '`')
                });
                match close {
                    Some(k) => j = k + run,
                    None => {
                        out.extend(&c[j..j + run]);
                        j += run;
                    }
                }
            }
            x => {
                out.push(x);
                j += 1;
            }
        }
    }
    out
}

/// A YAML line with the escapes of its double-quoted scalars decoded (`\\` becomes `\`; `\n`,
/// ` ` and the like become a space).
fn yaml_unescape(line: &str) -> String {
    let c: Vec<char> = line.chars().collect();
    let mut out = String::new();
    let mut quoted = false;
    let mut j = 0;
    while j < c.len() {
        let hex = match c.get(j + 1) {
            Some('x') => 2,
            Some('u') => 4,
            Some('U') => 8,
            _ => 0,
        };
        match (quoted, c[j]) {
            (true, '\\') if c.get(j + 1) == Some(&'\\') => {
                out.push('\\');
                j += 2;
            }
            (true, '\\') => {
                out.push(' ');
                j += 2 + hex;
            }
            (_, '"') => {
                quoted = !quoted;
                out.push('"');
                j += 1;
            }
            (_, x) => {
                out.push(x);
                j += 1;
            }
        }
    }
    out
}

/// Raw typst or LaTeX on one (code-free) line: (kind, token).
fn raw(line: &str) -> Vec<(&'static str, String)> {
    let mut out = Vec::new();
    let c: Vec<char> = line.chars().collect();
    let mut j = 0;
    while j < c.len() {
        let word_end = |from: usize, ok: fn(char) -> bool| {
            (from..c.len()).find(|&k| !ok(c[k])).unwrap_or(c.len())
        };
        match c[j] {
            '\\' if c.get(j + 1).is_some_and(|x| x.is_ascii_alphabetic()) => {
                let e = word_end(j + 1, |x| x.is_ascii_alphabetic());
                out.push(("raw-latex", c[j..e].iter().collect()));
                j = e;
            }
            '\\' => j += 2,
            '#' if c.get(j + 1).is_some_and(|x| x.is_ascii_alphabetic())
                && (j == 0 || c[j - 1].is_whitespace() || matches!(c[j - 1], '(' | '[' | '{')) =>
            {
                let e = word_end(j + 1, |x| x.is_alphanumeric() || x == '_' || x == '-');
                let word: String = c[j + 1..e].iter().collect();
                let call = matches!(c.get(e), Some('(' | '[' | '.'))
                    && c.get(e + 1).is_some_and(|x| !x.is_whitespace());
                let kw = TYPST_WORDS.contains(&word.as_str())
                    && c.get(e).is_none_or(|x| !x.is_alphanumeric());
                if call || kw {
                    out.push(("raw-typst", c[j..e].iter().collect()));
                }
                j = e;
            }
            _ => j += 1,
        }
    }
    out
}

/// A paragraph line ending in a hard break: two or more spaces, or an odd run of backslashes.
fn hard_break(line: &str) -> bool {
    let slashes = line.len() - line.trim_end_matches('\\').len();
    !line.trim().is_empty() && (line.ends_with("  ") || slashes % 2 == 1)
}

pub fn check(file: &str, text: &str) -> Vec<Finding> {
    let lines: Vec<&str> = text.lines().collect();
    let mut out = Vec::new();
    let mut add = |i: usize, kind: &'static str, detail: String| {
        out.push(Finding {
            kind,
            file: file.to_string(),
            line: i + 1,
            detail,
        })
    };
    let front_end = match lines.first().map(|l| l.trim_end()) {
        Some("---") => (1..lines.len())
            .find(|&i| matches!(lines[i].trim_end(), "---" | "..."))
            .map_or(0, |i| i + 1),
        _ => 0,
    };
    let mut fence: Option<String> = None;
    for (i, line) in lines.iter().enumerate() {
        let t = line.trim_start();
        let tick = ["```", "~~~"].into_iter().find(|f| t.starts_with(f));
        match (&fence, tick) {
            (Some(f), Some(_))
                if t.trim_end()
                    .strip_prefix(f.as_str())
                    .is_some_and(|r| r.trim().is_empty()) =>
            {
                fence = None;
                continue;
            }
            (Some(_), _) => continue,
            (None, Some(_)) => {
                let run = t.len() - t.trim_start_matches(t.chars().next().unwrap_or('`')).len();
                fence = Some(t[..run].to_string());
                let info = t[run..].trim().to_ascii_lowercase();
                for (k, w) in [
                    ("raw-typst", "=typst"),
                    ("raw-latex", "=latex"),
                    ("raw-latex", "=tex"),
                ] {
                    if info.contains(&format!("{{{w}}}")) || info.starts_with(w) {
                        add(i, k, format!("raw {} block `{}`", &w[1..], t.trim_end()));
                    }
                }
                continue;
            }
            (None, None) => {}
        }
        let front = i < front_end;
        if front && t.starts_with('#') {
            continue;
        }
        let text = match front {
            true => yaml_unescape(line),
            false => line.to_string(),
        };
        for (kind, tok) in raw(&without_code(&text)) {
            add(i, kind, format!("`{tok}`"));
        }
        let next_text = lines.get(i + 1).is_some_and(|n| !n.trim().is_empty());
        if !front && next_text && hard_break(line) {
            let how = match line.ends_with('\\') {
                true => "trailing backslash",
                false => "two trailing spaces",
            };
            add(i, "hardbreak", format!("hard line break ({how})"));
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    const MD: &str = "---
# a YAML comment with #set
title: 'Brief \\textbf{x}'
short: \"Sec.\\u00A0523\\nNext \\\\emph{y} and \\\\\\\\ok\"
---
# Heading

90\\. Not a list. \\- dash, \\* star, C# and a url https://x.org/a#frag, #ad #MO-61088 #IT
Line one \x20
line two\\
line three\\\\
end.

Signed #linebreak() and `#set text()` in code, \\vspace{1em}. #set par(x) #text[y] #h(1em)
(#v(2pt)) [#pagebreak()] the \\`equities' doctrine and `code` \\\\vspace

```{=typst}
#pagebreak()
```

```rust
let x = \\textbf;
```
Last line with trailing spaces \x20
";

    #[test]
    fn findings() {
        let f = check("usage/INPUT-ca9-x.md", MD);
        let got: Vec<(usize, &str, &str)> = f
            .iter()
            .map(|x| (x.line, x.kind, x.detail.as_str()))
            .collect();
        assert_eq!(
            got,
            vec![
                (3, "raw-latex", "`\\textbf`"),
                (4, "raw-latex", "`\\emph`"),
                (9, "hardbreak", "hard line break (two trailing spaces)"),
                (10, "hardbreak", "hard line break (trailing backslash)"),
                (14, "raw-typst", "`#linebreak`"),
                (14, "raw-latex", "`\\vspace`"),
                (14, "raw-typst", "`#set`"),
                (14, "raw-typst", "`#text`"),
                (14, "raw-typst", "`#h`"),
                (15, "raw-typst", "`#v`"),
                (15, "raw-typst", "`#pagebreak`"),
                (17, "raw-typst", "raw typst block ````{=typst}`"),
            ]
        );
    }

    #[test]
    fn helpers() {
        assert_eq!(without_code("a `#x` b ``c ` d`` e"), "a  b  e");
        assert_eq!(without_code("a \\`x` b"), "a \\`x` b");
        assert_eq!(
            yaml_unescape("k: \"a\\u00A0b\\\\c\" \\d"),
            "k: \"a b\\c\" \\d"
        );
        assert!(hard_break("x\\"));
        assert!(!hard_break("x\\\\"));
        assert!(!hard_break("x "));
    }
}
