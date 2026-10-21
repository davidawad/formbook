//! `fb lint pipefail`: no shell under tools/ pipes into a grep that stops reading early.
//! Every script under tools/ runs with `set -o pipefail` (fragments are sourced into one that does), and
//! a `grep -q` (also `-l`, `-m`, `--quiet`, `--silent`, `--files-with-matches`, `--max-count`) exits at
//! its first match, so the writer upstream can die of SIGPIPE and the pipeline then reports failure even
//! though grep matched: a random, load-dependent check failure (CA9-GEN-001, fb-595.71). Feed grep a
//! file or a here-string (`grep -q re <<< "$x"`) instead.
//!
//! The scan is quote-, comment- and heredoc-aware: a `|` inside quotes (awk, jq programs) or in a comment
//! is not a pipe. Output: `LINT pipefail <path>:<line>: <detail>`; exit 1 on findings.
use crate::{repo_root, Res};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

/// A command of a pipeline that reads the previous command's output: its first line and its words.
struct Consumer {
    line: usize,
    text: String,
}

/// The commands of `src` that follow an unquoted `|`.
fn consumers(src: &str) -> Vec<Consumer> {
    let chars: Vec<char> = src.chars().collect();
    let (mut out, mut cur) = (Vec::new(), String::new());
    let (mut piped, mut start, mut line) = (false, 1usize, 1usize);
    let (mut sq, mut dq) = (false, false);
    let mut heredocs: Vec<(String, bool)> = Vec::new();
    let mut i = 0;
    let flush = |cur: &mut String, piped: bool, start: usize, out: &mut Vec<Consumer>| {
        if piped && !cur.trim().is_empty() {
            out.push(Consumer {
                line: start,
                text: cur.trim().to_string(),
            });
        }
        cur.clear();
    };
    while i < chars.len() {
        let c = chars[i];
        let next = chars.get(i + 1).copied();
        if c == '\n' {
            line += 1;
        }
        if sq {
            sq = c != '\'';
            cur.push(c);
            i += 1;
            continue;
        }
        if dq {
            match c {
                '\\' => {
                    cur.push(c);
                    if let Some(n) = next {
                        cur.push(n);
                        line += usize::from(n == '\n');
                    }
                    i += 2;
                    continue;
                }
                '"' => dq = false,
                _ => {}
            }
            cur.push(c);
            i += 1;
            continue;
        }
        let word_start = i == 0 || chars[i - 1].is_whitespace() || ";|&()".contains(chars[i - 1]);
        match c {
            '\\' => {
                // a line continuation keeps the command going
                if next == Some('\n') {
                    line += 1;
                    cur.push(' ');
                } else if let Some(n) = next {
                    cur.push(c);
                    cur.push(n);
                }
                i += 2;
                continue;
            }
            '\'' => sq = true,
            '"' => dq = true,
            '#' if word_start => {
                while i < chars.len() && chars[i] != '\n' {
                    i += 1;
                }
                continue;
            }
            '<' if next == Some('<') && chars.get(i + 2) != Some(&'<') => {
                // heredoc: remember the delimiter, skip the body after this line
                let mut j = i + 2;
                let strip = chars.get(j) == Some(&'-');
                j += usize::from(strip);
                while chars.get(j).is_some_and(|c| *c == ' ') {
                    j += 1;
                }
                let mut delim = String::new();
                while let Some(&d) = chars.get(j) {
                    if d.is_whitespace() || ";|&()<>".contains(d) {
                        break;
                    }
                    if !"'\"\\".contains(d) {
                        delim.push(d);
                    }
                    j += 1;
                }
                cur.push_str("<<");
                cur.push_str(&delim);
                heredocs.push((delim, strip));
                i = j;
                continue;
            }
            '\n' => {
                // a line that ends in a pipe continues on the next
                if !(piped && cur.trim().is_empty()) {
                    flush(&mut cur, piped, start, &mut out);
                    piped = false;
                }
                i += 1;
                for (delim, strip) in std::mem::take(&mut heredocs) {
                    while i < chars.len() {
                        let end = chars[i..]
                            .iter()
                            .position(|c| *c == '\n')
                            .map_or(chars.len(), |p| i + p);
                        let body: String = chars[i..end].iter().collect();
                        let body = if strip {
                            body.trim_start_matches('\t')
                        } else {
                            &body
                        };
                        i = (end + 1).min(chars.len());
                        line += 1;
                        if body == delim {
                            break;
                        }
                    }
                }
                continue;
            }
            '|' if next != Some('|') => {
                flush(&mut cur, piped, start, &mut out);
                piped = true;
                i += 1 + usize::from(next == Some('&'));
                continue;
            }
            '|' | '&' | ';' | '(' | ')' => {
                flush(&mut cur, piped, start, &mut out);
                piped = false;
                let double = next == Some(c) && c != '(' && c != ')';
                i += 1 + usize::from(double);
                continue;
            }
            _ => {}
        }
        if cur.trim().is_empty() && !c.is_whitespace() {
            start = line;
        }
        cur.push(c);
        i += 1;
    }
    flush(&mut cur, piped, start, &mut out);
    out
}

