// Minnesota Court of Appeals (minnctapp): motion with supporting argument (motion-brief).
//
// Content-agnostic. Numbers trace to Minn. R. Civ. App. P. 132.02 (documents other than formal
// briefs: 13-point, double spaced, pages numbered at the center of the bottom margin, caption with
// court, title of the case, docket number and descriptive title), 127 (motions) and 132.04
// (signature); see ../../rules.md. No case-specific text, measured coordinates or forced breaks.

#import "@preview/cmarker:0.1.10"

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 132 names no face (docs/FONTS.md).
#let type-size = 13pt                      // Rule 132.02 subd. 1: at least 13-point.
#let double-leading = 1.61em               // Rule 132.02 subd. 1: double spaced (pitch = 2 x 1.15 em single).
#let single-leading = 0.46em               // single-spaced caption, block quotes, footnotes, signature.
#let page-margin = 1in                     // Rule 132.02 subd. 1: typewritten matter not over 6-1/2 x 9-1/2 in.
#let para-indent = 0.5in
#let sig-indent = 3.2in

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("minnctapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("minnctapp-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let party(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  pad(left: 1.4in, inl(side.designation))
}

#let minnctapp-motion(meta, body) = {
  set document(title: need(meta, "doc_title"))
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.25in, strong(upper(it.body)))
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, strong(emph(it.body)))
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption (Rule 132.02 subd. 2) ----
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, strong(inl(need(meta, "court_line"))))
    v(0.6em)
    line(length: 100%, stroke: 0.5pt)
    v(0.4em)
    grid(columns: (1fr, 1fr), column-gutter: 0.3in,
      {
        for (i, side) in need(meta, "caption").enumerate() {
          if i > 0 { pad(left: 0.7in, [v.]) }
          v(0.6em)
          party(side)
          v(0.6em)
        }
      },
      {
        strong[#need(meta, "case_number")]
        v(1.2em)
        align(center, strong(inl(need(meta, "doc_title"))))
      })
    line(length: 100%, stroke: 0.5pt)
    v(0.8em)
  }

  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  cmarker.render(text + notes, raw-typst: false, smart-punctuation: true)

  // ---- Signature (Rule 132.04) ----
  v(0.4in)
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #pad(left: sig-indent, inl(sig.closing))
    #v(0.2em)
    #grid(columns: (sig-indent, 1fr),
      inl(need(meta, "date")),
      [
        #underline[/s/ #inl(sig.signer)] \
        #for l in sig.lines [ #inl(l) \ ]
      ])
  ]
}
