// Memorandum of law supporting a motion in an adversary proceeding, United States Bankruptcy Court
// for the District of Delaware. Rules: Del. Bankr. L.R. 7007-1 (no notice of motion in an adversary
// proceeding; opening brief filed with the motion), 7007-2(a)(i) (cover contents), 7007-2(a)(ii) (format),
// 7007-2(a)(iv) (length, exclusive of the tables), 7007-2(b) (contents, in order); Del. Bankr. L.R. 9004-1(a)
// (caption contents); Fed. R. Bankr. P. 9004(a) (legible), 7008 (consent statement, see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 7007-2(a)(ii): Courier New or Times New Roman; vendored
#let type-size = 12pt                    // LR 7007-2(a)(ii): at least 12-point typeface
#let margin = 1in                        // LR 7007-2(a)(ii): side margins not less than 1 inch (all sides used here)
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                 // first-line indent of body text
#let heading-hang = 0.5in                // a level-2 heading's lines after the first hang this far
#let quote-inset = 0.5in                 // a block quotation is indented half an inch on both sides
#let cap-left = 3.4in                    // Form 416 caption: the party column, ruled at its right and foot ...
#let cap-rule = 0.75pt                   // ... with a rule this thick ...
#let cap-pad-right = 10pt                // ... its text this far from the rule ...
#let cap-pad-below = 8pt                 // ... and its last line this far above it
#let cap-right = 0.35in                  // the case column's text this far right of the rule (0.2 in gutter + 0.15 in)
#let sig-col = 3.2in                     // the counsel and signature column; "Dated:" and the place sit left of it
#let toc-step = 0.5in                    // a contents row is indented this much per heading level below 1 ...
#let toc-hang = 0.5in                    // ... its lines after the first hang this much further
#let toc-col = 0.5in                     // the page column of the contents

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/deb-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                   // LR 7007-2(a)(ii): double spaced (docx 480)
#let pitch-single = 14pt                 // court line, captions, title, counsel, quotations, contents, footnotes (docx 280)
#let cover-gap = 14pt                    // a blank single line: court line to caption, caption to caption, to the title
#let counsel-above = 28pt                // the party designation to the cover's counsel block: two blank single lines
#let toc-above = 24pt                    // the contents' title to its first row
#let toc-gap-1 = 14pt                    // above a level-1 row of the contents
#let toc-gap = 7pt                       // above any other row
#let quote-gap = 14pt                    // above, between and below the paragraphs of a block quotation
#let sig-above = 24pt                    // the last paragraph to the signature block
#let note-gap = 7pt                      // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 6pt                // the text to the footnote rule (LibreOffice reserves no more above a note)
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("deb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Footnote definitions "[^n]: text" keyed by label. Their chunks are removed from the body and each reference
/// "[^n]" becomes a typst footnote with the definition's text.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^(\\w+)\\]:[ \\t]*(.+)$")) { d.insert(m.captures.at(0), m.captures.at(1)) }
  d
}

/// Inline markdown for one text segment; a space at either edge is kept (a footnote reference sits between two).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references turned into typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

#let is-def(t) = t.match(regex("^\\[\\^\\w+\\]:")) != none

/// A single-pitch line (one paragraph; it wraps on single lines). `above`: the space before it.
#let sline(content, above: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  align(align-to, par(first-line-indent: 0pt, content)))

/// Single-pitch lines, one paragraph each; an empty item is a blank single line.
#let lines(items) = {
  let gap = 0pt
  for i in items {
    if i == "" { gap += pitch-single } else {
      sline(inl(i), above: gap)
      gap = 0pt
    }
  }
}

/// Lines in a column from `sig-col`, single spaced; `left` (content) beside the first of them (docx: a tab and a
/// hanging indent). `rows`: strings, an empty one a blank single line.
#let column-lines(rows, left, above) = {
  set text(..edges(pitch-single))
  let gap = above
  for (n, r) in rows.enumerate() {
    if r == "" and n >= left.len() { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, left.at(n, default: []))#inl(r)]))
      gap = 0pt
    }
  }
}

/// A body paragraph on the double pitch, its first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(content))

/// Headings on the body pitch, bold, with no space of their own, kept with the block after them: level 1 centered
/// capitals, level 2 at the margin with its later lines hanging half an inch, level 3 centered capitals (the table
/// of authorities). `toc`: the heading goes into the contents.
#let heading-block(level, s, toc: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  if toc { [#metadata((level: level, text: s))<deb-toc>] }
  set par(first-line-indent: 0pt)
  if level == 2 { par(hanging-indent: heading-hang, text(weight: "bold", inl(s))) }
  else { align(center, par(text(weight: "bold", upper(inl(s))))) }
})

/// A block quotation: its paragraphs single spaced, indented on both sides, a blank single line above, between
/// and below them.
#let quotation(t, defs) = {
  let paras = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).map(p => p.trim())
    .filter(p => p != "")
  for p in paras {
    block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-inset, right: quote-inset, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, rich(p.replace("\n", " "), defs))
    }))
  }
}

