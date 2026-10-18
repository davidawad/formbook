//! What is taken out of a page before comparison: things the filing system or the clerk added, and
//! pictures. Built in: the CM/ECF header or footer banner ("Case: 26-1136, 04/09/2026, DktEntry: 23.1,
//! Page 2 of 54"), clerk stamps ("FILED ... CLERK" blocks in the top right), and text lying on a raster
//! image (a signature or seal with a text layer). Anything else goes in `usage/MASKS.json`:
//! `{"FILED-EXAMPLE-<id>.pdf": [{"page": 1, "bbox": [x0, y0, x1, y1], "why": "clerk stamp"}]}` (`page`
//! omitted = every page). Those regions are removed from the render too (see diff).
use super::{Line, Masked, Rect};
use crate::{fail, Res};
use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct MaskRegion {
    #[serde(default)]
    pub page: Option<usize>,
    pub bbox: [f64; 4],
    #[serde(default)]
    pub why: String,
}

impl MaskRegion {
    pub fn rect(&self) -> Rect {
        Rect {
            x0: self.bbox[0],
            y0: self.bbox[1],
            x1: self.bbox[2],
            y1: self.bbox[3],
        }
    }
    pub fn on(&self, n: usize) -> bool {
        self.page.is_none_or(|p| p == n)
    }
}

/// The mask regions for `pdf` from `MASKS.json` in its folder (none if there is no such file or entry).
pub fn regions_for(pdf: &Path) -> Res<Vec<MaskRegion>> {
    let file = pdf.with_file_name("MASKS.json");
    let Ok(text) = std::fs::read_to_string(&file) else {
        return Ok(vec![]);
    };
    let all: std::collections::BTreeMap<String, Vec<MaskRegion>> =
        serde_json::from_str(&text).map_err(|e| fail(2, format!("fb: {}: {e}", file.display())))?;
    let name = pdf
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_default();
    Ok(all.get(&name).cloned().unwrap_or_default())
}

/// A docket banner: in the top or bottom band, naming a case and a page, docket entry, document or date.
pub fn is_banner(l: &Line, h: f64) -> bool {
    let band = l.bottom <= 60.0 || l.top >= h - 50.0;
    let t = l.text.to_lowercase();
    let has = |keys: &[&str]| keys.iter().any(|k| t.contains(k));
    let case = has(&["case", "appeal:"]);
    let docket = has(&["dktentry", "document", "doc:", "doc ", "filed", "pg:"]);
    // Bankruptcy and district banners wrap or drop the word "case": "Main Document Page 1 of 8",
    // "2:20-cv-01234 Document 12 Filed 01/01/20", "PageID 100". State e-filing legends (NYSCEF) too.
    let document = t.contains("document") && (t.contains("filed") || page_of(&t));
    let legend = has(&[
        "nyscef",
        "county clerk",
        "documents bearing this legend",
        "filed electronically pursuant to new york",
    ]);
    band && ((case && docket) || document || t.starts_with("pageid") || legend)
}

/// "page 2 of 54", "page: 2 of 54", "pg: 1 of 30".
fn page_of(t: &str) -> bool {
    let w: Vec<&str> = t
        .split_whitespace()
        .map(|w| w.trim_matches(|c: char| !c.is_alphanumeric()))
        .collect();
    let num = |s: &str| !s.is_empty() && s.chars().all(|c| c.is_ascii_digit());
    w.windows(4)
        .any(|x| matches!(x[0], "page" | "pg") && num(x[1]) && x[2] == "of" && num(x[3]))
}

const STAMP_WORDS: [&str; 5] = ["FILED", "RECEIVED", "ENTERED", "LODGED", "DOCKETED"];

fn is_stamp_key(l: &Line, w: f64, h: f64) -> bool {
    let t = l.text.trim();
    let keyword =
        STAMP_WORDS.contains(&t) || t.contains(", CLERK") || t.ends_with("CLERK OF COURT");
    keyword && l.left >= w * 0.5 && l.bottom <= h * 0.2
}

