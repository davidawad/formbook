// Motion with memorandum for the U.S. Bankruptcy Court, W.D. Washington (wawb).
// Rules: LBR 9004-1 (8-1/2 x 11, embedded font 11 or 12 point, double spaced, numbered lines, judge's name
// top right, bottom notation: abbreviated title and page number left, counsel right); LBR 9013-1(c)(3)(A)
// (the notice may be combined with the motion: the caption says so and the notice is the first part of the
// text); LBR 9013-1(d)(1)(B) (judge, chapter, location, date, time and response date noted top right);
// LBR 9013-1(d)(1)(C) (length of memoranda: 12 pages, or 24 for dispositive motions, without approval).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LBR 9004-1(a): standard embedded font; vendored in fonts/
#let type-size = 12pt                   // LBR 9004-1(a): 11 or 12 point
#let footer-size = 11pt                 // LBR 9004-1(a): the bottom notation is held to the same 11 point minimum
#let lines-per-page = 27                // LBR 9004-1(b)(1): numbered paper, one number per double-spaced line
#let page-w = 8.5in                     // LBR 9004-1(a): 8-1/2 x 11 inch
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let number-width = 1in                 // the line numbers, right-aligned in the first inch of the page
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations are indented on both sides, still double spaced
#let list-indent = 0.5in                // a list item's bullet half an inch in ...
#let list-box = 0.4in                   // ... the text hanging 0.9 in from the margin
#let notation-width = 3.6in             // the top-right notation (LBR 9013-1(d)(1)(B))
#let caption-left = 3.0in               // width of the party column of the caption
#let caption-gutter = 0.25in            // the ")" column
#let caption-pad-bottom = 12pt          // the party column's rule stands off its text by half a numbered line
#let case-pad = 0.1in                   // the case number and title stand off the ")" column
#let footer-right = 2.7in               // the bottom notation: counsel's column at the right ...
#let footer-gutter = 0.2in
#let footer-gap = 4pt                   // ... below the last numbered line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit
// (docx/wawb-motion-brief.lua and docx/reference.xml set the same twips).
#let pitch = 24pt                       // LBR 9004-1(a): double spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // notation and caption: two single lines to a numbered line
#let pitch-footer = 12pt                // the bottom notation's lines
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the bottom notation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *aka*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single lines start this far below a numbered line's top, so that every other one sits on a numbered line's
/// baseline and the others halfway between two (the baseline of a line box is at 0.8 of its pitch).
#let single-offset = 0.8 * (pitch - pitch-single)

/// The space that brings a block of height `h` (from a numbered line's top) back onto the numbered lines. The docx
/// engine computes the same from the same counts of single lines: a block's height is counted from its items, not
/// measured, so a wrapped item leaves the lines that follow it half a numbered line lower in both engines.
#let regrid(h) = {
  let r = calc.rem(calc.round(h / 1pt * 20), calc.round(pitch / 1pt * 20))
  if r == 0 { 0pt } else { pitch - r / 20 * 1pt }
}

/// One line (a paragraph of its own) with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, body)

/// Single-spaced lines, one paragraph each; an empty item is a blank line (the next line sits a line lower).
/// `above`: a space of its own above the first line (padding, which typst keeps at the top of a grid cell, as Word
/// keeps a paragraph's space before at the top of a table cell).
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
  for t in items {
    if t == "" { gap += pitch-single } else {
      line-block(pad(top: gap, inl(t)))
      gap = 0pt
    }
  }
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Plain text outside the flow (the page background and foreground do not see the document's show rules).
#let furniture(size, pitch, body) = {
  set text(font: font-family, size: size, hyphenate: false, kerning: false, ligatures: false, overhang: false,
    ..edges(pitch))
  set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, linebreaks: "simple", justify: false)
  body
}

/// Numbers 1 to 27 down the left margin, one per numbered line, level with its text (LBR 9004-1(b)(1)).
#let line-numbers() = furniture(type-size, pitch, {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-width, height: pitch, align(right, str(i))))
  }
})

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Bottom notation (LBR 9004-1(b)(3)): on the left, the abbreviated title and the page number; on the
/// right, the name, address and telephone of the firm preparing the paper.
#let footer-block(title, firm-lines) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-gap,
  furniture(footer-size, pitch-footer, block(width: text-width, grid(
    columns: (text-width - footer-gutter - footer-right, footer-gutter, footer-right),
    [#upper(title) - #context counter(page).display()],
    [],
    align(right, for l in firm-lines { block(above: 0pt, below: 0pt, l) }),
  ))),
)

