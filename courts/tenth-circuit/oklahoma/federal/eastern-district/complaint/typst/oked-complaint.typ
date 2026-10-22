// Complaint for the U.S. District Court for the Eastern District of Oklahoma (oked).
// Rules: LCvR 5.2(a) (paper, 12-point print style, 1-inch margins, line spacing of at least 1.5),
// LCvR 3.1 (parties numbered consecutively in the caption), Fed. R. Civ. P. 10(a) (caption) and
// 10(b) (numbered paragraphs). See ../README.md for each choice and its source.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LCvR 5.2(a) names no typeface; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // LCvR 5.2(a): print style, footnotes included, not smaller than 12 point
#let page-margin = 1in                  // LCvR 5.2(a): margins at least 1 inch on the top, bottom and sides
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of paragraphs; a paragraph number or prayer letter starts here
#let number-width = 0.5in               // the paragraph number sits in a half-inch box after the indent: text from 1 in
#let caption-left = 3.5in               // width of the party column of the caption
#let caption-paren = 0.3in              // the column of ")" marks, as in the exemplar caption
#let caption-number = 0.5in             // a party's number "(n)" in a box at the left of the party column
#let caption-versus = 1.1in             // "v." this far into the party column
#let caption-designation = 1.8in        // "Plaintiff," / "Defendants." this far into the party column
#let quote-left = 1in                   // block quotations: indented 1 in on the left
#let quote-right = 0.5in                // and 0.5 in on the right
#let sig-left = 3.2in                   // the signature block starts 3.2 in from the margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/oked.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // LCvR 5.2(a): at least 1.5 spacing; the body is double spaced, two 12 pt lines
#let pitch-single = 13.8pt              // caption, headings, block quotations (LCvR 5.2(a) excepts them) and signature block
#let court-gap = 24pt                   // court title to caption
#let title-above = 24pt                 // caption to title
#let title-below = 12pt                 // title to the body
#let heading-above = 12pt               // above a heading
#let quote-gap = 12pt                   // above and below a block quotation
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // between the parts of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oked-complaint: the sample must start with a YAML frontmatter block") }
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

/// Markdown to inline typst content (case names in italics, bold words).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// One single-pitch line (a paragraph of its own); none is a blank line.
#let sline(above: 0pt, below: 0pt, left: 0pt, hang: 0pt, centered: false, c) = if c == none {
  block(width: 100%, height: pitch-single, above: above, below: below)
} else {
  block(width: 100%, above: above, below: below, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, hanging-indent: hang, c))
  })
}

// ---------------------------------------------------------------------------
// Caption: court name, parties (numbered, LCvR 3.1), ")" column, case number and legends
// ---------------------------------------------------------------------------

/// One caption row per line of the sample: the party lines (the first line of a party numbered), a blank row
/// between parties, "v." between the sides, the designations.
#let caption-rows(meta) = {
  let rows = ()
  let k = 0
  let first-side = true
  for key in ("plaintiffs", "defendants") {
    if not first-side {
      rows.push(none)                          // a blank row, "v.", a blank row between the sides
      rows.push((left: caption-versus, text: "v."))
      rows.push(none)
    }
    first-side = false
    for (pi, p) in meta.caption.at(key).enumerate() {
      if pi > 0 { rows.push(none) }
      k += 1                                   // LCvR 3.1: each party numbered, plaintiffs then defendants
      for (li, line) in p.names.enumerate() {
        rows.push((number: if li == 0 { k } else { none }, text: line))
      }
      if "designation" in p { rows.push((left: caption-designation, text: p.designation)) }
    }
  }
  rows
}

