// Complaint for the U.S. District Court for the Western District of Texas (txwd).
// Rules: W.D. Tex. Local Rule CV-10(a) (12-point or larger type including footnotes, double-spaced, 8½ × 11
// paper with one-inch margins on all sides, case style and descriptive name on the document), CV-10(b)
// (attorney's address, e-mail, signature, state bar card number, telephone and fax); Fed. R. Civ. P. 8(a)
// and 10(a)-(b) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // CV-10 names no face; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // CV-10(a): 12-point or larger
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so this gives a 2.0em (24 pt) pitch
#let single-leading = 0.545em           // single spacing (caption, signature, headings): a 1.2em line pitch (line box 0.655em + leading)
#let single-pitch = 1.2em
#let margin = 1in                       // CV-10(a): one-inch margins on all sides
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.7in               // party column: the longest party line (about 3.3 in) must not wrap
#let caption-mid = 0.3in                // the § column
#let signature-indent = 3.2in           // signature block starts here

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, lists, smart punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body.
#let chunks(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the document
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading)
  for line in meta.court {
    align(center, text(weight: "bold", line))
    linebreak()
  }
}

/// Caption rows: [left, right]. Each row prints a § in the middle column (the W.D. Tex. convention in
/// both exemplars). A row's leading spaces become an indent. Each row is one line: text is not wrapped.
#let caption(rows) = {
  set par(leading: single-leading, justify: false)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    rows: single-pitch,
    row-gutter: 0pt,
    ..rows.map(r => {
      let left = r.at(0)
      let stripped = left.trim(at: start)
      let lead = left.len() - stripped.len()
      // an empty cell would collapse the row, so it gets one line of height
      let one-line = block(height: single-pitch, width: 100%)
      (
        if stripped == "" { one-line } else { [#h(lead * 0.075in)#stripped] },
        align(center, [§]),
        if r.at(1) == "" { one-line } else { [#h(0.2in)#r.at(1)] },
      )
    }).flatten(),
  )
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, list items, centered lines
// ---------------------------------------------------------------------------

#let counter-para = counter("txwd-para")

#let heading-center(c) = block(width: 100%, above: 1.2em, below: 1.2em, sticky: true,
  align(center, text(weight: "bold", c)))

#let heading-left(c) = block(width: 100%, above: 1.2em, below: 1.2em, sticky: true,
  text(weight: "bold", c))

/// One line of a centered block; a markdown quote marker (">") in front of it is dropped.
#let unquote(l) = { let t = l.trim(); if t.starts-with(">") { t.slice(1).trim() } else { t } }

#let centered-lines(c) = block(width: 100%, above: 1.2em, below: 1.2em,
  align(center, stack(dir: ttb, spacing: single-leading,
    ..c.split("\n").map(l => [#unquote(l)]))))

#let body-block(body) = {
  // paragraph spacing equals the double leading, so the first line of a paragraph sits one 2.0 em pitch below the last
  set par(leading: body-leading, first-line-indent: 0pt, spacing: body-leading, justify: false)
  for c in chunks(body) {
    if c.starts-with("### ") {
      heading-left(c.slice(4))
    } else if c.starts-with("## ") {
      heading-center(c.slice(3))
    } else if c.starts-with("# ") {
      heading-center(upper(c.slice(2)))
    } else if c.starts-with(">") {
      centered-lines(c)
    } else if c.starts-with("~ ") {
      // unnumbered paragraph (the prayer lead-in)
      [#h(para-indent)#inl(c.slice(2))]
      parbreak()
    } else if c.match(regex("^(\\d+\\.|-) ")) != none {
      // list: numbered by the markdown; sub-items indent
      set enum(indent: 0.5in, body-indent: 0.35em)
      set list(indent: 0.5in, body-indent: 0.35em)
      inl(c)
    } else {
      // numbered paragraph (FRCP 10(b))
      counter-para.step()
      context [#h(para-indent)#counter-para.display().#h(0.25in)#inl(c)]
      parbreak()
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block: CV-10(b) (signature, state bar card number, address, e-mail, telephone, fax)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  set par(leading: single-leading)
  block(width: 100%, breakable: false, above: 1.2em, grid(
    columns: (1fr, signature-indent),
    [Dated: #meta.date],
    stack(dir: ttb, spacing: single-leading,
      [Respectfully submitted,],
      v(1.2em),
      [/s/ #sig.signer],
      ..sig.lines.map(l => if l == "" { v(1.2em) } else { [#l] }),
    ),
  ))
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let txwd-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center,
    footer-descent: 0pt, header: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, justify: false)

  court-title(meta)
  v(2 * 1.2em)
  caption(meta.caption)
  v(2 * 1.2em)
  align(center, text(weight: "bold", meta.title))
  v(1.2em)
  body-block(body)
  signature-block(meta)
}
