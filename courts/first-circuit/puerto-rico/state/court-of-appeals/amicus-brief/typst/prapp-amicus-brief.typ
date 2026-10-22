// Tribunal de Apelaciones de Puerto Rico: amicus-brief template (escrito de comparecencia, alegato de amicus curiae). Requirement IDs (PRAPP-...) refer to ../../rules.md. Rule-driven and content-agnostic: no case
// text, no coordinates measured off a filing, no forced line breaks. The body is Markdown rendered by cmarker; the cover,
// index, signature and certificates come from the YAML frontmatter of the INPUT (keys in usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"  // FONT STANDARD: Times New Roman (PRAPP-FORM-003 names Courier 12 or a similar face)
#let type-size = 12pt                    // PRAPP-FORM-003: pica (12 pt) or larger
#let body-leading = 1.15em               // PRAPP-FORM-002: double-spaced text (one line of Times is about 1.15 em)
#let single-leading = 0.45em             // quotations, footnotes, cover, counsel and signature blocks (PRAPP-FORM-002 excepts them)
#let para-spacing = body-leading            // one double-spaced line between paragraphs (style choice)
#let para-indent = 0.5in                 // first-line indent (style choice)
#let margin-left = 1.5in                 // PRAPP-FORM-004: left margin not less than 1.5 in
#let margin-right = 1in                  // PRAPP-FORM-004: right margin not less than 0.5 in
#let margin-tb = 1in                     // PRAPP-FORM-004: the rule sets no top or bottom margin (style choice)
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("prapp-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prapp-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: 0.3em,
  ..items.map(l => if bold { text(weight: "bold", [#l]) } else { [#l] }),
)

// ---------------------------------------------------------------------------
// Cover (PRAPP-COVER-001..003): heading, caption with the designations of the filing, case information, counsel
// ---------------------------------------------------------------------------

#let caption-parties(parties) = stack(
  dir: ttb,
  spacing: 0.5em,
  ..parties.map(p => {
    let names = p.at("names").map(n => [#n])
    let role = p.at("role", default: "")
    stack(
      dir: ttb,
      spacing: 0.3em,
      ..names,
      if role != "" { align(right)[#role] },
    )
  }),
)

#let counsel-grid(groups) = grid(
  columns: (1fr,) * calc.min(groups.len(), 2),
  column-gutter: 1.2em,
  row-gutter: 1.2em,
  ..groups.map(g => stack(
    dir: ttb,
    spacing: 0.3em,
    ..g.at("names").map(n => [#n]),
    ..g.at("lines", default: ()).map(l => [#l]),
  )),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines-of(need(meta, "court"), bold: true))
  v(1.5em)
  grid(
    columns: (1.25fr, 1fr),
    column-gutter: 0.6in,
    align(left, caption-parties(need(meta, "parties"))),
    align(left, stack(
      dir: ttb,
      spacing: 0.6em,
      if "origin" in meta [ #meta.at("origin") ],
      { let cn = need(meta, "case_number"); if type(cn) == array { lines-of(cn) } else { [#cn] } },
      if "lower_case" in meta { lines-of(meta.at("lower_case")) },
      if "subject" in meta { lines-of(meta.at("subject")) },
    )),
  )
  v(2.2em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(2.2em)
  counsel-grid(need(meta, "counsel"))
  if "date" in meta {
    v(1.5em)
    align(right)[#meta.at("date")]
  }
}

// ---------------------------------------------------------------------------
// Index (PRAPP-IDX-001): the índice follows the cover. Generated from the headings of the body.
// ---------------------------------------------------------------------------

#let toc-page() = {
  align(center)[#text(weight: "bold")[ÍNDICE]]
  v(1em)
  outline(title: none, depth: toc-depth, indent: 2em)
}

// ---------------------------------------------------------------------------
// Signature block (PRAPP-CERT-001, PRAPP-COVER-002): each counsel signs with name, RUA, e-mail and address
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    #meta.at("closing", default: "RESPETUOSAMENTE SOMETIDO.")
    #if "date" in meta [ #v(0.6em) #meta.at("date") ]
    #v(1.2em)
    #grid(
      columns: (1fr,) * calc.min(sig.at("blocks").len(), 2),
      column-gutter: 1.2em,
      row-gutter: 1.2em,
      ..sig.at("blocks").map(b => stack(
        dir: ttb,
        spacing: 0.3em,
        [#b.at("name")],
        [#b.at("sign", default: "")],
        ..b.at("lines", default: ()).map(l => [#l]),
      )),
    )
  ]
}

#let certificate(c) = {
  block(breakable: true)[
    #set par(leading: body-leading, spacing: para-spacing, first-line-indent: 0pt)
    #v(1.2em)
    #if "heading" in c [ #align(center)[#text(weight: "bold")[#c.at("heading")]] #v(0.6em) ]
    #inl(c.at("text"))
    #if "signer" in c [
      #v(1.2em)
      #set par(leading: single-leading, spacing: single-leading)
      #block(width: 4in)[#c.at("signer")]
    ]
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let prapp-amicus-brief(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  set page(
    paper: "us-letter",
    margin: (left: margin-left, right: margin-right, top: margin-tb, bottom: margin-tb),
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "es", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)

  // Headings: level 1 bold, level 2 bold, level 3 bold italic. The line spacing of the text is kept around them.
  show heading.where(level: 1): it => {
    v(body-leading)
    block(sticky: true, width: 100%, par(first-line-indent: 0pt, text(size: type-size, weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 2): it => {
    v(body-leading)
    block(sticky: true, width: 100%, par(first-line-indent: 0pt, text(size: type-size, weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 3): it => {
    v(body-leading)
    block(sticky: true, width: 100%, par(first-line-indent: 0pt, text(size: type-size, weight: "bold", style: "italic", it.body)))
    v(para-spacing)
  }

  // Block quotations and lists are single-spaced and indented on both sides (PRAPP-FORM-002 excepts quotations).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: body-leading, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it.body
  })

  // List markers are the bullet at every depth (the default en dash of a nested list is not in the face).
  set list(marker: [•])

  // Footnotes (notas al calce) are single-spaced, at the pica size.
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.4em)

  // A printed filing carries no hyperlink targets. A toa: link keeps its text.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") { it.body } else { it.body }
  }

  // Cover (no page number).
  cover(meta)
  pagebreak()

  // Every page after the cover is numbered in Arabic numerals.
  set page(numbering: "1")
  if meta.at("toc", default: true) {
    toc-page()
    pagebreak()
  }

  // Body.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Signature block, then certificates that follow it.
  signature(meta)
  for c in meta.at("certificates", default: ()) { certificate(c) }
}
