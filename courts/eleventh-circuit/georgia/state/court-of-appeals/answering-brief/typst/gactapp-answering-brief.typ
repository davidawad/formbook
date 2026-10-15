// Court of Appeals of Georgia (gactapp): answering-brief (see the doc-type name in the README).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule
// cited next to it (see ../README.md for the rule text status). No case-specific text,
// no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"     // Substitute for the face named in the rules (docs/FONTS.md). See README.md.
#let type-size = 14pt                      // Ga. Ct. App. R. 2(3): 14-point or larger serif (secondhand; see README.md).
#let body-leading = 1.1em                  // Double spacing at 14 pt: baseline pitch about 2.2 x type size. Checked by eye on the render.
#let single-leading = 0.45em               // Headings, block quotations, cover: single-spaced.
#let page-margin = 1in
#let para-indent = 0.5in
#let toc-depth = 2

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gactapp-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("gactapp-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #side.designation
  ]
}

/// Counsel group: names (bold) then the italic lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #emph(l) \ ]
  v(0.6em)
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let gactapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
  show heading.where(level: 1): it => block(above: 1.6em, below: 1.2em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // ---- Cover (no page number) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COURT OF APPEALS OF THE STATE OF GEORGIA] \
      #v(0.4in)
      #text(weight: "bold")[Case No. #need(meta, "case_number")]
    ]
    #v(0.5in)
    #caption-side(meta.caption.at(0))
    #v(0.3in)
    #align(center)[v.]
    #v(0.3in)
    #caption-side(meta.caption.at(1))
    #v(0.5in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #emph(need(meta, "proceeding"))
      #if "trial_court_case" in meta [ \ #emph("Trial court case no. " + meta.trial_court_case) ]
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(need(meta, "brief_title")))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      for g in need(meta, "counsel") { counsel-group(g) }
      if "phone" in meta [ #meta.phone ]
    }
  ]

  // ---- Table of contents ----
  page(numbering: "i")[
    #counter(page).update(1)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[TABLE OF CONTENTS])
    #v(0.5em)
    #outline(title: none, depth: toc-depth, indent: 1.5em)
  ]

  // ---- Body ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #if "date" in meta [ #meta.date \ ]
    #v(0.6em)
    #h(3.2in) /s/ #upper(need(meta, "signature").signer) \
    #for l in need(meta, "signature").lines [ #h(3.2in) #emph(l) \ ]
  ]
}
