//! Gate 4 CROSS-ENGINE (fb-595.54): the latex or docx render of a sample against the typst render of the
//! same INPUT (diff/xengine.rs). A folder whose `params.cross_engine` is `gate` fails on any difference;
//! every other folder prints the verdict as REPORTED, so a difference is never silently skipped while the
//! fan-out (phase 2) brings the folders to the gate.
use super::native::Verdict;
use super::sh::cfg;
use super::{Ctx, Sample};
use crate::diff::xengine::{self, Cross};
use crate::{measure, Res};
use std::path::Path;

/// Methods of this gate (checks.yaml `method`).
pub fn is_method(m: &str) -> bool {
    m.starts_with("cross_engine_")
}

/// The yq expression for the mode of `engine`: `params.cross_engine_<engine>` (one engine held back, e.g. a docx
/// whose renderer measures lines coarser than the reference) over the folder's `params.cross_engine`.
fn mode_expr(engine: &str) -> String {
    format!(".params.cross_engine_{engine} // .params.cross_engine // \"report\"")
}

/// True when the folder gates the check for this engine; false when it only reports it.
pub fn gated(c: &Ctx) -> Res<bool> {
    Ok(cfg(&c.env, &c.checks, &mode_expr(&c.engine))?.trim() == "gate")
}

/// The numbered lines a page of a folder on pleading paper (`params.pleading_lines`; 0 when it declares none).
pub fn pleading_lines(c: &Ctx) -> Res<usize> {
    Ok(cfg(&c.env, &c.checks, ".params.pleading_lines // 0")?
        .trim()
        .parse()
        .unwrap_or(0))
}

/// The typst render of the sample whose `engine` render is `pdf` (usage/OUTPUT-<id>.<engine>.pdf).
pub fn reference(pdf: &str, engine: &str) -> String {
    let stem = pdf.strip_suffix(&format!(".{engine}.pdf")).unwrap_or(pdf);
    format!("{stem}.typst.pdf")
}

fn verdict(pass: bool, meas: String, detail: &[String]) -> Verdict {
    Verdict {
        pass,
        meas,
        detail: detail.join("\n"),
    }
}

fn judge(x: &Cross, method: &str) -> Option<Verdict> {
    Some(match method {
        "cross_engine_pages" => verdict(
            x.pages_equal(),
            format!("typst {} pages, this engine {}", x.pages.0, x.pages.1),
            &[],
        ),
        "cross_engine_ends" => verdict(
            x.ends_bad == 0,
            format!(
                "{} of {} shared pages start or end on another word",
                x.ends_bad,
                x.pages.0.min(x.pages.1)
            ),
            &x.ends,
        ),
        "cross_engine_breaks" => verdict(
            x.breaks_equal(),
            format!(
                "{}/{} typst lines break after the same word ({:.1}%), first differing {}; largest width drift of an identical line {:.2} pt",
                x.same,
                x.lines,
                x.pct(),
                x.first_text(),
                x.width_drift()
            ),
            &x.first,
        ),
        _ => return None,
    })
}

/// The verdict of a cross-engine method on sample `s`.
pub fn evaluate(c: &Ctx, s: &Sample, method: &str) -> Res<Option<Verdict>> {
    if !is_method(method) {
        return Ok(None);
    }
    let r = reference(&s.pdf, &c.engine);
    if !Path::new(&r).is_file() {
        let base = r.rsplit('/').next().unwrap_or(&r);
        return Ok(Some(verdict(
            false,
            format!("the typst reference {base} is missing; render it first"),
            &[],
        )));
    }
    let n = pleading_lines(c)?;
    let x = xengine::compare(
        &measure::load_pleading(Path::new(&r), n)?,
        &measure::load_pleading(Path::new(&s.pdf), n)?,
    );
    Ok(judge(&x, method))
}

/// The REPORTED block of a folder that does not gate the check: the verdict, not counted as a failure.
pub fn reported_text(id: &str, name: &str, meas: &str, detail: &str) -> String {
    reported_why(
        id,
        name,
        meas,
        detail,
        "params.cross_engine is not `gate` for this folder",
    )
}

/// The REPORTED block with the reason the check is not gated (`why`).
pub fn reported_why(id: &str, name: &str, meas: &str, detail: &str, why: &str) -> String {
    let det: String = detail
        .split('\n')
        .filter(|l| !l.is_empty())
        .map(|l| format!("          - {l}\n"))
        .collect();
    format!(
        "  REPORTED {} {name}\n          measured: {meas}\n          ({why}: reported, not counted; docs/EVAL-LOOP.md)\n{det}",
        super::rows::pad14(id)
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reference_paths() {
        assert_eq!(
            reference("/a/usage/OUTPUT-opening-brief-2.latex.pdf", "latex"),
            "/a/usage/OUTPUT-opening-brief-2.typst.pdf"
        );
        assert_eq!(
            reference("/a/usage/OUTPUT-motion.docx.pdf", "docx"),
            "/a/usage/OUTPUT-motion.typst.pdf"
        );
    }

    #[test]
    fn engine_mode_overrides_the_folder() {
        assert_eq!(
            mode_expr("docx"),
            ".params.cross_engine_docx // .params.cross_engine // \"report\""
        );
    }

    #[test]
    fn verdicts() {
        let x = Cross {
            pages: (3, 4),
            lines: 10,
            same: 9,
            first_at: Some((2, 5)),
            ..Cross::default()
        };
        assert!(!judge(&x, "cross_engine_pages").unwrap().pass);
        assert!(judge(&x, "cross_engine_ends").unwrap().pass);
        let b = judge(&x, "cross_engine_breaks").unwrap();
        assert!(
            !b.pass && b.meas.contains("9/10") && b.meas.contains("p2 line 5"),
            "{}",
            b.meas
        );
        assert!(judge(&x, "other").is_none());
        assert!(
            reported_text("XENG-001", "n", "m", "a\nb").contains("  REPORTED XENG-001       n\n")
        );
    }
}
