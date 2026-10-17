//! Rule (b), LaTeX: in the document body (after `\begin{document}`), no `\\`, `\newline`,
//! `\linebreak` and no `\vspace{<literal>}` (a length that starts with a number, `1.2\baselineskip`
//! included). The preamble is the parameter block and is not checked. `\\` is allowed inside
//! tabular-like and display-math environments, and inside a pandoc-template loop
//! (`$for(x)$..\\..$endfor$`, `$sep$\\`), where it separates repeated data items, not text.
use super::Finding;

const TABULAR: &[&str] = &[
    "tabular",
    "tabular*",
    "tabularx",
    "longtable",
    "array",
    "tabu",
    "supertabular",
    "xltabular",
    "align",
    "align*",
    "eqnarray",
    "eqnarray*",
    "gather",
    "gather*",
    "multline",
    "split",
    "matrix",
    "pmatrix",
    "bmatrix",
    "cases",
];

/// The line without its `%` comment (an escaped `\%` is not a comment).
fn strip_comment(line: &str) -> &str {
    let b = line.as_bytes();
    let mut j = 0;
    while j < b.len() {
        match b[j] {
            b'\\' => j += 2,
            b'%' => return &line[..j],
            _ => j += 1,
        }
    }
    line
}

/// The `{...}` group starting at byte `at` (after optional blanks), without braces.
fn group(s: &str, at: usize) -> Option<&str> {
    let rest = s.get(at..)?.trim_start();
    let inner = rest.strip_prefix('{')?;
    let mut d = 1;
    for (j, c) in inner.char_indices() {
        match c {
            '{' => d += 1,
            '}' if d == 1 => return Some(&inner[..j]),
            '}' => d -= 1,
            _ => {}
        }
    }
    None
}

fn literal(arg: &str) -> bool {
    let a = arg.trim().trim_start_matches(['-', '+']);
    a.starts_with(|c: char| c.is_ascii_digit() || c == '.')
        && !a.chars().all(|c| matches!(c, '0' | '.' | 'p' | 't'))
}

pub fn check(file: &str, text: &str) -> Vec<Finding> {
    let mut out = Vec::new();
    let mut body = false;
    let mut table = 0usize;
    let mut loops = 0usize;
    for (i, raw) in text.lines().enumerate() {
        let line = strip_comment(raw);
        if !body {
            body = line.contains("\\begin{document}");
            continue;
        }
        let mut add = |kind: &'static str, detail: String| {
            out.push(Finding {
                kind,
                file: file.to_string(),
                line: i + 1,
                detail,
            })
        };
        let b = line.as_bytes();
        let mut j = 0;
        while j < b.len() {
            if b[j] != b'\\' {
                j += 1;
                continue;
            }
            if b.get(j + 1) == Some(&b'\\') {
                let pre = &line[..j];
                let data = loops + pre.matches("$for(").count() > pre.matches("$endfor$").count();
                if table == 0 && !data {
                    add("break", "forced line break `\\\\`".into());
                }
                j += 2;
                continue;
            }
            let name_len = line[j + 1..]
                .find(|c: char| !c.is_ascii_alphabetic())
                .unwrap_or(line.len() - j - 1);
            let name = &line[j + 1..j + 1 + name_len];
            let after = j + 1 + name_len;
            let star = line[after..].starts_with('*');
            let env = group(line, after);
            match name {
                "begin" if env.is_some_and(|e| TABULAR.contains(&e)) => table += 1,
                "end" if env.is_some_and(|e| TABULAR.contains(&e)) => {
                    table = table.saturating_sub(1)
                }
                "newline" | "linebreak" => add("break", format!("forced line break `\\{name}`")),
                "vspace" => {
                    if let Some(arg) = group(line, after + usize::from(star)).filter(|a| literal(a))
                    {
                        add(
                            "vspace",
                            format!("magic vertical space `\\vspace{{{arg}}}`"),
                        );
                    }
                }
                _ => {}
            }
            j = after.max(j + 2);
        }
        loops = (loops + line.matches("$for(").count())
            .saturating_sub(line.matches("$endfor$").count());
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    const TEX: &str = r"\documentclass{article}
\newcommand\gap{\vspace{2.5pt}\\}
\begin{document}
Name\\Firm
$for(author)$$author$$sep$\\$endfor$
$for(lines)$\\
$lines$\\
$endfor$ $signer$\\
\begin{tabular}{ll} a & b \\ c & d \\ \end{tabular}
\vspace{1.2\baselineskip} \vspace*{12pt} \vspace{\parskip} \vspace{0pt}
x\newline y \linebreak[4] % \\ in a comment, 50\% \\
\end{document}
";

    #[test]
    fn body_only() {
        let f = check("latex/template.tex", TEX);
        let got: Vec<(usize, &str, &str)> = f
            .iter()
            .map(|x| (x.line, x.kind, x.detail.as_str()))
            .collect();
        assert_eq!(
            got,
            vec![
                (4, "break", "forced line break `\\\\`"),
                (8, "break", "forced line break `\\\\`"),
                (
                    10,
                    "vspace",
                    "magic vertical space `\\vspace{1.2\\baselineskip}`"
                ),
                (10, "vspace", "magic vertical space `\\vspace{12pt}`"),
                (11, "break", "forced line break `\\newline`"),
                (11, "break", "forced line break `\\linebreak`"),
            ]
        );
    }
}
