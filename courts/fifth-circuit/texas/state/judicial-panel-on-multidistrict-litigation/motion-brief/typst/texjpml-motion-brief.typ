// Texas Judicial Panel on Multidistrict Litigation (Supreme Court of Texas, MDL Panel Clerk):
// papers filed in the Panel's docket. This file is shared by the answering-brief, reply-brief,
// motion-brief and amicus-brief folders of the court; only the frontmatter differs.
//
// Rule-driven and content-agnostic. Governing rules, sources and kinds: ../../rules.md.
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The body is the markdown rendered by cmarker; the cover, contents, index of authorities,
// signature and certificate of service are generated from the YAML frontmatter.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule, an exemplar, or a choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // no rule names a face; exemplars use Times New Roman
#let type-size = 14pt              // TRAP 9.4(e) 14-point, applied by convention (rules.md TEXJPML-FORM-006)
#let footnote-size = 12pt          // TRAP 9.4(e): footnotes no smaller than 12-point
#let body-leading = 0.9em          // double-spaced text: natural line (about 1.1 em) + 0.9 em = about 24 pt pitch
#let single-leading = 0.2em        // single-spaced text: footnotes, block quotations, headings, cover, counsel
#let page-margin = 1in             // TRAP 9.4(c), applied by convention: at least 1 inch on all sides
#let para-indent = 0.5in
#let short-line = 50               // paragraphs shorter than this (characters) are set flush left
#let default-date = ""

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
  if m == none { panic("texjpml brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Escape a literal string for use in a regex.
#let regex-literal(s) = {
  let out = ""
  for ch in s.clusters() {
    if "\\.^$|?*+()[]{}".contains(ch) { out += "\\" + ch } else { out += ch }
  }
  out
}

/// Lines of a field that may be a single string or a list of strings.
#let as-lines(v) = if type(v) == array { v } else if v == none { () } else { (v,) }

/// A rule line across the text width.
#let rule-line() = line(length: 100%, stroke: 0.75pt)

/// One line of a cover or signature block, with inline markdown (emphasis) honored.
#let md-line(l) = if l.len() > 2 and l.starts-with("*") and l.ends-with("*") { emph(l.slice(1, l.len() - 1)) } else { [#l] }

// ---------------------------------------------------------------------------
// Cover (unnumbered page i)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set align(center)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  if "docket" in meta { text(weight: "bold")[#meta.docket]; v(0.2in) }
  for l in as-lines(meta.at("court", default: none)) { [#l]; linebreak() }
  v(0.14in)
  rule-line()
  v(0.14in)
  for l in as-lines(meta.caption) { text(weight: "bold")[#upper(l)]; linebreak() }
  v(0.14in)
  rule-line()
  v(0.14in)
  text(weight: "bold")[#meta.brief_title]
  v(0.14in)
  rule-line()
  if "notes" in meta {
    v(0.2in)
    for n in meta.notes { text(weight: "bold")[#n]; linebreak() }
  }
  v(0.25in)
  // Counsel: one block per counsel group, in two columns, each block kept whole.
  let blocks = meta.at("counsel", default: ())
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    row-gutter: 0.12in,
    ..blocks.map(b => block(breakable: false, align(left, {
      set par(first-line-indent: 0in)
      as-lines(b.at("lines", default: ())).map(md-line).join(linebreak())
    }))),
  )
  if "date" in meta {
    v(0.25in)
    align(left)[#meta.date]
  }
  // Keeps the last cover line above the 1 in bottom margin.
  v(0.2in)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (generated)
// ---------------------------------------------------------------------------

#let signature-block(lines) = block(breakable: false, above: 1.2em, below: 1.2em, pad(left: 3in)[
  #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  #as-lines(lines).map(md-line).join(linebreak())
])

/// Certificate of service: wording is the template's; the date and the signature block come from the
/// frontmatter (`service: {date: ...}`; the signature is `signature`). TRAP 9.5(d), (e), applied by convention.
#let service-certificate(meta) = {
  // Wording as the filing states it (the served document is the brief itself); the date, the title and the
  // signer come from the frontmatter (`service: {date, signer}`). TRAP 9.5(d), (e), applied by convention.
  block(breakable: false, width: 100%, above: 1.2em, {
    align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
    par(first-line-indent: para-indent)[
      I hereby certify that, on #meta.service.date, a true and correct copy of this #meta.brief_title was
      served through the electronic filing system to all counsel of record.
    ]
    signature-block(meta.service.at("signer", default: meta.signature))
  })
}

// ---------------------------------------------------------------------------
// Index of authorities (generated, only when `authorities` is in the frontmatter)
// ---------------------------------------------------------------------------

#let authorities-index(groups) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  let n = 0
  for g in groups {
    block(above: 1.6em, below: 1em, sticky: true, text(weight: "bold", upper(g.group)))
    for a in g.items {
      let i = n
      n += 1
      let name = if a.at("italic", default: true) { emph(a.name) } else { [#a.name] }
      let cite = a.at("cite", default: none)
      block(above: 1em, below: 1em, breakable: false, grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        par(hanging-indent: 0.25in)[#name#if cite != none [, #cite] #box(width: 1fr, repeat[.~])],
        context {
          let pages = query(<texjpml-authority>)
            .filter(m => m.value == i)
            .map(m => counter(page).at(m.location()).first())
            .dedup()
            .sorted()
          if pages.len() == 0 { text(weight: "bold")[not cited] } else { [~] + pages.map(str).join(", ") }
        },
      ))
    }
  }
}

/// Mark every occurrence of each authority's `find` string in `body` with invisible metadata.
#let mark-authorities(groups, body) = {
  let items = groups.map(g => g.items).flatten()
  for (i, a) in items.enumerate() {
    let key = a.at("find", default: a.name).replace("\u{a7} ", "\u{a7}\u{a0}")
    body = {
      show regex(regex-literal(key)): it => [#it#metadata(i)<texjpml-authority>]
      body
    }
  }
  body
}

// ---------------------------------------------------------------------------
// Heading numbers (automatic, never typed): level 2 = I., level 3 = A., level 4 = 1., level 5 = a.
// Level 1 is an unnumbered centered section.
// ---------------------------------------------------------------------------

#let heading-number(..n) = {
  let k = n.pos().last()
  let lvl = n.pos().len()
  if lvl == 2 { numbering("I.", k) }
  else if lvl == 3 { numbering("A.", k) }
  else if lvl == 4 { numbering("1.", k) }
  else if lvl == 5 { numbering("a.", k) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------

#let render(src) = {
  let (meta, body) = split-frontmatter(src)

  // The body is split at `{{contents}}`: before it, front matter on lower-roman pages (may be empty);
  // after it, the table of contents, the index of authorities, then the body from page 1.
  let parts = body.split(regex("(?m)^\\{\\{contents\\}\\}[ \t]*$"))
  assert(parts.len() == 2, message: "texjpml brief: the markdown needs exactly one {{contents}} line")
  let (front, main) = parts
  // A section sign is never left at the end of a line apart from its number.
  let main = main.replace("\u{a7} ", "\u{a7}\u{a0}")

  set document(title: meta.brief_title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "i",
    footer: context {
      // The cover (and any continuation of its counsel list) carries no page number.
      let cover-end = query(<texjpml-cover-end>).first().location().page()
      if here().page() > cover-end {
        align(center, text(size: type-size, counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: heading-number)

  // Level-1 sections: centered bold capitals, single-spaced.
  show heading.where(level: 1): it => block(width: 100%, above: 0.35in, below: 0.25in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #set align(center)
    #text(weight: "bold", upper(it.body))
  ]
  // Level 2 (I.): centered bold, numbered from the heading counter.
  show heading.where(level: 2): it => block(width: 100%, above: 0.3in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #set align(center)
    #text(weight: "bold")[#context numbering(it.numbering, ..counter(heading).at(it.location())) #h(0.5em) #it.body]
  ]
  // Levels 3 to 5: flush left with a hanging number.
  show heading.where(level: 3): it => block(above: 0.25in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #grid(columns: (0.5in, 1fr), text(weight: "bold")[#context numbering(it.numbering, ..counter(heading).at(it.location()))], text(weight: "bold", it.body))
  ]
  show heading.where(level: 4): it => block(above: 0.25in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #grid(columns: (0.5in, 1fr), [#context numbering(it.numbering, ..counter(heading).at(it.location()))], text(weight: "bold", it.body))
  ]
  show heading.where(level: 5): it => block(above: 0.25in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #grid(columns: (0.5in, 1fr), [#context numbering(it.numbering, ..counter(heading).at(it.location()))], text(style: "italic", it.body))
  ]

  // Block quotations and footnotes: single-spaced (TRAP 9.4(d)); footnotes at footnote-size.
  show quote.where(block: true): it => block(above: 1.2em, below: 1.2em, inset: (x: 0.5in))[
    #set par(leading: single-leading, spacing: 1.2em, first-line-indent: 0in)
    #it.body
  ]
  set footnote.entry(separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in)
  show list: set par(first-line-indent: 0in)
  show enum: set par(first-line-indent: 0in)
  // Short standalone lines are not indented; a paragraph that ends in a colon is kept with what follows.
  show par: it => {
    let s = plain-text(it.body).trim()
    let p = if it.first-line-indent.amount != 0pt and s.len() < short-line {
      par(first-line-indent: 0pt, it.body)
    } else { it }
    if s.ends-with(":") { context block(sticky: true, spacing: par.spacing, p) } else { p }
  }

  let render-md(md) = cmarker.render(md, raw-typst: false, smart-punctuation: true)

  // Cover (page i, unnumbered).
  cover(meta)
  [#metadata(none)<texjpml-cover-end>]
  pagebreak()

  // Front matter (may be empty): lower-roman pages from ii.
  if front.trim() != "" {
    render-md(front)
    pagebreak()
  }

  // Table of contents, generated from the headings.
  [
    #align(center, text(weight: "bold")[TABLE OF CONTENTS])
    #set par(leading: single-leading, first-line-indent: 0in)
    #show outline.entry.where(level: 1): set block(above: 0.2in)
    #show outline.entry: set block(above: 0.12in)
    #outline(title: none, depth: 4, indent: 0.4in)
  ]
  pagebreak()

  // Index of authorities (generated, only when the frontmatter lists authorities).
  if "authorities" in meta {
    align(center, text(weight: "bold")[INDEX OF AUTHORITIES])
    authorities-index(meta.authorities)
    pagebreak()
  }

  // Body: arabic page numbers from 1.
  set page(numbering: "1")
  counter(page).update(1)
  let content = render-md(main)
  let content = if "authorities" in meta { mark-authorities(meta.authorities, content) } else { content }
  content
  // Signature (after the last section), then the certificate of service when the frontmatter asks for one.
  if "signature" in meta {
    if "date" in meta { block(breakable: false, above: 1.2em, [Dated: #meta.date]) }
    signature-block(meta.signature)
  }
  if "service" in meta {
    service-certificate(meta)
  }
}
