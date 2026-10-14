// Adversary complaint, United States Bankruptcy Court, District of the Virgin Islands (vib).
//
// Rule-driven and content-agnostic. Requirement IDs (VIB-AC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (markdown contract: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // VIB-AC-FONT: vendored in /fonts, the only font typst can see.
#let type-size = 13pt                    // VIB-AC-FONT: LBR 5005-1(B) "no smaller than 12 Courier or an equivalent"; EB Garamond needs 13 pt for Courier-12 x-height.
#let body-leading = 0.85em               // VIB-AC-SPACING: double-spaced body (the filed exemplar's line pitch is about twice the type size).
#let page-margin = 1in                   // VIB-AC-MARGIN: letter paper, one-inch margins on every side.
#let para-indent = 0.5in                 // first-line indent of unnumbered paragraphs.
#let number-width = 0.5in                // width of the paragraph-number box.

#let para-counter = counter("vib-complaint-paragraph")

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("vib-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Numbered paragraphs. cmarker hands each markdown list item here; every item is one
/// paragraph, numbered from a counter that runs through the whole document, so numbering
/// continues across headings (VIB-AC-NUMBER, LBR 5005-1(A): all paragraphs in all pleadings
/// are sequentially numbered; FRCP 10(b)). Sub-items are written inline as (a), (b), ...
#let numbered-paragraphs(..items) = {
  for it in items.pos() {
    para-counter.step()
    context block(width: 100%, above: body-leading, below: 0pt, {
      h(para-indent)
      box(width: number-width)[#para-counter.get().first().]
      it
    })
  }
}

// ---------------------------------------------------------------------------
// Caption (VIB-AC-CAPTION: Form 416 layout, FRBP 7010, FRBP 9004(b), LBR 7008-1(A))
// ---------------------------------------------------------------------------

#let party-lines(names) = names.map(n => inl(n)).join(linebreak())

#let caption-block(meta) = {
  set par(first-line-indent: 0pt)
  let debtor = need(meta, "debtor")
  let adv = need(meta, "adversary")
  let sides = need(meta, "caption")
  let plaintiff = sides.at(0)
  let defendant = sides.at(1)
  let indent-designation = 1.2in
  table(
    columns: (3.45in, 1fr),
    stroke: none,
    inset: 0pt,
    table.hline(y: 0, end: 1, stroke: 0.7pt),
    table.vline(x: 1, stroke: 0.7pt),
    table.hline(y: 1, end: 1, stroke: 0.7pt),
    table.hline(y: 2, end: 1, stroke: 0.7pt),
    // row 0: debtor, with the chapter and case number on the right
    pad(top: 0.5em, bottom: 0.9em, right: 0.25in)[
      In re:#linebreak()#v(0.5em)
      #party-lines(debtor.names)#linebreak()
      #h(indent-designation)#debtor.designation
    ],
    pad(top: 0.5em, bottom: 0.9em, left: 0.25in)[
      #need(meta, "chapter")#v(1.2em)
      Case No. #need(meta, "case_number")
    ],
    // row 1: the adversary parties, with the adversary number on the right
    pad(top: 0.9em, bottom: 0.9em, right: 0.25in)[
      #party-lines(plaintiff.names)#linebreak()
      #h(indent-designation)#plaintiff.designation
      #v(0.6em)
      v.
      #v(0.6em)
      #party-lines(defendant.names)#linebreak()
      #h(indent-designation)#defendant.designation
    ],
    pad(top: 0.9em, bottom: 0.9em, left: 0.25in)[
      Adv. Proc. No. #adv.number
      #if "note" in adv [#v(0.6em) #adv.note]
    ],
  )
}

#let court-header(meta) = {
  set par(first-line-indent: 0pt)
  align(center)[
    #text(weight: "bold")[IN THE DISTRICT COURT OF THE VIRGIN ISLANDS]#linebreak()
    #text(weight: "bold")[DIVISION OF #upper(need(meta, "division")), BANKRUPTCY DIVISION]
  ]
}

#let title-block(meta) = {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", upper(need(meta, "title"))))
}

// ---------------------------------------------------------------------------
// Signature block (VIB-AC-SIGNATURE, FRBP 9011 signing convention)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  set par(first-line-indent: 0pt)
  let groups = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    [Dated: #need(meta, "date")]
    for (i, g) in groups.enumerate() {
      if i > 0 { v(1.0em); pad(left: 3.0in)[\- and –]; v(0.8em) }
      block(breakable: false, pad(left: 3.0in, {
        if "signer" in g [By: /s/ #g.signer#linebreak()]
        else [#v(0.8em)]
        for l in g.lines { [#inl(l)#linebreak()] }
      }))
    }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let complaint(meta, md) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context [
      #set text(size: type-size, font: font-family)
      #grid(
        columns: (1fr, auto),
        [#upper(if "footer" in meta { meta.footer } else { need(meta, "title") })],
        [Page #counter(page).display() of #counter(page).final().first()],
      )
    ],
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  set par(leading: body-leading, justify: false, first-line-indent: para-indent)

  // Headings: centered and bold; the complaint's headings are not numbered.
  show heading.where(level: 1): it => block(above: 1.3em, below: 1.0em, sticky: true, width: 100%,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(above: 1.1em, below: 1.0em, sticky: true, width: 100%,
    align(center, text(size: type-size, weight: "bold", it.body)))

  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: 0.55em, first-line-indent: 0pt)

  court-header(meta)
  v(1.6em)
  caption-block(meta)
  v(1.6em)
  title-block(meta)
  v(0.6em)

  cmarker.render(md, raw-typst: false, smart-punctuation: true,
    set-document-title: false, scope: (enum: numbered-paragraphs))

  signature-block(meta)
}
