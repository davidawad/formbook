// Arkansas Court of Appeals (arkctapp): motion with memorandum of authorities (motion-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Rules of the Supreme Court and Court of Appeals of the State of Arkansas, current
// through December 15, 2025, https://opinions.arcourts.gov/ark/cr/en/1871/1/document.do; see
// ../../rules.md). No case-specific text, no coordinates measured off any filed paper, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter
// of the sample (schema: ../README.md, "Markdown contract").
//
// A motion has no separate cover, table of contents or table of authorities: the caption and the
// title open the first page and the motion text follows (Rule 2-1(a), (e)).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 4-1(d): serif, proportional; no face is named. Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 14pt                      // Rule 4-1(d): not less than 14 points.
#let double-leading = 1.61em               // Rule 4-1(b): double-spaced. Measured pitch = 9.7 pt natural + leading = 32.2 pt, twice the 16.1 pt single line (1.15 em) of Times at 14 pt.
#let single-leading = 0.46em               // Quoted material and the caption block are single-spaced: 16.1 pt at 14 pt.
#let page-margin = 1in                     // Rule 4-1(c): not less than one inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style; exemplar does the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arkctapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("arkctapp-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: names flush left, the designation flush right on the same line.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  align(right, strong(inl(side.designation)))
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

#let arkctapp-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Rule 4-1(e): paginated consecutively, the first page is page one.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: the memorandum title, centred, capitals, bold. Level 2: centred bold sub-heading.
  // Level 3: left, bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced (Rule 4-1(b)).
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
      #strong(upper(need(meta, "court_line")))
    ]
    v(0.15in)
    for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #align(center)[v.] ]
      #caption-side(side)
      #v(0.1em)
    ]
    if "case_number" in meta { align(center, strong[CASE NO. #meta.case_number]) }
    v(0.1in)
    align(center)[
      #for l in meta.at("proceeding", default: ()) [ #strong(inl(l)) \ ]
    ]
    v(0.15in)
    align(center, strong(upper(inl(need(meta, "title")))))
    v(0.15in)
  }

  // ---- Body. The closing block follows the conclusion; the certificate of service starts on a
  // new page (as filed).
  let cut = body.position("\n# Certificate")
  let main-part = if cut == none { body } else { body.slice(0, cut) }
  let certs = if cut == none { "" } else { body.slice(cut) }
  cmarker.render(main-part, raw-typst: false, smart-punctuation: true)

  v(0.4in)
  signature-block(meta)

  if certs.len() > 0 {
    pagebreak(weak: true)
    cmarker.render(certs, raw-typst: false, smart-punctuation: true)
  }
}
