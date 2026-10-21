//! The reference document of `fb render --engine docx`, built from `docx/reference.xml` (were the per-court
//! `docx/build-reference.sh` and `make-reference.sh` shell builders).
//!
//! `reference.xml` holds only the WordprocessingML a court sets; fb starts from pandoc's own reference document
//! (`pandoc --print-default-data-file reference.docx`) and applies it:
//!
//! ```text
//! <reference xmlns:w=".." xmlns:r=".." styles="merge|replace" theme-font="Times New Roman" strip-theme-fonts="true">
//!   <w:docDefaults>..</w:docDefaults>      replaces pandoc's document defaults (optional)
//!   <w:style w:styleId="X">..</w:style>    merge: replaces pandoc's style X in place, or is added at the end;
//!                                          replace: the styles part holds only these (and the defaults and
//!                                          a <w:latentStyles>, when given)
//!   <footer id="rIdX"><w:p>..</w:p></footer>  a footer part (word/footerN.xml) under relationship id rIdX
//!   <w:sectPr>..</w:sectPr>                the document's last section properties (optional)
//! </reference>
//! ```
//!
//! `theme-font` sets the theme's major and minor latin faces; `strip-theme-fonts` drops the `w:*Theme` font
//! attributes from the styles part, so every style names its font explicitly. The parts are packed with
//! docxzip::pack (reproducible archive).
use crate::proc::capture;
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::Command;

const STYLES_NS: &str = r#"xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships""#;

/// A parsed `reference.xml`.
#[derive(Debug, Default, PartialEq)]
struct Spec {
    replace_styles: bool,
    theme_font: Option<String>,
    strip_theme_fonts: bool,
    defaults: Option<String>,
    latent: Option<String>,
    styles: Vec<String>,
    footers: Vec<(String, String)>,
    sect: Option<String>,
}

fn bad(what: &str) -> crate::Fail {
    fail(1, format!("fb render: docx/reference.xml: {what}"))
}

/// The value of attribute `name` in the start tag `tag`.
fn attr(tag: &str, name: &str) -> Option<String> {
    let key = format!(" {name}=\"");
    let at = tag.find(&key)? + key.len();
    let end = tag[at..].find('"')?;
    Some(tag[at..at + end].to_string())
}

/// Every `<name ...>...</name>` or `<name .../>` element of `text` (not nested in itself), in order; `<name`
/// must be followed by a space, `/` or `>` so `w:style` does not match `w:styles`.
fn elements<'a>(text: &'a str, name: &str) -> Vec<&'a str> {
    let open = format!("<{name}");
    let close = format!("</{name}>");
    let mut out = vec![];
    let mut from = 0;
    while let Some(i) = text[from..].find(&open).map(|i| i + from) {
        let next = text[i + open.len()..].chars().next();
        if !matches!(next, Some(' ' | '>' | '/' | '\n' | '\t' | '\r')) {
            from = i + open.len();
            continue;
        }
        let Some(tag_end) = text[i..].find('>').map(|j| j + i + 1) else {
            break;
        };
        if text[..tag_end].ends_with("/>") {
            out.push(&text[i..tag_end]);
            from = tag_end;
            continue;
        }
        let Some(j) = text[i..].find(&close).map(|j| j + i + close.len()) else {
            break;
        };
        out.push(&text[i..j]);
        from = j;
    }
    out
}

/// The content of an element (between its start tag and its end tag).
fn inner(el: &str) -> &str {
    let start = el.find('>').map_or(0, |i| i + 1);
    let end = el.rfind("</").unwrap_or(el.len());
    &el[start..end.max(start)]
}

fn parse(text: &str) -> Res<Spec> {
    well_formed(text)?;
    let root = text
        .find("<reference")
        .and_then(|i| text[i..].find('>').map(|j| &text[i..i + j]))
        .ok_or_else(|| bad("no <reference> element"))?;
    let flag = |n: &str| attr(root, n).is_some_and(|v| v == "true");
    let replace_styles = match attr(root, "styles").as_deref() {
        None | Some("merge") => false,
        Some("replace") => true,
        Some(v) => return Err(bad(&format!("styles=\"{v}\" (merge or replace)"))),
    };
    let footer_els = elements(text, "footer");
    let mut rest = text.to_string();
    let mut footers = vec![];
    for f in &footer_els {
        let id = attr(&f[..f.find('>').unwrap_or(0)], "id")
            .ok_or_else(|| bad("a <footer> has no id"))?;
        footers.push((id, inner(f).trim().to_string()));
        rest = rest.replacen(f, "", 1);
    }
    Ok(Spec {
        replace_styles,
        theme_font: attr(root, "theme-font"),
        strip_theme_fonts: flag("strip-theme-fonts"),
        defaults: elements(&rest, "w:docDefaults")
            .first()
            .map(|s| s.to_string()),
        latent: elements(&rest, "w:latentStyles")
            .first()
            .map(|s| s.to_string()),
        styles: elements(&rest, "w:style")
            .iter()
            .map(|s| s.to_string())
            .collect(),
        footers,
        sect: elements(&rest, "w:sectPr").last().map(|s| s.to_string()),
    })
}

