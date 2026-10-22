// Massachusetts Supreme Judicial Court (mass): motion for reconsideration or modification of a decision
// (petition for rehearing). Requirement IDs (MA-...) refer to ../../rules.md.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Massachusetts Rules of Appellate Procedure, as posted on mass.gov; see ../../rules.md). No case-specific
// text, no coordinates measured off any filed document, no forced line breaks. The markdown body is rendered
// by cmarker; the metadata is the YAML frontmatter of the INPUT (keys listed in the usage/INPUT-*.md header).
//
// A motion has no separate cover: the caption and the title open page 1 (MRAP 20 (b) (2) (A)), and the
// text follows on that page. Page numbers run from page 1 to the last page.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 14pt                      // MRAP 20 (a) (4) (B): proportionally spaced font of 14 point or larger, footnotes included (the court's standard; MRAP 20 (b) (2) (A) sets 12 point as the floor for a motion).
#let body-leading = 22.2pt                 // MRAP 20 (a) (4) (C): double-spaced, not more than 27 lines per page (a pitch of at least 24 pt). This extra leading gives a pitch of about 32 pt on this face, the pitch the filed exemplar sets (about 20 lines per page).
#let single-leading = 0.3em                // MRAP 20 (a) (4) (C): headings, footnotes, indented quotations and visual aids may be single-spaced.
#let page-margin = 1in                     // MRAP 20 (b) (2) (A): side and top margins at least 1 inch; MRAP 20 (a) (4) (A): all four margins at least 1 inch.
#let para-indent = 0.5in                   // style: first-line paragraph indent.
#let court-name = "COMMONWEALTH OF MASSACHUSETTS"  // MRAP 20 (b) (2) (A): the court name on the first page (fixed for this court).
#let court-division = "Supreme Judicial Court"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mass-petition-for-rehearing: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation (for example "Petitioners,").
#let caption-side(side) = align(center)[
  #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  #for n in side.names [ #inl(n) \ ]
  #emph(side.designation)
]

/// One counsel block: an optional signature line (for example "/s/ Name") then the lines beneath it.
#let counsel-block(b) = block(width: 100%, breakable: false)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #if "sig" in b [ #inl(b.sig) \ ]
  #for l in b.at("lines", default: ()) [ #inl(l) \ ]
]

/// The signature block (MRAP 20 (b) (2) (B)): an introduction ("Respectfully submitted,"), then the
/// counsel blocks in the columns given by the frontmatter.
#let signature-block(sig) = block(width: 100%, breakable: false)[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  #if "intro" in sig [ #sig.intro \ ]
  #v(1.0em)
  #grid(
    columns: (1fr,) * sig.columns.len(),
    column-gutter: 0.4in,
    ..sig.columns.map(col => stack(
      dir: ttb,
      spacing: 1.0em,
      ..col.map(b => counsel-block(b)),
    )),
  )
]

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mass-petition-for-rehearing(meta, body) = {
  set document(title: need(meta, "title"))
  // MRAP 20 (a) (4) (A): page numbers in the margin, from page 1 (the first page carries the caption).
  // The top and bottom margins are 1 inch plus 4 pt: the raised figure of a footnote reference on the first line
  // of a page then stays inside the margin (MRAP 20 (a) (4) (A): margins at least 1 inch).
  set page(
    paper: "us-letter",
    margin: (top: page-margin + 4pt, bottom: page-margin + 4pt, left: page-margin, right: page-margin),
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Headings: level 1 centred bold (Background, Discussion); level 2 and 3 bold, hanging, left.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.0em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.0em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 0.8em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced (MRAP 20 (a) (4) (C) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same 14 point face as the text, single-spaced (MRAP 20 (a) (4) (B), (C)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption and title (MRAP 20 (b) (2) (A)) ----
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center)[
      #text(weight: "bold")[#court-name] \
      #court-division
    ]
    v(0.8em)
    grid(
      columns: (1fr, auto),
      align(left)[#need(meta, "venue")],
      align(right)[No. #need(meta, "case_number")],
    )
    v(0.6em)
    let sides = need(meta, "caption")
    caption-side(sides.at(0))
    v(0.1in)
    align(center)[v.]
    v(0.1in)
    caption-side(sides.at(1))
    v(0.3em)
    line(length: 100%, stroke: 0.5pt)
    v(0.3em)
    align(center)[#text(weight: "bold", upper(inl(need(meta, "title"))))]
    v(0.3em)
    line(length: 100%, stroke: 0.5pt)
    v(0.6em)
  }

  // ---- Body ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block (MRAP 20 (b) (2) (B)) and date of signing ----
  v(0.8em)
  signature-block(need(meta, "signature"))
  if "date" in meta {
    v(0.8em)
    set par(leading: single-leading, first-line-indent: 0pt)
    inl(meta.date)
  }

  // ---- Certificate of compliance with the length rule (MRAP 27 (d)), when the filing supplies one ----
  if "compliance" in meta {
    let c = meta.compliance
    v(1.2em)
    block(breakable: false)[
      #align(center, text(weight: "bold")[CERTIFICATE OF COMPLIANCE])
      #v(0.6em)
      #for p in c.paragraphs { par(inl(p)) }
    ]
    if "signature" in c { counsel-block(c.signature) }
  }
}
