// The shared document model (fb-595.54.12): a doc folder's whole layout as data, `typst/layout.yaml`, set by this
// file in typst and by lib/latex/xdoc.lua and lib/docx/xdoc.lua in the other engines, which `fb engines gen`
// (tools/fb/src/enginegen) wires into the folder's latex/ and docx/. All three read the same layout and the same
// sample, and lay every block out on the cross-engine model (lib/typst/xengine.typ: first fit, exact line boxes,
// no kerning, ligatures or hyphenation), so the latex and docx renders break every line and page where this one
// does by construction. The grammar of layout.yaml is in docs/EVAL-LOOP.md, "Generated engines"; in short:
//
//   font, size, pitch: {body, single}, margin: {top, bottom, left, right}, indent, list_indent,
//   page_number: {align, from}, footnote: {size, pitch, gap, clearance}, quote: {left, right, above, below, gap},
//   heading: [level 1, level 2, ...] (each a text style plus above/below), front: [blocks], closing: [blocks],
//   tail: {at, pitch, indent, gap, above}
//   blocks: {text: "literal with {field} or {a.b}", <style>}, {rule: <stroke>, above, below},
//           {columns: [{width, blocks}, ..], gutter}, {each: field, blocks, between}, {group: [blocks], keep}
//   style: align (left, center, right), bold, italic, upper, underline, left, right, hang, above, below, pitch
//          (body, single or a number), keep, optional
//
// Lengths are points (twips = 20 x pt in Word, bp in LaTeX); every number belongs in layout.yaml, with its rule.
#import "@preview/cmarker:0.1.10"
#import "xengine.typ": xengine, edges

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("xdoc: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let pt(x) = if x == none { 0pt } else { x * 1pt }

// A rule's line box besides its stroke (lib/pandoc/xdoc.lua RULE): LibreOffice's smallest exact line, one twip.
#let RULE = 0.05

/// The value at a dotted path ("a.b", "." the context itself), or none (an empty string too); "a.b|text": the text
/// when there is none (a blank a filer completes, e.g. "{service.date|____________}"; lib/pandoc/xdoc.lua lookup alike).
#let lookup(ctx, path) = {
  let bar = path.position("|")
  if bar != none {
    let v = lookup(ctx, path.slice(0, bar))
    return if v == none { path.slice(bar + 1) } else { v }
  }
  if path == "." { return ctx.at(".", default: none) }
  let v = ctx
  for k in path.split(".") {
    if type(v) == dictionary and k in v { v = v.at(k) } else { return none }
  }
  // an empty string prints nothing: it is missing
  if v == "" { none } else { v }
}

/// The paragraphs of a text template: "{path}" alone and a list value gives one per item; otherwise every {path} is
/// replaced by its value. Each paragraph is then split at "<br>" (a line of its own in every engine). A missing
/// value panics, or gives no paragraph when `optional`.
#let expand(tpl, ctx, optional) = {
  let tpl = str(tpl)
  let whole = tpl.match(regex("^\\{([^{}]+)\\}$"))
  let out = ()
  if whole != none and type(lookup(ctx, whole.captures.at(0))) == array {
    out = lookup(ctx, whole.captures.at(0)).map(str)
  } else {
    let missing = false
    let s = tpl
    for m in tpl.matches(regex("\\{([^{}]+)\\}")) {
      let v = lookup(ctx, m.captures.at(0))
      if v == none {
        if optional { missing = true } else { panic("xdoc: missing required metadata field `" + m.captures.at(0) + "`") }
      } else {
        s = s.replace(m.text, str(v))
      }
    }
    out = if missing { () } else { (s,) }
  }
  out.map(s => s.split("<br>")).flatten()
}

/// The pitch of a style: body, single (the default) or a number of points.
#let pitch-of(spec, p) = {
  if p == none or p == "single" { pt(spec.pitch.single) } else if p == "body" { pt(spec.pitch.body) } else { pt(p) }
}

/// Text in a style: bold, italic, upper, underline.
#let styled(st, body) = {
  let b = body
  if st.at("underline", default: false) { b = underline(b) }
  if st.at("italic", default: false) { b = emph(b) }
  if st.at("bold", default: false) { b = strong(b) }
  b
}

