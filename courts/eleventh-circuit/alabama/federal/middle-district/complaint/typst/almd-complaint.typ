// M.D. Ala. complaint: content-agnostic. Everything case-specific comes from the sample's frontmatter;
// everything here is either a rule (FRCP 10, FRCP 11, LR 5.6) or a named parameter below.
// Entry point: main.typ calls almd-complaint(meta, body).

#import "@preview/cmarker:0.1.10"

// ---- Parameters -------------------------------------------------------------------------------
// Rules: FRCP 10(a) caption, FRCP 10(b) numbered paragraphs, FRCP 11(a) signature block, LR 5.6
// (8-1/2 x 11 white paper, double-spaced except quoted material, every page numbered consecutively).
// The Middle District's local rules set no typeface, size or margin; the values below follow the
// filed exemplars (tier 2, convention: 14 pt, double-spaced, one-inch margins).
#let page-margin = 1in
#let type-size = 14pt
#let font-name = "EB Garamond"            // vendored in fonts/eb-garamond; the only font typst may see
#let body-leading = 1.65em                // line pitch 32 pt at 14 pt: double-spaced (LR 5.6); tuned against the exemplar pitch
#let single-leading = 0.5em               // caption, signature, service block: one line pitch of about 16 pt at 14 pt
#let para-indent = 0.5in

// Caption grid: left (party names), ")" column, right (case number, jury demand).
#let cap-left = 3.4in
#let cap-paren = 0.15in
#let cap-right = 2.95in

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The court title: each line of `meta.court`, centered, as the exemplars print it.
#let court-title(meta) = {
  set align(center)
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
  for line in meta.court { [#strong[#line] \ ] }
}

/// FRCP 10(a) caption: parties on the left with a ")" column, the file number and the jury
/// demand on the right. Each side is its names (one line each) and its designation; a blank row
/// separates the sides. Row layout is the only thing measured here; no line is broken by hand.
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
  let case-no = meta.at("case_number", default: "")
  let case-text = if case-no == "" { "" } else { case-no }
  let cells = ()
  for (k, r) in rows.enumerate() {
    let right = ""
    if k == sep { right = [Civil Action No. #case-text] }
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
/// `note` is printed after the name, `lines` are the address and contact lines.
#let signature-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
  block(sticky: true, above: body-leading, below: body-leading)[Respectfully submitted,]
  for g in meta.signature {
    let sig = if g.at("esign", default: true) [/s/ #g.signer] else [#g.signer]
    let note = g.at("note", default: none)
    block(breakable: false, above: body-leading, below: 0pt)[
      #sig#if note != none [ (#note)]\
      #for line in g.lines [#line \ ]
    ]
  }
}

/// Lines that follow the signature (the service address, for example), single-spaced.
#let service-note(meta) = {
  let lines = meta.at("service_note", default: ())
  if lines.len() > 0 {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    block(breakable: false, above: body-leading)[
      #for line in lines [#line \ ]
    ]
  }
}

#let almd-complaint(meta, body) = {
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

  // Headings: level 1 is centered and bold (the exemplars' section heads); level 2 is centered bold
  // in the same type; level 3 is flush left and bold. Each is kept with the text that follows it.
  show heading.where(level: 1): it => block(sticky: true, above: body-leading, below: body-leading)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    #align(center)[#strong(it.body)]
  ]
  show heading.where(level: 2): it => block(sticky: true, above: body-leading, below: body-leading)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    #align(center)[#strong(it.body)]
  ]
  show heading.where(level: 3): it => block(sticky: true, above: body-leading, below: body-leading)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    #strong(it.body)
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

  block(breakable: false)[
    #signature-block(meta)
    #service-note(meta)
  ]
}
