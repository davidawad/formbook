// Motion with notice and memorandum of points and authorities, United States Bankruptcy Court, Central District of
// California (cacb). Rules: LBR 9013-1(c)(2) (notice of motion: relief, hearing date/time/place, the 14-day response
// advisement), (c)(3)(A)-(C) (written statement of reasons with a memorandum, declarations, exhibits), (c)(4) (objection to
// the bankruptcy court's authority to enter a final order), (d)(2) (21 days' notice), (f) (responses, 14 days before the
// hearing), (g) (replies, 7 days before the hearing); LBR 9004-1 and The Central Guide Supplement to LBR 9004-1 (Aug.
// 2022): the same page, typeface, spacing, numbered-margin and caption rules as the adversary complaint (Central Guide
// 9004-1(b)-(c)); a motion is listed among the documents that need numbered margins (9004-1(b)(2)(B)(i)).
// See ../README.md for the rule text, the open choices and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Central Guide 9004-1(b)(2)(C): Times New Roman is a listed typeface; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt                   // Central Guide 9004-1(b)(2)(C): not smaller than 12 point (the floor)
#let lines-per-page = 27                // Central Guide 9004-1(b)(2)(B)(i): not more than 28 numbered lines per page; 27 keeps the last line above the 1 in bottom margin the checks hold the text to
#let page-w = 8.5in                     // Central Guide 9004-1(b)(2)(A): 8 1/2 by 11 inch pages
#let page-h = 11in
#let top-margin = 72pt                  // Central Guide 9004-1(b)(2)(C): line 1 at least 1 inch below the top edge
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-indent = 0.5in                // list items: the label half an inch in, the text a box after it
#let heading-step = 0.5in               // headings A., 1., a. stand 0.5, 1 and 1.5 in from the margin
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the caption's columns, and the signature block's
#let caption-inset = 10pt               // the party text stands off the column's rule
#let right-inset = 0.1in                // the right column's text stands this far in
#let cell-inset = 4pt                   // a table cell's text stands this far in from the cell's sides
#let counsel-lines = 7                  // Central Guide 9004-1(c)(1)(B): lines 1-7 are left for counsel and the clerk; the court title starts on line 8
#let sig-left = 2.6in                   // the signature block's date column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // Central Guide 9004-1(b)(2)(F): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // counsel, caption, signature: single-spaced, two lines to a numbered line
#let half-gap = 12pt                    // a blank single line in the caption and the signature block
#let to-grid = pitch - 2.4pt            // the space above a block of single lines after a numbered line: every second single line
                                        // then stands on a numbered line's baseline (0.8 x 24 pt; a single line's is 0.8 x 12 pt)
#let counsel-drop = 9.6pt              // the counsel lines start 9.6 pt down, so the first stands on line 1's baseline (0.8 x 24 pt) and every
                                        // second one on a numbered line's
