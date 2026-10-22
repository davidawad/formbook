// U.S. Bankruptcy Court, Western District of Tennessee: adversary complaint (FRBP 7001, 7010).
//
// Rule-driven and content-agnostic. No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The body is markdown rendered by cmarker; the metadata is the YAML
// frontmatter of the sample (schema: ../README.md, "Markdown contract"). Requirement IDs (TNWB-...)
// refer to ../README.md and ../../rules.md.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule, to the exemplar's convention,
// or is a stated choice in ../README.md). TNWB-FORM-002: the local rules set no typeface, size,
// spacing or margin, so every number below is the exemplar's convention or a stated choice.
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // the exemplar's face (Times New Roman); vendored, docs/FONTS.md
#let type-size = 12pt                      // the exemplar's body size
#let note-size = 10pt                      // footnotes (the exemplar's are smaller than the body)
#let page-margin = 1in                     // the exemplar's margins, letter paper
#let para-indent = 0.5in                   // first-line indent; the paragraph number or prayer letter stands there
#let number-box = 0.5in                    // the number's box: the text starts 1 in from the margin, as filed
#let cap-left = 3.3in                      // caption: the party column
#let cap-mark = 0.5in                      // caption: the column of section marks (§), as filed
#let cap-designation = 1.5in               // caption: "DEBTOR.", "Plaintiff,", "Defendants." stand this far in
#let cap-versus = 0.5in                    // caption: "vs." stands this far in
#let rule = 0.5pt                          // the caption's rules and the transfer tables' rules
#let table-width = 60%                     // a transfer table: centered, its columns equal
#let table-inset = (x: 8pt, y: 3pt)        // a transfer table's cell padding
#let signature-indent = 2.5in              // the signature block, as filed

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/tnwb-adversary-complaint.lua sets the same twips).
#let pitch-body = 24pt                     // double spacing, as filed
#let pitch-single = 13.8pt                 // a single line: Word's single line in this face at 12 pt (1.15 x the size)
#let pitch-note = 11.5pt                   // a footnote line: Word's single line at 10 pt
#let gap = pitch-body / 2                  // around headings, the title, tables and the signature
#let note-gap = 6pt                        // between footnotes
#let note-clearance = 7.8pt                // above the footnote rule: with note-gap, Word's 13.8 pt separator line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, links, footnote references) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnwb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Blank-line separated blocks of the body, in order.
#let blocks-of(body) = body.trim(at: end).split(regex("\n[ \t]*\n")).filter(b => b.len() > 0)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: left, body)
  })

/// A body paragraph: the body pitch, the first-line indent, no space of its own (double spacing runs on).
#let body-par(body, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky, par(body))

/// An empty block of `h` (Word's empty paragraph: it is not dropped at the top of a page).
#let spacer(h) = block(width: 100%, height: h, above: 0pt, below: 0pt)

// ---------------------------------------------------------------------------
// Court heading and caption (TNWB-CAP-*; FRBP 9004(b), 7010 and Official Form 416 caption contents)
// ---------------------------------------------------------------------------

#let court-heading(meta) = {
  let lines = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF TENNESSEE")
  if "division" in meta { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, l))
  }
}

/// The caption as filed: the parties on the left, a section mark on every line in the middle, the case and
/// adversary numbers on the right; a rule under the debtor block and under the parties (a ruled row is taller by the
/// rule, as Word sets it). Rows: (left, right, left indent, rule below).
#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let chapter = need(meta, "chapter")
  let plaintiffs = need(meta, "plaintiffs")
  let defendants = need(meta, "defendants")
  let row(l, r: "", ind: 0pt, ruled: false) = (l, r, ind, ruled)

  let rows = (row("IN RE:"), row(""))
  let right = ("CASE NO.: " + need(meta, "case_number"),) + chapter
  for (i, d) in debtor.enumerate() { rows.push(row(upper(d), r: right.at(i, default: ""))) }
  for i in range(debtor.len(), right.len()) { rows.push(row("", r: right.at(i))) }
  rows.push(row(""))
  rows.push(row("DEBTOR.", ind: cap-designation))
  rows.push(row("", ruled: true))
  for (i, p) in plaintiffs.enumerate() {
    rows.push(row(upper(p), r: if i == 0 { "ADVERSARY PROCEEDING NO.: " + need(meta, "adversary_number") } else { "" }))
  }
  rows.push(row("Plaintiff" + if plaintiffs.len() > 1 { "s," } else { "," }, ind: cap-designation))
  rows.push(row(""))
  rows.push(row("vs.", ind: cap-versus))
  rows.push(row(""))
  for d in defendants { rows.push(row(upper(d))) }
  rows.push(row("Defendant" + if defendants.len() > 1 { "s." } else { "." }, ind: cap-designation, ruled: true))

  let cells = ()
  for (l, r, ind, ruled) in rows {
    let st = if ruled { (bottom: rule) } else { none }
    let ins = if ruled { (bottom: rule) } else { 0pt }
    cells.push(grid.cell(stroke: st, inset: ins, line-block(left: ind, inl(l))))
    cells.push(grid.cell(stroke: st, inset: ins, line-block(align(center)[§])))
    cells.push(grid.cell(inset: ins, line-block(inl(r))))
  }
  block(width: 100%, above: 0pt, below: 0pt, grid(columns: (cap-left, cap-mark, 1fr), ..cells))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations, headings, lettered prayer, transfer tables, quotations, footnotes
// ---------------------------------------------------------------------------

