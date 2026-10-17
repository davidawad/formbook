// Complaint for the U.S. District Court for the Western District of Kentucky (kywd).
// Rules: LR 5.2(a) (8 1/2 x 11 page, margins of at least one inch on all sides, text double spaced except
// block quotes, headings and footnotes, 12-point proportionately spaced font); Fed. R. Civ. P. 10(a) (caption:
// court, title, file number, Rule 7(a) designation) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // LR 5.2(a): proportionately spaced; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // LR 5.2(a): at least 12-point
#let page-w = 8.5in                     // LR 5.2(a): 8 1/2 x 11 inch page
#let page-h = 11in
#let margin = 1in                       // LR 5.2(a): margins of at least one inch on all sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // LR 5.2(a): double spaced (24 pt baseline pitch at 12 pt; measured, README.md)
#let single-leading = 0.495em            // block quotes, headings, caption and signature: single spaced
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.1in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kywd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a)): court title, then the party column closed by a column of ")" marks,
// the file number on the "vs." row, and the title of the paper centered below.
// ---------------------------------------------------------------------------

#let court-title(meta) = stack(
  dir: ttb,
  spacing: single-leading,
  ..meta.court.map(l => align(center, text(weight: "bold", l))),
)

/// One row per line of the party column. "vs." sits between the parties; designations are indented.
#let caption-rows(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      rows.push((t: "", indent: 0in))
      rows.push((t: "vs.", indent: 0.75in))
      rows.push((t: "", indent: 0in))
    }
    for n in p.names {
      rows.push((t: n, indent: 0in))
    }
    rows.push((t: p.designation, indent: 1.5in))
  }
  rows
}

#let caption(meta) = {
  let rows = caption-rows(meta)
  let case-row = rows.position(r => r.t == "vs.")
  if case-row == none { case-row = 0 }
  // The ")" column is one mark per row, so the column is as tall as the party column (the grid row height).
  grid(
    columns: (caption-left, 0.3in, 1fr),
    row-gutter: single-leading,
    ..rows.enumerate().map(((i, r)) => (
      block(width: 100%, inset: (left: r.indent), r.t),
      [)],
      if i == case-row [CASE NO. #meta.case_number] else [],
    )).flatten(),
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", meta.title))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lists, and the signature and jury-demand blocks
// ---------------------------------------------------------------------------

/// The signature block (LR 5.2(a) sets no form; the layout follows the filed exemplar).
#let signature-block(sig) = block(width: 100%, breakable: false, {
  v(body-leading)
  pad(left: 3.25in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading)
    [By: /s/ #sig.by]
    v(body-leading)
    stack(
      dir: ttb,
      spacing: single-leading,
      ..sig.lines.map(l => if l == "" { v(body-leading) } else { [#l] }),
    )
  })
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph; a paragraph beginning "WHEREFORE" is the unnumbered
/// prayer lead-in. Numbering is applied per chunk, not with a `show par` rule (a show rule that re-wraps
/// paragraph content recurses without end in typst 0.15).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading: its show rule sets the block spacing and keeps it with the paragraph after it.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are spaced by body-leading (set enum/list in kywd-complaint); a list may break across pages.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("WHEREFORE") {
      [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
    } else {
      // Paragraph spacing (par.spacing = body-leading) makes the gap between paragraphs one double-spaced line.
      para-counter.step()
      context [#h(para-indent)#(para-counter.display()).#h(0.5in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
    }
    parbreak()
  }
}

#let kywd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.5in, spacing: body-leading)

  // Headings: level 1 is a centered bold caps section; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  allegations(body, para-counter)

  signature-block(meta.signature)

  if "jury_demand" in meta and meta.jury_demand != none {
    block(width: 100%, sticky: true, above: body-leading, below: body-leading,
      align(center, text(weight: "bold", meta.jury_demand.heading)))
    [#h(para-indent)#inl(meta.jury_demand.text)]
    signature-block(meta.signature)
  }
}
