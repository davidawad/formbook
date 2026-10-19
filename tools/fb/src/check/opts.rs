//! Arguments, the logical court path and court.json resolution (check.sh lines 1-60).
use crate::{fail, Res};
use std::path::Path;

pub const USAGE: &str =
    "usage: tools/check.sh <court-dir-or-doc-type> [--engine E] [--no-render] [--only SAMPLE_ID]";

#[derive(Debug, PartialEq)]
pub struct Opts {
    pub engine: String,
    pub render: bool,
    pub only: String,
}

/// The options after the folder, in check.sh's order: unknown options first, then the engine.
pub fn parse_opts(args: &[String]) -> Res<Opts> {
    let mut o = Opts {
        engine: "typst".into(),
        render: true,
        only: String::new(),
    };
    let mut it = args.iter();
    while let Some(a) = it.next() {
        let mut value = || {
            it.next()
                .cloned()
                .ok_or_else(|| fail(2, "tools/check.sh: shift: can't shift that many"))
        };
        match a.as_str() {
            "--no-render" => o.render = false,
            "--engine" => o.engine = value()?,
            "--only" => o.only = value()?,
            _ => return Err(fail(2, format!("unknown option {a}"))),
        }
    }
    match o.engine.as_str() {
        "typst" | "latex" | "docx" => Ok(o),
        e => Err(fail(2, format!("unknown engine {e} (typst, latex, docx)"))),
    }
}

/// Lexical normalization as `cd DIR && pwd` does it: `.` dropped, `..` pops a component.
pub fn normalize(path: &str) -> String {
    let parts = path.split('/').fold(Vec::<&str>::new(), |mut v, c| {
        match c {
            "" | "." => {}
            ".." => {
                v.pop();
            }
            _ => v.push(c),
        }
        v
    });
    format!("/{}", parts.join("/"))
}

/// The shell's idea of the current directory: $PWD when it names the cwd, else the real path.
fn logical_cwd() -> Res<String> {
    let real = std::env::current_dir().map_err(|e| fail(2, format!("fb check: {e}")))?;
    let pwd = std::env::var("PWD").ok().filter(|p| {
        p.starts_with('/') && std::fs::canonicalize(p).ok() == std::fs::canonicalize(&real).ok()
    });
    Ok(pwd.unwrap_or_else(|| real.to_string_lossy().into_owned()))
}

/// `DOC=$(cd "$1" && pwd)`.
pub fn logical_dir(arg: &str) -> Res<String> {
    let joined = match arg.starts_with('/') {
        true => arg.to_string(),
        false => format!("{}/{arg}", logical_cwd()?),
    };
    let d = normalize(&joined);
    match Path::new(&d).is_dir() {
        true => Ok(d),
        false => Err(fail(2, format!("tools/check.sh: cd: can't cd to {arg}"))),
    }
}

/// `dirname` of an absolute, normalized path.
pub fn dirname(p: &str) -> &str {
    match p.rfind('/') {
        Some(0) | None => "/",
        Some(i) => &p[..i],
    }
}

/// The nearest folder at or above DOC with court.json.
pub fn resolve_court(doc: &str) -> Res<String> {
    let mut c = doc.to_string();
    while !Path::new(&format!("{c}/court.json")).is_file() && c != "/" {
        c = dirname(&c).to_string();
    }
    match Path::new(&format!("{}/court.json", c.trim_end_matches('/'))).is_file() {
        false => Err(fail(2, format!("no court.json found above {doc}"))),
        true => Ok(c),
    }
}

/// `${DOC#"$ROOT/"}` with `/` turned into `_`.
pub fn doc_key(doc: &str, root: &str) -> String {
    let rel = doc.strip_prefix(&format!("{root}/")).unwrap_or(doc);
    rel.replace('/', "_")
}

#[cfg(test)]
mod tests {
    use super::*;

    fn v(a: &[&str]) -> Vec<String> {
        a.iter().map(|s| s.to_string()).collect()
    }

    #[test]
    fn options() {
        let o = parse_opts(&v(&["--no-render", "--engine", "latex", "--only", "x"])).unwrap();
        assert_eq!(
            o,
            Opts {
                engine: "latex".into(),
                render: false,
                only: "x".into()
            }
        );
        assert_eq!(parse_opts(&[]).unwrap().engine, "typst");
        assert_eq!(
            parse_opts(&v(&["--bogus"])).unwrap_err().msg,
            "unknown option --bogus"
        );
        let e = parse_opts(&v(&["--engine", "pdf"])).unwrap_err();
        assert_eq!(
            (e.code, e.msg.as_str()),
            (2, "unknown engine pdf (typst, latex, docx)")
        );
        // an unknown option wins over a bad engine given before it
        assert_eq!(
            parse_opts(&v(&["--engine", "pdf", "-x"])).unwrap_err().msg,
            "unknown option -x"
        );
        assert_eq!(parse_opts(&v(&["--only"])).unwrap_err().code, 2);
        assert_eq!(
            parse_opts(&v(&["--only", "--no-render"])).unwrap().only,
            "--no-render"
        );
    }

    #[test]
    fn paths() {
        assert_eq!(normalize("/a/./b/../c/"), "/a/c");
        assert_eq!(normalize("/.."), "/");
        assert_eq!(dirname("/a/b"), "/a");
        assert_eq!(dirname("/a"), "/");
        assert_eq!(doc_key("/r/courts/x/y", "/r"), "courts_x_y");
        assert_eq!(doc_key("/tmp/x", "/r"), "_tmp_x");
    }
}
