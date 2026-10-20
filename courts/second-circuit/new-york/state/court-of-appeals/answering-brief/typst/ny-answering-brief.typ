// New York Court of Appeals: answering brief (brief for respondent).
//
// Rule-driven and content-agnostic. Rule IDs (NY-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"          // NY-TYPE-001: serif, proportional; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let body-size = 14pt                      // NY-TYPE-002: 14-point body for a proportional font.
#let note-size = 12pt                      // NY-TYPE-002: footnotes at least 12-point.
#let body-leading = 1.59em                 // NY-FORM-002: double spacing: 31.4 pt line pitch at 14 pt (cap-height to baseline
                                           // line box 9.1 pt + 22.3 pt leading), as a word processor sets 14-point double.
#let single-leading = 0.45em               // block quotations, footnotes, cover and certificates.
#let page-margin = 1in                     // NY-FORM-001: one inch on all sides.
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ny-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ny-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// 11622 -> "11,622"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

/// Word count of the markdown body, whitespace-delimited like a word processor.
/// Footnote definitions are removed; markup characters are counted as they are
/// (a known approximation, see README "Known gaps").
#let count-words(md) = {
  let s = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:.*$"), "")
  s.split(regex("\\s+")).filter(w => w != "").len()
}

// ---------------------------------------------------------------------------
// Cover (NY-COVER-001..003; no colour, no plastic cover: NY-FORM-005)
// ---------------------------------------------------------------------------

#let cover(meta) = page(numbering: none, footer: none)[
  #set par(leading: single-leading, spacing: 1.2em, first-line-indent: 0pt, justify: false)
  #if "argued_by" in meta [
    // 22 NYCRR 500.13(b): the argument request (time and presenter) goes in the upper right corner.
    #block(width: 100%, below: 1.6em, align(right, block(spacing: 0.4em)[To be argued by:] + block(spacing: 0.4em, inl(meta.argued_by))))
  ]
  #align(center)[
    #text(size: 14pt, weight: "bold")[Court of Appeals]
    #v(0.2em)
    #text(size: 14pt, weight: "bold")[of the State of New York]
  ]
  #v(1.2em)
  #align(center)[
    #text(size: 14pt)[#need(meta, "apl_docket")]
    #if "county_clerk_index" in meta [
      #v(0.4em)
      #text(size: 14pt)[#meta.county_clerk_index]
    ]
  ]
  #v(1.5em)
  #for side in need(meta, "caption") {
    align(center)[
      #for name in side.names {
        block(inl(name))
      }
      #v(0.3em)
      #side.designation
    ]
    if side != need(meta, "caption").last() {
      align(center)[#v(0.6em) #emph[--against--] #v(0.6em)]
    }
  }
  #v(1.8em)
  #align(center)[
    #text(size: 14pt, weight: "bold")[#upper(need(meta, "brief_title"))]
  ]
  #v(1.2em)
  #if "proceeding" in meta [
    #align(center)[#meta.proceeding]
  ]
  #v(1fr)
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    ..need(meta, "counsel").map(g => {
      let lines = g.at("names").map(n => block(inl(n))) + g.at("lines", default: ()).map(l => block(inl("*" + l + "*")))
      block(breakable: false, lines.join(v(0.3em)))
    })
  )
  #v(0.8em)
  #need(meta, "phone")
  // 500.13(b): counsel's telephone and facsimile numbers; `fax` is printed under the telephone line when given.
  #if "fax" in meta [ #v(0.3em) #meta.fax ]
  #if "date" in meta [ #v(0.4em) #meta.date ]
  // Keeps the last line's descenders inside the 1 in bottom margin (NY-FORM-001).
  #v(0.3em)
]

// ---------------------------------------------------------------------------
// Disclosure statement (NY-DISC-001: 22 NYCRR 500.1(f); shown only when given)
// ---------------------------------------------------------------------------

#let disclosure-page(meta) = {
  if "disclosure" not in meta { return }
  pagebreak()
  align(center)[#text(weight: "bold")[DISCLOSURE STATEMENT]]
  v(1em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  inl(meta.disclosure)
}

// ---------------------------------------------------------------------------
// Tables: contents and authorities (NY-TOC-001; authorities without page numbers: known gap)
// ---------------------------------------------------------------------------

#let toc-page() = {
  pagebreak()
  align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
  v(1em)
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  // Page column heading, as filed contents pages print it.
  align(right, block(above: 0pt, below: 0.6em, strong(underline[Page])))
  outline(title: none, depth: 2, indent: 0.5in)
}

#let toa-groups = (
  (kind: "case", title: "Cases"),
  (kind: "constitution", title: "Constitutional Provisions"),
  (kind: "statute", title: "Statutes"),
  (kind: "regulation", title: "Regulations"),
  (kind: "rule", title: "Rules"),
  (kind: "other", title: "Other Authorities"),
)

