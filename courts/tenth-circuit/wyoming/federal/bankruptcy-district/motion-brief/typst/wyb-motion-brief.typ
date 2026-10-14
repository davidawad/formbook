// Memorandum in support of a dispositive motion in an adversary proceeding, United States
// Bankruptcy Court, District of Wyoming. Rules: LBR 9013-1(A)(2) (separate memorandum with a
// dispositive motion in an adversary), LBR 9013-2 (memorandum, 20-page limit), LBR 9013-3
// (certificate of service), LBR 9004-1 (form). Sources and dates: ../README.md.
#import "@preview/cmarker:0.1.10"

// ---- rule parameters (every number traces to a rule; see README.md) ----
#let font-family = "EB Garamond"          // vendored in fonts/; the only font (system fonts are ignored)
#let body-size = 13pt                     // LBR 9004-1(A): typewritten text not less than 13 point
#let small-size = 11pt                    // LBR 9004-1(A): counsel headings not smaller than 10 point
#let body-leading = 1.35em                // double spacing: EB Garamond's line box is 0.65em, so this is a 2.0em pitch
#let single-leading = 0.5em               // single spacing for counsel, caption, signature, certificate
#let margin-top = 1in                     // LBR 9004-1(A): top margin one inch
#let margin-side = 1in
#let margin-bottom = 1in
#let para-indent = 0.5in                  // first-line indent of body paragraphs
#let caption-left = 3.4in                 // width of the party column of the caption

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Inline or block markdown from a string, with smart punctuation.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// The court's name is the court's, not the case's: it is fixed in this template.
#let court-title() = align(center)[
  #text(weight: "bold")[IN THE UNITED STATES BANKRUPTCY COURT] \
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

// One caption group: names, each on its own line, then the designation indented.
#let caption-group(p) = {
  let names = p.at("names", default: ()).map(l => [#md(l)]).join(linebreak())
  block(width: 100%)[
    #names \
    #h(1.2in) #md(p.at("designation", default: ""))
  ]
}

// Caption: parties on the left (closed by a right rule and a bottom rule), case numbers on the right.
// Third-party parties follow a rule inside the left column.
#let caption(meta) = {
  set par(leading: single-leading)
  let parties = ()
  for (i, p) in meta.at("parties", default: ()).enumerate() {
    if i > 0 { parties.push(align(center)[v.]) }
    parties.push(caption-group(p))
  }
  let third = ()
  for (i, p) in meta.at("third_party", default: ()).enumerate() {
    if i > 0 { third.push(align(center)[v.]) }
    third.push(caption-group(p))
  }
  let case-lines = ()
  for key in ("bankruptcy_case", "adversary") {
    if key in meta { case-lines.push(md(meta.at(key))) }
  }
  grid(
    columns: (caption-left, 1fr),
    gutter: 0.3in,
    block(width: 100%, inset: (right: 0.2in, bottom: 0.2in), stroke: (right: 0.6pt, bottom: 0.6pt))[
      #parties.join(v(0.9em))
      #if third.len() > 0 [
        #v(0.9em)
        #line(length: 100%, stroke: 0.6pt)
        #v(0.9em)
        #third.join(v(0.9em))
      ]
    ],
    block(width: 100%, inset: (top: 0.2in))[
      #case-lines.join(v(0.6em))
    ],
  )
}

// Body: blank-line chunks. Headings: "# " bold, "## " bold italic. Paragraphs: first-line indent,
// not numbered (a memorandum is not a pleading; the author writes any numbers, escaped: "1\.").
#let render-body(body) = {
  let chunks = body.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let out = ()
  for c in chunks {
    if c.starts-with("## ") {
      out.push(block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
        #text(weight: "bold", style: "italic")[#md(c.slice(3))]
      ])
    } else if c.starts-with("# ") {
      out.push(block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
        #text(weight: "bold")[#md(c.slice(2))]
      ])
    } else {
      out.push([#h(para-indent) #md(c)])
    }
  }
  out.join(parbreak())
}

// Date and signature stay together (LBR 9004-1: names typed under the signature line).
#let signature-block(meta) = block(width: 100%, breakable: false)[
  #let sig = meta.at("signature", default: none)
  #if "date" in meta { block(width: 100%, above: body-leading, below: body-leading)[#md(meta.date)] }
  #if sig != none {
    set par(leading: single-leading)
    align(right)[
      #block(width: 3.2in)[
        #for s in sig.at("signatures", default: ()) [#md(s) \ #v(0.6em)]
        #for l in sig.at("lines", default: ()) [
          #text(size: small-size)[#md(l)] \
        ]
      ]
    ]
  }
]

// Certificate of service (LBR 9013-3): the date, the manner (CM/ECF), the persons served and
// their capacity, and the signer. Filed within seven days of service (LBR 9013-3).
#let certificate(meta) = {
  let svc = meta.at("service", default: none)
  if svc != none {
    block(width: 100%, breakable: false, above: body-leading)[
      #align(center)[#text(weight: "bold")[CERTIFICATE OF SERVICE]]
      #v(body-leading)
      #h(para-indent) I hereby certify that on #md(svc.date), I served a true and correct copy of the above and foregoing through the Case Management/Electronic Case Filing (CM/ECF) system of the United States Bankruptcy Court for the District of Wyoming, and the Notice of Electronic Filing of this document sent to the recipients below by the CM/ECF system constitutes service.
      #v(body-leading)
      #set par(leading: single-leading)
      #for r in svc.at("recipients", default: ()) [
        #md(r) \
      ]
      #v(body-leading)
      #align(right)[
        #block(width: 3.2in)[
          /s/ #svc.signer \
          #svc.signer
        ]
      ]
    ]
  }
}

#let wyb-motion-brief(meta, body) = {
  set document(title: meta.at("title", default: "Memorandum"))
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
  align(center)[#text(weight: "bold")[#md(meta.at("title", default: "MEMORANDUM"))]]
  v(0.6em)
  render-body(body)
  signature-block(meta)
  certificate(meta)
}
