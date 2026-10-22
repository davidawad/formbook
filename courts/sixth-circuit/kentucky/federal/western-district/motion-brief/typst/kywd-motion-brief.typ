// Memorandum in support of a Rule 12(b) motion for the U.S. District Court for the Western District of
// Kentucky (kywd). Rules: LR 5.2(a) (8 1/2 x 11 page, margins of at least one inch on all sides, text double
// spaced except block quotes, headings and footnotes, 12-point proportionately spaced font); LR 7.1(a), (d)
// (motion and memorandum merged; 25-page limit for a motion, without leave), LR 7.1(e) (separate proposed
// order, not part of this file); Fed. R. Civ. P. 10(a) (caption, title, file number, Rule 7(a) designation).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.2(a): proportionately spaced; Times New Roman (vendored) per docs/FONTS.md
#let type-size = 12pt                   // LR 5.2(a): at least 12-point
#let margin = 1in                       // LR 5.2(a): margins of at least one inch on all sides (8 1/2 x 11 page)
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge
#let para-indent = 0.5in                // first-line indent of body paragraphs (memoranda are not numbered)
#let item-box = 0.5in                   // a list item's label box after the indent, the text hanging after it
#let quote-indent = 0.5in               // a block quotation's indent on both sides (LR 5.2(a): single spaced)
#let caption-left = 3.1in               // width of the party column of the caption
#let paren-col = 0.3in                  // the column of ")" marks
#let versus-indent = 0.75in             // "vs." between the parties
#let designation-indent = 1.5in         // "PLAINTIFF" / "DEFENDANTS"
#let sig-indent = 3.25in                // the signature block starts here

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kywd-motion-brief.lua sets the same twips).
#let pitch-body = 24pt                  // LR 5.2(a): double spaced; body text, headings, list items
#let pitch-single = 13.8pt              // single spacing: court title, caption, title, quotations, signature
#let court-below = 13.8pt               // the court title to the caption (a blank single line)
#let title-above = 13.8pt               // the caption to the title
#let title-below = 24pt                 // the title to the text (a blank double line)
#let heading-above = 12pt               // above a heading (half a double line)
#let quote-space = 12pt                 // above and below a block quotation
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 13.8pt                   // between the groups of the signature block (a blank single line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kywd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, unloose(c)))
})

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a)): court title, party column closed by a column of ")" marks, the case
// number on the "vs." row (or the first row), the title of the paper centered below.
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in meta.court { sline(centered: true, text(weight: "bold", inl(l))) }

/// One row per line of the party column. "vs." sits between the parties; designations are indented.
#let caption-rows(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      rows.push((t: "", indent: 0in))
      rows.push((t: "vs.", indent: versus-indent))
      rows.push((t: "", indent: 0in))
    }
    for n in p.names { rows.push((t: n, indent: 0in)) }
    rows.push((t: p.designation, indent: designation-indent))
  }
  rows
}

/// The ")" column is one mark per row, so the column is as tall as the party column (docx: one table row each).
#let caption(meta) = {
  let rows = caption-rows(meta)
  let label = meta.at("case_label", default: "CASE NO.")
  let case-row = rows.position(r => r.t == "vs.")
  if case-row == none { case-row = 0 }
  block(width: 100%, above: court-below, below: 0pt, grid(
    columns: (caption-left, paren-col, 1fr),
    ..rows.enumerate().map(((i, r)) => (
      sline(left: r.indent, inl(r.t)),
      sline[)],
      sline(if i == case-row [#label #meta.case_number] else []),
    )).flatten(),
  ))
}

#let title-block(meta) = block(width: 100%, above: title-above, below: title-below,
  sline(centered: true, text(weight: "bold", inl(meta.title))))

// ---------------------------------------------------------------------------
// Body: paragraphs (first-line indent), headings, lists, quotations
// ---------------------------------------------------------------------------

/// Heading levels, on the body pitch, half a double line above: 1 centered bold capitals; 2 and 3 bold, left.
/// Sticky, so a heading never ends a page.
#let heading-block(level, t) = block(above: heading-above, below: 0pt, width: 100%, sticky: true, {
  set align(center) if level == 1
  par(first-line-indent: 0pt, text(weight: "bold", if level == 1 { upper(unloose(inl(t))) } else { unloose(inl(t)) }))
})

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(c)))

/// A list item ("1. ...", "- ..."): the label at the indent in its box, the text hanging after it.
#let list-item(label, t) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: para-indent + item-box,
    [#h(para-indent)#box(width: item-box, label)#unloose(inl(t))]))

#let list-items(t) = {
  // a line that starts with a label opens an item; any other line continues the item before it
  let items = ()
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^(\\d+\\.|[-*+])[ \\t]+(.*)$"))
    if m != none { items.push((m.captures.at(0), m.captures.at(1))) } else {
      let (lab, s) = items.pop()
      items.push((lab, s + " " + l.trim()))
    }
  }
  for (lab, s) in items {
    list-item(if lab.ends-with(".") { lab } else { [•] }, s.trim())
  }
}

/// Each blank-line-separated chunk of markdown is a heading, a list, a quotation or a paragraph. Paragraphs are
/// not numbered (a memorandum is not a complaint; Fed. R. Civ. P. 10(b) does not apply).
#let memo-body(body) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else if t.starts-with(">") {
      // a block quotation: single spaced (LR 5.2(a)), indented on both sides
      block(width: 100%, above: quote-space, below: quote-space, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        par(first-line-indent: 0pt, unloose(inl(t.replace(regex("(?m)^>[ \t]?"), ""))))
      }))
    } else {
      body-par(inl(t))
    }
  }
}

/// The signature block (LR 5.2(a) sets no form; the layout follows the filed exemplars): single spaced at the
/// signature indent, a blank single line between "Respectfully submitted,", the /s/ line and the lines (and for
/// each empty line); kept on one page.
#let signature-block(sig) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  sline(left: sig-indent)[Respectfully submitted,]
  sline(above: sig-gap, left: sig-indent)[/s/ #inl(sig.by)]
  let gap = sig-gap
  for l in sig.lines {
    if l == "" { gap = sig-gap } else {
      sline(above: gap, left: sig-indent, inl(l))
      gap = 0pt
    }
  }
})

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let kywd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // the page number in a single-pitch line box that ends footer-distance above the page edge (Word: the footer
    // distance)
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Every body paragraph opens with the half-inch indent (after a heading too).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. List items are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled section or pilcrow sign ("¶¶ 32-33") stays with the number after it, as one sign does (xengine boxes "¶ 32").
  show regex("[§¶]{2,} \\S+"): it => box(it)

  {
    set text(..edges(pitch-single))
    court-title(meta)
    caption(meta)
    title-block(meta)
  }

  memo-body(body)

  signature-block(meta.signature)

  if "certificate" in meta and meta.certificate != none {
    block(width: 100%, above: sig-above, below: 0pt, sticky: true,
      sline(centered: true, text(weight: "bold", inl(meta.certificate.heading))))
    body-par(inl(meta.certificate.text))
    signature-block(meta.signature)
  }
}
