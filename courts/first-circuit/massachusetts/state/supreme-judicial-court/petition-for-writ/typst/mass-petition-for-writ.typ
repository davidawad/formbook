// Massachusetts Supreme Judicial Court (mass): petition under G. L. c. 211, s. 3 (petition-for-writ).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Massachusetts Rules of Appellate Procedure, Rules 16, 20 and 21, as posted on mass.gov; see ../../rules.md,
// MA-FORM-*, MA-COVER-*, MA-SIG-001, MA-PET-004). No case-specific text, no coordinates measured off any
// filed petition, no forced line breaks. The markdown body is rendered by cmarker; the cover, counsel and
// signature come from the YAML frontmatter of the sample (keys listed in the frontmatter of usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 14pt                      // MRAP 20 (a) (4) (B): proportionally spaced font of 14 point or larger, footnotes included.
#let body-leading = 1.65em                 // MRAP 20 (a) (4) (C): double-spaced (not more than 3 lines per vertical inch, 27 lines per page).
#let single-leading = 0.46em               // MRAP 20 (a) (4) (C): headings, footnotes, indented quotations may be single-spaced; also the cover and counsel blocks (0.46 em on the cap-height line: a 1.15 em pitch).
#let page-margin = 1in                     // MRAP 20 (a) (4) (A): top, bottom, left and right margins at least 1 inch.
#let para-indent = 0.5in                   // style: first-line paragraph indent.
#let sig-indent = 3.2in                    // style: the signature block starts right of centre.
#let court-name = "COMMONWEALTH OF MASSACHUSETTS"  // MRAP 20 (b) (2) (A) and 20 (a) (6) (B) (i): name of the court (fixed for this court).
#let court-division = "Supreme Judicial Court"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mass-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A list of lines set as a stack: each entry is one line of the block (no forced breaks), single-spaced.
#let lines-stack(items, style: none) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(i => if style == none { inl(i) } else { style(inl(i)) }),
)

/// One caption side: centred names, then the designation.
#let caption-side(side) = align(center)[
  #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  #lines-stack(side.names)
  #v(0.4em)
  #emph(side.designation)
]

/// One counsel group on the cover: names (one per line), then the office and contact lines, then the role.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  lines-stack(g.names)
  v(single-leading)
  lines-stack(g.lines)
  if "for" in g [ #v(single-leading) #emph(inl(g.at("for"))) ]
}

/// Two-column grid of counsel groups; the cover and the signature block both use it.
#let counsel-grid(groups, render) = grid(
  columns: (1fr, 1fr),
  column-gutter: 0.3in,
  row-gutter: 0.2in,
  ..groups.map(render),
)

/// Signature block (MRAP 16 (a) (12), 20 (b) (2) (B)): "Respectfully submitted," then one block per signer,
/// the signature line and the printed name, the signer's BBO number, office and contact lines, and the date.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #lines-stack(sig.at("intro", default: ()))
    #v(0.8em)
    #counsel-grid(sig.blocks, b => {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      if "signer" in b { lines-stack(("/s/ " + b.signer,)); v(0.5em) }
      lines-stack(b.at("names", default: ()))
      v(single-leading)
      lines-stack(b.at("lines", default: ()))
      if "for" in b [ #v(single-leading) #emph(inl(b.at("for"))) ]
    })
    #if "date" in meta [ #v(1em) Dated: #inl(meta.date) ]
  ]
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mass-petition-for-writ(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // MRAP 20 (a) (4) (A): page numbers in the margin; the cover is page 1 and numbering runs to the last page.
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

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold); level 2 is a point heading
  // (bold, hanging); level 3 is a subpoint (bold italic); level 4 is an enumerated subpoint (italic).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
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
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(style: "italic", it.body)
  ]

  // Block quotations: indented on both sides, single-spaced (MRAP 20 (a) (4) (C)).
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

  // ---- Cover (MRAP 20 (b) (2) (A), 20 (a) (6) (B)): court, county and docket, parties, title, counsel ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #stack(dir: ttb, spacing: single-leading, text(weight: "bold")[#court-name], [#court-division])
    ]
    #v(0.2in)
    #grid(
      columns: (1fr, 1fr),
      [#inl(need(meta, "county"))], align(right)[No. #need(meta, "case_number")],
    )
    #v(0.2in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(need(meta, "caption").at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", inl(need(meta, "brief_title")))
    ]
    #v(0.2in)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      counsel-grid(need(meta, "counsel"), counsel-group)
    }
  ]

  // ---- Body: the petition as filed (MRAP 20 (a) (4) (C) double spacing) ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block (MRAP 16 (a) (12), 20 (b) (2) (B)) ----
  v(0.4em)
  signature-block(meta)
}
