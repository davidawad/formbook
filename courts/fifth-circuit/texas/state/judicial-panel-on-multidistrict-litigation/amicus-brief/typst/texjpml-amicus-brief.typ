// Texas Judicial Panel on Multidistrict Litigation (Supreme Court of Texas, MDL Panel Clerk):
// an amicus curiae letter brief. A letter, not a bound brief: no cover, no contents, no index.
//
// Rule-driven and content-agnostic. Governing rules, sources and kinds: ../../rules.md (TEXJPML-AMI-001).
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The body is the markdown rendered by cmarker; the date, addressee, salutation and signature come
// from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule, an exemplar, or a choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // no rule names a face; exemplar uses Times New Roman
#let type-size = 14pt              // TRAP 9.4(e) 14-point, applied by convention (rules.md TEXJPML-FORM-006)
#let footnote-size = 12pt          // TRAP 9.4(e): footnotes no smaller than 12-point
#let body-leading = 0.9em          // double-spaced text (about 28 pt pitch at 14 pt)
#let single-leading = 0.2em        // single-spaced: footnotes, addressee, signature
#let page-margin = 1in             // TRAP 9.4(c), applied by convention
#let para-indent = 0.5in
#let short-line = 50               // paragraphs shorter than this (characters) are set flush left

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let plain-text(c) = {
  if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain-text).join() }
  else if c.has("body") { plain-text(c.body) }
  else if c.has("child") { plain-text(c.child) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("texjpml amicus brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let as-lines(v) = if type(v) == array { v } else if v == none { () } else { (v,) }

/// One line of an address or signature block, with inline markdown (emphasis) honored.
#let md-line(l) = if l.len() > 2 and l.starts-with("*") and l.ends-with("*") { emph(l.slice(1, l.len() - 1)) } else { [#l] }

#let single-block(lines) = block(breakable: false, above: 1em, below: 1em, {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  as-lines(lines).map(md-line).join(linebreak())
})

// ---------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------

#let render(src) = {
  let (meta, body) = split-frontmatter(src)
  let body = body.replace("\u{a7} ", "\u{a7}\u{a0}")

  set document(title: meta.at("title", default: meta.at("brief_title", default: "Letter brief")))
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)

  // The file-date line, the addressee and the salutation open the letter (single-spaced).
  if "date" in meta { block(above: 0in, below: 1em, { set par(first-line-indent: 0in); md-line(meta.date) }) }
  single-block(meta.at("addressee", default: ()))
  if "salutation" in meta {
    block(above: 1em, below: 1em, { set par(first-line-indent: 0in); md-line(meta.salutation) })
  }

  // Level-2 headings in the letter: centered bold capitals as printed (for example "TO THE TEXAS MDL PANEL").
  show heading.where(level: 2): it => block(width: 100%, above: 0.6em, below: 0.6em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #set align(center)
    #text(weight: "bold", it.body)
  ]
  set footnote.entry(separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in)
  // Short standalone lines are not indented.
  show par: it => {
    let s = plain-text(it.body).trim()
    if it.first-line-indent.amount != 0pt and s.len() < short-line {
      par(first-line-indent: 0pt, it.body)
    } else { it }
  }

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Closing signatures, one block per signer, single-spaced in the right half.
  for s in meta.at("signature", default: ()) {
    block(breakable: false, above: 1.2em, below: 0.6em, pad(left: 3in, {
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
      as-lines(s).map(md-line).join(linebreak())
    }))
  }
}