// ---------------------------------------------------------------------------
// First page: notation (top right), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// LBR 9013-1(d)(1)(B): the name of the judge, the chapter, and the location, date and time of the hearing,
/// and the response date, in the top right-hand corner of the first page. LBR 9004-1(b)(2): the judge's name
/// is on the front page's right side.
#let notation-rows(meta) = {
  let h = meta.hearing
  (
    meta.at("judge", default: none),
    meta.at("chapter", default: none),
    "Hearing location: " + h.location,
    "Hearing date: " + h.date,
    "Hearing time: " + h.time,
    "Response date: " + h.response_date,
  ).filter(x => x != none)
}

#let notation(meta) = block(width: 100%, above: 0pt, below: 0pt, breakable: false,
  align(right, block(width: notation-width, align(right, line-stack(notation-rows(meta), above: single-offset)))))

#let court-lines(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF WASHINGTON")
  if "division" in meta { lines.push(upper(meta.division)) }
  lines
}

/// The caption: the debtor's case in the left column ("In re:", one entry per line of the debtor names, the
/// designation) closed by a rule, a column of ")" beside it with one ")" per entry (the convention in both filed
/// exemplars), and the case number and the title of the paper at the right. Each entry is one line: the sample
/// breaks the debtor names into entries, so the ")" column and the names stay on the same lines.
#let caption-rows(meta) = meta.debtor.names + (meta.debtor.designation,)

#let caption(meta, above) = {
  let rows = caption-rows(meta)
  block(width: 100%, above: above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
    grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: caption-pad-bottom), line-stack(rows, above: single-offset)),
    line-stack(rows.map(i => ")"), above: single-offset),
    pad(left: case-pad, bottom: caption-pad-bottom, {
      line-stack((meta.case_number,), above: single-offset)
      strong(line-stack((meta.brief_title,), above: pitch-single))
    }),
  ))
}

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  notation(meta)
  for (k, l) in court-lines(meta).enumerate() {
    let above = if k == 0 { pitch + regrid(single-offset + notation-rows(meta).len() * pitch-single) } else { 0pt }
    line-block(above: above, align(center, text(weight: "bold", l)))
  }
  caption(meta, pitch)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body blocks: each blank-line-separated chunk of markdown is one paragraph (first-line indent), one
/// block quotation (indented both sides), a list or a heading. Paragraphs are not numbered: the motion practice
/// of LBR 9013-1 does not number them. `first-above`: the space above the first block (a numbered line below the
/// caption, back on the numbered lines), dropped at the top of a page.
#let blocks(body, first-above) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (k, c) in chunks.enumerate() {
    let t = c.trim()
    let md = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let plain = not (t.starts-with("#") or t.starts-with(">") or t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")))
    if k == 0 and not plain { v(first-above) }
    let above = if k == 0 and plain { first-above } else { 0pt }
    if t.starts-with("#") {
      md
    } else if t.starts-with(">") {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: quote-indent, right: quote-indent, md))
    } else if not plain {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent, md))
    } else {
      // The signature block (its chunk starts "Dated:") is kept whole on one page.
      block(width: 100%, above: above, below: 0pt, breakable: not t.starts-with("Dated:"), [#h(para-indent)#md])
    }
  }
}

#let wawb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.footer_counsel),
  )
  // No punctuation hanging into the margin (Word hangs none): a right-aligned line ends at the margin.
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false, overhang: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number; a list item's bullet in a box of list-box, the text hanging.
  show: xengine.with(pitch: pitch, list-indent: list-box)
  // A doubled sign stays whole and with its number ("§§ 502"): typst would break between the signs. A no-break
  // space, as the docx filter writes (a box would set the signs apart in the PDF text of an italic line).
  show regex("[§¶]{2,} \\S"): it => it.text.replace(" ", "\u{a0}")
  // A block quotation is its text; blocks() indents it.
  show quote.where(block: true): it => it.body

  // Headings: level 1 is a centered bold caps section (RELIEF REQUESTED, MEMORANDUM OF LAW); level 2 a bold
  // left-aligned subsection; level 3 an italic left-aligned sub-subsection. On the numbered lines, no space of
  // their own, kept with what follows.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if it.level == 2 { text(weight: "bold", it.body) }
    else { text(weight: "regular", emph(it.body)) }
  })

  cover(meta)

  blocks(body, pitch + regrid(single-offset + (caption-rows(meta).len() + 1) * pitch-single))
}
