// Texas Court of Appeals, Fifth District at Dallas: appellant's opening brief.
//
// Rule-driven and content-agnostic. Governing rules and their verification status: ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The body is the sample markdown rendered by cmarker; the metadata is the YAML frontmatter of
// the same file (contract: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"   // TRAP 9.4(e) names no typeface; EB Garamond per docs/FONTS.md
#let type-size = 14pt              // TRAP 9.4(e): conventional typeface no smaller than 14-point
#let footnote-size = 12pt          // TRAP 9.4(e): footnotes no smaller than 12-point
#let body-leading = 1.6em          // TRAP 9.4(e): double-spaced body text; natural line + 1.6em = 2.25em pitch (README)
#let single-leading = 0.5em        // footnotes, block quotations, headings, cover, contents: single-spaced (pitch 1.15em)
#let page-margin = 1in             // TRAP 9.4(c): margins at least 1 inch on all four sides
#let para-indent = 0.5in
#let court-lines = ("IN THE COURT OF APPEALS", "FOR THE FIFTH DISTRICT OF TEXAS", "AT DALLAS")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Plain text of a piece of content, for measuring only.
#let plain-text(c) = {
  if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain-text).join() }
  else if c.has("body") { plain-text(c.body) }
  else if c.has("child") { plain-text(c.child) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("texapp brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The cover: case number, court, parties, lower court, title and counsel (Fifth Court convention).
#let cover(meta) = {
  set align(center)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in)
  [No. #meta.case_number]
  v(0.2in)
  line(length: 100%, stroke: 0.75pt)
  v(0.2in)
  for l in court-lines {
    text(weight: "bold")[#l]
    linebreak()
  }
  v(0.2in)
  line(length: 100%, stroke: 0.75pt)
  v(0.25in)
  if "caption" in meta { text(weight: "bold")[#meta.caption] ; v(0.25in) }
  text(weight: "bold")[#upper(meta.appellant)]
  linebreak()
  [Appellant,]
  v(0.25in)
  [v.]
  v(0.25in)
  text(weight: "bold")[#upper(meta.appellee)]
  linebreak()
  [Appellee.]
  v(0.25in)
  line(length: 100%, stroke: 0.75pt)
  v(0.2in)
  [On Appeal from the #meta.trial_court, #meta.county County, Texas]
  linebreak()
  [Trial Court Cause No. #meta.trial_cause]
  v(0.2in)
  line(length: 100%, stroke: 0.75pt)
  v(0.2in)
  text(weight: "bold")[#upper(meta.brief_title)]
  v(0.25in)
  line(length: 100%, stroke: 0.75pt)
  v(0.4in)
  align(left, pad(left: 3in)[
    #set par(first-line-indent: 0in)
    Respectfully submitted,
    #v(0.25in)
    #for l in meta.counsel [
      #l
      #linebreak()
    ]
  ])
}

// ---------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------

#let render(src) = {
  let (meta, body) = split-frontmatter(src)
  set document(title: meta.brief_title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context {
      // The cover carries no page number; every later page is numbered from the cover as page 1.
      if counter(page).get().first() > 1 {
        align(center, text(size: type-size, counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)

  // Headings: single-spaced, kept with the text that follows.
  show heading.where(level: 1): it => block(width: 100%, above: 0.3in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #set align(center)
    #text(weight: "bold", upper(it.body))
  ]
  show heading.where(level: 2): it => block(above: 0.25in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(above: 0.2in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show heading.where(level: 4): it => block(above: 0.2in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in)
    #text(style: "italic", it.body)
  ]

  // Block quotations and footnotes: single-spaced; footnotes in 12-point.
  show quote.where(block: true): it => block(above: 0.2in, below: 0.2in, inset: (x: 0.5in))[
    #set par(leading: single-leading, first-line-indent: 0in)
    #it.body
  ]
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0in)
  // Short paragraphs (signature and address lines, list-like entries) are not indented;
  // body paragraphs keep the first-line indent.
  show par: it => if it.first-line-indent.amount != 0pt and plain-text(it.body).len() < 100 {
    par(first-line-indent: 0pt, it.body)
  } else { it }


  cover(meta)
  pagebreak()

  // Table of contents, generated from the headings of the body (levels 1 and 2).
  // Wrapped in content brackets so its single-spacing does not leak into the body.
  [
    #align(center, text(weight: "bold")[TABLE OF CONTENTS])
    #v(0.3in)
    #set par(leading: single-leading, first-line-indent: 0in)
    #show outline.entry.where(level: 1): set block(above: 0.15in)
    #outline(title: none, depth: 2, indent: 0.5in)
  ]
  pagebreak()

  cmarker.render(body, raw-typst: false, smart-punctuation: true)
}
