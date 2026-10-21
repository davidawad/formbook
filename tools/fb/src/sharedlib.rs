//! The shared libraries of the latex and docx engines (lib/latex, lib/docx, lib/pandoc; fb-595.54.1).
//!
//!   * Lua: every pandoc run of `fb render` sees `<root>/lib/?.lua` first on LUA_PATH, so a court filter loads a
//!     shared module with `require("docx.xengine")` (lib/docx/xengine.lua) or `require("latex.xengine")`.
//!   * LaTeX: a template line `\usepackage{NAME}` whose NAME is a shared package `lib/latex/NAME.sty` is replaced, in
//!     the generated doc.tex, by the package's text between `\makeatletter` and `\makeatother` (its
//!     `\NeedsTeXFormat` and `\ProvidesPackage` lines dropped). The .tex then compiles alone with stock pdflatex, as
//!     the interop rule wants; any other `\usepackage` is left to TeX Live.
use crate::{fail, Res};
use std::path::Path;

/// LUA_PATH with the repo's lib/ first; `prev` is the inherited value (`;;` stands for Lua's default path).
pub fn lua_path(root: &Path, prev: Option<&str>) -> String {
    let first = format!("{}/lib/?.lua;", root.display());
    match prev.filter(|p| !p.is_empty()) {
        Some(p) if p.starts_with(&first) => p.to_string(),
        Some(p) => format!("{first}{p}"),
        None => format!("{first};"),
    }
}

/// `src` with each line that is `\usepackage{NAME}` (a `%` comment may follow), for a file `lib_latex/NAME.sty`,
/// replaced by that file.
pub fn inline_packages(lib_latex: &Path, src: &str) -> Res<String> {
    let mut out = String::with_capacity(src.len());
    for line in src.split_inclusive('\n') {
        let body = line.trim_end_matches(['\n', '\r']);
        let name = body
            .strip_prefix("\\usepackage{")
            .and_then(|r| r.split_once('}'))
            .filter(|(_, rest)| rest.trim().is_empty() || rest.trim_start().starts_with('%'))
            .map(|(n, _)| n)
            .filter(|n| !n.is_empty() && n.chars().all(|c| c.is_ascii_alphanumeric() || c == '-'));
        let sty = name.map(|n| lib_latex.join(format!("{n}.sty")));
        match sty.filter(|p| p.is_file()) {
            Some(p) => {
                let text = std::fs::read_to_string(&p)
                    .map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))?;
                let n = name.unwrap_or_default();
                out.push_str(&format!(
                    "% ---- {n}.sty (lib/latex), inlined by fb render ----\n\\makeatletter\n"
                ));
                for l in text.lines() {
                    if !l.starts_with("\\NeedsTeXFormat") && !l.starts_with("\\ProvidesPackage") {
                        out.push_str(l);
                        out.push('\n');
                    }
                }
                out.push_str(&format!("\\makeatother\n% ---- end of {n}.sty ----\n"));
            }
            None => out.push_str(line),
        }
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proc::TempDir;

    #[test]
    fn lua_path_puts_lib_first() {
        let r = Path::new("/repo");
        assert_eq!(lua_path(r, None), "/repo/lib/?.lua;;");
        assert_eq!(lua_path(r, Some("")), "/repo/lib/?.lua;;");
        assert_eq!(
            lua_path(r, Some("/x/?.lua;;")),
            "/repo/lib/?.lua;/x/?.lua;;"
        );
        assert_eq!(lua_path(r, Some("/repo/lib/?.lua;;")), "/repo/lib/?.lua;;");
    }

    #[test]
    fn inlines_only_shared_packages() {
        let t = TempDir::new("sharedlib-test").unwrap();
        std::fs::write(
            t.path().join("xe.sty"),
            "% c\n\\NeedsTeXFormat{LaTeX2e}\n\\ProvidesPackage{xe}[x]\n\\def\\xe@a{1}\n",
        )
        .unwrap();
        let src = "\\usepackage{geometry}\n\\usepackage{xe} % shared\n  \\usepackage{xe}\n\\usepackage{xe}x\nend\n";
        let got = inline_packages(t.path(), src).unwrap();
        assert_eq!(
            got,
            "\\usepackage{geometry}\n% ---- xe.sty (lib/latex), inlined by fb render ----\n\\makeatletter\n% c\n\
             \\def\\xe@a{1}\n\\makeatother\n% ---- end of xe.sty ----\n  \\usepackage{xe}\n\\usepackage{xe}x\nend\n"
        );
        assert!(!got.contains("ProvidesPackage"));
    }

    #[test]
    fn ignores_names_that_are_not_file_names() {
        let t = TempDir::new("sharedlib-test2").unwrap();
        let src = "\\usepackage{../x}\n\\usepackage{}\n";
        assert_eq!(inline_packages(t.path(), src).unwrap(), src);
    }
}
