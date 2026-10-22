// Supreme Court of the State of Hawai'i (haw): reply brief.
//
// Content-agnostic. The parameters below are the ones HRAP 32(a) (8-1/2 x 11, not less than 1-inch margins;
// flyleaf with a 3-inch top margin, HAW-FLY-002) and HRAP 32(b) (12-point Times New Roman; footnotes and
// quotations in the same face and size; double spacing except headings, quotations, citations, indexes and
// footnotes, HAW-FORM-003..005) set; see ../../rules.md. HRAP 28(a) (a reply brief does not exceed 10 pages,
// HAW-BRIEF-002) is not machine-checked. No case-specific text, no coordinates measured off any filed brief,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample. The table of authorities is NOT generated (the exemplar carries one; see the report).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HAW-FORM-003: 12-point Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 12pt                    // HAW-FORM-003, HAW-FORM-004: body, quotations and footnotes at 12 pt.
#let body-leading = 1.65em               // HAW-FORM-005: double spacing for body text at 12 pt (about a 28 pt line pitch; the exemplar 27.6 pt).
#let single-leading = 0.45em             // HAW-FORM-005: single spacing (about 13.8 pt pitch) for headings, quotations, footnotes, captions and counsel blocks.
#let page-margin = 1in                   // HAW-FORM-001: not less than one inch on all sides.
#let flyleaf-top = 3in                   // HAW-FLY-002: the flyleaf has a 3-inch top margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                  // signature block starts right of centre, as the exemplar does.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #underline[/s/ #emph(sig.signer)] \
    #sig.signer
    #if "lines" in sig {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let haw-reply-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
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

  // Block quotations: indented, single-spaced, same face and size as the text (HAW-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: text size, single-spaced (HAW-FORM-004, HAW-FORM-005).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): 3-inch top margin, no page number ----
  page(margin: (top: flyleaf-top, left: page-margin, right: page-margin, bottom: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF HAWAI'I] \
      #v(0.3in)
      #text(weight: "bold")[Supreme Court No. #need(meta, "case_number")]
    ]
    #v(0.3in)
    #for (i, side) in need(meta, "caption").enumerate() {
      if i > 0 { align(center)[v.]; v(0.2in) }
      caption-side(side)
      v(0.2in)
    }
    #v(0.1in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 14pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
        if "phone" in meta [ #meta.phone ]
      })
    }
  ]

  // ---- Table of contents (roman page numbers) ----
  if meta.at("toc", default: true) {
    page(numbering: "i")[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Body (arabic page numbers from 1) ----
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the conclusion (HAW-SIG-001) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
