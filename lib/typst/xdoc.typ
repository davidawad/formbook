// The shared document model (fb-595.54.12): a doc folder's whole layout as data, `typst/layout.yaml`, set by this
// file in typst and by lib/latex/xdoc.lua and lib/docx/xdoc.lua in the other engines, which `fb engines gen`
// (tools/fb/src/enginegen) wires into the folder's latex/ and docx/. All three read the same layout and the same
// sample, and lay every block out on the cross-engine model (lib/typst/xengine.typ: first fit, exact line boxes,
// no kerning, ligatures or hyphenation), so the latex and docx renders break every line and page where this one
// does by construction. The grammar of layout.yaml is in docs/EVAL-LOOP.md, "Generated engines"; in short:
//
//   font, size, pitch: {body, single}, margin: {top, bottom, left, right}, paper (letter, legal), justify, indent,
//   list_indent,
//   page_number: {align, from}, footnote: {size, pitch, gap, clearance}, quote: {left, right, above, below, gap},
//   heading: [level 1, level 2, ...] (each a text style plus above/below; `number`: "I." etc., the label in a box of
//   `label_box` or the `hang`, `number_prefix`, `label_line`), front: [blocks], closing: [blocks],
//   before_tables: [blocks], body_before_tables: {count | until | marker} (pages between the cover and the tables),
//   tail: {at, pitch, indent, gap, above}
//   blocks: {text: "literal with {field}, {a.b} or {a.b|default} ({body_words}, {xd.words}: computed)", <style>},
//           {markdown: "{field}", <style>, gap} (paragraphs at blank lines),
//           {rule: <stroke>, above, below},
//           {columns: [{width, blocks}, ..], gutter}, {each: field, blocks, between}, {group: [blocks], keep},
//           {fill: <weight>} (a page's own blocks: the space the page leaves, shared by weight),
//           {box: [blocks], width, height, stroke, inset, valign} (a ruled box; stroke and inset per side or one)
//   style: align (left, center, right), bold, italic, upper, underline, left, right, hang, above, below, pitch
//          (body, single or a number), keep, optional
//
// Lengths are points (twips = 20 x pt in Word, bp in LaTeX); every number belongs in layout.yaml, with its rule.
#import "@preview/cmarker:0.1.10"
#import "xengine.typ": xengine, edges

/// Resolve relative markdown images beside the sample, not beside cmarker's package.
#let markdown-scope() = {
  let sample = sys.inputs.at("sample", default: "")
  let parts = sample.split("/")
  let dir = parts.slice(0, calc.max(0, parts.len() - 1)).join("/")
  (image: (source, ..args) => {
    let source = str(source)
    if source.starts-with("/") or source.match(regex("^[A-Za-z][A-Za-z0-9+.-]*:")) != none {
      image(source, ..args)
    } else {
      image("/" + dir + "/" + source, ..args)
    }
  })
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("xdoc: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// An apostrophe right after closing emphasis ("*Rucho*'s"): cmarker's smart punctuation makes it an opening quote
/// ("Rucho‘s"), pandoc a right one, as written (fb-595.54.14).
#let apostrophes(s) = s.replace(regex("(\\S[*_]+)'(\\w)"), m => m.captures.at(0) + "\u{2019}" + m.captures.at(1))

/// A frontmatter string as markdown inlines. A value that starts like a block ("* Pro hac vice", "1. ", "# ", "> ") is text:
/// its marker escaped (lib/pandoc/xdoc.lua inlines alike).
#let md(s) = {
  // a value that reads as a thematic break ("______", a signature line) is its characters
  if str(s).match(regex("^\\s*(?:(?:_\\s*){3,}|(?:-\\s*){3,}|(?:\\*\\s*){3,})$")) != none {
    return cmarker.render(str(s).replace(regex("[-_*]"), m => "\\" + m.text), raw-typst: false, smart-punctuation: true, scope: markdown-scope())
  }
  let s = str(s).replace(regex("^(\\s*)([-*+>#])(\\s|$)"), m => m.captures.at(0) + "\\" + m.captures.at(1) + m.captures.at(2))
    .replace(regex("^(\\s*)(\\d+)([.)])(\\s|$)"), m => m.captures.at(0) + m.captures.at(1) + "\\" + m.captures.at(2) + m.captures.at(3))
  cmarker.render(apostrophes(s), raw-typst: false, smart-punctuation: true, scope: markdown-scope())
}
#let pt(x) = if x == none { 0pt } else { x * 1pt }

// A rule's line box besides its stroke (lib/pandoc/xdoc.lua RULE): LibreOffice's smallest exact line, one twip.
#let RULE = 0.05

// The paper (layout.yaml `paper`; lib/pandoc/xdoc.lua PAPER): letter, the default, or legal (612 x 1008 pt).
#let PAPER = (letter: "us-letter", legal: "us-legal")

/// The value at a dotted path ("a.b", "." the context itself), or none; "a.b|text": the text when
/// there is none (a blank a filer completes, e.g. "{service.date|____________}"; lib/pandoc/xdoc.lua lookup alike).
#let lookup(ctx, path) = {
  let bar = path.position("|")
  if bar != none {
    let v = lookup(ctx, path.slice(0, bar))
    return if v == none { path.slice(bar + 1) } else { v }
  }
  if path == "." { return ctx.at(".", default: none) }
  let v = ctx
  for k in path.split(".") {
    // a list item by its index from 0 ("signature.lines.0")
    let item = type(v) == array and k.match(regex("^[0-9]+$")) != none and int(k) < v.len()
    if type(v) == dictionary and k in v { v = v.at(k) } else if item { v = v.at(int(k)) } else { return none }
  }
  v
}

/// Whether a frontmatter value is set: present and not false, "" or an empty list or map.
#let is-set(v) = v not in (none, false, "", (), (:))

/// The paragraphs of a text template: "{path}" alone and a list value gives one per item; otherwise every {path} is
/// replaced by its value. Each paragraph is then split at "<br>" (a line of its own in every engine). A missing
/// value panics, or gives no paragraph when `optional` (an empty string too).
#let expand(tpl, ctx, optional, lines: true) = {
  let tpl = str(tpl)
  // a value's newline starts a line of its own, as "<br>" does (a YAML block scalar's last one dropped); a markdown
  // block keeps them (`lines: false`: it splits at blank lines)
  let val(v) = if lines { str(v).trim("\n", at: end).replace("\r\n", "\n").replace("\n", "<br>") } else { str(v) }
  let whole = tpl.match(regex("^\\{([^{}]+)\\}$"))
  let out = ()
  if whole != none and type(lookup(ctx, whole.captures.at(0))) == array {
    out = lookup(ctx, whole.captures.at(0)).map(val)
  } else {
    let missing = false
    let s = tpl
    for m in tpl.matches(regex("\\{([^{}]+)\\}")) {
      let v = lookup(ctx, m.captures.at(0))
      // an optional block whose field is empty prints nothing, as one whose field is missing
      if v == none or (optional and v == "") {
        if optional { missing = true } else { panic("xdoc: missing required metadata field `" + m.captures.at(0) + "`") }
      } else {
        s = s.replace(m.text, val(v))
      }
    }
    out = if missing { () } else { (s,) }
  }
  out.map(s => s.split("<br>")).flatten()
}

