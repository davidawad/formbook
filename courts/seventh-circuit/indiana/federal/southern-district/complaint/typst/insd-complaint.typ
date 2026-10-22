// Complaint for the U.S. District Court for the Southern District of Indiana (insd).
// Rules: S.D. Ind. L.R. 5-1(b) (1-inch margins, 12-point body, double spacing except headings and
// quotations, consecutively numbered pages, title on the first page, filer's name, address, telephone
// and e-mail); Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let numbered = true                    // Fed. R. Civ. P. 10(b): claims in numbered paragraphs
#let font-family = ("Times New Roman", "Liberation Serif")        // no face named by L.R. 5-1(b); Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // L.R. 5-1(b): at least 12-point type in the body
#let margin = 1in                       // L.R. 5-1(b): at least 1-inch margins
#let page-w = 8.5in                     // 8 1/2 x 11 inch paper (L.R. 5-1(d) for paper filings)
#let page-h = 11in
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of paragraphs; a paragraph number or list label starts here
#let number-box = 0.5in                 // a paragraph number (list label) in a box after the indent: its text starts 1 in from the margin
#let caption-party-w = 3.4in            // width of the party column of the caption
#let caption-paren-w = 0.3in            // the column of ")" marks between parties and case number
#let quote-inset = 0.5in                // block quotations are indented on both sides
#let sig-left = 3.25in                  // the signature lines start 3.25 in from the margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/insd.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // L.R. 5-1(b): double spaced, two 12 pt lines
#let pitch-single = 13.8pt              // headings, caption, quotations and signature block: single spaced
#let para-gap = 16.1pt                  // below every paragraph, list item, heading and quotation
#let heading-above = 12pt               // above a heading
#let court-gap = 24pt                   // court title to caption
#let title-above = 18pt                 // caption to title
#let jury-above = 6pt                   // title to the jury demand
#let title-below = 12pt                 // title (or jury demand) to the body
#let sig-above = 24pt                   // the last paragraph to the signature block
#let date-gap = 12pt                    // the date line to the signature lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Markdown to inline typst content.
#let md(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// One single-pitch line (a paragraph of its own) of plain text, as written; "" is a blank line.
#let sline(above: 0pt, left: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, c))
  })
}

/// A heading: bold, single-spaced, kept with the text after it.
#let heading(s, align-to: center, above: heading-above) = block(width: 100%, above: above, below: para-gap, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(align-to, strong(md(s)))
})

/// A body paragraph on the body pitch, its first line indented; `label` (a number) in a box after the indent.
#let body-par(label: none, above: 0pt, sticky: false, c) = block(width: 100%, above: above, below: para-gap, sticky: sticky,
  par(first-line-indent: 0pt, [#h(para-indent)#if label != none { box(width: number-box, label) }#c]))

/// One chunk of the markdown body (chunks are separated by blank lines).
/// `above`: the space above it (the first chunk, under the title); `sticky`: kept with the block after it.
#let chunk(t, num, above: 0pt, sticky: false) = {
  if t.starts-with("### ") {
    heading(t.slice(4), align-to: left, above: calc.max(above, heading-above))
  } else if t.starts-with("## ") {
    heading(t.slice(3), above: calc.max(above, heading-above))
  } else if t.starts-with("# ") {
    heading(upper(t.slice(2)), above: calc.max(above, heading-above))
  } else if t.starts-with("- ") or t.match(regex("^\\d+\\. ")) != none {
    // A list: each item's number as written (a bullet as "•") at the indent, its lines hanging at 1 in.
    let marks = t.matches(regex("(?m)^(\\d+\\.|-)[ \\t]+")).map(m => if m.captures.at(0) == "-" { "•" } else { m.captures.at(0) })
    let items = t.split(regex("(?m)^(\\d+\\.|-)[ \\t]+")).map(s => s.trim()).filter(s => s != "")
    for (k, item) in items.enumerate() {
      block(width: 100%, above: if k == 0 { above } else { 0pt }, below: para-gap,
        sticky: sticky and k == items.len() - 1, par(first-line-indent: 0pt, hanging-indent: para-indent + number-box,
        [#h(para-indent)#box(width: number-box, marks.at(k))#md(item)]))
    }
  } else if t.starts-with(">") {
    let q = t.replace(regex("(?m)^>[ \\t]?"), "")
    block(width: 100%, above: above, below: para-gap, sticky: sticky, pad(x: quote-inset, sline(md(q))))
  } else if num != none {
    body-par(label: [#num.], above: above, sticky: sticky, md(t))
  } else {
    body-par(above: above, sticky: sticky, md(t))
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

#let cover(meta) = {
  for l in meta.court { sline(centered: true, strong(l)) }
  let rows = calc.max(meta.caption.left.len(), meta.caption.right.len())
  block(width: 100%, above: court-gap, below: 0pt, grid(
    columns: (caption-party-w, caption-paren-w, 1fr),
    for l in meta.caption.left { sline(l) },
    for _ in range(rows) { sline([)]) },
    for l in meta.caption.right { sline(l) },
  ))
  sline(above: title-above, centered: true, strong(upper(meta.title)))
  if meta.at("jury_demand", default: false) {
    sline(above: jury-above, centered: true, strong("JURY TRIAL DEMANDED"))
  }
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 5-1(b): the filer's name, address, telephone and e-mail)
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  sline(sig.date)
  block(width: 100%, above: date-gap, below: 0pt, for l in sig.lines { sline(left: sig-left, l) })
})

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let insd-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // L.R. 5-1(b): consecutively numbered pages, centered at the foot, in a single-pitch line box that ends
    // footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)

  // Paragraphs before the first heading (the lead-in) are not numbered.
  let seen = false
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") { seen = true }
    let list-or-quote = t.starts-with("- ") or t.starts-with(">") or t.match(regex("^\\d+\\. ")) != none
    let para = seen and not t.starts-with("#") and not list-or-quote and not t.starts-with("WHEREFORE")
    if para and numbered { n += 1 }
    // the first chunk stands title-below under the title; the last is kept with the signature (a signature never
    // stands alone on a page)
    chunk(t, if para and numbered { n } else { none }, above: if i == 0 { title-below } else { 0pt },
      sticky: i == chunks.len() - 1)
  }

  signature-block(meta.signature)
}
