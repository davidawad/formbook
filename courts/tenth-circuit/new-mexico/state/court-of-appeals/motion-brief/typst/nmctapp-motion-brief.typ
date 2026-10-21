// New Mexico Court of Appeals (nmctapp): brief in chief (opening brief), answer brief, reply brief,
// amicus brief, motion and writ-of-error petition. One template, the doc type comes from the frontmatter.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (New Mexico Rules of Appellate Procedure, NMRA Part 12, compiled PDF created 2026-08-11,
// https://nmonesource.com/nmos/nmra/en/5673/1/document.do, HTTP 200 on 2026-10-21; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample
// (schema: README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // NMRA 12-305(D)(1): proportionally spaced, with serifs, such as Times New Roman.
#let type-size = 14pt                      // NMRA 12-305(D)(1): 14-point or larger.
#let cover-size = 12pt                     // NMRA 12-305(D)(1): the cover may be 11-point or larger when needed to fit the 12-305(F)-(G) information on one page.
#let body-leading = 1.15em                 // NMRA 12-305(E): double-spaced (one extra line of 14 pt type between lines).
#let single-leading = 0.3em                // NMRA 12-305(E): headings, footnotes, quotations, tables may be single-spaced.
#let top-margin = 1in                      // NMRA 12-305(B)(2): one inch, top and bottom.
#let bottom-margin = 1.05in                // NMRA 12-305(B)(2) says one inch; a little more keeps descenders of the last line clear of the 1 in line (stricter is fine).

#let side-margin = 1in                     // NMRA 12-305(B)(2): one inch, left and right.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre.
#let court-name = "IN THE COURT OF APPEALS OF THE STATE OF NEW MEXICO"  // NMRA 12-305(F)(1): name of the appellate court on the front page.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmctapp: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nmctapp: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Signature block (the exemplars use "s/" and the typed name, then the attorney lines).
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
#let toa-marker(key) = [#metadata(key)<nmctapp-toa>]

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
  let pages = query(<nmctapp-toa>)
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
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (NMRA 12-305(F) caption and (G) cover contents)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.5em)
  set text(size: cover-size)
  align(center, strong(court-name))
  v(0.8em)
  grid(
    columns: (1fr, 2.2in),
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
      #v(1.2em)
      No. #strong(inl(need(meta, "case_number")))
    ],
  )
  v(0.8em)
  // Lower court: county, trial judge and lower-court number (NMRA 12-305(G)(1)-(2)).
  for l in need(meta, "lower_court") [ #inl(l) \ ]
  v(0.8em)
  align(center, block(above: 0.6em, below: 0.6em)[
    #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
  ])
  if "oral_argument" in meta [ #align(center, strong(inl(meta.oral_argument))) ]
  v(0.6em)
  // Counsel groups in two columns so the cover stays on one page.
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    row-gutter: 0.6em,
    ..for c in need(meta, "counsel") {
      (block(breakable: false, [
        #set par(leading: single-leading, first-line-indent: 0pt)
        #if "heading" in c [ #emph(inl(c.heading)) \ ]
        #for l in c.lines [ #inl(l) \ ]
      ]),)
    }
  )
}

// ---------------------------------------------------------------------------
// Statement of compliance (NMRA 12-318(G), 12-503(G)): the attorney states the word count.
// The count is the filer's own, carried in the frontmatter (compliance.words).
// ---------------------------------------------------------------------------

#let compliance-page(meta) = {
  let c = meta.compliance
  heading(level: 1)[Statement of Compliance]
  par(first-line-indent: (amount: para-indent, all: true))[
    I certify that this brief complies with the type-volume limitation of Rule #c.at("rules", default: "12-318(F)(3)") NMRA.
    #if "program" in c [ According to #inl(c.program), the body of this brief, as defined by Rule #c.at("definition", default: "12-318(F)(1)") NMRA, contains #c.words words. ] else [ The body of this brief, as defined by Rule #c.at("definition", default: "12-318(F)(1)") NMRA, contains #c.words words. ]
  ]
  v(0.4em)
  signature-block(need(meta, "signature"))
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nmctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Pages: the cover is unnumbered, the front matter is roman, the body is arabic from 1.
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    numbering: none,
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
  show heading.where(level: 4): it => block(width: 100%, above: 0.9em, below: 0.7em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced (NMRA 12-305(E)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (NMRA 12-305(D)(1)), single-spaced (NMRA 12-305(E)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (unnumbered) ----
  page[#cover(meta)]

  let cert-pos = meta.at("compliance", default: (:)).at("position", default: "after-toc")
  let has-cert = "compliance" in meta

  // ---- Table of contents (roman numerals) ----
  if meta.at("toc", default: true) {
    page(numbering: "i")[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }
  if has-cert and cert-pos == "front" {
    page(numbering: "i", compliance-page(meta))
  }
  if has-cert and cert-pos == "after-toc" {
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

  if has-cert and cert-pos == "end" {
    v(0.6em)
    compliance-page(meta)
  }

  // ---- Certificate of service (last page, when the filing has one) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(first-line-indent: (amount: para-indent, all: true), inl(p)) }
    v(0.4em)
    signature-block(svc.signature)
  }
}