/// The words of markdown text, whitespace-delimited as a word processor counts them, the markup taken out first: an
/// HTML comment, a footnote mark, a link's target, a heading's, quotation's or list item's marker, a backslash
/// escape, emphasis (`*`, an `_` at a word's edge); a link keeps its text. lib/pandoc/xdoc.lua `count_words` takes
/// the same steps in the same order, so both give the same count.
#let count-words(src) = {
  let keep(m) = m.captures.at(0)
  let s = "\n" + src + "\n"
  s = s.replace(regex("[\u{00A0}\u{2002}\u{2003}\u{2009}\u{202F}]"), " ")
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)
  s = s.replace("<br>", " ")
  s = s.replace(regex("\n#+[ \t]+"), "\n")
  s = s.replace(regex("\n>[ \t]?"), "\n")
  s = s.replace(regex("\n[ \t]*[-*+][ \t]+"), "\n")
  s = s.replace(regex("\n[ \t]*[0-9]+[.)][ \t]+"), "\n")
  s = s.replace(regex("\\\\([^\n])"), keep)
  s = s.replace("*", "")
  s = s.replace(regex("([ \t\n\r(\\[\"])_"), keep)
  s = s.replace("\u{201C}_", "\u{201C}")
  s = s.replace(regex("_([ \t\n\r.,;:)\\]\"!?])"), keep)
  s = s.replace("_\u{201D}", "\u{201D}")
  s.split(regex("[ \t\n\r\u{000B}\u{000C}]+")).filter(w => w != "").len()
}

/// A count with its thousands grouped ("11,942").
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

/// The text a word count reads (layout.yaml `words`): the body up to the tail heading, its level-1 sections from the
/// one whose heading starts with `from` through the one that starts with `through`, less the sections whose headings
/// start with an `exclude` (with `sections`, only those whose title starts with one listed, in any case), and the
/// footnotes those sections call (each once). Footnote definitions are the lines
/// `[^label]: ..` and the lines indented four spaces or a tab after them. lib/pandoc/xdoc.lua `counted_text` alike.
#let counted-text(spec, body) = {
  let w = spec.words
  let at = spec.at("tail", default: (:)).at("at", default: none)
  let defs = (:)
  let lines = ()
  let cur = none
  for l in body.split("\n") {
    let l = l.trim("\r", at: end)
    let m = l.match(regex("^\\[\\^([^\\]]+)\\]:(.*)$"))
    if m != none {
      cur = m.captures.at(0)
      defs.insert(cur, m.captures.at(1))
    } else if cur != none and (l.starts-with("    ") or l.starts-with("\t")) {
      defs.at(cur) += "\n" + l
    } else {
      cur = none
      lines.push(l)
    }
  }
  // the level-1 sections (the lines before the first heading a section without one), up to the tail
  let secs = ((head: none, lines: ()),)
  for l in lines {
    let m = l.match(regex("^# +(.*)$"))
    if m != none {
      let head = m.captures.at(0)
      if at != none and head.starts-with(at) { break }
      secs.push((head: head, lines: (l,)))
    } else {
      secs.at(-1).lines.push(l)
    }
  }
  let starts(s, p) = s.head != none and s.head.starts-with(p)
  let from = w.at("from", default: none)
  if from != none {
    let i = secs.position(s => starts(s, from))
    if i == none { panic("xdoc: words.from: no level-1 heading starts with `" + from + "`") }
    secs = secs.slice(i)
  }
  let through = w.at("through", default: none)
  if through != none {
    let i = secs.position(s => starts(s, through))
    if i == none { panic("xdoc: words.through: no level-1 heading starts with `" + through + "`") }
    secs = secs.slice(0, i + 1)
  }
  // `sections`: only the level-1 sections whose title (lower case, without "*") starts with one listed
  let only = w.at("sections", default: ()).map(lower)
  if only.len() > 0 {
    secs = secs.filter(s => s.head != none and only.any(p => lower(s.head.replace("*", "").trim()).starts-with(p)))
  }
  let ex = w.at("exclude", default: ())
  let text = secs.filter(s => not ex.any(p => starts(s, p))).map(s => s.lines.join("\n")).join("\n")
  let called = ()
  for m in text.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    if k in defs and k not in called { called.push(k) }
  }
  (text, ..called.map(k => defs.at(k))).join("\n")
}

/// The values the model computes for the text blocks (`{xd.words}`), over the frontmatter; a count over
/// `words.limit` (or the frontmatter field `words.limit_field` names, a court order's limit) stops the render;
/// `words.given`: a frontmatter field that states the count (the filer's certified count) instead.
#let computed(spec, meta, body) = {
  // `constants`: the layout's court constants (a district's name in the generic FRCP base, fb-595.17) as {xd.<key>}
  let meta = if "constants" in spec { meta + (xd: meta.at("xd", default: (:)) + spec.constants) } else { meta }
  if "words" not in spec { return meta }
  let w = spec.words
  let n = if "given" in w and is-set(meta.at(w.given, default: none)) { int(meta.at(w.given)) } else {
    count-words(counted-text(spec, body)) }
  let limit = meta.at(w.at("limit_field", default: ""), default: w.at("limit", default: none))
  let limit = if limit == none { none } else { int(limit) }
  if limit != none and n > limit {
    panic("xdoc: the body has " + str(n) + " words, over the limit of " + str(limit) + " (layout.yaml words.limit)")
  }
  meta + (xd: meta.at("xd", default: (:)) + (words: group-digits(n)))
}

/// A URL (`http://`, `https://`, `www.`) as the pieces a line may end between: after a slash not followed by another
/// (so after "https://", not inside it), a dot before an ASCII letter or digit, a hyphen before a letter, a "?", "!"
/// or "&" before a letter or digit (where LibreOffice breaks by Unicode line breaking, unboxed in Word; "&" between a
/// query string's fields, a long one overflowed the margin otherwise); the same places in every engine
/// (lib/pandoc/xdoc.lua url_pieces; LaTeX \allowbreak, Word a zero-width space): each piece in a box, a zero-width
/// space between them, so no engine breaks a URL anywhere else.
#let URL = regex("(https?://|www\\.)[^\\s<>]+")
#let url-pieces(s) = {
  let cs = s.clusters()
  let pieces = ()
  let cur = ""
  for (i, c) in cs.enumerate() {
    cur += c
    let next = cs.at(i + 1, default: none)
    let cut = next != none and ((c == "/" and next != "/") or (c == "." and next.match(regex("^[A-Za-z0-9]$")) != none)
      or (c == "-" and next.match(regex("^[A-Za-z]$")) != none)
      or (c in ("?", "!", "&") and next.match(regex("^[A-Za-z0-9]$")) != none))
    if cut { pieces.push(cur); cur = "" }
  }
  if cur != "" { pieces.push(cur) }
  pieces
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
  sticky: st.at("keep", default: false), breakable: not st.at("keep", default: false), {
  set text(size: pt(st.at("size", default: spec.size)), ..edges(pitch-of(spec, st.at("pitch", default: none))))
  let al = (left: left, center: center, right: right).at(st.at("align", default: "left"))
  // an explicit par: typst ignores a `set par(hanging-indent)` inside a block
  pad(left: pt(st.at("left", default: 0)), right: pt(st.at("right", default: 0)), align(al,
    par(first-line-indent: (amount: pt(st.at("indent", default: 0)), all: true), justify: false,
      hanging-indent: pt(st.at("hang", default: 0)), styled(st, body))))
})

/// A string as typst content: markdown inlines, in capitals when the style says so.
#let inl(st, s) = if st.at("upper", default: false) { upper(md(s)) } else { md(s) }