/// The option of a grep command that makes it stop reading early, if any.
fn early_exit(cmd: &str) -> Option<String> {
    let mut words = cmd
        .split_whitespace()
        .skip_while(|w| *w == "!" || *w == "command");
    let name = words.next()?;
    if !matches!(name, "grep" | "egrep" | "fgrep") {
        return None;
    }
    let mut words = words.peekable();
    while let Some(w) = words.next() {
        if w == "--" || !w.starts_with('-') || w == "-" {
            return None;
        }
        if let Some(long) = w.strip_prefix("--") {
            let long = long.split('=').next().unwrap_or(long);
            if matches!(
                long,
                "quiet" | "silent" | "files-with-matches" | "max-count"
            ) {
                return Some(w.to_string());
            }
            if !w.contains('=')
                && matches!(
                    long,
                    "regexp" | "file" | "after-context" | "before-context" | "context"
                )
            {
                words.next();
            }
            continue;
        }
        for (k, ch) in w.char_indices().skip(1) {
            if "qlm".contains(ch) {
                return Some(w.to_string());
            }
            // an option with an argument: the rest of the word, or the next word
            if "efABCdD".contains(ch) {
                if k + 1 == w.len() {
                    words.next();
                }
                break;
            }
        }
    }
    None
}

pub fn check_text(name: &str, text: &str) -> Vec<String> {
    consumers(text)
        .into_iter()
        .filter_map(|c| {
            early_exit(&c.text).map(|opt| {
                format!(
                    "LINT pipefail {name}:{}: `| {}`: grep {opt} exits at its first match and under pipefail the writer's SIGPIPE fails the pipeline; feed grep a file or a here-string",
                    c.line, c.text
                )
            })
        })
        .collect()
}

fn is_shell(p: &Path) -> bool {
    match p.extension().and_then(|e| e.to_str()) {
        Some("sh" | "bash") => true,
        Some(_) => false,
        None => std::fs::read_to_string(p).is_ok_and(|t| {
            t.lines()
                .next()
                .is_some_and(|l| l.starts_with("#!") && (l.ends_with("sh") || l.contains("bash")))
        }),
    }
}

fn shell_files(dir: &Path, v: &mut Vec<PathBuf>) {
    let Ok(rd) = std::fs::read_dir(dir) else {
        return;
    };
    let mut entries: Vec<PathBuf> = rd.filter_map(|e| e.ok()).map(|e| e.path()).collect();
    entries.sort();
    for p in entries {
        let skip = p.file_name().is_some_and(|n| n == "target" || n == ".git");
        if p.is_dir() && !skip {
            shell_files(&p, v);
        } else if p.is_file() && is_shell(&p) {
            v.push(p);
        }
    }
}

