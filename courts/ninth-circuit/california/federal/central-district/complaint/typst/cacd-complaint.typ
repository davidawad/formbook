// Complaint for the U.S. District Court for the Central District of California (cacd).
// Rules: L.R. 11-3.1 to 11-3.8 (legibility, 14-point font, paper and numbered lines, pagination,
// double spacing, quotations, title page); Fed. R. Civ. P. 10(a)-(b) (caption, numbered paragraphs);
// Fed. R. Civ. P. 8(a) (short and plain statement); Fed. R. Civ. P. 38 (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 11-3.1.1: proportionally spaced font; vendored in fonts/ (README.md, Known gaps)
#let type-size = 14pt                   // L.R. 11-3.1.1: standard (non-condensed) 14-point or larger
#let footer-size = 10pt                 // the footer's page number, title and case number
#let lines-per-page = 27                // L.R. 11-3.2: not more than 28 lines per page
#let page-w = 8.5in                     // L.R. 11-3.2: 8 1/2 x 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // L.R. 11-3.2: line 1 begins at least one inch below the top edge
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let number-width = 1in                 // the line numbers stand right-aligned in the first inch of the page
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let number-box = 0.45in                // the allegation number's box: the text starts 0.95 in from the margin
#let item-indent = 0.5in                // list items: the label half an inch in
#let item-box = 0.4in                   // the label's box: the item's text hangs 0.9 in from the margin
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column's rule and the case column
#let caption-inset = 10pt               // the party text stands off the column's rule
#let right-inset = 0.1in                // the case column's text stands this far in
#let counsel-lines = 7                  // L.R. 11-3.8(a)-(c): counsel from line 1; the court title on or below line 8
#let sig-left = 2.6in                   // the date column of the signature block
#let footer-case = 1.6in                // the footer's case-number column, at the right margin
#let footer-bottom = 16pt              // the footer ends this far above the foot of the page and grows upward (Word's footer)
#let footer-gap = 4pt                   // between the footer's page number and its title line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // L.R. 11-3.2 and 11-3.6: double spaced; the numbered lines are this pitch
#let pitch-single = 16pt                // counsel, caption and signature: single-spaced (L.R. 11-3.8(a)), 1.14 x the
                                        // type size, two thirds of a numbered line (three single lines to two numbered)
#let pitch-footer = 11.5pt              // the footer's lines, 1.15 x its size
#let gap = 16pt                         // between the caption's parts and the signature's groups: one single line
#let drop = 6.4pt                       // a single-spaced block starts this far into its numbered line, so that its first
                                        // line (and every third after it) stands on the line number's baseline
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacd-complaint: the sample must start with a YAML frontmatter block") }
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

/// A double-spaced paragraph (one or more numbered lines) with a first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, on the baseline of its line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-width, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer: page number, the paper's title and the case number (L.R. 11-3.8(d)), below the last numbered line.
#let footer-block(title, case-number) = place(
  bottom + left,
  dx: left-margin,
  dy: -footer-bottom,
  block(width: text-width, {
    set align(top)              // the cells keep to the top of their row (place sets the bottom)
    set text(size: footer-size, ..edges(pitch-footer))
    set par(first-line-indent: 0pt)
    block(width: 100%, below: 0pt, align(center, context counter(page).display("-1-")))
    block(width: 100%, above: footer-gap, grid(
      columns: (1fr, footer-case),
      upper(inl(title)),
      align(right, [CASE NO. #case-number]),
    ))
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel, from line 1 (L.R. 11-3.8(a)). Lines 1-7 at least; more counsel lines push the court title down by whole
/// numbered lines (L.R. 11-3.8(c): "except where additional space is required for counsel identification"). The
/// Word filter counts the same lines (docx/lib/lines.lua).
#let counsel-block(meta) = context {
  let c = for l in meta.counsel { line-block(inl(l)) }
  let h = measure(width: text-width, c).height + drop
  block(width: 100%, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch, inset: (top: drop), above: 0pt,
    below: 0pt, c)
}

/// The court name (L.R. 11-3.8(d)): bold, centered, one numbered line each.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "CENTRAL DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { block(width: 100%, above: 0pt, below: 0pt, align(center, strong(l))) }
}

/// The caption, a numbered line below the court title (L.R. 11-3.8(e); Fed. R. Civ. P. 10(a)): each party's names,
/// then its designation, "v." between the parties, in a column ruled on the right and bottom; the case number, the
/// title of the paper, a legend and the jury demand beside it.
#let caption(meta) = block(width: 100%, above: pitch + drop, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: gap), {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for l in p.names + (p.designation,) { line-block(inl(l)) }
    }
  }),
  pad(left: right-inset, {
    line-block[Case No. #meta.case_number]
    line-block(above: gap, strong(inl(meta.brief_title)))
    if "legend" in meta and meta.legend != none { line-block(above: gap, strong(upper(meta.legend))) }
    if "jury_demand" in meta and meta.jury_demand { line-block(above: gap, strong("DEMAND FOR JURY TRIAL")) }
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

/// Headings, one numbered line each: level 1 a centered section in capitals; level 2 a centered bold sub-heading;
/// level 3 bold italic. Sticky: a heading never ends a page.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    align(center, strong(it.body))
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered,
/// list items lettered (a), (b), ... or bulleted. Numbering is applied per chunk, not with a `show par` rule: a show
/// rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (k, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else {
      n += 1
      let par = body-par([#box(width: number-box, [#n.])#md(t)])
      // the last paragraph is kept whole with the signature block, so the signature never stands on a page alone
      if k == chunks.len() - 1 { block(sticky: true, breakable: false, above: 0pt, below: 0pt, par) } else { par }
    }
  }
}

// The signature block, a numbered line below the text, is kept whole: it never splits across a page break. The
// space above it is an inset, kept at the top of a page as Word keeps the space above a table's first line.
#let signature-block(meta) = block(breakable: false, width: 100%, above: 0pt, below: 0pt, inset: (top: pitch + drop), grid(
  columns: (sig-left, 1fr),
  column-gutter: caption-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    for (j, l) in meta.signature.firm.enumerate() { line-block(above: if j == 0 { gap } else { 0pt }, inl(l)) }
    line-block(above: gap, [By: /s/ #meta.signature.signer])
    for l in (meta.signature.signer,) + meta.signature.lines { line-block(inl(l)) }
  },
))

#let cacd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch; list items as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 17200"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  set enum(numbering: "(a)")

  cover(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
}