/// One paragraph block of a style (a line of the front matter, a heading, a closing line).
#let line-block(spec, st, body, above, below) = block(width: 100%, above: above, below: below,
  sticky: st.at("keep", default: false), {
  set text(size: pt(st.at("size", default: spec.size)), ..edges(pitch-of(spec, st.at("pitch", default: none))))
  let al = (left: left, center: center, right: right).at(st.at("align", default: "left"))
  // an explicit par: typst ignores a `set par(hanging-indent)` inside a block
  pad(left: pt(st.at("left", default: 0)), right: pt(st.at("right", default: 0)), align(al,
    par(first-line-indent: (amount: pt(st.at("indent", default: 0)), all: true),
      hanging-indent: pt(st.at("hang", default: 0)), styled(st, body))))
})

/// A string as typst content: markdown inlines, in capitals when the style says so.
#let inl(st, s) = if st.at("upper", default: false) { upper(md(s)) } else { md(s) }

/// The context of an item of a list: its fields (a dictionary item) and "." (the item) over the outer context.
#let item-ctx(ctx, it) = if type(it) == dictionary { ctx + it + ("." : it) } else { ctx + ("." : it) }

/// The blocks of a list. `first`: the list opens its container (a column, a group, the page), where the space
/// above its first block is set as explicit space (every engine keeps it there).
#let blocks(spec, list, ctx, first: false) = {
  let first = first
  for b in list {
    // at the start of a container typst drops a block's space above (Word and LaTeX keep it): it is a pad there
    let lead = if first { pt(b.at("above", default: 0)) } else { 0pt }
    let above = if first { 0pt } else { pt(b.at("above", default: 0)) }
    if lead > 0pt { v(lead) }
    let below = pt(b.at("below", default: 0))
    if "text" in b {
      let ps = expand(b.text, ctx, b.at("optional", default: false))
      for (i, s) in ps.enumerate() {
        line-block(spec, b, inl(b, s), if i == 0 { above } else { 0pt }, if i == ps.len() - 1 { below } else { 0pt })
      }
      if ps.len() > 0 { first = false }
    } else if "rule" in b {
      // a box of RULE + the stroke, the line at its top (LibreOffice: a bordered paragraph of one twip)
      block(width: 100%, height: pt(RULE + b.rule), above: above, below: below,
        place(top + left, dy: pt(b.rule) / 2, line(length: 100%, stroke: pt(b.rule))))
      first = false
    } else if "columns" in b {
      // the columns, each with its context: a list of columns, or one column per item of a list (`each`)
      // (`per_row`: that many columns a row, the rows `row_gap` apart; a short last row keeps the widths)
      let rows = if type(b.columns) == dictionary {
        let items = lookup(ctx, b.columns.each)
        if items == none { panic("xdoc: missing required metadata field `" + b.columns.each + "`") }
        let cols = items.map(it => b.columns + (ctx: item-ctx(ctx, it)))
        let n = b.columns.at("per_row", default: cols.len())
        range(0, cols.len(), step: calc.max(n, 1)).map(i => {
          let row = cols.slice(i, calc.min(i + n, cols.len()))
          row + range(n - row.len()).map(_ => (blocks: (), ctx: ctx))
        })
      } else { (b.columns.map(c => c + (ctx: ctx)),) }
      for (ri, cols) in rows.enumerate() {
        let widths = cols.map(c => if c.at("width", default: none) == none { 1fr } else { pt(c.width) })
        let gap = if type(b.columns) == dictionary { pt(b.columns.at("row_gap", default: 0)) } else { 0pt }
        block(width: 100%, above: if ri == 0 { above } else { gap }, below: if ri == rows.len() - 1 { below } else { 0pt },
          breakable: false, grid(
          columns: widths, column-gutter: pt(b.at("gutter", default: 0)),
          ..cols.map(c => grid.cell(align: if c.at("valign", default: "top") == "center" { horizon } else { top },
            blocks(spec, c.blocks, c.ctx, first: true))),
        ))
      }
      first = false
    } else if "each" in b {
      let items = lookup(ctx, b.each)
      if items == none { panic("xdoc: missing required metadata field `" + b.each + "`") }
      for (i, it) in items.enumerate() {
        if i > 0 and "between" in b { blocks(spec, b.between, ctx, first: false) }
        // the space above the first item's first block: the each block's own
        let bl = b.blocks
        if i == 0 and bl.len() > 0 { bl.at(0).insert("above", calc.max(b.at("above", default: 0),
          bl.at(0).at("above", default: 0))) }
        blocks(spec, bl, item-ctx(ctx, it), first: first and i == 0)
      }
      if items.len() > 0 { first = false }
    } else if "when" in b {
      // the blocks, when the frontmatter has the field
      if lookup(ctx, b.when) != none {
        blocks(spec, b.blocks, ctx, first: first)
        first = false
      }
    } else if "break" in b {
      pagebreak(weak: true)
      first = false
    } else if "group" in b {
      block(width: 100%, above: above, below: below, breakable: not b.at("keep", default: true),
        blocks(spec, b.group, ctx, first: true))
      first = false
    } else {
      panic("xdoc: unknown block " + repr(b))
    }
  }
}

