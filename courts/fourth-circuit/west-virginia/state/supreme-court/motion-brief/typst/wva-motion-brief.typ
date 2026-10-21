// West Virginia Supreme Court of Appeals: motion and supporting memorandum (RAP 29, RAP 38; see ../../rules.md).
// Content-agnostic: no case text, no measured coordinates, no forced line breaks. The caption, counsel,
// signature and certificate come from the YAML frontmatter of usage/INPUT-motion-brief.md; the body is
// rendered by cmarker.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // WVA-TPL-002: declared face (the rules set no typeface)
#let type-size = 12pt // WVA-FORM-003, RAP 38(a): no smaller than 12-point proportionally spaced type
#let note-size = 12pt // WVA-FORM-004, RAP 38(a): footnotes no smaller than 11-point (12 used)
#let body-leading = 1.15em // WVA-FORM-002, RAP 38(a): double-spaced text (Times natural line height about 1.15 em; as in the answering-brief template).
#let single-leading = 0.3em // single spacing for captions, counsel, quotations, footnotes, signature (about 1.2 x 12 pt pitch).
#let body-gap = 0.6em // space between paragraphs (style choice, not rule-mandated)
#let page-margin = 1in // WVA-FORM-005, RAP 38(a): margins no less than one inch on all sides
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("wva-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wva-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Front page: the caption (WVA-COVER-001)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center)[IN THE SUPREME COURT OF APPEALS OF WEST VIRGINIA]
  v(0.8em)
  for l in meta.at("lower_court", default: ()) {
    align(center, l)
  }
  v(0.8em)
  line(length: 45%, stroke: 0.6pt)
  v(0.6em)
  for n in need(meta, "appellate_case_numbers") {
    align(center)[No. #n]
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
// Signature block (WVA-CERT-001): dated at left, signer at right
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

// Certificate of service (WVA-ELEC-002, RAP 37): rendered only when the sample supplies one.
#let certificate(meta) = {
  let c = meta.at("certificate_of_service", default: none)
  if c == none { return }
  heading(level: 1, outlined: false, numbering: none)[CERTIFICATE OF SERVICE]
  set par(leading: body-leading, spacing: body-gap, first-line-indent: para-indent)
  inl(c.text)
  v(0.8em)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  for r in c.at("recipients", default: ()) {
    for l in r { block(width: 100%, inl(l)) }
    v(0.4em)
  }
  if "signature_lines" in c [ #v(0.6em) #for l in c.signature_lines [ #block(width: 100%, inl(l)) ] ]
  if "date" in c [ #v(0.6em) Dated: #c.date ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let wva-motion-brief(meta, body) = {
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
  // Counsel on the cover (WVA-COVER-001(5)): name, address, telephone, WV State Bar number, e-mail.
  if "counsel" in meta {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    v(0.6em)
    pad(left: 45%, for g in meta.counsel {
      for n in g.names [ #strong(inl(n)) \ ]
      for l in g.lines [ #inl(l) \ ]
      v(0.6em)
    })
  }
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature(meta)
  certificate(meta)
}
