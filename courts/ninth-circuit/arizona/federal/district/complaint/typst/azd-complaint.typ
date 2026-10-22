// Complaint for the U.S. District Court for the District of Arizona (azd).
// Rules: LRCiv 7.1(a) (first page: counsel from line 1, court title on or below line 6, caption with the case
// number, description and jury demand to the right of center), 7.1(b)(1) (double-spaced, no more than 28 lines
// per page, proportional font of at least 13 point, numbered pages, left margin at least 1 1/2 inches, right at
// least 1/2 inch); Fed. R. Civ. P. 8(a) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LRCiv 7.1(b)(1): proportional font; vendored in fonts/ (see README.md, gap 2)
#let type-size = 13pt                   // LRCiv 7.1(b)(1): a proportional font of no less than 13 point, footnotes included
#let lines-per-page = 27                // LRCiv 7.1(b)(1): no more than 28 lines per page
#let top-margin = 72pt                  // line 1 sits on the top margin; the 27 lines end at 10 in
#let left-margin = 1.5in                // LRCiv 7.1(b)(1): not less than 1 1/2 inches (room for the line numbers)
#let right-margin = 1in                 // LRCiv 7.1(b)(1): not less than 1/2 inch
#let text-width = 8.5in - left-margin - right-margin
#let number-column = 1.08in             // the line numbers end this far from the page's left edge
#let para-indent = 0.5in                // first-line indent of the lead-in and the numbered allegations
#let number-box = 0.5in                 // an allegation's number box: the text starts an inch in
#let item-indent = 0.5in                // relief items: the letter half an inch in
#let item-box = 0.4in                   // the letter's box: the item's text hangs 0.9 in from the margin
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case number
#let caption-inset = 10pt               // the party text stands off the column's right rule
#let caption-pad = 8pt                  // the party column's bottom rule stands this far below its last line
#let right-inset = 0.1in                // the case number stands this far into its column
#let title-gap = 12pt                   // between the case number and the description of the paper
#let counsel-lines = 5                  // LRCiv 7.1(a)(2): the court title begins on or below line 6
#let signature-width = 3.4in            // the signature block, at the right margin
#let certificate-width = 3.6in          // the certificate's signature, at the right margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LRCiv 7.1(b)(1): double-spaced body; the numbered lines are this pitch
#let pitch-single = 16pt                // counsel block, caption, signature: three single lines take two numbered lines
#let single-lift = 6.4pt               // a single-spaced block starts this far into a numbered line, so its first baseline is that line's
                                        // (0.8 x 24 - 0.8 x 16): no single line stands half-way into a line number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("azd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// The space that brings `n` single lines (and `extra` points) down to the next numbered line, so whatever follows
/// stays on the grid of numbered lines. Counted by entry, not measured, as the Word filter counts them.
#let grid-pad(n, extra: 0pt) = {
  let h = single-lift + n * pitch-single + extra
  calc.ceil(h / pitch) * pitch - h
}

/// Single lines, the last one followed by the space that brings the block to whole numbered lines (at least
/// `min` of them).
#let single-lines(lines, min: 0) = {
  let rest = calc.max(grid-pad(lines.len()), min * pitch - single-lift - lines.len() * pitch-single)
  // the lift and the rest as padding, not as spacing: they hold at the top of a page and at the end of a
  // container too (as in Word)
  pad(top: single-lift, bottom: rest, for l in lines { line-block(l) })
}

/// A double-spaced paragraph with a first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Page furniture: line numbers, pleading rules, page number
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, on the baselines of the text's lines.
#let line-numbers() = {
  set text(..edges(pitch))
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-column, height: pitch, align(right, str(i))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = context {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page.height), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page.height), stroke: 0.75pt))
  place(top + left, dx: page.width - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page.height), stroke: 0.75pt))
}

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-5 or more), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  // a numbered line above the caption and below it (Word: the paragraph after the table takes the space below)
  let below = pitch + grid-pad(rows.len(), extra: caption-pad)
  block(width: 100%, above: pitch + single-lift, below: below, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    // Each party: its names, then its designation; "v." between the parties.
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad),
      for r in rows { line-block(inl(r)) }),
    // LRCiv 7.1(a)(3), right of center: (A) the number of the action, (B) a brief description of the paper,
    // including a demand for jury trial if made.
    pad(left: right-inset, {
      line-block[Case No. #meta.case_number]
      line-block(above: title-gap, strong(inl(meta.brief_title)))
    }),
  ))
}

#let cover(meta) = {
  // Lines 1 to 5 at least; a longer counsel block pushes the court title down, which the rule allows only on or
  // below line 6 (LRCiv 7.1(a)(2)).
  single-lines(meta.counsel.map(inl), min: counsel-lines)
  block(width: 100%, above: 0pt, below: 0pt, align(center, strong("IN THE UNITED STATES DISTRICT COURT")))
  block(width: 100%, above: 0pt, below: 0pt, align(center, strong("FOR THE DISTRICT OF ARIZONA")))
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

/// Headings: one numbered line each, kept with the text after them (a heading never ends a page): level 1 a
/// centered section in capitals, level 2 a centered bold sub-heading, level 3 bold italic at the margin.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    align(center, strong(it.body))
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered. The last block is kept
/// with the signature block, so the signature never stands on a page alone.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    show: if i == chunks.len() - 1 { it => block(sticky: true, breakable: false, above: 0pt, below: 0pt, it) } else { it => it }
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#md(t)])
    }
  }
}

// LRCiv 7.1 gives no signature form; the "DATED this ... day of ..." line is the form of the local rules' Appendix C.
#let signature-block(meta) = {
  // the firm, a blank single line, the signature line and the lines under it
  let firm = meta.signature.firm.map(inl)
  let rest = ([By: /s/ #meta.signature.signer],) + meta.signature.lines.map(inl)
  let pad-below = grid-pad(firm.len() + 1 + rest.len())
  block(width: 100%, above: pitch, below: 0pt, breakable: false, {
    block(width: 100%, above: 0pt, below: 0pt)[DATED this #inl(meta.date).]
    pad(left: text-width - signature-width, top: single-lift, bottom: pad-below, {
      for l in firm { line-block(l) }
      for (j, l) in rest.enumerate() {
        line-block(above: if j == 0 { pitch-single } else { 0pt }, l)
      }
    })
  })
}

#let certificate(meta) = if "certificate" in meta {
  block(sticky: true, width: 100%, above: pitch, below: 0pt, align(center, strong(inl(meta.certificate.heading))))
  body-par(inl(meta.certificate.text))
  block(width: 100%, above: 0pt, below: 0pt, pad(left: text-width - certificate-width)[/s/ #meta.certificate.signer])
}

#let azd-complaint(meta, body) = {
  // LRCiv 7.1(b)(1): letter size; 27 numbered lines of 24 pt from the top margin; the page number centered under
  // them, 8 pt below the text area, in a single line (Word's footer, 48 pt above the page foot).
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: 11in - top-margin - lines-per-page * pitch, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    footer-descent: 8pt,
    footer: context line-block(align(center, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch; relief items as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 1332"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists become A., B., C., ... (prayer items).
  set enum(numbering: "A.")

  cover(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
  certificate(meta)
}
