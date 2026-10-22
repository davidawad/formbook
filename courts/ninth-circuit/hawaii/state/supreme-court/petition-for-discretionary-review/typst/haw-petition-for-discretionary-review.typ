// Supreme Court of the State of Hawaii (haw): petition for discretionary review, i.e. the application for transfer
// under HRS 602-58 and HRAP 40.2 (court-root exemplar, Davis v. Victorino, SCAP-22-0000368).
//
// Content-agnostic. The parameters below are the HRAP 32 form rules set (rules.md, HAW-FORM-001 to -006: letter
// paper, one-inch margins, 12 point Times New Roman, footnotes and quotations in the text face, double spacing, no
// condensing) and the flyleaf and signature rules (HAW-FLY-001, HAW-FLY-002, HAW-SIG-001). The HAW-PFR-001 limit
// (12 pages for an application for certiorari) is NOT applied: the transfer application's page rule is in HRAP 40.2,
// whose contents rules were not transcribed (rules.md: OPEN), so no page limit is set (eval.yaml absent).
// Headings, quotations and footnotes are single spaced; the body is double spaced.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample. The table of
// contents is NOT generated for this template unless the frontmatter asks for it (the exemplar has none).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // HAW-FORM-003, HAW-TYPE-001; Liberation Serif is the metric twin.
#let type-size = 12pt                   // HAW-FORM-003: 12 point; HAW-FORM-004: footnotes and quotations the same size.
#let body-leading = 1.61em              // HAW-FORM-005: double spacing (about 27.6 pt line pitch at 12 pt).
#let single-leading = 0.45em              // HAW-FORM-005: single spacing for headings, quotations, footnotes, caption and counsel blocks.
#let page-margin = 1in                  // HAW-FORM-001: not less than one inch all round.
#let cover-top = 3in                    // HAW-FLY-002: the flyleaf has a 3-inch top margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                 // HAW-SIG-001: the signature block sits right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-petition-for-discretionary-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-petition-for-discretionary-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Left column of the flyleaf caption: party names, then the party designation set to the right.
#let caption-left(sides) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for side in sides [
    #for n in side.names [ #block(inl(n)) ]
    #v(0.2em)
    #align(right, block(inl(side.designation)))
    #v(0.8em)
  ]
}

/// Right column of the flyleaf caption: the proceeding references, one entry per block; "" is a gap.
#let caption-right(lines) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for l in lines [
    #if l == "" { v(0.8em) } else { block(inl(l)) }
  ]
}

/// Counsel block at the foot of the flyleaf (HAW-FLY-001: names, telephone, e-mail, bar number).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #block(strong(inl(n))) ]
  for l in g.lines [ #block(inl(l)) ]
  v(0.6em)
}

/// Signature block (HAW-SIG-001): the signing attorney's signature line, the typed name, then the firm and role.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "lead" in sig [ #block(inl(sig.lead)) #v(0.8em) ]
    #block(inl(sig.sign))
    #block(inl(sig.name))
    #v(0.8em)
    #for l in sig.lines [ #block(inl(l)) ]
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let haw-petition-for-discretionary-review(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body (HAW-FORM-005: headings single spaced). Level 1 is a section ("I. PRIOR PROCEEDINGS"),
  // level 2 a sub-heading ("A. ..."), level 3 a sub-sub-heading; all bold, left, with a hanging indent.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations (HAW-FORM-004: same face and size as the text): indented both sides, single spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes (HAW-FORM-004): body size, single spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002) ----
  page(numbering: none)[
    #v(cover-top - page-margin)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #block(width: 100%, need(meta, "case_number"))
    #v(0.4in)
    #align(center, text(weight: "bold", need(meta, "court_title")))
    #v(0.4in)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      caption-left(need(meta, "caption")),
      caption-right(need(meta, "caption_right")),
    )
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents (only when the frontmatter asks for one) ----
  if meta.at("toc", default: false) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Body: the first numbered page is the page after the flyleaf ----
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the conclusion ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
