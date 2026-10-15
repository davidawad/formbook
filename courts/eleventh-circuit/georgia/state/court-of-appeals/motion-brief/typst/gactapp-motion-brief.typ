// Georgia Court of Appeals: motion (motion-brief). Rule-driven and content-agnostic.
//
// Requirement IDs (GACA-...) refer to ../README.md, which records the rule text, its source and
// what could and could not be verified on this box. No case-specific text, no coordinates measured
// off an exemplar, no forced line breaks. The body is markdown rendered by cmarker; the cover,
// caption, signature and certificates come from the YAML frontmatter of the same sample file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // GACA-FORM-002: Times New Roman named by the rule; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 14pt                   // GACA-FORM-002: 14-point type, footnotes included (unverified against the official rule text; see README)
#let body-leading = 1.65em              // GACA-FORM-003: double spacing; line pitch measured in README
#let single-leading = 0.35em            // caption, counsel block, headings in single spacing, footnotes, block quotes
#let margins = (top: 1in, bottom: 1in, x: 1in)  // GACA-FORM-004 (margins are a style assumption, not from a verified rule; see README)
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gactapp-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gactapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines for counsel, caption, certificates.
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the motion (GACA-FIRST-001..003)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  align(center, strong[#upper(need(meta, "court"))])
  v(1.2em)
  let parties = need(meta, "parties")
  grid(
    columns: (1fr, 1.1fr),
    column-gutter: 0.4in,
    block(stroke: (right: 0.75pt), inset: (right: 0.6em, bottom: 0.6em), width: 100%, single[
      #for p in parties [ #p.name \ #h(1.5em) #p.role \ ]
    ]),
    single[
      Case No. #need(meta, "case_number")
      #if "lower_court_case" in meta [ \ #meta.lower_court_case ]
    ],
  )
  v(1.4em)
  align(center, block(width: 85%, strong[#need(meta, "title")]))
  v(1.2em)
}

// ---------------------------------------------------------------------------
// Certificates and signature block (GACA-SIG-001, GACA-CERT-001)
// ---------------------------------------------------------------------------

#let word-count-certificate(meta) = {
  if "word_count" not in meta { return }
  block(breakable: false, above: 1.2em, below: 0.4em, {
    align(center, strong[CERTIFICATE OF WORD COUNT])
    par(first-line-indent: para-indent, leading: body-leading, justify: false)[
      I certify that this motion contains #meta.word_count words, excluding the caption, the
      signature block, and this certificate, as counted by the word-processing software used to
      prepare it.
    ]
  })
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.2em, {
    par(first-line-indent: para-indent, leading: body-leading, justify: false)[
      Respectfully submitted this #sig.date.
    ]
    v(1.2em)
    pad(left: 3.25in, block(width: 3.25in, single[
      #for line in sig.lines [ #line \ ]
      \
      #sig.signer_line \
      #for line in sig.signer [ #line \ ]
    ]))
  })
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  block(breakable: false, above: 1.6em, {
    align(center, strong[CERTIFICATE OF SERVICE])
    par(first-line-indent: para-indent, leading: body-leading, justify: false)[
      I certify that on #svc.date, I served a copy of this #svc.doc_type on #svc.served_on by
      #svc.method, addressed as follows:
    ]
    v(0.4em)
    single[#for line in svc.address [ #line \ ]]
    v(1em)
    pad(left: 3.25in, block(width: 3.25in, single[#need(meta, "signature").signer_line]))
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let gactapp-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: para-indent, justify: false)
  set quote(block: true)
  show quote: it => block(inset: (left: 0.5in, right: 0.5in), width: 100%, par(
    leading: single-leading, first-line-indent: 0pt, it.body,
  ))
  show footnote.entry: set text(size: type-size)
  show heading.where(level: 1): it => block(above: 1.2em, below: 0.8em, sticky: true, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: 1em, below: 0.6em, sticky: true, text(size: type-size, weight: "bold", it.body))

  cover(meta)
  // The body starts on the cover page, as in the motion form; a page break is not forced here.
  // Markdown body (GACA-CONT-001).
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  word-count-certificate(meta)
  signature-block(meta)
  certificate-of-service(meta)
}
