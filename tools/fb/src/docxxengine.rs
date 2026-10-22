//! The style recipe of the cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"; was
//! lib/docx/xengine-reference.sh), the base of a `docx/reference.xml` that says `base="xengine"` (docxref.rs).
//!
//! From pandoc's default reference document: one font (the typst template's, typstface.rs) and size everywhere;
//! widow control on and no paragraph spacing by default; exact line spacing: Body Text and List Item at the body
//! pitch, Block Text and Footnote Text at the single pitch, headings at their own; Body Text with a first-line
//! indent, List Item hanging, Block Text indented both sides; footnotes kept whole with a space after each; headings
//! black and bold, level 1 centered capitals, levels 4 and 5 italic; links black; letter paper, 1 in margins and a
//! centered page-number footer (`rIdFooter1`). The styles part is then written as `xmllint --format` writes it
//! (xmlfmt.rs), so a template built by the shell recipe renders byte-identical.
//!
//! Attributes of `<reference>` (twips, sizes in half points): `size`, `body`, `single` (required); `indent` (720),
//! `list` (indent), `heading` (single), `heading-before` (240), `heading-after` (120), `quote` (280), `note-after`
//! (140), `note` (single), `note-size` (size), `footer` (432).

/// The recipe's parameters.
#[derive(Debug, Clone, PartialEq)]
pub struct Recipe {
    pub font: String,
    pub size: String,
    pub body: String,
    pub single: String,
    pub indent: String,
    pub list: String,
    pub heading: String,
    pub heading_before: String,
    pub heading_after: String,
    pub quote: String,
    pub note_after: String,
    pub note: String,
    pub note_size: String,
    pub footer: String,
}

/// The parameters from the `<reference>` start tag (`attr` reads one attribute); `font` is the typst face.
pub fn recipe(attr: impl Fn(&str) -> Option<String>, font: &str) -> Result<Recipe, String> {
    let need = |k: &str| attr(k).ok_or_else(|| format!("base=\"xengine\" needs {k}=\"..\""));
    let or = |k: &str, d: &str| attr(k).unwrap_or_else(|| d.to_string());
    let (size, single, indent) = (need("size")?, need("single")?, or("indent", "720"));
    Ok(Recipe {
        font: font.to_string(),
        body: need("body")?,
        list: or("list", &indent),
        heading: or("heading", &single),
        heading_before: or("heading-before", "240"),
        heading_after: or("heading-after", "120"),
        quote: or("quote", "280"),
        note_after: or("note-after", "140"),
        note: or("note", &single),
        note_size: or("note-size", &size),
        footer: or("footer", "432"),
        size,
        single,
        indent,
    })
}

/// The start of the `<w:style ..>` tag naming `id`.
fn style_at(s: &str, id: &str) -> Result<usize, String> {
    let key = format!("w:styleId=\"{id}\"");
    let mut from = 0;
    while let Some(i) = s[from..].find("<w:style ").map(|i| i + from) {
        let end = s[i..].find('>').map_or(s.len(), |j| i + j);
        if s[i..end].contains(&key) {
            return Ok(i);
        }
        from = i + 1;
    }
    Err(format!("xengine: pandoc's styles have no {id}"))
}

/// The first `needle` at or after `from`.
fn after(s: &str, from: usize, needle: &str, what: &str) -> Result<usize, String> {
    s[from..]
        .find(needle)
        .map(|i| i + from)
        .ok_or_else(|| format!("xengine: {what}: no {needle}"))
}

/// The first `<w:pPr>..</w:pPr>` of style `id` replaced by `ppr`.
fn set_ppr(s: &mut String, id: &str, ppr: &str) -> Result<(), String> {
    let a = after(s, style_at(s, id)?, "<w:pPr>", id)?;
    let b = after(s, a, "</w:pPr>", id)? + "</w:pPr>".len();
    s.replace_range(a..b, ppr);
    Ok(())
}

fn skip_ws(s: &str, i: usize) -> usize {
    i + s[i..].len() - s[i..].trim_start().len()
}

fn exact(before: &str, after: &str, line: &str) -> String {
    format!(
        r#"<w:spacing w:before="{before}" w:after="{after}" w:line="{line}" w:lineRule="exact"/>"#
    )
}

