//! The reference document of `fb render --engine docx`, built from `docx/reference.xml` (were the per-court
//! `docx/build-reference.sh` and `make-reference.sh` shell builders, and a committed binary `reference.docx`).
//!
//! `reference.xml` holds only the WordprocessingML a court sets; fb starts from pandoc's own reference document
//! (`pandoc --print-default-data-file reference.docx`), or from the cross-engine recipe (docxxengine.rs), and
//! applies it:
//!
//! ```text
//! <reference xmlns:w=".." xmlns:r=".." base="pandoc|xengine" styles="merge|replace" theme-font="{font}"
//!            strip-theme-fonts="true" pandoc-from="markdown+smart" [recipe attributes, docxxengine.rs]>
//!   <w:styles ..>..</w:styles>             the whole styles part, verbatim (alone: no other styles, no xengine base)
//!   <w:docDefaults>..</w:docDefaults>      replaces the document defaults (optional)
//!   <w:style w:styleId="X">..</w:style>    merge: replaces style X in place, or is added at the end;
//!                                          replace: the styles part holds only these (and the defaults and
//!                                          a <w:latentStyles>, when given)
//!   <footer id="rIdX"><w:p>..</w:p></footer>  a footer part (word/footerN.xml) under relationship id rIdX
//!   <header id="rIdY"><w:p>..</w:p></header>  a header part (word/headerN.xml), the same way
//!   <part name="word/settings.xml"><w:settings ..>..</w:settings></part>  a part of pandoc's reference, replaced
//!   <w:sectPr>..</w:sectPr>                the document's last section properties (optional)
//! </reference>
//! ```
//!
//! `{font}` anywhere in the file is the body face of the folder's typst template (typstface.rs): the docx names the
//! face the typst template sets, from one source. `theme-font` sets the theme's major and minor latin faces;
//! `strip-theme-fonts` drops the `w:*Theme` font attributes from the styles part, so every style names its font
//! explicitly. `pandoc-from` is the reader of every pandoc pass (default `markdown+smart`). The parts are packed
//! with docxzip::pack (reproducible archive). `fb docx-reference --extract` writes the file from a reference.docx
//! (docxextract.rs).
use crate::proc::capture;
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::Command;

pub(crate) const STYLES_NS: &str = r#"xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships""#;
const DECL: &str = r#"<?xml version="1.0" encoding="UTF-8" standalone="yes"?>"#;
/// What `{font}` stands for in a reference.xml.
pub(crate) const FONT: &str = "{font}";

/// A parsed `reference.xml`.
#[derive(Debug, Default, PartialEq)]
pub(crate) struct Spec {
    pub(crate) xengine: Option<crate::docxxengine::Recipe>,
    pub(crate) replace_styles: bool,
    pub(crate) theme_font: Option<String>,
    pub(crate) strip_theme_fonts: bool,
    pub(crate) pandoc_from: Option<String>,
    /// namespace declarations (and mc:Ignorable) of `<reference>` beyond w and r, for the styles part
    pub(crate) ns: String,
    pub(crate) styles_part: Option<String>,
    pub(crate) defaults: Option<String>,
    pub(crate) latent: Option<String>,
    pub(crate) styles: Vec<String>,
    pub(crate) footers: Vec<(String, String)>,
    pub(crate) headers: Vec<(String, String)>,
    pub(crate) parts: Vec<(String, String)>,
    pub(crate) sect: Option<String>,
}

fn bad(what: &str) -> crate::Fail {
    fail(1, format!("fb render: docx/reference.xml: {what}"))
}

/// The value of attribute `name` in the start tag `tag`.
pub(crate) fn attr(tag: &str, name: &str) -> Option<String> {
    let key = format!(" {name}=\"");
    let at = tag.find(&key)? + key.len();
    let end = tag[at..].find('"')?;
    Some(tag[at..at + end].to_string())
}

/// Every `<name ...>...</name>` or `<name .../>` element of `text` (not nested in itself), in order; `<name`
/// must be followed by a space, `/` or `>` so `w:style` does not match `w:styles`.
pub(crate) fn elements<'a>(text: &'a str, name: &str) -> Vec<&'a str> {
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
pub(crate) fn inner(el: &str) -> &str {
    let start = el.find('>').map_or(0, |i| i + 1);
    let end = el.rfind("</").unwrap_or(el.len());
    &el[start..end.max(start)]
}

/// The start tag of an element.
fn start_tag(el: &str) -> &str {
    &el[..el.find('>').unwrap_or(0)]
}

/// `text` with `{font}` replaced by `face` (an error if it is needed and the typst template names none).
pub(crate) fn with_font(text: &str, face: Option<&str>) -> Res<String> {
    if !text.contains(FONT) {
        return Ok(text.to_string());
    }
    face.map(|f| text.replace(FONT, f))
        .ok_or_else(|| bad("names {font}, but the typst template sets no face (typstface.rs)"))
}

