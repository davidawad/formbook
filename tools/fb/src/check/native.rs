//! Native implementations for the checks whose inputs are already materialized by `prepare`.
//!
//! The shell checker remains the compatibility path for methods not migrated here yet. Keeping
//! this dispatch explicit makes it possible to compare each native verdict with the old method.
use super::{sh::io_fail, Ctx, Sample};
use crate::Res;
use std::fs;

#[derive(Debug, PartialEq)]
pub struct Verdict {
    pub pass: bool,
    pub meas: String,
    pub detail: String,
}

fn file(path: &str) -> Res<String> {
    fs::read_to_string(path).map_err(|e| io_fail(path, e))
}

fn metric(w: &str, key: &str) -> Res<String> {
    let path = format!("{w}/g0.metrics");
    Ok(file(&path)?
        .lines()
        .find_map(|line| line.strip_prefix(&format!("{key}=")).map(str::to_owned))
        .unwrap_or_default())
}

fn int_metric(w: &str, key: &str) -> Res<usize> {
    Ok(metric(w, key)?.parse().unwrap_or(0))
}

fn result(pass: bool, meas: impl Into<String>, detail: impl Into<String>) -> Verdict {
    Verdict {
        pass,
        meas: meas.into(),
        detail: detail.into(),
    }
}

/// Return `Some` for methods implemented in Rust, and `None` for the compatibility bridge.
pub fn evaluate(c: &Ctx, s: &Sample, method: &str) -> Res<Option<Verdict>> {
    let verdict = match method {
        "g0_content" => {
            let missing = int_metric(&s.w, "blocks_missing")?;
            let blocks = int_metric(&s.w, "blocks")?;
            result(
                missing == 0,
                format!("{blocks} blocks, {missing} missing or altered"),
                report_lines(&s.w, "FAIL (H|P|Q|L) block")?,
            )
        }
        "g0_italics" => {
            let bad = int_metric(&s.w, "italic_blocks_bad")?;
            result(
                bad == 0,
                format!("{bad} blocks with italic text rendered roman"),
                report_lines(&s.w, "FAIL italic")?,
            )
        }
        "g0_footnotes" => {
            let bad = int_metric(&s.w, "footnotes_bad")?;
            let count = int_metric(&s.w, "footnotes")?;
            result(
                bad == 0,
                format!("{count} footnotes, {bad} missing or misplaced"),
                report_lines(&s.w, "FAIL footnote")?,
            )
        }
        "page_size" => {
            let info = file(&format!("{}/info.txt", s.w))?;
            let mut sizes = std::collections::BTreeMap::<String, usize>::new();
            for line in info
                .lines()
                .filter(|l| l.starts_with("Page ") && l.contains(" size:"))
            {
                let fields: Vec<_> = line.split_whitespace().collect();
                if fields.len() >= 6 {
                    *sizes
                        .entry(format!("{} x {}", fields[3], fields[5]))
                        .or_default() += 1;
                }
            }
            let measured = sizes
                .iter()
                .map(|(size, n)| format!("{size} ({n} pages) "))
                .collect::<String>();
            let width = super::sh::cfg(&c.env, &c.checks, ".params.page_width_pt")?;
            let height = super::sh::cfg(&c.env, &c.checks, ".params.page_height_pt")?;
            result(
                size_matches(&sizes, &width, &height, s.npages.parse().unwrap_or(0)),
                measured,
                "",
            )
        }
        "toc_layout" => {
            let runs = super::toclayout::parse_runs(&file(&format!("{}/runs.tsv", s.w))?);
            let (pages, found) = super::toclayout::analyze(&s.pdf, &runs, c.ftop as f64)?;
            let meas = match pages.len() {
                0 => "no TABLE OF CONTENTS or TABLE OF AUTHORITIES page".to_string(),
                n => format!("{n} table pages, {} layout defects", found.len()),
            };
            result(
                found.is_empty(),
                meas,
                found.iter().take(8).cloned().collect::<Vec<_>>().join("\n"),
            )
        }
        "cover_pages" => {
            let runs = super::toclayout::parse_runs(&file(&format!("{}/runs.tsv", s.w))?);
            let cover = super::sh::cfg(&c.env, &c.checks, ".params.cover_pages // 1")?;
            let (pass, meas, detail) = super::coverpages::judge(
                &super::coverpages::printed(&runs, c.ftop as f64),
                s.npages.parse().unwrap_or(0),
                cover.parse().unwrap_or(1),
            );
            result(pass, meas, detail)
        }
        "text_overlap" => {
            let found = super::overlap::find(&super::overlap::words_of(&s.pdf)?);
            result(
                found.is_empty(),
                format!(
                    "{} pairs of lines closer than solid or printed over each other",
                    found.len()
                ),
                found.iter().take(8).cloned().collect::<Vec<_>>().join("\n"),
            )
        }
        "cover_structure" => {
            let doc = crate::layout::Doc::open(std::path::Path::new(&c.doc))?;
            let (pass, meas, detail) = super::coverstruct::judge(
                Some(doc.filed(&s.sid).as_path()),
                std::path::Path::new(&s.pdf),
            )?;
            result(pass, meas, detail)
        }
        "page_limit" => {
            let limit = super::sh::cfg(&c.env, &c.checks, ".params.page_limit")?;
            let pages: usize = s.npages.parse().unwrap_or(0);
            let limit_num: usize = limit.parse().unwrap_or(0);
            result(
                pages <= limit_num,
                format!("{pages} pages; limit {limit}"),
                "",
            )
        }
        _ => return Ok(None),
    };
    Ok(Some(verdict))
}