#let toa-page(meta) = {
  if "authorities" not in meta { return }
  pagebreak()
  align(center)[#text(weight: "bold")[TABLE OF AUTHORITIES]]
  v(1em)
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  let auths = meta.authorities.values()
  for g in toa-groups {
    // Alphabetical within each group, as filed tables of authorities list them.
    let items = auths.filter(a => a.kind == g.kind).sorted(key: a => lower(a.name + " " + a.cite))
    if items.len() == 0 { continue }
    text(weight: "bold")[#g.title]
    v(0.4em)
    for a in items {
      let shown = if a.kind == "case" { "*" + a.name + "*" } else { a.name }
      block(above: 0.5em, inl(shown + ", " + a.cite))
    }
    v(0.8em)
  }
}

// ---------------------------------------------------------------------------
// Signature and certificates (NY-SIG-001, NY-CERT-001, NY-CERT-002)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  v(1.5em)
  block(breakable: false, pad(left: 3.25in, [
    Respectfully submitted,
    #v(1.8em)
    #sig.signer
    #for l in sig.lines { linebreak(); inl("*" + l + "*") }
    #if "date" in meta [ #linebreak() #meta.date ]
  ]))
}

#let certificate-of-compliance(meta, words) = {
  pagebreak()
  align(center)[#text(weight: "bold")[CERTIFICATE OF COMPLIANCE]]
  v(1em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  [I certify that this brief complies with the word limit of 22 NYCRR 500.13(c)(1), that it contains #group-digits(words) words in the body of the brief, excluding the caption, tables and signature block, and that the count was made by the word-processing system used to prepare it.]
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  v(1.5em)
  block(breakable: false, pad(left: 3.25in, [
    #need(meta, "signature").signer
    #if "date" in meta [ #linebreak() #meta.date ]
  ]))
}

#let certificate-of-service(meta) = {
  if "service" not in meta { return }
  pagebreak()
  align(center)[#text(weight: "bold")[CERTIFICATE OF SERVICE]]
  v(1em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  [I certify that on the date below I served copies of this brief on counsel for all parties by #meta.service.method.]
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for u in meta.service.at("unregistered", default: ()) {
    block(above: 1em, breakable: false, [#u.name #linebreak() #u.address])
  }
  v(1.5em)
  block(breakable: false, pad(left: 3.25in, [
    #need(meta, "signature").signer
    #if "date" in meta [ #linebreak() #meta.date ]
  ]))
}

// ---------------------------------------------------------------------------
// Main entry
// ---------------------------------------------------------------------------

#let ny-answering-brief(meta, md) = {
  set document(title: need(meta, "brief_title"))
  set text(font: font-family, size: body-size, lang: "en")
  // Front matter (cover unnumbered, tables in roman); the body restarts at 1 (set below).
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "i",
    number-align: center + bottom,
  )
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set footnote.entry(gap: 0.5em, indent: 0pt, separator: line(length: 1.5in, stroke: 0.5pt))
  // NY-TYPE-002: footnotes at least 12-point; single spaced (NY-FORM-003). The note number is
  // followed by a space, as a word processor sets it.
  show footnote.entry: it => {
    set text(size: note-size)
    set par(leading: single-leading, spacing: 0.5em, first-line-indent: (amount: para-indent, all: true))
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Section headings (NY-HEAD-001): level 1 centered, bold, capitals.
  // Sub-headings: bold, left, with the letters and numerals typed in the markdown.
  // Headings are set unjustified and unhyphenated: the filed exemplars break them at word
  // ends, not at hyphens (no forced breaks: the wrap is left to the engine).
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1.2em, sticky: true, {
    set text(size: body-size)
    set par(leading: single-leading, justify: false)
    set text(hyphenate: false)
    align(center)[#text(weight: "bold")[#upper(it.body)]]
  })
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true, {
    set text(size: body-size)
    set par(leading: single-leading, justify: false, first-line-indent: 0pt)
    set text(hyphenate: false)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1.3em, below: 1.1em, sticky: true, pad(left: 0.5in, {
    set text(size: body-size)
    set par(leading: single-leading, justify: false, first-line-indent: 0pt)
    set text(hyphenate: false)
    text(weight: "bold", it.body)
  }))
  show heading.where(level: 4): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true, pad(left: 1in, {
    set text(size: body-size)
    set par(leading: single-leading, justify: false, first-line-indent: 0pt)
    set text(hyphenate: false)
    text(style: "italic", it.body)
  }))

  // Block quotations (NY-FORM-003): indented, single-spaced.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(above: 1em, below: 1em, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    it.body
  }))

  cover(meta)
  disclosure-page(meta)
  toc-page()
  toa-page(meta)

  // Body: starts on a new page, numbered from 1; the first heading begins the argument.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  certificate-of-compliance(meta, count-words(md))
  certificate-of-service(meta)
}