/// The styles part of pandoc's reference with the recipe applied (before formatting).
fn edit(styles: &str, r: &Recipe) -> Result<String, String> {
    let mut s = styles.to_string();
    let f = &r.font;
    let fonts = format!(r#"<w:rFonts w:ascii="{f}" w:hAnsi="{f}" w:eastAsia="{f}" w:cs="{f}"/>"#);
    let size = format!(r#"<w:sz w:val="{0}"/><w:szCs w:val="{0}"/>"#, r.size);
    // docDefaults: the theme fonts and 12 pt become the face and size
    let a = after(
        &s,
        0,
        r#"<w:rFonts w:asciiTheme="minorHAnsi""#,
        "docDefaults",
    )?;
    let mut b = after(&s, a, ">", "docDefaults")? + 1;
    if !s[..b].ends_with("/>") {
        return Err("xengine: docDefaults: rFonts is not an empty element".into());
    }
    for tag in [r#"<w:sz w:val="24" />"#, r#"<w:szCs w:val="24" />"#] {
        b = skip_ws(&s, b);
        if !s[b..].starts_with(tag) {
            return Err(format!("xengine: docDefaults: no {tag}"));
        }
        b += tag.len();
    }
    s.replace_range(a..b, &format!("{fonts}{size}"));
    let sp = r#"<w:spacing w:after="200" />"#;
    let at = after(&s, 0, sp, "pPrDefault")?;
    s.replace_range(
        at..at + sp.len(),
        r#"<w:widowControl/><w:spacing w:after="0"/>"#,
    );
    set_ppr(
        &mut s,
        "BodyText",
        &format!(
            r#"<w:pPr>{}<w:ind w:firstLine="{}"/></w:pPr>"#,
            exact("0", "0", &r.body),
            r.indent
        ),
    )?;
    for n in 1..=5 {
        let id = format!("Heading{n}");
        let jc = if n == 1 {
            r#"<w:jc w:val="center"/>"#
        } else {
            ""
        };
        let caps = if n == 1 { "<w:caps/>" } else { "" };
        let ital = if n >= 4 { "<w:i/>" } else { "" };
        let ppr = format!(
            r#"<w:pPr><w:keepNext/><w:keepLines/>{}<w:ind w:firstLine="0"/>{jc}<w:outlineLvl w:val="{}"/></w:pPr>"#,
            exact(&r.heading_before, &r.heading_after, &r.heading),
            n - 1
        );
        let rpr = format!(
            r#"<w:rPr>{fonts}<w:b/><w:bCs/>{caps}{ital}<w:color w:val="000000"/>{size}</w:rPr>"#
        );
        let a = after(&s, style_at(&s, &id)?, "<w:pPr>", &id)?;
        let e = skip_ws(&s, after(&s, a, "</w:pPr>", &id)? + "</w:pPr>".len());
        if !s[e..].starts_with("<w:rPr>") {
            return Err(format!("xengine: {id}: no rPr after its pPr"));
        }
        let b = after(&s, e, "</w:rPr>", &id)? + "</w:rPr>".len();
        s.replace_range(a..b, &format!("{ppr}{rpr}"));
    }
    let list = format!(
        r#"<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>{}<w:ind w:left="{1}" w:hanging="{1}"/></w:pPr></w:style>"#,
        exact("0", "0", &r.body),
        r.list
    );
    let at = style_at(&s, "BlockText")?;
    s.insert_str(at, &list);
    let ind = format!(
        r#"<w:ind w:firstLine="0" w:left="{0}" w:right="{0}"/>"#,
        r.indent
    );
    set_ppr(
        &mut s,
        "BlockText",
        &format!(
            "<w:pPr>{}{ind}</w:pPr>",
            exact(&r.quote, &r.quote, &r.single)
        ),
    )?;
    let q = "<w:qFormat />";
    let at = after(&s, style_at(&s, "FootnoteText")?, q, "FootnoteText")? + q.len();
    s.insert_str(
        at,
        &format!(
            r#"<w:pPr><w:keepLines/>{}</w:pPr><w:rPr><w:sz w:val="{1}"/><w:szCs w:val="{1}"/></w:rPr>"#,
            exact("0", &r.note_after, &r.note),
            r.note_size
        ),
    );
    set_ppr(
        &mut s,
        "FootnoteBlockText",
        &format!(
            r#"<w:pPr><w:spacing w:before="{0}" w:after="{0}"/>{ind}</w:pPr>"#,
            r.quote
        ),
    )?;
    let blue = r#"<w:color w:val="4F81BD" w:themeColor="accent1" />"#;
    let at = after(&s, style_at(&s, "Hyperlink")?, blue, "Hyperlink")?;
    s.replace_range(at..at + blue.len(), r#"<w:color w:val="000000"/>"#);
    Ok(s)
}

/// The recipe's styles part, formatted as `xmllint --format` writes it.
pub fn styles(pandoc_styles: &str, r: &Recipe) -> Result<String, String> {
    crate::xmlfmt::format(&edit(pandoc_styles, r)?)
}

/// The recipe's document part: the section names the footer and sets the page.
pub fn document(doc: &str, r: &Recipe) -> Result<String, String> {
    let a = after(doc, 0, "<w:sectPr>", "sectPr")?;
    let mut b = a + "<w:sectPr>".len();
    for tag in [
        "<w:footnotePr>",
        r#"<w:numRestart w:val="eachSect" />"#,
        "</w:footnotePr>",
    ] {
        b = skip_ws(doc, b);
        if !doc[b..].starts_with(tag) {
            return Err(format!("xengine: sectPr: no {tag}"));
        }
        b += tag.len();
    }
    let sect = format!(
        "<w:sectPr><w:footerReference w:type=\"default\" r:id=\"rIdFooter1\" />\n      <w:pgSz w:w=\"12240\" w:h=\"15840\" /><w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"{}\" w:gutter=\"0\" />",
        r.footer
    );
    Ok(format!("{}{sect}{}", &doc[..a], &doc[b..]))
}

/// The recipe's footer (relationship id `rIdFooter1`): a centered PAGE field.
pub const FOOTER: &str = r#"<w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p>"#;

/// The footer parts of a reference: `own` (the spec's), after the recipe's centered page number (`rIdFooter1`) when
/// there is a recipe (an xengine base), unless `own` writes a footer under that id.
pub fn footers(own: &[(String, String)], recipe: Option<&Recipe>) -> Vec<(String, String)> {
    let mut footers = own.to_vec();
    if recipe.is_some() && !footers.iter().any(|(id, _)| id == "rIdFooter1") {
        footers.insert(0, ("rIdFooter1".into(), FOOTER.into()));
    }
    footers
}

#[cfg(test)]
mod tests {
    use super::*;

    fn r() -> Recipe {
        let a = |k: &str| match k {
            "size" => Some("28".to_string()),
            "body" => Some("588".to_string()),
            "single" => Some("340".to_string()),
            _ => None,
        };
        recipe(a, "Times New Roman").unwrap()
    }

    #[test]
    fn defaults_follow_the_script() {
        let r = r();
        assert_eq!(
            (
                r.indent.as_str(),
                r.list.as_str(),
                r.heading.as_str(),
                r.note.as_str(),
                r.note_size.as_str(),
                r.footer.as_str()
            ),
            ("720", "720", "340", "340", "28", "432")
        );
        assert!(recipe(|_| None, "X").is_err());
    }

    #[test]
    fn the_section_names_the_footer() {
        let doc = "<w:body><w:p/><w:sectPr>\n  <w:footnotePr>\n <w:numRestart w:val=\"eachSect\" />\n </w:footnotePr>\n</w:sectPr></w:body>";
        let got = document(doc, &r()).unwrap();
        assert!(got.starts_with("<w:body><w:p/><w:sectPr><w:footerReference w:type=\"default\" r:id=\"rIdFooter1\" />\n      <w:pgSz"));
        assert!(got.ends_with("w:footer=\"432\" w:gutter=\"0\" />\n</w:sectPr></w:body>"));
    }

    #[test]
    fn style_at_matches_the_whole_id() {
        let s =
            "<w:style w:styleId=\"BodyTextNote\"/><w:style w:type=\"p\" w:styleId=\"BodyText\"/>";
        assert_eq!(style_at(s, "BodyText").ok(), s.find("<w:style w:type"));
        assert!(style_at(s, "Missing").is_err());
    }
}