/// LibreOffice keeps page sizes in whole 1/100 mm (0.0283 pt), so a 6 1/8 in page (15557.5) comes out
/// 441.014 pt; a size within one such unit of the expected one is that size.
const PAGE_SIZE_TOL_PT: f64 = 72.0 / 2540.0;

/// All `npages` pages have one size, `width` x `height` pt within PAGE_SIZE_TOL_PT.
fn size_matches(
    sizes: &std::collections::BTreeMap<String, usize>,
    width: &str,
    height: &str,
    npages: usize,
) -> bool {
    let near = |a: &str, b: &str| match (a.parse::<f64>(), b.parse::<f64>()) {
        (Ok(a), Ok(b)) => (a - b).abs() <= PAGE_SIZE_TOL_PT,
        _ => false,
    };
    let mut it = sizes.iter();
    match (it.next(), it.next()) {
        (Some((size, n)), None) => {
            *n == npages
                && size
                    .split_once(" x ")
                    .is_some_and(|(w, h)| near(w, width) && near(h, height))
        }
        _ => false,
    }
}

fn report_lines(w: &str, pattern: &str) -> Res<String> {
    let report = file(&format!("{w}/g0.report"))?;
    Ok(report
        .lines()
        .filter(|line| line.starts_with("FAIL ") && simple_match(line, pattern))
        .take(8)
        .collect::<Vec<_>>()
        .join("\n"))
}

// The two report selectors above are deliberately fixed prefixes / simple alternatives. This
// matcher avoids adding a regex dependency just to express those selectors.
fn simple_match(line: &str, pattern: &str) -> bool {
    if pattern == "FAIL (H|P|Q|L) block" {
        return [
            "FAIL H block",
            "FAIL P block",
            "FAIL Q block",
            "FAIL L block",
        ]
        .iter()
        .any(|prefix| line.starts_with(prefix));
    }
    line.starts_with(pattern)
}

#[cfg(test)]
mod tests {
    use super::{simple_match, size_matches};

    #[test]
    fn page_size_allows_libreoffice_rounding_only() {
        let one = |size: &str, n| std::collections::BTreeMap::from([(size.to_string(), n)]);
        assert!(size_matches(&one("441 x 666", 12), "441", "666", 12));
        // LibreOffice: 8820 twips (441 pt) -> 15558/100 mm -> 441.014 pt
        assert!(size_matches(&one("441.014 x 666", 12), "441", "666", 12));
        assert!(!size_matches(&one("441.043 x 666", 12), "441", "666", 12));
        assert!(!size_matches(&one("612 x 792", 12), "441", "666", 12));
        assert!(!size_matches(&one("441 x 666", 11), "441", "666", 12));
        let mut two = one("441 x 666", 11);
        two.insert("612 x 792".into(), 1);
        assert!(!size_matches(&two, "441", "666", 12));
    }

    #[test]
    fn selectors_match_the_shell_check_report_prefixes() {
        assert!(simple_match("FAIL H block 2", "FAIL (H|P|Q|L) block"));
        assert!(simple_match("FAIL L block 3", "FAIL (H|P|Q|L) block"));
        assert!(!simple_match("FAIL F footnote 1", "FAIL (H|P|Q|L) block"));
        assert!(simple_match("FAIL italic 1", "FAIL italic"));
    }
}
