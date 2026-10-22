// Supreme Court of Kansas (kan): petition for review (petition-for-review). The same template
// shape serves the other Kansas Supreme Court doc types in this folder family; only the header
// comment and the panic names differ.
//
// Content-agnostic. Every number is a named parameter below. No case-specific text, no coordinates
// measured off any filed paper, no forced line breaks. The court's rules have not been retrieved,
// so the layout uses the default 12-point body and 1-inch margins; no rule is cited here.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample
// (schema: README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman is the standard face (docs/FONTS.md); Liberation Serif is its metric-compatible substitute.
#let type-size = 12pt                     // Default body size (rules not retrieved).
#let caption-size = 12pt
#let body-leading = 1.1em                 // Double-spaced body text (a convention the exemplar shows).
#let single-leading = 0.2em               // Quotations, headings, footnotes and the cover block are single-spaced.
#let top-margin = 1in                     // Default one inch on all sides (rules not retrieved).
#let side-margin = 1in
#let bottom-margin = 1in                  // Page numbers sit in this margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                   // Signature block starts right of centre.
#let court-name = "IN THE SUPREME COURT OF THE STATE OF KANSAS"
#let docket-width = 2.2in                 // Right column of the cover: docket number.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kan-petition-for-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("kan-petition-for-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Signature block: "s/" line, then the signer's firm and contact lines.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)]
    #for l in sig.at("lines", default: ()) [ #linebreak() #inl(l) ]
  ])
}

// ---------------------------------------------------------------------------
// Cover
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.5em)
  set text(size: caption-size)
  align(center, text(weight: "bold", court-name))
  v(0.8em)
  grid(
    columns: (1fr, docket-width),
    column-gutter: 0.3in,
    [
      #for p in need(meta, "parties") {
        for n in p.at("names", default: ()) [ #inl(n) \ ]
        if "designation" in p [ #emph(inl(p.designation)) \ ]
        v(0.4em)
      }
    ],
    [
      #if "case_number" in meta [ #inl(meta.case_number) ]
    ],
  )
  v(0.8em)
  if "cover_lines" in meta {
    for l in meta.cover_lines [ #align(center, inl(l)) \ ]
    v(0.8em)
  }
  if "lower_court" in meta {
    for l in meta.lower_court [ #inl(l) \ ]
    v(0.8em)
  }
  // Counsel blocks sit in the right half of the cover.
  block(width: 100%, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #for c in need(meta, "counsel") {
      block(breakable: false, [
        #for l in c.lines [ #inl(l) \ ]
      ])
      v(0.6em)
    }
  ])
  line(length: 100%, stroke: 0.75pt)
  align(center, block(above: 0.8em, below: 0.8em)[
    #text(weight: "bold", size: 14pt, upper(inl(need(meta, "brief_title"))))
  ])
  line(length: 100%, stroke: 0.75pt)
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let kan-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Pages: the cover is unnumbered, the table of contents is roman, the body is arabic from 1.
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    numbering: none,
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: 0em, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 is a point heading (bold, left); level 3 is a sub-point (bold italic, left).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the body size, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size, bottom-edge: -3pt)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Cover (unnumbered) ----
  page[#cover(meta)]

  // ---- Table of contents (roman numerals) ----
  if meta.at("toc", default: true) {
    page(numbering: "i")[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Body (arabic from 1) ----
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block after the last paragraph ----
  if "signature" in meta {
    v(0.3in)
    block(width: 100%, breakable: false)[
      #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
      #v(0.4em)
      #signature-block(meta.signature)
    ]
  }

  // ---- Certificate of service (last page, when the filing has one) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    // A paragraph string with "\n" in it is an address block: each line on its own line, not indented.
    for p in svc.at("paragraphs", default: ()) {
      let lines = p.split("\n")
      if lines.len() > 1 {
        block(breakable: false, inset: (left: 0.5in), above: 0.6em)[
          #set par(leading: single-leading, first-line-indent: 0pt)
          #for l in lines [ #inl(l) \ ]
        ]
      } else {
        par(first-line-indent: (amount: para-indent, all: true), inl(p))
      }
    }
    // Served counsel: one block per recipient, each a list of lines.
    for group in svc.at("served", default: ()) {
      block(breakable: false, inset: (left: 0.5in), above: 0.6em)[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #for l in group [ #inl(l) \ ]
      ]
    }
    v(0.4em)
    if "signature" in svc { signature-block(svc.signature) }
  }
}
