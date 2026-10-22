// Motion with memorandum of points and authorities, United States Bankruptcy Court, District of Arizona (arb).
// Rules: FRBP 9013(a), (b) (a request for an order is made by written motion, which states its grounds
// with particularity and the relief requested); LRBP 9013-1(a) (a motion includes a memorandum setting out
// the supporting authorities), (b) (15 pages, exclusive of attachments, unless the court orders otherwise);
// LRBP 1005-1(a) (court title); LRBP 9004-1 (a) first-page filer block, (c) dual caption where there is an
// adversary proceeding, (e) hearing if known, (g) form of papers, (h) length. See ../README.md.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-title = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA")  // LRBP 1005-1(a)
#let font-family = ("Times New Roman", "Liberation Serif")        // proportional, standard; vendored in fonts/ (LRBP 9004-1(g))
#let type-size = 13pt                   // LRBP 9004-1(g): "a proportional font size no smaller than 13 point"
#let footnote-size = 12pt               // LRBP 9004-1(g): footnotes may be 12 point (the tables too, as filed)
#let footer-size = 11pt                 // the footer: page number, the paper's title and the case number
#let lines-per-page = 27                // LRBP 9004-1(g): no more than 28 lines per page
#let page-limit = 15                    // LRBP 9013-1(b): 15 pages, exclusive of attachments (see README.md)
#let page-h = 11in                      // LRBP 9004-1(g): paper 8 1/2 by 11 inches
#let top-margin = 72pt                  // numbered line 1 sits on the top margin
#let left-margin = 1.5in                // LRBP 9004-1(g): left margin at least 1 1/2 inches
#let right-margin = 1in                 // LRBP 9004-1(g): right margin at least 1/2 inch
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let list-box = 0.5in                   // a list item's bullet or number in a half-inch box at the margin
#let quote-indent = 0.5in               // block quotations: half an inch in on both sides
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the right column
#let caption-inset = 10pt               // the party text stands off the column's right rule
#let right-inset = 0.1in                // the right column's text stands this far in
#let sig-left = 2.6in                   // the signature block: "Dated" left, the signer in a column right of it
#let sig-gutter = 0.2in
#let filer-lines = 7                    // the court title starts on line 8 (convention; LRBP 9004-1(a) only fixes line 1)
#let cell-x = 4pt                       // table cells: padding left and right

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LRBP 9004-1(g): double spacing; the numbered lines are this pitch. Footnotes
                                        // and quotations too: on the numbered lines, as the rest of the text
#let pitch-single = 16pt                // filer block, caption, signature, table rows: single lines, two thirds of the pitch
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let footer-gap = 6pt                   // the footer stands this far below the last numbered line
#let pitch-footer = 13pt                // the footer's lines
#let footer-line-gap = 4pt              // between the page number and the title line
#let note-clearance = 12pt              // from the text to the footnote rule
// A run of single lines starts this far below a numbered line, so that every single line's baseline stands on a
// numbered line's baseline or 8 pt off it (0.8 x 24 - 0.8 x 16): never half-way, where the PDF text of the two
// engines would read a line number with another line (their glyph boxes differ in height).
#let single-offset = 6.4pt
#let caption-pad = 9.6pt                // below the caption row: back to a multiple of the single pitch
// Table cells: the same offset above the text and 9.6 pt below it, so a row is a whole number of single lines and
// its text lines stand on the numbered lines or 8 pt off them. Word adds the 0.5 pt of each horizontal rule to the
// rows (typst draws them over the cells): its cells keep 0.5 pt less above the text, and the line below its table
// 0.5 pt less (the rule above the first row).
#let cell-top = single-offset
#let cell-bottom = 9.6pt
#let rule = 0.5pt
#let table-gap = 16pt                  // above a table (a single line); below it a whole numbered line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("arb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (a paragraph of its own); `none` is an empty line.
#let line-block(body) = block(width: 100%, above: 0pt, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == none { box(height: pitch-single) } else if type(body) == str { inl(body) } else { body }
})

/// A run of single lines, `single-offset` below where it starts.
#let line-run(items, inset: (:)) = block(width: 100%, above: 0pt, below: 0pt,
  inset: (top: single-offset) + inset, for i in items { line-block(i) })

/// One numbered line (the double pitch) of unindented text.
#let grid-line(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set par(first-line-indent: 0pt)
  body
})

