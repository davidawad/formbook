// pawd-motion-brief.typ: memorandum of law in support of a motion, for the United States District Court
// for the Western District of Pennsylvania (a Rule 12(b) motion is the case the sample covers).
// Rules (fetched 2026-10-14, see ../README.md): LCvR 5.1.A-B (paper, type, spacing, margins, footnotes),
// LCvR 5.1.F (a motion and its brief are separate documents), LCvR 5.2.B (signature block with the
// PA bar number prefix), LCvR 7.D (a proposed order accompanies every motion, filed separately).
// Content-agnostic: no case text here. The sample supplies the frontmatter and the markdown body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---- LCvR 5.1 format ----
#let font-family = ("Times New Roman", "Liberation Serif") // LCvR 5.1.B names no face; the exemplar's (vendored, docs/FONTS.md)
#let type-size = 12pt                   // LCvR 5.1.B: not smaller than 12 pt, footnotes included
#let margin = 1in                       // LCvR 5.1.B: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent; a heading's and a contents row's label box; a level's step
#let caption-paren = 0.4in              // the ")" column between the parties and the right column
#let caption-right = 2.9in              // the right column: case number, judge, "Electronically Filed"
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line
#let sig-col = 3.0in                    // the signature's column starts here

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pawd-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 24pt                  // LCvR 5.1.B: double-spaced
#let pitch-single = 13.8pt              // LCvR 5.1.B: headings, quotations and footnotes may be single-spaced; also the
                                        // court title, caption, contents, signature and footer
#let caption-above = 24pt               // the court title to the caption
#let title-above = 24pt                 // the caption to the title of the memorandum
#let toc-page-above = 24pt              // the contents' title to its "Page" label
#let row-gap = 12pt                     // above every row of the contents
#let heading-above = 24pt               // above a heading
#let heading-below = 12pt               // below a heading
#let quote-gap = 12pt                   // above and below a block quotation
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt             // from the text to the footnote rule (the space LibreOffice keeps above it)
#let sig-above = 24pt                   // the last paragraph to the signature block; the gaps inside it
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawd-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Inline markdown (names with *et al.*, the counsel line in italics).
#let md(s) = unloose(cmarker.render(s, smart-punctuation: true, raw-typst: false))

/// Single-spaced lines, one paragraph each. `above`: the space before the first line. An item is a string
/// (markdown) or content; `align`: the lines' alignment.
#let line-stack(items, above: 0pt, align: left) = {
  set text(..edges(pitch-single))
  set std.align(align)
  set par(first-line-indent: 0pt)
  for (k, i) in items.enumerate() {
    block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt, par(if type(i) == str { md(i) } else { i }))
  }
}

/// Heading numbers: I. (level 1), A. (level 2), 1. (level 3), a. (level 4). Numbers are never typed in the sample.
#let brief-numbering(..nums) = {
  let lvl = nums.pos().len()
  let n = nums.pos().last()
  if lvl == 1 { numbering("I.", n) } else if lvl == 2 { numbering("A.", n) } else if lvl == 3 { numbering("1.", n) } else { numbering("a.", n) }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The caption: parties in a left column with a ")" per single line; on the right the case number, the judge and
/// "Electronically Filed", a blank single line apart.
#let caption(meta) = {
  let rows = ()
  for (i, p) in meta.caption.enumerate() {
    if i > 0 { rows.push("v.") }
    for n in p.names { rows.push(n) }
    rows.push(p.designation)
  }
  let right = {
    line-stack(([#meta.at("case_label", default: "Civil Action No.") #meta.case_number],))
    if meta.at("judge", default: none) != none { line-stack(above: pitch-single, (meta.judge,)) }
    if meta.at("electronically_filed", default: false) { line-stack(above: pitch-single, ([Electronically Filed],)) }
  }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (1fr, caption-paren, caption-right),
    line-stack(rows),
    line-stack(rows.map(_ => ")"), align: center),
    right,
  ))
}

#let cover(meta) = {
  line-stack(([*IN THE UNITED STATES DISTRICT COURT*], [*FOR THE WESTERN DISTRICT OF PENNSYLVANIA*]), align: center)
  caption(meta)
  block(width: 100%, above: title-above, below: 0pt, align(center, par(first-line-indent: 0pt, strong(md(meta.title)))))
}

// ---------------------------------------------------------------------------
// Table of contents (generated from the headings, levels 1 and 2)
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
  line-stack((strong[TABLE OF CONTENTS],), align: center)
  line-stack(above: toc-page-above, (strong[Page],), align: right)
  show outline.entry: toc-entry
  outline(title: none, depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A heading, single-spaced at the type size, bold, kept with the next block: level 1 centred, its number and a space
/// before the text; the lower levels the label in a half-inch box after the level's step, the text hanging after it.
#let style-heading(it) = {
  let num = numbering(it.numbering, ..counter(heading).at(it.location()))
  let ind = (calc.min(it.level, 4) - 2) * para-indent
  block(width: 100%, breakable: false, sticky: true, above: heading-above, below: heading-below, {
    set text(size: type-size, weight: "bold", ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, par[#num #it.body]) }
    else { pad(left: ind, par(hanging-indent: para-indent, [#box(width: para-indent, num)#it.body])) }
  })
}

/// The signature block, single-spaced: "Date:" at the margin, then "Respectfully submitted," the firm, the signer's
/// "s/" line and the attorney lines in a column from `sig-col`, 24 pt between the groups.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  let sig = meta.signature
  let date = meta.at("date", default: none)
  if date != none { line-stack(([Date: #date],)); v(sig-above) }
  pad(left: sig-col, {
    line-stack((sig.lead,))
    if sig.at("firm", default: none) != none { line-stack(above: sig-above, sig.firm) }
    line-stack(above: sig-above, (sig.signer,) + sig.lines)
  })
})

/// The memorandum's body, then the signature block. The last paragraph is kept on the same page as the signature (a
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

/// The memorandum. Page 1 is the caption page (no number). The table of contents is numbered in
/// roman numerals from ii (the caption page counts as i), and the body in arabic from 1.
#let pawd-motion-brief(meta, body) = {
  set document(title: meta.title)
  let footer-num = context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display())))
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LCvR 5.1.B: double-spaced), a section sign kept with its number; lists with their label in a
  // half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled section sign or pilcrow stays with its number ("¶¶ 26, 30"), as the docx binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // LCvR 5.1.B: footnotes single-spaced in the body's type size, under a 30 % rule, 7 pt between notes; the mark and
  // a space before the text (Word's footnote). A note is kept whole on the page of its mark (typst would otherwise
  // start a split note on the page before its mark when the mark's line moves on; docx: Footnote Text keepLines).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }
  // LCvR 5.1.B: quotations single-spaced and indented, half an inch in on both sides.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })
  set heading(numbering: brief-numbering)
  show heading: style-heading

  cover(meta)
  pagebreak()
  set page(numbering: "i", footer: footer-num)
  counter(page).update(2) // the caption page is i and is not printed
  contents()
  pagebreak()
  set page(numbering: "1", footer: footer-num)
  counter(page).update(1)
  body-with-signature(meta, body)
}
