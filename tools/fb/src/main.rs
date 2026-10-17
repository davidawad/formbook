//! `fb`: formbook tooling. Subcommands replace the branching of tools/check.sh,
//! tools/manifest.sh and tools/tracker.sh (and tools/gen_readmes.py).
mod check;
mod manifest;
mod readmes;
mod track;
mod tracker;

use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let (cmd, rest) = args
        .split_first()
        .map_or(("", &[][..]), |(c, r)| (c.as_str(), r));
    let result = match cmd {
        "check" => check::main(rest),
        "manifest" => manifest::main(rest),
        "tracker" => track::main(rest),
        "readmes" => readmes::main(rest),
        _ => Err(fail(2, "usage: fb check|manifest|tracker|readmes ...")),
    };
    result.unwrap_or_else(|e| {
        eprintln!("{}", e.msg);
        ExitCode::from(e.code)
    })
}

/// An error that ends the program: message for stderr and exit status.
#[derive(Debug)]
pub struct Fail {
    pub code: u8,
    pub msg: String,
}

pub fn fail(code: u8, msg: impl Into<String>) -> Fail {
    Fail {
        code,
        msg: msg.into(),
    }
}

pub type Res<T> = Result<T, Fail>;

/// The repo root: `$FB_ROOT` (set by the tools/*.sh wrappers), else the nearest ancestor of the current
/// directory holding data/index.json.
pub fn repo_root() -> Res<std::path::PathBuf> {
    let cwd = std::env::current_dir().map_err(|e| fail(2, format!("fb: {e}")))?;
    std::env::var_os("FB_ROOT")
        .map(|r| std::fs::canonicalize(&r).unwrap_or_else(|_| r.into()))
        .or_else(|| {
            cwd.ancestors()
                .find(|d| d.join("data/index.json").is_file())
                .map(|d| d.to_path_buf())
        })
        .ok_or_else(|| fail(2, "fb: no repo root (set FB_ROOT or run inside the repo)"))
}