/// A body paragraph: double-spaced, first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Page furniture: pleading paper (LRBP 9004-1(g))
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, each in a line box of the pitch.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: 8.5in - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer in the bottom margin: the page number, then the paper's title left and the case number (or the adversary
/// number, when there is one) right.
#let footer-block(meta) = {
  set text(size: footer-size, ..edges(pitch-footer))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display("1")))
  block(width: 100%, above: footer-line-gap, below: 0pt, grid(
    columns: (1fr, auto),
    upper(need(meta, "footer_title")),
    if "adversary_number" in meta [ADV. NO. #meta.adversary_number] else [CASE NO. #need(meta, "debtor").case_number],
  ))
}

// ---------------------------------------------------------------------------
// First page: filer block (line 1), court title, caption (LRBP 9004-1(a), (c), (e))
// ---------------------------------------------------------------------------

/// Filer block from line 1: counsel, firm, address, email, State Bar number, telephone and the party
/// represented (LRBP 9004-1(a)). Occupies at least `filer-lines` numbered lines (counted from its lines, as the
/// Word filter counts them).
#let filer-block(meta) = {
  let items = need(meta, "filer")
  line-run(items)
  let used = single-offset + items.len() * pitch-single
  v(calc.max(filer-lines, calc.ceil(used / pitch)) * pitch - used, weak: false)
}

#let court-title-block() = for l in court-title { grid-line(align(center, strong(l))) }

/// The rows of the hearing, when one is known (LRBP 9004-1(e)).
#let hearing-rows(meta) = if "hearing" in meta and meta.hearing != none {
  let hr = meta.hearing
  (none, "Hearing date: " + hr.at("date", default: ""), "Time: " + hr.at("time", default: ""),
    "Place: " + hr.at("place", default: ""))
} else { () }

/// Caption (LRBP 9004-1(a), (b), (e)). The debtor's caption is always given. When the motion is filed in an
/// adversary proceeding, the second caption names the adversary parties and the adversary number (9004-1(c)).
/// The right column carries the chapter and case number, the title, the relief sought and the hearing.
#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let left-cell(rows) = block(width: 100%, inset: (right: caption-inset, bottom: caption-pad), line-run(rows))
  let right-cell(rows) = block(width: 100%, inset: (left: right-inset, bottom: caption-pad), line-run(rows))
  let title-rows = (strong(upper(inl(need(meta, "title")))), none, inl(need(meta, "relief"))) + hearing-rows(meta)

  let debtor-rows = ("In re:", none) + debtor.names + (none, emph("Debtor."))
  let case-rows = ("Chapter " + str(debtor.chapter), none, "Case No. " + debtor.case_number)
  let cells = if "adversary_number" in meta {
    // Row 1 holds the debtor; row 2 holds the adversary parties and the title.
    let party-rows = ()
    for (k, p) in need(meta, "parties").enumerate() {
      if k > 0 { party-rows += (none, "v.", none) }
      party-rows += p.names
      party-rows += (none, emph(p.designation))
    }
    (left-cell(debtor-rows), right-cell(case-rows), left-cell(party-rows),
      right-cell(("Adv. No. " + meta.adversary_number, none) + title-rows))
  } else {
    // A contested matter in the main case: one caption, the title on the right.
    (left-cell(debtor-rows), right-cell(case-rows + (none,) + title-rows))
  }
  block(width: 100%, above: pitch, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    // the party column ruled right and below over the whole row, as a Word table cell is
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) },
    ..cells,
  ))
}

#let cover(meta) = {
  filer-block(meta)
  court-title-block()
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

/// "Dated" left and the signer's block right of it, single-spaced.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-run(([Dated: #need(meta, "date")],)),
    line-run(("Respectfully submitted,", none, "/s/ " + sig.signer) + sig.lines),
  )
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists, quotations, tables. Unlike the complaint, paragraphs are not numbered.
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

/// Headings on the numbered lines, kept with the text after them: level 1 centered, bold, in capitals; the others
/// bold, their label hung in a half-inch box one tab in per level below 2.
#let heading-rule(it) = {
  set text(size: type-size)
  let nums = counter(heading).at(it.location()).slice(0, it.level)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 0pt, below: 0pt,
      { set par(first-line-indent: 0pt); align(center, strong(upper(it.body))) })
  } else {
    let lab = numbering(it.numbering, ..nums)
    let ind = (it.level - 2) * heading-tab
    block(width: 100%, sticky: true, above: 0pt, below: 0pt,
      par(first-line-indent: 0pt, hanging-indent: ind + heading-tab, [#h(ind)#box(width: heading-tab, lab)#strong(it.body)]))
  }
}

/// Footnote definitions are `[^key]: text` chunks; they are removed from the body and returned by key.
#let split-footnotes(body) = {
  let defs = (:)
  let kept = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1).trim()) } else { kept.push(c) }
  }
  (kept, defs)
}

