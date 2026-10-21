// Minnesota Supreme Court (minn): motion-brief.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Minnesota Rules of Civil Appellate Procedure, https://www.revisor.mn.gov/court_rules/ap/, Rules 120, 127, 132.02, 132.04;
// see ../../rules.md). No case-specific text, no coordinates measured off any filed paper, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 132.02 subd. 1 names no face; Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 132.02 subd. 1: all material in at least 13-point type.
#let double-leading = 1.61em               // Rule 132.02 subd. 1: typed material is double spaced (pitch = 2 x the 1.15 em single line).
#let single-leading = 0.46em               // single line (1.15 em): captions, block quotations, footnotes, signature blocks.
#let page-margin = 1in                     // Rule 132.02 subd. 1: typewritten matter not over 6-1/2 by 9-1/2 inches on 8-1/2 by 11 paper.
#let para-indent = 0.5in
#let sig-indent = 3in                      // signature block sits right of centre (style; the exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("minn-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("minn-motion: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: the names flush left, the designation indented on its own line.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0pt)
  [#for (i, n) in side.names.enumerate() [#if i > 0 [ \ ]#inl(n)]]
  if "designation" in side { pad(left: 1.0in, top: 0.2em, inl(side.designation)) }
}

/// Signature block: the firm lines, then "s/" and the typed name, then the lines below.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
    #v(0.6em)
    #if "signer" in sig [ #underline[#inl(sig.signer)] \ ]
    #for l in sig.at("lines", default: ()) { if l == "" { v(0.8em) } else [ #inl(l) \ ] }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let minn-motion(meta, body) = {
  set document(title: need(meta, "title"))
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Headings: bold, single-spaced, hanging; typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, strong(it.body))
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show list: set par(leading: single-leading, first-line-indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption page (Rule 132.02 subd. 2: court, title of the case, docket number, descriptive title) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #need(meta, "case_number") \
      #strong[#for l in need(meta, "court_lines") [ #inl(l) \ ]]
    ]
    #v(0.2in)
    #grid(columns: (1.45fr, 0.7fr), column-gutter: 0.2in,
      block(stroke: (right: 0.75pt), inset: (right: 0.15in, bottom: 0.2in))[
        #for (i, side) in need(meta, "caption").enumerate() [
          #if i > 0 { let j = side.at("joiner", default: "v."); if j != "" [ #v(0.2em) #j #v(0.2em) ] }
          #caption-side(side)
        ]
      ],
      align(center + horizon, strong(upper(inl(need(meta, "title"))))),
    )
  ]

  // ---- Body, then the signature block ----
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  cmarker.render(text + notes, raw-typst: false, smart-punctuation: true)

  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
    #for s in meta.at("signature_more", default: ()) [ #v(0.8em) #signature-block(s) ]
  ]
}
