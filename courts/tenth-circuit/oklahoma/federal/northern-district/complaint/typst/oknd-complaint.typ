// U.S. District Court, Northern District of Oklahoma: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (OKND-...) refer to ../../rules.md and ../README.md, which
// quote the rule text: LGnR2-4(a) (format of papers; Local Rules, effective 2026-07-31), LCvR38-1 (jury demand
// notation), LCvR3-1 (civil cover sheet is a separate filing), Fed. R. Civ. P. 8(a) and 10(a)-(b). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. Every case-specific word comes from the
// sample's frontmatter and body (schema: ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // OKND-FONT-002: LGnR2-4(a) names no face; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // OKND-FONT-001: print style not smaller than 12 point
#let footer-size = 12pt                 // the page number, at the 12 pt floor
#let page-w = 8.5in                     // OKND-FORM-001: 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // OKND-FONT-001: margins at least one inch on the top, bottom and sides
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent; a paragraph number or list label starts here
#let number-box = 0.5in                 // a paragraph number in a box after the indent: its text starts 1 in from the margin
#let label-box = 0.4in                  // a list label "(a)" in a box after the indent: the item's lines hang at 0.9 in
#let caption-rule = 0.75pt              // the rule down the right and across the foot of the party column
#let caption-pad = 14.4pt               // the party column's text stands this far from its right rule
#let caption-foot = 12pt                // ... and its last line this far above its foot rule
#let caption-right-pad = 14.4pt         // the case number stands this far right of the rule
#let designation-indent = 1.8in         // a side's designation ("Plaintiff,") is set in this far
#let sig-col = 3.2in                    // the signature column at the right; "Dated:" at the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (docx/oknd-complaint.lua and docx/reference.xml set the same twips: 20 x pt).
// OKND-FORM-001 / OKND-FONT-001: "double-spaced", and "The use of 'Exactly 24 pt' spacing is not permitted"
// (LGnR2-4(a)): the body pitch is the face's own double spacing, twice Times New Roman's single line (1.15 em),
// as a word processor's "Double" sets it, not a fixed 24 pt.
#let pitch-body = 27.6pt                // double spacing: 2 x 13.8 pt
#let pitch-single = 13.8pt              // single spacing of the face (1.15 x 12 pt): court name, caption, title, headings, signature
#let court-gap = 27.6pt                 // court name to caption (a blank double line)
#let versus-gap = 13.8pt                // above and below "v." in the caption
#let title-above = 27.6pt               // caption to title
#let jury-above = 13.8pt                // title to the jury notation
#let title-below = 27.6pt               // title (or the jury notation) to the body
#let heading-gap = 13.8pt               // above and below a heading (a blank single line)
#let sig-above = 27.6pt                 // the last paragraph to the signature block
#let signer-above = 27.6pt              // "Respectfully submitted," to "/s/"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oknd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("oknd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Markdown to inline content.
#let md(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// One single-pitch paragraph, with an explicit space above it.
#let sline(above: 0pt, below: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, if type(c) == str { md(c) } else { c }))
})

// ---------------------------------------------------------------------------
// Cover: court name, caption, title (FRCP 10(a); OKND-CONT-001) and the jury notation (LCvR38-1)
// ---------------------------------------------------------------------------

/// Parties on the left (each side: its names, then its designation; "v." between sides), the file number on the
/// right, centred on the party column's height; the party column ruled at its right and foot.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let left = for (i, side) in sides.enumerate() {
    for n in side.names { sline(n) }
    sline(left: designation-indent, side.designation)
    if i < sides.len() - 1 { sline(above: versus-gap, below: versus-gap, centered: true, "v.") }
  }
  block(width: 100%, above: court-gap, below: 0pt, breakable: false, grid(
    columns: (1fr, 1fr),
    stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if x == 0 { (right: caption-pad, bottom: caption-foot) } else { (left: caption-right-pad, bottom: caption-foot) },
    align: (x, y) => if x == 1 { horizon } else { top },
    left,
    sline([Case No. #need(meta, "case_number")]),
  ))
}

#let cover(meta) = {
  // The court's own name, on two centred lines.
  sline(centered: true, strong[UNITED STATES DISTRICT COURT])
  sline(centered: true, strong[NORTHERN DISTRICT OF OKLAHOMA])
  caption(meta)
  sline(above: title-above, centered: true, strong(md(need(meta, "title"))))
  // LCvR38-1: "Jury Trial Demanded" on the front page, immediately following the title.
  if meta.at("jury_demand", default: false) {
    sline(above: jury-above, centered: true, strong[Jury Trial Demanded])
  }
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), lettered lists, headings
// ---------------------------------------------------------------------------