/// A list item's own text and the lists nested in it.
#let split-item(body) = {
  let cs = if body.func() == [].func() { body.children } else { (body,) }
  let subs = cs.filter(c => c.func() in (list, enum))
  let head = cs.filter(c => c.func() not in (list, enum, parbreak))
  while head.len() > 0 and head.last() == [ ] { head = head.slice(0, -1) }
  (head.join(), subs)
}

/// A list (bulleted or numbered) at nesting `level`: each item's label in a box of the list indent, `level` boxes
/// in, the text hanging after it, no space of its own; a nested list one level deeper. Bullets per level from
/// `list.markers`.
#let list-items(spec, it, level) = {
  let li = pt(spec.at("list_indent", default: spec.indent))
  let markers = spec.at("list", default: (:)).at("markers", default: ("•",))
  let numbered = it.func() == enum
  let n = if numbered and it.start != auto { it.start } else { 1 }
  for item in it.children {
    if numbered and item.at("number", default: none) not in (none, auto) { n = item.number }
    let lab = if numbered { numbering(it.numbering, n) } else { markers.at(calc.min(level, markers.len() - 1)) }
    let (head, subs) = split-item(item.body)
    block(above: 0pt, below: 0pt, pad(left: level * li,
      par(first-line-indent: 0pt, hanging-indent: li, { box(width: li, lab); head })))
    for s in subs { list-items(spec, s, level + 1) }
    n += 1
  }
}

/// The level-n heading style, the last one for deeper levels.
#let heading-style(spec, n) = {
  let hs = spec.at("heading", default: ())
  if hs.len() == 0 { (bold: true) } else { hs.at(calc.min(n, hs.len()) - 1) }
}

/// The number of a heading (layout.yaml heading style `number`, a typst numbering pattern): the count at its level of
/// typst's heading counter, which every heading steps (xdoc sets a numbering when a style has a `number`; the show
/// rule writes the heading itself). lib/pandoc/xdoc.lua number_headings counts alike. none when unnumbered.
#let heading-label(spec, h) = {
  let st = heading-style(spec, h.level)
  if "number" not in st { return none }
  let c = counter(heading).at(h.location())
  numbering(st.number, c.at(h.level - 1, default: 1))
}

/// Whether a heading style numbers its headings.
#let numbered(spec) = spec.at("heading", default: ()).any(h => "number" in h)

/// The words of a body (`{body_words}`; lib/pandoc/xdoc.lua count_words): split at white space, a word holds an ASCII
/// letter or digit.
#let count-words(s) = s.split(regex("\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()

/// The entries of the frontmatter's table of authorities (`authorities: [{heading, entries: [{cite, find}]}]`), in
/// order, each with its number k (from 1; lib/pandoc/xdoc.lua numbers them alike).
#let authority-entries(meta) = {
  let out = ()
  for g in meta.at("authorities", default: ()) { for e in g.entries { out.push(e + (k: out.len() + 1)) } }
  out
}

