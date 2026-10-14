// BIA brief on appeal. Sources: BIA Practice Manual ch. 3.3(c) (cover page, caption, fonts, spacing),
// ch. 3.2(d) (proof of service), ch. 4.6 (contents, 50-page limit), App. E (cover pages);
// 8 C.F.R. 1003.3(c)(1). Every case fact comes from the sample's frontmatter; nothing here is case-specific.
#import "@preview/cmarker:0.1.10"

// ---- parameters (rule each one traces to: README.md) ----
#let body-size = 12pt
#let body-leading = 1.74em       // double-spaced text, ch. 3.3(c)(7); measured pitch ~27.6pt at 12pt
#let margin = 1in                // convention; the manual sets no margin figure
#let page-limit = 50             // ch. 4.6(b)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("(?s)^---\n(.*?)\n---\n"))
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let bia-brief(meta, md) = {
  set document(title: meta.title, author: meta.filer.name)
  set text(font: "EB Garamond", size: body-size, lang: "en")
  set par(justify: false, leading: body-leading, first-line-indent: 0.5in)
  show heading.where(level: 1): it => block(above: 1.2em, below: 1.2em, par(leading: 0.65em, align(center, text(weight: "bold", upper(it.body)))))
  show heading.where(level: 2): it => block(above: 1em, below: 1em, par(leading: 0.65em, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(above: 1em, below: 1em, par(leading: 0.65em, text(weight: "bold", style: "italic", it.body)))
  show heading: set par(first-line-indent: 0pt)
  show quote.where(block: true): set par(leading: 0.65em)
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, it)

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context {
      // Cover (page 1) is unnumbered; ch. 4.6(b) requires pagination, ch. 4.6(c)(2) the A-number at bottom right.
      if counter(page).get().first() > 1 [
        #set text(size: 11pt)
        #grid(
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          [], counter(page).display(), [A#meta.a_number],
        )
      ]
    },
  )

  // ---- cover page (ch. 3.3(c)(6), App. E) ----
  {
    set par(first-line-indent: 0pt, leading: 0.65em)
    text(size: 11pt)[
      #meta.filer.name \
      #meta.filer.lines.join(linebreak())
    ]
    if meta.at("custody", default: none) != none {
      place(top + right, dy: -0.4in, box(stroke: 1pt, inset: 4pt, text(weight: "bold", upper(meta.custody))))
    }
    v(0.5in)
    align(center)[
      #text(weight: "bold")[UNITED STATES DEPARTMENT OF JUSTICE] \
      #text(weight: "bold")[EXECUTIVE OFFICE FOR IMMIGRATION REVIEW] \
      #text(weight: "bold")[BOARD OF IMMIGRATION APPEALS] \
      #meta.location
    ]
    v(0.4in)
    set par(first-line-indent: 0pt, leading: 0.65em)
    grid(
      columns: (1fr, 2.6in),
      column-gutter: 0.2in,
      inset: (right: 0.2in, bottom: 0.15in),
      [
        In the Matter of:

        #v(0.2em)
        #meta.respondent.name,

        #v(0.2em)
        #meta.respondent.role

        #v(0.2em)
        #meta.proceeding_type
      ],
      [
        #v(0.6in)
        File No.: A#meta.a_number
      ],
    )
    v(0.5in)
    align(center, text(weight: "bold", upper(meta.title)))
    v(1fr)
    set par(first-line-indent: 0pt, leading: 0.65em)
    grid(
      columns: (1fr, 1fr),
      [
        #meta.counsel.names.join(linebreak()) \
        #meta.counsel.lines.join(linebreak())
      ],
      align(right)[
        #meta.counsel.role
      ],
    )
  }
  pagebreak()

  // ---- table of contents (generated from the headings; excluded from the page limit, ch. 4.6(b)) ----
  {
    align(center, text(weight: "bold", [TABLE OF CONTENTS]))
    v(0.3in)
    set par(first-line-indent: 0pt, leading: 0.9em)
    outline(title: none, depth: 2, indent: 0pt)
  }
  pagebreak()

  // ---- body ----
  let body = cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  body

  // ---- signature block (ch. 3.3(b), ch. 4.6(c)(1)) ----
  v(0.4in)
  block(breakable: false)[
    #set par(first-line-indent: 0pt, leading: 0.65em)
    #grid(
      columns: (1fr, 3in),
      align: (left, left),
      [Dated: #meta.date],
      [
        Respectfully submitted,

        #v(0.4in)
        #line(length: 3in, stroke: 0.5pt)
        #meta.signature.signer \
        #meta.signature.lines.join(linebreak())
      ],
    )
  ]

  // ---- certificate of service (ch. 3.2(d)) ----
  pagebreak()
  align(center, text(weight: "bold", [CERTIFICATE OF SERVICE]))
  v(0.3in)
  set par(first-line-indent: 0.5in, leading: body-leading)
  let svc = meta.service
  if svc.means == "ecas" [
    This document was electronically filed through ECAS and both parties are participating in ECAS. Therefore, no separate service was completed.
  ] else [
    I certify that on #svc.date, I served a copy of the foregoing #svc.document, by #svc.means, on #svc.served_on.name, at #svc.served_on.address.
  ]
  v(0.3in)
  set par(first-line-indent: 0pt, leading: 0.65em)
  grid(
    columns: (1fr, 3in),
    [],
    [
      #v(0.4in)
      #line(length: 3in, stroke: 0.5pt)
      #svc.served_by.name \
      #svc.served_by.role
    ],
  )
}
