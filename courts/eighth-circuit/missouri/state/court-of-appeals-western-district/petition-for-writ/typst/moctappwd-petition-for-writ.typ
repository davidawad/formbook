// Missouri Court of Appeals, Western District (moctappwd): petition for writ.
//
// Content-agnostic. Numbers trace to Mo. Sup. Ct. R. 84.03(b) (effective January 1, 2024; see
// ../../rules.md). No case-specific text, no measured coordinates, no forced line breaks.
// The markdown body is rendered by cmarker; metadata is the YAML frontmatter of the sample.
// A writ petition has no cover or tables: the caption opens page one and the text follows.

#import "@preview/cmarker:0.1.10"

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 84.03(b)(3): Times New Roman.
#let type-size = 13pt                      // Rule 84.03(b)(3): not smaller than 13 point, footnotes included.
#let body-leading = 1.45em                 // Rule 84.03(b)(2): line spacing not less than 1.5. Pitch = 9.7/13 natural + leading; 1.5 x 1.15 x 13 pt = 22.4 pt.
#let single-leading = 0.4em                // single spacing: caption, headings, long quotations, footnotes, certificates, signature.
#let page-margin = 1in                     // Rule 84.03(b)(2): not less than one inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moctappwd-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("moctappwd-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption: party lines left, a column of ")" marks sized to the left column, case number beside "v.".
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
  let lines = need(meta, "caption")
  let left = block(width: 3.1in, for l in lines { par(inl(l)) })
  context {
    let line-h = measure(par(spacing: 0pt, leading: single-leading)[X]).height + single-leading.to-absolute()
    let h = measure(left).height
    let n = calc.ceil(h / line-h)
    grid(columns: (3.1in, 0.3in, 1fr),
      left,
      block(for i in range(n) [)\ ]),
      pad(top: h * 0.45, inl(need(meta, "case_number_line"))))
  }
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
    #v(0.6em)
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
  ])
}

#let moctappwd-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, bold, single-spaced. Level 2: sub-heading, bold, hanging.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 13 pt (Rule 84.03(b)(3)), single-spaced (Rule 84.03(b)(2)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }
  set footnote.entry(gap: 0.5em)

  // Court line and caption open page one.
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #strong[#need(meta, "court_line") \ #need(meta, "district_line")]
  ]
  v(1.2em)
  caption(meta)
  v(1.4em)
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #strong(underline(upper(inl(need(meta, "brief_title")))))
  ]
  v(0.8em)

  // Footnote definitions go with the main text, where their references are.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  cmarker.render(text + notes, raw-typst: false, smart-punctuation: true)

  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
