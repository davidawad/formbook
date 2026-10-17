//! Rule (b), typst: no forced line breaks (`linebreak(`, a markup `\` break) and no `v(<literal>)`
//! outside the named-parameter block: the leading run of top-level `#let name = value` lines (comments
//! and blank lines allowed in between) after the file's opening comments and imports. `v(name)`,
//! `v(name * 0.5)`, `v(1fr)` and `v(0pt)` are fine anywhere.
use super::Finding;

/// The line with string literals blanked and comments removed; `block` carries `/* */` across lines.
pub fn code_only(line: &str, block: &mut bool) -> String {
    let mut out = String::new();
    let mut chars = line.chars().peekable();
    let mut in_str = false;
    while let Some(c) = chars.next() {
        match (*block, in_str, c, chars.peek().copied()) {
            (true, _, '*', Some('/')) => {
                chars.next();
                *block = false;
            }
            (true, ..) => {}
            (_, true, '\\', _) => {
                chars.next();
            }
            (_, true, '"', _) => {
                in_str = false;
                out.push('"');
            }
            (_, true, ..) => {}
            (_, false, '/', Some('/')) => break,
            (_, false, '/', Some('*')) => {
                chars.next();
                *block = true;
            }
            (_, false, '"', _) => {
                in_str = true;
                out.push('"');
            }
            _ => out.push(c),
        }
    }
    out
}

fn ident_char(c: char) -> bool {
    c.is_alphanumeric() || c == '_' || c == '-'
}

/// `#let name = ...` (not a function, not a destructuring).
fn param_let(code: &str) -> bool {
    let Some(rest) = code.strip_prefix("#let ") else {
        return false;
    };
    let name_len = rest.find(|c: char| !ident_char(c)).unwrap_or(rest.len());
    name_len > 0 && rest[name_len..].trim_start().starts_with('=')
}

fn depth(code: &str) -> i32 {
    code.chars()
        .map(|c| match c {
            '(' | '[' | '{' => 1,
            ')' | ']' | '}' => -1,
            _ => 0,
        })
        .sum()
}

/// Number of leading lines that form the header and named-parameter block.
pub fn param_block_end(lines: &[&str]) -> usize {
    let mut block = false;
    let mut d = 0;
    let mut seen_let = false;
    for (i, line) in lines.iter().enumerate() {
        let code = code_only(line, &mut block);
        let code = code.trim();
        if d > 0 {
            d += depth(code);
            continue;
        }
        let header = code.is_empty()
            || (!seen_let && (code.starts_with("#import") || code.starts_with("#include")));
        match (header, param_let(code)) {
            (true, _) => {}
            (_, true) => {
                seen_let = true;
                d = depth(code).max(0);
            }
            _ => return i,
        }
    }
    lines.len()
}

/// A numeric length literal other than zero or a fraction: `12pt`, `0.5em`, `-1in`, `10%`.
fn literal_length(arg: &str) -> bool {
    let a = arg.trim().trim_start_matches(['-', '+']);
    let num_end = a
        .find(|c: char| !(c.is_ascii_digit() || c == '.'))
        .unwrap_or(a.len());
    let (num, unit) = a.split_at(num_end);
    let zero = num.chars().all(|c| c == '0' || c == '.');
    !num.is_empty() && !zero && ["pt", "em", "in", "mm", "cm", "%"].contains(&unit)
}

/// The first argument of a call whose `(` is at `open`.
fn first_arg(code: &str, open: usize) -> &str {
    let mut d = 0;
    for (j, c) in code[open..].char_indices() {
        match c {
            '(' | '[' | '{' => d += 1,
            ')' | ']' | '}' if d == 1 => return &code[open + 1..open + j],
            ')' | ']' | '}' => d -= 1,
            ',' if d == 1 => return &code[open + 1..open + j],
            _ => {}
        }
    }
    &code[open + 1..]
}

/// Byte offsets of the `(` of each `name(` call in a line (the name not part of a longer identifier
/// and not a method).
fn calls(code: &str, name: &str) -> Vec<usize> {
    code.match_indices(&format!("{name}("))
        .filter(|(i, _)| {
            !code[..*i]
                .chars()
                .next_back()
                .is_some_and(|c| ident_char(c) || c == '.')
        })
        .map(|(i, _)| i + name.len())
        .collect()
}

