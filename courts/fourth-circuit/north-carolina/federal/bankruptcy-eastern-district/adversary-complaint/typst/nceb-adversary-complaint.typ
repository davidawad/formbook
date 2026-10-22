// Adversary complaint in the U.S. Bankruptcy Court, E.D.N.C. (nceb).
// Rules: FRBP 7010 (caption per Official Form 416A, which FRCP 10 applies to) and FRCP 10(a) (caption, title, file number);
// FRCP 10(b) (allegations in numbered paragraphs, each limited as far as practicable to one set of circumstances);
// FRBP 7008(a) (statement of core or non-core status and of consent to final orders); FRBP 9004(a) (legible),
// 9004(b) (caption: court, division, case and adversary numbers, designation); LBR 9004-2 (caption states the court,
// division and chapter); LBR 9011-4 and Admin Guide Rule 5005-4(8) (signature block, "s/" signature). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no E.D.N.C. typeface rule (FRBP 9004(a): "clearly legible"); Times New Roman, the house standard (docs/FONTS.md; the exemplar is in Century Schoolbook)
#let type-size = 12pt                   // no E.D.N.C. type-size rule; the exemplar is a 12 pt serif
#let margin = 1in                       // no E.D.N.C. margin rule; 1 inch as in the exemplar
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.2in               // the party column, ruled on its right and bottom
#let caption-gutter = 0.2in             // between the party column and the case numbers
#let caption-inset = 0.1in              // the case numbers' own inset
#let rule-pad-right = 10pt              // the party text stops this far left of the rule
#let rule-pad-bottom = 8pt              // and the rule this far below the last party's space
#let item-indent = 0.5in                // lettered items of the introduction
#let list-indent = 0.25in               // the prayer's numbers: a box of this width, the text hanging after it
#let quote-inset = 1in                  // block quotations: indented 1 inch on both sides
#let sig-indent = 3in                   // the signature column
#let cell-x = 6pt                       // table cell insets
#let cell-y = 3pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing as in the exemplar
#let pitch-single = 13.8pt              // caption, quotations, tables, signature: 1.15 x 12 pt
#let gap = 12pt                         // the unit of the spaces between single-spaced blocks

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nceb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (smart punctuation: the author's characters are kept).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Body chunks: blank-line-separated blocks of the markdown body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, right: right, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption: court (centered caps), then the parties on the left and the case numbers on the right.
// FRBP 9004(b) and LBR 9004-2 require the court, the division, the case and adversary numbers, the chapter,
// and a designation of the paper; the title below states that designation.
// ---------------------------------------------------------------------------

/// A party: its names, the designation at the right, a gap after it.
#let party-block(p) = {
  for n in p.names { line-block(md(n)) }
  line-block(below: gap, align(right, md(p.designation)))
}

#let caption(meta) = {
  for l in meta.court { line-block(align(center, text(weight: "bold", upper(l)))) }
  line-block(align(center, text(weight: "bold", upper(meta.division))))
  block(width: 100%, above: 1.5 * gap, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: rule-pad-right, bottom: rule-pad-bottom), {
      for p in meta.caption.in_re { party-block(p) }
      for p in meta.caption.parties { party-block(p) }
      v(gap)   // the last party's gap too (a block's last `below` is not kept)
    }),
    pad(left: caption-gutter + caption-inset, {
      v(pitch-double)
      line-block[Case No. #meta.case_number]
      line-block[Chapter #meta.chapter]
      if "adversary_number" in meta { line-block(above: pitch-single)[Adversary Proceeding No. #meta.adversary_number] }
    }),
  ))
  line-block(above: 1.5 * gap, below: gap, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(width: 100%, breakable: false, above: gap, below: 0pt, {
  if "lead" in sig { line-block(md(sig.lead)) }
  if "firm" in sig { line-block(above: gap, left: sig-indent, upper(sig.firm)) }
  for s in sig.signers {
    line-block(above: gap, left: sig-indent, md(s.sign))
    for l in s.lines { line-block(left: sig-indent, md(l)) }
  }
  if "role" in sig { line-block(above: gap, left: sig-indent, text(style: "italic", sig.role)) }
})

// ---------------------------------------------------------------------------
// Tables: a pipe table set as a ruled grid, single-spaced, the full text width; each column's share is its longest
// word (x3, so no word breaks) plus its longest cell (capped at 60 characters), as the docx filter computes it.
// ---------------------------------------------------------------------------

#let cells(line) = {
  let l = line.trim()
  if l.starts-with("|") { l = l.slice(1) }
  if l.ends-with("|") { l = l.slice(0, -1) }
  l.split("|").map(c => c.trim())
}

/// A cell's characters as the reader sees them (markdown escapes removed).
#let plain-len(s) = s.replace(regex("\\\\(.)"), m => m.captures.at(0)).clusters().len()

#let pipe-table(c) = {
  let lines = c.split("\n").filter(l => l.trim() != "")
  let rows = (cells(lines.at(0)),) + lines.slice(2).map(cells)
  // an all-empty header row is not a row
  if rows.at(0).all(x => x == "") { rows = rows.slice(1) }
  let n = rows.at(0).len()
  let weights = range(n).map(i => {
    let word = 1
    let text = 1
    for r in rows {
      let s = r.at(i, default: "")
      for w in s.split(" ").filter(w => w != "") { word = calc.max(word, plain-len(w)) }
      text = calc.max(text, calc.min(plain-len(s), 60))
    }
    3 * word + text
  })
  let total = weights.sum()
  block(width: 100%, above: gap / 2, below: gap, breakable: false, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    table(
      columns: weights.map(w => text-width * w / total),
      stroke: 0.5pt,
      inset: (x: cell-x, y: cell-y),
      ..rows.map(r => range(n).map(i => md(r.at(i, default: "")))).flatten(),
    )
  })
}

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, lettered introduction items, prayer list, quotations, tables
// ---------------------------------------------------------------------------

