// North Dakota Supreme Court (nd): appellee's brief (answering-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (North Dakota Rules of Appellate Procedure 28, 32 and the rules named in ../../rules.md,
// read at https://www.ndcourts.gov/legal-resources/rules/ndrappp via r.jina.ai on 2026-10-21).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
//
// Frontmatter keys read here: case_number, number_lines (list), court_lines (list), caption
// (list of {names, designation}), proceeding, judge, brief_title, oral_argument (bool), counsel
// (list of {names, lines}), signature ({firm, signer, lines}), date, toc (bool, default true),
// authorities (TOA groups), notes_after (unused).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 32(a)(5): no face is named; Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // Rule 32(a)(5): 12 point or larger (and at most 16 characters per inch).
#let double-leading = 1.61em               // Rule 32(a)(5): double-spaced. Natural line box + 1.61 em = 2 x the 1.15 em single line.
#let single-leading = 0.46em               // Rule 32(a)(5): headings and quotations may be single-spaced.
#let margin-left = 1.5in                   // Rule 32(a)(4): at least one and one-half inch at the left.
#let margin-other = 1in                    // Rule 32(a)(4): at least one inch on all other sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style; exemplars do the same).
#let toc-depth = 3                         // Rule 28(b)(1): contents of the brief, with the headings of the exemplars.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nd-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nd-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: names centred, the designation centred beneath.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #for n in side.names [ #inl(n) \ ]
    #v(0.1em)
    #inl(side.designation)
  ]
}

/// Counsel block. Names, then the firm, address and contact lines.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.8em)
}

/// Signature block: the firm lines, then "/s/" and the typed name, underlined, then the bar number
/// and the party the signer represents.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
    #v(0.6em)
    #underline[/s/ #inl(sig.signer)] \
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<nd-toa>]

#let mark-authorities(meta, content) = {
  // Longest `find` first, so that "39-08-01.2" is matched before its prefix "39-08-01".
  let keys = ()
  for group in meta.at("authorities", default: ()) {
    for e in group.entries { if "find" in e { keys.push(e.find) } }
  }
  let out = content
  for key in keys.sorted(key: k => -k.len()) {
    out = {
      show key: it => it + toa-marker(key)
      out
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<nd-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.7em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.7em, below: 0.7em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nd-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 32(a)(4): 8.5 x 11 in, 1.5 in left and 1 in elsewhere, numbered at the bottom centre,
  // numbering begins on the cover page with 1.
  set page(paper: "us-letter", margin: (left: margin-left, right: margin-other, top: margin-other, bottom: margin-other + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, capitals, bold, single-spaced. Level 2: point heading, bold.
  // Level 3: sub-heading, bold italic. Headings are typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced (Rule 32(a)(5)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same typeface and size as the text, double-spaced (Rule 32(a)(5), as amended 2023).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: double-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Rule 32(a)(2): case number, court, title of case, nature of proceeding and court
  // below, title of the brief, counsel with bar number, address and telephone) ----
  page[
    #set par(leading: single-leading, spacing: 0.9em, first-line-indent: 0pt)
    #align(center)[
      #for l in need(meta, "court_lines") [ #strong[#l] \ ]
    ]
    #v(0.02in)
    #align(center)[
      #for l in meta.at("number_lines", default: (need(meta, "case_number"),)) [ #strong[#l] \ ]
    ]
    #v(0.02in)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #align(center)[v.] ]
      #caption-side(side)
      #v(0.1em)
    ]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt)
    #align(center)[#inl(need(meta, "proceeding"))]
    #if "judge" in meta [ #align(center)[#inl(meta.judge)] ]
    #line(length: 100%, stroke: 0.5pt)
    #v(0.04in)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #if meta.at("oral_argument", default: false) [
      #v(0.03in)
      #align(center)[#strong[ORAL ARGUMENT REQUESTED]]
    ]
    #v(0.04in)
    #align(left)[
      #for g in need(meta, "counsel") { counsel-group(g) }
    ]
  ]

  // ---- Table of contents (Rule 28(b)(1)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, strong[TABLE OF CONTENTS])
      #v(0.4em)
      #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (Rule 28(b)(2)), then the body. The signature follows the request
  // for relief and the certificates start on a new page (as filed). Footnote definitions sit at the
  // end of the body; they go with the main text, where their references are.
  if "authorities" in meta {
    page(authorities-table(meta))
  }
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position(regex("(?i)\n# (\\d+\\.\\s*)?certificate"))
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the request for relief) ----
  if "signature" in meta {
    v(0.4in)
    block(width: 100%, breakable: false)[
      #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
      #v(0.4em)
      #signature-block(meta.signature)
    ]
  }

  // ---- Certificates: transcribed from the filed brief, on a new page ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