pub(crate) fn parse(text: &str, face: Option<&str>) -> Res<Spec> {
    let text = &with_font(text, face)?;
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
    let xengine = match attr(root, "base").as_deref() {
        None | Some("pandoc") => None,
        Some("xengine") => {
            let f = face.ok_or_else(|| {
                bad("base=\"xengine\" takes the typst template's face, and it sets none")
            })?;
            Some(crate::docxxengine::recipe(|k| attr(root, k), f).map_err(|e| bad(&e))?)
        }
        Some(v) => return Err(bad(&format!("base=\"{v}\" (pandoc or xengine)"))),
    };
    let mut rest = text.to_string();
    let (mut footers, mut headers) = (vec![], vec![]);
    for (kind, list) in [("footer", &mut footers), ("header", &mut headers)] {
        for f in elements(text, kind) {
            let id =
                attr(start_tag(f), "id").ok_or_else(|| bad(&format!("a <{kind}> has no id")))?;
            list.push((id, inner(f).trim().to_string()));
            rest = rest.replacen(f, "", 1);
        }
    }
    let mut parts = vec![];
    for p in elements(text, "part") {
        let name = attr(start_tag(p), "name").ok_or_else(|| bad("a <part> has no name"))?;
        parts.push((name, inner(p).trim().to_string()));
        rest = rest.replacen(p, "", 1);
    }
    let styles_part = elements(&rest, "w:styles").first().map(|s| s.to_string());
    if let Some(sp) = &styles_part {
        rest = rest.replacen(sp.as_str(), "", 1);
    }
    let spec = Spec {
        xengine,
        replace_styles,
        theme_font: attr(root, "theme-font"),
        strip_theme_fonts: flag("strip-theme-fonts"),
        pandoc_from: attr(root, "pandoc-from"),
        ns: extra_ns(root),
        styles_part,
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
        headers,
        parts,
        sect: elements(&rest, "w:sectPr").last().map(|s| s.to_string()),
    };
    let piecewise = spec.defaults.is_some() || spec.latent.is_some() || !spec.styles.is_empty();
    if spec.styles_part.is_some() && (piecewise || spec.xengine.is_some()) {
        return Err(bad(
            "a whole <w:styles> part takes no other styles and no xengine base",
        ));
    }
    Ok(spec)
}

/// The `xmlns:x` declarations of a start tag other than w and r, and its `mc:Ignorable`, in order, each followed by a
/// space (the styles part gets them: a style may use `w14:` elements).
fn extra_ns(tag: &str) -> String {
    let mut out = String::new();
    for (i, _) in tag.match_indices(' ') {
        let a = &tag[i + 1..];
        let Some(eq) = a.find("=\"") else { continue };
        let name = &a[..eq];
        let keep = (name.starts_with("xmlns:") && name != "xmlns:w" && name != "xmlns:r")
            || name == "mc:Ignorable";
        if let (true, Some(v)) = (keep, attr(tag, name)) {
            out.push_str(&format!("{name}=\"{v}\" "));
        }
    }
    out
}

pub(crate) fn well_formed(text: &str) -> Res<()> {
    let mut r = quick_xml::Reader::from_str(text);
    loop {
        match r.read_event() {
            Ok(quick_xml::events::Event::Eof) => return Ok(()),
            Ok(_) => {}
            Err(e) => return Err(bad(&format!("not well-formed XML: {e}"))),
        }
    }
}

/// The styles part of the base reference with the spec applied.
fn styles(base: &str, s: &Spec) -> Res<String> {
    if let Some(part) = &s.styles_part {
        return Ok(format!("{DECL}\n{part}\n"));
    }
    let mut out = if s.replace_styles {
        let parts: Vec<&str> = [s.defaults.as_deref(), s.latent.as_deref()]
            .into_iter()
            .flatten()
            .chain(s.styles.iter().map(String::as_str))
            .collect();
        format!(
            "{DECL}\n<w:styles {}{STYLES_NS}>\n{}\n</w:styles>\n",
            s.ns,
            parts.join("\n")
        )
    } else {
        let mut out = base.to_string();
        if !s.ns.is_empty() {
            out = out.replacen("<w:styles ", &format!("<w:styles {}", s.ns), 1);
        }
        let mut added = vec![];
        for st in &s.styles {
            let id = attr(start_tag(st), "w:styleId")
                .ok_or_else(|| bad("a <w:style> has no w:styleId"))?;
            let key = format!("w:styleId=\"{id}\"");
            if let Some(old) = elements(&out, "w:style")
                .into_iter()
                .find(|e| start_tag(e).contains(&key))
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
pub(crate) fn theme(base: &str, font: &str) -> String {
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

pub(crate) fn read(p: &Path) -> Res<String> {
    std::fs::read_to_string(p).map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))
}

pub(crate) fn write(p: &Path, text: &str) -> Res<()> {
    std::fs::write(p, text).map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))
}

