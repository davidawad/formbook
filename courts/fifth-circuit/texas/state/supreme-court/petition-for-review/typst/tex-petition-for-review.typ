#import "@preview/cmarker:0.1.10"

// Texas Rules of Appellate Procedure, Rule 9.4(c)-(e): letter paper, one-inch margins,
// double-spaced text in a conventional typeface of at least 14 point, footnotes of at
// least 12 point. Liberation Serif is the metric clone of Times New Roman, the face of
// the filed exemplars.
#let text-font = "Liberation Serif"
#let text-size = 14pt
#let note-size = 12pt

// Typst leading is the gap between lines. On this font the natural line height is
// 0.655 em, so 1.645 em gives a 32.2 pt baseline pitch (Word "double" at 14 pt) and
// 0.5 em gives a 16.2 pt single pitch. Measured with pdftotext -bbox; see README.md.
#let double = 1.645em
#let single = 0.5em

// Rule 9.4(i)(2): length limit for a petition for review, computer-generated.
#let word-limit = 4500

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("sample must start with YAML frontmatter") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Rule 9.4(i)(1), 2026 text: these sections are not counted. Everything else is,
// including headings, footnotes and quotations.
#let excluded-section = regex(
  "(?i)^(identit|table of contents|index of authorities|statement regarding oral argument|statement of the case|statement of jurisdiction|issues? presented|certificate|appendix)",
)

#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()

// Counts the words of every counted H1 section. The signature block after the prayer
// ("Respectfully submitted") is excluded.
#let word-count(main) = {
  let total = 0
  for chunk in main.split(regex("(?m)^# ")).slice(1) {
    let title = chunk.split("\n").first().trim()
    if title.find(excluded-section) != none { continue }
    total += count-words(chunk.split("Respectfully submitted").first())
  }
  total
}

#let cover(meta) = {
  set par(leading: single, first-line-indent: 0pt, justify: false)
  align(center)[No. #meta.case_number]
  v(0.45in)
  align(center)[#strong[IN THE SUPREME COURT OF TEXAS]]
  v(0.35in)
  for (i, side) in meta.caption.enumerate() {
    if i > 0 {
      v(0.2in)
      align(center)[v.]
      v(0.2in)
    }
    align(center)[#side]
  }
  v(0.35in)
  align(center)[#meta.on_review]
  v(0.35in)
  line(length: 100%, stroke: 0.75pt)
  v(0.2in)
  align(center)[#strong[#meta.title]]
  v(0.2in)
  line(length: 100%, stroke: 0.75pt)
  v(1fr)
  let lead = meta.lead_counsel
  align(left)[
    #for line in lead.address { line + linebreak() }
    #lead.name #linebreak()
    #lead.phone #linebreak()
    #lead.email #linebreak()
    Texas Bar No. #lead.bar_number
    #v(0.3in)
    #meta.filing_party
  ]
  if meta.at("oral_argument_requested", default: false) {
    v(0.4in)
    align(center)[#strong[ORAL ARGUMENT REQUESTED]]
  }
}

// Table of contents: generated from the headings, page numbers from the layout.
#let contents() = {
  align(center)[#strong[TABLE OF CONTENTS]]
  v(double)
  set par(leading: single, first-line-indent: 0pt, justify: false)
  show outline.entry: it => { block(above: 0.7em)[#it] }
  outline(title: none, depth: 2, indent: 2em)
}

// Index of authorities: entered in frontmatter (`authorities`), one entry per authority,
// pages given by the author from the rendered PDF.
#let authorities-page(groups) = {
  heading(level: 1)[INDEX OF AUTHORITIES]
  set par(leading: single, first-line-indent: 0pt, justify: false)
  for g in groups {
    block(above: double, below: single, sticky: true)[#strong(g.group)]
    for a in g.items {
      let name = if a.at("italic", default: false) { emph(a.name) } else { [#a.name] }
      block(above: 0.7em)[#name#a.rest #box(width: 1fr, repeat[.]) #a.pages]
    }
  }
}

#let render-doc(meta, body) = {
  let start = body.position(regex("(?im)^# " + meta.body_start + "[ \\t]*$"))
  assert(start != none, message: "body_start heading not found: " + meta.body_start)
  let front = body.slice(0, start)
  let main = body.slice(start)
  let words = word-count(main)
  assert(
    words <= word-limit,
    message: "word count " + str(words) + " exceeds the " + str(word-limit) + "-word limit of Rule 9.4(i)(2)",
  )
  let main = main.replace("{{word-count}}", str(words))

  set page(paper: "us-letter", margin: 1in, numbering: none)
  set text(font: text-font, size: text-size, lang: "en", hyphenate: false)
  set par(leading: double, spacing: double, justify: true, first-line-indent: 0.5in)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single, spacing: single, justify: false)
  show heading.where(level: 1): it => block(width: 100%, above: double, below: double, sticky: true)[
    #set par(leading: single, first-line-indent: 0pt, justify: false)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: double, below: double, sticky: true)[
    #set par(leading: single, first-line-indent: 0pt, justify: false)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: double, below: double, sticky: true)[
    #set par(leading: single, first-line-indent: 0pt, justify: false)
    #strong(emph(it.body))
  ]
  show quote.where(block: true): it => pad(left: 1in, right: 1in)[
    #set par(leading: single, spacing: double, first-line-indent: 0pt, justify: true)
    #it.body
  ]

  // Cover: page 1, no number.
  cover(meta)
  pagebreak()

  // Front matter: lower-roman numbers, starting at ii on the page after the cover.
  set page(numbering: "i")
  // Counsel lists are single-spaced, the way the filed exemplars set them.
  {
    set par(leading: single, spacing: 0.9em, first-line-indent: 0pt, justify: false)
    cmarker.render(front, smart-punctuation: true)
  }
  pagebreak()
  contents()
  pagebreak()
  authorities-page(meta.authorities)
  pagebreak()

  // Body: arabic numbers from 1.
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(main, smart-punctuation: true)
}
