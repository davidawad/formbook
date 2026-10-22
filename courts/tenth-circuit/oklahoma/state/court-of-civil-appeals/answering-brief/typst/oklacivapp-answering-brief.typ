// Oklahoma Court of Civil Appeals: answering brief (appellee's principal brief), filed in the
// Supreme Court of Oklahoma, which assigns the appeal to the Court of Civil Appeals (Okla. Sup.
// Ct. R. 1.11 governs form; the rule text was not retrieved, see ../../rules.md).
//
// Rule-driven and content-agnostic. Governing rules and their verification status: ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The body is the sample markdown rendered by cmarker; the metadata is the YAML frontmatter of
// the same file (contract: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt              // 12-point default; Okla. Sup. Ct. R. 1.11 not retrieved (../rules.md)
#let footnote-size = 11pt          // footnotes one point smaller, as the exemplar sets them
#let body-leading = 1.6em          // double-spaced text: natural line + 1.6em = 2.25em pitch (README)
#let single-leading = 0.495em      // single-spaced: footnotes, block quotations, headings, tables, lists
#let page-margin = 1in             // 1 in on all four sides (default; see ../rules.md)
#let para-indent = 0.5in
#let short-line = 50               // paragraphs shorter than this (characters) are set flush left
#let label-column = 2.25in         // first column of a two-column (label, text) table and of the identity list

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
  if m == none { panic("oklacivapp brief: the sample must start with a YAML frontmatter block") }
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

