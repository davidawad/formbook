// Supreme Court of South Carolina: motion and supporting memorandum (SCACR Rules 240, 267).
//
// Rule-driven and content-agnostic: no case text, no measured coordinates, no forced line breaks.
// Requirement IDs (SC-...) refer to ../../rules.md. The markdown body is rendered by cmarker;
// the caption, counsel and signature come from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // SC-FORM-003: declared face (rules set no typeface)
#let type-size = 12pt // SC-FORM-001, SCACR 267(c): standard 12-point or larger
#let note-size = 12pt // SCACR 267(c): no type smaller than 12-point
#let body-leading = 1.1em // SC-FORM-001, SCACR 267(c): double-spaced text
#let single-leading = 0.35em // single spacing for captions, counsel, quotations, footnotes, signature
#let body-gap = 0.6em // space between paragraphs (style choice, not rule-mandated)
#let page-margin = 1in // SC-FORM-002, SCACR 267(d): one inch on all sides
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("sc-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sc-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Front page: the caption (SC-FORM-004, SC-FORM-005)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center)[THE STATE OF SOUTH CAROLINA]
  v(0.3em)
  align(center)[#need(meta, "court_name")]
  v(0.8em)
  for l in meta.at("lower_court", default: ()) {
    align(center, l)
  }
  v(0.8em)
  line(length: 45%, stroke: 0.6pt)
  v(0.6em)
  for n in need(meta, "appellate_case_numbers") {
    align(center)[Appellate Case No. #n]
  }
  v(0.6em)
  line(length: 45%, stroke: 0.6pt)
  v(1.0em)

  for (i, g) in need(meta, "caption").enumerate() {
    if "connector" in g {
      align(center)[#g.connector]
      v(0.6em)
    }
    let lines = g.lines
    for (j, l) in lines.enumerate() {
      if j < lines.len() - 1 {
        block(width: 100%, inl(l))
      } else {
        block(width: 100%, [#inl(l) #box(width: 1fr, repeat[.]) #g.role])
      }
    }
    v(0.6em)
  }
  line(length: 45%, stroke: 0.6pt)
  v(0.8em)
  align(center)[#text(weight: "bold", upper(need(meta, "brief_title")))]
  v(0.6em)
  line(length: 45%, stroke: 0.6pt)
  v(1.2em)
}

// ---------------------------------------------------------------------------
// Signature block (SC-FORM-006, SC-FORM-007): dated at left, signer at right
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.0em)
    #grid(
      columns: (1fr, 3.4in),
      gutter: 0.2in,
      [Dated: #need(meta, "date")],
      [
        #for g in sig {
          for l in g.lines { block(width: 100%, inl(l)) }
          v(0.8em)
        }
      ],
    )
  ]
}

// Certificate of service (SC-FORM-010): rendered only when the sample supplies one.
#let certificate(meta) = {
  let c = meta.at("certificate_of_service", default: none)
  if c == none { return }
  heading(level: 1, outlined: false, numbering: none)[CERTIFICATE OF SERVICE]
  set par(leading: body-leading, spacing: body-gap, first-line-indent: para-indent)
  inl(c.text)
  v(0.8em)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  for r in c.at("recipients", default: ()) {
    block(width: 100%, inl(r))
    v(0.4em)
  }
  if "date" in c [ #v(0.6em) Dated: #c.date ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let sc-motion-brief(meta, body) = {
  set document(title: upper(need(meta, "brief_title")), author: "")
  set page(paper: "us-letter", margin: page-margin, numbering: "1", footer: context {
    set align(center)
    set text(font: font-family, size: type-size)
    counter(page).display()
  })
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-gap, first-line-indent: para-indent)

  show heading: set text(size: type-size)
  show heading.where(level: 1): it => block(
    above: 1em,
    below: 0.8em,
    width: 100%,
    align(center, text(weight: "bold", it.body)),
  )
  show heading: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  show link: it => it.body
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  show quote.where(block: true): it => {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    pad(left: 0.5in, right: 0.5in, bottom: body-gap, it.body)
  }

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature(meta)
  certificate(meta)
}