/// Inline markdown with footnotes: each `[^key]` marker becomes a typst footnote whose text is the definition.
/// Typst numbers footnotes in order of appearance, as Word does.
#let with-notes(t, defs) = {
  let pos = 0
  let out = []
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    assert(k in defs, message: "arb-motion-brief: footnote [^" + k + "] has no definition in the sample")
    out += inl(t.slice(pos, m.start))
    out += footnote(inl(defs.at(k)))
    pos = m.end
    // a space after the mark stays (each piece is rendered on its own, which trims it)
    if t.slice(pos).starts-with(regex("\\s")) { out += [ ] }
  }
  out + inl(t.slice(pos))
}

/// A markdown table (`| a | b |` rows, a `|---|` separator after the header row) as equal columns of single lines
/// at the footnote size, thin rules.
#let data-table(t, defs) = {
  let rows = t.split(regex("\\r?\\n")).map(l => l.trim()).filter(l => l != "")
  let cells(l) = l.trim("|").split("|").map(c => c.trim())
  rows = rows.filter(l => l.match(regex("^\\|?[\\s:|-]+\\|?$")) == none)
  let n = cells(rows.first()).len()
  let cell(c) = {
    set text(size: footnote-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    with-notes(c, defs)
  }
  // A row never splits; the header row repeats on every page the table runs over (Word's table header).
  show table.cell: set table.cell(breakable: false)
  block(width: 100%, above: table-gap, below: pitch, table(
    columns: (1fr,) * n,
    inset: (left: cell-x, right: cell-x, top: cell-top, bottom: cell-bottom),
    stroke: rule,
    table.header(..cells(rows.first()).map(cell)),
    ..rows.slice(1).map(l => cells(l).map(cell)).flatten(),
  ))
}

/// Body chunks as set text: headings, tables, lists, quotations and paragraphs. The last chunk is kept with
/// `tail` (the signature block), so a signature never stands alone on a page.
#let body-chunks(body, tail) = {
  let (chunks, defs) = split-footnotes(body)
  chunks = chunks.filter(c => c.trim() != "")
  for (idx, c) in chunks.enumerate() {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("|") {
      data-table(t, defs)
    } else if t.starts-with(">") {
      // A block quotation: half an inch in on both sides, on the numbered lines.
      block(width: 100%, above: 0pt, below: 0pt, pad(x: quote-indent, {
        set par(first-line-indent: 0pt)
        with-notes(t.split(regex("\\r?\\n")).map(l => l.trim(">", at: start).trim()).join(" "), defs)
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      body-par(with-notes(t, defs))
    }
    if idx == chunks.len() - 1 { block(breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
  if chunks.len() == 0 { tail }
}

#let arb-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("filer", "debtor", "title", "relief", "footer_title", "date", "signature") {
    let _ = need(meta, k)
  }
  if "adversary_number" in meta {
    let _ = need(meta, "parties")
  }

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    footer: footer-block(meta),
    footer-descent: footer-gap,
  )
  set document(title: upper(need(meta, "title")) + ", Case No. " + need(meta, "debtor").case_number, author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: list-box)
  // A doubled sign stays with its number ("§§ 547"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Heading numbers come from the level (I., A., 1., a.) under level 2; level 1 is a centred section.
  set heading(numbering: heading-num)
  show heading: heading-rule

  // Footnotes: 12 point (LRBP 9004-1(g)), on the numbered lines, under a 30 % rule; the mark and a space before
  // the text (Word's footnote).
  set footnote.entry(gap: 0pt, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)

  body-chunks(body, signature-block(meta))

  // LRBP 9013-1(b) and 9004-1(h): 15 pages, exclusive of attachments, unless the court orders otherwise.
  context {
    let n = counter(page).final().first()
    assert(n <= page-limit, message: "arb-motion-brief: " + str(n) + " pages; LRBP 9013-1(b) allows " + str(page-limit) + " (exclusive of attachments) unless the court orders otherwise")
  }
}
