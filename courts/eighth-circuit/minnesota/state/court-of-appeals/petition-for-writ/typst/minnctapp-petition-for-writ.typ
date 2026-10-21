// Minnesota Court of Appeals (minnctapp): petition for writ of mandamus or prohibition.
//
// Content-agnostic. Parameters trace to the Minnesota Rules of Civil Appellate Procedure
// (Revisor of Statutes, https://www.revisor.mn.gov/court_rules/ap/subtype/rcap/id/120/ and
// .../id/132/; see ../../rules.md): Rule 120.01 (petition contents), 120.04 and 132.02 (form of
// documents: 13-point, double spaced, caption, page numbers at the center of the bottom margin),
// 132.04 (signature). No case-specific text, no measured coordinates, no forced line breaks.

#import "@preview/cmarker:0.1.10"

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 132.02 names no face; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 132.02 subd. 1: at least 13-point type.
#let double-leading = 1.61em               // Rule 132.02 subd. 1: double spaced (pitch = 2 x single 1.15 em).
#let single-leading = 0.46em               // single pitch, for caption, quotations, footnotes, signature.
#let page-margin = 1in                     // Rule 132.02 subd. 1: written matter not over 6-1/2 x 9-1/2 in.
#let para-indent = 0.5in
#let sig-indent = 3.2in

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("minnctapp-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("minnctapp-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// Party block: names, then the designation indented, as in the filed caption.
#let party(side) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  for n in side.names [ #inl(n) \ ]
  v(0.5em)
  pad(left: 1.2in, inl(side.designation))
}

#let minnctapp-petition(meta, body) = {
  set document(title: need(meta, "title"))
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 2): it => block(width: 100%, above: 0.4em, below: 0.4em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #set text(weight: "regular")
    #pad(left: 0.5in, it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 0.4em, below: 0.4em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #set text(weight: "regular")
    #pad(left: 0.5in, it.body)
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show footnote.entry: it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption (Rule 132.02 subd. 2: court, title of the case, docket number, descriptive title) ----
  {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    align(center, strong(inl(need(meta, "court_line"))))
    v(0.3em)
    line(length: 100%, stroke: 0.5pt)
    v(0.5em)
    grid(columns: (1fr, 1fr), column-gutter: 0.3in,
      {
        for (i, side) in need(meta, "caption").enumerate() {
          if i > 0 { v(0.6em) }
          if "between" in side { block(inl(side.between)); v(0.6em) }
          party(side)
        }
      },
      {
        strong(inl(need(meta, "title")))
        v(0.3em)
        for l in meta.at("title_notes", default: ()) [ #inl(l) \ ]
        v(0.8em)
        for f in meta.at("fields", default: ()) [
          #inl(f.label) \
          #if "value" in f [ #inl(f.value) \ ]
          #v(0.5em)
        ]
      })
    v(0.3em)
    line(length: 100%, stroke: 0.5pt)
    v(0.8em)
  }

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature (Rule 132.04) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: 0pt, inl(need(meta, "date")))
    #v(0.2in)
    #pad(left: sig-indent)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #underline[#inl("/s/ " + need(meta, "signer"))] \
      #for l in meta.at("signature_lines", default: ()) [ #inl(l) \ ]
    ]
  ]
  if "of_counsel" in meta {
    v(0.2in)
    block(width: 100%, breakable: false)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #pad(left: sig-indent)[
        OF COUNSEL: \ \
        #for l in meta.of_counsel [ #inl(l) \ ]
      ]
    ]
  }
}