/// Split `lines` into kept and masked.
pub fn apply(
    lines: Vec<Line>,
    n: usize,
    w: f64,
    h: f64,
    images: &[Rect],
    regions: &[MaskRegion],
) -> (Vec<Line>, Vec<Masked>) {
    let rect = |l: &Line| Rect {
        x0: l.left,
        y0: l.top,
        x1: l.right,
        y1: l.bottom,
    };
    // Clerk stamps: a keyword line in the top right, plus the lines stacked on it.
    let mut stamp: Option<Rect> = None;
    for l in lines.iter().filter(|l| is_stamp_key(l, w, h)) {
        stamp = Some(stamp.map_or(rect(l), |s| s.union(&rect(l))));
    }
    if let Some(mut s) = stamp {
        loop {
            let grown = lines
                .iter()
                .filter(|l| l.left >= w * 0.5 && l.bottom <= h * 0.25)
                .map(rect)
                .filter(|r| {
                    let near = Rect {
                        x0: s.x0 - 12.0,
                        y0: s.y0 - 18.0,
                        x1: s.x1 + 12.0,
                        y1: s.y1 + 18.0,
                    };
                    near.intersects(r)
                })
                .fold(s, |a, r| a.union(&r));
            if grown == s {
                break;
            }
            s = grown;
        }
        stamp = Some(s);
    }
    // Images covering most of the page are scans with a text layer, not signatures: keep their text.
    let small: Vec<&Rect> = images
        .iter()
        .filter(|r| r.w() * r.h() < 0.5 * w * h)
        .collect();
    let mut kept = Vec::new();
    let mut masked = Vec::new();
    for l in lines {
        let r = rect(&l);
        let (cx, cy) = ((r.x0 + r.x1) / 2.0, (r.y0 + r.y1) / 2.0);
        let kind = if is_banner(&l, h) {
            Some("cmecf-banner".to_string())
        } else if stamp.is_some_and(|s| s.contains_pt(cx, cy)) {
            Some("clerk-stamp".to_string())
        } else if let Some(m) = regions
            .iter()
            .find(|m| m.on(n) && m.rect().contains_pt(cx, cy))
        {
            Some(format!("region: {}", m.why))
        } else if small.iter().any(|i| i.contains_pt(cx, cy)) {
            Some("on-image".to_string())
        } else {
            None
        };
        match kind {
            Some(kind) => masked.push(Masked {
                kind,
                bbox: r,
                text: l.text,
            }),
            None => kept.push(l),
        }
    }
    (kept, masked)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn l(text: &str, x0: f64, y0: f64, x1: f64, y1: f64) -> Line {
        Line {
            text: text.into(),
            baseline: y1,
            baseline_est: false,
            left: x0,
            right: x1,
            top: y0,
            bottom: y1,
            size: 12.0,
            font: String::new(),
            bold: false,
            italic: false,
            words: vec![],
        }
    }

    #[test]
    fn banners_of_several_courts() {
        for t in [
            "Case: 26-1136, 04/09/2026, DktEntry: 23.1, Page 2 of 54",
            "USCA Case #21-5001 Document #1883 Filed: 02/01/2021 Page 1 of 30",
            "USCA4 Appeal: 21-1234 Doc: 12 Filed: 03/03/2021 Pg: 1 of 30",
            "Case 1:20-cv-01234-ABC Document 12 Filed 01/01/20 Page 1 of 20 PageID #: 100",
        ] {
            assert!(is_banner(&l(t, 100.0, 5.0, 500.0, 18.0), 792.0), "{t}");
        }
        for t in [
            "Main Document Page 1 of 8",
            "Description: Main Document , Page 3 of 9",
            "2:20-cv-01234-kjd Document 12 Filed 01/01/20 Page 1 of 20",
            "PageID 1234",
            "NYSCEF DOC. NO. 12 RECEIVED NYSCEF: 01/02/2023",
        ] {
            assert!(is_banner(&l(t, 100.0, 750.0, 500.0, 762.0), 792.0), "{t}");
        }
        assert!(!is_banner(
            &l(
                "Case No. 26-1136, filed in this court",
                72.0,
                300.0,
                500.0,
                314.0
            ),
            792.0
        ));
        // A filer's own running footer is part of the filing.
        assert!(!is_banner(
            &l(
                "Case No. 3:20-cv-01234 Opening Brief Page 5",
                72.0,
                750.0,
                500.0,
                762.0
            ),
            792.0
        ));
        assert!(!is_banner(
            &l("UNCLASSIFIED//FOR PUBLIC RELEASE", 200.0, 20.0, 400.0, 32.0),
            792.0
        ));
    }

    #[test]
    fn stamp_block_and_region_and_image() {
        let lines = vec![
            l("FILED", 450.0, 40.0, 490.0, 52.0),
            l("APR 09 2026", 440.0, 54.0, 500.0, 66.0),
            l("MOLLY C. DWYER, CLERK", 420.0, 68.0, 540.0, 80.0),
            l("No. 26-1136", 270.0, 100.0, 340.0, 114.0),
            l("/s/ Jane Roe", 80.0, 600.0, 160.0, 614.0),
            l("masked here", 80.0, 700.0, 160.0, 714.0),
        ];
        let regions = vec![MaskRegion {
            page: Some(1),
            bbox: [70.0, 690.0, 200.0, 720.0],
            why: "stamp".into(),
        }];
        let img = vec![Rect {
            x0: 70.0,
            y0: 590.0,
            x1: 200.0,
            y1: 620.0,
        }];
        let (kept, masked) = apply(lines, 1, 612.0, 792.0, &img, &regions);
        assert_eq!(kept.len(), 1);
        assert_eq!(kept[0].text, "No. 26-1136");
        let kinds: Vec<&str> = masked.iter().map(|m| m.kind.as_str()).collect();
        assert_eq!(
            kinds,
            [
                "clerk-stamp",
                "clerk-stamp",
                "clerk-stamp",
                "on-image",
                "region: stamp"
            ]
        );
    }
}
