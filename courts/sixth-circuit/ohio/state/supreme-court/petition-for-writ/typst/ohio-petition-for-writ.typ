// Ohio Supreme Court document template (merit briefs, memoranda in support of jurisdiction,
// motions, original-action complaints, amicus briefs). Entry point typst/main.typ calls
// ohio-brief(meta, body). Every number traces to a rule in ../rules.md. Nothing here is
// case-specific: case text comes only from the sample's frontmatter and body.
#import "@preview/cmarker:0.1.10"

// ---- RoP 3.09: paper and typography ------------------------------------------------------
#let face = "Times New Roman" // RoP 3.09(B)(1)(b)(i)
#let body-size = 12pt // RoP 3.09(B)(1)(b): at least 12-point type
#let note-size = 12pt // RoP 3.09(B)(3): footnotes and quotations are also 12-point
#let margin = 1in // RoP 3.09(B)(2)(c): margins at least one inch
#let indent = 0.5in
// RoP 3.09(B)(3): text is double-spaced. Measured on this build, Times New Roman 12 pt sets a
// natural baseline pitch of about 8.3 pt, so a 13.8 pt single-spaced line (1.15 em) needs 5.5 pt
// (0.46 em) of leading and a 27.6 pt double-spaced line (2.3 em) needs 19.3 pt (1.6 em).
#let leading-double = 1.6em
#let leading-single = 0.46em

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohio-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number at the foot of each counted page (the cover has none).
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: face, size: body-size, counter(page).display(n))) }
}

#let front-title(t) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, block(above: 1.2em, below: 1.2em, text(weight: "bold", t)))
}

// Lines set one under another in a single paragraph with no paragraph spacing.
#let lines-of(items, italic: false) = {
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  items.map(l => if italic [#emph(l)] else [#l]).join(linebreak())
}

// ---- RoP 3.07: cover page -------------------------------------------------------------------
#let caption-side(c) = {
  lines-of(c.names)
  v(0.5em)
  pad(left: 2.2in, c.designation)
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  align(center, text(weight: "bold", "IN THE SUPREME COURT OF OHIO"))
  v(1.8em)
  grid(
    columns: (3.95in, 1fr),
    gutter: 0.25in,
    [
      #for c in meta.caption {
        caption-side(c)
        v(0.6em)
      }
    ],
    [
      Supreme Court Case No. #meta.case_number
      #if "proceeding" in meta [ #v(1.2em) #meta.proceeding ]
      #if "lower_court" in meta [ #v(1.2em) #meta.lower_court ]
    ],
  )
  v(2.4em)
  align(center, text(weight: "bold", meta.filing_type))
  if "on_behalf_of" in meta {
    v(0.8em)
    align(center, meta.on_behalf_of)
  }
  // The counsel block of a complaint with a long caption runs to a second, unnumbered cover page.
  pagebreak(weak: true)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => lines-of(g.lines)),
  )
}

// ---- Closing: signature blocks and certificate of service ------------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted,
  #v(0.8em)
  #signature-blocks(meta)
]

// RoP 3.11(B)(1)(a): service on counsel of record. The method and date come from the filer.
#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I hereby certify that a copy of the foregoing was sent by #meta.service.method on #meta.service.date to the following counsel of record:
  #v(1em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #grid(
    columns: range(meta.service.recipients.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.service.recipients.map(g => lines-of(g.lines)),
  )
  #v(1.6em)
  #signature-blocks(meta)
]

// ---- Body styling (applied with `#show: style-body`) -----------------------------------------
#let style-body(it) = {
  set text(font: face, size: body-size, lang: "en")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  show heading.where(level: 2): h => block(above: 1.2em, below: 0.8em, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(
    above: 1.1em,
    below: 0.6em,
    text(weight: "bold", style: "italic", h.body),
  )
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote.entry: n => {
    set text(font: face, size: note-size)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    n
  }
  show quote.where(block: true): q => block(above: 1em, below: 1em, pad(
    left: indent,
    right: indent,
    {
      set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
      q.body
    },
  ))
  it
}

// ---- Entry -----------------------------------------------------------------------------------
#let ohio-brief(meta, body) = {
  set document(title: meta.case_number + " " + meta.filing_type)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: face, size: body-size, lang: "en")
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  if "toc" in meta and meta.toc {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CONTENTS]
      #outline(title: none, depth: 2, indent: 0pt)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: false, h1-level: 1)
    #if "signature" in meta [#closing(meta)]
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
