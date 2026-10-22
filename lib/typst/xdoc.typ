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

/// The value at a dotted path ("a.b", "." the context itself), or none.
#let lookup(ctx, path) = {
  if path == "." { return ctx }
  let v = ctx
  for k in path.split(".") {
    if type(v) == dictionary and k in v { v = v.at(k) } else { return none }
  }
  v
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
    par(first-line-indent: 0pt, hanging-indent: pt(st.at("hang", default: 0)), styled(st, body))))
})

/// A string as typst content: markdown inlines, in capitals when the style says so.
#let inl(st, s) = if st.at("upper", default: false) { upper(md(s)) } else { md(s) }

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
      let cols = b.columns
      let widths = cols.map(c => if c.at("width", default: none) == none { 1fr } else { pt(c.width) })
      block(width: 100%, above: above, below: below, breakable: false, grid(
        columns: widths, column-gutter: pt(b.at("gutter", default: 0)),
        ..cols.map(c => blocks(spec, c.blocks, ctx, first: true)),
      ))
      first = false
    } else if "each" in b {
      let items = lookup(ctx, b.each)
      if items == none { panic("xdoc: missing required metadata field `" + b.each + "`") }
      for (i, it) in items.enumerate() {
        if i > 0 and "between" in b { blocks(spec, b.between, ctx, first: false) }
        let item-ctx = if type(it) == dictionary { ctx + it + ("." : it) } else { ctx + ("." : it) }
        // the space above the first item's first block: the each block's own
        let bl = b.blocks
        if i == 0 and bl.len() > 0 { bl.at(0).insert("above", calc.max(b.at("above", default: 0),
          bl.at(0).at("above", default: 0))) }
        blocks(spec, bl, item-ctx, first: first and i == 0)
      }
      if items.len() > 0 { first = false }
    } else if "group" in b {
      block(width: 100%, above: above, below: below, breakable: not b.at("keep", default: true),
        blocks(spec, b.group, ctx, first: true))
      first = false
    } else {
      panic("xdoc: unknown block " + repr(b))
    }
  }
}

/// The level-n heading style, the last one for deeper levels.
#let heading-style(spec, n) = {
  let hs = spec.at("heading", default: ())
  if hs.len() == 0 { (bold: true) } else { hs.at(calc.min(n, hs.len()) - 1) }
}

/// The body: markdown; paragraphs at the body pitch with a first-line indent, headings, quotations, lists and
/// footnotes as layout.yaml says.
#let body-of(spec, src) = {
  let q = spec.at("quote", default: (:))
  show heading: it => {
    let st = heading-style(spec, it.level)
    line-block(spec, st + (keep: true), if st.at("upper", default: false) { upper(it.body) } else { it.body },
      pt(st.at("above", default: 0)), pt(st.at("below", default: 0)))
  }
  show quote.where(block: true): it => block(width: 100%, above: pt(q.at("above", default: 0)),
    below: pt(q.at("below", default: 0)), {
    set text(..edges(pitch-of(spec, q.at("pitch", default: none))))
    set par(first-line-indent: 0pt, spacing: pt(q.at("gap", default: 0)))
    pad(left: pt(q.at("left", default: spec.indent)), right: pt(q.at("right", default: spec.indent)), it.body)
  })
  cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)
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
      if pn != none and n >= pn.at("from", default: 1) {
        let al = (left: left, center: center, right: right).at(pn.at("align", default: "center"))
        align(al, text(..edges(pt(spec.pitch.single)), str(n)))
      }
    })
  set text(font: spec.font, size: pt(spec.size), lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: pt(spec.indent), all: true))
  show: xengine.with(pitch: pt(spec.pitch.body), list-indent: pt(spec.at("list_indent", default: spec.indent)))
  set heading(numbering: none)
  set footnote.entry(gap: pt(fn.at("gap", default: 7)), clearance: pt(fn.at("clearance", default: 7.5)), indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: pt(fn.at("size", default: spec.size)), ..edges(note-pitch))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    [#super(numbering(note.numbering, ..counter(footnote).at(note.location())))#h(0.25em)#note.body]
  }
  // the body up to the tail heading, and the tail (certificates set after the closing)
  let tail = spec.at("tail", default: none)
  let (main, rest) = (body, "")
  if tail != none {
    let at = body.match(regex("(?m)^# +" + tail.at))
    if at != none { (main, rest) = (body.slice(0, at.start), body.slice(at.start)) }
  }
  blocks(spec, spec.at("front", default: ()), meta, first: true)
  body-of(spec, main)
  blocks(spec, spec.at("closing", default: ()), meta)
  if rest != "" {
    block(width: 100%, above: pt(tail.at("above", default: 0)), below: 0pt, {
      set text(..edges(pitch-of(spec, tail.at("pitch", default: none))))
      set par(first-line-indent: (amount: pt(tail.at("indent", default: 0)), all: true),
        spacing: pt(tail.at("gap", default: 0)))
      body-of(spec, rest)
    })
  }
}