/// The context of an item of a list: its fields (a dictionary item) and "." (the item) over the outer context.
#let item-ctx(ctx, it, i: none) = {
  let c = if type(it) == dictionary { ctx + it + ("." : it) } else { ctx + ("." : it) }
  if i == none { c } else { c + ("#": i + 1) }
}

/// The weight of a fill block: `fill: true` is 1.
#let fill-weight(b) = if b.fill == true { 1 } else { b.fill }

/// A page's own blocks (front, closing) whose fills are not followed by a page break: a fill shares out the rest of
/// its page, which only a break ends (the cover always ends in one).
#let check-fills(list) = {
  let has-fill(bs) = bs.any(b => "fill" in b or ("blocks" in b and type(b.blocks) == array and has-fill(b.blocks)))
  let last-break = list.enumerate().filter(((i, b)) => "break" in b).map(((i, b)) => i)
  let end = if last-break.len() == 0 { -1 } else { last-break.last() }
  if has-fill(list.slice(end + 1)) { panic("xdoc: a fill must be followed by a {break: true} on its page") }
}



/// The checks a court's rules ask of the body (layout.yaml `checks`), stopping the render: `footnotes: false`, no
/// footnote; `sections: [..]`, those level-1 headings (by the start of their text, any case) present and in that order
/// (lib/pandoc/xdoc.lua check alike).
#let check-body(spec, body) = {
  let c = spec.at("checks", default: (:))
  if c.at("footnotes", default: true) == false and body.match(regex("(?m)^\\[\\^[^\\]]+\\]:")) != none {
    panic("xdoc: the court allows no footnote (layout.yaml checks.footnotes)")
  }
  let heads = body.matches(regex("(?m)^# +(.*)$")).map(m => lower(m.captures.at(0).trim()))
  let at = 0
  for s in c.at("sections", default: ()) {
    let i = range(at, heads.len()).find(i => heads.at(i).starts-with(lower(s)))
    if i == none { panic("xdoc: the section `" + s + "` is missing or out of order (layout.yaml checks.sections)") }
    at = i + 1
  }
}
/// The paragraphs of a markdown value (a `{markdown: "{field}"}` block): split at its blank lines, each paragraph's
/// lines joined by a space (lib/pandoc/xdoc.lua md_paragraphs).
#let md-paragraphs(ps) = {
  ps.map(s => s.split(regex("\n[ \t]*\n")).map(p => p.trim().replace(regex("[ \t]*\n[ \t]*"), " "))).flatten()
    .filter(p => p != "")
}

