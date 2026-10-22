// Complaint for the U.S. District Court for the Eastern District of Wisconsin (wied).
// Rules (texts in ../README.md): General L.R. 5(a) (8½ x 11 paper, one-inch margins, double spacing,
// 12-point proportional serif type), General L.R. 5(c) (signature block), Civil L.R. 8 (diversity
// pleading), Civil L.R. 10(a) (numbered paragraphs), Fed. R. Civ. P. 8(a), 10(a)-(b), 38.
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
#let para-indent = 0.5in                // first-line indent of every body paragraph; a paragraph number starts here
#let number-box = 0.5in                 // a paragraph number in a box after the indent: its text starts 1 in from the margin
#let letter-box = 0.4in                 // a prayer item's letter at the indent, its lines hanging at 0.9 in
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.3in
#let caption-right-pad = 0.1in          // the right column's text stands this far in
#let vs-indent = 0.75in                 // "v." between the parties
#let designation-indent = 1.5in         // "Plaintiff," / "Defendants." under the names
#let sig-indent = 3.0in                 // the signature block in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wied.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // General L.R. 5(a)(5): double-spaced, 24 pt at 12 pt: body, headings, prayer
#let pitch-single = 13.8pt              // single spacing (a layout choice; General L.R. 5(a)(5) asks double spacing of the text): court title, caption, signature
#let cover-gap = 24pt                   // court title to caption, caption to title, title to lead-in (a blank double line)
#let section-above = 12pt               // half a double line above a section heading (`#`)
#let list-below = 12pt                  // the prayer list to the paragraph after it
#let sig-above = 24pt                   // the last paragraph to "Dated this ...", and "Dated" to the firm
#let sig-gap = 13.8pt                   // a blank single line between the parts of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wied-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (italics, case names, headings).
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
#let body-par(above: 0pt, below: 0pt, sticky: false, c) = block(width: 100%, above: above, below: below,
  sticky: sticky, par(first-line-indent: (amount: para-indent, all: true), unloose(c)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

#let court-title() = {
  sline(centered: true, text(weight: "bold", [UNITED STATES DISTRICT COURT]))
  sline(centered: true, text(weight: "bold", [FOR THE EASTERN DISTRICT OF WISCONSIN]))
}

/// Party names on the left, the case number and jury legend on the right (no ruled box: the
/// pleading form in General L.R. 5 has no line numbers, and the caption is a plain two-column block).
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
    if meta.at("jury_demand", default: false) { sline(left: caption-right-pad, "JURY TRIAL DEMANDED") }
  },
))

#let cover(meta) = {
  court-title()
  caption(meta)
  sline(above: cover-gap, centered: true, text(weight: "bold", upper(meta.document_title)))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b); Civil L.R. 10(a))
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one paragraph (numbered), a list (lettered, A., B., ...)
/// or a heading. Paragraphs under a level-1 heading "PRAYER..." or "DEMAND..." are not numbered: the prayer
/// and the jury demand are conventionally unnumbered. Numbering is applied per chunk, not with a `show par`
/// rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let item-re = regex("(?m)^\\d+\\.[ \\t]+")
  let numbered = true
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      if t.starts-with("# ") {
        let title = upper(t.trim("#", at: start).trim())
        numbered = not (title.starts-with("PRAYER") or title.starts-with("DEMAND"))
      }
      md(t)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // The prayer: lettered A., B., ...; a list may break across pages, like any body text.
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: if i == items.len() - 1 { list-below } else { 0pt },
          par(first-line-indent: 0pt, hanging-indent: para-indent + letter-box,
            [#h(para-indent)#box(width: letter-box, numbering("A.", i + 1))#unloose(md(item))]))
      }
    } else if numbered {
      n += 1
      body-par([#box(width: number-box, [#n.])#unloose(md(t))])
    } else {
      body-par(md(t))
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

#let wied-complaint(meta, body) = {
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
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("§§ 1981"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the type size on the body pitch, kept with the text after them: level 1 centered bold caps (a
  // section, half a double line above it); level 2 centered bold (a count); level 3 bold italic at the margin.
  show heading: it => block(width: 100%, above: if it.level == 1 { section-above } else { 0pt }, below: 0pt,
    sticky: true, {
      set text(size: type-size, weight: "bold")
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, upper(it.body)) }
      else if it.level == 2 { align(center, it.body) }
      else { text(style: "italic", it.body) }
    })

  cover(meta)

  if "lead_in" in meta { body-par(above: cover-gap, md(meta.lead_in)) }

  allegations(body)

  signature-block(meta)
}
