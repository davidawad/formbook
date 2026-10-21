// Supreme Court of Missouri (mo): motion with suggestions (motion-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Missouri Supreme Court Rules 84.03(b), as readopted effective January 1, 2024; see
// ../../rules.md). No case-specific text, no coordinates measured off any filed paper, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter.
//
// A motion has no cover, table of contents or table of authorities: the bracketed caption and
// the title open the first page and the motion text follows. The certificate of service
// follows the signature block.

#import "@preview/cmarker:0.1.10"

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 84.03(b)(3): Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 84.03(b)(3): not smaller than 13 point.
#let double-leading = 1.61em               // Rule 84.03(b)(2): spacing not less than 1.5; double used. Pitch = 2 x single.
#let single-leading = 0.46em               // Caption, headings, long quotations, footnotes, certificates, signature: single-spaced (Rule 84.03(b)(2)).
#let page-margin = 1in                     // Rule 84.03(b)(2): not less than one inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (convention).

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mo-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mo-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: party names, then the designation indented.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  pad(left: 1in, inl(side.designation))
}

#let signature-block(meta) = {
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "closing" in meta { pad(left: sig-indent, inl(meta.closing)) ; v(0.5em) }
    #for b in need(meta, "signature") {
      block(above: 0.9em, pad(left: sig-indent, for l in b [ #inl(l) \ ]))
    }
  ]
}

#let mo-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Rule 84.03(b)(1): consecutively paginated at the bottom, the first page is page one.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.8em)
    #it.body
  ]
  show footnote.entry: it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption and title ----
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, strong(upper(need(meta, "court_line"))))
    v(0.2in)
    let sides = need(meta, "caption")
    let nlines = sides.map(s => s.names.len() + 1).sum() + sides.len() - 1
    grid(
      columns: (3.1in, 0.3in, 1fr),
      {
        for (i, side) in sides.enumerate() {
          if i > 0 { pad(left: 0.8in, [v.]) ; v(0.2em) }
          caption-side(side)
          v(0.2em)
        }
      },
      align(center, for _ in range(nlines + 3) [) \ ]),
      pad(top: 2.2em, [Case No. #need(meta, "case_number")]),
    )
    v(0.15in)
    align(center, strong(inl(need(meta, "title"))))
    v(0.1in)
  }

  // Body, then signature block; certificate of service after it.
  let cut = body.position("\n# Certificate")
  let main-part = if cut == none { body } else { body.slice(0, cut) }
  let certs = if cut == none { "" } else { body.slice(cut) }
  cmarker.render(main-part, raw-typst: false, smart-punctuation: true)

  v(0.3in)
  signature-block(meta)

  if certs.len() > 0 {
    v(0.3in)
    {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.8em)
      cmarker.render(certs, raw-typst: false, smart-punctuation: true)
    }
  }
}
