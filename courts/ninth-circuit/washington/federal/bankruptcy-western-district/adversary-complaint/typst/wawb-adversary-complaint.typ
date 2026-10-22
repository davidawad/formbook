// Adversary complaint for the U.S. Bankruptcy Court, W.D. Washington (wawb).
// Rules: Fed. R. Bankr. P. 7001 (what is an adversary proceeding), 7010 (Civil Rule 10 applies, but the
// caption must substantially conform to the appropriate Form 416), 9004(a) (caption: court, title, number,
// designation); LBR 9004-1 (8-1/2 x 11, embedded font 11 or 12 point, double spaced, numbered lines,
// judge's name top right, bottom notation: abbreviated title and page number left, attorney name,
// address and telephone right); Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LBR 9004-1(a): standard embedded font; vendored in fonts/
#let type-size = 12pt                   // LBR 9004-1(a): 11 or 12 point
#let footer-size = 11pt                 // LBR 9004-1(a): the bottom notation is printed in the same 11 point minimum
#let lines-per-page = 27                // LBR 9004-1(b)(1): numbered paper, one number per double-spaced line
#let page-w = 8.5in                     // LBR 9004-1(a): 8-1/2 x 11 inch
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let number-width = 1in                 // the line numbers, right-aligned in the first inch of the page
#let para-indent = 0.5in                // a paragraph number starts half an inch in ...
#let number-box = 0.5in                 // ... in a box of its own, so the text starts 1 in from the margin
#let list-indent = 0.5in                // a prayer item's letter half an inch in ...
#let list-box = 0.4in                   // ... the text hanging 0.9 in from the margin
#let counsel-width = 3.4in              // counsel block at the top left; the judge line sits at the right (2.6 in)
#let counsel-lines = 7                  // at least 7 numbered lines are reserved for counsel
#let caption-left = 3.0in               // width of the party column of the caption
#let caption-gutter = 0.2in
#let caption-pad = 10pt                 // the party column's rules stand off its text by this much on the right ...
#let caption-pad-bottom = 12pt          // ... and below (half a numbered line, so the caption keeps the grid)
#let case-pad = 0.1in                   // the adversary number and title stand off the gutter
#let sig-left = 2.6in                   // the date column of the signature block
#let sig-gutter = 0.2in
#let footer-right = 2.7in               // the bottom notation: counsel's column at the right ...
#let footer-gutter = 0.2in
#let footer-gap = 4pt                   // ... below the last numbered line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit
// (docx/wawb-adversary-complaint.lua and docx/reference.xml set the same twips).
#let pitch = 24pt                       // LBR 9004-1(a): double spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // counsel, caption and signature: two single lines to a numbered line
#let pitch-footer = 12pt                // the bottom notation's lines
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the bottom notation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
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
// Cover: counsel (top left), judge (top right), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel at the top left (LBR 9004-1(b)(3) and FRCP 10: the preparer is identified); the judge's
/// name and chapter at the top right (LBR 9004-1(b)(2)). Lines 1 to 7 at least; more counsel lines
/// push the court title down.
#let judge-rows(meta) = (meta.at("judge", default: none), meta.at("chapter", default: none)).filter(x => x != none)

#let top-block(meta) = block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
  columns: (counsel-width, text-width - counsel-width, 0pt),
  line-stack(meta.counsel, above: single-offset),
  align(right, line-stack(judge-rows(meta), above: single-offset)),
  block(height: single-offset + 2 * counsel-lines * pitch-single),
))

#let court-lines(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF WASHINGTON")
  if "division" in meta { lines.push(upper(meta.division)) }
  lines
}

/// The caption (Form 416, substantially: the appropriate version named in Rule 7010): the debtor's case in the
/// left column with the parties beneath it, closed by a rule; the adversary number and the title of the paper at
/// the right.
#let caption-rows(meta) = {
  let rows = ()
  if "debtor" in meta and meta.debtor != none {
    rows += meta.debtor.names
    rows += (meta.debtor.at("case_number", default: none), meta.debtor.at("note", default: none))
      .filter(x => x != none)
    rows.push("")
  }
  // Each party: its names, then its designation; "v." between the parties.
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  rows
}

#let caption(meta, above) = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
  columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
  grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-pad-bottom),
    line-stack(caption-rows(meta), above: single-offset)),
  [],
  pad(left: case-pad, bottom: caption-pad-bottom, {
    line-stack(("Adversary No. " + meta.adversary_number,), above: single-offset)
    strong(line-stack((meta.brief_title,), above: pitch-single))
  }),
))

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  top-block(meta)
  let rows = calc.max(2 * counsel-lines, meta.counsel.len(), judge-rows(meta).len())
  for (k, l) in court-lines(meta).enumerate() {
    line-block(above: if k == 0 { pitch + regrid(single-offset + rows * pitch-single) } else { 0pt }, align(center, text(weight: "bold", l)))
  }
  caption(meta, pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The date, then one signature per firm (LBR and Civil Rule 11: a signature for each attorney), after a
/// numbered line of its own. Kept in one block so the block never breaks across a page; the space above it is
/// spacing of its own (docx: an empty paragraph of that height), so it stays behind when the block moves on.
#let signature-block(meta) = {
  v(pitch)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (sig-left, sig-gutter, text-width - sig-left - sig-gutter),
    line-stack(("Dated: " + meta.date,), above: single-offset),
    [],
    for (k, s) in meta.signature.enumerate() {
      line-stack((s.firm,), above: if k == 0 { single-offset } else { pitch })
      line-stack(("/s/ " + s.signer,) + s.lines, above: pitch-single)
    },
  ))
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), made applicable by Rule 7010). Each blank-line-separated
/// chunk of markdown that is neither a heading nor a list is one numbered paragraph. Headings are
/// rendered unnumbered; a list is lettered A., B., C. (the exemplar's prayer convention).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, above: 0pt, below: 0pt,
        pad(left: list-indent, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)))
    } else {
      para-counter.step()
      block(width: 100%, above: 0pt, below: 0pt, context [#h(para-indent)#box(width: number-box)[#para-counter.display().]#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)])
    }
  }
}

#let wawb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

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
  // body pitch, a section sign kept with its number; a prayer item's letter in a box of list-box, the text hanging.
  show: xengine.with(pitch: pitch, list-indent: list-box)
  // A doubled sign stays whole and with its number ("§§ 502"): typst would break between the signs. A no-break
  // space, as the docx filter writes (a box would set the signs apart in the PDF text of an italic heading).
  show regex("[§¶]{2,} \\S"): it => it.text.replace(" ", "\u{a0}")
  set enum(numbering: "A.")

  // Headings: level 1 is a centered section; level 2 a centered bold heading (count titles); level 3 a bold italic
  // line under it (the statutory basis). On the numbered lines, no space of their own, kept with what follows.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if it.level == 2 { align(center, text(weight: "bold", it.body)) }
    else { align(center, text(weight: "bold", emph(it.body))) }
  })

  cover(meta)

  // A numbered line below the caption (and back on the numbered lines after it: the caption's rows and its bottom
  // padding of one single line), then the lead-in.
  // (space above the lead-in, dropped at the top of a page)
  let below = pitch + regrid(single-offset + (caption-rows(meta).len() + 1) * pitch-single)
  if "lead_in" in meta {
    block(width: 100%, above: below, below: 0pt, [#h(para-indent)#inl(meta.lead_in)])
  } else { v(below) }

  allegations(body, para-counter)

  signature-block(meta)
}