/// The blocks of a list. `first`: the list opens its container (a column, a group, the page), where the space
/// above its first block is set as explicit space (every engine keeps it there).
#let blocks(spec, list, ctx, first: false, page: false) = {
  let first = first
  for b in list {
    // at the start of a container typst drops a block's space above (Word and LaTeX keep it): it is a pad there
    let lead = if first { pt(b.at("above", default: 0)) } else { 0pt }
    let above = if first { 0pt } else { pt(b.at("above", default: 0)) }
    let texty = "text" in b or "markdown" in b
    if lead > 0pt and not texty { v(lead) }
    let below = pt(b.at("below", default: 0))
    if texty {
      // `lines`: the style of a value of more than one line, a paragraph per line (an address among paragraphs), with
      // its `above` over it and over the value after it (lib/pandoc/xdoc.lua tree alike): each paragraph with `ml` (it
      // comes from such a value) and `first` (it opens its value)
      let ps = if "lines" in b and "text" in b {
        expand(b.text, ctx, b.at("optional", default: false), lines: false).map(v => {
          let t = v.trim("\n", at: end).replace("\r\n", "\n")
          let ml = t.contains("\n")
          t.split("\n").enumerate().map(((j, l)) => (s: l, ml: ml, first: j == 0))
        }).flatten()
      } else if "text" in b { expand(b.text, ctx, b.at("optional", default: false)) } else {
        md-paragraphs(expand(b.markdown, ctx, b.at("optional", default: false), lines: false))
      }
      // its space above only when it sets a paragraph (an optional block whose field is missing sets none: the next
      // block opens the container, lib/pandoc/xdoc.lua tree alike)
      if lead > 0pt and ps.len() > 0 { v(lead) }
      // the space between the block's paragraphs (`gap`)
      let gap = pt(b.at("gap", default: 0))
      for (i, p) in ps.enumerate() {
        let (s, st, gap) = if type(p) == dictionary {
          (p.s, if p.ml { b + b.lines } else { b },
            if i > 0 and p.first and (p.ml or ps.at(i - 1).ml) { pt(b.lines.at("above", default: 0)) } else { gap })
        } else { (p, b, gap) }
        // a layout heading (`heading: <level>`, a certificate's title): a heading as the body's, set in its level's
        // style (show-heading), listed in the contents and bookmarked, never numbered (labelled <xd-lh>)
        if "heading" in b { [#heading(level: b.heading, outlined: true, bookmarked: true, inl((:), s)) <xd-lh>]; continue }
        // an empty paragraph is a line of its pitch, as Word sets it (lib/latex/xdoc.lua par: \mbox{})
        let body = if s.trim() == "" { box(height: pitch-of(spec, st.at("pitch", default: none)), baseline: 20%) } else {
          inl(st, s) }
        line-block(spec, st, body, if i == 0 { above } else { gap }, if i == ps.len() - 1 { below } else { 0pt })
      }
      if ps.len() > 0 { first = false }
    } else if "rule" in b {
      // a box of RULE + the stroke, the line at its top (LibreOffice: a bordered paragraph of one twip); a rule of 0 is
      // the box alone, space that holds at the top of a page too (fb-595.54.14)
      block(width: 100%, height: pt(RULE + b.rule), above: above, below: below, if b.rule > 0 {
        place(top + left, dy: pt(b.rule) / 2, line(length: 100%, stroke: pt(b.rule))) })
      first = false
    } else if "columns" in b {
      // the columns, each with its context: a list of columns, or one column per item of a list (`each`)
      // (`per_row`: that many columns a row, the rows `row_gap` apart; a short last row keeps the widths; `widths`: the
      // width of the column at each place in a row, from the left, the places it does not give shared alike)
      let rows = if type(b.columns) == dictionary {
        let ws = b.columns.at("widths", default: ())
        let at-width(j, c) = if j < ws.len() { c + (width: ws.at(j)) } else { c }
        let items = lookup(ctx, b.columns.each)
        if items == none { panic("xdoc: missing required metadata field `" + b.columns.each + "`") }
        if "split" in b.columns {
          // `split`: two columns, the first holding the first N items (N the frontmatter field `split` names, or a
          // number; half of them, rounded up, without it), the second the rest, the items of a column `gap` apart
          // (lib/pandoc/xdoc.lua tree alike)
          let s = b.columns.split
          let k = if type(s) == str { lookup(ctx, s) } else { s }
          let k = if k == none { calc.ceil(items.len() / 2) } else { calc.min(int(k), items.len()) }
          let col(part) = (ctx: ctx + ("__split": part), blocks: ((each: "__split",
            gap: b.columns.at("gap", default: 0), blocks: b.columns.blocks),))
          ((col(items.slice(0, k)), col(items.slice(k))).enumerate().map(((j, c)) => at-width(j, c)),)
        } else {
          let cols = items.enumerate().map(((i, it)) => b.columns + (ctx: item-ctx(ctx, it, i: i)))
          let n = b.columns.at("per_row", default: cols.len())
          range(0, cols.len(), step: calc.max(n, 1)).map(i => {
            let row = cols.slice(i, calc.min(i + n, cols.len()))
            (row + range(n - row.len()).map(_ => (blocks: (), ctx: ctx))).enumerate().map(((j, c)) => at-width(j, c))
          })
        }
      } else { (b.columns.map(c => c + (ctx: ctx)),) }
      let gutter = pt(b.at("gutter", default: 0))
      for (ri, cols) in rows.enumerate() {
        let widths = cols.map(c => if c.at("width", default: none) == none { 1fr } else { pt(c.width) })
        let gap = if type(b.columns) == dictionary { pt(b.columns.at("row_gap", default: 0)) } else { 0pt }
        let cell(c, content) = grid.cell(align: if c.at("valign", default: "top") == "center" { horizon } else { top },
          content)
        let plain = grid(columns: widths, column-gutter: gutter,
          ..cols.map(c => cell(c, blocks(spec, c.at("blocks", default: ()), c.ctx, first: true))))
        block(width: 100%, above: if ri == 0 { above } else { gap }, below: if ri == rows.len() - 1 { below } else { 0pt },
          breakable: false, if not cols.any(c => "repeat" in c) { plain } else { layout(size => {
          // a `repeat` column (")" beside a caption) sets its text once a line, as many lines as the tallest other
          // column of the row is high at its pitch (lib/latex/xdoc.lua and lib/docx/xdoc.lua count them alike)
          let fixed = widths.filter(w => type(w) == length).sum(default: 0pt) + gutter * (cols.len() - 1)
          let flex = widths.filter(w => type(w) != length).len()
          let w-of(w) = if type(w) == length { w } else { (size.width - fixed) / calc.max(flex, 1) }
          let tall = cols.zip(widths).filter(((c, w)) => "repeat" not in c)
            .map(((c, w)) => measure(block(width: w-of(w), blocks(spec, c.blocks, c.ctx, first: true))).height)
          let h = tall.fold(0pt, calc.max)
          grid(columns: widths, column-gutter: gutter, ..cols.map(c => if "repeat" in c {
            let p = pitch-of(spec, c.at("pitch", default: none))
            cell(c, range(calc.max(calc.ceil(h / p - 0.01), 0)).map(_ => line-block(spec, c, inl(c, str(c.repeat)),
              0pt, 0pt)).join())
          } else { cell(c, blocks(spec, c.blocks, c.ctx, first: true)) }))
        }) })
      }
      first = false
    } else if "each" in b {
      let items = lookup(ctx, b.each)
      if items == none { panic("xdoc: missing required metadata field `" + b.each + "`") }
      for (i, it) in items.enumerate() {
        // between two items: the blocks in the context of the item before (its fields decide a `when`), the item after
        // as `next` ("when: next.versus"; lib/pandoc/xdoc.lua tree alike)
        if i > 0 and "between" in b {
          blocks(spec, b.between, item-ctx(ctx, items.at(i - 1), i: i - 1) + (next: it), first: false, page: page)
        }
        // the space above the first item's first block: the each block's own
        let bl = b.blocks
        if i == 0 and bl.len() > 0 { bl.at(0).insert("above", calc.max(b.at("above", default: 0),
          bl.at(0).at("above", default: 0))) }
        // `gap`: the least space between two items (above the first block of every item after the first)
        if i > 0 and bl.len() > 0 and b.at("gap", default: 0) > 0 { bl.at(0).insert("above", calc.max(b.gap,
          bl.at(0).at("above", default: 0))) }
        blocks(spec, bl, item-ctx(ctx, it, i: i), first: first and i == 0, page: page)
      }
      if items.len() > 0 { first = false }
    } else if "when" in b or "unless" in b {
      // the blocks when the field is set (`when`) or not (`unless`): false, "" and an empty list are not set; a
      // field the frontmatter lacks has the block's `default`
      let v = lookup(ctx, if "when" in b { b.when } else { b.unless })
      if v == none { v = b.at("default", default: none) }
      // `is`: set when the value is that one (compared as text)
      let on = if "is" in b { v != none and str(v) == str(b.is) } else { is-set(v) }
      if on == ("when" in b) {
        blocks(spec, b.blocks, ctx, first: first, page: page)
        first = false
      }
    } else if "box" in b {
      // a ruled box (a "court use only" area, a caption column ruled at its side): its blocks `inset` from its
      // edges, `stroke` on its sides (a number, or per side: top, right, bottom, left), `width` (the container's when
      // not given), `height` (fixed when given), the blocks set at its `valign` (top, center, bottom)
      let sides(v, f) = if type(v) == dictionary {
        ("top", "right", "bottom", "left").map(k => (k, f(v.at(k, default: 0)))).to-dict()
      } else { f(v) }
      let al = (top: top, center: horizon, bottom: bottom).at(b.at("valign", default: "top"))
      block(width: if "width" in b { pt(b.width) } else { 100% },
        height: if "height" in b { pt(b.height) } else { auto },
        stroke: sides(b.at("stroke", default: 0), x => if x > 0 { pt(x) } else { none }),
        inset: sides(b.at("inset", default: 0), pt), above: above, below: below, breakable: false,
        align(al, blocks(spec, b.box, ctx, first: true)))
      first = false
    } else if "fill" in b {
      // space that fills the page: what the page leaves, shared by weight among its fills (typst drops the space
      // of the blocks next to it, and the model drops it in every engine)
      if not page { panic("xdoc: a fill is set in a page's own blocks (cover, front, closing), not in a column or group") }
      v(fill-weight(b) * 1fr)
      first = false
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

/// The label of a heading whose level's style numbers it (`number`: a typst numbering pattern of one counting
/// symbol, "I.", "A.", "1.", "a.", "(1)"; `number_prefix`: literal text before it, "POINT "), or none. The count is
/// typst's heading counter's (a heading steps its level and drops the deeper ones), counted here from the
/// headings before it: the model's headings are unnumbered for typst (lib/pandoc/xdoc.lua heading_labels alike).
#let heading-label(spec, h) = {
  let st = heading-style(spec, h.level)
  // a layout heading (<xd-lh>) is never numbered, and does not count
  if "number" not in st or h.at("label", default: none) == <xd-lh> { return none }
  // typst's counter: a level steps itself and drops the deeper ones, or pads the levels above it with 1s
  let counts = (0,)
  for x in query(selector(heading).before(h.location(), inclusive: true)).filter(x => x.at("label", default: none) != <xd-lh>) {
    let l = calc.min(x.level, 9)
    if counts.len() >= l { counts = counts.slice(0, l); counts.at(l - 1) += 1 } else { while counts.len() < l { counts.push(1) } }
  }
  st.at("number_prefix", default: "") + numbering(st.number, counts.at(calc.min(h.level, 9) - 1))
}

/// The width of a numbered level's label box: `label_box`, else a `hang` over 0 (the title's later lines hung under the
/// title), else none (the label before the title after a space).
#let label-width(st) = if "label_box" in st { st.label_box } else if st.at("hang", default: 0) > 0 { st.hang } else { none }

/// A heading's text with its label (heading-label): in its box (label-width), else before it after a space.
#let labeled(st, lab, body) = {
  let w = label-width(st)
  if w != none { [#box(width: pt(w), lab)#body] } else { [#lab #body] }
}

/// The words of a body (`{body_words}`; lib/pandoc/xdoc.lua plain_words): split at white space, a word holds an ASCII
/// letter or digit.
#let plain-words(s) = s.split(regex("\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()

/// The entries of the frontmatter's table of authorities (`authorities: [{heading, entries: [{cite, find}]}]`), in
/// order, each with its number k (from 1; lib/pandoc/xdoc.lua numbers them alike). None for keyed authorities (a map:
/// keyed-entries).
#let authority-entries(meta) = {
  let au = meta.at("authorities", default: ())
  if type(au) != array { return () }
  let out = ()
  // `finds`: several strings that cite the entry ("art. I, § 3", "art. I, §§ 3"); `find` the first of them
  for g in au { for e in g.entries {
    let e = if "finds" in e and e.finds.len() > 0 { e + (find: e.finds.first()) } else { e }
    out.push(e + (k: out.len() + 1))
  } }
  out
}

/// The sort key of a keyed authority: its `sort`, else its name and citation, in lower case, letters, digits and
/// spaces only (lib/pandoc/xdoc.lua sort_key).
#let sort-key(e) = lower(str(e.at("sort", default: e.at("name", default: "") + " " + e.at("cite", default: ""))))
  .replace(regex("[^a-z0-9 ]"), "")

/// The keyed authorities (the frontmatter's `authorities: {key: {kind, name, cite, sort}}`, grouped by
/// layout.yaml `authorities.kinds`): every entry, group by group, sorted by sort key (then key), each with its key, its
/// group's index and its number k from 1 (lib/pandoc/xdoc.lua keyed alike). An entry of a kind no group lists stops
/// the render.
#let keyed-entries(spec, meta) = {
  let au = meta.at("authorities", default: none)
  let kinds = spec.at("authorities", default: (:)).at("kinds", default: none)
  if type(au) != dictionary or kinds == none { return () }
  for (key, e) in au.pairs() {
    if not kinds.any(g => g.kind == e.at("kind", default: none)) {
      panic("xdoc: authority `" + key + "` has kind `" + str(e.at("kind", default: none))
        + "`, which no group of layout.yaml authorities.kinds lists")
    }
  }
  let out = ()
  for (gi, g) in kinds.enumerate() {
    let es = au.pairs().filter(((key, e)) => e.at("kind", default: none) == g.kind)
      .sorted(key: ((key, e)) => (sort-key(e), key))
    for (key, e) in es { out.push(e + (key: key, group: gi, k: out.len() + 1)) }
  }
  out
}

/// Content with `tag` after its first word (into italics and bold): the page of a citation is the page of its first
/// word (the mark after the word, not before it: typst sets a mark that opens a line at the end of the line before).
#let after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) } else { let r = after-first-word(ch, tag); out.push(r.first()); placed = r.last() }
    }
    return (out.join(), placed)
  }
  (c, false)
}