fn well_formed(text: &str) -> Res<()> {
    let mut r = quick_xml::Reader::from_str(text);
    loop {
        match r.read_event() {
            Ok(quick_xml::events::Event::Eof) => return Ok(()),
            Ok(_) => {}
            Err(e) => return Err(bad(&format!("not well-formed XML: {e}"))),
        }
    }
}

/// The styles part of pandoc's reference with the spec applied.
fn styles(base: &str, s: &Spec) -> Res<String> {
    let mut out = if s.replace_styles {
        let parts: Vec<&str> = [s.defaults.as_deref(), s.latent.as_deref()]
            .into_iter()
            .flatten()
            .chain(s.styles.iter().map(String::as_str))
            .collect();
        format!(
            "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<w:styles {STYLES_NS}>\n{}\n</w:styles>\n",
            parts.join("\n")
        )
    } else {
        let mut out = base.to_string();
        let mut added = vec![];
        for st in &s.styles {
            let id = attr(&st[..st.find('>').unwrap_or(0)], "w:styleId")
                .ok_or_else(|| bad("a <w:style> has no w:styleId"))?;
            let key = format!("w:styleId=\"{id}\"");
            if let Some(old) = elements(&out, "w:style")
                .into_iter()
                .find(|e| e[..e.find('>').unwrap_or(0)].contains(&key))
            {
                out = out.replacen(old, st, 1);
            } else {
                added.push(st.as_str());
            }
        }
        if let Some(d) = &s.defaults {
            let old = elements(&out, "w:docDefaults")
                .first()
                .map(|o| o.to_string())
                .ok_or_else(|| bad("pandoc's styles part has no w:docDefaults"))?;
            out = out.replacen(&old, d, 1);
        }
        let at = out
            .rfind("</w:styles>")
            .ok_or_else(|| bad("pandoc's styles part has no </w:styles>"))?;
        format!("{}{}\n{}", &out[..at], added.join("\n"), &out[at..])
    };
    if s.strip_theme_fonts {
        for a in ["asciiTheme", "hAnsiTheme", "eastAsiaTheme", "csTheme"] {
            out = strip_attr(&out, &format!("w:{a}"));
        }
    }
    Ok(out)
}

/// `text` without any ` name="..."` attribute.
fn strip_attr(text: &str, name: &str) -> String {
    let key = format!(" {name}=\"");
    let mut out = String::with_capacity(text.len());
    let mut rest = text;
    while let Some(i) = rest.find(&key) {
        out.push_str(&rest[..i]);
        let after = &rest[i + key.len()..];
        rest = after.find('"').map_or("", |j| &after[j + 1..]);
    }
    out.push_str(rest);
    out
}

/// The theme with its major and minor latin faces set to `font`.
fn theme(base: &str, font: &str) -> String {
    let mut out = base.to_string();
    for group in ["<a:majorFont>", "<a:minorFont>"] {
        let Some(g) = out.find(group) else { continue };
        let key = "<a:latin typeface=\"";
        let Some(i) = out[g..].find(key).map(|i| i + g + key.len()) else {
            continue;
        };
        let Some(j) = out[i..].find('"').map(|j| j + i) else {
            continue;
        };
        out.replace_range(i..j, font);
    }
    out
}

fn read(p: &Path) -> Res<String> {
    std::fs::read_to_string(p).map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))
}

fn write(p: &Path, text: &str) -> Res<()> {
    std::fs::write(p, text).map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))
}

