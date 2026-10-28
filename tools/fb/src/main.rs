//! `fb`: formbook tooling. Subcommands hold the logic that used to be shell: check, check-selftest, render
//! (typst, latex, docx), overlay, bootstrap, showcase, manifest, tracker, worklist, claim, contribute, find, new-filing, render-filing;
//! `fb readmes` replaces tools/gen_readmes.py. The tools/*.sh that remain are zero-branching `exec` wrappers.
mod bootstrap;
mod check;
mod checkchanged;
mod claim;
mod contribute;
mod diff;
mod diffselftest;
mod doclig;
mod docxdedupe;
mod docxextract;
mod docxopen;
mod docxpages;
mod docxpass;
mod docxref;
mod docxxengine;
mod docxzip;
mod enginegen;
mod engines;
mod eval;
mod fetch;
mod filing;
mod fontorder;
mod fonts;
mod layout;
mod lint;
mod lofonts;
mod manifest;
mod matchstamp;
mod measure;
mod overlay;
mod pdfrepro;
mod pin;
mod proc;
mod readmes;
mod render;
mod selftest;
mod sharedlib;
mod showcase;
mod t1ids;
mod texlive;
mod track;
mod tracker;
mod typstface;
mod unicode;
mod worklist;
mod xmlfmt;

use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let (cmd, rest) = args
        .split_first()
        .map_or(("", &[][..]), |(c, r)| (c.as_str(), r));
    let result = match cmd {
        "check" => check::main(rest),
        "check-changed" => checkchanged::main(rest),
        "toc-layout" => check::toclayout::main(rest),
        "text-overlap" => check::overlap::main(rest),
        "cover-pages" => check::coverpages::main(rest),
        "eval" => eval::main(rest),
        "engines" => enginegen::main(rest),
        "manifest" => manifest::main(rest),
        "tracker" => track::main(rest),
        "readmes" => readmes::main(rest),
        "render" => render::main(rest),
        "render-latex" => render::latex_main(rest),
        "docx-reference" => docxref::main(rest),
        "diff" => diff::main(rest),
        "calibrate" => diff::calibrate::main(rest),
        "cross-engine" => diff::xbaseline::main(rest),
        "measure" => measure::main(rest),
        "diff-selftest" => diffselftest::main(rest),
        "fetch" => fetch::main(rest),
        "fonts" => fonts::main(rest),
        "lint" => lint::main(rest),
        "match-stamp" => matchstamp::main(rest),
        "usage" => layout::main(rest),
        "overlay" => overlay::main(rest),
        "bootstrap" => bootstrap::main(rest),
        "showcase" => showcase::main(rest),
        "worklist" => worklist::main(rest),
        "claim" => claim::main(rest),
        "contribute" => contribute::main(rest),
        "check-selftest" => selftest::main(rest),
        "selftest" => selftest::main(rest),
        "find" => filing::find(rest),
        "new" => filing::new(rest),
        "build" => filing::build(rest),
        "new-filing" => filing::new_filing(rest),
        "render-filing" => filing::render_filing(rest),
        _ => Err(fail(2, "usage: fb check|check-changed|eval|selftest|check-selftest|bootstrap|showcase|render|render-latex|docx-reference|build|new|render-filing|overlay|fonts|manifest|tracker|worklist|claim|contribute|find|new-filing|readmes|measure|diff|calibrate|cross-engine|fetch|lint|match-stamp|diff-selftest|usage|toc-layout|text-overlap|cover-pages ...")),
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