/// The chunks of a markdown part: a heading, a quotation, or a paragraph.
#let blocks(chunks, defs, toc: false) = {
  for t in chunks {
    let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
    if h != none {
      let level = h.captures.at(0).len()
      heading-block(level, h.captures.at(1), toc: toc and level <= 2)
    } else if t.starts-with(">") {
      quotation(t, defs)
    } else {
      body-par(rich(t.replace("\n", " "), defs))
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (LR 7007-2(a)(i)): caption, title, party, date of filing, counsel
// ---------------------------------------------------------------------------

/// One caption block (FRBP 7010, Official Form 416; LR 9004-1(a)): the party names at the left, each designation
/// set right, ruled at the right and the foot; the case information right of the rule. Grid cell strokes and
/// insets: the rule runs the height of the row, the taller of the two columns, with the space below it under both
/// (LibreOffice takes a cell's bottom margin for the whole row; docx: a one-row table, the left cell bordered).
#let caption-block(c) = {
  let left-col = {
    for (k, p) in c.parties.enumerate() {
      lines(if k > 0 { ("",) } else { () } + p.names)
      if "designation" in p { sline(inl(p.designation), align-to: right) }
    }
  }
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
    inset: (x, y) => if x == 0 { (right: cap-pad-right, bottom: cap-pad-below) }
      else { (left: cap-right, bottom: cap-pad-below) },
    left-col, lines(c.right),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  sline(align-to: center, text(weight: "bold", upper(inl(meta.court))))
  caption-block(meta.caption.bankruptcy)
  caption-block(meta.caption.adversary)
  sline(above: cover-gap, align-to: center, text(weight: "bold", inl(meta.title)))
  sline(above: cover-gap, align-to: center, inl(meta.party_designation))
  column-lines(meta.counsel, ([Dated: #inl(meta.date)],), counsel-above)
}

// ---------------------------------------------------------------------------
// Contents and signature
// ---------------------------------------------------------------------------

/// Table of contents (LR 7007-2(b)(i)(A)): the table of authorities and the body's level-1 and level-2 headings,
/// single-spaced rows indented by level, the page in its own column at the right after a dot leader (listing-row).
#let contents() = {
  heading-block(1, "Table of Contents")
  context {
    set text(..edges(pitch-single))
    for (i, m) in query(<deb-toc>).enumerate() {
      let lv = m.value.level
      let ind = if lv == 2 { toc-step } else { 0pt }
      let n = counter(page).at(m.location())
      let page = numbering(if m.value.at("front", default: false) { "i" } else { "1" }, ..n)
      let title = if lv == 2 { inl(m.value.text) } else { upper(inl(m.value.text)) }
      listing-row(m.location(), { h(ind); title }, page, toc-col, ind + toc-hang,
        if i == 0 { toc-above } else if lv == 2 { toc-gap } else { toc-gap-1 })
    }
  }
}

/// The signature block, single spaced: "Dated:" and the place at the left, each counsel block (firm, a blank line,
/// the attorneys) from `sig-col`, a blank line between blocks; kept whole.
#let signature-block(meta) = {
  let rows = ()
  for (k, b) in meta.signature.blocks.enumerate() {
    if k > 0 { rows.push("") }
    rows += b.firm + ("",) + b.attorneys
  }
  block(width: 100%, above: sig-above, below: 0pt, breakable: false,
    column-lines(rows, ([Dated: #inl(meta.date)], inl(meta.signature.place)), 0pt))
}

// ---------------------------------------------------------------------------
// The document: the cover (unnumbered), the contents and the table of authorities (lower roman from i), the
// brief (arabic from 1; LR 7007-2(a)(iv) counts its pages without the tables)
// ---------------------------------------------------------------------------

#let footer = context if page.numbering != none {
  align(center, text(..edges(pitch-single), counter(page).display(page.numbering)))
}

#let deb-motion-brief(meta, body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and c != "---" and not is-def(c))
  // the front matter (the table of authorities) runs to the first level-1 heading; the brief from it
  let first = chunks.position(c => c.match(regex("^#[ \\t]")) != none)
  let front = if first == none { () } else { chunks.slice(0, first) }
  let main = if first == none { chunks } else { chunks.slice(first) }

  set page(paper: "us-letter", margin: margin, numbering: none, footer-descent: footer-descent, footer: footer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 547"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size, single-spaced (docx: Footnote Text in 14 pt boxes, 7 pt after), a short rule above.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)

  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  contents()
  for t in front {
    let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
    if h != none and h.captures.at(0).len() == 3 {
      // a front-matter section opens a page and is listed in the contents with its roman page
      pagebreak(weak: true)
      block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
        [#metadata((level: 1, text: h.captures.at(1), front: true))<deb-toc>]
        heading-block(3, h.captures.at(1))
      })
    } else {
      blocks((t,), defs)
    }
  }

  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  blocks(main.slice(0, -1), defs, toc: true)
  // the last paragraph is kept on one page with the signature block
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    blocks(main.slice(-1), defs, toc: true)
    signature-block(meta)
  })
}
