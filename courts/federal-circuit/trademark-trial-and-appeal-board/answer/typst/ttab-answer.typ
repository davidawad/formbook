// Trademark Trial and Appeal Board: inter partes paper (answer, answer and counterclaim, and other
// pleadings and motions that carry the standard Board caption).
//
// Rule-driven and content-agnostic. Requirement IDs (TTAB-...) refer to ../rules.md.
// No case-specific text. The body is markdown rendered by cmarker; the caption, signature block and
// certificate of service come from the YAML frontmatter of the same file (schema: ../README.extra.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // the rule names no face (TTAB-FORM-006); metric-compatible with Times New Roman, vendored (OFL). `--input font=...` overrides it.
#let type-size = 12pt                     // TTAB-FORM-001: at least 11-point (the template uses 12)
#let body-leading = 1.39em                // TTAB-FORM-002: with the ascender/descender line extent this gives a baseline
                                          // pitch of 27.6 pt at 12 pt, the same as Word's "double" for Times New Roman.
#let single-leading = 0.2em               // caption, block quotations, signature block, certificate.
#let page-margin = 1in                    // TTAB-FORM-005 (convention; the Board states no margin)
#let para-indent = 0.5in
#let letter-width = 8.5in
#let letter-height = 11in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("ttab-answer: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-answer: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (TTAB-COVER-001, -002, -010, TTAB-CONT-002; TBMP 311.01(a), 309.02(a))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let plaintiff = need(meta, "plaintiff")
  let defendant = need(meta, "defendant")
  let matter = need(meta, "matter")
  let kind = meta.at("kind", default: "opposition")
  let number-label = if kind == "cancellation" { "Cancellation No." } else { "Opposition No." }
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.7em)
  align(center)[
    #strong[IN THE UNITED STATES PATENT AND TRADEMARK OFFICE] \
    #strong[BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD]
  ]
  v(1.1em)
  grid(
    columns: (64%, 36%),
    column-gutter: 0pt,
    // left cell: matter lines and the parties; a rule down its right edge and along its foot
    block(
      stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: 0.7em, bottom: 0.9em),
      width: 100%,
      {
        for l in matter { par(inl(l)) }
        v(0.6em)
        par(inl(plaintiff.name))
        pad(left: 2.2em, par(inl(plaintiff.role)))
        pad(left: 1.1em, par(emph[v.]))
        par(inl(defendant.name))
        pad(left: 2.2em, par(inl(defendant.role)))
      },
    ),
    // right cell: the proceeding number, vertically centred against the parties
    align(horizon, pad(left: 1.1em)[
      #number-label #need(meta, "proceeding_number")
    ]),
  )
  v(1.4em)
  align(center, text(weight: "bold", underline(inl(need(meta, "title")))))
  v(0.9em)
}

// ---------------------------------------------------------------------------
// Signature block (TTAB-CERT-001 to -003, -030; 37 CFR 2.119(e), 2.193(c), (d))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.45em)
  block(breakable: false, width: 100%, {
    par(inl("Dated: " + sig.date))
    v(0.5em)
    pad(left: 3.25in, {
      par(inl("Respectfully submitted,"))
      v(0.3em)
      par(strong(inl(sig.firm)))
      v(1.1em)
      par(inl(sig.esign))
      line(length: 100%, stroke: 0.5pt)
      par(inl(sig.name))
      par(inl(sig.title))
      for l in sig.at("lines", default: ()) { par(inl(l)) }
    })
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (TTAB-CERT-004, -005, -031; 37 CFR 2.119(a), (b); TBMP 113.03)
// ---------------------------------------------------------------------------

#let certificate-of-service(meta) = {
  let sv = need(meta, "service")
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.7em)
  align(center, text(weight: "bold", underline[CERTIFICATE OF SERVICE]))
  v(0.6em)
  let by = if sv.at("method", default: "email") == "email" { "by email" } else { sv.method }
  par(justify: false, first-line-indent: para-indent, {
    [I hereby certify that on ]
    inl(sv.date)
    [, a true and complete copy of the foregoing ]
    inl(sv.paper)
    [ was served #by on:]
  })
  for r in sv.recipients {
    pad(left: para-indent, {
      block(breakable: false, {
        par(inl(r.name + ", " + r.role))
        for l in r.at("lines", default: ()) { par(inl(l)) }
        par(inl(r.email))
      })
    })
  }
  v(0.8em)
  block(breakable: false, width: 100%, pad(left: 3.25in, {
    par(inl(sv.esign))
    line(length: 100%, stroke: 0.5pt)
    par(inl(sv.name))
    par(inl(sv.title))
  }))
}

// ---------------------------------------------------------------------------
// The paper
// ---------------------------------------------------------------------------

#let ttab-answer(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    width: letter-width,
    height: letter-height,
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: sys.inputs.at("font", default: font-family), size: type-size, lang: "en", region: "US",
           top-edge: "ascender", bottom-edge: "descender", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)

  // Headings: level 1 centred bold capitals-as-typed; level 2 bold; level 3 italic. No numbering.
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(width: 100%, above: 1.6em, below: 1.0em, breakable: false, sticky: true,
      align(center, text(weight: "bold", size: type-size, it.body)))
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(width: 100%, above: 1.3em, below: 0.9em, breakable: false, sticky: true,
      text(weight: "bold", size: type-size, it.body))
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(width: 100%, above: 1.1em, below: 0.8em, breakable: false, sticky: true,
      text(style: "italic", size: type-size, it.body))
  }

  // Drafting markers: a paragraph that is entirely bold text beginning with "[" is a drafting note
  // (for example "[CONFORM: ...]"). It is set flush left, single-spaced, in italics. TTAB-TOOL-002.
  show strong: it => if plain(it.body).starts-with("[") {
    block(width: 100%, above: 0.9em, below: 0.9em, breakable: false, sticky: true, {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.7em)
      text(style: "italic", weight: "regular", it.body)
    })
  } else { it }

  // Block quotations: indented both sides, single-spaced.
  show quote.where(block: true): it => {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.7em)
    block(above: 0.9em, below: 1.0em, inset: (left: 1in, right: 1in), it.body)
  }

  // Numbered paragraphs: the number sits at the first-line indent; wrapped lines return to the margin.
  // (Rendered by hand from the enum's children: typst's own enum layout hangs the body.)
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      let k = if item.has("number") and item.number != auto { item.number } else { n }
      [#k.#h(0.55em)#item.body]
      parbreak()
      n = k + 1
    }
  }

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  v(1.6em)
  signature-block(meta)
  if "service" in meta {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
