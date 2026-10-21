// Court of Appeals of Maryland (Supreme Court of Maryland) filing template: petition (rules.md).
// Entry point: typst/main.typ, which calls md-petition-for-review(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to rules.md (MD-* ids). Nothing here is case-specific: case text
// comes from the frontmatter.
#import "@preview/cmarker:0.1.10"

// ---- Rule 8-112 and Rule 1-301(c): form ----------------------------------------------------------
// MD-FORM-003: a face on the Court's approved list (Times New Roman is on it).
#let font-family = ("Times New Roman", "Liberation Serif")
// MD-FORM-004: type size not less than 13 points, footnotes included.
#let body-size = 13pt
#let note-size = 13pt
// MD-FORM-001: top and left margins not less than 1 1/2 in; bottom and right not less than 1 in.
#let margin-top = 1.5in
#let margin-left = 1.5in
#let margin-bottom = 1in
#let margin-right = 1in
#let indent = 0.5in
// MD-FORM-002: double spacing for computer-generated text, except headings, indented quotations and footnotes.
// Leading is measured on the render (13 pt Liberation Serif, typst 0.15): the natural line is about 0.69 em, so a
// leading of 0.46 em gives a single pitch of about 1.15 em and 1.6 em gives the double pitch of about 2.29 em.
#let leading-double = 1.6em
#let leading-single = 0.46em
#let leading-tight = 0.5em

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-lines = ("IN THE", "SUPREME COURT OF MARYLAND")
#let doc-noun = "petition" // the noun in the certification of compliance
// The body markdown carries the pertinent-law appendix under this heading; the template places it after the
// certification of compliance (the order the Court's form uses).
#let appendix-heading = "# CITATION AND VERBATIM TEXT OF ALL PERTINENT LAW"
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "other", title: "OTHER AUTHORITIES"),
  (key: "rule", title: "RULES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("md filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the bottom margin (MD-FORM-005: consecutively numbered pages); none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover ---------------------------------------------------------------------------------------
// The docket line and the lower-court references are printed as the filer supplies them in frontmatter.
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  lines-of(side.names)
  block(width: 100%, [#h(0.5in)#side.designation])
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(1.2em)
  if "record_number" in meta [
    #align(center, text(weight: "bold", meta.record_number))
    #if "term" in meta [#align(center, meta.term)]
    #v(1.6em)
  ]
  caption-side(meta.caption.at(0))
  v(0.8em)
  if meta.caption.at(1).designation != "" [
    #block(width: 100%, [#h(0.5in) v.])
    v(0.8em)
  ]
  caption-side(meta.caption.at(1))
  if "proceeding" in meta [
    #v(1.2em)
    #for l in meta.proceeding [#align(center, l)]
  ]
  v(2.2em)
  align(center, text(weight: "bold", meta.doc_title))
  v(2.4em)
  // Counsel blocks stack one under another: two columns overflow the right margin with long e-mail addresses.
  for g in meta.counsel [
    #lines-of(g.names)
    #lines-of(g.lines)
    #v(1.2em)
  ]
}

// ---- Table of contents and table of citations (Rule 8-504(a)) ----------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the table is built from those records.
// Every other link prints its text only.
#let authority-line(a) = if a.kind == "case" {
  [#emph(a.name), #a.cite]
} else if "cite" in a and a.cite != "" {
  [#a.name, #a.cite]
} else {
  [#a.name]
}

#let table-of-authorities(auths) = context {
  let hits = query(<toa-hit>)
  for k in kinds {
    let rows = auths.pairs().filter(((key, a)) => a.kind == k.key)
    if rows.len() == 0 { continue }
    rows = rows.sorted(key: ((key, a)) => lower(a.at("sort", default: if "name" in a { a.name } else { a.cite })))
    block(above: 1.1em, below: 0.5em, text(weight: "bold", k.title))
    for (key, a) in rows {
      let pages = hits.filter(h => h.value.key == key).map(h => counter(page).at(h.location()).first())
      let pages = pages.dedup().sorted()
      let shown = if pages.len() >= 7 { "passim" } else { pages.map(str).join(", ") }
      block(
        above: 0pt,
        below: 0.5em,
        grid(
          columns: (1fr, auto),
          gutter: 1em,
          par(leading: leading-tight, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: date line, signature block, certification of compliance, certificate of service ----
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  #if "submitted" in meta [#meta.submitted]
  #v(0.8em)
  #for g in meta.signature [
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    #lines-of(g.lines)
    #v(1.2em)
  ]
]

// Rule 8-112 (certification of word count and compliance, official form): the word count is stated when the
// rule's exemption applies, and the certification is signed.
#let compliance-certificate(meta) = [
  #front-title[CERTIFICATION OF WORD COUNT AND COMPLIANCE WITH RULE 8-112]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  1. This #doc-noun contains #if "word_count" in meta [#meta.word_count] else [#("_" * 8)] words, excluding the parts exempted from the word count by Rule 8-503.
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  2. This #doc-noun complies with the font, spacing, and type size requirements stated in Rule 8-112.
  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #for g in meta.certificate_signature [
    #lines-of(g.lines)
    #v(1.2em)
  ]
]

// Certificate of service: the filer's text and recipients (dates the filer has not supplied print as blanks).
#let certificate-of-service(meta) = {
  let s = meta.at("service", default: (:))
  [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #if "text" in s [#s.text] else [#("_" * 12)]
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(1.2em)
  #if "recipients" in s [
    #for g in s.recipients [
      #lines-of(g.names)
      #lines-of(g.lines)
      #v(1.2em)
    ]
  ]
  #if "signature" in s [#lines-of(s.signature)]
  ]
}

// ---- Body styling (applied with `#show: style-body`) ------------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "en")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  show heading.where(level: 2): h => block(above: 1.2em, below: 0.8em, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(
    above: 1.1em,
    below: 0.6em,
    text(weight: "bold", style: "italic", h.body),
  )
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote: f => text(font: font-family, size: note-size, f)
  show footnote.entry: n => {
    set text(font: font-family, size: note-size)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    n
  }
  show quote.where(block: true): q => block(above: 1em, below: 1em, pad(
    left: indent,
    right: indent,
    {
      set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
      q.body
    },
  ))
  show link: l => {
    if type(l.dest) == str and l.dest.starts-with("toa:") {
      [#l.body#metadata((key: l.dest.slice(4)))<toa-hit>]
    } else if type(l.dest) == str {
      l.body
    } else {
      l
    }
  }
  it
}

// ---- Entry -----------------------------------------------------------------------------------------
#let md-petition-for-review(meta, body) = {
  set document(title: "" + meta.at("record_number", default: "") + " " + meta.doc_title)
  set page(
    paper: "us-letter",
    margin: (top: margin-top, left: margin-left, bottom: margin-bottom, right: margin-right),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: body-size, lang: "en")
  // Cover: no folio. Front matter: roman numerals. Body: restarts at 1 in arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  if meta.at("toc", default: true) {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CONTENTS]
      #outline(title: none, depth: 3, indent: 0pt)
    ]
  }
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CITATIONS]
      #table-of-authorities(meta.authorities)
    ]
  }
  // The pertinent-law appendix (Rule 8-504) follows the certification of compliance, not the signature block.
  let parts = body.split(appendix-heading)
  let main = parts.at(0)
  let appx = if parts.len() > 1 { appendix-heading + parts.at(1) } else { none }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(main, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  if "word_count" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #compliance-certificate(meta)
    ]
  }
  if appx != none {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #cmarker.render(appx, raw-typst: false, smart-punctuation: true, h1-level: 1)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-service(meta)
  ]
}
