// Memorandum of points and authorities in support of a motion, for the U.S. District Court for the
// District of Columbia (dcd). Rules: LCvR 7(a) (statement of points and authorities with each motion),
// 7(c) (proposed order, not part of this file), 7(e) (45-page limit); LCvR 5.1(c) (party and attorney
// identification), 5.1(d) (8 1/2 by 11, typed, double-spaced, 12-point, case number with judge initials).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no typeface is required by LCvR 5.1(d); the vendored serif in fonts/
#let type-size = 12pt                   // LCvR 5.1(d): all pleadings in 12-pt type, footnotes too
#let page-w = 8.5in                     // LCvR 5.1(d): standard 8 1/2 by 11 inch format
#let page-h = 11in
#let margin = 1in                       // convention (no margin figure in LCvR 5.1); 1-inch margins all round
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations: indented from both margins
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case-number column
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let right-inset = 0.1in                // the case-number column stands off the gutter
#let sig-left = 2.8in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toc-step = 0.25in                  // contents: an entry steps in a quarter inch per heading level below the first

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // LCvR 5.1(d): double-spaced (Word's double, as in the filed exemplars)
#let caption-pad = pitch-single / 2     // caption: the rules stand half a line off the text
#let gap = 12pt                         // between contents rows, and between the signature block's groups
#let footer-descent = 21.7pt            // the page number's line box ends 0.5 in above the page foot (Word's footer)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dcd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (a page of its own)
// ---------------------------------------------------------------------------

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    // LCvR 5.1(d): the case number is followed by the judge's initials once a judge is assigned.
    let number = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
    line-block("Civil Action No. " + number)
  }),
))

#let cover(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE DISTRICT OF COLUMBIA")))
  caption(meta)
  // The title of the paper, centered under the caption (LCvR 5.1(d): a heading under the caption).
  line-block(align(center, text(weight: "bold", inl(meta.brief_title))))
}

// One contents row: a step in per heading level below the first; the page number in its own column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind, gap)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: "Dated" at the left; "Respectfully submitted,", the firm, the signature line and the
/// signature, then one group of lines per signer, at the right; it never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    line-block(above: gap, inl(meta.signature.firm))
    line-block(above: gap, "________________________________")
    line-block(inl(meta.signature.signature))
    for lines in meta.signature.blocks {
      for (i, l) in lines.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(l)) }
    }
  },
))

/// The body: each blank-line-separated chunk of markdown is a heading, a block quotation (`>`, indented from both
/// margins) or a paragraph (first-line indented, unnumbered: a memorandum is not a numbered pleading).
#let paragraphs(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      block(width: 100%, above: 0pt, below: 0pt, pad(x: quote-indent, par(first-line-indent: 0pt, md(t.slice(1).trim()))))
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(t)))
    }
    // The last paragraph stays whole with the signature block, so a signature never stands alone on a page.
    if i == chunks.len() - 1 { block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
}

#let dcd-motion-brief(meta, body) = {
  set page(width: page-w, height: page-h, margin: margin, numbering: none, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (LCvR 5.1(d): double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)

  // Headings at the body size, single-spaced and bold, a single line above and below them: level 1 centered in
  // capitals, levels 2 and 3 at the margin. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: pitch-single, below: pitch-single, b)
  }

  cover(meta)

  // The page number: centered in a single-spaced line box (Word's footer). The cover is unnumbered; the contents
  // are numbered in lower-case roman; the body starts again at 1.
  set page(footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  if "toc" in meta and meta.toc {
    set page(numbering: "i")
    counter(page).update(1)
    line-block(below: gap, align(center, text(weight: "bold", "TABLE OF CONTENTS")))
    {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      show outline.entry: toc-entry
      outline(title: none, depth: 3, indent: 0pt)
    }
  }

  set page(numbering: "1")   // a new page, numbered from 1
  counter(page).update(1)
  paragraphs(body, signature-block(meta))
}
