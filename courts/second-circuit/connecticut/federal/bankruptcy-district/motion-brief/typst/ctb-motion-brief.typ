// Memorandum of law supporting a motion, for the United States Bankruptcy Court, D. Connecticut (ctb).
// Rules: Local Bankr. R. 9013-1 (motions conform to FRBP 9013); Local Bankr. R. 7007-1 (adversary motion practice
// follows D. Conn. L. Civ. R. 7) and 7007-2(a) (a brief is at most 25 pages, excluding the table of contents and
// table of authorities; a reply at most 10); D. Conn. L. Civ. R. 7(a)(1)-(2) (oral argument indicated in the lower
// margin of the first page); D. Conn. L. Civ. R. 7(a)(5) (text at least 12 point, footnotes at least 10 point);
// Local Bankr. R. 5005-1 adopting D. Conn. L. Civ. R. 10 (double spacing, 8 1/2 x 11, margins of at least 1 inch,
// page numbers after page 1, docket number with judge initials, signature block); FRBP 9004(a)-(b) (caption).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // no typeface rule in the bankruptcy local rules; Times New Roman (vendored), the house face per docs/FONTS.md (README.md, gap 2 of ../adversary-complaint)
#let type-size = 12pt                  // D. Conn. L. Civ. R. 7(a)(5), applied by Local Bankr. R. 7007-1: text at least 12 point
#let docket-size = 10pt                // the docket line beside the page number (L. Civ. R. 10 sets no size)
#let page-w = 8.5in                    // L. Civ. R. 10: 8 1/2 x 11 inches
#let page-h = 11in
#let margin = 1in                      // L. Civ. R. 10: margins of at least 1 inch
#let footer-distance = 0.5in           // the footer's line box ends half an inch above the page edge (docx: footer 720)
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in               // first-line indent of every body paragraph; a paragraph number starts here
#let number-box = 0.5in                // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-indent = 0.5in             // a lettered sub-item ("a. ...") is indented by this, every line
#let caption-left = 3.4in              // width of the left (party) column of the caption, closed by a right and a bottom rule
#let caption-gutter = 0.2in            // between the party column and the case column
#let caption-rule = 0.75pt             // the party column's rules
#let caption-pad-right = 10pt          // the party column's text to its right rule ...
#let caption-pad-below = 8pt           // ... and to its bottom rule
#let case-pad = 0.1in                  // the case column's text stands off the gutter
#let debtor-indent = 0.5in             // the debtors' names under "In re:"
#let versus-indent = 2.0in             // "v." between the sides
#let designation-indent = 2.5in        // "Debtors.", "Plaintiff,", "Defendant."
#let page-col = 0.5in                  // contents and authorities: the page column the rows wrap before
#let row-hang = 0.5in                  // a row's second line hangs this far in from its first
#let toc-indent = 0.5in                // a level 2 heading's row starts this far in
#let sig-gutter = 0.3in                // between two signing firms' blocks, side by side

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ctb-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                 // L. Civ. R. 10: double-spaced (2 x 12 pt): body, headings, the tables' titles
#let pitch-single = 13.8pt             // single spacing: court, caption, title, table rows, signature blocks, footer
#let caption-above = 24pt              // the court's name to the caption (one blank double line)
#let caption-gap = 12pt                // between the debtor box and the adversary box
#let title-above = 24pt                // the caption to the title
#let table-title-below = 24pt          // a table's title to its column label
#let row-above = 12pt                  // contents: above each row; authorities: above each group
#let sig-above = 24pt                  // the last paragraph to "RESPECTFULLY SUBMITTED,"
#let sig-gap = 13.8pt                  // "RESPECTFULLY SUBMITTED," to the firms' blocks (a blank single line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, right: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  set align(end) if right
  pad(left: left, par(first-line-indent: 0pt, unloose(c)))
})

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// The headings of the body, in order: (level, title).
#let body-headings(body) = body-chunks(body).filter(t => t.starts-with("#")).map(t => {
  let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
  (calc.min(m.captures.at(0).len(), 2), m.captures.at(1).trim())
})

// ---------------------------------------------------------------------------
// Cover: caption (FRBP 9004(b), Official Form 416A), title; the oral-argument legend is the cover's footer
// ---------------------------------------------------------------------------

/// One caption box: the party column (right and bottom rules) and the case column, both from their first line.
#let caption-box(above, left, right) = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) } else { none },
  pad(right: caption-pad-right, bottom: caption-pad-below, left.join()),
  [],
  pad(left: case-pad, right.join()),
))

