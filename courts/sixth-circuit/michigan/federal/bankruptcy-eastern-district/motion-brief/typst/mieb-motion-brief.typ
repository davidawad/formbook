// U.S. Bankruptcy Court, E.D. Michigan: motion with a brief in support (Fed. R. Bankr. P. 9013, 9014;
// Local Bankruptcy Rules 9004-1, 9014-1 and 9029-1(h)).
//
// Rule-driven and content-agnostic. Requirement IDs (MIEB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker in one piece per document (so footnotes work); the metadata comes
// from the YAML frontmatter of the same file (schema: ../README.md). A line holding only `---` starts the next
// document of the filing (the motion, the brief in support, the certificate of service), each with its own
// caption and title.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // MIEB-FORM-002: proportional serif; Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 14pt                    // MIEB-FORM-002: LBR 9029-1(h) "14 point (proportional)" for all text and footnotes.
#let margins = 1in                       // MIEB-FORM-001: LBR 9029-1(h) "at least 1 inch on the top, sides and bottom".
#let text-width = 8.5in - 2 * margins
#let para-indent = 0.5in                 // first-line indent of body paragraphs; a block quotation's indent both sides.
#let list-indent = 0.5in                 // a list item's label box
#let caption-col = text-width / 2        // caption: the debtor column and the case column
#let case-pad = 0.25in                   // caption: the case column stands off the debtor column
#let sig-col = 3.2in                     // signature: the signer's column at the right
#let rule-stroke = 0.5pt                 // the caption's rules (docx: w:sz 4)
#let rule-pad = 4pt                      // caption: the text stands off its rules (docx: 80 twips)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/mieb-motion-brief.lua and docx/reference.xml set
// the same twips, 20 x pt).
#let pitch-body = 28pt                   // MIEB-FORM-003: LBR 9029-1(h) "double-spaced": twice the 14 pt type
#let pitch-single = 17pt                 // MIEB-FORM-004: caption, title, signature; quotations and footnotes (exempt from double spacing)
#let court-below = 16.8pt                // the court name to the caption's first rule
#let caption-below = 16.8pt              // the caption's last rule to the title
#let title-below = 11.2pt                // the title to the text
#let heading-above = 14pt                // a "#" heading: the space above it
#let quote-space = 14pt                  // a block quotation: the space above and below it
#let signature-above = 16.8pt            // the last paragraph to the signature block
#let note-gap = 4pt                      // between two footnotes
#let note-clearance = 12pt               // the body text to the footnote rule

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (italics, links, footnotes, headings) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mieb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mieb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A metadata value that may be one string or a list of strings, as a list.
#let lines-of(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line (a paragraph of its own; a string as plain text).
#let line-block(body) = block(width: 100%, above: 0pt, below: 0pt, body)

// ---------------------------------------------------------------------------
// Document setup: applied with `#show: motion-doc.with(meta)` in main.typ
// ---------------------------------------------------------------------------

#let motion-doc(meta, doc) = {
  set document(title: need(meta, "titles").at(0))
  // Every page numbered "N of M", bottom centre (MIEB-FORM-001), in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margins,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1 of 1", both: true))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Every body paragraph indented, the first after a heading or a title too (docx: Body Text).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number, list labels in a box of list-indent.
  show: xengine.with(pitch: pitch-body, list-indent: list-indent)
  // A doubled section sign stays with its number too ("§§ 157(a)"; xengine binds one sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Headings (markdown #, ##, ###) on the body pitch, kept with the text after them: "#" centred bold, 14 pt above;
  // "##" bold; "###" bold italic (docx: Heading 1 to 3).
  show heading: it => block(width: 100%, sticky: true, above: if it.level == 1 { heading-above } else { 0pt },
    below: 0pt, {
      set par(first-line-indent: 0pt)
      set text(size: type-size)
      if it.level == 1 { align(center, strong(it.body)) }
      else if it.level == 2 { strong(it.body) }
      else { strong(emph(it.body)) }
    })
  // Footnotes: 14 point (MIEB-FORM-002), single-spaced (exempt from double spacing, LBR 9029-1(h)), 4 pt apart.
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Block quotations: single-spaced and indented half an inch on both sides (exempt from double spacing).
  show quote.where(block: true): it => block(width: 100%, above: quote-space, below: quote-space,
    pad(x: para-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))
  doc
}

// ---------------------------------------------------------------------------
// Caption of each document (MIEB-CAP-001, LBR 9004-1(a))
// ---------------------------------------------------------------------------

#let caption(meta, title) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for l in lines-of(need(meta, "court")) { line-block(align(center, l)) }
  let ir = need(meta, "in_re")
  let cs = need(meta, "case")
  let debtor = {
    for (i, n) in lines-of(ir.names).enumerate() { line-block(if i == 0 { "In re: " + n } else { n }) }
    line-block(ir.role)
    line-block("/")
  }
  let case = {
    line-block("Chapter " + cs.chapter)
    line-block("Case No. " + cs.number)
    line-block(cs.judge)
  }
  // The caption ruled above and below across both columns (docx: the cells' borders).
  block(above: court-below, below: 0pt, grid(
    columns: (caption-col, caption-col),
    stroke: (top: rule-stroke, bottom: rule-stroke),
    inset: (top: rule-pad, bottom: rule-pad),
    debtor,
    pad(left: case-pad, case),
  ))
  block(width: 100%, above: caption-below, below: title-below, align(center, strong(title)))
}

// ---------------------------------------------------------------------------
// Signature block at the end of each document (MIEB-SIG-001), kept whole
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, breakable: false, above: signature-above, below: 0pt, grid(
    columns: (text-width - sig-col, sig-col),
    line-block("Dated: " + need(meta, "date")),
    {
      line-block("Respectfully submitted,")
      line-block(sig.signer)
      for l in lines-of(sig.lines) { line-block(l) }
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry point: one document per `---`-separated part of the body
// ---------------------------------------------------------------------------

/// One document's text: cmarker renders it whole (footnotes resolve within it); the last block is kept with the
/// signature block (docx: keepNext), so the signature never stands alone on a page.
#let part-body(s) = {
  let chunks = s.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^"))
  let text-chunks = chunks.filter(c => not c.starts-with("[^"))
  let head = text-chunks.slice(0, -1).join("\n\n")
  let tail = text-chunks.last()
  if head != none { md(head + if defs.len() > 0 { "\n\n" + defs.join("\n\n") } else { "" }) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    [#md(tail + if tail.contains("[^") { "\n\n" + defs.join("\n\n") } else { "" })#parbreak()])
}

#let motion-body(meta, md-src) = {
  let parts = md-src.split(regex("\\r?\\n---[ \\t]*\\r?\\n"))
  let titles = need(meta, "titles")
  if parts.len() != titles.len() {
    panic("mieb-motion-brief: the body has " + str(parts.len()) + " documents but `titles` lists " + str(titles.len()))
  }
  for i in range(parts.len()) {
    if i > 0 { pagebreak(weak: true) }
    caption(meta, titles.at(i))
    part-body(parts.at(i).trim())
    signature(meta)
  }
}
