// Supreme Court of Guam brief template (answering brief, GRAP 16). Entry point: typst/main.typ,
// which calls guam-brief(meta, body) with the sample's frontmatter and markdown. Every number is a
// named constant below and traces to a rule in ../README.md. Nothing here is case-specific: case
// text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- GRAP 16(a)(4)-(5): typography and margins ----------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // proportional serif face; Liberation Serif is its metric twin
#let body-size = 14pt // GRAP 16(a)(5)(A): a proportionally spaced face must be 14-point or larger
#let note-size = 14pt // GRAP 16(a)(5)(A) applies to the whole brief, footnotes included
#let margin = 1in // GRAP 16(a)(4): margins at least one inch on all four sides
#let indent = 0.5in
// GRAP 16(a)(4): double-spaced text. TNR's own line pitch is about 1.15 em; the extra leading
// makes the pitch 2.3 em (32.2 pt at 14 pt, as the filed exemplar). Single spacing is the own pitch.
#let leading-double = 1.63em
#let leading-single = 0.5em
#let leading-tight = 0.5em

// ---- Court constants (not case text) ----------------------------------------------------------
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("guam-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover. The front matter is roman; the body restarts at 1.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a caption or a signature.
#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover: GRAP 16(a)(2)(A)-(F) ----------------------------------------------------------------
#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", [SUPREME COURT CASE NO. #meta.case_number]))
  v(2.4em)
  for l in meta.court_lines {
    align(center, text(weight: "bold", l))
  }
  v(2.2em)
  block(width: 88%, align(center, lines-of(meta.caption)))
  v(2.6em)
  align(center, text(weight: "bold", meta.brief_title))
  v(3.4em)
  align(center, lines-of(meta.counsel))
}

// ---- Certificates ---------------------------------------------------------------------------------
// A certificate may carry its own signature lines; otherwise the brief's signature is used.
#let signature-block(meta, cert: none) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  let sig = if cert != none and "signature" in cert { cert.signature } else { meta.signature }
  block(width: 52%, lines-of(sig))
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted this #meta.date.
  #signature-block(meta)
]

#let certificate-page(meta, cert) = [
  #front-title[#cert.title]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #cert.text
  #if "recipients" in cert [
    #v(1.2em)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    #grid(
      columns: range(cert.recipients.len()).map(_ => 1fr),
      gutter: 0.3in,
      ..cert.recipients.map(g => lines-of(g.lines)),
    )
    #v(1.4em)
  ]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  #if "dated" in cert [Dated this #cert.dated.]
  #signature-block(meta, cert: cert)
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
    text(weight: "bold", h.body),
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
#let guam-brief(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document: footnote areas are laid out with the page's own style.
  set text(font: font-family, size: body-size, lang: "en")
  // The cover has no folio; the table of contents is roman; the body restarts at 1 in Arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 3, indent: 0pt)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  for cert in meta.certificates {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-page(meta, cert)
    ]
  }
}
