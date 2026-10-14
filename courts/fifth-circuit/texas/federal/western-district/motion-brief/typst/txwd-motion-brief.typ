// Motion with brief in support, for the U.S. District Court for the Western District of Texas (txwd).
// Rules: W.D. Tex. Local Rule CV-10(a) (12-point or larger type including footnotes, double-spaced, 8½ × 11
// paper with one-inch margins on all sides, case style and descriptive name), CV-10(b) (attorney's address,
// e-mail, signature, state bar card number, telephone and fax); CV-7(a) (a motion must meet CV-10), CV-7(c)(1)
// (authority cited in the motion, not a separate brief), CV-7(c)(2) (20-page limit for other motions, exclusive
// of caption, signature block, certificate); Fed. R. Civ. P. 7(b)(1) (a motion states the grounds with
// particularity). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only font the repo ships
#let type-size = 13pt                   // CV-10(a): 12-point or larger. 13 pt because EB Garamond sets smaller than Times 12
#let body-leading = 1.35em              // double spacing: the line box is 0.65em, so this gives a 2.0em (26 pt) pitch
#let single-leading = 0.55em            // single spacing (caption, signature, headings, block quotes): a 1.2em pitch
#let single-pitch = 1.2em
#let margin = 1in                       // CV-10(a): one-inch margins on all sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.7in               // party column of the caption
#let caption-mid = 0.3in                // the § column
#let signature-indent = 3.2in           // signature block starts here

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, lists, smart punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body.
#let chunks(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

/// One line of a block quote: a markdown quote marker (">") in front of it is dropped.
#let unquote(l) = { let t = l.trim(); if t.starts-with(">") { t.slice(1).trim() } else { t } }

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

/// Caption rows: [left] or [left, right]. The § column is printed on every row (the W.D. Tex. convention
/// in both exemplars); the right cell carries the case number on one row, if the row has one.
#let caption(rows) = {
  set par(leading: single-leading, justify: false)
  let one-line = block(height: single-pitch, width: 100%)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    rows: single-pitch,
    ..rows.map(r => {
      let left = r.at(0)
      let right = if r.len() > 1 { r.at(1) } else { "" }
      let stripped = left.trim(at: start)
      let lead = left.len() - stripped.len()
      (
        if stripped == "" { one-line } else { [#h(lead * 0.075in)#stripped] },
        align(center, [§]),
        if right == "" { one-line } else { [#h(0.2in)#right] },
      )
    }).flatten(),
  )
}

// ---------------------------------------------------------------------------
// Headings, body, block quotes
// ---------------------------------------------------------------------------

// Headings are typst headings so the table of contents can be generated from them. The author types the
// numbers (I., A., 1.) as the exemplar does; the template does not number them.
/// A block quotation: single-spaced, indented both sides (CV-10(a) allows single spacing for quotations
/// more than two lines long; a shorter quotation is kept in the flow here, as the exemplar does).
#let block-quote(c) = block(width: 100%, above: 1.2em, below: 1.2em, inset: (left: 0.5in, right: 0.5in),
  {
    set par(leading: single-leading, spacing: 0pt)
    inl(unquote(c))
  })

#let body-block(body) = {
  // paragraph spacing equals the double leading, so the first line of a paragraph sits one 2.0 em pitch below the last
  set par(leading: body-leading, first-line-indent: 0pt, spacing: body-leading, justify: false)
  for c in chunks(body) {
    if c.starts-with("### ") {
      heading(level: 3, outlined: true, c.slice(4))
    } else if c.starts-with("## ") {
      heading(level: 2, outlined: true, c.slice(3))
    } else if c.starts-with("# ") {
      heading(level: 1, outlined: true, upper(c.slice(2)))
    } else if c.starts-with(">") {
      block-quote(c)
    } else if c.match(regex("^(\\d+\\.|-) ")) != none {
      // list: numbered or bulleted by the markdown; sub-items indent
      set enum(indent: 0.5in, body-indent: 0.35em)
      set list(indent: 0.5in, body-indent: 0.35em)
      inl(c)
    } else {
      // body paragraph (a motion is not numbered like a complaint: FRCP 10(b) does not apply)
      context [#h(para-indent)#inl(c)]
      parbreak()
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate: CV-10(b)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  set par(leading: single-leading)
  block(width: 100%, breakable: false, above: 1.2em, grid(
    columns: (1fr, signature-indent),
    [],
    stack(dir: ttb, spacing: single-leading,
      [Respectfully submitted,],
      v(1.2em),
      ..sig.firm.map(l => [#l]),
      v(1.2em),
      [/s/ #sig.signer],
      ..sig.lines.map(l => if l == "" { v(1.2em) } else { [#l] }),
    ),
  ))
}

#let certificate-block(cert) = block(width: 100%, breakable: false, above: 2.4em, {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, text(weight: "bold", cert.heading))
  block(width: 100%, above: 1.2em, [#h(para-indent)#inl(cert.text)])
  set par(leading: single-leading)
  block(width: 100%, above: 1.2em, align(right, stack(dir: ttb, spacing: single-leading,
    [/s/ #cert.signer],
    ..cert.lines.map(l => [#l]),
  )))
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let txwd-motion-brief(meta, body) = {
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center,
    footer-descent: 0pt, header: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, justify: false)

  // cover
  court-title(meta)
  v(2 * 1.2em)
  caption(meta.caption)
  v(2 * 1.2em)
  align(center, text(weight: "bold", meta.title))

  // table of contents, generated from the headings of the body
  pagebreak()
  align(center, text(weight: "bold", meta.toc_title))
  v(1.2em)
  set par(leading: single-leading, spacing: 0.9em)
  outline(title: none, depth: 3, indent: 1.5em)

  // body
  pagebreak()
  body-block(body)
  signature-block(meta)
  if "certificate" in meta { certificate-block(meta.certificate) }
}