#let grid-pad = 14.4pt                  // the space below such a block: it ends on the grid again (21.6 + 12 n + 14.4 pt)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: the page number and footer line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// A metadata value as a list (a YAML list or one string).
#let as-list(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A numbered line of its own (a heading line), kept with what follows.
#let heading-block(body) = block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, ending half an inch left of the text, on the
/// baselines of the double-spaced text.
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
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Page number at the bottom of every page (Central Guide 9004-1(b)(2)(G)), then the paper's title and the case
/// number on the footer line: single lines, 6 pt below the last numbered line.
#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: type-size, ..edges(pitch-single))
    line-block(align(center, context counter(page).display("1")))
    line-block(above: 4pt, grid(columns: (1fr, auto), upper(inl(title)), [CASE NO. #case-number]))
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title and hearing
// ---------------------------------------------------------------------------

/// The counsel block: single lines from line 1, filling at least lines 1-7 (Central Guide 9004-1(c)(1)(B)-(C)); more
/// counsel lines push the court title down by whole numbered lines, half a line kept below the last.
#let counsel-block(meta) = {
  let lines = as-list(meta.counsel)
  let rows = calc.max(counsel-lines, calc.ceil((lines.len() + 1) / 2))
  block(width: 100%, height: rows * pitch, above: 0pt, below: 0pt, inset: (top: counsel-drop),
    for l in lines { line-block(inl(l)) })
}

#let court-title(meta) = {
  for l in ("UNITED STATES BANKRUPTCY COURT", "CENTRAL DISTRICT OF CALIFORNIA", upper(meta.division)) {
    block(width: 100%, above: 0pt, below: 0pt, align(center, strong(l)))
  }
}

/// The caption for a motion in the bankruptcy case (Central Guide 9004-1(c)(1)(I), the sample caption of a
/// motion): debtor on the left; case number, chapter, title and hearing on the right. The hearing lines
/// come from the sample (date, time, place, courthouse address), as the Central Guide requires on page 1.
/// Both columns end `grid-pad` below their last line (the party column's rule there), so the text after the
/// caption stands on the numbered lines.
#let caption(meta) = block(width: 100%, above: to-grid, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: grid-pad), {
    line-block[In re:]
    for n in as-list(meta.caption.debtor.names) { line-block(inl(n)) }
    line-block(inl(meta.caption.debtor.designation))
  }),
  block(width: 100%, inset: (left: right-inset, bottom: grid-pad), {
    line-block[Case No. #meta.bankruptcy_case]
    line-block[Chapter #meta.chapter]
    line-block(above: half-gap, strong(inl(meta.brief_title)))
    if "legend" in meta and meta.legend != none { line-block(above: half-gap, strong(upper(meta.legend))) }
    for (j, l) in as-list(meta.hearing).enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
  if "lead_in" in meta {
    block(width: 100%, above: pitch, below: 0pt, par(first-line-indent: 0pt, inl(meta.lead_in)))
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block, where the sample marks one: the date at left; the firm and the signer at right, single
/// lines; it ends on the numbered lines again (`grid-pad`) and never splits across pages.
#let signature-block(meta) = block(breakable: false, width: 100%, above: to-grid, below: 0pt, inset: (bottom: grid-pad), grid(
  columns: (sig-left, 1fr),
  column-gutter: caption-gutter,
  line-block[Dated: #meta.date],
  {
    for l in as-list(meta.signature.firm) { line-block(inl(l)) }
    line-block(above: half-gap)[By: /s/ #meta.signature.signer]
    line-block(upper(meta.signature.signer))
    for l in as-list(meta.signature.lines) { line-block(inl(l)) }
  },
))

/// A markdown table (`| a | b |` rows, a `|---|` separator after the first row) as equal unruled columns, as in the
/// filed forms, its text in numbered lines; a row never splits across a page.
#let data-table(t) = {
  let rows = t.split(regex("\\r?\\n")).map(l => l.trim()).filter(l => l != "")
  rows = rows.filter(l => l.match(regex("^\\|?[\\s:|-]+\\|?$")) == none)
  let cells(l) = l.trim("|").split("|").map(c => c.trim())
  let n = cells(rows.first()).len()
  set table.cell(breakable: false)
  block(width: 100%, above: 0pt, below: 0pt, table(
    columns: (1fr,) * n,
    inset: (x: cell-inset, y: 0pt),
    stroke: none,
    ..rows.map(l => cells(l).map(c => par(first-line-indent: 0pt, inl(c)))).flatten(),
  ))
}

/// A heading of the sample: level 1 a centered section (NOTICE OF MOTION, MEMORANDUM OF POINTS AND AUTHORITIES, ...)
/// that restarts the numbering; levels 2-5 numbered I., A., 1., a. from the level, counted here (not typed by the
/// author). Level 2 as filed: a blank line, the numeral, then the title on the next line, centered.
#let heading-of(level, title, count) = {
  if level == 1 {
    heading-block(align(center, strong(upper(inl(title)))))
  } else if level == 2 {
    block(sticky: true, width: 100%, above: pitch, below: 0pt, align(center, strong(numbering("I.", count))))
    heading-block(align(center, strong(upper(inl(title)))))
  } else if level == 3 {
    heading-block(pad(left: heading-step, strong[#numbering("A.", count) #inl(title)]))
  } else if level == 4 {
    heading-block(pad(left: 2 * heading-step, strong[#numbering("1.", count) #inl(title)]))
  } else {
    heading-block(pad(left: 3 * heading-step, emph[#numbering("a.", count) #inl(title)]))
  }
}

/// The body: headings numbered from their level, paragraphs indented and double-spaced, lists, tables, quotations.
/// Each blank-line-separated chunk of markdown is one paragraph (or heading, list, table, quotation). Markers from
/// the sample: `<!-- signature -->` places the signature block where the filing has one; `<!-- pagebreak -->` starts
/// the next block on a new page. A paragraph (or table) before a signature block goes with it, and the last three
/// before a page break or the end stay together (a declaration's closing and the declarant's name, a proof's signature line), so neither ever
/// stands on a page alone.
#let body-chunks(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let kind(t) = if t == "<!-- signature -->" { "signature" } else if t == "<!-- pagebreak -->" { "break" } else if (
    t.starts-with("#")) { "heading" } else if t.starts-with("|") { "table" } else if t.starts-with(">") {
    "quote" } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) { "list" } else { "para" }
  let kinds = chunks.map(kind)
  let at(i) = if i < kinds.len() { kinds.at(i) } else { "end" }
  let counts = (0, 0, 0, 0)
  let held = ()
  for (i, t) in chunks.enumerate() {
    let k = kinds.at(i)
    let piece = if k == "signature" {
      signature-block(meta)
    } else if k == "break" {
      pagebreak(weak: true)
    } else if k == "heading" {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      let level = m.captures.at(0).len()
      if level == 1 { counts = (0, 0, 0, 0) } else {
        counts.at(level - 2) += 1
        for j in range(level - 1, 4) { counts.at(j) = 0 }
      }
      heading-of(level, m.captures.at(1), if level > 1 { counts.at(level - 2) } else { 0 })
    } else if k == "table" {
      // Word cannot start a page with a table: the docx puts a 1 pt line before it, and so does this.
      if at(i - 1) == "break" { block(width: 100%, height: 1pt, above: 0pt, below: 0pt) }
      data-table(t)
    } else if k == "quote" {
      block(width: 100%, above: 0pt, below: 0pt, inset: (left: para-indent, right: para-indent),
        par(first-line-indent: 0pt, md(t.split(regex("\\r?\\n")).map(l => l.trim(">", at: start).trim()).join("\n"))))
    } else if k == "list" {
      pad(left: item-indent, md(t))
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(t)))
    }
    let text-like(j) = at(j) in ("para", "table")
    let keep = text-like(i) and (at(i + 1) == "signature"
      or (text-like(i + 1) and (at(i + 2) in ("break", "end") or (text-like(i + 2) and at(i + 3) in ("break", "end")))))
    if keep {
      held.push(piece)
    } else if held.len() > 0 {
      block(breakable: false, width: 100%, above: 0pt, below: 0pt, { held.join(); piece })
      held = ()
    } else {
      piece
    }
  }
}

#let cacb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.bankruptcy_case),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch; list items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: item-indent)
  // A doubled sign stays with its number ("§§ 363"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  body-chunks(meta, body)
}
