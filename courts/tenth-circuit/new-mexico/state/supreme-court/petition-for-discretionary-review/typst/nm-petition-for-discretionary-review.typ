// New Mexico Supreme Court (nm): petition for writ of certiorari (petition-for-discretionary-review). The same template serves the
// other doc types of this court; only the header comment and the panic names differ.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited
// next to it (NMRA 12-305, read from the NM Supreme Court's Proposal 2025-031; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman is the standard face (docs/FONTS.md); Liberation Serif is its metric-compatible substitute.
#let type-size = 14pt                      // NMRA 12-305(D)(1): proportionally spaced type 14-point or larger, footnotes included.
#let caption-size = 14pt                   // NMRA 12-305(D)(1): the cover may use 11-point only if needed to fit; this template keeps 14-point.
#let body-leading = 1.65em                 // NMRA 12-305(E): double-spaced text (about 2 x the single line of this face at 14 pt).
#let single-leading = 0.45em               // NMRA 12-305(E): quotations, headings and footnotes may be single-spaced.
#let cover-leading = 0.45em                // cover caption lines, single-spaced (NMRA 12-305(E)).
#let top-margin = 1in                      // NMRA 12-305(B)(2): one inch on all sides.
#let side-margin = 1in                     // NMRA 12-305(B)(2): one inch left and right.
#let bottom-margin = 1in                   // NMRA 12-305(B)(2): one inch at the bottom; page numbers sit in this margin (NMRA 12-305(B)(3)).
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre.
#let court-name = "SUPREME COURT OF THE STATE OF NEW MEXICO" // NMRA 12-305(F)(1)(a): name of the appellate court.
#let docket-width = 2.2in                  // right column of the cover: docket number (NMRA 12-305(F)(1)(c)).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nm-petition-for-discretionary-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nm-petition-for-discretionary-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Signature block (NMRA 12-305(B)(5): name, address and telephone of counsel; NMRA 12-302(A)).
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)]
    #for l in sig.at("lines", default: ()) [ #linebreak() #inl(l) ]
    #if "role" in sig [ #linebreak() #strong(sig.role) ]
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of
// the authority in the body. A show rule on that string drops a marker after each occurrence;
// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<nm-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<nm-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        // Word joiners hold the page reference to the leaders, so it never wraps alone (DEF-TOC-001).
        #inl(e.cite)#h(0.3em)#box(width: 1fr, repeat[.#h(2pt)])#sym.wj#h(4pt)#sym.wj#box(if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (NMRA 12-305(F) caption, (G) cover contents)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: cover-leading, first-line-indent: 0pt, spacing: 0.5em)
  set text(size: caption-size)
  align(center, text(weight: "bold", court-name))
  v(0.8em)
  grid(
    columns: (1fr, docket-width),
    column-gutter: 0.3in,
    [
      #for p in need(meta, "parties") {
        if "designation" in p [ #emph(inl(p.designation)) \ ]
        if "names" in p {
          for n in p.names [ #inl(n) \ ]
        }
        v(0.4em)
      }
    ],
    [
      #if "case_number" in meta [ No. #inl(meta.case_number) ]
    ],
  )
  v(0.8em)
  // Free lines under the caption (appeal line, oral-argument request; NMRA 12-305(G)(4)).
  if "cover_lines" in meta {
    for l in meta.cover_lines [ #align(center, inl(l)) \ ]
    v(0.8em)
  }
  // County or administrative body and trial judge (NMRA 12-305(G)(1)-(2)); omitted for 12-502 briefs.
  if "lower_court" in meta {
    for l in meta.lower_court [ #inl(l) \ ]
    v(0.8em)
  }
  // Counsel groups in two columns so the cover stays on one page (NMRA 12-305(G)(3)).
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    row-gutter: 0.6em,
    ..for c in need(meta, "counsel") {
      (block(breakable: false, [
        #set par(leading: cover-leading, first-line-indent: 0pt)
        #if "heading" in c [ #emph(inl(c.heading)) \ ]
        #for l in c.lines [ #inl(l) \ ]
      ]),)
    }
  )
  line(length: 100%, stroke: 0.75pt)
  align(center, block(above: 0.8em, below: 0.8em)[
    #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
  ])
  line(length: 100%, stroke: 0.75pt)
}

// Certificate of compliance (NMRA 12-318(F)): the attorney certifies the type-volume and size limits.
// The statement and signature come from the frontmatter (compliance.statement, compliance.signature).
#let compliance-page(meta) = {
  heading(level: 1)[#meta.compliance.at("title", default: "Certificate of Compliance with Rule 12-318(F), NMRA")]
  par(first-line-indent: (amount: para-indent, all: true), inl(meta.compliance.statement))
  v(0.4em)
  if "signature" in meta.compliance { signature-block(meta.compliance.signature) }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nm-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Pages: the cover is unnumbered, the tables are roman, the body is arabic from 1.
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    numbering: none,
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 is a point heading (bold, left); level 3 is a sub-point (bold italic, left).
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

  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (NMRA 12-305(E)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (NMRA 12-305(D)(1)), single-spaced (NMRA 12-305(E)).
  show footnote.entry: it => {
    set text(size: type-size, bottom-edge: -3pt)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (unnumbered) ----
  page[#cover(meta)]

  // ---- Table of contents and table of authorities (roman numerals) ----
  if meta.at("toc", default: true) {
    page(numbering: "i")[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }
  if "compliance" in meta {
    page(numbering: "i", compliance-page(meta))
  }
  if "authorities" in meta {
    page(numbering: "i", authorities-table(meta))
  }

  // ---- Body (arabic from 1) ----
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)

  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block after the conclusion ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (last page, when the filing has one) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(first-line-indent: (amount: para-indent, all: true), inl(p)) }
    v(0.4em)
    if "signature" in svc { signature-block(svc.signature) }
  }
}
