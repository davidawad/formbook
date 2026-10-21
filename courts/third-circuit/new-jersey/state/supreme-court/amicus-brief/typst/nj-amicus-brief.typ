// Supreme Court of New Jersey (nj): amicus curiae letter brief under R. 2:6-2(b).
//
// Content-agnostic. Every number is a named constant below and traces to rules.md (NJ-* ids): the letter form
// of R. 2:6-2(b) carries the R. 2:6-6 information in its heading, so there is no separate cover page.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks. The markdown body
// is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

// NJ-FORM-003: Times New Roman or a similar face. The filed exemplar is set in Times New Roman.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt                      // NJ-FORM-003: 14 pt, stricter than the 12-point minimum (see OPEN in rules.md).
#let note-size = 12pt                      // footnotes: 12 pt, the minimum type size (courtcaddy R. 2:6-10 text); the sibling PA sample uses 12 pt too.
#let letterhead-size = 12pt                // letterhead and address lines (not the brief text).
#let margin = 1in                          // NJ-FORM-004: approximately one inch.
#let indent = 0.5in                        // first-line indent of paragraphs.
// Measured on the render (14 pt Liberation Serif, typst 0.15): a leading of 1.6 em gives a 32 pt pitch (double),
// 0.46 em a 16 pt pitch (single; footnotes, block quotations, headings, letter address lines).
#let leading-double = 1.6em                // NJ-FORM-002: double-spaced text.
#let leading-single = 0.46em               // NJ-FORM-002: footnotes and indented quotations may be single-spaced.
#let leading-tight = 0.5em                 // table of contents entries.
#let sig-indent = 3.2in                    // signature block starts right of centre (as the exemplar).

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-address = (
  "Honorable Chief Justice and Associate Justices",
  "Supreme Court of New Jersey",
  "25 Market Street",
  "Trenton, New Jersey 08625",
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nj-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nj-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// Page number in the bottom margin; none on a page that has no folio.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// ---- Letter heading (R. 2:6-2(b); R. 2:6-6(a) information in the heading) -----------------------
#let letterhead(meta) = {
  let lh = need(meta, "letterhead")
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  set text(size: letterhead-size)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    align(left)[#for l in lh.left [ #inl(l) \ ]],
    align(right)[#for l in lh.right [ #inl(l) \ ]],
  )
}

#let letter-address(meta) = {
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  v(1.4em)
  inl(need(meta, "date"))
  v(1.2em)
  for l in court-address [ #l \ ]
  v(0.8em)
  block(width: 100%, pad(left: indent, grid(
    columns: (0.5in, 1fr),
    [Re:],
    [#for l in need(meta, "re") [ #strong(inl(l)) \ ]],
  )))
  v(0.8em)
}

// ---- Table of contents (roman numerals; the letter page and this list share page i) ----------------
#let contents() = {
  v(0.8em)
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(0.4em)
  show outline.entry: it => block(above: 0.6em, below: 0.6em, it)
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  outline(title: none, depth: 2, indent: 0.5in)
}

// ---- Closing: signature block -------------------------------------------------------------------
#let signature-block(meta) = block(width: 100%, breakable: false, pad(left: sig-indent)[
  #set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  #for g in need(meta, "signature") [
    #for l in g.lines [ #inl(l) \ ]
    #v(1.1em)
  ]
])

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nj-amicus-brief(meta, body) = {
  set document(title: need(meta, "document_title"))
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: body-size, lang: "en", hyphenate: false)
  set par(leading: leading-double, spacing: leading-double, first-line-indent: indent, justify: false)

  // Heading levels in the markdown body: level 1 is a section (centred, bold, capitals as printed);
  // levels 2-4 are numbered points and sub-points (bold, hanging), numbered by the template.
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 2 { numbering("I.", n.last()) }
    else if n.len() == 3 { numbering("A.", n.last()) }
    else if n.len() == 4 { numbering("1.", n.last()) }
    else { "" }
  })
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: body-size)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    #align(center, text(weight: "bold", it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: body-size)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold")[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(0.5in)#it.body]
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: body-size)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold")[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(0.5in)#it.body]
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: body-size)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(style: "italic")[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(0.5in)#it.body]
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 1in, right: 1in), above: 0.8em, below: 1.2em)[
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: single spaced.
  show footnote.entry: it => {
    set text(size: note-size)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    it
  }

  // ---- Page i: letter heading, salutation and opening paragraph, then the table of contents ----
  set page(numbering: "i", footer: folio)
  counter(page).update(1)
  letterhead(meta)
  letter-address(meta)
  par(first-line-indent: 0pt)[Honorable Chief Justice and Associate Justices:]
  v(0.2em)
  inl(need(meta, "intro"))
  contents()

  // ---- Body (Arabic numerals from the first page of the brief, as the exemplar) ----
  pagebreak()
  set page(numbering: "1", footer: folio)
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // ---- Closing: signature block (letter form: no date line, no certificate) ----
  v(0.6em)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: 0pt)[Respectfully submitted,]
    #v(0.4em)
    #signature-block(meta)
  ]
}
