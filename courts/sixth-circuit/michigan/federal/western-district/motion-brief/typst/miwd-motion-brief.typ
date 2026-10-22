// Brief in support of a dispositive motion for the U.S. District Court for the Western District of Michigan (miwd).
// Rules: LCivR 10.1 (double spaced, 8 1/2 x 11, one side, type 12 point or larger, margins at least 1 inch);
// LCivR 7.2(b) (a brief in support of a dispositive motion is at most 25 pages, exclusive of cover sheet, tables
// and indices: enforced below); LCivR 7.2(d) (a request for oral argument goes in the caption); LCivR 7.1(a)
// (a brief states the reasons and cites the rules and authorities relied on); LCivR 10.3 and Fed. R. Civ. P. 11(a)
// (date, address, e-mail and telephone of the signing attorney). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LCivR 10.1 names no face; Times New Roman (vendored, docs/FONTS.md), as the filed brief
#let type-size = 12pt                   // LCivR 10.1: type no smaller than 12 point (footnotes included)
#let page-w = 8.5in                     // LCivR 10.1: 8 1/2 x 11 inch paper
#let margin = 1in                       // LCivR 10.1: all margins at least one inch
#let para-indent = 0.5in                // first-line indent of body paragraphs; a heading's label box; a level's step
#let max-body-pages = 25                // LCivR 7.2(b): dispositive-motion brief, exclusive of cover, tables and indices
#let caption-left = 3.25in              // the party column of the caption
#let caption-gutter = 0.25in            // between the party column's rule and the right column ...
#let caption-right-inset = 0.1in        // ... whose text starts this far further in
#let caption-pad-right = 10pt           // the party column's text to its right rule
#let caption-pad-bottom = 8pt           // the last party line to the rule under the party column
#let title-inset = 0.65in               // the cover title is centered in the middle 80 % of the line
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line
#let sig-col = 2.8in                    // the signature's right column starts here; "Dated:" sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/miwd-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 24pt                  // LCivR 10.1: double spaced
#let pitch-single = 13.8pt              // single spacing: court title, caption, headings, contents, footnotes,
                                        // quotations, signature, footer
#let caption-above = 24pt               // the court title to the caption
#let oral-above = 12pt                  // the judge's line to ORAL ARGUMENT REQUESTED
#let title-above = 72pt                 // the caption to the title of the brief
#let toc-page-above = 24pt              // the contents' title to its "Page" label
#let row-gap = 12pt                     // between two rows of the contents
#let heading-gap = 12pt                 // above and below a heading
#let quote-gap = 12pt                   // above and below a block quotation
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt             // from the text to the footnote rule (the space LibreOffice keeps above it)
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // the firm to the "/s/" line
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each. `above`: the space before the first line; `alignment`: of every line.
/// An item is a string (markdown) or content.
#let line-stack(items, above: 0pt, alignment: left) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    block(width: 100%, above: g, below: 0pt, align(alignment, par(if type(i) == str { inl(i) } else { i })))
    g = 0pt
  }
}

/// Heading numbers: I. (level 1), A. (level 2), 1. (level 3), a. (level 4). Numbers are never typed in the sample.
#let brief-numbering(..nums) = {
  let lvl = nums.pos().len()
  let n = nums.pos().last()
  if lvl == 1 { numbering("I.", n) } else if lvl == 2 { numbering("A.", n) } else if lvl == 3 { numbering("1.", n) } else { numbering("a.", n) }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LCivR 7.2(d); Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF MICHIGAN")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  line-stack(lines.map(l => text(weight: "bold", l)), alignment: center)
}

/// The caption (Fed. R. Civ. P. 10(a)): the parties single-spaced in a column closed by a rule on its right and under
/// it ("v." between the parties); at the right the case number and the judge (blanks for the clerk when the sample
/// has none) and, when requested, ORAL ARGUMENT REQUESTED in bold (LCivR 7.2(d)).
#let caption(meta) = {
  let blank = "__________________"
  let cn = if meta.case_number == "" { blank } else { meta.case_number }
  let hon = if meta.judge == "" { blank } else { meta.judge }
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-pad-right, bottom: caption-pad-bottom), line-stack(rows)),
    [],
    pad(left: caption-right-inset, {
      line-stack(("Case No. " + cn, "Hon. " + hon))
      if "oral_argument_requested" in meta and meta.oral_argument_requested {
        line-stack(above: oral-above, (text(weight: "bold", "ORAL ARGUMENT REQUESTED"),))
      }
    }),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: title-above, below: 0pt, pad(x: title-inset,
    align(center, par(first-line-indent: 0pt, text(weight: "bold", inl(meta.title))))))
}

