// Adversary complaint for the United States Bankruptcy Court, Central District of California (cacb).
// Rules: FRBP 7008(a) and LBR 7008-1 (core/non-core statement in the first numbered paragraph); FRBP 7010 (caption);
// LBR 7003-1 (Official Form 1040 cover sheet, paper filings only); LBR 9004-1 and The Central Guide Supplement to
// LBR 9004-1 (Aug. 2022): 8.5 x 11 pages, numbered margins of at most 28 lines, 12-point type or larger, double
// spacing, line 1 at least 1 inch below the top edge, page numbers at the bottom, counsel block on lines 1-7,
// court title on or below line 8, double caption, case / chapter / adversary numbers, hearing line on page 1.
// See ../README.md for the rule text, the open choices and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Central Guide 9004-1(b)(2)(C): Times New Roman is a listed typeface; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt                   // Central Guide 9004-1(b)(2)(C): not smaller than 12 point (the floor; the filed exemplar is 12 pt)
#let lines-per-page = 27                // Central Guide 9004-1(b)(2)(B)(i): not more than 28 numbered lines per page; 27 keeps the last line above the 1 in bottom margin the checks hold the text to
#let page-w = 8.5in                     // Central Guide 9004-1(b)(2)(A): 8 1/2 by 11 inch pages
#let page-h = 11in
#let top-margin = 72pt                  // Central Guide 9004-1(b)(2)(C): line 1 at least 1 inch below the top edge
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent of numbered allegations; the number stands here
#let number-box = 0.5in                 // the allegation number's box: the text starts an inch in
#let item-indent = 0.5in                // prayer items: the number half an inch in, the text a box after it
#let caption-left = 2.9in               // width of the party column of the double caption: the right column holds the title, which must fit on page 1
#let caption-gutter = 0.2in             // between the party column and the right column
#let caption-inset = 10pt               // the party text stands off the column's rule
#let caption-pad = 8pt                  // the party column's bottom rule stands this far below its last line
#let right-inset = 0.1in                // the right column's text stands this far in
#let counsel-lines = 7                  // Central Guide 9004-1(c)(1)(B): the space between lines 1 and 7 is left for the clerk; the court title starts on line 8
#let sig-left = 2.6in                   // the signature block's date column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // Central Guide 9004-1(b)(2)(F): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // counsel, caption, signature: single-spaced, two lines to a numbered line
#let half-gap = 12pt                    // a blank single line in the caption and the signature block
#let to-grid = pitch - 2.4pt          // the space above a block of single lines after a numbered line: every second single line
                                        // then stands on a numbered line's baseline (0.8 x 24 pt; a single line's is 0.8 x 12 pt)
#let counsel-drop = 9.6pt              // the counsel lines start 9.6 pt down, so the first stands on line 1's baseline (0.8 x 24 pt) and every
                                        // second one on a numbered line's
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: the page number and footer line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A double-spaced paragraph with a first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, ending half an inch left of the text, on the baselines of the double-spaced text.
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

/// Page number at the bottom of every page (Central Guide 9004-1(b)(2)(G)), then the paper's title and the adversary
/// number on the footer line: single lines, 6 pt below the last numbered line.
#let footer-block(title, adversary-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: type-size, ..edges(pitch-single))
    line-block(align(center, context counter(page).display("1")))
    line-block(above: 4pt, grid(columns: (1fr, auto), upper(inl(title)), [ADV. NO. #adversary-number]))
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), double caption, title of the paper
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

/// The double caption (Central Guide 9004-1(c)(2)): debtor on top, then the adversary parties, separated
/// from the right-hand column by a rule. Right column: case number, chapter, adversary number, title, hearing.
#let caption(meta) = block(width: 100%, above: to-grid, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    line-block[In re:]
    for n in as-list(meta.caption.debtor.names) { line-block(inl(n)) }
    line-block(inl(meta.caption.debtor.designation))
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: half-gap, [v.]) }
      for (j, n) in as-list(p.names).enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block[Case No. #meta.bankruptcy_case]
    line-block[Chapter #meta.chapter]
    line-block(above: half-gap)[Adv. No. #meta.adversary_number]
    line-block(above: half-gap, strong(inl(meta.brief_title)))
    if "legend" in meta and meta.legend != none { line-block(above: half-gap, strong(upper(meta.legend))) }
    for (j, l) in as-list(meta.hearing).enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings, each in numbered lines: level 1 a centered section in capitals; level 2 a bold centered sub-heading;
/// level 3 bold italic. Sticky: a heading never ends a page.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    align(center, strong(it.body))
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
}

/// The signature block, one blank numbered line below the text: the date at left; "Respectfully submitted,", the
/// firm and the signer at right, single lines.
#let signature-block(meta) = block(width: 100%, above: to-grid, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: caption-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    for (j, l) in as-list(meta.signature.firm).enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
    line-block(above: half-gap)[By: /s/ #meta.signature.signer]
    line-block(upper(meta.signature.signer))
    for l in as-list(meta.signature.lines) { line-block(inl(l)) }
  },
))

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (FRBP 7010 applies Fed. R. Civ. P. 10(b)). Headings and lists are unnumbered. Numbering is
/// applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end
/// in typst 0.15. The last paragraph or list item is kept with the signature block in one unbreakable block, so the
/// signature never stands on a page alone.
#let allegations(body, signature) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list: the prayer's items, numbered from the markdown start number.
      if last {
        let starts = t.matches(regex("\\n(\\d+\\.|[-*+])[ \\t]"))
        let cut = if starts.len() > 0 { starts.last().start } else { 0 }
        if cut > 0 { pad(left: item-indent, md(t.slice(0, cut))) }
        block(breakable: false, width: 100%, above: 0pt, below: 0pt, { pad(left: item-indent, md(t.slice(cut).trim())); signature })
      } else {
        pad(left: item-indent, md(t))
      }
    } else {
      let piece = if t.starts-with("WHEREFORE") {
        // The prayer's lead-in is not a numbered allegation (it is unnumbered in the filed complaint).
        body-par(md(t))
      } else {
        n += 1
        body-par([#box(width: number-box, [#n.])#md(t)])
      }
      if last { block(breakable: false, width: 100%, above: 0pt, below: 0pt, { piece; signature }) } else { piece }
    }
  }
}

#let cacb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.adversary_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch; list items as a number box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: item-indent)
  // A doubled sign stays with its number ("§§ 547"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule

  cover(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  allegations(body, signature-block(meta))
}