/// Findings over every shell file under `<root>/tools`, and the number of files read.
pub fn check(root: &Path) -> (usize, Vec<String>) {
    let mut files = Vec::new();
    shell_files(&root.join("tools"), &mut files);
    let found = files
        .iter()
        .flat_map(|p| {
            let name = p
                .strip_prefix(root)
                .unwrap_or(p)
                .to_string_lossy()
                .into_owned();
            check_text(&name, &std::fs::read_to_string(p).unwrap_or_default())
        })
        .collect();
    (files.len(), found)
}

pub fn main() -> Res<ExitCode> {
    let (n, found) = check(&repo_root()?);
    found.iter().for_each(|x| println!("{x}"));
    match found.len() {
        0 => {
            println!("RESULT: LINT PIPEFAIL PASS ({n} files)");
            Ok(ExitCode::SUCCESS)
        }
        k => {
            println!("RESULT: LINT PIPEFAIL FAIL ({k} findings in {n} files)");
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lines(src: &str) -> Vec<usize> {
        check_text("t.sh", src)
            .iter()
            .map(|f| f.split(':').nth(1).unwrap().parse().unwrap())
            .collect()
    }

    #[test]
    fn rejects_early_exit_grep_in_a_pipe() {
        // the CA9-GEN-001 defect of fb-595.71
        assert_eq!(
            lines("has() { printf '%s\\n' \"$body\" | grep -Eq \"$1\"; }\n"),
            [1]
        );
        assert_eq!(
            lines("x\nif cmd | sed s/a/b/ | grep -q y; then :; fi\n"),
            [2]
        );
        assert_eq!(
            lines("a | grep --quiet x\nb | grep -c x | grep -qx 1\n"),
            [1, 2]
        );
        assert_eq!(
            lines("a | grep -l x\na | grep -m1 x\na | grep --max-count=1 x\n"),
            [1, 2, 3]
        );
        assert_eq!(lines("cmd |\n  grep -F -q -- \"$n\"\n"), [2]);
        assert_eq!(lines("cmd \\\n  | grep -q x\n"), [2]);
        assert_eq!(lines("v=$(a | grep -q b && echo y)\n"), [1]);
        assert_eq!(lines("a |& grep -q x\n! a | grep -q x\n"), [1, 2]);
        assert_eq!(
            lines("a | grep -e x -q\na | grep --regexp x --quiet\n"),
            [1, 2]
        );
    }

    #[test]
    fn accepts_safe_forms() {
        for ok in [
            "has() { grep -Eq \"$1\" <<< \"$body\"; }\n",
            "grep -q x file\n",
            "a | grep -c x\n",
            "a | grep -v x | wc -l\n",
            "a | grep -e -q\n",
            "a | grep -- -q\n",
            "a || grep -q x f\n",
            "# not code: printf | grep -q\n",
            "echo hi # printf x | grep -q y\n",
            "awk '{ print $1 | \"grep -q x\" }' f\n",
            "jq -r '.a | grep -q'\n",
            "echo \"a | grep -q b\"\n",
            "echo ${#x} | grep -c x\n",
            "cat <<'EOF'\na | grep -q x\nEOF\necho ok\n",
            "cat <<-EOF > f\n\ta | grep -q x\n\tEOF\n",
        ] {
            assert!(
                check_text("t.sh", ok).is_empty(),
                "{ok:?}: {:?}",
                check_text("t.sh", ok)
            );
        }
    }

    #[test]
    fn heredoc_keeps_line_numbers() {
        assert_eq!(lines("cat <<EOF\none\ntwo\nEOF\na | grep -q x\n"), [5]);
    }

    #[test]
    fn tools_tree_is_clean() {
        let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
        let (n, found) = check(&root);
        assert!(n > 0, "no shell files found under tools/");
        assert!(found.is_empty(), "{}", found.join("\n"));
    }
}