/// Content with every occurrence of an authority's `find` text marked (<xd-toa>, the entry's number) at the end of the
/// word it ends in: the pages of the table of authorities. Not before the word (typst sets a mark that opens a line at
/// the end of the line before, a page early), not inside it (see below).
#let with-marks(meta, content) = {
  let out = content
  for e in authority-entries(meta) {
    if "find" in e {
      let k = e.k
      out = {
        // the whole word around the find: a show rule that split it ("MCL 15.243" from "(1)(f)") would let
        // xengine's ")(" box start a word of its own, a place to break the line LaTeX and Word do not have
        show regex("\\S*" + e.find.replace(regex("[.*+?^${}()|\\[\\]\\\\]"), m => "\\" + m.text) + "\\S*"): it => [#it#metadata(k)<xd-toa>]
        out
      }
    }
  }
  out
}

/// The numbering of the pages from here on (a typst numbering pattern, or none): the document is numbered "1" from its
/// first page, unless `page_number.front` numbers the tables before the body apart (cover none, tables "i" from 1,
/// body "1" from 1).
#let xd-num = state("xd-num", "1")
#let FORMATS = ("lower-roman": "i", "upper-roman": "I", "decimal": "1")

/// The label of the page at a location.
#let page-label(loc) = {
  let fmt = xd-num.at(loc)
  if fmt == none { "" } else { numbering(fmt, ..counter(page).at(loc)) }
}

/// The body: markdown; paragraphs at the body pitch with a first-line indent, headings, quotations, lists and
/// footnotes as layout.yaml says, the authorities marked.
/// Whether content holds a footnote (its mark).
#let has-note(c) = {
  if type(c) != content { return false }
  if c.func() == footnote { return true }
  if c.has("children") { return c.children.any(has-note) }
  if c.has("body") { return has-note(c.body) }
  if c.has("child") { return has-note(c.child) }
  false
}

/// The paragraphs of a body (cmarker's sequence, split at its paragraph breaks) that anchor a footnote, with no widow or
/// orphan control, as lib/latex/xdoc.lua and lib/docx/xdoc.lua set them (a show rule on par comes too late: the note is
/// realized by then).
#let free-notes(body) = {
  if body.func() != [].func() { return body }
  let (out, run) = ((), ())
  for c in body.children + (parbreak(),) {
    if c.func() == parbreak {
      out.push(if run.any(has-note) { set text(costs: (widow: 0%, orphan: 0%)); run.join() } else { run.join() })
      out.push(c)
      run = ()
    } else { run.push(c) }
  }
  out.slice(0, -1).join()
}

#let body-of(spec, meta, src) = {
  let q = spec.at("quote", default: (:))
  show heading: it => context {
    let st = heading-style(spec, it.level)
    let text = if st.at("upper", default: false) { upper(it.body) } else { it.body }
    // its number in a box of the hanging indent, the text after it
    let label = heading-label(spec, it)
    if label != none { text = box(width: pt(st.at("hang", default: 0)), label) + text }
    line-block(spec, st + (keep: true), text, pt(st.at("above", default: 0)), pt(st.at("below", default: 0)))
  }
  show list: it => list-items(spec, it, 0)
  show enum: it => list-items(spec, it, 0)
  show quote.where(block: true): it => block(width: 100%, above: pt(q.at("above", default: 0)),
    below: pt(q.at("below", default: 0)), {
    set text(..edges(pitch-of(spec, q.at("pitch", default: none))))
    set par(first-line-indent: 0pt, spacing: pt(q.at("gap", default: 0)))
    pad(left: pt(q.at("left", default: spec.indent)), right: pt(q.at("right", default: spec.indent)), it.body)
  })
  with-marks(meta, free-notes(cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)))
}

