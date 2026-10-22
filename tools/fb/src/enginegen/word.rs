//! The generated `docx/reference.xml` of a folder on the shared document model (gen.rs): the cross-engine recipe
//! (docxxengine.rs) at the layout's size and pitches in the typst face (`{font}`), and the styles, footer and
//! section lib/docx/xdoc.lua relies on. Twips = 20 x pt; sizes in half points.
use super::gen::{fmt, footer, num, twips};
use super::tex::{CLEARANCE, NOTE_GAP};
use serde_yaml::Value;

fn exact(before: i64, after: i64, line: i64) -> String {
    format!(
        r#"<w:spacing w:before="{before}" w:after="{after}" w:line="{line}" w:lineRule="exact"/>"#
    )
}

fn style(id: &str, name: &str, based: &str, ppr: &str) -> String {
    format!(
        r#"<w:style w:type="paragraph" w:customStyle="1" w:styleId="{id}"><w:name w:val="{name}"/><w:basedOn w:val="{based}"/><w:qFormat/><w:pPr>{ppr}</w:pPr></w:style>"#
    )
}

/// A pitch of the layout: "body", "single" (the default) or points.
fn pitch(l: &Value, v: Option<&Value>) -> Result<f64, String> {
    match v {
        Some(Value::String(s)) if s == "body" => num(l, "pitch.body", None),
        Some(Value::Number(n)) => Ok(n.as_f64().unwrap_or(0.0)),
        _ => num(l, "pitch.single", None),
    }
}

