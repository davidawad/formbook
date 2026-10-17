//! The bridge to the shell checks: one `sh` per check runs `chk_<method>` from tools/check/lib.sh.
use super::sh::{cmd, flush, io_fail, Env};
use crate::Res;
use std::io::Write;
use std::process::Stdio;

/// Sources lib.sh, runs one check and appends its verdict after a NUL-framed marker on stdout.
/// Anything the check itself prints comes before the marker and is passed through.
const SCRIPT: &str = r#". "$ROOT/tools/check/lib.sh"
fb_method=$1
shift
ST=FAIL
MEAS="(check did not run)"
DETAIL=""
"chk_$fb_method" "$@"
printf '\000fb-check-verdict\000%s\000%s\000%s' "$ST" "$MEAS" "$DETAIL"
"#;

const MARK: &[u8] = b"\0fb-check-verdict\0";

#[derive(Debug, PartialEq)]
pub struct Verdict {
    pub pass: bool,
    pub meas: String,
    pub detail: String,
}

/// Split the bridge's stdout into the check's own output and its verdict.
pub fn parse(out: &[u8]) -> (&[u8], Verdict) {
    let at = (0..=out.len().saturating_sub(MARK.len()))
        .rev()
        .find(|&i| out[i..].starts_with(MARK));
    let (own, tail) = at.map_or((out, &b""[..]), |i| (&out[..i], &out[i + MARK.len()..]));
    let mut f = tail.split(|&b| b == 0).map(String::from_utf8_lossy);
    let st = f.next().unwrap_or_default();
    let meas = f
        .next()
        .map_or("(check did not run)".to_string(), |s| s.into_owned());
    let detail = f.next().unwrap_or_default().into_owned();
    let v = Verdict {
        pass: at.is_some() && st == "PASS",
        meas,
        detail,
    };
    (own, v)
}

/// Run `chk_<method> args...` with the per-sample variables of check.sh in the environment.
pub fn run(env: &Env, vars: &[(&str, &str)], method: &str, args: &[String]) -> Res<Verdict> {
    let mut c = cmd(env, "sh", &["-c", SCRIPT, "fb-check", method]);
    c.args(args)
        .envs(vars.iter().copied())
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit());
    flush();
    let o = c.output().map_err(|e| io_fail("sh", e))?;
    let (own, v) = parse(&o.stdout);
    let mut so = std::io::stdout().lock();
    let _ = so.write_all(own);
    let _ = so.flush();
    Ok(v)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verdicts() {
        let (own, v) = parse(b"hello\n\0fb-check-verdict\0PASS\0m 1\0");
        assert_eq!(own, b"hello\n");
        assert_eq!(
            v,
            Verdict {
                pass: true,
                meas: "m 1".into(),
                detail: "".into()
            }
        );
        let (_, v) = parse(b"\0fb-check-verdict\0FAIL\0m\0a\nb");
        assert!(!v.pass);
        assert_eq!(v.detail, "a\nb");
        let (own, v) = parse(b"partial");
        assert_eq!(
            (own, v.pass, v.meas.as_str()),
            (&b"partial"[..], false, "(check did not run)")
        );
    }
}
