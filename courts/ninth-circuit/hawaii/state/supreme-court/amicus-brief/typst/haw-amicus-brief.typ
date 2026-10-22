// Supreme Court of the State of Hawaii (haw): amicus curiae brief.
//
// Content-agnostic. The parameters below come from the one FILED-EXAMPLE in ../usage/ (12-point
// Times New Roman, double-spaced, one-inch margins); the HRAP 32 values are set in ../../rules.md
// (HAW-FORM-001 to -006, HAW-FLY-001/002, HAW-SIG-001, HAW-AMIC-001). No case-specific text, no
// coordinates measured off any filed brief, no forced line breaks. The markdown body is rendered
// by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HAW-FORM-003, HAW-TYPE-001: Times New Roman 12 pt; Liberation Serif is its metric twin.
#let type-size = 12pt                    // HAW-FORM-003, HAW-FORM-004: footnotes and quotations in the same size as the text.
#let body-leading = 1.6em                // HAW-FORM-005: double spaced (27.6 pt line pitch as filed; paragraphs run on with a first-line indent).
#let single-leading = 0.46em             // headings, block quotations, footnotes, captions and counsel blocks (13.8 pt pitch as filed).
#let page-margin = 1in                   // HAW-FORM-001: not less than one-inch margins all around.
#let flyleaf-top = 3in                   // HAW-FLY-002: 3-inch top margin on the flyleaf.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                  // signature block starts right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-amicus-brief: missing required metadata field `" + key + "`") }
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

/// Signature block (HAW-SIG-001): signed in ink by the attorney, name typed beneath, then the
/// attorney's firm and the designation as attorneys for the amici.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "lead" in sig [ #sig.lead #v(0.8em) ]
    #underline[/s/ #sig.signer] \
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

#let haw-amicus-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 to 4 are sub-headings (bold, left, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
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
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented both sides, single-spaced, same size as the text (HAW-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: body size, single-spaced (HAW-FORM-004).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): 3-inch top margin, no page number ----
  page(margin: (top: flyleaf-top, rest: page-margin))[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[#need(meta, "case_number")] \
      #v(0.2in)
      #text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF HAWAIʻI]
    ]
    #v(0.2in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.1in)
    #align(center)[v.]
    #v(0.1in)
    #caption-side(need(meta, "caption").at(1))
    #v(0.2in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #for l in need(meta, "lower_court") [ #inl(l) \ ]
      #if "proceeding" in meta { v(0.2in); inl(meta.proceeding) }
    ]
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 12pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(0.2in)
    // Counsel blocks side by side, as the flyleaf lays them out (HAW-FLY-001).
    #block(width: 100%, breakable: false, grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      ..need(meta, "counsel").map(g => counsel-group(g)),
    ))
  ]

  // ---- Table of contents (generated from the headings) ----
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
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