/// A transfer table (a markdown pipe table): centered, single-spaced, ruled, the header row bold and centered,
/// the columns equal; rows are not split and the header is not repeated (the docx engine does the same).
#let transfer-table(b) = {
  let cells-of(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let lines = b.split("\n").map(l => l.trim()).filter(l => l != "")
  let rows = lines.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => cells-of(l))
  let ncol = rows.first().len()
  block(width: 100%, above: 0pt, below: 0pt, align(center, block(width: table-width, {
    set align(left)
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    // Word sets the table's top rule above its first row's padding: the first row is taller by its width.
    table(columns: (1fr,) * ncol, stroke: rule,
      inset: (x, y) => if y == 0 { (..table-inset, top: table-inset.y + rule) } else { table-inset },
      ..rows.enumerate().map(((i, r)) => range(ncol).map(j => {
        let c = inl(r.at(j, default: ""))
        if i == 0 { align(center, strong(c)) } else { c }
      })).flatten())
  })))
}

/// Render a body (markdown string) as the pleading's paragraphs. `tail` (the signature block) is
/// kept in one unbreakable block with the last paragraph, so the signature never stands alone.
#let pleading-body(body, tail: none) = {
  let blocks = blocks-of(body)

  // Footnote definitions are blocks of their own; they are rendered where they are referenced.
  let notes = (:)
  for b in blocks {
    if b.starts-with("[^") {
      let m = b.match(regex("^\\[\\^([^\\]]+)\\]:\\s*([\\s\\S]*)$"))
      notes.insert(m.captures.at(0), m.captures.at(1))
    }
  }
  let with-notes(b) = {
    let keys = b.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
    b + keys.map(k => "\n\n[^" + k + "]: " + notes.at(k)).join()
  }

  let n = 0          // allegation number
  let first = true   // the introductory paragraph is not an allegation
  // The last body block (footnote definitions do not count) stays with the signature block.
  let last-idx = blocks.enumerate().filter(p => not p.at(1).starts-with("[^")).last().at(0)
  let tail-used = false
  let keep(piece) = {
    block(breakable: false, width: 100%, above: 0pt, below: 0pt)[#piece#tail]
  }
  for (idx, b) in blocks.enumerate() {
    let last = idx == last-idx and tail != none
    if b.starts-with("[^") {
      // rendered at the reference
    } else if b.match(regex("^#{1,3} ")) != none {
      // Headings: single-spaced, half a body line from the text on either side, kept with the text after them;
      // level 1 centered bold underlined capitals (as filed), level 2 centered bold, level 3 bold at the margin.
      let m = b.match(regex("^(#{1,3}) +([\\s\\S]*)$"))
      let lvl = m.captures.at(0).len()
      let txt = inl(m.captures.at(1))
      let h = if lvl == 1 { align(center, underline(strong(upper(txt)))) }
        else if lvl == 2 { align(center, strong(txt)) } else { strong(txt) }
      line-block(above: gap, below: gap, sticky: true, h)
    } else if b.starts-with("- ") {
      // Prayer items: lettered A., B., ... in the number's box at the indent; continuation lines join their item.
      let items = ()
      for line in b.split("\n") {
        if line.starts-with("- ") { items.push(line.slice(2)) }
        else if items.len() > 0 { items.at(items.len() - 1) = items.at(items.len() - 1) + " " + line.trim() }
      }
      for (i, it) in items.enumerate() {
        let piece = body-par[#box(width: number-box, numbering("A.", i + 1))#inl(with-notes(it))]
        if last and i == items.len() - 1 { keep(piece); tail-used = true } else { piece }
      }
    } else if b.starts-with("|") {
      spacer(gap)
      transfer-table(b)
      spacer(gap)
      if last { tail; tail-used = true }
    } else if b.starts-with(">") {
      let txt = b.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")
      let piece = block(width: 100%, above: gap, below: gap, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: para-indent, right: para-indent, inl(with-notes(txt)))
      })
      if last { keep(piece); tail-used = true } else { piece }
    } else {
      // Allegations are numbered from 1. Not numbered: the introduction, the prayer lead-in
      // ("WHEREFORE", kept with the prayer) and an editorial note in italics within square brackets (`*[...]*`).
      let wherefore = b.starts-with("WHEREFORE")
      let piece = if first or wherefore or b.starts-with("*[") {
        body-par(sticky: wherefore, inl(with-notes(b)))
      } else {
        n += 1
        body-par[#box(width: number-box)[#n.]#inl(with-notes(b))]
      }
      if last { keep(piece); tail-used = true } else { piece }
      first = false
    }
  }
  // The signature block must never be dropped: if the last body block was a heading, it follows that block.
  if not tail-used and tail != none { tail }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 1001-3(h): signature, address, telephone, email, state bar number)
// ---------------------------------------------------------------------------

/// The closing at the paragraph indent on a body line; then, 2.5 in from the margin and half a body line below,
/// the firm (bold), the /s/ signature, the name, the address and contact lines and the role (italic).
#let signature-block(meta) = {
  let s = need(meta, "signature")
  body-par(inl(s.closing))
  line-block(above: gap, left: signature-indent, strong(inl(s.firm)))
  line-block(left: signature-indent, inl("/s/ " + s.signer))
  line-block(left: signature-indent, inl(s.at("name_line", default: s.signer)))
  for line in s.lines { line-block(left: signature-indent, inl(line)) }
  line-block(left: signature-indent, emph(inl(s.role)))
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  set document(title: need(meta, "title"))
  // Letter paper; the page number centered in the bottom margin, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 157"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 10 pt, single-spaced (the entry sets its own leading: it does not inherit the body's); the mark, a
  // space, the note (Word's footnote layout). LibreOffice splits a note anywhere: so does typst here.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  court-heading(meta)
  caption(meta)
  line-block(above: gap, below: gap, sticky: true, align(center, strong(upper(need(meta, "title")))))
  pleading-body(body, tail: signature-block(meta))
}