#let caption-row(r) = if r == none { sline(none) } else if "left" in r {
  sline(left: r.left, inl(r.text))
} else {
  sline(hang: caption-number,
    [#box(width: caption-number, if r.number != none [(#r.number)])#inl(r.text)])
}

#let caption-block(meta) = {
  let rows = caption-rows(meta)
  let n = rows.len()
  // The case number and legends sit about the middle of the party column, as in the exemplar: the case number on
  // row floor(n / 2) - 1, two blank rows, then the legends.
  let r0 = calc.max(0, calc.floor(n / 2) - 1)
  let right = range(r0).map(_ => none) + ([Case No. #meta.case_number], none, none)
  right += meta.at("legends", default: ()).map(l => strong(inl(l)))
  block(width: 100%, above: court-gap, below: 0pt, grid(
    columns: (caption-left, caption-paren, 1fr),
    { for r in rows { caption-row(r) } },
    { for _ in rows { sline([)]) } },
    { for r in right { sline(r) } },
  ))
}

#let cover(meta) = {
  for l in meta.court { sline(centered: true, strong(upper(l))) }
  caption-block(meta)
  sline(above: title-above, below: title-below, centered: true, strong(upper(inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, block quotations, lists
// ---------------------------------------------------------------------------

/// Level 1: centered bold capitals; level 2 bold; level 3 bold italic. Single-spaced, kept with the text after it.
#let heading-block(level, s) = block(width: 100%, above: heading-above, below: 0pt, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(s)))) }
  else if level == 2 { par(strong(inl(s))) }
  else { par(strong(emph(inl(s)))) }
})

/// A body paragraph on the body pitch, its first line indented; `label` (a number or letter) in a box after it.
#let body-par(label: none, sticky: false, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: 0pt, [#h(para-indent)#if label != none { box(width: number-width, label) }#c]))

/// Markdown body, chunk by chunk (blank-line separated). A chunk is a heading (`#`), a block quotation (`>`), a
/// list (`- `, the prayer items, lettered), a paragraph marked `<!--unnumbered-->` (the lead-in, continuation, the
/// WHEREFORE and the "For her ... Cause of Action" paragraphs, which the exemplar does not number), or a numbered
/// paragraph. The last chunk is kept with the signature block (a signature never stands alone on a page).
#let body(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let m = t.match(regex("^(#+) +([\\s\\S]*)$"))
      if m == none { panic("oked-complaint: a heading needs text: " + t) }
      heading-block(m.captures.at(0).len(), m.captures.at(1).trim())
    } else if t.starts-with(">") {
      // A block quotation is single-spaced (LCvR 5.2(a) excepts it), indented, not numbered, not split.
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      block(width: 100%, above: quote-gap, below: quote-gap, breakable: false, sticky: last,
        pad(left: quote-left, right: quote-right, sline(inl(q))))
    } else if t.starts-with("- ") {
      // A list (the prayer items): lettered (a), (b), ... as in the exemplar's prayers.
      let items = t.split(regex("(?m)^-[ \\t]+")).map(s => s.trim()).filter(s => s != "")
      for (k, it) in items.enumerate() {
        body-par(label: [(#("abcdefghijklmnopqrstuvwxyz".at(k))).], sticky: last and k == items.len() - 1, inl(it))
      }
    } else if t.starts-with("<!--unnumbered-->") {
      body-par(sticky: last, inl(t.slice("<!--unnumbered-->".len()).trim()))
    } else {
      n += 1
      body-par(label: [#n.], sticky: last, inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a): address, e-mail and telephone; the exemplar's layout)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  sline(left: sig-left, [Respectfully submitted,])
  for (i, s) in meta.signature.enumerate() {
    if i > 0 { sline(above: sig-gap, left: sig-left, [and]) }
    for (j, l) in s.firm.enumerate() { sline(above: if j == 0 { sig-gap } else { 0pt }, left: sig-left, strong(inl(l))) }
    sline(above: sig-gap, left: sig-left, inl("By: /s/ " + s.signer))
    for l in s.lines { sline(left: sig-left, inl(l)) }
  }
  if "attorneys_for" in meta { sline(above: sig-gap, left: sig-left, inl(meta.attorneys_for)) }
})

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let oked-complaint(meta, md) = {
  for k in ("court", "case_number", "caption", "title", "signature") {
    if k not in meta { panic("oked-complaint: missing required metadata field `" + k + "`") }
  }

  set page(
    paper: "us-letter",
    margin: page-margin,
    // The page number centered at the foot, 12 pt, in a single-pitch line box that ends footer-distance above the
    // page edge.
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set document(title: meta.title + ", No. " + meta.case_number, author: meta.signature.at(0).signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign or pilcrow kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)
  body(md)
  signature-block(meta)
}
