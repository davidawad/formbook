//! Font calibration for a latex template set in newtx (fb-595.45): the word height per point of the face the
//! template really uses, measured the way `prepare::calibrate` measures the typst face (regular, bold and italic
//! "Hxg" at 100 pt, the smallest height wins), but set by pdflatex, since typst cannot load the Type 1 newtx faces.
use super::sh::{capture, cmd, io_fail};
use super::Ctx;
use crate::Res;

/// The calibration document: the template's font packages only.
const TEX: &str = "\\documentclass{article}\n\\usepackage[T1]{fontenc}\n\\usepackage{newtxtext,newtxmath}\n\
\\usepackage[paperwidth=1000bp,paperheight=220bp,margin=20bp]{geometry}\n\\pagestyle{empty}\n\\begin{document}\n\
\\noindent\\fontsize{100bp}{120bp}\\selectfont Hxg \\textbf{Hxg} \\emph{Hxg}\n\\end{document}\n";

/// Whether this run calibrates with pdflatex: the latex engine accepts a metric-compatible Times (FONT_ALT) and the
/// template loads newtxtext.
pub fn applies(c: &Ctx) -> bool {
    let alt = c.env.iter().any(|(k, v)| k == "FONT_ALT" && !v.is_empty());
    alt && c.engine == "latex"
        && std::fs::read_to_string(format!("{}/{}", c.doc, c.template))
            .is_ok_and(|t| t.contains("\\usepackage{newtxtext"))
}

/// The newtx calibration ("" when pdflatex fails, like a failed typst calibration).
pub fn calibrate(c: &Ctx, dir: &str) -> Res<String> {
    let tex = format!("{dir}/c.tex");
    std::fs::write(&tex, TEX).map_err(|e| io_fail(&tex, e))?;
    let o = std::process::Command::new(crate::texlive::pdflatex())
        .args(["-interaction=nonstopmode", "-halt-on-error", "c.tex"])
        .current_dir(dir)
        .output()
        .map_err(|e| io_fail("pdflatex", e))?;
    if !o.status.success() {
        eprintln!("calibration failed (pdflatex, newtx)");
        return Ok(String::new());
    }
    let (tsv, _) = capture(cmd(
        &c.env,
        "pdftotext",
        &["-tsv", &format!("{dir}/c.pdf"), "-"],
    ))?;
    Ok(super::prepare::calib_of(&tsv))
}