pub fn reference(l: &Value, _face: &str) -> Result<String, String> {
    let tw = |x: f64, w: &str| twips(x, w);
    let size = num(l, "size", None)?;
    let half = (size * 2.0).round() as i64;
    let body = tw(num(l, "pitch.body", None)?, "pitch.body")?;
    let (single_pt, _, dist) = footer(l)?;
    let single = tw(single_pt, "pitch.single")?;
    let indent = tw(num(l, "indent", None)?, "indent")?;
    let list = tw(
        num(l, "list_indent", Some(num(l, "indent", None)?))?,
        "list_indent",
    )?;
    let fnv = l.get("footnote");
    let note = tw(
        pitch(l, fnv.and_then(|f| f.get("pitch")))?,
        "footnote.pitch",
    )?;
    let nsize = (num(l, "footnote.size", Some(size))? * 2.0).round() as i64;
    let gap = tw(num(l, "footnote.gap", Some(NOTE_GAP))?, "footnote.gap")?;
    let _ = CLEARANCE; // LibreOffice sets the space above the footnote rule itself (typst and LaTeX follow it: tex.rs)
    let q = l.get("quote");
    let qn = |k: &str, d: f64| num(l, &format!("quote.{k}"), Some(d));
    let (qa, qb, qg) = (
        tw(qn("above", 0.0)?, "quote.above")?,
        tw(qn("below", 0.0)?, "quote.below")?,
        tw(qn("gap", 0.0)?, "quote.gap")?,
    );
    let ql = tw(qn("left", num(l, "indent", None)?)?, "quote.left")?;
    let qr = tw(qn("right", num(l, "indent", None)?)?, "quote.right")?;
    let qp = tw(pitch(l, q.and_then(|q| q.get("pitch")))?, "quote.pitch")?;
    let qind = format!(r#"<w:ind w:left="{ql}" w:right="{qr}" w:firstLine="0"/>"#);
    let t = l.get("tail");
    let tp = tw(pitch(l, t.and_then(|t| t.get("pitch")))?, "tail.pitch")?;
    let ti = tw(num(l, "tail.indent", Some(0.0))?, "tail.indent")?;
    let tg = tw(num(l, "tail.gap", Some(0.0))?, "tail.gap")?;
    let m = |s: &str| -> Result<i64, String> { tw(num(l, &format!("margin.{s}"), None)?, s) };
    let pn = l.get("page_number");
    let jc = pn
        .and_then(|p| p.get("align"))
        .and_then(Value::as_str)
        .unwrap_or("center");
    let from = num(l, "page_number.from", Some(1.0))?;
    let numbered = !pn.is_some_and(Value::is_null);
    let foot = tw(
        (dist * 20.0).round() / 20.0,
        "the page number's distance from the page foot",
    )?;
    let fld = r#"<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>"#;
    let footer_p = format!(
        r#"<w:p><w:pPr>{}<w:jc w:val="{jc}"/></w:pPr>{}</w:p>"#,
        exact(0, 0, single),
        if numbered { fld } else { "" }
    );
    let first = if numbered && from > 1.0 {
        r#"<w:footerReference w:type="first" r:id="rIdFooterFirst"/>"#
    } else {
        ""
    };
    let title_pg = if first.is_empty() { "" } else { "<w:titlePg/>" };
    let mut out = String::new();
    out.push_str("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    out.push_str(&format!(
        "<!-- {} The Word styles of the shared document model (lib/docx/xdoc.lua): the cross-engine recipe \
(tools/fb/src/docxxengine.rs) in the typst face at {} pt, Body Text in exact {} pt line boxes with a {} pt \
first-line indent, footnotes in {} pt boxes {} pt apart; added: Body Text Note (a paragraph that anchors a \
footnote, without widow control: typst may move its last line on alone with the note), a Footnote Text that is never \
split (typst and LaTeX never split a note), the quotation styles (first, middle, last, only), the tail style, the page-number \
footer in a single line box {} pt above the page foot, and the page's margins. Twips: 20 x pt. -->\n",
        super::gen::HEAD,
        fmt(size),
        fmt(body as f64 / 20.0),
        fmt(indent as f64 / 20.0),
        fmt(note as f64 / 20.0),
        fmt(gap as f64 / 20.0),
        fmt(foot as f64 / 20.0),
    ));
    out.push_str(&format!(
        r#"<reference xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" base="xengine" size="{half}" body="{body}" single="{single}" indent="{indent}" list="{list}" note="{note}" note-size="{nsize}" note-after="{gap}" footer="{foot}">"#
    ));
    out.push('\n');
    for s in [
        style(
            "BodyTextNote",
            "Body Text Note",
            "BodyText",
            r#"<w:widowControl w:val="0"/>"#,
        ),
        format!(
            r#"<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepLines/>{}</w:pPr><w:rPr><w:sz w:val="{nsize}"/><w:szCs w:val="{nsize}"/></w:rPr></w:style>"#,
            exact(0, gap, note)
        ),
        style(
            "XdQuote",
            "Xd Quote",
            "Normal",
            &(exact(qg, qg, qp) + &qind),
        ),
        style(
            "XdQuoteFirst",
            "Xd Quote First",
            "Normal",
            &(exact(qa, qg, qp) + &qind),
        ),
        style(
            "XdQuoteLast",
            "Xd Quote Last",
            "Normal",
            &(exact(qg, qb, qp) + &qind),
        ),
        style(
            "XdQuoteOnly",
            "Xd Quote Only",
            "Normal",
            &(exact(qa, qb, qp) + &qind),
        ),
        style(
            "XdTail",
            "Xd Tail",
            "Normal",
            &(exact(0, tg, tp) + &format!(r#"<w:ind w:firstLine="{ti}"/>"#)),
        ),
    ] {
        out.push_str(&s);
        out.push('\n');
    }
    // list items per nesting level, in the body and in the tail: the label at the level's indent, the text hanging
    for (base, line) in [("XdList", body), ("XdTailList", tp)] {
        for lv in 1..=3i64 {
            let ind = format!(r#"<w:ind w:left="{}" w:hanging="{list}"/>"#, lv * list);
            out.push_str(&style(
                &format!("{base}{lv}"),
                &format!("{base} {lv}"),
                "Normal",
                &(exact(0, 0, line) + &ind),
            ));
            out.push('\n');
        }
    }
    out.push_str(&format!(r#"<footer id="rIdFooter1">{footer_p}</footer>"#));
    out.push('\n');
    if !first.is_empty() {
        out.push_str(&format!(
            r#"<footer id="rIdFooterFirst"><w:p><w:pPr>{}</w:pPr></w:p></footer>"#,
            exact(0, 0, single)
        ));
        out.push('\n');
    }
    out.push_str(&format!(
        r#"<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>{first}<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="{}" w:right="{}" w:bottom="{}" w:left="{}" w:header="720" w:footer="{foot}" w:gutter="0"/>{title_pg}</w:sectPr>"#,
        m("top")?,
        m("right")?,
        m("bottom")?,
        m("left")?
    ));
    out.push_str("\n</reference>\n");
    Ok(out)
}
