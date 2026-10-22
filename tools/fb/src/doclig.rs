//! Word's "no ligatures" for the LibreOffice conversion (fb-595.54.5; docs/EVAL-LOOP.md, "Cross-engine gate").
//!
//! Word sets no ligatures unless a run asks for them (`w14:ligatures`); LibreOffice forms a font's standard
//! ligatures (fi, fl, ff ...) whatever the document says, since it does not read `w14:ligatures`. For a font that has
//! them (TeX Gyre Schola, EB Garamond, Gelasio) the .docx.pdf then sets "firearm" 0.5 pt narrower than Word, typst and
//! LaTeX do, and lines break elsewhere. A document whose default run properties say so, `<w14:ligatures
//! w14:val="none"/>` in `w:docDefaults` (styles.xml), is converted from a copy whose font names carry LibreOffice's
//! font-feature suffix `:-liga` ("TeX Gyre Schola:-liga": the same font, standard ligatures off). The delivered .docx
//! is not changed; the PDF names the fonts as before. Any other document is converted as it is.
use crate::{fail, Res};
use std::path::{Path, PathBuf};

const MARK: &str = "<w14:ligatures w14:val=\"none\"";

/// True when the docDefaults of `styles` turn ligatures off.
fn wants_no_ligatures(styles: &str) -> bool {
    match (
        styles.find("<w:docDefaults"),
        styles.find("</w:docDefaults>"),
    ) {
        (Some(a), Some(b)) if a < b => styles[a..b].contains(MARK),
        _ => false,
    }
}

/// `xml` with every font name of a `w:rFonts` element (w:ascii, w:hAnsi, w:eastAsia, w:cs) suffixed `:-liga`.
fn suffix_fonts(xml: &str) -> String {
    let mut out = String::with_capacity(xml.len() + 64);
    let mut rest = xml;
    while let Some(i) = rest.find("<w:rFonts ") {
        out.push_str(&rest[..i]);
        let tail = &rest[i..];
        let end = tail.find('>').map_or(tail.len(), |e| e + 1);
        let mut el = tail[..end].to_string();
        for attr in ["w:ascii=\"", "w:hAnsi=\"", "w:eastAsia=\"", "w:cs=\""] {
            if let Some(s) = el.find(attr) {
                let v = s + attr.len();
                if let Some(q) = el[v..].find('"') {
                    if !el[v..v + q].contains(':') {
                        el.insert_str(v + q, ":-liga");
                    }
                }
            }
        }
        out.push_str(&el);
        rest = &tail[end..];
    }
    out.push_str(rest);
    out
}

/// The document LibreOffice is to convert: `docx` itself, or (when its defaults turn ligatures off) a copy under
/// `work` with the same file name whose font names say so.
pub fn for_libreoffice(docx: &Path, work: &Path) -> Res<PathBuf> {
    let dir = work.join("noliga-unz");
    crate::docxzip::unpack(docx, &dir)?;
    let styles = std::fs::read_to_string(dir.join("word/styles.xml")).unwrap_or_default();
    if !wants_no_ligatures(&styles) {
        let _ = std::fs::remove_dir_all(&dir);
        return Ok(docx.to_path_buf());
    }
    for rel in crate::docxzip::files(&dir) {
        let p = dir.join(&rel);
        if p.extension().is_some_and(|e| e == "xml") && rel.starts_with("word") {
            let text = std::fs::read_to_string(&p)
                .map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))?;
            if text.contains("<w:rFonts ") {
                std::fs::write(&p, suffix_fonts(&text))
                    .map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))?;
            }
        }
    }
    let out_dir = work.join("noliga");
    std::fs::create_dir_all(&out_dir)
        .map_err(|e| fail(2, format!("fb render: {}: {e}", out_dir.display())))?;
    let name = docx
        .file_name()
        .ok_or_else(|| fail(2, "fb render: a .docx without a file name"))?;
    let copy = out_dir.join(name);
    crate::docxzip::pack(&dir, &copy)?;
    let _ = std::fs::remove_dir_all(&dir);
    Ok(copy)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn only_the_document_defaults_decide() {
        let on = r#"<w:styles><w:docDefaults><w:rPrDefault><w:rPr><w14:ligatures w14:val="none"/></w:rPr></w:rPrDefault></w:docDefaults></w:styles>"#;
        let style = r#"<w:styles><w:docDefaults/><w:style><w:rPr><w14:ligatures w14:val="none"/></w:rPr></w:style></w:styles>"#;
        assert!(wants_no_ligatures(on));
        assert!(!wants_no_ligatures(style));
        assert!(!wants_no_ligatures("<w:styles/>"));
    }

    #[test]
    fn every_rfonts_name_gets_the_suffix_once() {
        let x = r#"<w:r><w:rPr><w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" w:cs="X:-liga"/></w:rPr><w:t>fi</w:t></w:r><w:rFonts w:asciiTheme="minorHAnsi"/>"#;
        let y = suffix_fonts(x);
        assert!(y.contains(
            r#"w:ascii="TeX Gyre Schola:-liga" w:hAnsi="TeX Gyre Schola:-liga" w:cs="X:-liga""#
        ));
        assert!(y.ends_with(r#"<w:t>fi</w:t></w:r><w:rFonts w:asciiTheme="minorHAnsi"/>"#));
    }
}
