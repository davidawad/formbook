// Supreme Court of Hawaii (haw): petition for writ (mandamus, prohibition, extraordinary writ).
//
// Content-agnostic. The parameters below are the ones HRAP 32(a) and (b) set (HAW-FORM-001 letter
// size and 1-inch margins; HAW-FORM-003 12 point Times New Roman; HAW-FORM-004 footnotes and
// quotations in the text size; HAW-FORM-005 double spacing for text, single for headings, quotations,
// citations and footnotes) and HAW-FLY-001 and HAW-FLY-002 (flyleaf contents; 3-inch top margin on
// the flyleaf) and HAW-SIG-001 (signature block). See ../../rules.md. No case-specific text, no
// coordinates measured off any filed document, no forced line breaks. The markdown body is rendered
// by cmarker; the metadata is the YAML frontmatter of the sample.
//
// OPEN: the HRAP 21 contents of a petition for a writ of mandamus or prohibition were not transcribed
// (rules.md); the template applies HRAP 32 form and flyleaf rules and the petition's own structure
// (from its exemplar) only. The table of authorities is not generated (not in the exemplar's
// transcription either).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HAW-FORM-003, HAW-TYPE-001; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 12pt                    // HAW-FORM-003: 12 point pica equivalent.
#let body-leading = 1.65em               // HAW-FORM-005: double spacing (about 27.6 pt line pitch at 12 pt, the Times line box being about 7.9 pt).
#let single-leading = 0.5em              // HAW-FORM-005: single spacing (about 13.8 pt pitch) for headings, quotations, footnotes and blocks.
#let page-margin = 1in                   // HAW-FORM-001: not less than 1 inch all around.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.25in                 // signature block starts right of centre, as the exemplar does.
#let flyleaf-top = 2in                   // HAW-FLY-002: flyleaf top margin of 3 inches = 1 inch page margin + 2 inches.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption: left column names and designations, right column the proceeding lines.
#let caption-block(sides, right) = grid(
  columns: (3.1in, 1fr),
  column-gutter: 0.2in,
  [
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
    #for side in sides [
      #if "names" in side { for n in side.names [ #inl(n) \ ] }
      #if "designation" in side [ #pad(left: if "indent" in side and side.indent { 1.5in } else { 0in }, emph(side.designation)) ]
    ]
  ],
  [
    #set par(leading: single-leading, first-line-indent: 0pt)
    #for l in right [ #inl(l) \ ]
  ],
)

/// Counsel group: names (the bar numbers are part of the names) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #n \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block of one signatory (HAW-SIG-001): the date line, the firm and the signer's line.
#let signature-block(sig) = block(width: 100%, breakable: false, {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  if "date" in sig { inl(sig.date) ; v(0.6em) }
  pad(left: sig-indent)[
    #for l in sig.firm_lines [ #l \ ]
    #v(0.6em)
    By /s/ #sig.signer \
    #for l in sig.lines [ #inl(l) \ ]
  ]
  v(1.2em)
})

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let haw-petition-for-writ(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none, number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced, same face and size as the text (HAW-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: text size, single-spaced (HAW-FORM-004).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): the cover starts 3 inches from the top ----
  page(numbering: none)[
    #v(flyleaf-top)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[S. C. No. #need(meta, "case_number")]
      #v(0.3in)
      #text(weight: "bold")[#need(meta, "court_title")]
    ]
    #v(0.4in)
    #caption-block(need(meta, "caption"), need(meta, "caption_right"))
    #v(0.6in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
  ]

  // ---- Flyleaf, continued: counsel and the judges (HAW-FLY-001). Printed "i", so the
  // flyleaf proper is the one unnumbered cover page (the exemplar leaves this page unnumbered). ----
  page(numbering: "i")[
    #counter(page).update(1)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      row-gutter: 1.4em,
      ..need(meta, "counsel").map(g => counsel-group(g)),
    )
    #if "judges" in meta [
      #v(1.4em)
      #for j in meta.judges [ #inl(j) \ ]
    ]
  ]

  // ---- Table of contents (generated from the body headings) ----
  if meta.at("toc", default: true) {
    page(numbering: "i")[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Body: the court caption again, the title, then the petition, numbered from 1 ----
  page(numbering: "1")[
    #counter(page).update(1)
    #set par(leading: body-leading, first-line-indent: (amount: para-indent, all: true))
    #align(center)[
      #text(weight: "bold")[S. C. No. #need(meta, "case_number")]
      #v(0.3in)
      #text(weight: "bold")[#need(meta, "court_title")]
    ]
    #v(0.4in)
    #caption-block(meta.at("body_caption", default: need(meta, "caption")), need(meta, "caption_right"))
    #v(0.6in)
    #align(center)[
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #cmarker.render(body, raw-typst: false, smart-punctuation: true)

    // ---- Date and signature blocks, after the conclusion (HAW-SIG-001) ----
    #v(0.3in)
    #for sig in need(meta, "signatures") { signature-block(sig) }
  ]
}
