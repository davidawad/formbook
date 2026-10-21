// Ohio Court of Appeals (ohioctapp): petition for writ (petition-for-writ).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it. No App.R. rule prescribes a petition for writ (App.R. 1(A) limits the rules to appeals),
// so the form applies App.R. 19 (A) and (B) by analogy, as marked in ../../rules.md
// (OHIOCTAPP-WRIT-001, OHIOCTAPP-WRIT-002, kind C). No page or word limit is set. No case-specific
// text, no coordinates measured off any filed paper, no forced line breaks. The markdown body is
// rendered by cmarker; the metadata is the YAML frontmatter of the sample.
//
// A petition has no separate cover, table of contents or table of authorities: the caption and the
// title open the first page and the text follows, with the signature block after the conclusion.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // OHIOCTAPP-FORM-004 (kind C): Times New Roman declared; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // OHIOCTAPP-FORM-002 (App.R. 19 (A)): at least twelve-point type, footnotes and captions included.
#let body-leading = 1.61em                 // OHIOCTAPP-FORM-003 (App.R. 19 (A)): double spaced. Typst's natural line for this face is 0.69 em, so the pitch is 2.30 em, twice the 1.15 em single pitch of Times.
#let single-leading = 0.46em               // Quotations, footnotes, caption and headings are single spaced (OHIOCTAPP-FORM-003): pitch 1.15 em.
#let page-margin = 1in                     // OHIOCTAPP-FORM-001 (App.R. 19 (A)): at least one inch at each side and top and bottom.
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
  if m == none { panic("ohioctapp-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ohioctapp-petition-for-writ: missing required metadata field `" + key + "`") }
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

#let ohioctapp-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Page numbers at the bottom centre, consecutively (conventional; not mandated by App.R. 19).
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)
  show heading: set text(size: type-size)

  // Level 1: a section ("PRELIMINARY STATEMENT"), bold, centred.
  // Level 2: sub-heading ("A. ..."), bold. Level 3: bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1in)
    #h(0.5in)#strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single spaced (OHIOCTAPP-FORM-003: quoted matter).
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
          #if i > 0 [ #v(0.5em) #block(width: 100%, inset: (left: 0.5in))[-vs-] #v(0.5em) ]
          #caption-side(side)
          #v(0.5em)
        ]
      ],
      [#v(2.2em) Case No. #if "case_number" in meta { meta.case_number } else { box(width: 1.6in, line(length: 100%, stroke: 0.5pt)) } \ #if "proceeding" in meta { for l in meta.proceeding [ #inl(l) \ ] }],
    )
    v(0.3in)
    align(center, underline(strong(upper(inl(need(meta, "title"))))))
    v(0.15in)
  }

  // ---- Body. The signature block follows the conclusion; a certificate of service, when the
  // filing has one, starts on a new page.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let trailing = ("\n# Certificate", "\n# VERIFICATION", "\n# INDEX OF EXHIBITS")
  let found = trailing.map(m => text.position(m)).filter(p => p != none)
  let cut = if found.len() == 0 { none } else { calc.min(..found) }
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
