//! Child processes and the bits of shell/awk semantics the driver relies on.
use crate::{fail, Fail, Res};
use std::fs::File;
use std::io::Write;
use std::process::{Command, Stdio};

/// Environment every child gets (check.sh exported LC_ALL, then TEMPLATE and ENGINE).
pub type Env = Vec<(String, String)>;

pub fn io_fail(what: &str, e: std::io::Error) -> Fail {
    fail(2, format!("fb check: {what}: {e}"))
}

/// Flush our stdout so child output lands after what we printed.
pub fn flush() {
    let _ = std::io::stdout().flush();
}

/// Print to stdout and flush (children share the stream).
pub fn out(s: &str) {
    let mut o = std::io::stdout().lock();
    let _ = o.write_all(s.as_bytes());
    let _ = o.flush();
}

pub fn cmd(env: &Env, prog: &str, args: &[&str]) -> Command {
    let mut c = Command::new(prog);
    c.args(args);
    c.envs(env.iter().map(|(k, v)| (k.as_str(), v.as_str())));
    c
}

/// `$(...)`: stdout with trailing newlines removed, stderr passed through; also the exit status.
pub fn capture(mut c: Command) -> Res<(String, bool)> {
    flush();
    let o = c
        .stderr(Stdio::inherit())
        .output()
        .map_err(|e| io_fail(&format!("{c:?}"), e))?;
    let s = String::from_utf8_lossy(&o.stdout).into_owned();
    Ok((strip_nl(&s).to_string(), o.status.success()))
}

/// Run with stdout to a file (created/truncated); returns success.
pub fn to_file(mut c: Command, path: &str) -> Res<bool> {
    flush();
    let f = File::create(path).map_err(|e| io_fail(path, e))?;
    let st = c
        .stdout(f)
        .status()
        .map_err(|e| io_fail(&format!("{c:?}"), e))?;
    Ok(st.success())
}

/// `a | b > path` (stderrs as the commands set them).
pub fn pipe_to_file(mut a: Command, mut b: Command, path: &str) -> Res<()> {
    flush();
    let f = File::create(path).map_err(|e| io_fail(path, e))?;
    let mut ca = a
        .stdout(Stdio::piped())
        .spawn()
        .map_err(|e| io_fail(&format!("{a:?}"), e))?;
    let src = ca
        .stdout
        .take()
        .ok_or_else(|| fail(2, "fb check: no pipe"))?;
    let rb = b.stdin(src).stdout(f).status();
    let _ = ca.wait();
    rb.map(|_| ()).map_err(|e| io_fail(&format!("{b:?}"), e))
}

/// `a | b` captured like `$(...)` (both stderrs passed through).
pub fn pipe_capture(mut a: Command, b: Command) -> Res<String> {
    flush();
    let mut ca = a
        .stdout(Stdio::piped())
        .spawn()
        .map_err(|e| io_fail(&format!("{a:?}"), e))?;
    let src = ca
        .stdout
        .take()
        .ok_or_else(|| fail(2, "fb check: no pipe"))?;
    let mut b = b;
    b.stdin(src);
    let r = capture(b);
    let _ = ca.wait();
    r.map(|(s, _)| s)
}

/// `yq e EXPR <court>/checks.yaml` (lib.sh's `cfg`).
pub fn cfg(env: &Env, court: &str, expr: &str) -> Res<String> {
    let file = format!("{court}/checks.yaml");
    capture(cmd(env, "yq", &["e", expr, &file])).map(|(s, _)| s)
}

pub fn strip_nl(s: &str) -> &str {
    s.trim_end_matches('\n')
}

/// Length of the longest prefix of `s` that is an awk number (sign, digits, fraction, exponent).
fn num_prefix(s: &str) -> usize {
    let b = s.as_bytes();
    let digits = |mut i: usize| {
        let st = i;
        while i < b.len() && b[i].is_ascii_digit() {
            i += 1;
        }
        (i, i - st)
    };
    let i = usize::from(matches!(b.first(), Some(b'+' | b'-')));
    let (i, n1) = digits(i);
    let (i, n2) = match b.get(i) {
        Some(b'.') => digits(i + 1),
        _ => (i, 0),
    };
    if n1 + n2 == 0 {
        return 0;
    }
    let exp = match b.get(i) {
        Some(b'e' | b'E') => {
            let j = i + 1 + usize::from(matches!(b.get(i + 1), Some(b'+' | b'-')));
            let (k, n) = digits(j);
            (n > 0).then_some(k)
        }
        _ => None,
    };
    exp.unwrap_or(i)
}

/// awk's string-to-number conversion: leading blanks skipped, the numeric prefix, else 0.
pub fn awk_num(s: &str) -> f64 {
    let t = s.trim_start_matches([' ', '\t', '\n']);
    t[..num_prefix(t)].parse().unwrap_or(0.0)
}

/// Does an input field look numeric to awk (a "strnum")?
pub fn is_strnum(s: &str) -> bool {
    let t = s.trim_matches([' ', '\t', '\n']);
    !t.is_empty() && num_prefix(t) == t.len()
}

/// awk records of a tab-separated file: lines (last one without newline included), fields on every tab.
pub fn awk_rows(text: &str) -> Vec<Vec<&str>> {
    let body = text.strip_suffix('\n').unwrap_or(text);
    match text.is_empty() {
        true => vec![],
        false => body.split('\n').map(|l| l.split('\t').collect()).collect(),
    }
}

/// awk comparison of a field with a numeric constant: numeric if the field is a strnum, else string.
pub fn awk_cmp(field: &str, n: f64, n_text: &str) -> std::cmp::Ordering {
    match is_strnum(field) {
        true => awk_num(field)
            .partial_cmp(&n)
            .unwrap_or(std::cmp::Ordering::Equal),
        false => field.cmp(n_text),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn numbers() {
        assert_eq!(awk_num("0.71000"), 0.71);
        assert_eq!(awk_num(" 14pt"), 14.0);
        assert_eq!(awk_num(""), 0.0);
        assert_eq!(awk_num("1e3x"), 1000.0);
        assert_eq!(awk_num("2e"), 2.0);
        assert_eq!(awk_num("-.5"), -0.5);
        assert!(is_strnum("71.98"));
        assert!(!is_strnum("level"));
        assert!(!is_strnum(""));
        assert!(!is_strnum("7a"));
    }

    #[test]
    fn rows() {
        assert!(awk_rows("").is_empty());
        assert_eq!(awk_rows("a\tb\nc"), vec![vec!["a", "b"], vec!["c"]]);
        assert_eq!(awk_rows("\n"), vec![vec![""]]);
        assert_eq!(strip_nl("x\n\n"), "x");
    }
}