/// The text of a keyed authority's row: a case-like group's (`italic`) name in italics before the citation, another
/// group's name, a comma and the citation, or the citation alone.
#let keyed-text(g, e) = if not is-set(e.at("name", default: none)) { e.cite } else if g.at("italic", default: false) {
  "*" + e.name + "* " + e.cite } else { e.name + ", " + e.cite }

/// Content with every occurrence of an authority's `find` text marked (<xd-toa>, the entry's number) at the end of the
/// word it ends in: the pages of the table of authorities. Not before the word (typst sets a mark that opens a line at
/// the end of the line before, a page early), not inside it (see below).
#let with-marks(meta, content) = {
  let out = content
  for e in authority-entries(meta) {
    for find in e.at("finds", default: if "find" in e { (e.find,) } else { () }) {
      let k = e.k
      out = {
        // the whole word around the find: a show rule that split it ("MCL 15.243" from "(1)(f)") would let
        // xengine's ")(" box start a word of its own, a place to break the line LaTeX and Word do not have
        // (a find that ends in a letter or digit ends where the word does: "Art. V" is not in "Art. VII")
        let bound = if find.match(regex("\\w$")) != none { "\\b" } else { "" }
        // the mark before the word's last character, where no line ends: after the word it could start the next
        // line (a page late), before it end the line before (a page early); LaTeX and Word read the find's end too
        show regex("\\S*" + find.replace(regex("[.*+?^${}()|\\[\\]\\\\]"), m => "\\" + m.text) + bound + "\\S*"): it => {
          let cs = it.text.clusters()
          // (a match that ends in a section or pilcrow sign and its token, which lib/typst/xengine.typ boxes: before the
          // sign, as a tag inside that box is set a line below, after the paragraph when it ends one: a page late at a page
          // end, "art. XVI, § 1.")
          let signs = cs.enumerate().filter(((i, c)) => c in ("§", "¶") and cs.at(i + 1, default: "") == " ")
          let at = if signs.len() == 0 or " " in cs.slice(signs.last().first() + 2) { cs.len() - 1 } else {
            signs.last().first() }
          if cs.len() < 2 { [#it#metadata(k)<xd-toa>] } else { [#cs.slice(0, at).join()#metadata(k)<xd-toa>#cs.slice(at).join()] }
        }
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


/// A coloured cover (layout.yaml `cover_fill: "#rrggbb"`, a court's mandated cover colour): the page background of
/// every page before the tables (the pages before <xd-heads>); none otherwise.
#let cover-fill(spec) = if "cover_fill" not in spec { (:) } else {
  (background: context {
    let h = query(<xd-heads>)
    if h.len() > 0 and here().page() < h.first().location().page() {
      rect(width: 100%, height: 100%, fill: rgb(spec.cover_fill))
    }
  })
}
/// The label of the page at a location.
#let page-label(loc) = {
  let fmt = xd-num.at(loc)
  if fmt == none { "" } else { numbering(fmt, ..counter(page).at(loc)) }
}

/// The show rule of the model's headings: the level's style, kept with what follows; a numbered level's label
/// (heading-label) on a line of its own (`label_line`), in its box (label-width) or before the title.
#let show-heading(spec) = it => {
    let st = heading-style(spec, it.level)
    // typst sets a heading bold by itself; here only the style's `bold` does, as in LaTeX and Word
    set text(weight: "regular")
    let body = if st.at("upper", default: false) { upper(it.body) } else { it.body }
    let (above, below) = (pt(st.at("above", default: 0)), pt(st.at("below", default: 0)))
    if "number" not in st { line-block(spec, st + (keep: true), body, above, below) } else { context {
      // a numbered level: the label on a line of its own (`label_line`), or before the title
      let lab = heading-label(spec, it)
      if st.at("label_line", default: false) {
        line-block(spec, st + (keep: true), lab, above, 0pt)
        line-block(spec, st + (keep: true), body, 0pt, below)
      } else {
        let hang = if label-width(st) != none { (hang: label-width(st)) } else { (:) }
        line-block(spec, st + hang + (keep: true), labeled(st, lab, body), above, below)
      }
    } }
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

/// The paragraphs of a body (cmarker's sequence, split at its paragraph breaks) that anchor a footnote, with no widow or
/// orphan control, as lib/latex/xdoc.lua and lib/docx/xdoc.lua set them (a show rule on par comes too late: the note is
/// realized by then). Not with layout.yaml `footnote.widows: true` (the paragraph keeps its widow and orphan control).
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


/// The paragraph settings of justified text (layout.yaml `justify: true`; none otherwise): every line but a
/// paragraph's last set to the full measure by stretching its spaces only, so the lines break where they do ragged
/// (first fit, a space never narrower than its width; LaTeX: interword stretch and no shrink, Word: jc both).
#let justified(spec) = if spec.at("justify", default: false) {
  (justify: true, justification-limits: (spacing: (min: 100%, max: 100000%), tracking: (min: 0pt, max: 0pt)))
} else { (:) }
/// A table of the body, in place of cmarker's (lib/pandoc/xdoc.lua table_nodes, rule for rule): a rule, then each
/// row as columns of equal width `table.gutter` apart, its cells one paragraph each in the `table` style (`head` over
/// it for the header rows, bold by default), a rule between two rows and after the last, `table.pad` between a rule
/// and a row; `table.above` and `table.below` around the whole. cmarker gives no alignment; spans are not supported
/// (fb-595.54.14).
#let body-table(spec, n, children) = {
  let t = spec.at("table", default: (:))
  let stroke = t.at("stroke", default: 0.5)
  let pad = t.at("pad", default: 0)
  let base = (:)
  for k in ("pitch", "size") { if k in t { base.insert(k, t.at(k)) } }
  let rows = ()
  let cells = ()
  for a in children {
    if a.func() == table.header {
      rows += a.children.map(c => c.body).chunks(n).map(r => (head: true, cells: r))
    } else if a.func() == table.cell { cells.push(a.body) } else { cells.push(a) }
  }
  rows += cells.chunks(n).map(r => (head: false, cells: r))
  let rule(above, below) = block(width: 100%, height: pt(RULE + stroke), above: pt(above), below: pt(below),
    place(top + left, dy: pt(stroke) / 2, line(length: 100%, stroke: pt(stroke))))
  rule(t.at("above", default: 0), pad)
  for (i, r) in rows.enumerate() {
    let st = base + if r.head { t.at("head", default: (bold: true)) } else { (:) }
    let cs = r.cells + range(n - r.cells.len()).map(_ => [])
    block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(columns: (1fr,) * n,
      column-gutter: pt(t.at("gutter", default: 0)), ..cs.map(c => line-block(spec, st, c, 0pt, 0pt))))
    rule(pad, if i == rows.len() - 1 { t.at("below", default: 0) } else { pad })
  }
}

