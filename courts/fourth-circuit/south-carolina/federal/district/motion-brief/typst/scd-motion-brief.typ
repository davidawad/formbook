// D.S.C. memorandum in support of a motion (FRCP 12(b)). Rules: FRCP 7(b), 10(a)-(b); D.S.C. Local
// Civ. Rule 1.05 (format of filed motions and supporting memoranda); Local Civ. Rule 7.05(A)-(B)
// (contents; 35 double-spaced pages for an initial brief). Content-agnostic: everything case-specific
// comes from the sample's frontmatter and body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/word-compat.typ": word-compat

// ---- rule parameters ----
// L.R. 1.05(B) requires Times New Roman, Arial or Courier New. Times New Roman is the face used here;
// its vendored metric-compatible substitute is Liberation Serif (docs/FONTS.md, substitution table).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                 // L.R. 1.05(C): minimum 12-point type
#let margin = 1in                     // L.R. 1.05(A): minimum one-inch margins
#let double-leading = 1.6em           // L.R. 1.05(E): double-spaced text (calibrated: about 27pt pitch at 12pt, see README.md)
#let single-leading = 0.2em
#let para-indent = 0.5in

/// Split the YAML frontmatter from the markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Court heading, centered, in capitals (FRCP 10(a): name of the court).
#let court-heading(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, strong(meta.court.map(upper).join(linebreak())))
  v(1.5em)
}

/// Caption (FRCP 10(a)): parties on the left, a column of ")" marks, the case number on the right.
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  let rows = meta.parties
  grid(
    columns: (1fr, 0.3in, 2.6in),
    align: (left, center, left),
    stack(dir: ttb, spacing: 0.9em, ..rows.map(r => pad(left: r.indent * 0.5in)[#cmarker.render(r.text, raw-typst: false, smart-punctuation: true)])),
    stack(dir: ttb, spacing: 0.9em, ..rows.map(r => [)])),
    stack(dir: ttb, spacing: 0.9em, [CASE NO.: #meta.case_number]),
  )
  v(1.5em)
}

/// Signature block: the signing attorneys (FRCP 11(a)), then the firm and the place and date.
#let signature(meta) = block(width: 100%, breakable: false, {
  set par(leading: single-leading, first-line-indent: 0pt)
  v(1.5em)
  grid(
    columns: (1fr, 3.2in),
    [#meta.signature.location \ #meta.signature.dated],
    [
      #for s in meta.signature.signers [#s \ ]
      #v(0.6em)
      #for l in meta.signature.firm [#l \ ]
    ],
  )
})

/// The document.
#let scd-motion-brief(meta, md) = {
  set document(title: meta.doc_title + ", " + meta.case_number)
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: double-leading, first-line-indent: (amount: para-indent, all: true))
  // Word paragraph composition (lib/typst/word-compat.typ); the INPUT's `word:` map sets justify/shrink.
  show: word-compat.with(meta.at("word", default: (:)))

  // headings: level 1 and 2 centered bold capitals (sections); level 3 left bold (subsections, as in the exemplar)
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 1.2em, below: 0.9em, align(center, text(size: type-size, strong(upper(it.body)))))
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 1.2em, below: 0.9em, align(center, text(size: type-size, strong(upper(it.body)))))
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 1em, below: 0.9em, text(size: type-size, strong(it.body)))
  }

  court-heading(meta)
  caption(meta)
  align(center, block(above: 0.5em, below: 1.2em, strong(upper(meta.doc_title))))

  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature(meta)
}
