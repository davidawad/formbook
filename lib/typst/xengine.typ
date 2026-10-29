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
//   - with `footnote-widows: false`, no footnote widows: a paragraph whose last line carries a footnote that does not
//     fit with it carries its second-to-last line over too, as LaTeX and Word do (widow-start, below; fb-595.54.9).
//     Opt-in: by default typst may set such a widow, and the LaTeX and Word filters turn widow control off for a
//     paragraph that anchors a footnote instead (the federal-circuit folders, fb-595.54.6); the rule's layout can
//     fail to settle in a long document whose notes move between passes, so a template enables it only where it
//     renders without warnings.
// The template keeps its own numbers: type size, pitches (`edges`), spacings, indents, page column widths.

/// The line box of a pitch: the baseline at 0.8 of it (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let edges(pitch) = (top-edge: 0.8 * pitch, bottom-edge: -0.2 * pitch)

// One side of the page margin as an absolute length, or none (auto, a ratio, inside/outside).
#let page-margin(side) = {
  let m = page.margin
  if type(m) == dictionary {
    m = m.at(side, default: m.at(if side in ("top", "bottom") { "y" } else { "x" }, default: m.at("rest", default: none)))
  }
  if type(m) == relative and m.ratio == 0% { m = m.length }
  if type(m) == length { m.to-absolute() } else { none }
}

/// Whether content holds a footnote (its mark).
#let has-note(c) = {
  if type(c) != content { return false }
  if c.func() == footnote { return true }
  if c.has("children") { return c.children.any(has-note) }
  if c.has("body") { return has-note(c.body) }
  if c.has("child") { return has-note(c.child) }
  false
}

