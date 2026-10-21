// Missouri Court of Appeals (moctapp): petition for writ (petition-for-writ).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Missouri Supreme Court Rules 84.03(b), 84.04(d)(3), 84.24, as read at
// https://rulesofcivilprocedure.com/mo/rule-84-03/ on 2026-10-21; see ../../rules.md). No
// case-specific text, no coordinates measured off any filed paper, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
//
// A petition has no separate cover, table of contents or table of authorities: the caption and the
// title open the first page and the text follows, with the signature block after the conclusion.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 84.03(b)(3): no smaller than 13-point Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 84.03(b)(3): footnotes included.
#let body-leading = 1.03em                 // Rule 84.03(b)(2): spacing at least 1.5. Natural line 9.0 pt + leading = 22.4 pt = 1.5 x the 14.95 pt single line (1.15 em) of Times at 13 pt.
#let single-leading = 0.46em               // Caption, headings, quotations and footnotes may be single-spaced (Rule 84.03(b)(2)): 14.95 pt at 13 pt.
#let page-margin = 1in                     // Rule 84.03(b)(2): at least one inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moctapp-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("moctapp-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: the names, then the designation indented beneath them.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  block(width: 100%, side.names.map(inl).join(linebreak()))
  block(width: 100%, above: 0.4em, inset: (left: 0.5in), inl(side.designation))
}

/// Closing block: the closing words, then each block of lines (firm, signer, counsel), single-spaced.
#let signature-block(meta) = {
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "closing" in meta { pad(left: sig-indent, inl(meta.closing)) ; v(0.5em) }
    #for b in need(meta, "signature") {
      block(above: 0.9em, pad(left: sig-indent, for l in b [ #inl(l) \ ]))
    }
  ]
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let moctapp-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Rule 84.03(b)(1): all pages numbered consecutively, in Arabic numerals at the bottom.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)
  show heading: set text(size: type-size)

  // Level 1: a section ("I. STATEMENT OF FACTS"), bold, typed with its own numbering.
  // Level 2: sub-heading ("A. ..."), bold. Level 3: bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1in)
    #h(0.5in)#strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced (Rule 84.03(b)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.8em)
    #it.body
  ]
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption and title ----
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center)[
      #for l in need(meta, "court_line") [ #strong(upper(inl(l))) \ ]
    ]
    v(0.15in)
    grid(
      columns: (3.3in, 1fr),
      column-gutter: 0.25in,
      block(stroke: (right: 0.5pt), width: 100%, inset: (right: 0.1in))[
        #for (i, side) in need(meta, "caption").enumerate() [
          #if i > 0 [ v. \ ]
          #caption-side(side)
          #v(0.5em)
        ]
      ],
      [#v(2.2em) No. #if "case_number" in meta { meta.case_number } else { box(width: 1.6in, line(length: 100%, stroke: 0.5pt)) }],
    )
    v(0.1in)
    align(center, underline(strong(upper(inl(need(meta, "title"))))))
    v(0.15in)
  }

  // ---- Body. The signature block follows the conclusion; a certificate of service, when the
  // filing has one, starts on a new page.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# Certificate")
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  cmarker.render(main-part, raw-typst: false, smart-punctuation: true)

  v(0.4in)
  signature-block(meta)

  if certs.len() > 0 {
    pagebreak(weak: true)
    cmarker.render(certs, raw-typst: false, smart-punctuation: true)
  }
}