/// The body: markdown; paragraphs at the body pitch with a first-line indent, headings, quotations, lists and
/// footnotes as layout.yaml says, the authorities marked.
#let body-of(spec, meta, src) = {
  let q = spec.at("quote", default: (:))
  // justified text (layout.yaml `justify`): the body, its quotations, lists and tail
  set par(..justified(spec))
  // the space between two body paragraphs, a paragraph and a list, two lists (layout.yaml `paragraph_gap`; next to
  // a heading or quotation that block's own space applies)
  let pgap = spec.at("paragraph_gap", default: none)
  set par(..if pgap != none { (spacing: pt(pgap)) } else { (:) })
  show heading: show-heading(spec)
  show list: it => if pgap == none { list-items(spec, it, 0) } else { block(above: pt(pgap), below: pt(pgap), list-items(spec, it, 0)) }
  show enum: it => if pgap == none { list-items(spec, it, 0) } else { block(above: pt(pgap), below: pt(pgap), list-items(spec, it, 0)) }
  show table: it => body-table(spec, if type(it.columns) == int { it.columns } else { it.columns.len() }, it.children)
  show quote.where(block: true): it => block(width: 100%, above: pt(q.at("above", default: 0)),
    below: pt(q.at("below", default: 0)), {
    set text(..edges(pitch-of(spec, q.at("pitch", default: none))))
    set par(first-line-indent: 0pt, spacing: pt(q.at("gap", default: 0)))
    // a list in the quotation: a block the gap from the paragraphs around it (lib/latex/xdoc.lua, lib/docx/xdoc.lua)
    let qgap = pt(q.at("gap", default: 0))
    show list: it => block(above: qgap, below: qgap, list-items(spec, it, 0))
    show enum: it => block(above: qgap, below: qgap, list-items(spec, it, 0))
    pad(left: pt(q.at("left", default: spec.indent)), right: pt(q.at("right", default: spec.indent)), it.body)
  })
  let rendered = cmarker.render(apostrophes(src), raw-typst: false, smart-punctuation: true, h1-level: 1, scope: markdown-scope())
  with-marks(meta, if spec.at("footnote", default: (:)).at("widows", default: false) { rendered } else { free-notes(rendered) })
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
    align(right + bottom, { set par(justify: false); page }),
  ))
  if target == none { row } else { link(target, row) }
}

/// The title of a table (contents, authorities): the level-1 heading style, not a heading itself; it opens a page.
#let table-title(spec, t) = {
  // `break: false` (the contents on the cover's page): no page of its own, its heading's space above
  let own = t.at("break", default: true) != false
  if own { pagebreak(weak: true) }
  let st = heading-style(spec, 1) + t.at("style", default: (:))
  line-block(spec, st + (keep: true), inl(st, t.title), if own { 0pt } else { pt(st.at("above", default: 0)) },
    pt(st.at("below", default: 0)))
}

/// The table of contents (layout.yaml `contents`): a row per heading of the body (levels to `depth`), its text
/// wrapping before a page column `col` and `hang` under its first line, `step` further in per level, `above` over
/// each row; the leader runs from three spaces after the text to the page (lib/typst/xengine.typ listing-row).
#let contents-pages(spec, c) = {
  table-title(spec, c)
  set text(..edges(pitch-of(spec, c.at("pitch", default: none))))
  context {
    let hs = query(selector(heading).after(<xd-heads>)).filter(h => h.level <= c.at("depth", default: 3))
    for h in hs {
      // the row's space above outside the indent (inside it typst would drop it: the start of a container)
      block(width: 100%, above: pt(c.at("above", default: 0)), below: 0pt,
        pad(left: (h.level - 1) * pt(c.at("step", default: 0)), {
          // a numbered heading's row carries its label, in the level's `label_box` (the row's later lines under the
          // title) or before the title after a space
          let st = heading-style(spec, h.level)
          let lab = heading-label(spec, h)
          let boxed = lab != none and "label_box" in st
          let text = if lab == none { h.body } else if boxed { labeled(st, lab, h.body) } else [#lab #h.body]
          let hang = if boxed { pt(st.label_box) } else { pt(c.at("hang", default: 0)) }
          table-row(h.location(), text, page-label(h.location()), pt(c.at("col", default: 36)), hang, 0pt)
        }))
    }
  }
}

/// A row of the authorities, the citation `cite` and its pages `list`: the page column is `col` (layout.yaml
/// `authorities.col`) or the list's own width when wider, but never so wide that the citation loses its own width (up
/// to half the line) and a leader of three ems: a longer list wraps in that column, so the citation does not run into
/// the pages (DEF-FORM-004). The row's space above is outside the layout (inside it typst would drop it).
#let page-fit(a, cite, list) = block(width: 100%, above: pt(a.at("above", default: 0)), below: 0pt, layout(size => {
  let room = size.width - calc.min(measure(cite).width, size.width / 2) - 3em.to-absolute() - LEADER-MIN.to-absolute()
  let col = calc.max(calc.min(measure(list).width, room), pt(a.at("col", default: 56)))
  table-row(none, cite, list, col, pt(a.at("hang", default: 0)), 0pt)
}))

