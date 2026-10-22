//! `fb docx-reference --extract <docx-dir>`: write `docx/reference.xml` (docxref.rs) from the folder's committed
//! `docx/reference.docx`, so its shell builder and the binary can go (fb-595.68). It keeps what fb render's pandoc
//! passes read from a reference document: the styles part verbatim, the footers and headers, the last section
//! properties, the theme's latin faces, and any other part that differs from pandoc's own reference. The typst
//! template's face becomes `{font}` (typstface.rs). Then it builds the reference document from the new file and
//! compares every one of those parts with the original: `same` or `DIFFERS`, exit 1 on any difference.
use crate::docxref::{attr, elements, inner, read, STYLES_NS};
use crate::{fail, Res};
use std::path::Path;

/// The root element of a part (its XML declaration and the white space around it dropped).
fn root_of(part: &str) -> &str {
    let t = part.trim();
    let t = match t.strip_prefix("<?xml") {
        Some(r) => r.find("?>").map_or(t, |i| &r[i + 2..]),
        None => t,
    };
    t.trim()
}

/// Every `="face"` attribute value written as `="{font}"`.
fn templated(text: &str, face: Option<&str>) -> String {
    match face {
        Some(f) => text.replace(
            &format!("=\"{f}\""),
            &format!("=\"{}\"", crate::docxref::FONT),
        ),
        None => text.to_string(),
    }
}

/// The footer and header relationships of a document.xml.rels: (kind, id, target), in order.
fn header_footer_rels(rels: &str) -> Vec<(String, String, String)> {
    elements(rels, "Relationship")
        .into_iter()
        .filter_map(|r| {
            let ty = attr(r, "Type")?;
            let kind = ["footer", "header"]
                .into_iter()
                .find(|k| ty.ends_with(&format!("/{k}")))?;
            Some((kind.to_string(), attr(r, "Id")?, attr(r, "Target")?))
        })
        .collect()
}

/// The last `<w:sectPr>` of a document part.
fn final_sect(doc: &str) -> Option<&str> {
    let end = doc.rfind("</w:body>")?;
    let start = doc[..end].rfind("<w:sectPr")?;
    let stop = doc[start..end].rfind("</w:sectPr>")? + start + "</w:sectPr>".len();
    Some(&doc[start..stop])
}

/// The minor latin face of a theme part.
fn theme_face(theme: &str) -> Option<String> {
    let g = theme.find("<a:minorFont>")?;
    attr(&theme[g..], "typeface")
}

/// The word/ parts of an unpacked package, relative to it, sorted.
fn word_parts(dir: &Path) -> Vec<String> {
    let mut v: Vec<String> = crate::docxzip::files(dir)
        .into_iter()
        .filter_map(|p| {
            p.strip_prefix(dir)
                .ok()
                .map(|r| r.to_string_lossy().into_owned())
        })
        .filter(|p| p.starts_with("word/") && !p.starts_with("word/_rels/"))
        .collect();
    v.sort();
    v
}

/// reference.xml for the unpacked reference `r` against pandoc's reference `b`.
fn extract(r: &Path, b: &Path, face: Option<&str>) -> Res<String> {
    let mut root = format!("<reference {STYLES_NS}");
    let mut body = vec![];
    let (rt, bt) = (
        read(&r.join("word/theme/theme1.xml"))?,
        read(&b.join("word/theme/theme1.xml"))?,
    );
    let mut theme_part = false;
    if rt != bt {
        match theme_face(&rt) {
            Some(f) if crate::docxref::theme(&bt, &f) == rt => {
                let tf = if Some(f.as_str()) == face {
                    crate::docxref::FONT.to_string()
                } else {
                    f
                };
                root.push_str(&format!(" theme-font=\"{tf}\""));
            }
            _ => theme_part = true,
        }
    }
    root.push('>');
    body.push(templated(root_of(&read(&r.join("word/styles.xml"))?), face));
    let rels = header_footer_rels(&read(&r.join("word/_rels/document.xml.rels"))?);
    let mut own = vec![
        "word/styles.xml".to_string(),
        "word/document.xml".to_string(),
    ];
    for (kind, id, target) in &rels {
        let part = format!("word/{target}");
        let text = read(&r.join(&part))?;
        let el = root_of(&text);
        let tag = &el[..el.find('>').unwrap_or(0)];
        let other_ns = tag
            .split(" xmlns:")
            .skip(1)
            .any(|d| !d.starts_with("w=") && !d.starts_with("r="));
        if !(tag.starts_with("<w:ftr") || tag.starts_with("<w:hdr")) || other_ns {
            return Err(fail(
                1,
                format!(
                    "fb docx-reference: {part}: a root other than <w:ftr {STYLES_NS}> (or w:hdr)"
                ),
            ));
        }
        body.push(format!(
            "<{kind} id=\"{id}\">{}</{kind}>",
            templated(inner(el).trim(), face)
        ));
        own.push(part);
    }
    if !theme_part {
        own.push("word/theme/theme1.xml".into()); // else it is a <part> below
    }
    let base_parts = word_parts(b);
    for part in word_parts(r) {
        if own.contains(&part) {
            continue;
        }
        if !base_parts.contains(&part) {
            return Err(fail(1, format!("fb docx-reference: {part} is not a part of pandoc's reference; reference.xml cannot hold it")));
        }
        let text = read(&r.join(&part))?;
        if text != read(&b.join(&part))? {
            body.push(format!(
                "<part name=\"{part}\">{}</part>",
                templated(root_of(&text), face)
            ));
        }
    }
    let (rd, bd) = (
        read(&r.join("word/document.xml"))?,
        read(&b.join("word/document.xml"))?,
    );
    if let Some(s) = final_sect(&rd).filter(|s| Some(*s) != final_sect(&bd)) {
        body.push(templated(s, face));
    }
    Ok(format!(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!-- Extracted from docx/reference.docx by fb docx-reference --extract (tools/fb/src/docxextract.rs); \
         {{font}} is the typst template's face. -->\n{}\n{}\n</reference>\n",
        root,
        body.join("\n")
    ))
}

