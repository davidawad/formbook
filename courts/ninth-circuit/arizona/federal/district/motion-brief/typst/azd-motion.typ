// Motion with memorandum for the U.S. District Court for the District of Arizona (azd).
// Rules: LRCiv 7.1(a) (first page), 7.1(b)(1) (double-spaced, 28 lines, proportional font of at least 13 point,
// numbered pages, margins); LRCiv 7.2(b) (memorandum filed with the motion), 7.2(e)(1) (a motion and its
// memorandum, 17 pages); LRCiv 12.1(c) (certification for a Rule 12(b)(6) motion: author content, see README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LRCiv 7.1(b)(1): proportional font; vendored in fonts/
#let type-size = 13pt                   // LRCiv 7.1(b)(1): a proportional font of no less than 13 point, footnotes included
#let lines-per-page = 27                // LRCiv 7.1(b)(1): no more than 28 lines per page
#let page-h = 11in                      // LRCiv 7.1(b)(1): letter size
#let top-margin = 72pt                  // line 1 sits on the top margin
#let left-margin = 1.5in                // LRCiv 7.1(b)(1): not less than 1 1/2 inches (room for the line numbers)
#let right-margin = 1in                 // LRCiv 7.1(b)(1): not less than 1/2 inch
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in                // hanging label width of numbered headings
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the right column
#let caption-inset = 10pt               // the party text stands off the column's right rule
#let caption-pad = 9.6pt                // the column's bottom rule below the last party line: the text after the caption
                                        // comes back to a third of a numbered line (see single-offset)
#let right-inset = 0.1in                // the right column's text stands this far in
#let sig-indent = 2.6in                // the signature block: a 3.4 in box at the right margin of the 6 in text
#let counsel-lines = 5                  // LRCiv 7.1(a)(2): the court title begins on or below line 6

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LRCiv 7.1(b)(1): double-spaced body; the numbered lines are this pitch
#let pitch-single = 16pt                // counsel, caption, signature, service list: single-spaced at 13 pt; two thirds of the
                                        // pitch, so every single line stands on a numbered line or a third of one off it
#let half-gap = 16pt                    // between the items of the caption's right column: a single line
// A run of single lines starts this far below a numbered line, so that every single line's baseline stands on a
// numbered line's baseline or 8 pt off it (0.8 x 24 - 0.8 x 16): never half-way, where the PDF text of the two
// engines would read a line number with another line (their glyph boxes differ in height).
#let single-offset = 6.4pt
#let right-pad = 1.6pt                  // below the caption's right column, for the same reason when it is the taller
#let signer-gap = 17.6pt                // above the certificate's signer line, after the service list: back on the grid
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the page number
#let footer-gap = 8pt                   // the page number stands this far below the last numbered line
#let pitch-footer = 15pt                // the page number's line
#let running-size = 9pt                 // the running line under the page number (pages 2 on)
#let pitch-running = 11pt               // its line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("azd-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// One numbered line (the double pitch) of unindented text.
#let grid-line(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set par(first-line-indent: 0pt)
  body
})

/// A body paragraph: double-spaced, first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Space that brings `n` single lines back onto the grid of numbered lines (at least `min` numbered lines in all):
/// counted from the lines, not measured, as the Word filter counts them.
#let grid-fill(n, min: 0, extra: single-offset) = {
  let used = extra + n * pitch-single
  let lines = calc.max(min, calc.ceil(used / pitch))
  v(lines * pitch - used, weak: false)
}

// ---------------------------------------------------------------------------
// Page furniture
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

/// The footer: the page number centered (LRCiv 7.1(b)(1): pages must be numbered), and from the second page the
/// running line (case number, short title and judge) below it, small (the exemplar carries it; no rule fixes its
/// position). On the first page an empty line of the same height keeps the footer's height.
#let footer(meta) = context {
  set par(first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: 0pt,
    align(center, text(size: type-size, ..edges(pitch-footer), counter(page).display())))
  let run = if counter(page).get().first() > 1 and "running_header" in meta { meta.running_header.join(" | ") } else { [] }
  block(width: 100%, height: pitch-running, above: 0pt, below: 0pt,
    align(center, text(size: running-size, ..edges(pitch-running), run)))
}

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-5 or more), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  // Lines 1 to 5 at least; a longer counsel block pushes the court title down, which the rule allows only
  // on or below line 6 (LRCiv 7.1(a)(2)); the block fills whole numbered lines.
  block(width: 100%, above: 0pt, below: 0pt, inset: (top: single-offset), for l in meta.counsel { line-block(inl(l)) })
  grid-fill(meta.counsel.len(), min: counsel-lines)
}