/// The table of authorities (layout.yaml `authorities`, the frontmatter's `authorities`): each group's heading in
/// the `group` style, then a row per entry, its pages (the distinct pages of its marks, or the entry's own `pages`,
/// or "--") in a column of `col` or the list's own width when wider (page-fit).
#let authorities-pages(spec, a, meta) = {
  table-title(spec, a)
  set text(..edges(pitch-of(spec, a.at("pitch", default: none))))
  let gst = a.at("group", default: (bold: true))
  if type(meta.authorities) == dictionary {
    // keyed authorities: the cited entries of each group of `kinds`, their pages from the links' marks; a list of
    // `passim` pages or more is "passim"; `page_heading` on the first group's line, at the right
    if "kinds" not in a { panic("xdoc: the frontmatter's authorities are keyed (a map): layout.yaml authorities.kinds names their groups") }
    let entries = keyed-entries(spec, meta)
    context {
      let hits = query(<xd-toa>)
      let first = true
      for (gi, g) in a.kinds.enumerate() {
        let members = entries.filter(e => e.group == gi and hits.any(h => h.value == e.k))
        if members.len() == 0 { continue }
        let title = inl(gst, g.title)
        if first and "page_heading" in a { title = [#title#h(1fr)#inl(gst, a.page_heading)] }
        line-block(spec, gst + (keep: true), title, pt(gst.at("above", default: 0)), pt(gst.at("below", default: 0)))
        first = false
        for e in members {
          let pages = hits.filter(m => m.value == e.k).map(m => page-label(m.location())).dedup()
          let list = if pages.len() >= a.at("passim", default: 1000000) { emph[passim] } else { pages.join(", ") }
          page-fit(a, md(keyed-text(g, e)), list)
        }
      }
    }
    return
  }
  let k = 0
  for g in meta.authorities {
    line-block(spec, gst + (keep: true), inl(gst, g.heading), pt(gst.at("above", default: 0)),
      pt(gst.at("below", default: 0)))
    for e in g.entries {
      k += 1
      let key = k
      context {
        let pages = query(<xd-toa>).filter(m => m.value == key).map(m => page-label(m.location())).dedup()
        // `passim` pages or more: "passim", in italics (as the keyed list)
        let list = if "find" not in e { str(e.at("pages", default: "--")) } else if pages.len() == 0 { "--" } else if (
          pages.len() >= a.at("passim", default: 1000000)) { emph[passim] } else { pages.join(", ") }
        page-fit(a, md(e.cite), list)
      }
    }
  }
}


/// A string as a regex that matches it literally.
#let literal(s) = s.replace(regex("[\\\\^$.|?*+()\\[\\]{}]"), m => "\\" + m.text)

/// The body sections set before the tables (layout.yaml `body_before_tables`), and the rest, as markdown: `count: N`,
/// the text before the body's (N+1)th level-1 heading; `until: <text>`, the text before the first level-1 heading that
/// starts with it; `marker: <text>`, the text before a line that is that text alone (the line dropped; the text
/// literal). A count or heading may read a field; a missing or empty one, or a split the body does not hold, sets
/// nothing before the tables. Footnote definitions serve both parts (lib/pandoc/xdoc.lua split_head).
#let split-head(spec, meta, body) = {
  let b = spec.at("body_before_tables", default: none)
  if b == none { return ("", body) }
  let value(v) = { let ps = expand(str(v), meta, true); if ps.len() > 0 and ps.first() != "" { ps.first() } else { none } }
  let (at, end) = (none, none)
  if "marker" in b {
    let m = str(b.marker) // literal text ("{{contents}}")
    let found = if m == "" { none } else { body.match(regex("(?m)^[ \\t]*" + literal(m) + "[ \\t]*$")) }
    if found != none { (at, end) = (found.start, found.end) }
  } else if "until" in b {
    let u = value(b.until)
    let found = if u == none { none } else { body.match(regex("(?m)^# +" + literal(u))) }
    if found != none { (at, end) = (found.start, found.start) }
  } else if "count" in b {
    let n = value(b.count)
    let hs = body.matches(regex("(?m)^# +"))
    if n != none and int(n) < hs.len() { (at, end) = (hs.at(int(n)).start, hs.at(int(n)).start) }
  } else { panic("xdoc: body_before_tables needs count, until or marker") }
  if at == none or (at == 0 and end == 0) { return ("", body) }
  let defs = body.matches(regex("(?m)^\\[\\^[^\\]]+\\]:.*(\\n(    |\\t).*)*")).map(m => m.text).join("\n\n")
  (body.slice(0, at) + "\n\n" + defs, body.slice(end))
}
/// The body's markdown less its last paragraph, and that paragraph (or none): the last block that is not a footnote
/// definition, when it is a paragraph (not a heading, quotation, list, table, code or HTML) and calls no footnote
/// (layout.yaml `keep_with_closing`; lib/pandoc/xdoc.lua last_para takes the paragraph pandoc reads there).
#let split-last(src) = {
  let blocks = src.split(regex("\n[ \t]*\n"))
  let i = blocks.len() - 1
  while i >= 0 and (blocks.at(i).trim() == "" or blocks.at(i).trim(at: start).starts-with(regex("\\[\\^[^\\]]+\\]:"))) {
    i -= 1
  }
  if i < 0 { return (src, none) }
  let b = blocks.at(i).trim("\n")
  let opens = regex("^(#|>|[-*+][ \t]|[0-9]+[.)][ \t]|\\||    |\t|```|~~~|<)")
  if b.match(opens) != none or b.contains("[^") { return (src, none) }
  ((blocks.slice(0, i) + blocks.slice(i + 1)).join("\n\n"), b)
}

/// `over` merged onto `base` (a layout's `base`, fb-595.17): a dictionary merges key by key, recursively; any other
/// value replaces the base's; none (YAML `~`) drops the base's key (tools/fb/src/enginegen/base.rs merge alike).
#let merge-layout(base, over) = {
  if type(base) != dictionary or type(over) != dictionary { return over }
  let out = base
  for (k, v) in over {
    if v == none { let _ = out.remove(k, default: none) } else if k in out { out.insert(k, merge-layout(out.at(k), v)) } else { out.insert(k, v) }
  }
  out
}

/// The layout with its `base` merged under it: `base: /lib/layouts/<name>.yaml`, a path from the repo root (the
/// generic FRCP brief, a federal district's local rules overlaid on it); a base may name its own base.
#let with-base(spec, depth: 0) = {
  if type(spec) != dictionary or "base" not in spec { return spec }
  let over = spec
  let path = over.remove("base")
  if type(path) != str or not path.starts-with("/") { panic("xdoc: layout.yaml `base` is a path from the repo root (/lib/layouts/<name>.yaml)") }
  if depth >= 8 { panic("xdoc: layout.yaml `base` " + path + ": bases chain more than 8 deep (a cycle?)") }
  merge-layout(with-base(yaml(path), depth: depth + 1), over)
}

