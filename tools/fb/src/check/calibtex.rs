//! Font calibration for a latex template set in a stock TeX Live face (fb-595.45, fb-595.49): the word height per
//! point of the face the template really uses, measured the way `prepare::calibrate` measures the typst face
//! (regular, bold and italic "Hxg" at 100 pt, the smallest height wins), but set by pdflatex, since typst cannot
//! load the Type 1 faces and their font descriptors give pdftotext other word heights than the vendored files.
use super::sh::{capture, cmd, io_fail};
use super::Ctx;
use crate::Res;

/// The stock font packages a latex template may load, each with the line the calibration document loads it by:
/// newtx (Times), and the Type 1 EB Garamond and Gelasio of the templates that declare those families.
const FONT_PACKAGES: [(&str, &str); 3] = [
    ("\\usepackage{newtxtext", "\\usepackage{newtxtext,newtxmath}"),
    ("\\usepackage{ebgaramond}", "\\usepackage{ebgaramond}"),
    ("\\usepackage{gelasio}", "\\usepackage{gelasio}"),
];

/// The calibration document: the template's font package only.
fn tex(load: &str) -> String {
    format!(
        "\\documentclass{{article}}\n\\usepackage[T1]{{fontenc}}\n{load}\n\
\\usepackage[paperwidth=1000bp,paperheight=220bp,margin=20bp]{{geometry}}\n\\pagestyle{{empty}}\n\\begin{{document}}\n\
\\noindent\\fontsize{{100bp}}{{120bp}}\\selectfont Hxg \\textbf{{Hxg}} \\emph{{Hxg}}\n\\end{{document}}\n"
    )
}

/// The font-package line of a template source, if it loads one of FONT_PACKAGES.
fn font_package(src: &str) -> Option<&'static str> {
    FONT_PACKAGES
        .iter()
        .find(|(probe, _)| src.contains(probe))
        .map(|(_, load)| *load)
}

/// The font package this run calibrates with: on the latex engine, the stock font package the template loads.
fn package(c: &Ctx) -> Option<&'static str> {
    (c.engine == "latex")
        .then(|| std::fs::read_to_string(format!("{}/{}", c.doc, c.template)).ok())
        .flatten()
        .and_then(|t| font_package(&t))
}

/// Whether this run calibrates with pdflatex.
pub fn applies(c: &Ctx) -> bool {
    package(c).is_some()
}

/// The pdflatex calibration ("" when pdflatex fails, like a failed typst calibration).
pub fn calibrate(c: &Ctx, dir: &str) -> Res<String> {
    let tex_path = format!("{dir}/c.tex");
    std::fs::write(&tex_path, tex(package(c).unwrap_or(FONT_PACKAGES[0].1)))
        .map_err(|e| io_fail(&tex_path, e))?;
    let o = std::process::Command::new(crate::texlive::pdflatex())
        .args(["-interaction=nonstopmode", "-halt-on-error", "c.tex"])
        .current_dir(dir)
        .output()
        .map_err(|e| io_fail("pdflatex", e))?;
    if !o.status.success() {
        eprintln!("calibration failed (pdflatex)");
        return Ok(String::new());
    }
    let (tsv, _) = capture(cmd(
        &c.env,
        "pdftotext",
        &["-tsv", &format!("{dir}/c.pdf"), "-"],
    ))?;
    Ok(super::prepare::calib_of(&tsv))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_template_font_package_picks_the_calibration_face() {
        assert_eq!(
            font_package("\\usepackage{newtxtext,newtxmath}"),
            Some("\\usepackage{newtxtext,newtxmath}")
        );
        assert_eq!(
            font_package("\\usepackage[T1]{fontenc}\n\\usepackage{gelasio}"),
            Some("\\usepackage{gelasio}")
        );
        assert_eq!(font_package("\\usepackage{fontspec}"), None);
        assert!(tex("\\usepackage{ebgaramond}").contains("\\usepackage{ebgaramond}\n"));
    }
}
