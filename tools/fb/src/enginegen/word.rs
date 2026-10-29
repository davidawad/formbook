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

/// Footnote Text's space before (twips): max(0, typst's clearance + gap - LibreOffice's 1.15 x size line).
pub fn note_before(l: &Value, size: f64) -> Result<i64, String> {
    let clear = num(l, "footnote.clearance", Some(CLEARANCE))?;
    let gap = num(l, "footnote.gap", Some(NOTE_GAP))?;
    Ok(((clear + gap - LO_NOTE_LINE * size) * 20.0)
        .round()
        .max(0.0) as i64)
}

/// LibreOffice's space above the first footnote line, in Word-compatible layout: one line of the Normal style, 1.15 x
/// its size (13.8 pt at 12 pt, 16.1 at 14; fb-595.54.13, fb-595.54.11.2).
pub const LO_NOTE_LINE: f64 = 1.15;

pub fn reference(l: &Value, _face: &str) -> Result<String, String> {
    let tw = |x: f64, w: &str| twips(x, w);
    let size = num(l, "size", None)?;
    let half = (size * 2.0).round() as i64;
    let body = tw(num(l, "pitch.body", None)?, "pitch.body")?;
    let (single_pt, _, dist) = footer(l)?;
    let (_, page_h) = super::gen::paper(l)?;
    // justified text (layout.yaml justify): Body Text (the recipe's `justify`) and the styles of the body's quotations,
    // lists, tail and notes
    let justify = l.get("justify").and_then(Value::as_bool).unwrap_or(false);
    let jc_both = if justify {
        r#"<w:jc w:val="both"/>"#
    } else {
        ""
    };
    let single = tw(single_pt, "page_number.pitch")?;
    let indent = tw(num(l, "indent", None)?, "indent")?;
    let list = tw(
        num(l, "list_indent", Some(num(l, "indent", None)?))?,
        "list_indent",
    )?;
    // a list's offset from the margin (layout.yaml list.left, fb-595.92): every list style that much further in
    let lleft = tw(num(l, "list.left", Some(0.0))?, "list.left")?;
    let fnv = l.get("footnote");
    let note = tw(
        pitch(l, fnv.and_then(|f| f.get("pitch")))?,
        "footnote.pitch",
    )?;
    let nsize = (num(l, "footnote.size", Some(size))? * 2.0).round() as i64;
    let gap = tw(num(l, "footnote.gap", Some(NOTE_GAP))?, "footnote.gap")?;
    // the space above the first note's line box: typst keeps the clearance and the gap; LibreOffice (Word-compatible
    // layout) one Normal line, 1.15 x the size, whatever the separator footnotes say (sw/source/core/layout/ftnfrm.cxx;
    // measured fb-595.54.11.2), so Footnote Text adds the rest before it (LibreOffice sets it above a page's first
    // note only, not between two). None where LibreOffice's line is the larger (a smaller clearance, a larger size).
    let before = note_before(l, size)?;
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
    // (a running footer of n lines: its last line box ends n - 1 lines lower, where typst stacks them; lib/docx/xdoc.lua
    // writes its paragraphs from the sample)
    // (a footer anchored at its foot, page_number.foot: the distance itself, whatever its lines)
    let lines = if super::gen::footed(l)?.is_some() {
        1.0
    } else {
        super::gen::footer_lines(l) as f64
    };
    let foot = tw(
        ((dist - (lines - 1.0) * single_pt) * 20.0).round() / 20.0,
        "the page number's distance from the page foot",
    )?;
    let fld = r#"<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>"#;
    // the page number alone, or the layout's `page_number.text` ("Page {page} of {pages}") with its fields
    let ptext = pn.and_then(|p| p.get("text")).and_then(Value::as_str);
    let number = match ptext {
        Some(t) if !super::gen::is_running(t) => page_text_runs(t, "NUMPAGES"),
        Some(_) => String::new(),
        None => fld.to_string(),
    };
    // the footer's type size (layout.yaml page_number.size, fb-595.96): on each of its runs when it is not the text's
    let fhalf = (num(l, "page_number.size", Some(size))? * 2.0).round() as i64;
    let number = if fhalf == half {
        number
    } else {
        number.replace(
            "<w:r>",
            &format!(r#"<w:r><w:rPr><w:sz w:val="{fhalf}"/><w:szCs w:val="{fhalf}"/></w:rPr>"#),
        )
    };
    let footer_p = format!(
        r#"<w:p><w:pPr>{}<w:jc w:val="{jc}"/></w:pPr>{}</w:p>"#,
        exact(0, 0, single),
        if numbered { number.as_str() } else { "" }
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
        r#"<reference xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" base="xengine" size="{half}" body="{body}" single="{single}" indent="{indent}" list="{list}" note="{note}" note-size="{nsize}"{nb} note-after="{gap}" footer="{foot}"{just}>"#,
        nb = if before > 0 { format!(r#" note-before="{before}""#) } else { String::new() },
        just = if justify { r#" justify="true""# } else { "" }
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
            r#"<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepLines/>{}{jc_both}</w:pPr><w:rPr><w:sz w:val="{nsize}"/><w:szCs w:val="{nsize}"/></w:rPr></w:style>"#,
            exact(before, gap, note)
        ),
        style(
            "XdQuote",
            "Xd Quote",
            "Normal",
            &(exact(qg, qg, qp) + &qind + jc_both),
        ),
        style(
            "XdQuoteFirst",
            "Xd Quote First",
            "Normal",
            &(exact(qa, qg, qp) + &qind + jc_both),
        ),
        style(
            "XdQuoteLast",
            "Xd Quote Last",
            "Normal",
            &(exact(qg, qb, qp) + &qind + jc_both),
        ),
        style(
            "XdQuoteOnly",
            "Xd Quote Only",
            "Normal",
            &(exact(qa, qb, qp) + &qind + jc_both),
        ),
        style(
            "XdTail",
            "Xd Tail",
            "Normal",
            &(exact(0, tg, tp) + &format!(r#"<w:ind w:firstLine="{ti}"/>"#) + jc_both),
        ),
    ] {
        out.push_str(&s);
        out.push('\n');
    }
    // keep_with_closing: the body's last paragraph whole and on the page of the closing (lib/docx/xdoc.lua)
    if l.get("keep_with_closing")
        .and_then(Value::as_bool)
        .unwrap_or(false)
    {
        out.push_str(&style(
            "BodyTextKeep",
            "Body Text Keep",
            "BodyText",
            "<w:keepNext/><w:keepLines/>",
        ));
        out.push('\n');
    }
    // list items per nesting level, in the body and in the tail: the label at the level's indent, the text hanging
    for (base, line) in [("XdList", body), ("XdTailList", tp)] {
        for lv in 1..=3i64 {
            let ind = format!(
                r#"<w:ind w:left="{}" w:hanging="{list}"/>"#,
                lleft + lv * list
            );
            out.push_str(&style(
                &format!("{base}{lv}"),
                &format!("{base} {lv}"),
                "Normal",
                &(exact(0, 0, line) + &ind + jc_both),
            ));
            out.push('\n');
        }
    }
    // the space between two body paragraphs, a paragraph and a list, two lists (layout.yaml paragraph_gap): the
    // styles of a body paragraph or a list's first item after one of them, the space before (lib/docx/xdoc.lua)
    if l.get("paragraph_gap").is_some() {
        let g = tw(num(l, "paragraph_gap", None)?, "paragraph_gap")?;
        let mut bases = vec![
            ("BodyText", "Body Text", body),
            ("BodyTextNote", "Body Text Note", body),
        ];
        if l.get("keep_with_closing")
            .and_then(Value::as_bool)
            .unwrap_or(false)
        {
            bases.push(("BodyTextKeep", "Body Text Keep", body));
        }
        for (id, name, line) in bases {
            out.push_str(&style(
                &format!("{id}Gap"),
                &format!("{name} Gap"),
                id,
                &exact(g, 0, line),
            ));
            out.push('\n');
        }
        out.push_str(&style(
            "XdList1Gap",
            "XdList 1 Gap",
            "XdList1",
            &exact(g, 0, body),
        ));
        out.push('\n');
    }
    // list items inside a quotation: the quote's indents and pitch, the label at the level's indent past the quote's
    for lv in 1..=3i64 {
        let ind = format!(
            r#"<w:ind w:left="{}" w:right="{qr}" w:hanging="{list}"/>"#,
            ql + lleft + lv * list
        );
        out.push_str(&style(
            &format!("XdQuoteList{lv}"),
            &format!("Xd Quote List {lv}"),
            "Normal",
            &(exact(0, 0, qp) + &ind + jc_both),
        ));
        out.push('\n');
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
        r#"<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>{first}<w:pgSz w:w="12240" w:h="{page_h}"/><w:pgMar w:top="{}" w:right="{}" w:bottom="{}" w:left="{}" w:header="720" w:footer="{foot}" w:gutter="0"/>{title_pg}</w:sectPr>"#,
        m("top")?,
        m("right")?,
        m("bottom")?,
        m("left")?
    ));
    out.push_str("\n</reference>\n");
    Ok(out)
}

/// Word runs of a page-number text (layout.yaml `page_number.text`, "Page {page} of {pages}"): its text as runs,
/// `{page}` the PAGE field, `{pages}` the field `pages` names (NUMPAGES; SECTIONPAGES for a body numbered apart:
/// lib/docx/xdoc.lua page_text).
pub fn page_text_runs(text: &str, pages: &str) -> String {
    let field = |name: &str, shown: &str| {
        format!(
            r#"<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> {name} </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>{shown}</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>"#
        )
    };
    let run = |s: &str| {
        let s = s
            .replace('&', "&amp;")
            .replace('<', "&lt;")
            .replace('>', "&gt;");
        format!(r#"<w:r><w:t xml:space="preserve">{s}</w:t></w:r>"#)
    };
    let mut out = String::new();
    let mut rest = text;
    while let Some(at) = rest.find('{') {
        let (pre, tail) = rest.split_at(at);
        if !pre.is_empty() {
            out.push_str(&run(pre));
        }
        if let Some(t) = tail.strip_prefix("{pages}") {
            out.push_str(&field(pages, "1"));
            rest = t;
        } else if let Some(t) = tail.strip_prefix("{page}") {
            out.push_str(&field("PAGE", "1"));
            rest = t;
        } else {
            out.push_str(&run("{"));
            rest = &tail[1..];
        }
    }
    if !rest.is_empty() {
        out.push_str(&run(rest));
    }
    out
}
