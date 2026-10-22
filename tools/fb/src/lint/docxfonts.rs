//! `fb lint fonts`, the docx rule (fb-595.68): a doc folder's docx names the face its typst template sets
//! (typstface.rs), one source for both. The faces of a docx are the `w:ascii` fonts of its styles (and the theme's
//! minor latin face where the document defaults name a theme font), read from `docx/reference.xml` (`{font}` and
//! `base="xengine"` take the typst face by construction) or from a committed `docx/reference.docx`. Code faces are
//! not body faces and are left out. Report-only without `--docx-strict`, which `just lint` passes (fb-595.68.39): it
//! fails on a difference, and on a reference.docx it cannot read.
use crate::docxref::{attr, elements, FONT};
use std::collections::BTreeSet;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Faces pandoc's reference (and Word) use for code or symbols, not for the body.
const NOT_BODY: [&str; 4] = ["Consolas", "Courier New", "Symbol", "Wingdings"];

/// One docx folder whose faces differ from its typst face.
#[derive(Debug, PartialEq)]
pub struct Finding {
    pub docx: PathBuf,
    pub faces: Vec<String>,
    pub typst: Option<String>,
}

/// The `w:ascii` faces of a styles part (and `minor`, the theme's minor latin face, when the document defaults name
/// a theme font instead).
pub fn style_faces(styles: &str, minor: Option<&str>) -> BTreeSet<String> {
    let mut out: BTreeSet<String> = elements(styles, "w:rFonts")
        .iter()
        .filter_map(|r| attr(r, "w:ascii"))
        .filter(|f| !NOT_BODY.contains(&f.as_str()))
        .collect();
    let defaults = elements(styles, "w:docDefaults");
    let themed = defaults.first().is_some_and(|d| {
        elements(d, "w:rFonts")
            .first()
            .is_some_and(|r| attr(r, "w:ascii").is_none() && attr(r, "w:asciiTheme").is_some())
    });
    if let (true, Some(m)) = (themed, minor) {
        out.insert(m.to_string());
    }
    out
}

/// The faces a `reference.xml` names, `{font}` standing for `typst`.
pub fn spec_faces(spec: &str, typst: Option<&str>) -> BTreeSet<String> {
    let mut out = style_faces(spec, None);
    let root = spec
        .find("<reference")
        .map_or("", |i| &spec[i..i + spec[i..].find('>').unwrap_or(0)]);
    if let Some(t) = attr(root, "theme-font") {
        out.insert(t);
    }
    if attr(root, "base").as_deref() == Some("xengine") {
        out.insert(FONT.to_string());
    }
    if out.remove(FONT) {
        if let Some(t) = typst {
            out.insert(t.to_string());
        }
    }
    out
}

fn unzip_part(docx: &Path, part: &str) -> Option<String> {
    let o = Command::new("unzip")
        .arg("-p")
        .arg(docx)
        .arg(part)
        .output()
        .ok()?;
    o.status
        .success()
        .then(|| String::from_utf8_lossy(&o.stdout).into_owned())
}

/// The faces of a docx folder, if it has a reference (reference.xml or reference.docx).
fn docx_faces(d: &Path, typst: Option<&str>) -> Option<BTreeSet<String>> {
    if let Ok(spec) = std::fs::read_to_string(d.join("reference.xml")) {
        return Some(spec_faces(&spec, typst));
    }
    let docx = d.join("reference.docx");
    if !docx.is_file() {
        return None;
    }
    // an unreadable reference (no unzip on PATH, a broken archive) is a finding, not a folder skipped
    let Some(styles) = unzip_part(&docx, "word/styles.xml") else {
        return Some(BTreeSet::from([
            "unreadable reference.docx (unzip on PATH?)".to_string(),
        ]));
    };
    let theme = unzip_part(&docx, "word/theme/theme1.xml").unwrap_or_default();
    let minor = theme
        .find("<a:minorFont>")
        .and_then(|g| attr(&theme[g..], "typeface"));
    Some(style_faces(&styles, minor.as_deref()))
}

fn docx_dirs(dir: &Path, out: &mut Vec<PathBuf>) {
    for e in std::fs::read_dir(dir).into_iter().flatten().flatten() {
        let p = e.path();
        if !p.is_dir() {
            continue;
        }
        if p.file_name().is_some_and(|n| n == "docx") {
            out.push(p);
        } else if p.file_name().is_none_or(|n| n != "usage") {
            docx_dirs(&p, out);
        }
    }
}

/// Every docx folder under `root/courts` with a reference, and those whose faces differ from the typst face.
pub fn check(root: &Path) -> (usize, Vec<Finding>) {
    let mut dirs = vec![];
    docx_dirs(&root.join("courts"), &mut dirs);
    dirs.sort();
    let mut seen = 0;
    let mut findings = vec![];
    for d in dirs {
        let typst = d.parent().and_then(crate::typstface::face);
        let Some(faces) = docx_faces(&d, typst.as_deref()) else {
            continue;
        };
        seen += 1;
        let same = typst
            .as_deref()
            .is_some_and(|t| faces.iter().all(|f| f == t));
        if !same {
            findings.push(Finding {
                docx: d.strip_prefix(root).unwrap_or(&d).to_path_buf(),
                faces: faces.into_iter().collect(),
                typst,
            });
        }
    }
    (seen, findings)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn faces_of_styles_and_specs() {
        let styles = r#"<w:docDefaults><w:rPr><w:rFonts w:asciiTheme="minorHAnsi"/></w:rPr></w:docDefaults><w:style><w:rFonts w:ascii="EB Garamond"/></w:style><w:style><w:rFonts w:ascii="Consolas"/></w:style>"#;
        let got: Vec<_> = style_faces(styles, Some("Cambria")).into_iter().collect();
        assert_eq!(got, ["Cambria", "EB Garamond"]);
        let spec = r#"<reference base="xengine" theme-font="{font}"><w:style><w:rFonts w:ascii="{font}"/></w:style></reference>"#;
        let got: Vec<_> = spec_faces(spec, Some("Times New Roman"))
            .into_iter()
            .collect();
        assert_eq!(got, ["Times New Roman"]);
        let spec =
            r#"<reference><w:style><w:rFonts w:ascii="Liberation Serif"/></w:style></reference>"#;
        let got: Vec<_> = spec_faces(spec, Some("Times New Roman"))
            .into_iter()
            .collect();
        assert_eq!(got, ["Liberation Serif"]);
    }
}