#let court-title() = {
  grid-line(align(center, strong("IN THE UNITED STATES DISTRICT COURT")))
  grid-line(align(center, strong("FOR THE DISTRICT OF ARIZONA")))
}

#let caption(meta) = block(width: 100%, above: pitch, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (top: single-offset, right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  block(width: 100%, inset: (left: right-inset, top: single-offset, bottom: right-pad), {
    // LRCiv 7.1(a)(3), right of center: (A) the number of the action, (B) a brief description of the paper,
    // (C) mention of the memorandum filed with it.
    line-block[Case No. #meta.case_number]
    line-block(above: half-gap, strong(inl(meta.brief_title)))
    line-block(above: half-gap, meta.judge)
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
}

// ---------------------------------------------------------------------------
// Headings, body, signature and certificate
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

/// Headings on the numbered lines, kept with the text after them: level 1 centered, bold, in capitals,
/// unnumbered; levels 2 to 5 numbered (I., A., 1., a.), bold (level 5 bold italic), the label hanging from an
/// indent of one tab per level below 2.
#let heading-rule(it) = {
  set text(size: type-size)
  let nums = counter(heading).at(it.location()).slice(0, it.level)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 0pt, below: 0pt,
      { set par(first-line-indent: 0pt); align(center, strong(upper(it.body))) })
  } else {
    let lab = numbering(it.numbering, ..nums)
    let ind = (it.level - 2) * heading-tab
    let b = if it.level == 5 { strong(emph(it.body)) } else { strong(it.body) }
    block(width: 100%, sticky: true, above: 0pt, below: 0pt,
      par(first-line-indent: 0pt, hanging-indent: ind + heading-tab, [#h(ind)#box(width: heading-tab, lab)#b]))
  }
}

/// The body, chunk by chunk (blank-line separated): a heading, or an unnumbered double-spaced paragraph.
#let body-blocks(body) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") { md(t) } else { body-par(md(t)) }
  }
}

/// "DATED:" on a numbered line, then the firm and the signer under "By: /s/", single-spaced in a box at the right
/// margin, filled to whole numbered lines. The block never breaks across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = sig.firm.map(inl) + (none, [By: /s/ #sig.signer]) + sig.lines.map(inl)
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    grid-line[DATED: #meta.date]
    block(width: 100%, inset: (left: sig-indent, top: single-offset), above: 0pt, below: 0pt, for l in lines { if l == none { block(height: pitch-single, above: 0pt, below: 0pt) } else { line-block(l) } })
    grid-fill(lines.len())
  })
}

#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(sticky: true, width: 100%, above: pitch, below: 0pt, grid-line(align(center, strong(c.heading))))
  body-par(inl(c.text))
  block(width: 100%, inset: (top: single-offset), above: 0pt, below: 0pt, for l in c.service { line-block(inl(l)) })
  grid-line(above: signer-gap, pad(left: sig-indent, [/s/ #c.signer]))
}

#let azd-motion(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    footer: footer(meta),
    footer-descent: footer-gap,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch)
  // A doubled sign stays with its number ("§§ 1983"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: heading-num)
  show heading: heading-rule

  cover(meta)
  if "lead_in" in meta { body-par(above: pitch, inl(meta.lead_in)) }
  body-blocks(body)

  // LRCiv 12.1(c): a Rule 12(b)(6) motion needs a certification of the conference before filing. Author content:
  // the template draws the heading and the text but does not check either.
  if "certification" in meta {
    block(sticky: true, width: 100%, above: 0pt, below: 0pt,
      grid-line(align(center, strong(meta.certification.heading))))
    body-par(inl(meta.certification.text))
  }

  signature-block(meta)
  certificate(meta)
}
