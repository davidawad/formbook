// Massachusetts Supreme Judicial Court: brief on the merits (and the appellant's and appellee's principal briefs
// that share its layout). Content-agnostic: every number is a named parameter below and traces to the rule cited
// beside it (Massachusetts Rules of Appellate Procedure, as posted on mass.gov; see ../../rules.md). No case text,
// no coordinates measured off any filed brief, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata is the YAML frontmatter of the INPUT (keys listed in ../usage/INPUT-brief-on-the-merits.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 14pt                      // MRAP 20 (a) (4) (B): proportionally spaced font of 14 point or larger, footnotes included.
#let body-leading = 1.61em                 // MRAP 20 (a) (4) (C): double-spaced, not more than 3 lines per vertical inch (27 lines per page). Calibrated to a 32.2 pt line pitch (measured on the render; the double-spaced filed exemplar has a 32.16 pt pitch).
#let single-leading = 0.45em               // MRAP 20 (a) (4) (C): headings, footnotes, indented quotations and visual aids may be single-spaced (a 16 pt pitch).
#let page-margin = 1in                     // MRAP 20 (a) (4) (A): top, bottom, left and right margins at least 1 inch.
#let para-indent = 0.5in                   // style: first-line indent of body paragraphs.
#let toc-depth = 4
#let court-name = "COMMONWEALTH OF MASSACHUSETTS"  // MRAP 20 (a) (6) (B) (i): name of the court.
#let court-division = "Supreme Judicial Court"      // MRAP 20 (a) (6) (B) (i): division of the court.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-brief-on-the-merits: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mass-brief-on-the-merits: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation (MRAP 20 (a) (6) (B) (i)-(v)).
#let caption-side(side) = align(center)[
  #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  #for n in side.names [ #inl(n) ]
  #v(0.2em)
  #side.designation
]

/// Counsel group: names, then the office, address and contact lines (MRAP 16 (a) (1), 20 (a) (6) (B) (iv)).
#let counsel-group(g) = stack(
  dir: ttb,
  spacing: single-leading,
  ..g.names.map(n => inl(n)),
  ..g.lines.map(l => inl(l)),
)

/// A signature cell: the typed signature, the printed name and BBO number, then the address and contact lines
/// (MRAP 16 (a) (12); MA-SIG-001).
#let sig-cell(s) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  stack(
    dir: ttb,
    spacing: single-leading,
    if "sign" in s { [/s/ #inl(s.sign)] },
    inl(s.print),
    ..s.at("lines", default: ()).map(l => inl(l)),
  )
}

/// The signature block after the conclusion: an introduction, the signers in two columns, then the date.
#let signature-block(sig, date) = block(width: 100%, breakable: false)[
  #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  #inl(sig.at("intro", default: "Respectfully,"))
  #v(1.2em)
  #grid(
    columns: (1fr,) * calc.min(sig.signers.len(), 2),
    column-gutter: 0.3in,
    row-gutter: 1.5em,
    ..sig.signers.map(s => sig-cell(s)),
  )
  #v(1em)
  #date
]

// ---------------------------------------------------------------------------
// Table of authorities. Each entry carries `key` and `find`: a string (or a list of strings) that appears in
// every citation of the authority in the body. A show rule on that string drops a marker after each
// occurrence; the table lists the pages of the markers (MRAP 16 (a) (4)).
// ---------------------------------------------------------------------------

