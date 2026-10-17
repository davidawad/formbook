// Complaint in an adversary proceeding, United States Bankruptcy Court, District of Wyoming.
// Rules: LBR 9004-1 (form), FRBP 9004(b) (caption), FRBP 7010 and Fed. R. Civ. P. 10(b) (numbered
// paragraphs), FRBP 7008(a) (consent to final orders). Sources and dates: ../README.md.
#import "@preview/cmarker:0.1.10"

// ---- rule parameters (every number traces to a rule; see README.md) ----
#let font-family = "Liberation Serif"     // Times New Roman substitute, the default per docs/FONTS.md
#let body-size = 13pt                     // LBR 9004-1(A): typewritten text not less than 13 point
#let small-size = 11pt                    // LBR 9004-1(A): counsel headings not smaller than 10 point
#let body-leading = 1.345em               // double spacing: Liberation Serif's line box is 0.655em, so this is a 2.0em pitch
#let single-leading = 0.495em              // single spacing for counsel, caption, signature (about 1.15em pitch)
#let margin-top = 1in                     // LBR 9004-1(A): top margin one inch
#let margin-side = 1in
#let margin-bottom = 1in
#let para-indent = 0.5in                  // first-line indent of numbered paragraphs
#let caption-left = 3.4in                 // width of the party column of the caption
#let upper-letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Inline or block markdown from a string, with smart punctuation.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// The court's name is the court's, not the case's: it is fixed in this template.
#let court-title() = align(center)[
  #text(weight: "bold")[THE UNITED STATES BANKRUPTCY COURT] \
  #text(weight: "bold")[FOR THE DISTRICT OF WYOMING]
]

#let counsel-block(meta) = {
  set text(size: small-size)
  set par(leading: single-leading)
  let lines = meta.at("counsel", default: ()).map(l => [#md(l)]).join(linebreak())
  block(width: 100%, below: 1.5em)[
    #lines
    #if "client" in meta [
      \ #text(style: "italic")[#md(meta.client)]
    ]
  ]
}

// Caption: parties on the left (closed by a right rule and a bottom rule), case numbers on the right.
#let caption(meta) = {
  set par(leading: single-leading)
  let debtor = meta.at("debtor", default: ()).map(l => [#md(l)]).join(linebreak())
  let parties = ()
  for (i, p) in meta.at("parties", default: ()).enumerate() {
    if i > 0 { parties.push(align(center)[v.]) }
    let names = p.at("names", default: ()).map(l => [#md(l)]).join(linebreak())
    parties.push(block(width: 100%)[
      #names \
      #h(2in) #md(p.at("designation", default: ""))
    ])
  }
  let case-lines = ()
  for key in ("bankruptcy_case", "chapter", "adversary", "judge") {
    if key in meta { case-lines.push(md(meta.at(key))) }
  }
  grid(
    columns: (caption-left, 1fr),
    gutter: 0.3in,
    block(width: 100%, inset: (right: 0.2in, bottom: 0.2in), stroke: (right: 0.6pt, bottom: 0.6pt))[
      #debtor
      #v(1.2em)
      #parties.join(v(0.9em))
    ],
    block(width: 100%, inset: (top: 0.2in))[
      #case-lines.join(v(0.6em))
    ],
  )
}

// A paragraph chunk (plain text with inline markdown). Numbered unless it is the WHEREFORE lead-in.
#let numbered-para(n, text) = [
  #h(para-indent) #n.#h(0.6em) #md(text)
]

#let unnumbered-para(text) = [
  #h(para-indent) #md(text)
]

#let lettered-item(letter, text) = [
  #h(para-indent) #letter.#h(0.6em) #md(text)
]

// Headings stay with the paragraph after them (sticky), so a heading never ends a page.
// above/below are one double-spaced pitch (the leading), so a heading sits on the same grid as the text.
#let heading-1(s) = block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
  #align(center)[#text(weight: "bold")[#md(s)]]
]

#let heading-2(s) = block(width: 100%, above: 0pt, below: body-leading, sticky: true)[
  #align(center)[#md(s)]
]

// Walk the body in blank-line chunks, numbering paragraphs (Fed. R. Civ. P. 10(b)) and
// lettering prayer items; the counters live in this function, so the output is deterministic.
// Paragraphs before the first heading are the unnumbered lead-in; so is the WHEREFORE paragraph.
#let render-body(body) = {
  let chunks = body.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let out = ()
  let n = 0
  let letter = 0
  let in-body = false
  for c in chunks {
    if c.starts-with("## ") {
      out.push(heading-2(c.slice(3)))
      in-body = true
    } else if c.starts-with("# ") {
      out.push(heading-1(c.slice(2)))
      in-body = true
      letter = 0
    } else if c.starts-with("- ") {
      out.push(lettered-item(upper-letters.at(letter), c.slice(2)))
      letter = letter + 1
    } else if c.starts-with("WHEREFORE") or not in-body {
      out.push(unnumbered-para(c))
      letter = 0
    } else {
      n = n + 1
      out.push(numbered-para(n, c))
    }
  }
  out.join(v(0.0em))
}

// The date and signature stay together (LBR 9004-1: names typed under the signature line).
#let signature-block(meta) = block(width: 100%, breakable: false)[
  #let sig = meta.at("signature", default: none)
  #if "date" in meta { block(width: 100%, above: body-leading, below: body-leading)[#md(meta.date)] }
  #if sig != none {
    set par(leading: single-leading)
    align(right)[
      #block(width: 3.2in)[
        #if "firm" in sig [#md(sig.firm) \ ]
        #v(1.2em)
        /s/ #sig.signer \
        #text(size: body-size)[#sig.signer] \
        #for l in sig.at("lines", default: ()) [
          #text(style: "italic", size: small-size)[#md(l)] \
        ]
      ]
    ]
  }
]

#let wyb-adversary-complaint(meta, body) = {
  set document(title: meta.at("title", default: "Complaint"))
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer: context align(center, text(size: small-size)[#counter(page).display()]),
  )
  set text(font: font-family, size: body-size, lang: "en", hyphenate: false)
  // paragraph spacing equals the leading: between paragraphs the next line sits one double-spaced pitch below
  set par(justify: false, leading: body-leading, first-line-indent: 0pt, spacing: body-leading)

  counsel-block(meta)
  court-title()
  v(1.2em)
  caption(meta)
  v(1.2em)
  align(center)[#text(weight: "bold")[#md(meta.at("title", default: "COMPLAINT"))]]
  v(0.6em)
  render-body(body)
  signature-block(meta)
}