/// pandoc's own reference document, unpacked into `dir`.
pub(crate) fn pandoc_reference(work: &Path, dir: &Path) -> Res<()> {
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
    crate::docxzip::unpack(&base, dir)
}

/// The doc folder a `docx/reference.xml` belongs to (the parent of its `docx/`).
fn doc_dir(spec_path: &Path) -> Option<&Path> {
    spec_path.parent()?.parent()
}

/// Build the reference document of `spec_path` into `work/reference.docx`.
pub fn build(spec_path: &Path, work: &Path) -> Res<PathBuf> {
    let face = doc_dir(spec_path).and_then(crate::typstface::face);
    let spec = parse(&read(spec_path)?, face.as_deref())?;
    let x = work.join("reference-parts");
    pandoc_reference(work, &x)?;
    let sp = x.join("word/styles.xml");
    let dp = x.join("word/document.xml");
    let footers = crate::docxxengine::footers(&spec.footers, spec.xengine.as_ref());
    if let Some(r) = &spec.xengine {
        write(
            &sp,
            &crate::docxxengine::styles(&read(&sp)?, r).map_err(|e| bad(&e))?,
        )?;
        write(
            &dp,
            &crate::docxxengine::document(&read(&dp)?, r).map_err(|e| bad(&e))?,
        )?;
    }
    // a spec without styles of its own leaves the base's styles part as it is (byte for byte)
    let own_styles = spec.styles_part.is_some()
        || spec.replace_styles
        || spec.strip_theme_fonts
        || !spec.ns.is_empty();
    if own_styles || spec.defaults.is_some() || spec.latent.is_some() || !spec.styles.is_empty() {
        write(&sp, &styles(&read(&sp)?, &spec)?)?;
    }
    if let Some(font) = &spec.theme_font {
        let tp = x.join("word/theme/theme1.xml");
        write(&tp, &theme(&read(&tp)?, font))?;
    }
    for (name, content) in &spec.parts {
        let p = x.join(name);
        if name.contains("..") || !p.is_file() {
            return Err(bad(&format!(
                "<part name=\"{name}\">: pandoc's reference has no such part"
            )));
        }
        write(&p, &format!("{DECL}\n{content}\n"))?;
    }
    let mut rels = String::new();
    let mut types = String::new();
    for (kind, list) in [("footer", &footers), ("header", &spec.headers)] {
        let root = if kind == "footer" { "w:ftr" } else { "w:hdr" };
        for (n, (id, body)) in list.iter().enumerate() {
            let file = format!("{kind}{}.xml", n + 1);
            write(
                &x.join("word").join(&file),
                &format!("{DECL}\n<{root} {STYLES_NS}>{body}</{root}>\n"),
            )?;
            rels.push_str(&format!(r#"<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/{kind}" Id="{id}" Target="{file}" />"#));
            types.push_str(&format!(r#"<Override PartName="/word/{file}" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.{kind}+xml" />"#));
        }
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
/// the styles in Word; `fb render` builds its own). `fb docx-reference --extract <docx-dir>`: write
/// docx/reference.xml from docx/reference.docx (docxextract.rs).
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    if args.first().map(String::as_str) == Some("--extract") {
        return crate::docxextract::main(&args[1..]);
    }
    let [dir, out] = args else {
        return Err(fail(
            2,
            "usage: fb docx-reference <docx-dir> <out.docx> | fb docx-reference --extract <docx-dir>",
        ));
    };
    std::env::set_var("SOURCE_DATE_EPOCH", crate::render::REPRO_EPOCH);
    let work = crate::proc::TempDir::new("docx-reference")?;
    let built = build(&Path::new(dir).join("reference.xml"), work.path())?;
    std::fs::copy(&built, out).map_err(|e| fail(2, format!("fb docx-reference: {out}: {e}")))?;
    println!("{out}");
    Ok(std::process::ExitCode::SUCCESS)
}

/// The reader of a folder on the shared document model (a generated `xdoc.lua`): pandoc's markdown as CommonMark reads
/// a heading (typst's cmarker): one may follow a paragraph line without a blank line.
pub const MODEL_FROM: &str = "markdown+smart-blank_before_header-implicit_figures";

/// The reader of every pandoc pass for the court's docx folder `d` (`pandoc-from`, default `markdown+smart`, or
/// MODEL_FROM for a folder on the shared document model).
pub fn pandoc_from(d: &Path) -> Res<String> {
    let default = if d.join("xdoc.lua").is_file() {
        MODEL_FROM
    } else {
        "markdown+smart"
    };
    let spec = d.join("reference.xml");
    if !spec.is_file() {
        return Ok(default.into());
    }
    let text = read(&spec)?;
    let root = text
        .find("<reference")
        .and_then(|i| text[i..].find('>').map(|j| &text[i..i + j]))
        .ok_or_else(|| bad("no <reference> element"))?;
    Ok(attr(root, "pandoc-from").unwrap_or_else(|| default.into()))
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
#[path = "docxref_tests.rs"]
mod tests;
