// Brief supporting a motion for the U.S. District Court for the Eastern District of Wisconsin (wied).
// Rules (texts in ../README.md): General L.R. 5(a) (8½ x 11 paper, one-inch margins, double spacing,
// single-spaced quotations of more than two lines, 12-point proportional serif type, case names italicized),
// General L.R. 5(c) (signature block), Civil L.R. 7(a) (a motion is accompanied by a supporting memorandum),
// Civil L.R. 7(f) (30-page limit for a principal memorandum, 15 for a reply; the caption, signature block and
// tables are excluded), Civil L.R. 7(j) (citations). Fed. R. Civ. P. 12(b).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // General L.R. 5(a)(6): proportional serif, no face named; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // General L.R. 5(a)(6)(A): 12-point or larger (headings and the page number too)
#let page-w = 8.5in                     // General L.R. 5(a)(5): 8½ by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // General L.R. 5(a)(5): at least one inch on all four sides
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let numeral-box = 1in                  // an argument heading's numeral ("I.") in a 1 in column, its text hanging after it
#let sub-indent = 0.5in                 // a sub-heading ("a. ...") is indented half an inch
#let quote-inset = 0.5in                // block quotations are indented on both sides
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.3in
#let caption-right-pad = 0.1in          // the right column's text stands this far in
#let vs-indent = 0.75in                 // "v." between the parties
#let designation-indent = 1.5in         // "Plaintiffs," / "Defendants." under the names
#let sig-indent = 3.0in                 // the signature block in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wied.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // General L.R. 5(a)(5): double-spaced, 24 pt at 12 pt: body, section headings
#let pitch-single = 13.8pt              // single spacing (General L.R. 5(a)(5) allows it for headings and long quotations): caption, argument headings, sub-headings, quotations, signature
#let cover-gap = 24pt                   // court title to caption, caption to title, title to the first paragraph
#let section-above = 12pt               // above a section heading (`#`) and an argument heading (`##`)
#let heading-below = 6pt                // below an argument heading, above and below a sub-heading (`###`)
#let quote-gap = 12pt                   // above and below a block quotation
#let sig-above = 24pt                   // the last paragraph to "Dated this ...", and "Dated" to the firm
#let sig-gap = 13.8pt                   // a blank single line between the parts of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wied-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (italics for case names, headings).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it; "" is a blank line.
#let sline(above: 0pt, left: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, if type(c) == str { unloose(md(c)) } else { c }))
  })
}

/// A body paragraph on the body pitch, its first line indented half an inch.
#let body-par(above: 0pt, c) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(c)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

#let court-title() = {
  sline(centered: true, text(weight: "bold", [UNITED STATES DISTRICT COURT]))
  sline(centered: true, text(weight: "bold", [FOR THE EASTERN DISTRICT OF WISCONSIN]))
}

/// Party names on the left, the case number on the right (no ruled box).
#let caption(meta) = block(width: 100%, above: cover-gap, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { sline(left: vs-indent, "v.") }
      for n in p.names { sline(n) }
      sline(left: designation-indent, p.designation)
    }
  },
  [],
  {
    let num = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
    sline(left: caption-right-pad, "Case No. " + num)
  },
))

#let cover(meta) = {
  court-title()
  caption(meta)
  sline(above: cover-gap, centered: true, text(weight: "bold", upper(meta.document_title)))
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs (briefs are not numbered; Civil L.R. 10(a) applies to pleadings)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one of: a section heading (`#`, centered caps), an argument
/// heading (`##`, "I. TEXT" with a hanging numeral), a sub-heading (`###`, "a. TEXT"), a block quotation
/// (`>`, single-spaced and indented, General L.R. 5(a)(5)), or a paragraph (first-line indent, double-spaced).
/// Numbering is not applied: a brief's paragraphs are not numbered.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let first = true
  for t in chunks {
    let above = if first { cover-gap } else { 0pt }
    first = false
    if t.starts-with("## ") {
      // Argument heading, single-spaced bold: the numeral in a hanging column, wrapped lines align with the text.
      let m = t.match(regex("^##\\s+([IVX]+\\.)\\s+([\\s\\S]*)$"))
      let (num, rest) = if m != none { (m.captures.at(0), m.captures.at(1)) } else { (none, t.slice(3).trim()) }
      block(width: 100%, above: calc.max(above, section-above), below: heading-below, sticky: true, {
        set text(..edges(pitch-single), weight: "bold")
        par(first-line-indent: 0pt, hanging-indent: if num != none { numeral-box } else { 0pt },
          [#if num != none { box(width: numeral-box, num) }#unloose(md(rest))])
      })
    } else if t.starts-with("### ") {
      // Sub-heading: bold italic, single-spaced, indented.
      block(width: 100%, above: calc.max(above, heading-below), below: heading-below, sticky: true, {
        set text(..edges(pitch-single), weight: "bold", style: "italic")
        pad(left: sub-indent, par(first-line-indent: 0pt, unloose(md(t.slice(4).trim()))))
      })
    } else if t.starts-with("#") {
      // Section heading: centered bold capitals at the type size on the body pitch.
      block(width: 100%, above: calc.max(above, section-above), below: 0pt, sticky: true, {
        set text(weight: "bold")
        set par(first-line-indent: 0pt)
        align(center, upper(unloose(md(t.trim("#", at: start).trim()))))
      })
    } else if t.starts-with(">") {
      // Block quotation: single-spaced, indented on both sides.
      let q = t.replace(regex("(?m)^>[ \\t]?"), "").trim()
      block(width: 100%, above: calc.max(above, quote-gap), below: quote-gap,
        pad(left: quote-inset, right: quote-inset, sline(q)))
    } else {
      body-par(above: above, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (General L.R. 5(c): "s/ name", attorney name, bar number, role, firm, address,
// telephone, e-mail)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  // (line, space above it)
  let lines = ((s.firm, sig-above), (s.role, 0pt))
  for sg in s.signers {
    lines.push(("s/ " + sg.name, sig-gap))
    lines.push((sg.name, 0pt))
    lines.push((sg.bar, 0pt))
  }
  for (i, a) in s.address.enumerate() { lines.push((a, if i == 0 { sig-gap } else { 0pt })) }
  lines.push(("Telephone: " + s.telephone, 0pt))
  for sg in s.signers { lines.push(("E-mail: " + sg.email, 0pt)) }
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    sline("Dated this " + meta.date + ".")
    for (l, gap) in lines { sline(above: gap, left: sig-indent, l) }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let wied-motion-brief(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number centered at the foot of every page, in a single-pitch line box that ends footer-distance
    // above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 78-91"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)

  body-chunks(body)

  signature-block(meta)
}
