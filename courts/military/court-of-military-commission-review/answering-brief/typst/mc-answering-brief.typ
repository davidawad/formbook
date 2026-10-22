// Template for a brief of the appellee (the United States) before the United States Court of Military
// Commission Review (USCMCR). The layout values are named parameters below; the case content
// comes only from the sample's frontmatter and markdown body, never from this file.
// The rule basis is in ../../rules.md (MC-*) and ../README.md.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): this render is the
// reference the docx engine (../docx/mc.lua) breaks every line and page alike with. Every line is a box of its
// pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---- Court constants -------------------------------------------------------------------------
#let court-line = "IN THE UNITED STATES COURT OF MILITARY COMMISSION REVIEW"
#let honorable-line = "TO THE HONORABLE, THE JUDGES OF THE COURT OF MILITARY COMMISSION REVIEW"

// ---- Rule-driven layout ----------------------------------------------------------------------
// MC-FORM-001 (Rule 15(e)): "typed double-spaced in Times New Roman, 12 point"; vendored in /fonts.
#let body-font = ("Times New Roman", "Liberation Serif")
#let body-size = 12pt                  // body, footnotes, cover, certificates (Rule 15(e): 12 point)
#let h1-size = 17pt                    // section headings
#let h2-size = 14.5pt                  // argument headings
#let pitch-double = 27.6pt             // Rule 15(e) double spacing: twice Times New Roman's 13.8 pt single line
#let pitch-single = 13.8pt             // headings, cover, caption, contents, signature, certificates, footnotes
#let pitch-h1 = 19.6pt                 // a 17 pt line, single-spaced
#let pitch-h2 = 16.7pt                 // a 14.5 pt line, single-spaced
#let h1-space = 13.4pt                 // above and below a section heading
#let h2-space = 11.6pt                 // above and below an argument heading
#let h3-space = 7.2pt                  // above and below a sub-heading
#let margin = 1in                      // MC-FORM-003 (exemplars)
#let indent = 0.5in
#let toc-page-col = 36pt               // contents: the page numbers keep the last 36 pt of the line to themselves
#let toc-step = 18pt                   // contents: a level-2 entry steps in
#let cert-label = 18pt                 // certificate of compliance: the item number's box
#let type-volume-rule = "Rule 14(i)"   // word-limit rule cited by the filed exemplar's certificate (APP-1 form)
#let typeface-rule = "Rule 14(e)"      // typeface rule cited by the filed exemplar's certificate (APP-1 form)

// Markdown to content. An empty string renders as nothing.
#let md(s) = if s == "" { [] } else {
  cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
}

// Split the YAML frontmatter from the markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mc-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// 13879 -> "13,879"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

// Caption: two sides, one row per line, with the parenthesis column between them.
#let caption(sides) = {
  let rows = calc.max(sides.left.len(), sides.right.len())
  let cells = range(rows).map(i => (
    md(sides.left.at(i, default: "")),
    align(center, [)]),
    md(sides.right.at(i, default: "")),
  )).flatten()
  grid(columns: (3.1in, 0.3in, 3.1in), row-gutter: 6pt, align: left, ..cells)
}

// Counsel groups on the cover: names, then the italic lines under them; a group is never split.
#let counsel-block(groups) = for (i, g) in groups.enumerate() {
  block(above: if i == 0 { 24pt } else { 12pt }, below: 0pt, breakable: false, pad(left: 2.2in, {
    for n in g.names { block(md(n)) }
    for l in g.lines { block(emph(md(l))) }
  }))
}

// Signature block: "//s//" before the signer's typed name (the exemplar's form). With `closing`,
// it starts with the date and "Respectfully submitted,". It is one unbreakable block, so it never splits.
#let signature(meta, closing: false, above: 12pt) = block(breakable: false, width: 100%, above: above, below: 0pt,
  pad(left: 2.8in, {
    if closing {
      block([Dated: #meta.date])
      block(above: 18pt, [Respectfully submitted,])
    }
    block(above: if closing { 12pt } else { 0pt }, "//s// " + meta.signature.signer)
    for l in meta.signature.at("lines", default: ()) { block(emph(md(l))) }
  }))

// One contents row: level 1 at the margin, level 2 a step in; the page number in its own column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = if hd.level >= 2 { toc-step } else { 0pt }
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind, 0pt)
}

#let mc-brief(meta, body) = {
  set document(title: "CMCR " + meta.case_number + ", brief of the United States (appellee)")
  set page(paper: "us-letter", margin: margin, numbering: none, footer: none)
  set text(font: body-font, size: body-size, lang: "en", fallback: false)
  set par(first-line-indent: indent)
  // The cross-engine layout model: first fit, no kerning or ligatures, no hyphenation, line boxes of the body
  // pitch, footnote marks at 58 %.
  show: xengine.with(pitch: pitch-double, list-indent: indent)
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    // marker, a space, then the note (Word's footnote: the reference mark and a space)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: body-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // ---- Cover (unnumbered) ----
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", court-line))
    block(above: 24pt, below: 24pt, caption(meta.caption))
    align(center, text(weight: "bold", honorable-line))
    counsel-block(meta.counsel)
  }
  // The page number: centered in a single-spaced line box, 0.5 in from the foot of the page (Word's footer).
  // Every page after the cover is numbered, as the filed briefs number theirs (../opening-brief FILED-EXAMPLE: i on the
  // contents; no rule leaves it blank): the contents in roman from i, the body in arabic from 1 (DEF-COVER-001).
  set page(numbering: "i", footer-descent: 21.7pt,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  counter(page).update(1)

  // ---- Table of contents, generated from the headings (numbered i) ----
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    block(width: 100%, below: 12pt, align(center, text(weight: "bold", "TABLE OF CONTENTS")))
    show outline.entry: toc-entry
    outline(title: none, depth: 2, indent: 0pt)
  }

  // ---- Body (numbered from 1) ----
  set page(numbering: "1")   // a new page, numbered from 1
  counter(page).update(1)

  show heading: it => {
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    if it.level == 1 {
      block(width: 100%, sticky: true, above: h1-space, below: h1-space,
        align(center, text(size: h1-size, weight: "bold", ..edges(pitch-h1), it.body)))
    } else if it.level == 2 {
      block(width: 100%, sticky: true, above: h2-space, below: h2-space,
        text(size: h2-size, weight: "bold", ..edges(pitch-h2), it.body))
    } else {
      block(width: 100%, sticky: true, above: h3-space, below: h3-space,
        text(weight: "bold", ..edges(pitch-single), it.body))
    }
  }
  show quote.where(block: true): it => block(above: 12pt, below: 12pt, pad(x: indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: 12pt)
    it.body
  }))

  md(body)

  // ---- After the conclusion: signature, then the certificates ----
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  signature(meta, closing: true, above: 18pt)

  // Certificate of compliance: word count from the frontmatter, not counted here.
  pagebreak()
  heading(level: 1, outlined: true, "CERTIFICATE OF COMPLIANCE")
  let item(n, b) = block(above: 12pt, below: 0pt,
    par(hanging-indent: cert-label, { box(width: cert-label, [#n.]); b }))
  item(1, [This brief complies with the type-volume limitation of #type-volume-rule because it contains #group-digits(meta.word_count) words; and])
  item(2, [This brief complies with the typeface and style requirements of #typeface-rule because it has been prepared using #meta.compliance.typeface.])
  block(above: 24pt, [Dated: #meta.date])
  signature(meta)

  // Certificate of service.
  pagebreak()
  heading(level: 1, outlined: true, "CERTIFICATE OF SERVICE")
  block(meta.service.text)
  signature(meta)
}
