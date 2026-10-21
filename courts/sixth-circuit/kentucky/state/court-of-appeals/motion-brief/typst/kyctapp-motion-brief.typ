// Kentucky Court of Appeals (kyctapp): a motion with its argument (RAP 7, RAP 21; RAP 5 form).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited beside it:
// Kentucky Rules of Appellate Procedure, created by Supreme Court of Kentucky Order 2022-49, effective
// January 1, 2023 (Internet Archive capture of the court-posted order; see ../../rules.md). No case text, no
// coordinates measured off a filed motion, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata is the YAML frontmatter of the sample (fields documented in ../README.md).
//
// Page layout: letter, 1 in on every side (RAP 5 (B) (4)); text and footnotes 12 pt, double spaced. Pages are
// numbered in Arabic numerals from the first page (no cover, no front matter).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // RAP 31 (A) (2) (recommended readable serif); Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 12pt                                       // RAP 5 (B) (4): black type no smaller than 12 point; footnotes too.
#let body-leading = 1.2em                                   // RAP 5 (B) (4): at least double space between lines (pitch about 2.35 em, about 28 pt).
#let single-leading = 0.2em                                 // Caption, title, signature, certificate and block quotations: single spaced.
#let para-indent = 0.5in
#let sig-indent = 3.0in                                     // signature block starts right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyctapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("kyctapp-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Caption and title
// ---------------------------------------------------------------------------

#let caption-lines(names) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  for n in names [ #inl(n) \ ]
}

#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  align(center)[
    #text(weight: "bold")[COMMONWEALTH OF KENTUCKY] \
    #text(weight: "bold")[COURT OF APPEALS] \
    #v(0.1in)
    CASE NO. #need(meta, "case_number")
  ]
  v(0.3in)
  let sides = need(meta, "caption")
  // One row per side; a side may carry `connector` (for example "V." or "and") printed on the row above it.
  let cells = ()
  for (i, s) in sides.enumerate() {
    if i > 0 {
      cells += ([#s.at("connector", default: "V.")], [], [])
    }
    cells += (
      [#caption-lines(s.names)],
      if i == 0 {
        [#align(center, {
          set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
          for l in meta.at("appeal_from", default: ()) [ #inl(l) \ ]
        })]
      } else { [] },
      [#align(right, text(weight: "bold")[#s.designation])],
    )
  }
  grid(
    columns: (2.5in, 2.5in, 1.0in),
    gutter: 0pt,
    row-gutter: 0.16in,
    ..cells,
  )
  v(0.25in)
  line(length: 100%, stroke: 0.75pt)
  v(0.12in)
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #text(weight: "bold")[#inl(need(meta, "brief_title"))]
  ]
  v(0.12in)
  line(length: 100%, stroke: 0.75pt)
  v(0.25in)
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let kyctapp-motion(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(
    paper: "us-letter",
    margin: 1in,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.1em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 0.9em, below: 0.6em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(style: "italic", it.body)
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.6em)
    #it.body
  ]
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  caption(meta)

  // ---- Body ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #pad(left: sig-indent)[
      Respectfully submitted,
      #v(0.6em)
      #for (i, s) in need(meta, "signature").signers.enumerate() {
        if i > 0 { v(0.7em) }
        if s.at("conformed", default: false) {
          underline[/s/ #emph(s.name)]
          linebreak()
        }
        s.name
        for l in s.at("lines", default: ()) {
          linebreak()
          inl(l)
        }
        linebreak()
      }
    ]
  ]

  // ---- Certificate of service (RAP 5 (A)) ----
  if "service" in meta {
    let svc = meta.service
    v(0.4in)
    block(width: 100%, breakable: false)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
      #v(0.3in)
      #set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))
      #for p in svc.at("paragraphs", default: ()) { inl(p) }
    ]
    for r in svc.at("recipients", default: ()) {
      block(above: 0.6em, below: 0.6em, breakable: false, pad(left: 0.5in, {
        set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        for l in r [ #inl(l) \ ]
      }))
    }
    v(0.4em)
    pad(left: sig-indent)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #if svc.signer.at("conformed", default: false) [ #underline[/s/ #emph(svc.signer.name)] \ ]
      #svc.signer.name
    ]
  }
}