#let cover(meta) = {
  for l in (meta.court, meta.district, meta.division) {
    sline(centered: true, text(weight: "bold", upper(l)))
  }
  let right1 = (sline[Chapter #meta.chapter], sline[#meta.main_case])
  if meta.at("jointly_administered", default: false) { right1.push(sline[(Jointly Administered)]) }
  caption-box(caption-above,
    (sline[In re:], sline(left: debtor-indent, md(meta.debtors)), sline(left: designation-indent)[Debtors.]),
    right1)
  let left2 = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { left2.push(sline(left: versus-indent)[v.]) }
    left2 += p.names.map(n => sline(md(n)))
    left2.push(sline(left: designation-indent, md(p.designation)))
  }
  caption-box(caption-gap, left2,
    (sline[Adv. Pro. No. #meta.adv_number (#meta.judge)], sline[Dated: #meta.date]))
  block(width: 100%, above: title-above, below: 0pt,
    sline(centered: true, text(weight: "bold", md(meta.title))))
}

/// D. Conn. L. Civ. R. 7(a)(1): whether oral argument is requested, in the lower margin of the first page.
#let oral-legend(meta) = {
  let oa = meta.at("oral_argument", default: none)
  if oa == none { none } else if oa == "requested" [ORAL ARGUMENT REQUESTED] else [ORAL ARGUMENT NOT REQUESTED]
}

// ---------------------------------------------------------------------------
// Table of contents (from the headings) and table of authorities (from the frontmatter)
// ---------------------------------------------------------------------------

/// A table's title on the body pitch, then its column label at the right.
#let table-head(title, col) = {
  block(width: 100%, above: 0pt, below: table-title-below, sticky: true,
    align(center, par(first-line-indent: 0pt, text(weight: "bold", title))))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, sline(right: true, col))
}

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// Every heading of levels 1 and 2 with the page it starts on: level 1 at the margin, level 2 half an inch in;
/// a long title wraps before the page column, its next line hanging half an inch further in.
#let toc(body) = {
  table-head([TABLE OF CONTENTS], [Page])
  context {
    set text(..edges(pitch-single))
    let marks = query(<ctb-head>)
    for (i, (level, title)) in body-headings(body).enumerate() {
      let loc = marks.at(i).location()
      let ind = if level == 1 { 0pt } else { toc-indent }
      listing-row(loc, [#h(ind)#unloose(md(title))], page-label(loc), page-col, ind + row-hang, row-above)
    }
  }
}

/// The authorities by category, with the pages the frontmatter gives (as the filer lists them).
#let toa(meta) = {
  table-head([TABLE OF AUTHORITIES], [Page(s)])
  set text(..edges(pitch-single))
  for cat in meta.authorities {
    block(width: 100%, above: row-above, below: 0pt, sticky: true,
      par(first-line-indent: 0pt, text(weight: "bold", upper(cat.category))))
    for a in cat.items {
      listing-row(none, unloose(md(a.cite)), [#a.pages], page-col, row-hang, 0pt)
    }
  }
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered sub-items, lists
// ---------------------------------------------------------------------------

/// Headings on the body pitch with no space of their own, kept with the block after them (docx: Heading 1 and 2 in
/// docx/reference.xml): `#` a major part, centred bold; `##` an argument heading, bold and left. Each carries the
/// mark the table of contents finds its page by.
#let section-heading(level, t) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set align(center) if level == 1
  par(first-line-indent: 0pt, [#metadata(level)<ctb-head>#text(weight: "bold", unloose(md(t)))])
})

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(c)))

/// Renders the body. Paragraphs before the first heading are unnumbered; every later paragraph is numbered
/// 1, 2, ... (the template numbers, the sample does not). Lettered sub-items (a., b., ...) are not numbered: they are
/// indented half an inch, every line, the letter part of the text.
#let body-text(body) = {
  let numbered = false
  let n = 0
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  for t in body-chunks(body) {
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      numbered = true
      section-heading(calc.min(m.captures.at(0).len(), 2), m.captures.at(1))
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      let ordered = t.match(regex("^\\d+\\.")) != none
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: para-indent + number-box,
          [#h(para-indent)#box(width: number-box, if ordered [#(i + 1).] else [•])#unloose(md(item))]))
      }
    } else if t.match(regex("^[a-z]\\.[ \\t]")) != none {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: letter-indent, par(first-line-indent: 0pt, unloose(md(t)))))
    } else if numbered {
      n += 1
      body-par[#box(width: number-box)[#n.]#unloose(md(t))]
    } else {
      body-par(md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature blocks (D. Conn. L. Civ. R. 10: name, office address, telephone and email under the signature;
// federal bar numbers beneath the names). One block per signing firm, side by side.
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let blocks = meta.signature.esigners
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    sline(text(weight: "bold", [RESPECTFULLY SUBMITTED,]))
    block(width: 100%, above: sig-gap, below: 0pt, grid(
      columns: blocks.map(b => 1fr),
      column-gutter: sig-gutter,
      ..blocks.map(b => (sline(upper(b.firm)), sline[/s/ #b.esigner], ..b.lines.map(l => sline(md(l)))).join()),
    ))
  })
}

// ---------------------------------------------------------------------------
// The document: cover (no number), contents and authorities (lower roman), body (arabic from 1)
// ---------------------------------------------------------------------------

#let ctb-motion-brief(meta, body) = {
  let docket = "Adv. Pro. No. " + meta.adv_number + " (" + meta.judge + ")"
  // L. Civ. R. 10 (via Local Bankr. R. 5005-1): page numbers in the bottom margin after page 1, and the docket number
  // with the judge's initials on every page after the caption: the number centred, the docket line at the right, in
  // a single-pitch line box that ends footer-distance above the page edge.
  let running-footer = context {
    set text(..edges(pitch-single))
    grid(columns: (1fr, auto, 1fr), [], numbering(here().page-numbering(), ..counter(page).get()),
      align(right, text(size: docket-size, docket)))
  }
  set page(width: page-w, height: page-h, margin: margin, footer-descent: margin - footer-distance - pitch-single)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Cover: no number; the oral-argument legend in its lower margin (the footer line), bold, at the left.
  let legend = oral-legend(meta)
  page(numbering: none, footer: if legend == none { none } else {
    set text(..edges(pitch-single))
    text(weight: "bold", legend)
  }, cover(meta))

  // Front matter: lower roman from i; the authorities on a page of their own.
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc(body)
  pagebreak()
  toa(meta)

  // Body: arabic numerals from 1.
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)
  body-text(body)
  signature(meta)
}
