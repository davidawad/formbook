// Brief in support of a motion for the U.S. District Court for the Southern District of Indiana (insd).
// Rules: S.D. Ind. L.R. 5-1(b) (1-inch margins, 12-point body, double spacing except headings and
// quotations, consecutively numbered pages, title on the first page, filer's name, address, telephone
// and e-mail); Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let numbered = false                   // briefs: paragraphs are not numbered (Fed. R. Civ. P. 10 does not apply)
#let font-family = ("Times New Roman", "Liberation Serif")        // no S.D. Ind. face rule; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // L.R. 5-1(b): at least 12-point type in the body
#let margin = 1in                       // L.R. 5-1(b): at least 1-inch margins
#let page-w = 8.5in                     // 8 1/2 x 11 inch paper (L.R. 5-1(d) for paper filings)
#let page-h = 11in
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of paragraphs
#let number-box = 0.5in                 // a paragraph number (when `numbered`) or a list label in a box after the indent: the text from 1 in
#let caption-party-w = 3.4in            // width of the party column of the caption
#let caption-paren-w = 0.3in            // the column of ")" marks between parties and case number
#let quote-inset = 0.5in                // block quotations are indented on both sides
#let sig-indent = 3.25in                // the signature lines start here

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/insd.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // L.R. 5-1(b): double spaced, a 24 pt pitch at 12 pt; paragraphs follow on the same pitch
#let pitch-single = 13.8pt              // headings, caption, quotations, signature block: single spaced
#let cover-gap = 24pt                   // court title to caption; the title to the body
#let title-above = 18pt                 // caption to the title
#let jury-above = 6pt                   // the title to the jury demand
#let heading-above = 12pt               // above a heading (headings have no space below)
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // the date to the signature lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (inline or block) to typst content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let inl(s) = unloose(md(s))

/// One single-pitch line (a paragraph of its own), with an explicit space above it; "" is a blank line. A string
/// is set as written (the caption's leading spaces stay).
#let sline(above: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    par(first-line-indent: 0pt, c)
  })
}

/// A heading: single-spaced, bold, kept with the text after it.
#let heading(s, align-to: center) = block(width: 100%, above: heading-above, below: 0pt, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(align-to, strong(inl(s)))
})

/// A body paragraph on the body pitch, its first line indented; `label` in a box after the indent.
#let body-par(c, label: none, hang: 0pt) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), hanging-indent: hang,
    if label == none { c } else [#box(width: number-box, label)#c]))

/// One chunk of the markdown body (chunks are separated by blank lines).
#let chunk(c, num) = {
  let t = c.trim()
  if t.starts-with("### ") {
    heading(t.slice(4), align-to: left)
  } else if t.starts-with("## ") {
    heading(t.slice(3))
  } else if t.starts-with("# ") {
    heading(upper(t.slice(2)))
  } else if t.starts-with("- ") or t.match(regex("^\\d+\\. ")) != none {
    // A list: the label at the indent in a box, the lines hanging at 1 in, on the body pitch.
    let items = t.split(regex("(?m)^(?:\\d+\\.|-)[ \\t]+")).map(s => s.trim()).filter(s => s != "")
    for (k, item) in items.enumerate() {
      body-par(inl(item), label: if t.starts-with("- ") [•] else [#(k + 1).], hang: para-indent + number-box)
    }
  } else if t.starts-with(">") {
    block(width: 100%, above: 0pt, below: 0pt, pad(x: quote-inset,
      sline(inl(t.replace(regex("(?m)^>[ \\t]?"), "")))))
  } else if num != none {
    body-par(inl(t), label: [#num.])
  } else {
    body-par(inl(t))
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

#let cover(meta) = {
  for l in meta.court { sline(centered: true, strong(l)) }
  let rows = calc.max(meta.caption.left.len(), meta.caption.right.len())
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (caption-party-w, caption-paren-w, 1fr),
    { for l in meta.caption.left { sline(l) } },
    { for _ in range(rows) { sline(")") } },
    { for l in meta.caption.right { sline(l) } },
  ))
  // The body starts a double line below the title (or the jury demand): the space below the last cover line.
  let jury = meta.at("jury_demand", default: false)
  block(width: 100%, above: title-above, below: if jury { 0pt } else { cover-gap },
    sline(centered: true, strong(upper(meta.title))))
  if jury {
    block(width: 100%, above: jury-above, below: cover-gap, sline(centered: true, strong("JURY TRIAL DEMANDED")))
  }
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 5-1(b): the filer's name, address, telephone and e-mail)
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  sline(sig.date)
  block(width: 100%, above: sig-gap, below: 0pt, pad(left: sig-indent, { for l in sig.lines { sline(l) } }))
})

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let insd-motion-brief(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // L.R. 5-1(b): consecutively numbered pages, centered at the foot from page 1, in a single-pitch line box that
    // ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 37"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)

  // Paragraphs before the first heading (the lead-in) are not numbered.
  let seen = false
  let n = 0
  for c in body.split("\n\n") {
    let t = c.trim()
    if t.starts-with("#") { seen = true }
    let list-or-quote = t.starts-with("- ") or t.starts-with(">") or t.match(regex("^\\d+\\. ")) != none
    let para = seen and not t.starts-with("#") and not list-or-quote and not t.starts-with("WHEREFORE")
    if para and numbered { n += 1 }
    if t != "" { chunk(c, if para and numbered { n } else { none }) }
  }

  signature-block(meta.signature)
}
