// M.D. Ala. brief in support of a Rule 12(b) motion: content-agnostic. Everything case-specific comes
// from the sample's frontmatter; everything here is a rule (FRCP 7(b), FRCP 10(a), FRCP 11(a), FRCP 5(b)
// and (d), LR 5.6) or a named parameter below. Entry point: main.typ calls almd-motion-brief(meta, body).

#import "@preview/cmarker:0.1.10"

// ---- Parameters -------------------------------------------------------------------------------
// Rules: FRCP 10(a) caption, FRCP 11(a) signature block, FRCP 5(d)(1)(B) certificate (required only for
// service not made through the electronic-filing system; included as the exemplars print it), LR 5.6
// (8-1/2 x 11 white paper, double-spaced except quoted material, every page numbered consecutively).
// The Middle District's local rules set no typeface, size, margin or page limit for briefs; the values
// below follow the filed exemplars (tier 2, convention: 14 pt, double-spaced, one-inch margins).
#let page-margin = 1in
#let type-size = 14pt
#let font-name = ("Times New Roman", "Liberation Serif")       // Times New Roman substitute, the default per docs/FONTS.md
#let body-leading = 1.65em                // line pitch 32 pt at 14 pt: double-spaced (LR 5.6)
#let single-leading = 0.495em              // caption, block quotations, signature, service list
#let para-indent = 0.5in

// Caption grid: left (party names), ")" column, right (case number, jury demand).
#let cap-left = 3.4in
#let cap-paren = 0.15in
#let cap-right = 2.95in

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The court title: each line of `meta.court`, centered and bold, as the exemplars print it.
#let court-title(meta) = {
  set align(center)
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
  for line in meta.court { [#strong[#line] \ ] }
}

/// FRCP 10(a) caption: parties on the left with a ")" column, the case number and jury demand on the
/// right. Each side is its names (one line each) and its designation, and the sides are separated by
/// "v.". The row layout is the only thing measured here; no line is broken by hand.
#let caption(meta) = {
  let rows = ()
  let sep = none
  let defendant-row = none
  for (i, side) in meta.caption.sides.enumerate() {
    if i > 0 {
      sep = rows.len()
      rows.push(([#h(0.5in)v.], ""))
      defendant-row = rows.len()
    }
    for name in side.names { rows.push((name, "")) }
    rows.push(([#h(0.5in)#side.designation], ""))
  }
  let label = meta.caption.at("case_label", default: "Civil Action No.")
  let case-no = meta.caption.at("case_number", default: "")
  let cells = ()
  for (k, r) in rows.enumerate() {
    let right = ""
    if k == sep { right = [#label #case-no] }
    if meta.at("jury_demand", default: false) and k == defendant-row { right = [JURY DEMAND] }
    cells += (r.at(0), [)], right)
  }
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
  grid(
    columns: (cap-left, cap-paren, cap-right),
    row-gutter: single-leading,
    ..cells,
  )
}

/// The signature block (FRCP 11(a): signer's name, address, e-mail and telephone). Each group is a
/// signer: `signer` is the name, `esign` (default true) prints the "/s/" electronic signature,
/// `note` is printed after the name, `lines` are the contact and role lines.
#let signature-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
  for g in meta.signature {
    let sig = if g.at("esign", default: true) [/s/ #g.signer] else [#g.signer]
    let note = g.at("note", default: none)
    block(breakable: false, above: body-leading, below: 0pt)[
      #sig#if note != none [ (#note)]\
      #for line in g.lines [#line \ ]
    ]
  }
}

/// The "OF COUNSEL" block, single-spaced, after the signature.
#let of-counsel(meta) = {
  let lines = meta.at("of_counsel", default: ())
  if lines.len() > 0 {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    block(breakable: false, above: body-leading)[
      #for line in lines [#line \ ]
    ]
  }
}

/// The certificate of service: heading, the certificate text, the list of those served, and the
/// signature of the person certifying.
#let certificate(meta) = {
  let cert = meta.at("certificate", default: none)
  // One unbreakable block: the heading, text, service list and signature move to the next page together.
  if cert != none {
    block(breakable: false, above: body-leading)[
      #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
      #align(center)[#strong(cert.heading)]
      #v(body-leading)
      #set par(first-line-indent: para-indent, leading: body-leading, spacing: 0pt)
      #cert.text
      #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
      #v(body-leading)
      #for line in cert.served [#line \ ]
      #v(body-leading)
      /s/ #cert.signer \
      #for line in cert.lines [#line \ ]
    ]
  }
}

#let almd-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-name, size: type-size, fill: black, lang: "en", hyphenate: false)
  set par(
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true),
    justify: false,
  )

  // Headings: level 1 is centered and bold (INTRODUCTION, ARGUMENT, CONCLUSION). Levels 2 and 3 are
  // flush left, bold, with a hanging indent so a wrapped heading lines up after its number ("I.", "A.").
  // Every heading is kept with the text that follows it.
  show heading.where(level: 1): it => block(sticky: true, above: body-leading, below: body-leading)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    #align(center)[#strong(it.body)]
  ]
  show heading.where(level: 2): it => block(sticky: true, above: body-leading, below: body-leading)[
    #set par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, spacing: 0pt)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(sticky: true, above: body-leading, below: body-leading)[
    #set par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, spacing: 0pt)
    #strong(it.body)
  ]

  // Block quotations are single-spaced and indented on both sides (quoted material, LR 5.6).
  show quote.where(block: true): it => block(
    sticky: false,
    above: body-leading,
    below: body-leading,
    inset: (left: 0.5in, right: 0.5in),
  )[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    #it.body
  ]

  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  block(sticky: true)[
    #set align(center)
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    #strong(meta.title)
  ]
  v(body-leading)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // The date line, then the signature, the "OF COUNSEL" block and the certificate, in the exemplar's order.
  let date-line = meta.at("signature_date", default: none)
  if date-line != none {
    block(breakable: false, above: body-leading)[#date-line]
  }
  signature-block(meta)
  of-counsel(meta)
  certificate(meta)
}