/// One row of a table of contents or authorities: lib/typst/xengine.typ's listing-row (the text wraps before a page
/// column `col`, a leader from three spaces after it to the page), with the room LibreOffice keeps: a right tab whose
/// leader has less than `LEADER-MIN` before the page column moves the last word to a new line (measured at 12 and 14
/// pt: 0.3232 to 0.3267 em), so the leader here never ends closer than that to the column either.
#let LEADER-MIN = 0.325em
#let table-row(target, body, page, col, hang-by, above) = {
  let row = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
    columns: (1fr, col), column-gutter: 0pt,
    par(hanging-indent: hang-by, first-line-indent: 0pt, leading: 0pt, justify: false, {
      body
      h(0.75em)
      box(width: 1fr, repeat[.])
      h(LEADER-MIN)
    }),
    align(right + bottom, page),
  ))
  if target == none { row } else { link(target, row) }
}

/// The title of a table (contents, authorities): the level-1 heading style, not a heading itself; it opens a page.
#let table-title(spec, t) = {
  pagebreak(weak: true)
  let st = heading-style(spec, 1) + t.at("style", default: (:))
  line-block(spec, st + (keep: true), inl(st, t.title), 0pt, pt(st.at("below", default: 0)))
}

/// The table of contents (layout.yaml `contents`): a row per heading of the body (levels to `depth`), its text
/// wrapping before a page column `col` and `hang` under its first line, `step` further in per level, `above` over
/// each row; the leader runs from three spaces after the text to the page (lib/typst/xengine.typ listing-row).
#let contents-pages(spec, c) = {
  table-title(spec, c)
  set text(..edges(pitch-of(spec, c.at("pitch", default: none))))
  context {
    let hs = query(selector(heading).after(<xd-body>)).filter(h => h.level <= c.at("depth", default: 3))
    for h in hs {
      // the row's space above outside the indent (inside it typst would drop it: the start of a container)
      block(width: 100%, above: pt(c.at("above", default: 0)), below: 0pt,
        pad(left: (h.level - 1) * pt(c.at("step", default: 0)), table-row(h.location(),
          { let l = heading-label(spec, h); if l != none [#l #h.body] else { h.body } },
          page-label(h.location()), pt(c.at("col", default: 36)), pt(c.at("hang", default: 0)), 0pt)))
    }
  }
}

/// The table of authorities (layout.yaml `authorities`, the frontmatter's `authorities`): each group's heading in
/// the `group` style, then a row per entry, its pages (the distinct pages of its marks, or the entry's own `pages`,
/// or "--") in a column of `col` or the list's own width when wider.
#let authorities-pages(spec, a, meta) = {
  table-title(spec, a)
  set text(..edges(pitch-of(spec, a.at("pitch", default: none))))
  let gst = a.at("group", default: (bold: true))
  let k = 0
  for g in meta.authorities {
    line-block(spec, gst + (keep: true), inl(gst, g.heading), pt(gst.at("above", default: 0)),
      pt(gst.at("below", default: 0)))
    for e in g.entries {
      k += 1
      let key = k
      context {
        let pages = query(<xd-toa>).filter(m => m.value == key).map(m => page-label(m.location())).dedup()
        let list = if "find" not in e { str(e.at("pages", default: "--")) } else if pages.len() == 0 { "--" } else {
          pages.join(", ") }
        table-row(none, md(e.cite), list, calc.max(pt(a.at("col", default: 56)), measure(list).width),
          pt(a.at("hang", default: 0)), pt(a.at("above", default: 0)))
      }
    }
  }
}

