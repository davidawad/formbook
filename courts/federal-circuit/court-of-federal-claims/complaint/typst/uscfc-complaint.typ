// United States Court of Federal Claims: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CFC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // Vendored in /fonts; the only face a render may use.
#let type-size = 12pt                      // CFC-FORM-002: text and footnotes no smaller than 12 point.
#let page-margin = 1in                     // CFC-FORM-003: margins not less than 1 inch on each side.
#let para-indent = 0.5in                   // Style: first-line indent of numbered paragraphs.
#let block-indent = 0.5in                  // Style: lists (prayer for relief) and quoted material.
#let caption-gutter = 0.25in               // Style: space between the two caption columns.
#let caption-left = 3.4in                  // Style: width of the party block in the caption.
#let sig-left = 3.25in                     // Style: left edge of the signature block.

// CFC-FORM-004: double spaced text. Pitch = 2 x a single line (1.15 em, the Word convention).
// Typst adds `leading` to the face's own line box, which is 0.65 em for EB Garamond
// (measured: a 12 pt line box is 7.8 pt); so leading = pitch - 0.65 em.
#let face-line-box = 0.65em
#let single-line = 1.15em
#let double-line = 2.3em
#let double-leading = double-line - face-line-box
#let single-leading = single-line - face-line-box   // quotations, footnotes, caption, counsel block.


// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("uscfc-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("uscfc-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (RCFC 10(a), 7(a) designation, 5.5(h) bid protest, 5.5(g) judge not required)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading)
  // RCFC 10(a): the caption has the court's name, a title, a file number.
  align(center, text(weight: "bold", upper(need(meta, "court"))))
  // RCFC 5.5(h): "Bid Protest" directly below the name of the court, in every filing.
  if meta.at("bid_protest", default: false) {
    align(center, text(weight: "bold", "Bid Protest"))
  }
  v(1.5em)

  // Left: the parties, each side's names then its designation (RCFC 7(a)).
  // Right: the file number, blank for the clerk where none is assigned yet.
  let sides = need(meta, "caption")
  let party-block = {
    for (i, side) in sides.enumerate() {
      if i > 0 {
        v(single-line)
        align(center, [v.])
        v(single-line)
      }
      for name in side.names { [#inl(name) \ ] }
      v(single-line)
      pad(left: 1.5in, [#inl(side.designation)])
    }
  }
  grid(
    columns: (caption-left, 1fr),
    gutter: caption-gutter,
    block(
      width: 100%,
      inset: (right: caption-gutter, bottom: single-line * 0.5),
      stroke: (right: 0.7pt + black, bottom: 0.7pt + black),
      party-block,
    ),
    align(bottom + left, pad(left: 0.2in, bottom: single-line * 0.5)[
      Case No. #if meta.at("file_number", default: none) != none [
        #meta.file_number
      ] else [
        #box(width: 1.2in, stroke: (bottom: 0.5pt + black))
      ]
      \
      Judge #box(width: 1.2in, stroke: (bottom: 0.5pt + black))
    ]),
  )
  v(2em)
  align(center, text(weight: "bold", upper(need(meta, "title"))))
  v(1em)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// (RCFC 5.5(d)(1) original signature; 5.5(e) date; 5.5(f) e-mail and telephone below
// the signature line; 5.5(g) no judge name is required in a complaint.)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  set par(leading: single-leading, justify: false)
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, {
    v(double-line)
    grid(
      columns: (1fr, sig-left - 1in),
      [Dated: #need(meta, "date")],
      [
        Respectfully submitted,
        #v(double-line)
        #box(width: 100%, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[/s/ #need(sig, "signer")]
        \
        #need(sig, "signer")
        #for line in sig.at("lines", default: ()) { [\ #inl(line)] }
        \
        Telephone: #need(sig, "phone")
        \
        E-mail: #need(sig, "email")
      ],
    )
  })
}

#let certificate-of-service(meta) = {
  // CFC-FORM-004: the certificate text is text, so it stays double spaced (body leading).
  pagebreak(weak: true)
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(double-line)
  par(first-line-indent: para-indent)[
    I hereby certify that on #need(meta, "date"), I caused a copy of the #lower(need(meta, "title")) to be served on all parties via the Court's electronic case filing system.
  ]
  v(double-line)
  // Same column as the signature block of the complaint.
  grid(columns: (1fr, sig-left - 1in), [], block(width: 100%, breakable: false)[
    #set par(justify: false, leading: single-leading)
    #box(width: 100%, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[/s/ #need(need(meta, "signature"), "signer")]
    \
    #need(need(meta, "signature"), "signer")
  ])
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let uscfc-complaint(meta, body) = {
  set document(title: need(meta, "title") + " (" + need(meta, "court") + ")")

  set page(
    paper: "us-letter",
    margin: page-margin,                   // CFC-FORM-003
    numbering: "1",                        // CFC-FORM-005: every page numbered, bottom centre.
    number-align: center + bottom,
  )

  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(
    justify: true,
    leading: double-leading,               // CFC-FORM-004: body is double spaced.
    spacing: double-leading,
    first-line-indent: (amount: para-indent, all: true),
  )

  // Headings are centred and bold (section), or bold and left-aligned (sub-section).
  // Neither is numbered: the complaint's own paragraph numbers are the author's.
  // Sticky: a heading never ends a page; it moves with the paragraph that follows it.
  show heading.where(level: 2): it => block(sticky: true, width: 100%, {
    set text(size: type-size)              // headings at the body size, as the title.
    set par(leading: single-leading, first-line-indent: 0pt)
    v(single-line)
    align(center, text(weight: "bold", upper(it.body)))
    v(single-line)
  })
  show heading.where(level: 3): it => block(sticky: true, width: 100%, {
    set text(size: type-size)              // headings at the body size, as the title.
    set par(leading: single-leading, first-line-indent: 0pt)
    v(single-line)
    text(weight: "bold", it.body)
    v(single-line)
  })

  // Prayer for relief: lettered and roman items, hanging at the block indent.
  set list(marker: none, indent: block-indent, body-indent: 0.5em, spacing: double-leading)
  show list: set par(first-line-indent: 0pt)

  // Quoted material and footnotes are single spaced (CFC-FORM-004) and at least 12 point.
  show quote.where(block: true): it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(x: block-indent, it.body)
  }
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    it
  }

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  if meta.at("certificate_of_service", default: false) {
    certificate-of-service(meta)
  }
}
