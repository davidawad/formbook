// Trademark Trial and Appeal Board: notice of opposition (combined or single).
//
// Rule-driven and content-agnostic. Rule IDs (TTAB-NOP-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed notice, no forced line breaks.
// The body is rendered by cmarker; the caption, applications and signature come from the
// YAML frontmatter of the same sample (schema: ../README.md, "Markdown contract").
// Paragraph numbers are typed in the markdown, as filed; the template does not number them.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a stated choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")           // vendored in /fonts; no system fallback (render.sh)
#let type-size = 12pt                       // TTAB-NOP-FORM-001: at least 11-point (37 CFR 2.126(a)(1))
#let body-leading = 0.695em                 // TTAB-NOP-FORM-002: double-spaced (24 pt pitch at 12 pt); measured in ../README.md
#let single-leading = 0em                   // caption, headings, signature block, exhibit slip sheets
#let page-margin = 1in                      // TTAB-NOP-FORM-003: convention for 8.5 x 11 paper (tier 2)
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ttab-notice-of-opposition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-notice-of-opposition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Front matter of the filing: the USPTO heading, the applications, the caption, the title
// ---------------------------------------------------------------------------

/// TBMP 309.02(a): the heading the Board requires at the top of the complaint.
#let board-heading() = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, strong[
    IN THE UNITED STATES PATENT AND TRADEMARK OFFICE\
    BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD
  ])
}

/// TBMP 309.02(a): identification of the application(s) opposed.
#let applications-block(meta) = {
  let apps = meta.at("applications", default: ())
  for app in apps {
    block(breakable: false, above: 1.2em, below: 0.4em, {
      set par(leading: single-leading, first-line-indent: 0pt)
      grid(
        columns: (2.2in, 1fr),
        row-gutter: 0.35em,
        [In re Application of:], [#inl(app.applicant)],
        [Serial No.:], [#app.serial],
        [Mark:], [#inl(app.mark)],
        [Application Date:], [#app.application_date],
        [Publication Date:], [#app.publication_date],
      )
    })
  }
}

/// The party caption: names on the left, a column of ")" for each line, and the opposition number
/// on the right. Every row is one line, so the parentheses line up with the names by construction.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for name in side.names {
      rows.push(inl(name))
    }
    rows.push(pad(left: 2.1in, inl(side.designation)))
    if i < sides.len() - 1 {
      rows.push([])
      rows.push(pad(left: 1.2in, [v.]))
      rows.push([])
    }
  }
  let n = rows.len()
  let number = if "opposition_no" in meta { meta.opposition_no } else { "______________" }
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(r)
    cells.push([)])
    // The right-hand cell spans every row of the caption, so it sits beside the whole block.
    if i == 0 { cells.push(table.cell(rowspan: n, align(horizon, [Opposition No. #number]))) }
  }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  table(
    columns: (3.4in, 0.35in, 2.4in),
    stroke: none,
    inset: (x: 0pt, y: 0.12em),
    align: (left, center, left),
    ..cells,
  )
}

// ---------------------------------------------------------------------------
// Body styles
// ---------------------------------------------------------------------------

/// Headings in a notice: count headings are centered and bold, in capitals.
#let style-heading(it) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  block(width: 100%, sticky: true, above: 1.4em, below: 1em,
    align(center, strong(upper(it.body))))
}

// ---------------------------------------------------------------------------
// Signature and exhibits
// ---------------------------------------------------------------------------

/// Signature block (37 CFR 2.193(c): the electronic signature is "/Name/").
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.6em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if "date" in meta [Date: #meta.date]
    pad(left: 3.0in, [
      Respectfully submitted,
      #v(1.2em)
      By: /#sig.signer/
      #linebreak()
      #for l in sig.lines [#inl(l)#linebreak()]
    ])
  })
}

/// One slip sheet per exhibit, on its own page: "EXHIBIT 1" with its description underneath.
#let exhibit-slip-sheets(meta) = {
  for ex in meta.at("exhibits", default: ()) {
    let parts = ex.split(":")
    let label = parts.at(0).trim()
    let desc = parts.slice(1).join(":").trim()
    pagebreak()
    v(1fr)
    align(center, {
      set par(leading: single-leading, first-line-indent: 0pt)
      strong(upper(label))
      if desc != "" { parbreak(); inl(desc) }
    })
    v(1fr)
  }
}

// ---------------------------------------------------------------------------
// The notice
// ---------------------------------------------------------------------------

#let ttab-notice-of-opposition(meta, md) = {
  set document(title: need(meta, "title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center)
  set text(
    font: font-family, size: type-size, lang: "en",
    top-edge: "ascender", bottom-edge: "descender",   // the line box is the font's own ascender-to-descender height
  )
  // Body text is double-spaced, and the first line of each paragraph is indented.
  set par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false, spacing: 0pt)
  show heading: it => style-heading(it)

  board-heading()
  applications-block(meta)
  v(1.2em)
  caption-table(meta)
  v(1.2em)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(0.6em)

  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  render(md)

  signature-block(meta)
  exhibit-slip-sheets(meta)
}