/// The whole document: page, type, the cross-engine model, front matter, body, closing, tail.
#let xdoc(spec, meta, body) = {
  let m = spec.margin
  let pn = spec.at("page_number", default: (align: "center", from: 1))
  let fn = spec.at("footnote", default: (:))
  let note-pitch = pitch-of(spec, fn.at("pitch", default: none))
  set document(title: str(meta.at("title", default: meta.at("doc_title", default: meta.at("brief_title", default: "")))))
  // The page number centered in a single line box in the bottom margin, where Word's footer sets it.
  set page(paper: "us-letter", margin: (top: pt(m.top), bottom: pt(m.bottom), left: pt(m.left), right: pt(m.right)),
    footer-descent: 30%, footer: context {
      let n = counter(page).get().first()
      let fmt = xd-num.get()
      if pn != none and fmt != none and n >= pn.at("from", default: 1) {
        let al = (left: left, center: center, right: right).at(pn.at("align", default: "center"))
        align(al, text(..edges(pt(spec.pitch.single)), numbering(fmt, n)))
      }
    })
  set text(font: spec.font, size: pt(spec.size), lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: pt(spec.indent), all: true))
  show: xengine.with(pitch: pt(spec.pitch.body), list-indent: none) // lists: list-items
  // no punctuation hanging into the margin (typst's overhang): LaTeX and Word set none, and a hanging period moved a
  // centered line 1.4 pt and lets a line hold more
  set text(overhang: false)
  // inside a URL a line may end after every slash not followed by another and every dot before an ASCII letter or digit
  // (lib/pandoc/xengine.lua urls; here, not in body-of: the footnotes are laid out outside its show rules)
  show regex("(https?://|\\(?www\\.)\\S+"): it => it.text.replace(regex("/([^/])"), m => "/\u{200B}" + m.captures.at(0))
    .replace(regex("\\.([A-Za-z0-9])"), m => ".\u{200B}" + m.captures.at(0))
  // every heading steps the heading counter when a style numbers them (heading-label)
  set heading(numbering: if numbered(spec) { "1.1" } else { none })
  set footnote.entry(gap: pt(fn.at("gap", default: 7)), clearance: pt(fn.at("clearance", default: 9.1)), indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: pt(fn.at("size", default: spec.size)), ..edges(note-pitch))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    // a note is never split across pages (LaTeX: \interfootnotelinepenalty 10000): its line moves on with it
    block(breakable: false)[#super(numbering(note.numbering, ..counter(footnote).at(note.location())))#h(0.25em)#with-marks(meta, note.body)]
  }
  // the body up to the tail heading, and the tail (certificates set after the closing)
  let tail = spec.at("tail", default: none)
  let (main, rest) = (body, "")
  if tail != none {
    let at = body.match(regex("(?m)^# +" + tail.at))
    if at != none {
      // footnote definitions (at the end of the sample) serve both parts: each part gets them all
      let defs = body.matches(regex("(?m)^\\[\\^[^\\]]+\\]:.*(\\n(    |\\t).*)*")).map(m => m.text).join("\n\n")
      (main, rest) = (body.slice(0, at.start) + "\n\n" + defs, body.slice(at.start))
    }
  }
  // the computed fields: the words of the body before the tail
  let words = count-words(if rest == "" { body } else { body.slice(0, body.len() - rest.len()) })
  let meta = if "body_words" in meta { meta } else { meta + (body_words: words) }
  let front = if pn == none { none } else { pn.at("front", default: none) }
  if front != none { xd-num.update(none) }
  if "cover" in spec {
    blocks(spec, spec.cover, meta, first: true)
    pagebreak()
  }
  // the tables numbered apart (page_number.front), from 1
  if front != none { xd-num.update(FORMATS.at(front)); counter(page).update(1) }
  if "contents" in spec { contents-pages(spec, spec.contents) }
  if "authorities" in spec and "authorities" in meta { authorities-pages(spec, spec.authorities, meta) }
  if "contents" in spec or "authorities" in spec { pagebreak(weak: true) }
  if front != none { xd-num.update("1"); counter(page).update(1) }
  [#metadata(none)<xd-body>]
  blocks(spec, spec.at("front", default: ()), meta, first: true)
  body-of(spec, meta, main)
  blocks(spec, spec.at("closing", default: ()), meta)
  if rest != "" {
    if tail.at("break", default: false) { pagebreak(weak: true) }
    block(width: 100%, above: pt(tail.at("above", default: 0)), below: 0pt, {
      set text(..edges(pitch-of(spec, tail.at("pitch", default: none))))
      set par(first-line-indent: (amount: pt(tail.at("indent", default: 0)), all: true),
        spacing: pt(tail.at("gap", default: 0)))
      body-of(spec, meta, rest)
    })
  }
}
