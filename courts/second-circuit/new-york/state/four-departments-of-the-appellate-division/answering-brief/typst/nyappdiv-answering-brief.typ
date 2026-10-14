// New York Appellate Division (all four Departments): answering brief (respondent's brief).
//
// Rule-driven and content-agnostic. Rule IDs (NYAD-...) refer to ../README.md, which cites
// 22 NYCRR 1250.8. No case-specific text, no coordinates measured off any filed brief, no
// forced line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // NYAD-TYPE-001: serif, proportional, vendored in /fonts.
#let body-size = 14pt                      // NYAD-TYPE-002: 14-point body, proportional face.
#let note-size = 12pt                      // NYAD-TYPE-002: footnotes no less than 12-point.
#let body-leading = 1.2em                  // NYAD-FORM-002: double spacing (estimate, see README).
#let single-leading = 0.45em               // NYAD-FORM-003: quotations, headings, footnotes, cover, certificates.
#let page-margin = 1in                     // NYAD-FORM-001: one inch on all sides.
#let para-indent = 0.5in
#let word-limit = 14000                    // NYAD-WORD-001: respondent's brief, 22 NYCRR 1250.8(f)(2).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nyappdiv-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyappdiv-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// 14000 -> "14,000"
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
/// Point headings and footnote text count; footnote definitions are removed from the
/// count because their text is printed at the foot of a page, not in the body. Markup
/// characters are counted as they are (a known approximation, see README "Known gaps").
#let count-words(md) = {
  let s = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:.*$"), "")
  s.split(regex("\\s+")).filter(w => w != "").len()
}

// ---------------------------------------------------------------------------
// Cover (NYAD-COVER-001..003)
// ---------------------------------------------------------------------------

/// Upper right: argued or submitted; if argued, the time and the attorney who will argue.
#let calendar-notation(cal) = {
  if cal.mode == "submitted" {
    [Submitted]
  } else {
    [Argued: #cal.at("argued_by", default: "[attorney]")]
    linebreak()
    [Time requested: #cal.at("time", default: "[time]")]
  }
}

#let cover(meta) = page(numbering: none, footer: none)[
  #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  #align(left)[
    #need(meta, "index_no") #linebreak()
    #need(meta, "docket")
  ]
  #v(0.8em)
  #align(center)[
    #text(size: 14pt)[#need(meta, "court")]
  ]
  #v(1.2em)
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
  #v(1.6em)
  #align(right)[
    #block(width: 3.2in, align(left, calendar-notation(need(meta, "calendar"))))
  ]
  #v(1.2em)
  #align(center)[
    #text(size: 14pt)[#upper(need(meta, "brief_title"))]
  ]
  #v(1fr)
  #align(right)[
    #block(width: 3.2in, breakable: false, {
      let c = need(meta, "counsel")
      for n in c.names { block(inl(n)) }
      for l in c.at("lines", default: ()) { block(inl(l)) }
      block(need(meta, "phone"))
      if "email" in c { block(inl(c.email)) }
    })
  ]
]

// ---------------------------------------------------------------------------
// Tables: contents and authorities (NYAD-TOC-001; table of authorities has no page references: known gap)
// ---------------------------------------------------------------------------

#let toc-page() = {
  pagebreak()
  align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
  v(1em)
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
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
    let items = auths.filter(a => a.kind == g.kind)
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
// Signature, printing specifications statement, proof of service (NYAD-SIG-001, NYAD-PRINT-001, NYAD-SERV-001)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  v(1.5em)
  block(breakable: false, pad(left: 3.25in, [
    Respectfully submitted,
    #v(1.8em)
    #sig.signer
    #for l in sig.lines { linebreak(); inl(l) }
    #if "date" in meta [ #linebreak() #meta.date ]
  ]))
}

/// Printing specifications statement, 22 NYCRR 1250.8(j). Typeface, point size and line
/// spacing are fixed by this template and printed from its constants, not typed by hand.
#let printing-statement(meta, words) = {
  pagebreak()
  align(center)[#text(weight: "bold")[PRINTING SPECIFICATIONS STATEMENT]]
  v(1em)
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  [This brief was prepared on a computer. The typeface is #font-family, a serifed, proportionally spaced typeface. The body is printed in #str(body-size.pt()) point type and footnotes in #str(note-size.pt()) point type. The line spacing is double-spaced. The word count, exclusive of the pages containing the table of contents, table of authorities, proof of service and certificate of compliance, and exclusive of the signature block, is #group-digits(words) words. The word count was made by the word-processing system used to prepare the brief.]
  v(1.5em)
  block(breakable: false, pad(left: 3.25in, [
    #need(meta, "signature").signer
    #if "date" in meta [ #linebreak() #meta.date ]
  ]))
}

#let certificate-of-service(meta) = {
  if "service" not in meta { return }
  pagebreak()
  align(center)[#text(weight: "bold")[AFFIDAVIT OF SERVICE]]
  v(1em)
  set par(leading: body-leading, first-line-indent: para-indent, justify: true)
  [#meta.service.at("affiant", default: "[Affiant name]") states that on the date below copies of this brief were served on counsel for every party by #meta.service.method.]
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

#let nyappdiv-answering-brief(meta, md) = {
  set document(title: need(meta, "brief_title"))
  set text(font: font-family, size: body-size, lang: "en")
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set par(leading: body-leading, first-line-indent: para-indent, justify: true)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Headings (NYAD-HEAD-001): headings may be bold and capitalised; body text may not (NYAD-TYPE-001).
  show heading.where(level: 1): it => block(above: 1.4em, below: 1.2em, sticky: true, align(center)[
    #text(weight: "bold")[#upper(it.body)]
  ])
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.9em, sticky: true, par(first-line-indent: 0pt, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(above: 1.3em, below: 1.1em, sticky: true, pad(left: 0.5in, par(first-line-indent: 0pt, text(weight: "bold", it.body))))
  show heading.where(level: 4): it => block(above: 1.2em, below: 1em, sticky: true, pad(left: 1in, par(first-line-indent: 0pt, text(style: "italic", it.body))))

  // Block quotations (NYAD-FORM-003): indented, single-spaced.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(above: 1em, below: 1em, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    it.body
  }))

  cover(meta)
  toc-page()
  toa-page(meta)

  // Body: starts on a new page; the first heading begins the brief's text.
  pagebreak()
  set par(leading: body-leading, first-line-indent: para-indent, justify: true)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  printing-statement(meta, count-words(md))
  certificate-of-service(meta)
}
