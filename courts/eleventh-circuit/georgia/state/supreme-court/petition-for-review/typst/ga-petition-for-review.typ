// Supreme Court of Georgia: petition for certiorari (Ga. Sup. Ct. R. 38-45).
//
// Rule-driven and content-agnostic. Requirement IDs (GA-SC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed petition, no forced
// line breaks. The markdown body is rendered by cmarker; metadata comes from the YAML
// frontmatter of the sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"      // GA-SC-FONT-001: Century family; substitute for Century Schoolbook (docs/FONTS.md)
#let type-size = 13pt                      // GA-SC-FONT-002: body and headings no smaller than 13-pt Century Schoolbook
#let note-size = 11pt                      // GA-SC-FONT-002: footnotes no smaller than 11-pt Century Schoolbook
#let body-leading = 0.78em                 // GA-SC-SPACE-001: line pitch of about 1.5 x type size (measured; between 1.2x and double)
#let single-leading = 0.5em                // single-spaced text (headings, quotations, footnotes, caption, counsel, signature, TOC): about 1.2x type size, the Rule 16(4) floor
#let body-gap = 0.6em                      // extra space between body paragraphs (style choice; not rule-mandated)
#let page-margin = 1in                     // GA-SC-MARGIN-001: at least one inch top, bottom and sides (Rule 16(5))
#let para-indent = 0.5in
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ga-petition-for-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ga-petition-for-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Cover page (Rule 16 applies; no page number on the cover)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set align(center)
  set par(leading: single-leading, spacing: single-leading)
  text(weight: "bold")[#need(meta, "case_number")]
  v(1.2em)
  block(text(weight: "bold")[IN THE])
  block(text(weight: "bold")[SUPREME COURT OF GEORGIA])
  v(1.5em)

  // Caption: names on the left, a column of close-parens, the docket on the right.
  let sides = need(meta, "caption")
  let left-col = []
  for (i, side) in sides.enumerate() {
    let block-content = {
      set align(left)
      for n in side.at("names") { block(width: 100%, inl(n)) }
      v(0.4em)
      align(right, inl(side.at("designation")))
    }
    left-col += block-content
    if i < sides.len() - 1 {
      left-col += v(1.2em)
      left-col += align(center, inl("v."))
      left-col += v(1.2em)
    }
  }
  let docket = need(meta, "docket")
  grid(
    columns: (1fr, auto, 1fr),
    column-gutter: 0.6em,
    align(left + horizon, left-col),
    align(horizon, [)]),
    align(left + horizon, {
      set align(left)
      for d in docket { block(width: 100%, inl(d)) }
    }),
  )
  v(1.5em)
  line(length: 100%, stroke: 0.7pt)
  v(0.9em)
  // Title and filer: the cover title is set in capitals and wraps naturally.
  text(weight: "bold")[#upper(need(meta, "title"))]
  if "filed_by" in meta {
    v(0.6em)
    inl(meta.at("filed_by"))
  }
  v(0.9em)
  line(length: 100%, stroke: 0.7pt)
  v(1.2em)

  // Counsel: groups side by side, as the exemplar sets them (not a rule-mandated layout).
  let counsel = need(meta, "counsel")
  set align(left)
  grid(
    columns: (1fr,) * calc.min(counsel.len(), 2),
    column-gutter: 1.2em,
    row-gutter: 1.0em,
    ..counsel.map(g => {
      set par(leading: single-leading, spacing: single-leading)
      for n in g.at("names") { block(width: 100%, inl(n)) }
      for l in g.at("lines") { block(width: 100%, inl(l)) }
    }),
  )
  v(1.2em)
  set align(center)
  text(weight: "bold")[#need(meta, "attorneys_for")]
}

// ---------------------------------------------------------------------------
// Questions presented (Rule 41(2): before the table of contents and the introduction)
// ---------------------------------------------------------------------------

#let questions-page(meta) = {
  align(center)[#text(weight: "bold")[QUESTIONS PRESENTED]]
  v(1.0em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt)
  let qs = need(meta, "questions_presented")
  for (i, q) in qs.enumerate() {
    block(inset: (left: 0.5in))[
      #h(-0.5in) #str(i + 1). #inl(q)
    ]
    v(body-leading)
  }
}

// ---------------------------------------------------------------------------
// Signature block (Rule 20(7): the word-count certification sits immediately above it)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  v(1.2em)
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(0.6em)
    This submission does not exceed the word-count limit imposed by Rule 20.
    #v(1.0em)
    #if "date" in meta [ #meta.at("date") #v(0.8em) ]
    Respectfully submitted,
    #v(1.0em)
    #block(width: 4.2in)[
      #set par(leading: single-leading, spacing: single-leading)
      #block(width: 100%)[/s/ #sig.at("signer")]
      #block(width: 100%)[#upper(sig.at("signer"))]
      #for l in sig.at("lines") { block(width: 100%, inl(l)) }
    ]
  ]
}

