// Maine Supreme Judicial Court (sitting as the Law Court) motion for reconsideration (MRAP 14(b)).
// Entry point: typst/main.typ calls me-petition-for-rehearing(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to a rule in ../rules.md. Nothing here is
// case-specific: case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Typography and paper (MRAP 7(g)(2), 1D(d)) --------------------------------------------
// No typeface is named by the rule; Times New Roman is the convention across the exemplars (ME-FORM-006).
#let font-family = "Times New Roman"
#let body-size = 14pt // ME-FORM-001: printed matter at least 14-point
#let note-size = 11pt // ME-FORM-001: footnotes may be 11-point
#let margin = 1in // ME-FORM-003, ME-FORM-004: 1 inch top, bottom and both sides
#let indent = 0.5in
// ME-FORM-005: double spacing between lines. Typst's natural pitch for this face is about 0.68em, so
// the leading is set so the baseline-to-baseline pitch is 1.15em (single) and 2.3em (double).
#let leading-double = 1.63em
#let leading-single = 0.47em

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("SUPREME JUDICIAL COURT OF THE STATE OF MAINE", "SITTING AS THE LAW COURT") // ME-MOT-001

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("me-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Arabic page number in the footer, continuous from page 1 (MRAP 7(g)(3)).
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a caption or a signature.
#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Caption and title (MRAP 1D(d), 14(b)) ----------------------------------------------------
#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(1.6em)
  align(center, [Law Court Docket No. #meta.docket])
  v(1.6em)
  for side in meta.caption {
    align(center, lines-of(side.names))
    v(0.4em)
    align(center, [#side.designation])
    v(1em)
    if side != meta.caption.last() {
      align(center, [v.])
      v(1em)
    }
  }
  v(1.2em)
  align(center, text(weight: "bold", meta.brief_title))
  v(2.4em)
}

// ---- Signature blocks (MRAP 1C(b)) and certificate of service (MRAP 1D(e)) ---------------------
#let signature-block(s) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  block(width: 3.4in, breakable: false)[
    #v(1.4em)
    #line(length: 100%)
    #lines-of(s.lines)
  ]
}

// The closing and every signature block stay on one page (ME-CERT-001: a signature is followed
// immediately by its signature block).
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(1.2em)
  Respectfully submitted,
  #v(0.6em)
  Dated: #meta.date
  #for s in meta.signature {
    align(right, signature-block(s))
  }
]

#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I certify that I have on this day served a true and correct copy of the foregoing upon the following counsel of record by #meta.service.method:
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(1.2em)
  #grid(
    columns: range(meta.service.recipients.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
  #v(1.4em)
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date
  #align(right, signature-block(meta.certificate_signature))
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
#let me-petition-for-rehearing(meta, body) = {
  set document(title: meta.docket + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document: footnote areas are laid out with the page's own style.
  set text(font: font-family, size: body-size, lang: "en")
  // One continuous Arabic numbering from the first page (MRAP 7(g)(3)). The caption opens the motion.
  page(numbering: "1", footer: folio)[
    #show: style-body
    #cover(meta)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  // ME-FORM-009, ME-CERT-004: the certificate of service states the manner of service on each party.
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-service(meta)
  ]
}
