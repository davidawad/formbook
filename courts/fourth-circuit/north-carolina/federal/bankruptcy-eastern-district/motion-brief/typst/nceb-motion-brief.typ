// Memorandum of law supporting a motion in the U.S. Bankruptcy Court, E.D.N.C. (nceb), adversary proceeding.
// Rules: FRBP 9004(a) (legible), 9004(b) (caption: court, division, case and adversary numbers, designation);
// LBR 9004-2 (caption states the court, division and chapter); LBR 7007-1(a) (motion filed with a memorandum);
// FRBP 9013(b) (motion states its grounds); LBR 9011-4 (signature block: name, firm, address, phone, email, State Bar no.);
// Admin Guide Rule 5005-4(8) ("s/" signature); LBR 9013-3 (certificate of service). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // no E.D.N.C. typeface rule; the exemplar is a Times-style serif; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                   // no E.D.N.C. type-size rule (FRBP 9004(a): "clearly legible"); exemplar is 12 pt
#let body-leading = 1.345em             // double spacing as in the exemplar: 0.655em line box + 1.345em leading = 24 pt pitch
#let single-leading = 0.5em             // single spacing: counsel, signature, certificate of service, quotations
#let margin = 1in                       // no E.D.N.C. margin rule; 1 inch as in the exemplar
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nceb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (smart punctuation: the author's characters are kept).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Caption: court (centered caps), then the parties on the left and the case numbers on the right.
// FRBP 9004(b) and LBR 9004-2 require the court, the division, the case and adversary numbers, the chapter,
// and a designation of the paper; the title below states that designation.
// ---------------------------------------------------------------------------

#let party-block(p) = {
  for n in p.names { [#n \ ] }
  align(right, [#p.designation])
  v(single-leading * 2)
}

#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for line in meta.court { align(center, text(weight: "bold", upper(line))) }
  align(center, text(weight: "bold", upper(meta.division)))
  v(single-leading * 3)
  grid(
    columns: (3.4in, 1fr),
    column-gutter: 0.2in,
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      [In re:]
      v(single-leading)
      for p in meta.caption.in_re { party-block(p) }
      for p in meta.caption.parties { party-block(p) }
    }),
    block(inset: (left: 0.1in), {
      v(single-leading * 4)
      [Case No. #meta.case_number \ ]
      [Chapter #meta.chapter \ ]
      if "adversary_number" in meta [ \ Adversary Proceeding No. #meta.adversary_number ]
    }),
  )
  v(single-leading * 3)
  align(center, text(weight: "bold", upper(meta.title)))
  v(single-leading * 2)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(breakable: false, {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  v(single-leading * 2)
  if "date" in sig [ Dated: #sig.date ]
  v(single-leading * 2)
  pad(left: 3in, {
    [Respectfully submitted,]
    v(single-leading * 2)
    for s in sig.signers {
      [#s.sign \ ]
      for l in s.lines { [#l \ ] }
      v(single-leading * 2)
    }
    if "role" in sig { [#text(style: "italic", sig.role)] }
  })
})

#let certificate(c) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, text(weight: "bold", upper(c.title)))
  v(single-leading * 3)
  par(leading: body-leading, first-line-indent: para-indent, justify: false, c.text)
  v(single-leading * 2)
  pad(left: 1in, {
    for l in c.served { [#l \ ] }
  })
  v(single-leading * 3)
  pad(left: 3in, {
    [Dated: #c.date]
    v(single-leading * 2)
    [#c.signer.sign \ ]
    for l in c.signer.lines { [#l \ ] }
  })
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, block quotations
// ---------------------------------------------------------------------------

#let body-style(body) = {
  // Level 1: centered, bold, capitals (argument sections: INTRODUCTION, ARGUMENT, CONCLUSION, ...).
  show heading.where(level: 1): it => block(width: 100%, above: 24pt, below: 12pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  // Level 2: bold, flush left (numbered argument points, e.g. "I. ...").
  show heading.where(level: 2): it => block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body)))
  // Block quotations: indented 1 inch on both sides, single-spaced (FRAP-style; see README.md).
  show quote.where(block: true): it => pad(left: 1in, right: 1in, top: 6pt, bottom: 12pt, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    it.body
  })
  set par(leading: body-leading, first-line-indent: para-indent, justify: false)
  md(body)
}

#let nceb-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  caption(meta)
  body-style(body)
  signature-block(meta.signature)
  if "certificate" in meta {
    pagebreak()
    certificate(meta.certificate)
  }
}