/// A block quotation: single-spaced, indented on both sides, its paragraphs a gap apart.
#let quotation(c) = {
  let ps = c.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).map(s => s.trim()).filter(s => s != "")
  for (i, q) in ps.enumerate() {
    line-block(above: if i == 0 { gap / 2 } else { gap }, below: if i == ps.len() - 1 { gap } else { 0pt },
      left: quote-inset, right: quote-inset, md(q))
  }
}

#let body-style(body) = {
  // Level 1: centered, bold, capitals (INTRODUCTION AND NATURE OF ACTION, FIRST CLAIM FOR RELIEF, PRAYER FOR RELIEF).
  // Level 2: centered, bold (the name of a claim). Level 3: centered (the statutory citation under a claim). All
  // single-spaced, kept with the text after them.
  show heading: it => {
    let (above, below) = if it.level == 1 { (2 * gap, gap) } else if it.level == 2 { (gap / 2, gap / 2) } else { (gap / 2, gap) }
    block(width: 100%, above: above, below: below, sticky: true, {
      set text(size: type-size, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      align(center, if it.level == 1 { text(weight: "bold", upper(it.body)) } else if it.level == 2 {
        text(weight: "bold", it.body) } else { it.body })
    })
  }
  let items = chunks(body)
  let first-heading = items.position(c => c.starts-with("#"))
  if first-heading == none { first-heading = items.len() }
  let n = 0
  for (i, c) in items.enumerate() {
    let next = if i + 1 < items.len() { items.at(i + 1) } else { "" }
    if c.starts-with("#") or c.starts-with(regex("^\\d+\\. ")) {
      // headings and the prayer list are not numbered
      md(c)
    } else if c.starts-with("|") {
      pipe-table(c)
    } else if c.starts-with(">") {
      quotation(c)
    } else if (c.ends-with(":") and next.starts-with(regex("^\\d+\\. "))) or c.starts-with("(") or i < first-heading {
      // the prayer's lead-in, a parenthetical that completes the paragraph before it (a table's "(collectively,
      // ...)"), and the lead-in paragraph before the first heading are not numbered
      block(width: 100%, md(c))
    } else if c.starts-with("[") {
      // bracketed editorial notes about the transcription are unnumbered and set in italics
      block(width: 100%, text(style: "italic", md(c)))
    } else if c.starts-with(regex("^[A-Z]\\. ")) {
      // lettered items of the introduction: unnumbered, indented
      block(width: 100%, pad(left: item-indent, md(c)))
    } else {
      n += 1
      block(width: 100%, md(str(n) + "\\.\u{2003}" + c))
    }
  }
}

#let nceb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  // The page number centered at the foot of every page, in a single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced); the prayer's numbers in a box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: list-indent)
  // A doubled sign stays with its number too ("§§ 151"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  caption(meta)
  body-style(body)
  signature-block(meta.signature)
}
