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
//   - a note never starts on a page before its mark: a paragraph a block only wraps (or a left `pad` in it) is laid
//     out bare once a note of it did (unwrap-note-par, below; fb-595.54.11.1), and a bare paragraph then without its
//     widow and orphan cost, so its mark's line stays with the note (loosen-note-par; fb-595.54.11.4). When no line
//     of a note fits on its mark's page, the line moves on with it, as LaTeX does; LibreOffice does that only on a
//     page with no note yet (docs/open-items/fb-595.54.11.4.md).
//   - a note split over a page end keeps typst's widow and orphan cost, as LaTeX keeps \clubpenalty/\widowpenalty
//     10000 inside notes and Word's Footnote Text keeps its lines together: a zero cost (LibreOffice's any-line
//     split) moved 32 renders and broke the line match in about 25 gated folders (fb-595.54.11.3).
//   - with `footnote-widows: false`, no footnote widows: a paragraph whose last line carries a footnote that does not
//     fit with it carries its second-to-last line over too, as LaTeX and Word do (widow-start, below; fb-595.54.9).
//     Opt-in: by default typst may set such a widow, and the LaTeX and Word filters turn widow control off for a
//     paragraph that anchors a footnote instead (the federal-circuit folders, fb-595.54.6); the rule's layout can
//     fail to settle in a long document whose notes move between passes, so a template enables it only where it
//     renders without warnings.
//   - with `show: docx-portions` over a stretch of text, an emph or strong span's ends floored to a twip, as
//     LibreOffice measures its runs (portion-piece, below; fb-595.54.10).
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