/// The parts of the built reference `n` that differ from the original `r`: (part, same).
fn compare(r: &Path, n: &Path) -> Res<Vec<(String, bool)>> {
    let mut out = vec![];
    let cmp = |a: &str, b: &str| root_of(a) == root_of(b);
    for part in ["word/styles.xml", "word/theme/theme1.xml"] {
        out.push((
            part.to_string(),
            cmp(&read(&r.join(part))?, &read(&n.join(part))?),
        ));
    }
    let (rr, nr) = (
        header_footer_rels(&read(&r.join("word/_rels/document.xml.rels"))?),
        header_footer_rels(&read(&n.join("word/_rels/document.xml.rels"))?),
    );
    for (_, id, target) in &rr {
        let built = nr
            .iter()
            .find(|(_, i, _)| i == id)
            .map(|(_, _, t)| n.join("word").join(t));
        let same = match built {
            Some(p) => cmp(&read(&r.join("word").join(target))?, &read(&p)?),
            None => false,
        };
        out.push((format!("word/{target} ({id})"), same));
    }
    for part in word_parts(r) {
        if out
            .iter()
            .any(|(p, _)| p == &part || p.starts_with(&format!("{part} (")))
            || part == "word/document.xml"
        {
            continue;
        }
        let built = n.join(&part);
        let same = built.is_file() && cmp(&read(&r.join(&part))?, &read(&built)?);
        out.push((part, same));
    }
    let (rd, nd) = (
        read(&r.join("word/document.xml"))?,
        read(&n.join("word/document.xml"))?,
    );
    out.push(("final w:sectPr".into(), final_sect(&rd) == final_sect(&nd)));
    Ok(out)
}

/// `fb docx-reference --extract <docx-dir>`.
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    let [dir] = args else {
        return Err(fail(2, "usage: fb docx-reference --extract <docx-dir>"));
    };
    let d = Path::new(dir);
    let original = d.join("reference.docx");
    let spec = d.join("reference.xml");
    if !original.is_file() {
        return Err(fail(
            2,
            format!("fb docx-reference: no {}", original.display()),
        ));
    }
    let face = d.parent().and_then(crate::typstface::face);
    std::env::set_var("SOURCE_DATE_EPOCH", crate::render::REPRO_EPOCH);
    let work = crate::proc::TempDir::new("docx-extract")?;
    let (r, b) = (work.path().join("original"), work.path().join("pandoc"));
    crate::docxzip::unpack(&original, &r)?;
    let bw = work.path().join("pandoc-work");
    std::fs::create_dir_all(&bw).map_err(|e| fail(2, format!("fb docx-reference: {e}")))?;
    crate::docxref::pandoc_reference(&bw, &b)?;
    let text = extract(&r, &b, face.as_deref())?;
    crate::docxref::write(&spec, &text)?;
    let built = crate::docxref::build(&spec, work.path())?;
    let n = work.path().join("built");
    crate::docxzip::unpack(&built, &n)?;
    let mut ok = true;
    for (part, same) in compare(&r, &n)? {
        ok &= same;
        println!("{} {part}", if same { "same   " } else { "DIFFERS" });
    }
    println!(
        "{}: {} (typst face: {})",
        spec.display(),
        if ok {
            "every part the same"
        } else {
            "parts differ"
        },
        face.as_deref().unwrap_or("none")
    );
    Ok(if ok {
        std::process::ExitCode::SUCCESS
    } else {
        std::process::ExitCode::from(1)
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roots_faces_and_relationships() {
        assert_eq!(root_of("<?xml version=\"1.0\"?>\n<a>x</a>\n"), "<a>x</a>");
        assert_eq!(
            templated(
                "<w:rFonts w:ascii=\"Times New Roman\"/>",
                Some("Times New Roman")
            ),
            "<w:rFonts w:ascii=\"{font}\"/>"
        );
        let rels = r#"<Relationships><Relationship Id="rId1" Type="http://x/styles" Target="styles.xml"/><Relationship Type="http://x/footer" Id="rIdF" Target="footer1.xml" /></Relationships>"#;
        assert_eq!(
            header_footer_rels(rels),
            vec![(
                "footer".to_string(),
                "rIdF".to_string(),
                "footer1.xml".to_string()
            )]
        );
        let doc = "<w:body><w:p><w:pPr><w:sectPr><a/></w:sectPr></w:pPr></w:p><w:sectPr><b/></w:sectPr></w:body>";
        assert_eq!(final_sect(doc), Some("<w:sectPr><b/></w:sectPr>"));
        assert_eq!(
            theme_face("<a:majorFont><a:latin typeface=\"A\"/></a:majorFont><a:minorFont><a:latin typeface=\"B\"/>").as_deref(),
            Some("B")
        );
    }
}
