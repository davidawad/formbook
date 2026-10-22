// The cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.54, fb-595.54.1): the typst render
// is the reference the LaTeX (lib/latex/xengine.sty) and Word (lib/docx/xengine.lua) renders break every line and
// page alike with. Apply it once in a template, after its own `set text` (font, size) and `set par` (indents):
//
//   #import "/lib/typst/xengine.typ": xengine, edges, listing-row
//   show: xengine.with(pitch: 29.4pt)
//
// What it sets, for every engine alike:
//   - no kerning, no ligatures, no hyphenation (Word sets none of them by default; pdfTeX turns them off);
//   - first-fit line breaking (typst "simple"), ragged right, as Word and LibreOffice break lines;
//   - exact line spacing: every line a box of its pitch with the baseline at 0.8 of it, the boxes touching (leading
//     0), no paragraph spacing of its own (blocks bring theirs; between two blocks the larger applies);
//   - footnote marks at 58 % of the type size that do not make their line taller;
//   - no break inside a token of adjacent parentheses ("60(b)(5)"), none between a section sign or pilcrow and its
//     number (the LaTeX and Word filters bind them with a no-break space);
//   - lists: the number or bullet in a box of `list-indent` at the margin, the text hanging after it, with no space
//     of their own (`list-indent: none` keeps typst's lists).
// The template keeps its own numbers: type size, pitches (`edges`), spacings, indents, page column widths.

/// The line box of a pitch: the baseline at 0.8 of it (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let edges(pitch) = (top-edge: 0.8 * pitch, bottom-edge: -0.2 * pitch)

#let xengine(pitch: none, list-indent: 0.5in, body) = {
  if pitch == none { panic("xengine: `pitch` (the body's line pitch) is required") }
  set text(hyphenate: false, kerning: false, ligatures: false, ..edges(pitch))
  set par(leading: 0pt, spacing: 0pt, linebreaks: "simple", justify: false)
  // A superscript (a footnote mark) does not make its line taller: its box is the line's own.
  show super: set text(top-edge: "baseline", bottom-edge: "baseline")
  // Footnote marks at 58 % of the type size: LibreOffice's superscript, which the LaTeX engine sets too.
  set super(size: 0.58em)
  // Never break inside a token of adjacent parentheses, nor between a section sign / pilcrow and its number.
  // Unbreakable boxes, so the extracted text stays exactly the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  // An item of a loose list (blank lines between the items) ends in a paragraph break; inside the item's paragraph
  // it means nothing (the items have no space of their own), so it is dropped.
  let unloose(body) = {
    if body.func() != [].func() { return body }
    let cs = body.children
    if not cs.any(c => c.func() == parbreak) { return body }
    while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
    while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
    cs.join()
  }
  let list-item(lab, body) = block(above: 0pt, below: 0pt,
    par(hanging-indent: list-indent, first-line-indent: 0pt, { box(width: list-indent, lab); unloose(body) }))
  show enum: it => if list-indent == none { it } else {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      list-item(numbering(it.numbering, n), item.body)
      n += 1
    }
  }
  show list: it => if list-indent == none { it } else {
    for item in it.children { list-item([•], item.body) }
  }
  body
}

/// One row of a table of contents or of authorities: the text wraps before a column of width `col` kept for the
/// page number, and a dot leader runs from the end of the text to the number on the last line (Word's layout: a
/// right indent and a right tab beyond it; LaTeX \xe@row), at least three spaces after it. Rows are not split
/// across pages. `target`: a location the row links to, or none.
#let listing-row(target, body, page, col, hang-by, above) = {
  let row = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
    columns: (1fr, col), column-gutter: 0pt,
    par(hanging-indent: hang-by, first-line-indent: 0pt, leading: 0pt, justify: false, {
      body
      h(0.75em)   // the leader is never shorter than three spaces, and it does not leave the last word
      box(width: 1fr, repeat[.])
    }),
    align(right + bottom, page),
  ))
  if target == none { row } else { link(target, row) }
}
