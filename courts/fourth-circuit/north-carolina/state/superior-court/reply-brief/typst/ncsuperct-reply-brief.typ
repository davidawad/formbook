// Superior Court of North Carolina (ncsuperct): one template for the papers of this court (opening and
// answering briefs, reply, motions, amicus briefs, petitions for judicial review and for writ). The doc
// folder's own name is the doc type; only the frontmatter and the heading text differ.
//
// Content-agnostic. Every number is a named parameter below. Tier 1 numbers come from the court's rules
// as recorded in ../../rules.md; the rules were not retrieved, so the values here are the default eval
// values (Times New Roman, 12 pt, 1 in margins, US letter) and no page limit is set.
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the INPUT.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md). Times is the face most exemplars use.
#let type-size = 12pt                     // Body text at 12 pt (the default eval floor; no rule read sets another).
#let body-leading = 1.55em                // Double-spaced for 12 pt Times: about 24 pt baselines (the exemplars and the usual convention for briefs).
#let single-leading = 0.45em              // Single-spaced: headings, block quotations, footnotes, caption and counsel blocks.
#let page-margin = 1in                    // 1 in on all four sides (the default eval margin).
#let para-indent = 0.5in                  // First-line indent of body paragraphs, as in the exemplars.
#let toc-depth = 3
#let sig-indent = 3.2in                   // Counsel and signature blocks set right of centre, as in the exemplars.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncsuperct-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ncsuperct-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation (italic, as in the exemplars).
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block: "/s/" and the typed name, then bar number, address, telephone, e-mail.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #for (i, s) in signers(sig).enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ncsuperct-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Cover unnumbered; front matter (table of contents) roman; body arabic from 1.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: none)  // 4 pt extra at the foot keeps footnote descents inside the 1 in margin
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)
  set list(marker: [–])   // en dash: the bullet of the default list marker is not in Times New Roman or Liberation Serif

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left; level 3 italic).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size as the text, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Cover ----
  page(numbering: none)[
    // Single-spaced throughout, paragraph spacing included: the body's double paragraph spacing between the caption's
    // lines pushed the cover past one page (DEF-COVER-001; NCSUPERCT-CONT-002, caption and counsel on the cover).
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(center)[
      #for l in need(meta, "court_lines") [ #text(weight: "bold")[#inl(l)] \ ]
      #v(0.3in)
      #need(meta, "file_number")
    ]
    #v(0.3in)
    #for (i, side) in need(meta, "caption").enumerate() {
      if i > 0 { v(0.2in); align(center)[v.]; v(0.2in) }
      caption-side(side)
    }
    #v(0.4in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(0.2in)  // at least this much between the title and the counsel block when the cover is full
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      // One counsel group sits right of centre, as in the exemplars; several groups are set in two columns across the
      // text width, in order down the left column then the right, each group kept whole, split where the two columns'
      // line counts are closest, so a long counsel list stays on the one cover page (DEF-COVER-001).
      let groups = need(meta, "counsel")
      if groups.len() > 1 {
        let size(g) = g.names.len() + g.lines.len()
        let total = groups.map(size).sum()
        let split = range(1, groups.len()).sorted(key: k => {
          let left = groups.slice(0, k).map(size).sum()
          calc.max(left, total - left)
        }).first()
        let column(gs) = gs.map(g => block(breakable: false, counsel-group(g))).join()
        grid(columns: (1fr, 1fr), column-gutter: 0.3in, column(groups.slice(0, split)), column(groups.slice(split)))
      }
      pad(left: sig-indent, {
        if groups.len() == 1 { counsel-group(groups.first()) }
        if "counsel_for" in meta [ #emph(inl(meta.counsel_for)) \ ]
        if "date" in meta { inl(meta.date) }
      })
    }
    // No bottom pad after the last line: the page's bottom margin (page-margin + 4 pt) keeps its descenders inside 1 in.
  ]

  // ---- Front matter (roman numerals) ----
  set page(numbering: "i")
  counter(page).update(1)

  // ---- Table of contents ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Body (arabic numerals from 1) ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block (after the body, when the frontmatter names one) ----
  if "signature" in meta {
    v(0.3in)
    signature-block(meta.signature)
  }

  // ---- Certificate (frontmatter `certificate`: a list of markdown paragraphs, the last may be a signature line) ----
  if "certificate" in meta {
    pagebreak(weak: true)
    heading(level: 1, meta.at("certificate_heading", default: "Certificate of Service"))
    for p in meta.certificate { par(first-line-indent: 0pt, inl(p)) }
  }
}