/// A heading on the single pitch, a blank single line above and below, kept with the text after it: level 1
/// centred bold capitals, level 2 centred bold, level 3 bold italic at the margin.
#let heading(level, s, above: 0pt) = block(width: 100%, above: calc.max(above, heading-gap), below: heading-gap,
  sticky: true, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if level == 1 { align(center, strong(upper(md(s)))) }
    else if level == 2 { align(center, strong(md(s))) }
    else { strong(emph(md(s))) }
  })

/// A body paragraph on the body pitch; `label` (a paragraph number) in a box after the first-line indent.
#let body-par(label: none, above: 0pt, sticky: false, c) = block(width: 100%, above: above, below: 0pt,
  sticky: sticky, par(first-line-indent: 0pt,
    [#h(para-indent)#if label != none { box(width: number-box, label) }#c]))

/// One chunk of the markdown body (chunks are separated by blank lines). `above`: the space above it; `sticky`:
/// kept with the block after it (the signature block, for the last chunk).
#let chunk(t, num, above: 0pt, sticky: false) = {
  let hm = t.match(regex("^(#{1,3}) "))
  if hm != none {
    heading(hm.captures.at(0).len(), t.slice(hm.end), above: above)
  } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
    // A list (subparagraphs, the prayer): lettered (a), (b), ... at the indent, its lines hanging at 0.9 in.
    // A list may break across pages, never inside an item's line.
    let bullet = t.match(regex("^[-*+]")) != none
    let items = t.split(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")).map(s => s.trim()).filter(s => s != "")
    for (k, item) in items.enumerate() {
      let lab = if bullet [•] else { numbering("(a)", k + 1) }
      block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt, sticky: sticky and k == items.len() - 1,
        par(first-line-indent: 0pt, hanging-indent: para-indent + label-box,
          [#h(para-indent)#box(width: label-box, lab)#md(item)]))
    }
  } else if num != none {
    body-par(label: [#num.], above: above, sticky: sticky, md(t))
  } else {
    // The prayer's lead-in (WHEREFORE ...): an indented paragraph, not a numbered allegation.
    body-par(above: above, sticky: sticky, md(t))
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRCP 11(a); LGnR2-6; OKND-CERT-001): "Dated:" at the left, the signature at the right
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    let col = page-w - 2 * margin - sig-col
    let row(above: 0pt, lead, c) = block(width: 100%, above: above, below: 0pt,
      par(first-line-indent: 0pt, hanging-indent: col, [#box(width: col, lead)#if type(c) == str { md(c) } else { c }]))
    row([Dated: #need(meta, "date")], [Respectfully submitted,])
    row(above: signer-above, none, "/s/ " + sig.signer)
    for l in sig.at("lines", default: ()) { row(none, l) }
  })
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let oknd-complaint(meta, body) = {
  for k in ("case_number", "caption", "title", "signature", "date") { let _ = need(meta, k) }

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number centred at the foot of every page, in a single-pitch line box that ends footer-distance
    // above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)

  // The unnumbered lead-in ("COMES NOW ...") under the title, then the chunks of the body. Paragraphs are numbered
  // from 1 (FRCP 10(b)); headings, lists and the prayer's WHEREFORE lead-in are not. The last chunk is kept with the
  // signature block (a signature never stands alone on a page).
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  if "lead_in" in meta { body-par(above: title-below, md(meta.lead_in)) }
  let n = 0
  for (i, t) in chunks.enumerate() {
    let para = not t.starts-with("#") and t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) == none and not t.starts-with("WHEREFORE")
    if para { n += 1 }
    chunk(t, if para { n } else { none }, above: if i == 0 and "lead_in" not in meta { title-below } else { 0pt },
      sticky: i == chunks.len() - 1)
  }

  signature-block(meta)
}