/// A line break that separates repeated data items, not text: inside a one-line `for x in xs { .. }`
/// (or `[ .. ]`) body or `.join(linebreak())` (the typst form of a pandoc `$sep$\\`).
fn data_join(code: &str, at: usize) -> bool {
    let before = &code[..at];
    let in_loop = before.rfind("for ").is_some_and(|f| {
        let rest = &before[f + 4..];
        let var = rest.find(|c: char| !ident_char(c)).unwrap_or(rest.len());
        let body = rest[var..].find(['{', '[']).map(|p| &rest[var + p..]);
        var > 0 && rest[var..].starts_with(" in ") && body.is_some_and(|b| depth(b) > 0)
    });
    in_loop || before.ends_with(".join(linebreak")
}

pub fn check(file: &str, text: &str) -> Vec<Finding> {
    let lines: Vec<&str> = text.lines().collect();
    let start = param_block_end(&lines);
    let mut block = false;
    let mut out = Vec::new();
    let mut add = |line: usize, kind: &'static str, detail: String| {
        out.push(Finding {
            kind,
            file: file.to_string(),
            line: line + 1,
            detail,
        })
    };
    for (i, line) in lines.iter().enumerate() {
        let code = code_only(line, &mut block);
        if i < start {
            continue;
        }
        if calls(&code, "linebreak")
            .iter()
            .any(|&at| !data_join(&code, at))
        {
            add(i, "break", "forced line break `linebreak(`".into());
        }
        for open in calls(&code, "v") {
            let arg = first_arg(&code, open);
            if literal_length(arg) {
                add(
                    i,
                    "vspace",
                    format!("magic vertical space `v({})`", arg.trim()),
                );
            }
        }
        let bytes = code.as_bytes();
        let markup = (0..bytes.len()).filter(|&j| {
            bytes[j] == b'\\'
                && (j == 0 || bytes[j - 1] != b'\\')
                && bytes.get(j + 1).is_none_or(|c| c.is_ascii_whitespace())
        });
        if markup.into_iter().any(|at| !data_join(&code, at)) {
            add(i, "break", "forced line break: markup `\\`".into());
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    const TPL: &str = "// header comment
#import \"@preview/cmarker:0.1.10\"

#let gap = 12pt          // a named parameter
// a comment inside the block
#let margins = (
  top: 1in,
)
#let sep = v(6pt)
#let helper(x) = v(gap)
#v(12pt)
#v(gap * 0.5) #v(1fr) #v(0pt)
[Name #linebreak() Firm] // v(3pt) in a comment
#let s = \"v(9pt) \\\\ in a string\"
#block(above: 1em)[x \\
y]
#nav(2pt) #box.v(1pt)
#for n in names { n; linebreak() } names.join(linebreak())
#for n in names [#n] #linebreak()
#for l in g.lines [ #inl(l) \\ ]
[Brief for Appellant in Support \\ of Nothing]
";

    #[test]
    fn param_block() {
        let lines: Vec<&str> = TPL.lines().collect();
        assert_eq!(
            param_block_end(&lines),
            9,
            "block ends at the first function definition"
        );
        assert!(param_let("#let page-margin = 1in"));
        assert!(!param_let("#let f(x) = x"));
        assert!(!param_let("#let (a, b) = (1, 2)"));
    }

    #[test]
    fn findings() {
        let f = check("typst/t.typ", TPL);
        let got: Vec<(usize, &str, &str)> = f
            .iter()
            .map(|x| (x.line, x.kind, x.detail.as_str()))
            .collect();
        assert_eq!(
            got,
            vec![
                (11, "vspace", "magic vertical space `v(12pt)`"),
                (13, "break", "forced line break `linebreak(`"),
                (15, "break", "forced line break: markup `\\`"),
                (19, "break", "forced line break `linebreak(`"),
                (21, "break", "forced line break: markup `\\`"),
            ]
        );
    }

    #[test]
    fn literals() {
        for (a, want) in [
            ("12pt", true),
            (" 0.5em", true),
            ("-1in", true),
            ("10%", true),
            ("1fr", false),
            ("0pt", false),
            ("gap", false),
            ("gap * 2", false),
            ("2 * gap", false),
        ] {
            assert_eq!(literal_length(a), want, "{a}");
        }
    }
}
