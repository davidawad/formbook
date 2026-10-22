// Supreme Court of the State of Hawai‘i (haw): brief on the merits (petitioner's supplemental merits brief).
//
// There is no separate brief-on-the-merits rule in the HRAP. The rule basis here is HRAP 28 (briefs,
// by analogy) and HRAP 32 (form), see ../../rules.md. OPEN: the court's own rule for supplemental
// merits briefing after certiorari (HAW-BRIEF-*, HAW-FORM-*, HAW-FLY-*, HAW-SIG-*) is taken by analogy.
//
// The parameters below are the ones HRAP 32(a) (flyleaf: 3-inch top margin, HAW-FLY-002; 1-inch
// margins, HAW-FORM-001), HRAP 32(b) (12-point Times New Roman, HAW-FORM-003; footnotes and quotations
// in the text font and size, HAW-FORM-004; double spacing with headings, quotations and footnotes
// single spaced, HAW-FORM-005) and HRAP 32(c) (signature, HAW-SIG-001) set. No case-specific text,
// no coordinates measured off any filed brief, no forced line breaks. The markdown body is rendered
// by cmarker; the metadata is the YAML frontmatter of the sample. The table of authorities is NOT
// generated yet (OPEN: HAW-BRIEF-003 requires a table of authorities in the opening brief).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HAW-FORM-003, HAW-TYPE-001; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 12pt                    // HAW-FORM-003: twelve point; HAW-FORM-004: footnotes and quotations the same size.
#let body-leading = 1.15em               // HAW-FORM-005: double spaced (27.6 pt pitch at 12 pt, the Times New Roman line is 1.15 em).
#let single-leading = 0.6em                // headings, block quotations, footnotes, captions and counsel blocks (13.8 pt pitch).
#let page-margin = 1in                   // HAW-FORM-001: not less than one inch all round.
#let flyleaf-top = 3in                   // HAW-FLY-002: 3-inch top margin on the flyleaf.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                  // signature block starts right of centre, as the filed exemplars do.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-brief-on-the-merits: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-brief-on-the-merits: missing required metadata field `" + key + "`") }
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

#let brief-on-the-merits(meta, body) = {
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

  // Block quotations: indented, single-spaced, same font and size as the text (HAW-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: body size, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): 3-inch top margin, no page number ----
  page(margin: (top: flyleaf-top, rest: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[NO. #need(meta, "case_number")] \
      #v(0.3in)
      #text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF HAWAI‘I]
      #if "trial_case_number" in meta [ \ #meta.trial_case_number ]
    ]
    #v(0.3in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
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
        if "phone" in meta [ #meta.phone ]
      })
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
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
