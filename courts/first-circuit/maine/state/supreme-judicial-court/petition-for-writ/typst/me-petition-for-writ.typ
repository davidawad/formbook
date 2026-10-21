// Maine Supreme Judicial Court original petition: petition for writ of habeas corpus (14 M.R.S. 5501 et seq.),
// filed before a single justice. Entry point: typst/main.typ calls me-petition-for-writ(meta, body).
// Every number is a named constant below and traces to a rule in ../rules.md. Nothing here is
// case-specific: case text comes from the sample's frontmatter and markdown only.
#import "@preview/cmarker:0.1.10"

// ---- Typography and paper (MRAP 7(g)(2), 1D(d); ME-PET-001, ME-PET-002) ------------------------
// No typeface is named by the rule; Times New Roman is the convention across the exemplars (ME-FORM-006).
#let font-family = "Times New Roman"
#let body-size = 14pt // ME-FORM-001: printed matter at least 14-point
#let note-size = 11pt // ME-FORM-001: footnotes may be 11-point
#let margin = 1in // ME-FORM-003 (applied by analogy to petitions, ME-FORM-004)
#let indent = 0.5in
// ME-FORM-005: double spacing between lines. Typst's natural pitch for this face is about 0.68em, so
// the leading is set so the baseline-to-baseline pitch is 1.15em (single) and 2.3em (double).
#let leading-double = 1.63em
#let leading-single = 0.47em

// ---- Court constants (not case text) ----------------------------------------------------------
// ME-PET-002: the caption names the State and the court.
#let court-lines = ("STATE OF MAINE", "SUPREME JUDICIAL COURT")

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("me-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Arabic page number in the footer, continuous from the first page as page 1 (ME-FORM-007).
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block or a signature.
#let lines-of(list) = for l in list {
  block(width: 100%, [#l])
}

// ---- Caption (ME-PET-002): court, docket number, parties on the first side, descriptive title ----
#let caption(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    [#court-lines.at(0)],
    [#court-lines.at(1) \ Docket No. #meta.docket],
  )
  v(1.6em)
  grid(
    columns: (3.3in, 1fr),
    gutter: 0.3in,
    {
      for side in meta.caption {
        lines-of(side.names)
        v(0.4em)
        [#side.designation]
        if side != meta.caption.last() {
          v(0.9em)
          [v.]
          v(0.9em)
        }
      }
    },
    align(horizon, [#meta.brief_title]),
  )
  v(1.8em)
}

// ---- Closing: signature blocks of the petitioners' counsel (ME-CERT-001) -----------------------
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  Respectfully submitted this #meta.date,
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(0.6em)
  #block(width: 100%, pad(left: 3.2in)[By the Petitioners,])
  #v(1.2em)
  #grid(
    columns: range(meta.signers.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signers.map(s => lines-of(s.lines)),
  )
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "en")
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
  // The exemplar's certificate uses a bullet and an "o" sub-bullet; the face's bullet glyph is not in the
  // vendored Times New Roman metric twin, so the top level uses an en dash (in the face) and the sub-level "o".
  set list(marker: ([–], [o]))
  show footnote: f => text(font: font-family, f)
  show footnote.entry: n => {
    set text(font: font-family, size: note-size)
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

// ---- Entry -------------------------------------------------------------------------------------
#let me-petition-for-writ(meta, body) = {
  set document(title: meta.docket + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // The caption opens the petition on page 1 (as in the filed exemplar); the body follows without a cover.
  // The certificate of filing and service is part of the markdown; it prints after the signature blocks.
  let i = body.position("# CERTIFICATE OF FILING AND SERVICE")
  if i == none { panic("me-petition-for-writ: the sample must contain the certificate of filing and service heading") }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #caption(meta)
    #cmarker.render(body.slice(0, i), raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
    #cmarker.render(body.slice(i), raw-typst: false, smart-punctuation: true, h1-level: 1)
  ]
}