// ---------------------------------------------------------------------------
// Table of contents (generated from the headings; LCivR 7.2(b) excludes it from the page limit)
// ---------------------------------------------------------------------------

/// A contents row: the label in a half-inch box after the level's step, the title hanging after it, a dot leader
/// to the page in the page column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * para-indent
  let num = numbering(brief-numbering, ..counter(heading).at(hd.location()))
  block(width: 100%, above: row-gap, below: 0pt, {
    set text(..edges(pitch-single))
    listing-row(hd.location(), { h(ind); box(width: para-indent, num); hd.body }, it.page(), toc-page-col,
      ind + para-indent, 0pt)
  })
}

#let contents() = {
  line-stack((text(weight: "bold", "TABLE OF CONTENTS"),), alignment: center)
  line-stack(above: toc-page-above, ("Page",), alignment: right)
  show outline.entry: toc-entry
  outline(title: none, depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A heading: single-spaced at the type size, the label in a half-inch box after the level's step and the text
/// hanging after it, a space above and below, kept with the next block. Level 1 bold capitals, level 2 bold, levels 3
/// and 4 regular.
#let style-heading(it) = {
  let num = numbering(it.numbering, ..counter(heading).at(it.location()))
  let ind = (calc.min(it.level, 4) - 1) * para-indent
  let body = if it.level == 1 { text(weight: "bold", upper(it.body)) } else if it.level == 2 { text(weight: "bold", it.body) } else { it.body }
  block(width: 100%, breakable: false, sticky: true, above: heading-gap, below: heading-gap, pad(left: ind, {
    set text(size: type-size, weight: "regular", ..edges(pitch-single))
    par(first-line-indent: 0pt, hanging-indent: para-indent,
      [#box(width: para-indent, if it.level <= 2 { text(weight: "bold", num) } else { num })#body])
  }))
}

/// The signature block (Fed. R. Civ. P. 11(a); LCivR 10.3), single-spaced: "Dated:" and the date at the left of the
/// first line; the firm, "/s/" with the signer and the signer's lines in a column from `sig-col` (docx: a tab and a
/// hanging indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = sig.firm.map(l => (l, 0pt))
  lines.push(("/s/ " + sig.signer, sig-gap))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [Dated: #meta.date])#inl(l)]))
    }
  })
}

/// The brief's body, then the signature block. The last paragraph is kept on the same page as the signature (a
/// signature never stands alone on a page); when the body ends in a heading, nothing is moved. Footnote definitions
/// stay in the first part, with their references.
#let body-with-signature(meta, body-md) = {
  let parts = body-md.trim(at: end).split(regex("\n[ \t]*\n"))
  let tail = none
  for (i, p) in parts.enumerate() {
    if not p.starts-with("[^") { tail = i }
  }
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if tail == none or parts.at(tail).starts-with("#") {
    render(body-md)
    signature-block(meta)
  } else {
    let head = parts.enumerate().filter(e => e.first() != tail).map(e => e.last()).join("\n\n")
    render(head)
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      render(parts.at(tail))
      signature-block(meta)
    })
  }
}

#let miwd-motion-brief(meta, body) = {
  // The page number centered at the foot in a single-pitch line box (Word's footer); none on the cover.
  let footer-num = context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display())))
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LCivR 10.1: double spaced), a section sign kept with its number; lists with their label in a
  // half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled section sign or pilcrow stays with its number ("¶¶ 60–63"; xengine binds a single sign), as the docx
  // binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the text size (LCivR 10.1), single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Quotations single-spaced, half an inch in on both sides.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })
  set heading(numbering: brief-numbering)
  show heading: style-heading

  // Front matter: caption page (no number), contents (roman numerals).
  cover(meta)
  pagebreak()
  set page(numbering: "i", footer: footer-num)
  counter(page).update(1)
  contents()
  pagebreak()

  // The brief itself starts at page 1. The page limit counts from here to the last page (LCivR 7.2(b)).
  set page(numbering: "1", footer: footer-num)
  counter(page).update(1)
  [#metadata(none) <brief-start>]
  body-with-signature(meta, body)

  context {
    let start-loc = query(<brief-start>).first().location()
    let first = counter(page).at(start-loc).first()
    let last = counter(page).final().first()
    let pages = last - first + 1
    assert(pages <= max-body-pages, message: "miwd-motion-brief: the brief is " + str(pages) + " pages; LCivR 7.2(b) allows " + str(max-body-pages) + " for a dispositive-motion brief")
  }
}
