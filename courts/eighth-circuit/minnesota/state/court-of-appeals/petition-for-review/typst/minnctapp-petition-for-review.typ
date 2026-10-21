// Minnesota Court of Appeals (minnctapp): petition for declaratory judgment on an agency rule
// (petition-for-review). Rules 114.01-114.02 and 132.02 (Minnesota Rules of Civil Appellate
// Procedure, https://www.revisor.mn.gov/court_rules/ap/subtype/rcap/id/114/ and .../132/; see
// ../../rules.md). Content-agnostic: no case text, no measured coordinates, no forced breaks.
// A captioned document without cover or contents (Rule 132.02 subd. 2: court, title of the case,
// docket number, brief descriptive title).

#import "@preview/cmarker:0.1.10"

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 132.02 names no face; Times New Roman first, Liberation Serif its metric twin.
#let type-size = 13pt                      // Rule 132.02 subd. 1: at least 13-point type.
#let double-leading = 1.61em               // Rule 132.02 subd. 1: double spaced (pitch = 2 x 1.15 em).
#let single-leading = 0.46em               // caption, quotations, footnotes, signature single-spaced.
#let page-margin = 1in                     // Rule 132.02 subd. 1: typewritten matter not over 6-1/2 x 9-1/2 in.
#let para-indent = 0.5in
#let sig-indent = 3in

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("minnctapp-petition-for-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("minnctapp-petition-for-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let minnctapp-petition(meta, body) = {
  set document(title: need(meta, "title"))
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #strong(it.body)
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show footnote.entry: it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption (Rule 132.02 subd. 2) ----
  align(center, strong(inl(need(meta, "court_line"))))
  v(0.3em)
  line(length: 100%, stroke: 0.5pt)
  {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    grid(columns: (1.1fr, 1fr), column-gutter: 0.3in,
      {
        for (i, side) in need(meta, "caption").enumerate() {
          if i > 0 { v(0.5em); pad(left: 0.5in)[v.]; v(0.5em) }
          for n in side.names [ #inl(n) \ ]
          v(0.5em)
          align(right, inl(side.designation))
        }
      },
      {
        align(center, strong(upper(inl(need(meta, "title")))))
        for f in need(meta, "fields") { v(1.2em); strong(inl(f)); linebreak() }
      })
  }
  v(0.3em)
  line(length: 100%, stroke: 0.5pt)
  v(0.5em)

  // ---- Body: footnote definitions stay with the main text ----
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  cmarker.render(text + notes, raw-typst: false, smart-punctuation: true)

  // ---- Signature (Rule 132.04) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "closing" in meta [ #inl(meta.closing) \ ]
    #if "date" in meta [ #inl(meta.date) \ ]
    #v(0.4em)
    #if "signed_for" in meta [ #inl(meta.signed_for) #v(0.6em) ]
    #pad(left: sig-indent)[
      #for l in meta.signature.at("firm", default: ()) [ #inl(l) \ ]
      #v(0.8em)
      #underline[/s/ #inl(meta.signature.signer)] \
      #for l in meta.signature.at("lines", default: ()) [ #inl(l) \ ]
    ]
  ]
}
