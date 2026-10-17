// Memorandum of law in support of a motion to dismiss, United States District Court, S.D. W. Va. (wvsd).
// Rules: LR Civ P 7.1(a)(2) (length), (a)(3) (paper, double spacing, margins), (a)(4) (typeface),
// (a)(6) (a motion to dismiss is a separate pleading); Fed. R. Civ. P. 10(a) (caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 7.1(a)(4): proportional face; Times New Roman is on the presumed-legible list; this is its substitute (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // LR 7.1(a)(4): 12-point or larger; footnotes included
#let page-w = 8.5in                     // LR 7.1(a)(3): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 7.1(a)(3): at least one inch on all four sides
#let body-leading = 1.345em             // LR 7.1(a)(3) double spacing: Liberation Serif line box 0.655em + 1.345em = 24 pt at 12 pt
#let single-leading = 0.5em             // single spacing for caption, counsel, headings, quotations, footnotes (LR 7.1(a)(3) allows)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.0in               // width of the party column of the caption
#let caption-paren = 0.3in              // the column of ")" marks between parties and the case number
#let block-indent = 3.25in              // counsel block and signature block start here
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines; "" is a blank line.
#let lines-block(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => if i == "" { v(single-leading * 2) } else { inl(i) }))

/// Heading numbers, set by the template (never typed in the sample). Level 1 is unnumbered.
/// Level 2 I., level 3 A., level 4 1., level 5 a.
#let heading-numbering(..n) = {
  let level = n.pos().len()
  let num = n.pos().last()
  if level == 2 { numbering("I.", num) }
  else if level == 3 { numbering("A.", num) }
  else if level == 4 { numbering("1.", num) }
  else if level == 5 { numbering("a.", num) }
  else { none }
}

// ---------------------------------------------------------------------------
// Cover page: court title, caption, title of the paper, counsel (the caption page carries no page number)
// ---------------------------------------------------------------------------

/// The caption: one row per party line, a column of ")" marks, and the case number at the right.
/// A side's `lead` is printed before it ("v." by default between sides; "" for none).
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  let rows = ()
  for (k, side) in meta.caption.enumerate() {
    let lead = side.at("lead", default: if k == 0 { "" } else { "v." })
    if lead != "" { rows.push(pad(left: 0.5in, inl(lead))) }
    for n in side.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.0in, inl(side.designation)))
    rows.push(v(single-leading * 2))
  }
  rows = rows.slice(0, rows.len() - 1)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(r)
    cells.push(")")
    if i == 0 {
      cells.push(grid.cell(rowspan: rows.len(), align(horizon, pad(left: 0.2in, {
        set par(leading: single-leading, first-line-indent: 0pt)
        [#meta.civil_action #linebreak() #meta.judge]
      }))))
    }
  }
  grid(columns: (caption-left, caption-paren, 1fr), row-gutter: single-leading, ..cells)
}

#let cover(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  align(center, text(weight: "bold")[
    IN THE UNITED STATES DISTRICT COURT \
    FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA \
    #upper(meta.division)
  ])
  v(24pt)
  caption(meta)
  v(24pt)
  align(center, text(weight: "bold", meta.brief_title))
  v(36pt)
  pad(left: block-indent, {
    let items = ()
    for g in meta.counsel {
      items += g.names
      items += g.lines
      items.push("")
    }
    lines-block(items)
  })
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, block quotations, footnotes
// ---------------------------------------------------------------------------

/// The signature block: "Dated" on the left line, then the signature lines at the right, kept together.
#let signature-block(meta) = block(breakable: false, above: 24pt, {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  [Dated: #meta.date]
  v(24pt)
  pad(left: block-indent, lines-block(meta.signature))
})

// ---------------------------------------------------------------------------
// The memorandum: cover (no number), then the body numbered from 1, then the signature block
// ---------------------------------------------------------------------------

#let memorandum(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en")
  set heading(numbering: heading-numbering)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  // Show rules live here, not at file top level: a module's show rules do not reach the importing document.
  show heading.where(level: 1): it => block(width: 100%, above: 18pt, below: 12pt, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), text(weight: "bold", it.body)))
  show heading.where(level: 3): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 0.5in, grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), text(weight: "bold", it.body))))
  show heading.where(level: 4): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 1.0in, grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body)))
  show heading.where(level: 5): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 1.5in, grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body)))
  show quote.where(block: true): it => block(above: 12pt, below: 12pt, inset: (left: 0.5in, right: 0.5in), {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    it.body
  })
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  cover(meta)
  pagebreak()
  set page(numbering: "1", number-align: center)
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature-block(meta)
}
