// Mississippi chancery courts (misschanceryct): memorandum in support of a motion (motion-brief).
//
// Rule-driven and content-agnostic. Requirement IDs (MISSCHANCERYCT-...) refer to ../../rules.md.
// The retrieved rules fix paper size, caption, service, signature and the electronic-filing form
// (MRCP 7(c), 10(a), 11(a); MEC 3(A)(1), 3(B)(2), 3(G)). They state no margin, typeface, point size,
// spacing or page limit for a memorandum, so those follow the filed exemplar (tier 2) and the
// one-inch margin of the default checks. No case-specific text, no coordinates measured off any
// filed paper, no forced line breaks. The body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the sample (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // no retrieved rule names a face (MISSCHANCERYCT-FORM-003); see docs/FONTS.md.
#let type-size = 12pt                  // MISSCHANCERYCT-FORM-003 (no rule); the exemplar text is 12 pt.
#let footnote-size = 11pt              // convention: footnotes a size below the text, legible at the exemplar size.
#let page-margin = 1in                 // MISSCHANCERYCT-FORM-003 (no rule); the default one-inch margin, as in the exemplar.
#let para-indent = 0.5in               // convention: text paragraphs begin with a first-line indent.
// A line box is one em (top and bottom edges below), so a leading of one em gives a baseline
// pitch of 24 pt: double spacing (tier 2, as the exemplar). Single spacing is a 2 pt leading.
#let box-edges = (top-edge: 0.7em, bottom-edge: -0.3em)
#let body-leading = 1em
#let single-leading = 2pt

// Text box settings used for every line, so the pitch above holds everywhere.
#let rule-stroke = 0.6pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("misschanceryct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("misschanceryct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A run of single-spaced lines, one item per line (no manual breaks).
#let address(lines) = stack(dir: ttb, spacing: single-leading, ..lines.map(l => inl(l)))

// ---------------------------------------------------------------------------
// Caption: court and district (centred, bold), parties with designations, cause number
// (MRCP 10(a): the name of the court, the title of the action and the file number)
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let parties = need(meta, "parties")
  let cause = need(meta, "cause_number")
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    strong(inl(need(meta, "court"))),
    strong(inl(need(meta, "district")))))
  v(body-leading)
  // Two columns: names on the left, designations on the right. Between two parties sits "V.",
  // and the cause number is set on that same line at the right.
  let cells = ()
  for (i, g) in parties.enumerate() {
    if i > 0 {
      cells.push([V.])
      cells.push(align(right, inl(cause)))
    }
    cells.push(address(g.names))
    cells.push(align(right, inl(g.designation)))
  }
  if parties.len() < 2 { cells.push([]); cells.push(align(right, inl(cause))) }
  grid(columns: (1fr, auto), row-gutter: single-leading + 10pt, column-gutter: 0.3in, ..cells)
  v(body-leading)
  // The title sits between two rules (the exemplar's caption setting).
  line(length: 100%, stroke: rule-stroke)
  v(0.6em)
  align(center, par(first-line-indent: 0pt, leading: single-leading, strong(inl(need(meta, "title")))))
  v(0.6em)
  line(length: 100%, stroke: rule-stroke)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature, counsel and certificate blocks (MEC 3(B)(2): "s/" then the name, bar number,
// firm, address, telephone, fax and e-mail)
// ---------------------------------------------------------------------------

#let signature-lines(sig) = block(width: 100%, breakable: false, pad(left: 3.2in,
  par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, {
    [/s/ #inl(sig.signer)]
    linebreak()
    inl(sig.signer)
    linebreak()
    inl(sig.role)
  })))

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: body-leading, {
    par(first-line-indent: para-indent, [RESPECTFULLY SUBMITTED this #need(meta, "date").])
    v(body-leading)
    signature-lines(sig)
    v(body-leading)
    let counsel = need(meta, "of_counsel")
    block(width: 100%, breakable: false, stack(dir: ttb, spacing: single-leading,
      par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)[OF COUNSEL:],
      address(counsel)))
  })
}

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  align(center, strong[CERTIFICATE OF SERVICE])
  v(body-leading)
  par(first-line-indent: para-indent, inl(need(cert, "text")))
  v(body-leading)
  block(width: 100%, breakable: false, {
    par(first-line-indent: para-indent, [SO CERTIFIED this #need(meta, "date").])
    v(body-leading)
    signature-lines(cert)
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let misschanceryct-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, ..box-edges, lang: "en")
  set par(
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true),
    justify: false,
  )

  // Headings: the author types the numbering, as the exemplar does. Level 2 bold; level 3
  // bold with a hanging label; level 4 bold italic (the numbered sub-points).
  show heading.where(level: 2): it => block(
    width: 100%, above: body-leading, below: body-leading * 0.5, sticky: true,
    par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt,
      hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body)),
  )
  show heading.where(level: 3): it => block(
    width: 100%, above: body-leading * 0.8, below: body-leading * 0.5, sticky: true,
    pad(left: 0.5in, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt,
      hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body))),
  )
  show heading.where(level: 4): it => block(
    width: 100%, above: body-leading * 0.8, below: body-leading * 0.5, sticky: true,
    pad(left: 1in, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt,
      hanging-indent: 0.5in, text(size: type-size, weight: "bold", style: "italic", it.body))),
  )
  show heading.where(level: 1): it => panic("misschanceryct-motion-brief: level-1 headings are not used in this template; use level 2")
  show heading.where(level: 5): it => panic("misschanceryct-motion-brief: headings deeper than level 4 are not supported")

  // Block quotations: indented on both sides, single-spaced.
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in),
    above: body-leading * 0.5, below: body-leading * 0.5)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // Footnotes: set at the footnote size, single-spaced.
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it
  }

  // Tables (the exemplar's figure tables): single-spaced cells, thin rules.
  set table(stroke: 0.5pt, inset: (x: 5pt, y: 4pt))
  show table: it => {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, justify: false)
    set text(size: type-size)
    it
  }

  // ---- caption, memorandum body, signature, counsel ----
  caption-block(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)

  // ---- certificate of service (MEC 3(G)) ----
  v(body-leading)
  certificate-block(meta)
}
