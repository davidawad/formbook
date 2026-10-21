// Indiana Supreme Court: motion and supporting response (motion-brief). Rule-driven and content-agnostic.
//
// Rules: Indiana Rules of Appellate Procedure, "Updated, Effective January 1, 2025", Rules 34 (G) and 43 (B)-(G),
// read from the Internet Archive capture listed in ../../rules.md (IND-MOT-004, IND-FORM-003 to -007). A motion
// conforms to Rule 43 (B) through (G) only (Rule 34 (G) (1)); the front-page form and the running header are
// convention here (see the README). No case-specific text, no coordinates measured off an exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the cover, caption, signature, verification and certificate of
// service come from the YAML frontmatter of the same sample file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // IND-FORM-003, IND-FORM-004: Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md)
#let type-size = 12pt                  // IND-FORM-003: 12-point or larger in body text and footnotes
#let body-leading = 1.6em              // IND-FORM-005: double spacing: line pitch about 27.6 pt (2 x 13.8 pt, the single line of a 12-point Times face), calibrated against the Liberation Serif metrics
#let single-leading = 5.5pt            // IND-FORM-005: single-spaced lines (pitch about 13.8 pt) separated by at least 4 points
#let page-margin = 1in                 // IND-FORM-007: all four margins at least one inch
#let para-indent = 0.5in               // style choice: first-line indent of body paragraphs
#let sig-indent = 3.25in               // style choice: left edge of the signature block
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ind-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ind-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block (caption, counsel, certificates, signature).
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)
#let lines-block(xs) = single[#for x in xs [ #inl(x) \ ]]

// ---------------------------------------------------------------------------
// Running header (IND-FORM-007 ... Rule 43 (H) names it for briefs and petitions; a motion carries it by convention)
// Every page except the front page, aligned at the left margin.
// ---------------------------------------------------------------------------

#let running-header(meta) = context {
  if here().page() > 1 and "running_header" in meta {
    set text(size: type-size)
    set par(leading: 0pt, first-line-indent: 0pt)
    align(left, for l in meta.running_header [ #inl(l) \ ])
  }
}

// ---------------------------------------------------------------------------
// Cover: court, number, caption with a column of close-parentheses, title, counsel (right side)
// ---------------------------------------------------------------------------

/// `caption_rows`: one entry per caption line: `left` (party text), `indent` (optional), `right` (docket text).
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for r in need(meta, "caption_rows") {
    grid(
      columns: (3.4in, 0.3in, 1fr),
      align: (left + horizon, center + horizon, left + horizon),
      row-gutter: single-leading,
      {
        if r.at("indent", default: false) { pad(left: 0.6in, inl(r.at("left", default: ""))) } else { inl(r.at("left", default: "")) }
      },
      [)],
      inl(r.at("right", default: "")),
    )
  }
}

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  align(center)[
    IN THE \
    #strong[#upper(need(meta, "court"))]
  ]
  v(0.8em)
  align(center, [No. #need(meta, "case_number")])
  if "lower_court_case" in meta {
    v(0.4em)
    align(center, single(inl(meta.lower_court_case)))
  }
  v(1.2em)
  caption(meta)
  v(1.6em)
  align(center, block(width: 85%, single(strong(upper(inl(need(meta, "title")))))))
  v(1fr)
  if "counsel" in meta {
    pad(left: sig-indent, {
      for g in meta.counsel {
        block(above: 0.9em, breakable: false, single[
          #for n in g.names [ #strong(inl(n)) \ ]
          #for l in g.lines [ #inl(l) \ ]
        ])
      }
    })
  }
  if "attorneys_for" in meta {
    v(0.9em)
    pad(left: sig-indent, single(inl(meta.attorneys_for)))
  }
  pagebreak()
}

// ---------------------------------------------------------------------------
// Signatures, verifications, certificate of service
// ---------------------------------------------------------------------------

/// One signer: optional "By: /s/ name" (IND-ELEC-003), then the name and the signer's lines.
#let signer-block(s) = block(breakable: false, above: 0.8em, single[
  #if s.at("by", default: false) [By: ]#if s.at("sig", default: false) [/s/ ]#inl(s.name) \
  #for l in s.at("lines", default: ()) [ #inl(l) \ ]
])

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.2em, {
    par(first-line-indent: 0pt, leading: single-leading)[Respectfully submitted,]
    pad(left: sig-indent, {
      lines-block(sig.at("firm", default: ()))
      for s in need(sig, "signers") { signer-block(s) }
    })
  })
}

/// A signed statement after the signature block (verification, word-count certification), each with its own heading.
#let signed-statement(s) = {
  heading(level: 1, outlined: true)[#s.heading]
  for p in s.at("paragraphs", default: (s.at("text", default: ""),)) {
    par(inl(p))
  }
  if "signer" in s { pad(left: sig-indent, signer-block(s.signer)) }
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let signers = svc.at("signers", default: need(need(meta, "signature"), "signers"))
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Certificate of Service]
  for p in svc.paragraphs { par(inl(p)) }
  for r in svc.at("served", default: ()) {
    block(above: 1em, below: 1em, breakable: false, pad(left: 1in, single({
      for n in r.at("names", default: ()) [ #inl(n) \ ]
      for l in r.at("lines", default: ()) [ #inl(l) \ ]
    })))
  }
  v(0.6em)
  pad(left: sig-indent, {
    lines-block(svc.at("firm", default: ()))
    for s in signers { signer-block(s) }
  })
  lines-block(svc.at("footer_lines", default: ()))
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ind-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // IND-FORM-006: every page numbered consecutively at the bottom, the front page included, from numeral one.
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center + bottom,
    header-ascent: 0.5in,
    header: running-header(meta),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))

  // Headings: level 1 centered bold capitals; level 2 bold; level 3 bold italic; level 4 bold. Single-spaced, no indent.
  show heading: set text(size: type-size)
  show heading: set par(leading: single-leading, first-line-indent: 0pt)
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true, align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 1.1em, below: 0.9em, sticky: true, {
    set par(hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set par(hanging-indent: 0.5in)
    text(weight: "bold", style: "italic", it.body)
  })
  show heading.where(level: 4): it => block(width: 100%, above: 0.9em, below: 0.7em, sticky: true, {
    set par(hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })

  // Block quotations are blocked and indented: single-spaced (IND-FORM-005).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), width: 100%, above: 0.8em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })
  // Footnotes: 12-point, single-spaced (IND-FORM-003, IND-FORM-005).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  cover(meta)

  if meta.at("toc", default: false) {
    align(center, strong[TABLE OF CONTENTS])
    v(0.5em)
    {
      set par(leading: single-leading, first-line-indent: 0pt)
      show outline.entry: it => block(above: 0.8em, below: 0.8em, it)
      outline(title: none, depth: toc-depth, indent: 1.5em)
    }
    pagebreak()
  }

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  for s in meta.at("signed_statements", default: ()) { signed-statement(s) }
  certificate-of-service(meta)
}