/// The whole document: page, type, the cross-engine model, front matter, body, closing, tail.
#let xdoc(spec, meta, body) = {
  let spec = with-base(spec)
  // the values the model computes ({xd.words}), from the sample as written
  let meta = computed(spec, meta, body)
  let m = spec.margin
  let pn = spec.at("page_number", default: (align: "center", from: 1))
  let fn = spec.at("footnote", default: (:))
  let note-pitch = pitch-of(spec, fn.at("pitch", default: none))
  set document(title: str(meta.at("title", default: meta.at("doc_title", default: meta.at("brief_title", default: "")))))
  // The page number centered in a single line box in the bottom margin, where Word's footer sets it.
  set page(paper: PAPER.at(spec.at("paper", default: "letter")), margin: (top: pt(m.top), bottom: pt(m.bottom), left: pt(m.left), right: pt(m.right)),
    footer-descent: 30%, footer: context {
      let n = counter(page).get().first()
      let fmt = xd-num.get()
      if pn != none and fmt != none and n >= pn.at("from", default: 1) {
        let al = (left: left, center: center, right: right).at(pn.at("align", default: "center"))
        // the number alone, or the layout's `page_number.text` ("Page {page} of {pages}": pages, the last page's count)
        let label = numbering(fmt, n)
        let shown = if "text" in pn {
          pn.text.replace("{pages}", str(counter(page).final().first())).replace("{page}", label)
        } else { label }
        align(al, text(..edges(pt(spec.pitch.single)), shown))
      }
    }, ..cover-fill(spec))
  set text(font: spec.font, size: pt(spec.size), lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: pt(spec.indent), all: true))
  show: xengine.with(pitch: pt(spec.pitch.body), list-indent: none) // lists: list-items
  // a doubled section sign or pilcrow stays with its number, as LaTeX and Word bind it (xengine binds a single one)
  show regex("(§§|¶¶) \\S+"): it => box(it)
  // no punctuation hanging into the margin (typst's overhang): LaTeX and Word set none, and a hanging period moved a
  // centered line 1.4 pt and lets a line hold more
  set text(overhang: false)
  set heading(numbering: none)
  // headings set by the layout (a certificate's title, `heading: <level>`) take the body's heading style
  show heading: show-heading(spec)
  set footnote.entry(gap: pt(fn.at("gap", default: 7)), clearance: pt(fn.at("clearance", default: 9.1)), indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  // a URL breaks only where every engine breaks it (url-pieces)
  show URL: it => url-pieces(it.text).map(p => box(p)).join(sym.zws)
  // links as their text when the court bars hyperlinks (layout.yaml links: false; lib/pandoc/xdoc.lua unlink): a URL
  // target, not a keyed authority's (toa:) nor the contents' own (a location)
  show link: it => if spec.at("links", default: true) != false or type(it.dest) != str or it.dest.starts-with("toa:") {
    it
  } else { it.body }
  // keyed authorities: a link [text](toa:key) is its text with the entry's mark after its first word
  let keyed = keyed-entries(spec, meta)
  show link: it => if keyed.len() == 0 or type(it.dest) != str or not it.dest.starts-with("toa:") { it } else {
    let e = keyed.find(e => e.key == it.dest.slice(4))
    if e == none { panic("xdoc: the link `" + it.dest + "` has no entry under the frontmatter's authorities") }
    after-first-word(it.body, [#metadata(e.k)<xd-toa>]).first()
  }
  show footnote.entry: it => {
    set text(size: pt(fn.at("size", default: spec.size)), ..edges(note-pitch))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, ..justified(spec))
    let note = it.note
    // a note is never split across pages (LaTeX: \interfootnotelinepenalty 10000): its line moves on with it
    block(breakable: false)[#super(numbering(note.numbering, ..counter(footnote).at(note.location())))#h(0.25em)#with-marks(meta, note.body)]
  }
  check-body(spec, body)
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
  let words = plain-words(if rest == "" { body } else { body.slice(0, body.len() - rest.len()) })
  let meta = if "body_words" in meta { meta } else { meta + (body_words: words) }
  // a table of contents a frontmatter field switches (layout.yaml contents.when, `default` when the frontmatter lacks
  // the field; lib/pandoc/xdoc.lua switch_contents)
  let spec = if "contents" in spec and "when" in spec.contents and not is-set({
    let v = lookup(meta, spec.contents.when)
    if v == none { spec.contents.at("default", default: none) } else { v } }) {
    let s = spec
    let _ = s.remove("contents")
    s
  } else { spec }
  let front = if pn == none { none } else { pn.at("front", default: none) }
  // `page_number.cover`: the cover counted in the tables' numbering (counted: unprinted, the tables from ii; numbered:
  // printed too); otherwise unnumbered and the tables from i
  let cover-mode = if front == none or pn == none { none } else { pn.at("cover", default: none) }
  if front != none {
    if cover-mode == none { xd-num.update(none) } else {
      counter(page).update(1)
      xd-num.update(if cover-mode == "numbered" { FORMATS.at(front) } else { none })
    }
  }
  // the contents on the cover's page (contents.break: false): no break after the cover
  let on-cover = spec.at("contents", default: (:)).at("break", default: true) == false
  if on-cover and front != none { panic("xdoc: contents.break: false needs a cover numbered with the body (no page_number.front)") }
  if "cover" in spec {
    blocks(spec, spec.cover, meta, first: true, page: true)
    if not on-cover { pagebreak() }
  }
  // the tables numbered apart (page_number.front), from 1 (from the cover when it is counted)
  if front != none {
    xd-num.update(FORMATS.at(front))
    if cover-mode == none { counter(page).update(1) }
  }
  // the pages before the tables (numbered with them): the layout's `before_tables`, then the body sections set before
  // them (`body_before_tables`); the contents list their headings
  let (pre, main) = split-head(spec, meta, main)
  [#metadata(none)<xd-heads>]
  if "before_tables" in spec {
    blocks(spec, spec.before_tables, meta, first: true, page: true)
    pagebreak()
  }
  // `body_before_tables: {.., place: between}`: the sections between the contents and the authorities, after the
  // layout's `between_tables`
  let between = spec.at("body_before_tables", default: (:)).at("place", default: none) == "between"
  if pre != "" and not between {
    body-of(spec, meta, pre)
    pagebreak()
  }
  if "contents" in spec { contents-pages(spec, spec.contents) }
  if "between_tables" in spec {
    pagebreak(weak: true)
    blocks(spec, spec.between_tables, meta, first: true, page: true)
  }
  if pre != "" and between {
    pagebreak(weak: true)
    body-of(spec, meta, pre)
  }
  if "authorities" in spec and "authorities" in meta { authorities-pages(spec, spec.authorities, meta) }
  if "contents" in spec or "authorities" in spec or "between_tables" in spec or (pre != "" and between) {
    pagebreak(weak: true)
  }
  if front != none { xd-num.update("1"); counter(page).update(1) }
  check-fills(spec.at("front", default: ()))
  check-fills(spec.at("closing", default: ()))
  check-fills(spec.at("after_tail", default: ()))
  blocks(spec, spec.at("front", default: ()), meta, first: true, page: true)
  // the last paragraph kept whole on the page of the closing (layout.yaml keep_with_closing)
  let (main, last) = if spec.at("keep_with_closing", default: false) { split-last(main) } else { (main, none) }
  body-of(spec, meta, main)
  // (a parbreak: inline content alone in a block is no paragraph, and would lose its first-line indent)
  if last != none { block(width: 100%, above: 0pt, below: 0pt, breakable: false, sticky: true, { body-of(spec, meta, last); parbreak() }) }
  blocks(spec, spec.at("closing", default: ()), meta, page: true)
  if rest != "" {
    if tail.at("break", default: false) { pagebreak(weak: true) }
    block(width: 100%, above: pt(tail.at("above", default: 0)), below: 0pt, {
      set text(..edges(pitch-of(spec, tail.at("pitch", default: none))))
      set par(first-line-indent: (amount: pt(tail.at("indent", default: 0)), all: true),
        spacing: pt(tail.at("gap", default: 0)))
      body-of(spec, meta, rest)
    })
  }
  // the blocks after the tail (layout.yaml after_tail: a certificate after a body part the closing precedes)
  blocks(spec, spec.at("after_tail", default: ()), meta, page: true)
}
