// Motion with brief for the U.S. District Court for the Eastern District of Oklahoma (oked).
// Rules: LCvR 7.1(b) (a brief may be combined with the motion if the title says so), LCvR 7.1(c)
// (briefs over 15 pages need an indexed table of contents and table of authorities, and the form of
// LCvR 5.2(a)), LCvR 5.2(a) (paper, 12-point print style including footnotes, 1-inch margins, line
// spacing of at least 1.5 except blocked quotations and footnotes). Fed. R. Civ. P. 7(b) and 10(a).
// See ../README.md for each choice and its source.
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
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-width = 0.5in               // a numbered paragraph's number sits in a half-inch box after the indent
#let caption-box-width = 3.5in          // the party box, as in the exemplar caption
#let caption-gutter = 0.3in             // between the party box and the case number
#let caption-inset-x = 0.1in            // the party box's text stands this far from its left and right rules
#let caption-inset-y = 0.12in           // and this far from its top and bottom rules
#let caption-rule = 0.75pt
#let caption-versus = 1.1in             // "v." this far into the party box
#let caption-designation = 1.9in        // a party's designation this far into the party box
#let heading-tab = 0.5in                // label column of level 2 and 3 headings
#let quote-left = 1in                   // block quotations: indented 1 in on the left
#let quote-right = 0.5in                // and 0.5 in on the right
#let sig-left = 3in                     // the date in a 3 in column, the signature after it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/oked.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // LCvR 5.2(a): at least 1.5 spacing; the body is double spaced, two 12 pt lines
#let pitch-single = 13.8pt              // caption, headings, block quotations, signature block and footnotes (LCvR 5.2(a) excepts quotations and footnotes)
#let note-gap = 6pt                     // between two footnotes
#let note-clearance = 8.5pt            // the body text to the footnote rule: with note-gap, the 14.5 pt LibreOffice keeps above a note (akd)
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
  if m == none { panic("oked-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Markdown to inline typst content (case names in italics, footnote references).
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
// Cover: court name, boxed caption with the case number and judge, title (LCvR 7.1(b))
// ---------------------------------------------------------------------------

/// The party box: each party's names one line at a time, the designation indented in italics, "v." between the
/// sides with a blank line above and below it.
#let caption-box(meta) = {
  let side(parties) = for p in parties {
    for l in p.names { sline(inl(l)) }
    if "designation" in p { sline(left: caption-designation, emph(inl(p.designation))) }
  }
  block(width: 100%, stroke: caption-rule, inset: (x: caption-inset-x, y: caption-inset-y), {
    side(meta.caption.plaintiffs)
    sline(none)
    sline(left: caption-versus, [v.])
    sline(none)
    side(meta.caption.defendants)
  })
}

#let cover(meta) = {
  for l in meta.court { sline(centered: true, strong(upper(inl(l)))) }
  block(width: 100%, above: court-gap, below: 0pt, grid(
    columns: (caption-box-width, caption-gutter, 1fr),
    caption-box(meta),
    [],
    pad(top: caption-inset-y, {
      // The case number and the judge on the third and fourth lines of the box, as in the exemplar.
      sline(none)
      sline(none)
      sline([Case No. #meta.case_number])
      if "judge" in meta { sline(inl(meta.judge)) }
    }),
  ))
  sline(above: title-above, below: title-below, centered: true, strong(upper(inl(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Headings and body
// ---------------------------------------------------------------------------

/// Level 1: centered bold capitals. Level 2: "I." with a hanging label. Level 3: "A." in the same way, a tab further
/// in. Single-spaced, kept with the text after it. The labels are counted here, not in the text, so the sample types
/// no numbers.
#let heading-block(level, label, c) = block(width: 100%, above: heading-above, below: 0pt, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 {
    align(center, strong(upper(c)))
  } else {
    let left = if level == 2 { 0pt } else { heading-tab }
    pad(left: left, par(hanging-indent: heading-tab, [#box(width: heading-tab, label)#strong(c)]))
  }
})

/// A body paragraph on the body pitch, its first line indented; `label` (a number) in a box after the indent.
#let body-par(label: none, sticky: false, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: 0pt, [#h(para-indent)#if label != none { box(width: number-width, label) }#c]))

/// The chunks of a markdown body (blank-line separated), without the footnote definitions.
#let chunks-of(md) = {
  md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and not c.starts-with(regex("\\[\\^[^\\]]+\\]:")))
}

/// Markdown body, chunk by chunk. A chunk is a heading (`#`, `##`, `###`), a block quotation (`>`), a numbered
/// paragraph (marked `<!--numbered-->`, as the facts are in the exemplar), or a paragraph. Argument paragraphs are
/// not numbered (the exemplar does not number them). Each chunk is rendered alone with the definitions of the
/// footnotes it refers to (`notes`). `keep-last`: the last chunk is kept with the block after it (the signature).
#let body(chunks, notes, keep-last: false, counters: (0, 0, 0)) = {
  let (n, h2, h3) = counters
  for (i, t) in chunks.enumerate() {
    let last = keep-last and i == chunks.len() - 1
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    if t.starts-with("#") {
      let m = t.match(regex("^(#+) +([\\s\\S]*)$"))
      if m == none { panic("oked-motion-brief: a heading needs text: " + t) }
      let level = m.captures.at(0).len()
      let c = inl(m.captures.at(1).trim() + defs)
      if level == 2 {
        h2 += 1
        h3 = 0
        heading-block(2, numbering("I.", h2), c)
      } else if level >= 3 {
        h3 += 1
        heading-block(3, numbering("A.", h3), c)
      } else {
        heading-block(1, none, c)
      }
    } else if t.starts-with(">") {
      // single-spaced (LCvR 5.2(a) excepts blocked quotations), indented, not numbered, not split
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      block(width: 100%, above: quote-gap, below: quote-gap, breakable: false, sticky: last,
        pad(left: quote-left, right: quote-right, sline(inl(q + defs))))
    } else if t.starts-with("<!--numbered-->") {
      n += 1
      body-par(label: [#n.], sticky: last, inl(t.slice("<!--numbered-->".len()).trim() + defs))
    } else {
      body-par(sticky: last, inl(t + defs))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block: the date on the left, the signature on the right (exemplar layout); kept on one page
// ---------------------------------------------------------------------------

#let signature-block(sig, date: none, attorneys: none) = block(width: 100%, above: sig-above, below: 0pt,
  breakable: false, {
    sline(hang: sig-left, [#box(width: sig-left, if date != none [Date: #inl(date)])Respectfully submitted,])
    sline(above: sig-gap, left: sig-left, inl("/s/ " + sig.signer))
    for l in sig.lines { sline(left: sig-left, inl(l)) }
    if attorneys != none { sline(above: sig-gap, left: sig-left, inl(attorneys)) }
  })

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let oked-motion-brief(meta, md) = {
  for k in ("court", "case_number", "caption", "brief_title", "signature") {
    if k not in meta { panic("oked-motion-brief: missing required metadata field `" + k + "`") }
  }

  set page(
    paper: "us-letter",
    margin: page-margin,
    // The page number centered at the foot, 12 pt, in a single-pitch line box that ends footer-distance above the
    // page edge.
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set document(title: meta.brief_title + ", No. " + meta.case_number, author: meta.signature.signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign or pilcrow kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes at 12 pt (LCvR 5.2(a): footnotes included) in single lines, the mark, a space, the text (docx:
  // Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt) // the entry does not inherit the body's leading 0
    [#super(num) #note.body]
  }

  cover(meta)

  // Footnote text is kept apart from the chunks: each chunk is rendered alone with the definitions it refers to.
  let notes = (:)
  for m in md.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) { notes.insert(m.captures.at(0), m.captures.at(1)) }

  // The body up to the certificate of service, then the signature, then the certificate on its own page. The last
  // paragraph (and a heading before it, which is sticky) is kept on the page with the signature block.
  let parts = md.split(regex("\\r?\\n# CERTIFICATE OF SERVICE[ \\t]*\\r?\\n"))
  body(chunks-of(parts.at(0)), notes, keep-last: true)
  signature-block(meta.signature, date: meta.at("date", default: none), attorneys: meta.at("attorneys_for", default: none))

  if parts.len() > 1 {
    pagebreak()
    sline(below: title-below, centered: true, strong(upper("Certificate of Service")))
    let cert = "certificate" in meta
    body(chunks-of(parts.at(1)), notes, keep-last: cert)
    if cert {
      signature-block(meta.certificate, attorneys: meta.certificate.at("attorneys_for", default: none))
    }
  }
}
