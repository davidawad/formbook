// Supreme Court of South Dakota (sd): motion with supporting statement (motion-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (SDCL ch. 15-26A, https://sdlegislature.gov/api/Statutes/<section>.html, verified 2026-10-21; see
// ../../rules.md). No case-specific text, no coordinates measured off any filed paper, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
//
// A motion has no cover, table of contents or table of authorities: the court line and a boxed
// caption open the first page and the motion text follows. SDCL 15-26A-87.2 sets service and filing
// of motions but no layout; paper, type and margins follow the brief rules (SDCL 15-26A-66, -69).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // SDCL 15-26A-66(b): proportional serif face, no face named. Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // SDCL 15-26A-66(b): 12-point or larger.
#let double-leading = 1.61em               // SDCL 15-26A-69(2): double-spaced. Measured pitch = natural line box + leading = 2 x the 13.8 pt single line (1.15 em) of Times at 12 pt.
#let single-leading = 0.46em               // Quotations and the caption are single-spaced: 13.8 pt at 12 pt.
#let margin-left = 1.5in                   // SDCL 15-26A-69(3): left margin one and one-half inches.
#let margin-other = 1in                    // SDCL 15-26A-69(3): all other margins not less than one inch.
#let para-indent = 0.5in
#let sig-indent = 3in                      // signature blocks sit right of centre (style; exemplar does the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("sd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One party of the caption: the names flush left, then the designation indented.
#let caption-party(p) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  block(below: 1.2em)[
    #inl(p.names)
    #v(0.9em)
    #pad(left: 0.5in, inl(p.designation))
  ]
}

/// A dated signature block: the "Dated" line, then the lines of the signer, single-spaced.
#let signature-block(s) = {
  block(width: 100%, breakable: false, above: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #par(first-line-indent: 0pt, inl(s.dated))
    #v(1.6em)
    #pad(left: sig-indent, s.lines.map(l => inl(l)).join(linebreak()))
  ]
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let sd-motion(meta, body) = {
  set document(title: need(meta, "title"))
  // SDCL 15-26A-69(3): left margin 1.5 in, all other margins 1 in (bottom carries 4 pt extra so body
  // text stays clear of the 1 in margin). SDCL 15-26A-69(4): the number is centred at the bottom.
  set page(paper: "us-letter", margin: (left: margin-left, right: margin-other, top: margin-other, bottom: margin-other + 4pt), numbering: "1",
    footer: context {
      set par(leading: single-leading, first-line-indent: 0pt)
      align(center)[Page #counter(page).display() of #counter(page).final().first()]
    })
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // SDCL 15-26A-69(2): double-spaced; 15-26A-69(3): not right-justified.
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  // Numbered statements of the motion: double-spaced, indented, hanging number.
  set enum(indent: 0.5in, body-indent: 0.4em, spacing: double-leading)
  // Block quotations: indented, single-spaced (SDCL 15-26A-69(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.8em)
    #it.body
  ]
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Court line and boxed caption ----
  {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    align(center)[
      #for l in need(meta, "court_line") [ #strong(inl(l)) \ ]
    ]
    v(0.3in)
    line(length: 100%, stroke: 0.75pt)
    v(0.12in)
    grid(columns: (1.15fr, 1fr), column-gutter: 0.3in,
      [
        #for (i, p) in need(meta, "parties").enumerate() {
          if type(p) == str { block(below: 1.2em, inl(p)) } else { caption-party(p) }
        }
      ],
      [
        #inl(need(meta, "case_number"))
        #v(1.2em)
        #strong(inl(need(meta, "title")))
      ])
    v(0.8em)
    line(length: 100%, stroke: 0.75pt)
    v(0.2in)
  }

  // ---- Body. Signature blocks follow the closing request; the certificate of service starts a new
  // page (as filed).
  let cut = body.position("\n# CERTIFICATE")
  let main-part = if cut == none { body } else { body.slice(0, cut) }
  let certs = if cut == none { "" } else { body.slice(cut) }
  cmarker.render(main-part, raw-typst: false, smart-punctuation: true)

  v(0.2in)
  for s in need(meta, "signatures") { signature-block(s) }

  if certs.len() > 0 {
    pagebreak(weak: true)
    // The certificate is single-spaced (as filed).
    set par(leading: single-leading, spacing: 1.1em)
    cmarker.render(certs, raw-typst: false, smart-punctuation: true)
  }
}