/// Build the reference document of `spec_path` into `work/reference.docx`.
pub fn build(spec_path: &Path, work: &Path) -> Res<PathBuf> {
    let spec = parse(&read(spec_path)?)?;
    let base = work.join("pandoc-reference.docx");
    let o = capture(Command::new("pandoc").args(["--print-default-data-file", "reference.docx"]))?;
    if !o.status.success() {
        return Err(fail(
            1,
            "fb render: pandoc --print-default-data-file failed",
        ));
    }
    std::fs::write(&base, &o.stdout)
        .map_err(|e| fail(2, format!("fb render: {}: {e}", base.display())))?;
    let x = work.join("reference-parts");
    crate::docxzip::unpack(&base, &x)?;
    let sp = x.join("word/styles.xml");
    write(&sp, &styles(&read(&sp)?, &spec)?)?;
    if let Some(font) = &spec.theme_font {
        let tp = x.join("word/theme/theme1.xml");
        write(&tp, &theme(&read(&tp)?, font))?;
    }
    let mut rels = String::new();
    let mut types = String::new();
    for (n, (id, body)) in spec.footers.iter().enumerate() {
        let file = format!("footer{}.xml", n + 1);
        write(
            &x.join("word").join(&file),
            &format!("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<w:ftr {STYLES_NS}>{body}</w:ftr>\n"),
        )?;
        rels.push_str(&format!(r#"<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="{id}" Target="{file}" />"#));
        types.push_str(&format!(r#"<Override PartName="/word/{file}" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />"#));
    }
    let rp = x.join("word/_rels/document.xml.rels");
    write(
        &rp,
        &read(&rp)?.replacen("</Relationships>", &format!("{rels}</Relationships>"), 1),
    )?;
    let cp = x.join("[Content_Types].xml");
    write(
        &cp,
        &read(&cp)?.replacen("</Types>", &format!("{types}</Types>"), 1),
    )?;
    if let Some(sect) = &spec.sect {
        let dp = x.join("word/document.xml");
        let doc = crate::docxpass::replace_final_sect(&read(&dp)?, sect)
            .ok_or_else(|| bad("pandoc's reference document has no final sectPr"))?;
        write(&dp, &doc)?;
    }
    for part in [
        "word/styles.xml",
        "word/document.xml",
        "word/_rels/document.xml.rels",
    ] {
        well_formed(&read(&x.join(part))?).map_err(|e| fail(1, format!("{}: {part}", e.msg)))?;
    }
    let out = work.join("reference.docx");
    crate::docxzip::pack(&x, &out)?;
    Ok(out)
}

/// `fb docx-reference <docx-dir> <out.docx>`: write the reference document a docx/reference.xml describes (to open
/// the styles in Word; `fb render` builds its own).
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    let [dir, out] = args else {
        return Err(fail(2, "usage: fb docx-reference <docx-dir> <out.docx>"));
    };
    std::env::set_var("SOURCE_DATE_EPOCH", crate::render::REPRO_EPOCH);
    let work = crate::proc::TempDir::new("docx-reference")?;
    let built = build(&Path::new(dir).join("reference.xml"), work.path())?;
    std::fs::copy(&built, out).map_err(|e| fail(2, format!("fb docx-reference: {out}: {e}")))?;
    println!("{out}");
    Ok(std::process::ExitCode::SUCCESS)
}

/// The court's docx folder as the engine runs it: `d` itself, or, when `d` has a `reference.xml`, a copy of it
/// in `work` holding the built `reference.docx` (so a court's own docx/render.sh finds it next to itself).
pub fn stage(d: &Path, work: &Path) -> Res<PathBuf> {
    let spec = d.join("reference.xml");
    if !spec.is_file() {
        return Ok(d.to_path_buf());
    }
    if d.join("reference.docx").exists() {
        return Err(fail(
            1,
            format!(
                "fb render: {} has both reference.xml and reference.docx; keep one",
                d.display()
            ),
        ));
    }
    let staged = work.join("docx");
    copy_tree(d, &staged)?;
    let built = build(&spec, work)?;
    std::fs::rename(&built, staged.join("reference.docx"))
        .map_err(|e| fail(2, format!("fb render: {}: {e}", staged.display())))?;
    Ok(staged)
}

fn copy_tree(from: &Path, to: &Path) -> Res<()> {
    let io = |p: &Path, e: std::io::Error| fail(2, format!("fb render: {}: {e}", p.display()));
    std::fs::create_dir_all(to).map_err(|e| io(to, e))?;
    for e in std::fs::read_dir(from).map_err(|e| io(from, e))?.flatten() {
        let (src, dst) = (e.path(), to.join(e.file_name()));
        if src.is_dir() {
            copy_tree(&src, &dst)?;
        } else {
            std::fs::copy(&src, &dst).map_err(|e| io(&src, e))?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const SPEC: &str = r#"<?xml version="1.0"?>
<reference xmlns:w="w" xmlns:r="r" theme-font="Times New Roman" strip-theme-fonts="true">
<w:docDefaults><w:rPrDefault/></w:docDefaults>
<w:style w:type="paragraph" w:styleId="Normal"><w:name w:val="Normal"/></w:style>
<w:style w:type="paragraph" w:styleId="New"><w:name w:val="New"/></w:style>
<footer id="rIdF"><w:p><w:r><w:t>1</w:t></w:r></w:p></footer>
<w:sectPr><w:footerReference r:id="rIdF"/></w:sectPr>
</reference>
"#;

    #[test]
    fn parses_every_piece() {
        let s = parse(SPEC).unwrap();
        assert!(!s.replace_styles && s.strip_theme_fonts);
        assert_eq!(s.theme_font.as_deref(), Some("Times New Roman"));
        assert_eq!(
            s.defaults.as_deref(),
            Some("<w:docDefaults><w:rPrDefault/></w:docDefaults>")
        );
        assert_eq!(s.styles.len(), 2);
        assert_eq!(
            s.footers,
            vec![(
                "rIdF".to_string(),
                "<w:p><w:r><w:t>1</w:t></w:r></w:p>".to_string()
            )]
        );
        assert_eq!(
            s.sect.as_deref(),
            Some(r#"<w:sectPr><w:footerReference r:id="rIdF"/></w:sectPr>"#)
        );
        assert!(parse("<reference styles=\"x\"/>").is_err());
        assert!(parse("<reference><w:style></reference>").is_err());
    }

    #[test]
    fn merge_replaces_same_ids_and_appends_the_rest() {
        let base = "<w:styles>\n<w:docDefaults><old/></w:docDefaults>\n<w:style w:styleId=\"Normal\"><w:rFonts w:asciiTheme=\"minorHAnsi\" w:ascii=\"A\"/></w:style>\n<w:style w:styleId=\"Keep\"><w:rFonts w:hAnsiTheme=\"x\"/></w:style>\n</w:styles>";
        let got = styles(base, &parse(SPEC).unwrap()).unwrap();
        assert!(!got.contains("<old/>") && got.contains("<w:rPrDefault/>"));
        assert_eq!(got.matches("w:styleId=\"Normal\"").count(), 1);
        assert!(got.contains("<w:name w:val=\"Normal\"/>") && got.contains("w:styleId=\"New\""));
        assert!(got.contains("w:styleId=\"Keep\"><w:rFonts/>"));
        assert!(got.find("w:styleId=\"New\"") < got.find("</w:styles>"));
        assert!(got.find("<w:name w:val=\"Normal\"/>") < got.find("w:styleId=\"Keep\""));
    }

    #[test]
    fn replace_keeps_only_the_spec() {
        let spec = SPEC.replace("<reference ", "<reference styles=\"replace\" ");
        let got = styles(
            "<w:styles><w:style w:styleId=\"Old\"/></w:styles>",
            &parse(&spec).unwrap(),
        )
        .unwrap();
        assert!(
            !got.contains("Old")
                && got.contains("w:styleId=\"New\"")
                && got.contains("<w:rPrDefault/>")
        );
    }

    #[test]
    fn theme_sets_major_and_minor_latin() {
        let t = "<a:majorFont><a:latin typeface=\"Aptos Display\"/></a:majorFont><a:minorFont><a:latin typeface=\"Aptos\"/></a:minorFont>";
        assert_eq!(
            theme(t, "Times New Roman"),
            "<a:majorFont><a:latin typeface=\"Times New Roman\"/></a:majorFont><a:minorFont><a:latin typeface=\"Times New Roman\"/></a:minorFont>"
        );
    }

    #[test]
    fn elements_do_not_confuse_style_and_styles() {
        assert_eq!(
            elements(
                "<w:latentStyles w:count=\"1\"/><w:style a=\"2\"/>",
                "w:latentStyles"
            ),
            ["<w:latentStyles w:count=\"1\"/>"]
        );
        assert_eq!(
            elements(
                "<w:styles><w:style a=\"1\">x</w:style></w:styles>",
                "w:style"
            ),
            ["<w:style a=\"1\">x</w:style>"]
        );
    }
}