/// The cover: the court and the case numbers of the appellate and trial courts, the case
/// style, the title of the filing, and the filing party's counsel.
#let cover(meta) = {
  set align(center)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF OKLAHOMA]
  v(0.2in)
  align(right, [Sup. Ct. Case No. #meta.case_number])
  v(0.1in)
  align(left, [Dist. Ct. Case No. #meta.trial_cause])
  v(0.15in)
  if "caption" in meta { text(weight: "bold")[#meta.caption]; v(0.15in) }
  text(weight: "bold")[#upper(meta.appellant)]
  linebreak()
  [#meta.appellant_role,]
  v(0.1in)
  [v.]
  v(0.1in)
  text(weight: "bold")[#upper(meta.appellee)]
  linebreak()
  [#meta.appellee_role]
  v(0.15in)
  [Appeal from #meta.trial_court, #meta.county County, Oklahoma]
  linebreak()
  [#meta.trial_judge]
  v(0.3in)
  text(weight: "bold")[#upper(meta.brief_title)]
  v(0.3in)
  [#meta.date]
  v(1fr)
  align(left, pad(left: 3in)[
    #set par(first-line-indent: 0in)
    #meta.counsel.map(l => [#l]).join(linebreak())
  ])
  // Keeps the last cover line above the 1 in bottom margin (the line box extends past the frame).
  v(0.05in)
}

/// Identity of parties and counsel: one row per role, the names and addresses single-spaced
/// beside it. A row is never split across pages.
#let identity-block(entries) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  for e in entries {
    block(breakable: false, above: 1.4em, below: 1.4em, grid(
      columns: (label-column, 1fr),
      column-gutter: 0.25in,
      text(weight: "bold", e.role),
      e.lines.map(l => [#l]).join(linebreak()),
    ))
  }
}

/// A signature block: single-spaced, in the right half of the page, never split.
#let signature-block(lines) = block(breakable: false, above: 1.6em, below: 1.6em, pad(left: 3in)[
  #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  #lines.map(l => [#l]).join(linebreak())
])

/// Index of authorities: authorities from the frontmatter, grouped, each listed with every body
/// page on which its `find` string appears (located by the layout, not typed).
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
      // The entry wraps inside the left column with a hanging indent; the dot leader runs to
      // the page-number column, so the numbers always stand flush right on the last line.
      block(above: 1em, below: 1em, breakable: false, grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        par(hanging-indent: 0.25in)[#name#if cite != none [, #cite] #box(width: 1fr, repeat[.~])],
        context {
          let pages = query(<oklacivapp-authority>)
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

/// Mark every occurrence of each authority's `find` string in `body` with invisible metadata,
/// so the index can list the pages.
#let mark-authorities(groups, body) = {
  let items = groups.map(g => g.items).flatten()
  for (i, a) in items.enumerate() {
    let key = a.at("find", default: a.name).replace("\u{a7} ", "\u{a7}\u{a0}")
    body = {
      show regex(regex-literal(key)): it => [#it#metadata(i)<oklacivapp-authority>]
      body
    }
  }
  body
}

// ---------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------

#let render(src) = {
  let (meta, body) = split-frontmatter(src)

  // A section sign is never left at the end of a line apart from its number.
  let body = body.replace("\u{a7} ", "\u{a7}\u{a0}")

  // The markdown is split at `{{contents}}`: before it, front matter on lower-roman pages;
  // after it, the table of contents, the index of authorities, then the body from page 1.
  let parts = body.split(regex("(?m)^\\{\\{contents\\}\\}[ \t]*$"))
  assert(parts.len() == 2, message: "oklacivapp brief: the markdown needs exactly one {{contents}} line")
  let (front, main) = parts

  set document(title: meta.brief_title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "i",
    footer: context {
      // The cover carries no page number; it counts as page i of the front matter.
      if here().page() > 1 {
        align(center, text(size: type-size, counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)

  // Headings: single-spaced, kept with the text that follows.
  show heading.where(level: 1): it => block(width: 100%, above: 0.35in, below: 0.25in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in, justify: false)
    #set align(center)
    #text(weight: "bold", upper(it.body))
  ]
  show heading.where(level: 2): it => block(above: 0.3in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(above: 0.25in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show heading.where(level: 4): it => block(above: 0.25in, below: 0.2in, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0in)
    #text(style: "italic", it.body)
  ]

  // Block quotations and footnotes: single-spaced; footnotes one point smaller than the text.
  show quote.where(block: true): it => block(above: 1.4em, below: 1.4em, inset: (x: 0.5in))[
    #set par(leading: single-leading, spacing: 1.2em, first-line-indent: 0in)
    #it.body
  ]
  set footnote.entry(separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in)
  show list: set par(first-line-indent: 0in)
  show enum: set par(first-line-indent: 0in)
  // Tables: no rules, single-spaced cells.
  set table(stroke: none, inset: (x: 0in, y: 0.08in), column-gutter: 0.25in)
  show table: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0in, justify: false)
  // A two-column markdown table is read as label and text (a statement of the case set out
  // in rows): the label column takes the identity-list width, and the first row (a markdown
  // table always has one) is an ordinary row, not a header repeated on every page.
  // Other tables keep their columns and header.
  show table: it => if it.columns == (auto, auto) {
    let cells = it.children.map(c => if c.func() == table.header { c.children } else { (c,) }).flatten()
    table(columns: (label-column, 1fr), ..cells)
  } else { it }
  // Short standalone lines (a record or case citation after a quotation, a label) are not
  // indented; body paragraphs keep the first-line indent.
  // A paragraph that ends in a colon introduces what follows (a list, a quotation) and is
  // kept on the same page with it.
  show par: it => {
    let s = plain-text(it.body).trim()
    let p = if it.first-line-indent.amount != 0pt and s.len() < short-line {
      par(first-line-indent: 0pt, it.body)
    } else { it }
    if s.ends-with(":") { context block(sticky: true, spacing: par.spacing, p) } else { p }
  }

  // Placeholders a body paragraph may hold on its own line.
  let render-md(md) = {
    let md-render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
    let pieces = md.split(regex("(?m)^(\\{\\{(?:identity|signature|signer)\\}\\})[ \t]*$"))
    let tags = md.matches(regex("(?m)^\\{\\{(identity|signature|signer)\\}\\}[ \t]*$")).map(m => m.captures.at(0))
    for (k, piece) in pieces.enumerate() {
      let t = tags.at(k, default: none)
      // A certificate (the last level-1 section before `{{signer}}`) is kept on one page with
      // its signature, so the signature never stands alone at the top of a page.
      let heads = piece.matches(regex("(?m)^# "))
      if t == "signer" and heads.len() > 0 {
        let at = heads.last().start
        md-render(piece.slice(0, at))
        block(breakable: false, width: 100%, { md-render(piece.slice(at)); signature-block(meta.signer) })
      } else {
        md-render(piece)
        if t == "identity" { identity-block(meta.identity) }
        else if t == "signature" { signature-block(meta.signature) }
        else if t == "signer" { signature-block(meta.signer) }
      }
    }
  }

  // Cover (page i, unnumbered).
  cover(meta)
  pagebreak()

  // Front matter (identity of parties, record citations): lower-roman pages from ii.
  if front.trim() != "" {
    render-md(front)
    pagebreak()
  }

  // Table of contents, generated from the headings.
  [
    #heading(level: 1)[Table of Contents]
    #set par(leading: single-leading, first-line-indent: 0in)
    #show outline.entry.where(level: 1): set block(above: 0.2in)
    #show outline.entry: set block(above: 0.12in)
    #outline(title: none, depth: 3, indent: 0.4in)
  ]
  pagebreak()

  // Index of authorities.
  if "authorities" in meta {
    heading(level: 1)[Index of Authorities]
    authorities-index(meta.authorities)
    pagebreak()
  }

  // Body: arabic page numbers from 1.
  set page(numbering: "1")
  counter(page).update(1)
  let content = render-md(main)
  if "authorities" in meta { mark-authorities(meta.authorities, content) } else { content }
}