// ---------------------------------------------------------------------------
// Certificate of service (Rule 20(6): excluded from the count)
// ---------------------------------------------------------------------------

#let service-certificate(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, outlined: true, numbering: none)[Certificate of Service]
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent)
  inl(svc.at("statement"))
  v(0.8em)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  grid(
    columns: (1fr,) * calc.min(svc.at("served").len(), 2),
    column-gutter: 1.0em,
    row-gutter: 1.0em,
    ..svc.at("served").map(g => {
      for n in g.at("names") { block(width: 100%, inl(n)) }
      for l in g.at("lines") { block(width: 100%, inl(l)) }
    }),
  )
  if "note" in svc {
    v(0.8em)
    set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent)
    inl(svc.at("note"))
  }
  v(1.0em)
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(0.6em)
    #block[/s/ #need(meta, "signature").at("signer")]
    #block[#upper(need(meta, "signature").at("signer"))]
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ga-petition-for-review(meta, body) = {
  set document(title: upper(need(meta, "title")), author: "")
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: para-indent)

  // Headings: level 1 centered bold; level 2 bold; level 3 bold italic. Single-spaced, no indent.
  show heading: set text(size: type-size)
  show heading: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  show heading.where(level: 1): it => {
    v(0.9em)
    block(sticky: true, width: 100%, align(center, text(weight: "bold", it.body)))
    v(0.6em)
  }
  show heading.where(level: 2): it => {
    v(0.6em)
    block(sticky: true, text(weight: "bold", it.body))
    v(0.4em)
  }
  show heading.where(level: 3): it => {
    v(0.4em)
    block(sticky: true, text(weight: "bold", style: "italic", it.body))
    v(0.3em)
  }

  // Block quotations and footnotes are single-spaced; footnotes are 11-pt.
  show quote.where(block: true): it => {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    pad(left: 0.5in, right: 0.5in, bottom: body-leading, it.body)
  }
  // Rule 17(3): e-filed documents carry no hyperlinks to other documents or external sites.
  // A link keeps its text and loses its target; outline entries (internal) are unaffected.
  show link: it => it.body
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)

  // 1. Cover (no number). 2. Questions presented. 3. Table of contents and body, numbered from 1.
  cover(meta)
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  questions-page(meta)
  pagebreak()

  // Rule 21: every counted page is numbered in Arabic numerals, from the first page after the cover.
  // The cover is the only unnumbered page.
  [
    #align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
    #v(0.8em)
    #set par(first-line-indent: 0pt)
    #outline(title: none, depth: toc-depth, indent: 0pt)
  ]
  pagebreak()

  // Paragraph gap for the body only (cmarker paragraphs ignore par spacing).
  {
    show par: it => it + v(body-gap)
    cmarker.render(body, raw-typst: false, smart-punctuation: true)
  }
  signature(meta)
  pagebreak()
  service-certificate(meta)
}