// Whether a note marked between `me` and the marker after it (`end`: its label, with the value `me`) starts on a page
// before its mark.
#let note-before-mark(me, end) = {
  let stop = query(end).filter(m => m.value == me)
  let notes = if stop.len() == 0 { () } else { query(selector(footnote).after(me).before(stop.first().location())) }
  let marks = notes.map(n => n.location())
  query(footnote.entry).any(e => e.note.location() in marks and e.location().page() < e.note.location().page())
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
// The paragraph may sit in a `pad` that only indents it on the left (lib/typst/xdoc.typ's list items): the bare
// paragraph then indents every line by that much more (Md. Ct. App. petition-for-writ note 147, fb-595.54.11.4).
#let unwrap-note-par(it) = {
  let b = it.body
  let left = 0pt
  if type(b) == content and b.func() == pad {
    let pf = b.fields()
    let body = pf.remove("body")
    let l = pf.remove("left", default: 0pt)
    if type(l) == relative and l.ratio == 0% { l = l.length }
    if pf.values().any(v => v != 0pt) or type(l) != length { return it }
    (b, left) = (body, l)
  }
  if type(b) != content or b.func() != par or not has-note(b.body) or it.has("label") { return it }
  let f = it.fields()
  if not (f.breakable and f.height == auto and f.width in (auto, 100%) and f.fill == none and not f.clip
    and not f.sticky and (f.stroke, f.inset, f.outset) == ((:), (:), (:))) { return it }
  context {
    let me = here()
    let s = par.spacing.to-absolute()
    let bare = if f.above.to-absolute() != s or f.below.to-absolute() != s { false }
      else if query(<xe-bare>).any(m => m.value == me) { true } else { note-before-mark(me, <xe-np-end>) }
    if bare {
      let pf = b.fields()
      let body = pf.remove("body")
      let fi = pf.at("first-line-indent", default: par.first-line-indent)
      if type(fi) != dictionary { fi = (amount: fi, all: false) }
      let hi = pf.remove("hanging-indent", default: par.hanging-indent)
      [#metadata(me)<xe-bare>]
      par(..pf, first-line-indent: (amount: left + if fi.at("all", default: false) { fi.amount } else { 0pt },
        all: true), hanging-indent: left + hi, body)
    } else { it }
    [#metadata(me)<xe-np-end>]
  }
}

// Nor does a note of a bare paragraph (fb-595.54.11.4). typst keeps a paragraph's first and last two lines together
// (its widow and orphan cost) after it has placed the note of the line it lays: when the next line does not fit
// below that one, both move on and the note stays behind (a mark on the second-to-last line, its note started at
// the foot of the page before: 14 pt type on 31.4 pt lines with 20 pt notes, ca10 reply-brief). Such a paragraph is
// laid out without that cost once one of its notes started on a page before its mark, so its mark's line stays with
// the note and the line after it moves on alone, as Word sets a paragraph that anchors a note (Body Text Note: no
// widow control) and LaTeX where its filter turns widow control off for it. <xe-loose> holds it. The notes keep the
// cost (fb-595.54.11.3): a note's entry takes the styles of its mark, not of the paragraph's show rule. A paragraph
// whose notes all start on their marks' pages is laid out as before. (By the time a paragraph is shown its footnotes
// are, so only a paragraph that holds an element's tag is looked at.)
#let loosen-note-par(it) = {
  let b = it.body
  if not (type(b) == content and b.has("children") and b.children.any(c => repr(c.func()) == "tag")) { return it }
  context {
    let me = here()
    if query(<xe-loose>).any(m => m.value == me) or note-before-mark(me, <xe-lp-end>) {
      [#metadata(me)<xe-loose>]
      set text(costs: (widow: 0%, orphan: 0%))
      it
    } else { it }
    [#metadata(me)<xe-lp-end>]
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

// Word's text portions (fb-595.54.10). LibreOffice lays a line out in portions, one per run of like formatting (an
// italic or bold span, the text either side of it), and gives a portion it sets whole a width in whole twips,
// rounded down; inside a portion, and in the portion a line breaks in, it adds the glyphs' advances unrounded. So the
// portion after a span starts where the span ends, floored to a twip (the line starts on a whole twip: the margins and
// indents are whole twips), and a line fits iff the floored widths of its whole portions and the unrounded width of
// its last one sum to no more than the measure. Measured on the ca8 reply brief's docx PDF: each of the 418 portion
// starts in it lies at the floor of the portion's unrounded advance; the rounded advance matches 280, the unrounded
// one 224, a sum of glyphs or words rounded or floored 301, 191 and 258. Under `show: docx-portions` each emph or
// strong span does the same here: the text after its start, and from its end on, moves left by what that position
// lies past a whole twip. The shift goes inside the span's first (last) two characters, as tracking, which adds no
// break opportunity and keeps the PDF text as written. Each piece records its shift; a piece recomputes the shifts of
// its line from the positions and shifts the last pass laid out (both of the same pass), so the layout settles a pass
// after its line breaks do. A template scopes it to text that is not laid out more than once (not a cover fitted by
// measure, nor contents rows): there the pieces would not settle in typst's five passes. Not modelled: a span of one
// character, and the portions Word starts elsewhere (a footnote mark, a no-break or zero-width space the filters
// write).
#let twip = 0.05pt
#let past-twip(x) = calc.max(0pt, x - calc.floor(x / twip + 1e-6) * twip)

// Two characters of a span, `s`, the shift of its boundaries inside them: `start` (the span starts at `s`), `rest`
// (the span ends after `rest`, which starts with `s`; none if it does not).
#let portion-piece(s, start, rest) = context {
  let me = here()
  let p = me.position()
  let offs = if start { (0pt,) } else { () }
  if rest != none { offs.push(measure(rest).width) }
  // the pieces before this one on its line, as the last pass placed them, and their shifts then
  let raws = ()
  let old = 0pt
  for m in query(selector(<xe-tw>).before(me, inclusive: false)) {
    let q = m.location().position()
    if q.page == p.page and calc.abs((q.y - p.y) / 1pt) < 0.01 {
      raws.push((x: q.x + old, offs: m.value.offs))
      old += m.value.shift
    }
  }
  raws.push((x: p.x + old, offs: offs))
  let acc = 0pt
  let shift = 0pt
  // the first pass knows no positions (every one is the page origin): it shifts nothing
  if p.x == 0pt and p.y == 0pt { raws = () }
  for r in raws {
    let pos = r.x - acc
    shift = 0pt
    for o in r.offs { shift += past-twip(pos + o - shift) }
    acc += shift
  }
  [#metadata((shift: shift, offs: offs))<xe-tw>]
  text(tracking: text.tracking - shift, s)
}

// A span's body with its boundaries' pieces: the first characters of its first text (`start`), the last of its last
// (`end`). A body that is not text or a sequence of it is left as it is.
#let portion-split(body, start, end) = {
  if type(body) != content or not (start or end) { return body }
  if body.func() == text {
    let cs = body.text.clusters()
    let n = cs.len()
    if n < 2 { return body }
    let cat(a, b) = cs.slice(a, b).sum(default: "")
    if start and end and n < 4 { return portion-piece(cat(0, 2), true, body.text) + cat(2, n) }
    let head = if start { portion-piece(cat(0, 2), true, none) } else { cat(0, 2) }
    if not end { return head + cat(2, n) }
    let tail = portion-piece(cat(n - 2, n), false, cat(n - 2, n))
    return if start { head + cat(2, n - 2) + tail } else { cat(0, n - 2) + tail }
  }
  if body.has("children") {
    let cs = body.children
    if cs.len() == 0 { return body }
    if cs.len() == 1 { return portion-split(cs.first(), start, end) }
    return (portion-split(cs.first(), start, false), ..cs.slice(1, -1), portion-split(cs.last(), false, end)).join()
  }
  body
}

/// Word's text portions for `body` (show: docx-portions): each emph or strong span's boundaries floored to a twip
/// (portion-piece, above).
#let docx-portions(body) = {
  show emph: it => if it.at("label", default: none) == <xe-portion> { it } else {
    [#emph(portion-split(it.body, true, true))<xe-portion>]
  }
  show strong: it => if it.at("label", default: none) == <xe-portion> { it } else {
    [#strong(delta: it.delta, portion-split(it.body, true, true))<xe-portion>]
  }
  body
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
  // Nor in a bare paragraph whose last (first) two lines typst keeps together (loosen-note-par, above).
  show par: loosen-note-par
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
