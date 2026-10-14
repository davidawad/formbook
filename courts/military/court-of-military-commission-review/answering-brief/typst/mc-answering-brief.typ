// Template for a brief of the appellee (the United States) before the United States Court of Military
// Commission Review (USCMCR). The layout values are named parameters below; the case content
// comes only from the sample's frontmatter and markdown body, never from this file.
// The rule basis and what is still unverified are in ../README.md.
#import "@preview/cmarker:0.1.10"

// ---- Court constants -------------------------------------------------------------------------
#let court-line = "IN THE UNITED STATES COURT OF MILITARY COMMISSION REVIEW"
#let honorable-line = "TO THE HONORABLE, THE JUDGES OF THE COURT OF MILITARY COMMISSION REVIEW"

// ---- Rule-driven layout (UNVERIFIED against the current Rules of Practice; see README.md) ----
// Only EB Garamond is vendored. The filed exemplars use Times New Roman, and their certificates
// also cite a monospaced 12-cpi option; neither face is vendored, so EB Garamond stands in.
#let body-font = "EB Garamond"
#let body-size = 12pt
#let body-leading = 0.95em    // double-spaced body text
#let single-leading = 0.5em   // block quotations, headings, captions, cover, signature, certificates
#let margin = 1in
#let indent = 0.5in
#let type-volume-rule = "Rule 14(i)"   // word-limit rule cited by the filed exemplar's certificate
#let typeface-rule = "Rule 14(e)"      // typeface rule cited by the filed exemplar's certificate

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

// Caption: two sides, one row per line, with the parenthesis column between them.
#let caption(sides) = {
  let rows = calc.max(sides.left.len(), sides.right.len())
  let cells = range(rows).map(i => (
    align(left, md(sides.left.at(i, default: ""))),
    align(center, [)]),
    align(left, md(sides.right.at(i, default: ""))),
  )).flatten()
  grid(
    columns: (3.1in, 0.3in, 3.1in),
    row-gutter: single-leading,
    align: left,
    ..cells,
  )
}

// Counsel groups on the cover: names, then the italic lines under them.
#let counsel-block(groups) = for g in groups {
  pad(left: 2.2in, block(breakable: false, stack(
    dir: ttb,
    spacing: single-leading,
    ..g.names.map(n => md(n)),
    ..g.lines.map(l => emph(md(l))),
  )))
  v(1em)
}

// Signature block: "//s//" before the signer's typed name (the exemplar's form). With `closing`,
// it starts with "Respectfully submitted,". It is one unbreakable block, so it never splits.
#let signature(meta, closing: false) = block(breakable: false, width: 100%, {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
  pad(left: 2.8in, stack(
    dir: ttb,
    spacing: single-leading,
    ..if closing { ([Dated: #meta.date], v(1.5em), [Respectfully submitted,], v(1em)) } else { () },
    "//s// " + meta.signature.signer,
    ..meta.signature.at("lines", default: ()).map(l => emph(md(l))),
  ))
})

#let mc-brief(meta, body) = {
  set document(title: "CMCR " + meta.case_number + ", brief of the United States (appellee)")
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: body-font, size: body-size, lang: "en", hyphenate: false)

  // ---- Cover (unnumbered) ----
  block(width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    align(center, text(weight: "bold", court-line))
    v(2em)
    caption(meta.caption)
    v(2em)
    align(center, text(weight: "bold", honorable-line))
    v(2em)
    counsel-block(meta.counsel)
  })
  pagebreak()

  // ---- Table of contents, generated from the headings (unnumbered page) ----
  set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(1em)
  outline(title: none, depth: 2, indent: 1.5em)
  pagebreak()

  // ---- Body (numbered from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  set par(justify: false, leading: body-leading, first-line-indent: indent, spacing: body-leading)

  show heading.where(level: 1): it => {
    v(0.8em)
    block(width: 100%, sticky: true, {
      set par(first-line-indent: 0pt, leading: single-leading)
      align(center, text(weight: "bold", it.body))
    })
    v(0.8em)
  }
  show heading.where(level: 2): it => {
    v(0.8em)
    block(width: 100%, sticky: true, {
      set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: indent)
      text(weight: "bold", it.body)
    })
    v(0.8em)
  }
  show heading.where(level: 3): it => {
    v(0.6em)
    block(width: 100%, sticky: true, {
      set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: indent)
      text(weight: "bold", it.body)
    })
    v(0.6em)
  }
  show quote.where(block: true): it => pad(x: indent, block(width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em)
    it.body
  }))
  show footnote.entry: set text(size: 11pt)

  md(body)

  // ---- After the conclusion: signature, then the certificates ----
  v(1.5em)
  signature(meta, closing: true)

  // Certificate of compliance: word count from the frontmatter, not counted here.
  pagebreak()
  heading(level: 1, outlined: true, "CERTIFICATE OF COMPLIANCE")
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em)
  [1. This brief complies with the type-volume limitation of #type-volume-rule because it contains #meta.word_count words; and]
  [2. This brief complies with the typeface and style requirements of #typeface-rule because it has been prepared using #meta.compliance.typeface.]
  v(1em)
  [Dated: #meta.date]
  signature(meta)

  // Certificate of service.
  pagebreak()
  heading(level: 1, outlined: true, "CERTIFICATE OF SERVICE")
  [#meta.service.text]
  signature(meta)
}
