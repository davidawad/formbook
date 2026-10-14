// Motion with memorandum of law, United States Bankruptcy Court, District of the Virgin Islands (vib).
//
// Rule-driven and content-agnostic. Requirement IDs (VIB-MB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // VIB-MB-FONT: vendored in /fonts, the only font typst can see.
#let type-size = 13pt                    // VIB-MB-FONT: LBR 5005-1(B) "no smaller than 12 Courier or an equivalent"; 13 pt EB Garamond matches Courier-12 x-height.
#let body-leading = 0.85em               // VIB-MB-SPACING: double-spaced body.
#let page-margin = 1in                   // VIB-MB-MARGIN: letter paper, one-inch margins on every side.
#let para-indent = 0.5in                 // first-line indent of body paragraphs.
#let level-step = 0.5in                  // each heading level below the first is indented one step.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("vib-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Per-level heading counters for levels 2-5 (level 1 is an unnumbered section). Explicit counters,
/// not the built-in heading counter, so a level-3 heading under a level-1 section still counts A., B., ...
#let hcount = (counter("vib-h2"), counter("vib-h3"), counter("vib-h4"), counter("vib-h5"))

/// The label of a numbered heading (the author never types numbers): level 2 is I., level 3 is A.,
/// level 4 is 1., level 5 is a. (VIB-MB-HEADINGS). Level 1 is unnumbered.
#let label-for(level, i) = {
  if level == 2 { numbering("I.", i) }
  else if level == 3 { numbering("A.", i) }
  else if level == 4 { numbering("1.", i) }
  else { numbering("a.", i) }
}

#let heading-label(h) = {
  if h.level == 1 or h.level > 5 { none } else {
    // counter.at(location) is the value before this heading steps its level, so its own number is +1
    label-for(h.level, hcount.at(h.level - 2).at(h.location()).first() + 1)
  }
}

// ---------------------------------------------------------------------------
// Caption (VIB-MB-CAPTION: Form 416 layout, FRBP 7010, FRBP 9004(b), LBR 7008-1(A))
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
    columns: (3.9in, 1fr),
    stroke: none,
    inset: 0pt,
    table.hline(y: 0, end: 1, stroke: 0.7pt),
    table.vline(x: 1, stroke: 0.7pt),
    table.hline(y: 1, end: 1, stroke: 0.7pt),
    table.hline(y: 2, end: 1, stroke: 0.7pt),
    pad(top: 0.4em, bottom: 0.6em, right: 0.25in)[
      In re:#linebreak()#v(0.5em)
      #party-lines(debtor.names)#linebreak()
      #h(indent-designation)#debtor.designation
    ],
    pad(top: 0.4em, bottom: 0.6em, left: 0.25in)[
      #need(meta, "chapter")#v(1.2em)
      Case No. #need(meta, "case_number")
    ],
    pad(top: 0.6em, bottom: 0.6em, right: 0.25in)[
      #party-lines(plaintiff.names)#linebreak()
      #h(indent-designation)#plaintiff.designation
      #v(0.6em)
      v.
      #v(0.6em)
      #party-lines(defendant.names)#linebreak()
      #h(indent-designation)#defendant.designation
    ],
    pad(top: 0.6em, bottom: 0.6em, left: 0.25in)[
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

/// The cover's counsel blocks, lower right (as the filed brief has them; LBR 9013-1, FRBP 9011).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt)
  pad(left: 2.3in, {
    for g in need(meta, "counsel") {
      block(breakable: false, above: 0.6em, {
        text(weight: "bold", upper(g.firm))
        for l in g.lines { [#linebreak()#inl(l)] }
      })
    }
  })
}

// ---------------------------------------------------------------------------
// Signature block (VIB-MB-SIGNATURE, FRBP 9011 signing convention)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  set par(first-line-indent: 0pt)
  let groups = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    [Dated: #need(meta, "date")]
    v(0.6em)
    pad(left: 3.0in)[Respectfully submitted,]
    for (i, g) in groups.enumerate() {
      if i > 0 { v(1.0em); pad(left: 3.0in)[\- and –]; v(0.6em) } else { v(0.8em) }
      block(breakable: false, pad(left: 3.0in, {
        if "signer" in g [/s/ #g.signer#linebreak()]
        for l in g.lines { [#inl(l)#linebreak()] }
      }))
    }
  })
}

// ---------------------------------------------------------------------------
// Table of contents: every heading of levels 1-4, dot leaders, page numbers
// ---------------------------------------------------------------------------

#let toc-section() = {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(1.2em)
  show outline.entry: it => {
    let hd = it.element
    let lab = heading-label(hd)
    let ind = (hd.level - 1) * level-step
    pad(left: ind, bottom: 0.45em, link(hd.location(), grid(
      columns: (level-step, 1fr),
      if lab == none [] else [#lab],
      [#hd.body#box(width: 1fr, repeat[.#h(0.2em)])#it.page()],
    )))
  }
  outline(title: none, depth: 4, indent: 0pt)
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let motion(meta, md) = {
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

  show heading: it => {
    if it.level == 1 {
      block(above: 1.3em, below: 1.0em, sticky: true, width: 100%,
        align(center, text(size: type-size, weight: "bold", upper(it.body))))
    } else {
      // Step this level and restart the deeper ones (VIB-MB-HEADINGS). The label is read in-flow,
      // after the step, so it shows this heading's own number.
      hcount.at(it.level - 2).step()
      for k in range(it.level - 1, 4) { hcount.at(k).update(0) }
      let ind = (it.level - 2) * level-step
      context block(above: 1.1em, below: 1.0em, sticky: true, width: 100%,
        pad(left: ind, grid(
          columns: (level-step, 1fr),
          [#label-for(it.level, hcount.at(it.level - 2).get().first())],
          if it.level <= 3 [#text(weight: "bold", it.body)] else [#it.body],
        )))
    }
  }
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: 0.55em, first-line-indent: 0pt)

  // Cover: court, caption, title, counsel.
  set par(first-line-indent: 0pt)
  court-header(meta)
  v(0.6em)
  caption-block(meta)
  v(0.6em)
  align(center, text(weight: "bold", upper(need(meta, "title"))))
  v(0.5em)
  counsel-block(meta)
  pagebreak()

  toc-section()
  pagebreak()

  set par(first-line-indent: para-indent)
  cmarker.render(md, raw-typst: false, smart-punctuation: true, set-document-title: false)

  signature-block(meta)
}