// A note never starts on a page before its mark (fb-595.54.11.1). A footnote in a paragraph a template wraps in a
// breakable block cannot take its line on with it: when the line and its note do not both fit, typst may keep the
// note where the line was first laid and move the line on alone (lawb motion-brief: note 7 on page 4, its mark on
// page 5). A bare paragraph moves the line and its note on together, as LaTeX and Word do. So a block that only wraps
// a paragraph (no size, box, fill, stroke, keep or label of its own, its spacing the paragraph spacing) is laid out
// as the bare paragraph, with the same lines and spacing and its first line indented as the first paragraph of a
// block is (only with `all: true`), once one of its notes started on a page before its mark: on the next layout
// pass, and from then on (<xe-bare> holds it, so the layout converges). A block whose notes all start on their marks'
// pages is laid out as before (a note too long for the rest of its mark's page then follows on the next page).
#let unwrap-note-par(it) = {
  let b = it.body
  if type(b) != content or b.func() != par or not has-note(b.body) or it.has("label") { return it }
  let f = it.fields()
  if not (f.breakable and f.height == auto and f.width in (auto, 100%) and f.fill == none and not f.clip
    and not f.sticky and (f.stroke, f.inset, f.outset) == ((:), (:), (:))) { return it }
  context {
    let me = here()
    let s = par.spacing.to-absolute()
    let bare = if f.above.to-absolute() != s or f.below.to-absolute() != s { false }
      else if query(<xe-bare>).any(m => m.value == me) { true } else {
      let end = query(<xe-np-end>).filter(m => m.value == me)
      let notes = if end.len() == 0 { () } else { query(selector(footnote).after(me).before(end.first().location())) }
      let marks = notes.map(n => n.location())
      query(footnote.entry).any(e => e.note.location() in marks and e.location().page() < e.note.location().page())
    }
    if bare {
      let pf = b.fields()
      let body = pf.remove("body")
      let fi = pf.at("first-line-indent", default: par.first-line-indent)
      if type(fi) != dictionary { fi = (amount: fi, all: false) }
      [#metadata(me)<xe-bare>]
      par(..pf, first-line-indent: (amount: if fi.at("all", default: false) { fi.amount } else { 0pt }, all: true), body)
    } else { it }
    [#metadata(me)<xe-np-end>]
  }
}

// The marker the line count of a paragraph is measured under (so the measured copy does not place a guard itself).
#let measuring = 0.0123pt

// Footnote widows. typst keeps a paragraph's last two lines together by their heights alone: when the last line
// carries a footnote that does not fit below it, the line moves to the next page by itself, a widow LaTeX and Word
// never set (they move the line before it too). Each paragraph is tagged where it starts (<xe-ps>) and ends
// (<xe-pe>); a footnote whose line is a widow (its paragraph started on the page before and has only this line on
// this one) flags the paragraph by the position of its start, and on the next layout pass the paragraph places an
// empty float at the foot of its first page that ends the text half a line above the bottom of its second-to-last
// line, so that line moves on with the last. The flag holds while the float stands (the layout then converges);
// a paragraph without such a footnote is laid out exactly as before.
#let widow-start(it) = context {
  let me = here().position()
  if par.spacing == measuring or not query(<xe-widow>).any(m => m.value == me) { return }
  let (mt, mb, ml, mr) = ("top", "bottom", "left", "right").map(page-margin)
  if none in (mt, mb, ml, mr) { return }
  let pitch = (text.top-edge - text.bottom-edge).to-absolute()
  // where the text ends on that page: the float's own foot when it stood on the last pass, else the bottom margin
  let prev = query(<xe-float>).filter(f => f.value.par == me)
  let floor = if prev.len() > 0 { prev.first().location().position().y + prev.first().value.h } else { page.height - mb }
  // the paragraph's lines (every line a box of the pitch), measured without its footnotes
  let fields = it.fields()
  let body = fields.remove("body")
  if body.has("children") { body = body.children.filter(c => repr(c.func()) != "tag").join() }
  let lines = calc.round(measure({ set par(spacing: measuring); par(..fields, body) },
    width: page.width - ml - mr).height / pitch)
  let h = floor - me.y - (lines - 1.5) * pitch
  if h > 0pt {
    place(bottom, float: true, clearance: 0pt, block(width: 0pt, height: h, [#metadata((par: me, h: h))<xe-float>]))
  }
}

#let widow-check() = context {
  let mark = here()
  let top = page-margin("top")
  if top == none { return }
  // the paragraph the mark is in: its start and end tags, matched by nesting (a footnote entry is a paragraph too,
  // and its tags may fall between the mark and its paragraph's end)
  let tags = selector(<xe-ps>).or(<xe-pe>)
  let enclosing(list, open) = {
    let depth = 0
    for t in list {
      if (t.label == open) { if depth == 0 { return t.location().position() }; depth -= 1 } else { depth += 1 }
    }
    none
  }
  let s = enclosing(query(tags.before(mark, inclusive: false)).rev(), <xe-ps>)
  let ep = enclosing(query(tags.after(mark, inclusive: false)), <xe-pe>)
  if s == none or ep == none { return }
  let pitch = (text.top-edge - text.bottom-edge).to-absolute()
  let m = mark.position()
  let line-top = m.y - text.top-edge.to-absolute()
  let widow = (s.page + 1 == m.page and ep.page == m.page and line-top < top + 0.5 * pitch
    and ep.y <= line-top + pitch + 0.5pt)
  if widow or query(<xe-float>).any(f => f.value.par == s) [#metadata(s)<xe-widow>]
}

#let xengine(pitch: none, list-indent: 0.5in, footnote-widows: true, body) = {
  if pitch == none { panic("xengine: `pitch` (the body's line pitch) is required") }
  set text(hyphenate: false, kerning: false, ligatures: false, ..edges(pitch))
  set par(leading: 0pt, spacing: 0pt, linebreaks: "simple", justify: false)
  // A superscript (a footnote mark) does not make its line taller: its box is the line's own.
  show super: set text(top-edge: "baseline", bottom-edge: "baseline")
  // Footnote marks at 58 % of the type size: LibreOffice's superscript, which the LaTeX engine sets too.
  set super(size: 0.58em)
  // A paragraph that anchors a footnote laid out bare, not in a block that only wraps it (unwrap-note-par, above).
  show block: unwrap-note-par
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
  // No footnote widows (widow-start, above), when the template asks for it.
  if footnote-widows { body } else {
    show par: it => [#widow-start(it)<xe-ps>#it#metadata(none)<xe-pe>]
    show footnote: it => it + widow-check()
    body
  }
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
