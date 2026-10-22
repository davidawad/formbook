// Supreme Court of the State of Hawaii (haw): application for writ of certiorari (HRAP 40.1), the
// petition-for-review doc type.
//
// Content-agnostic. The parameters below are the ones HRAP 32 sets (HAW-FORM-001 page and margins,
// HAW-FORM-003 12 pt Times New Roman or its metric twin, HAW-FORM-004 footnotes and quotations in the
// text's font and size, HAW-FORM-005 double spacing with headings, quotations and footnotes single-spaced).
// The flyleaf rules are HAW-FLY-001 (contents) and HAW-FLY-002 (3-inch top margin on the cover page);
// the signature block is HAW-SIG-001. HAW-PFR-001 (12-page limit, order of sections) is not machine-checked:
// the template states no page limit and the section order comes from the markdown body.
// See ../../rules.md. No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample. The table of authorities is NOT generated (HAW-PFR-001 does not require one for an application).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HAW-FORM-003 (Times New Roman is deemed to comply); Liberation Serif is its metric twin.
#let type-size = 12pt                    // HAW-FORM-003: standard 12 point pica.
#let body-leading = 1.61em               // HAW-FORM-005: double spacing; a 27.6 pt line pitch, as the exemplar sets it.
#let single-leading = 0.46em            // headings, block quotations, footnotes, captions and counsel blocks: single spacing.
#let page-margin = 1in                   // HAW-FORM-001: not less than one inch all around.
#let flyleaf-top = 3in                   // HAW-FLY-002: a 3-inch top margin on the flyleaf.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                  // HAW-SIG-001: signature block set right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-petition-for-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-petition-for-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// The caption (HAW-FLY-001): one table row per line of the caption, a ")" column between the
/// parties and the case details. Each row is {left, right, indent}; indent is a left pad in inches.
#let caption-table(rows) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  table(
    columns: (3.1in, 0.3in, 3.1in),
    rows: 13.8pt,                  // one fixed row per caption line: the single-spaced pitch of 12 pt text
    stroke: none,
    inset: (x: 0pt, y: 0pt),
    align: (left, left, left),
    ..rows.map(r => (
      pad(left: r.at("indent", default: 0) * 1in, r.at("left", default: "")),
      [)],
      r.at("right", default: ""),
    )).flatten(),
  )
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #underline[/s/ #emph(sig.signer)] \
    #sig.at("typed", default: sig.signer)
    #if "lines" in sig {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let haw-petition-for-review(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 is a sub-heading (bold, left, hanging). Headings are single-spaced (HAW-FORM-005).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations (HAW-FORM-004: same font and size as the text): indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes (HAW-FORM-004): the text's size, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): unnumbered; 3-inch top margin ----
  page(numbering: none, margin: (top: flyleaf-top, bottom: page-margin, left: page-margin, right: page-margin))[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #need(meta, "case_number") \
    #v(0.3in)
    #align(center)[
      #text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF HAWAII] \
      #if "ica_case_number" in meta [ (NO. #meta.ica_case_number in the Intermediate Court of Appeals) ]
    ]
    #caption-table(need(meta, "caption"))
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      for g in need(meta, "counsel") { counsel-group(g) }
      if "phone" in meta [ #meta.phone ]
    }
  ]

  // ---- Table of contents (roman page numbers) ----
  if meta.at("toc", default: true) {
    pagebreak()
    set page(numbering: "i")
    counter(page).update(1)
    align(center, text(weight: "bold")[TABLE OF CONTENTS])
    v(0.5em)
    show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
    outline(title: none, depth: toc-depth, indent: 1.5em)
  }

  // ---- Body (arabic page numbers from 1) ----
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  if "body_title" in meta {
    align(center, text(weight: "bold", upper(inl(meta.body_title))))
  }
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the conclusion ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
