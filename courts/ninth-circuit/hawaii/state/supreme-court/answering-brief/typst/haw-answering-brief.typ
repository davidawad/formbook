// Supreme Court of the State of Hawai'i (haw): answering brief.
//
// Content-agnostic. The parameters below are the ones HRAP 32 (font, spacing, margins, flyleaf) and
// HRAP 28 (brief form, sections) set; see ../../rules.md. Row IDs are cited where each setting is made.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
// The table of authorities is NOT generated (HRAP 28(b)(1) requires one for the opening brief; the
// answering-brief section order is taken from the exemplar, see HAW-BRIEF-008 in ../../rules.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HAW-FORM-003: 12 pt Times New Roman is deemed to satisfy HRAP 32(b). Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 12pt                    // HAW-FORM-003: standard 12 point pica.
#let body-leading = 1.35em               // HAW-FORM-005: double spacing at 12 pt (about 24 pt line pitch; the exemplar body sets 21 to 26 pt).
#let single-leading = 0.45em             // HAW-FORM-005: single spacing (about 13.8 pt) for headings, quotations, citations and footnotes.
#let page-margin = 1in                   // HAW-FORM-001: 8-1/2 x 11 inches with not less than 1-inch margins all around.
#let flyleaf-top = 3in                   // HAW-FLY-002: 3-inch top margin on the flyleaf.
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
  if m == none { panic("haw-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath (HAW-FLY-001).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signature (HAW-SIG-001): signed in ink, the name typed or printed beneath.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    /s/ #sig.signer \
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

#let haw-answering-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left, hanging). Headings are single-spaced (HAW-FORM-005).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented both sides, single-spaced, same size as the text (HAW-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.6em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same font and size as the text, single-spaced (HAW-FORM-004, HAW-FORM-005).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): 3-inch top margin, one page, no page number ----
  page(margin: (top: flyleaf-top, rest: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[#need(meta, "case_number")] \
      #v(0.25in)
      #text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF HAWAI'I] \
      #if "lower_court" in meta [ #v(0.15in) #for l in meta.lower_court [ #inl(l) \ ] ]
    ]
    #v(0.2in)
    #caption-side(need(meta, "caption").at(0))
    #if "consolidated" in meta [ #v(0.2in) #align(center, inl(meta.consolidated)) ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      for g in need(meta, "counsel") { counsel-group(g) }
    }
  ]

  // ---- Table of contents ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Body ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the conclusion (HAW-SIG-001) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), [DATED: #inl(meta.date).]) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
  // Notation at the bottom of the signature page: case number, case name and title (HAW-SIG-001).
  if "notation" in meta {
    place(bottom + left, block(width: 100%, par(leading: single-leading, first-line-indent: 0pt, text(size: type-size, meta.notation))))
  }
}