#let toa-marker(key) = [#metadata(key)<mass-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      let finds = if type(e.find) == array { e.find } else { (e.find,) }
      for f in finds {
        let key = e.key
        out = {
          show f: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<mass-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else if pages.len() > 5 { [passim] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[TABLE OF AUTHORITIES]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The page references sit in their own column aligned to the last line of the citation.
      block(above: 0.6em, below: 0.6em, breakable: false)[
        #grid(
          columns: (1fr, auto),
          column-gutter: 0.25in,
          align: (left + top, right + bottom),
          inl(e.cite),
          box(toa-pages(e.key)),
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mass-brief(meta, body) = {
  set document(title: need(meta, "brief_title"), author: "")
  // MRAP 20 (a) (4) (A): page numbers in the margin, consecutively from the cover (page 1). The top and bottom
  // margins are 1 inch plus 4 pt so the raised figure of a footnote reference on a page's first line stays inside
  // the printed margin's limit (MRAP 20 (a) (4) (A)).
  set page(
    paper: "us-letter",
    margin: (top: page-margin + 4pt, bottom: page-margin + 4pt, left: page-margin, right: page-margin),
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(
    leading: body-leading,
    spacing: body-leading,  // no extra gap between paragraphs: the next paragraph keeps the same 32.2 pt pitch
    first-line-indent: (amount: para-indent, all: true),
    justify: false,
  )
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a part (centred, bold, capitals); level 2 is a point of
  // argument or a fact sub-heading (bold, hanging); level 3 is a lettered sub-point; level 4 a numbered sub-point.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented on both sides, single-spaced (MRAP 20 (a) (4) (C) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // Footnotes: the same 14 point face as the text, single-spaced (MRAP 20 (a) (4) (B), (C)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities (MRAP 16 (a) (4))
  }

  // ---- Cover (MRAP 20 (a) (6) (B)): counted as page 1 and not printed; the next page prints 2 ----
  page(numbering: none)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(center)[
      #stack(dir: ttb, spacing: single-leading,
        text(weight: "bold")[#court-name],
        [#court-division],
      )
      #v(0.12in)
      No. #need(meta, "case_number")
    ]
    #v(0.12in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.08in)
    #align(center)[v.]
    #v(0.08in)
    #caption-side(need(meta, "caption").at(1))
    #v(0.12in)
    #align(center)[#inl(need(meta, "proceeding"))]
    #v(0.15in)
    #align(center)[
      #line(length: 2.2in, stroke: 0.6pt)
      #v(0.12in)
      #text(weight: "bold", need(meta, "brief_title"))
      #v(0.12in)
      #line(length: 2.2in, stroke: 0.6pt)
    ]
    #v(0.2in)
    #{
      let groups = need(meta, "counsel")
      grid(
        columns: (1fr,) * calc.min(groups.len(), 2),
        column-gutter: 0.3in,
        row-gutter: 0.6em,
        ..groups.map(g => counsel-group(g)),
      )
    }
  ]

  // Numbering from the cover: the cover is page 1 (not printed); pages after it print their number.
  set page(numbering: "1", number-align: center + bottom)

  // ---- Corporate disclosure statement (MRAP 16 (a) (2); SJC Rule 1:21) ----
  if "disclosure" in meta {
    heading(level: 1)[CORPORATE DISCLOSURE STATEMENT]
    for p in meta.disclosure.paragraphs { inl(p) }
    pagebreak(weak: true)
  }

  // ---- Table of contents (MRAP 16 (a) (3)) ----
  if meta.at("toc", default: true) {
    heading(level: 1, outlined: false)[TABLE OF CONTENTS]
    show outline.entry: it => block(above: 0.5em, below: 0.5em, it)
    outline(title: none, depth: toc-depth, indent: 1.5em)
    pagebreak(weak: true)
  }

  // ---- Table of authorities (MRAP 16 (a) (4)) ----
  if "authorities" in meta {
    authorities-table(meta)
    pagebreak(weak: true)
  }

  // ---- Body: everything before the addendum sentinel ----
  let parts = body.split("\n# ADDENDUM\n")
  mark-authorities(meta, cmarker.render(parts.at(0), raw-typst: false, smart-punctuation: true))

  // ---- Signature block (MRAP 16 (a) (12)): after the conclusion ----
  v(0.6em)
  signature-block(need(meta, "signature"), need(meta, "date"))

  // ---- Addendum (MRAP 16 (a) (13)): its own table of contents, then the documents ----
  if parts.len() > 1 {
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[ADDENDUM]
    mark-authorities(meta, cmarker.render(parts.at(1), raw-typst: false, smart-punctuation: true))
  }

  // ---- Certificate of compliance (MRAP 16 (a) (14), 16 (k), 20 (a) (2) (F)) ----
  let c = need(meta, "compliance")
  pagebreak(weak: true)
  heading(level: 1)[CERTIFICATE OF COMPLIANCE]
  for p in c.paragraphs { inl(p) }
  v(1.2em)
  block(breakable: false, grid(
    columns: (1fr, 3in),
    column-gutter: 0.3in,
    [Dated: #c.date],
    sig-cell(c.signature),
  ))

  // ---- Certificate of service (MRAP 16 (a) (15), 13 (e)) ----
  let svc = need(meta, "service")
  v(1.5em)
  block(breakable: false)[
    #heading(level: 1)[CERTIFICATE OF SERVICE]
    #for p in svc.paragraphs { inl(p) }
    #v(1.2em)
    #grid(
      columns: (1fr, 3in),
      column-gutter: 0.3in,
      [Dated: #svc.date],
      sig-cell(svc.signature),
    )
  ]
}
