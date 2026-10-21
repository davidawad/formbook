// Supreme Court of Pennsylvania filing template (Pa.R.A.P.) (brief-on-the-merits; rules.md). Entry point: typst/main.typ,
// which calls pa-brief-on-the-merits(meta, body) with the sample's frontmatter and markdown. Every number is a named
// constant below and traces to rules.md (VA-* ids). Nothing here is case-specific: case text comes from frontmatter.
#import "@preview/cmarker:0.1.10"

// ---- Rules 5:6(a): typography ------------------------------------------------------------------
// Rule 5:6(a)(3): a font from the Court's list (Times New Roman is on it); 14-point type or larger, footnotes
// included; double spaced except headings, assignments of error, quotations over 49 words, and footnotes.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt // Rule 5:6(a)(3): at least 14-point, text may not be reduced
#let note-size = 14pt // Rule 5:6(a)(3): footnotes are included in the 14-point minimum
#let margin = 1in // Rule 5:6(a)(2): at least one inch on all four sides
#let indent = 0.5in
// Measured on the render (14 pt Liberation Serif, typst 0.15): the natural line is 0.69 em; a leading of 1.6 em
// gives a 32 pt pitch (double), 0.46 em a 16 pt pitch (single), 0.5 em a 17 pt pitch (TOC and TOA entries).
#let leading-double = 1.6em
#let leading-single = 0.46em // single spacing for headings, quotations, footnotes, caption and signature lines
#let leading-tight = 0.5em // TOC and TOA entries 

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-lines = ("IN THE", "SUPREME COURT OF PENNSYLVANIA")
#let doc-noun = "brief" // "brief" for briefs, the noun used in the compliance certificate
#let compliance-cite = "Pa.R.A.P. 124, 127 and 2135(d)" // cited in the compliance certificate; rules.md PA-CERT-002
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("va filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the bottom margin ; none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

// A date the filer has not printed in the source is a blank line for the filer to complete, never a guessed date.
#let when(d, key) = if key in d { d.at(key) } else { "____________" }

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (Rule 5:6(b)) ------------------------------------------------------------------------
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
  if meta.case_number != "" [
    #align(center, text(weight: "bold", "No. " + meta.case_number))
    #v(1.6em)
  ]
  // Style of the case: the appellant or petitioner is named first (Rule 5:6(b)).
  caption-side(meta.caption.at(0))
  v(0.8em)
  block(width: 100%, [#h(0.5in) v.])
  v(0.8em)
  caption-side(meta.caption.at(1))
  if "proceeding" in meta [
    #v(1.2em)
    #align(center, meta.proceeding)
  ]
  v(2.2em)
  align(center, text(weight: "bold", meta.brief_title))
  v(2.4em)
  // Counsel name, VSB number, mailing address, telephone, fax (if any), e-mail (Rule 5:6(b)).
  // Counsel blocks stack one under another: two columns overflow the right margin with long e-mail addresses.
  for g in meta.counsel [
    #lines-of(g.names)
    #lines-of(g.lines)
    #v(1.2em)
  ]
}

// ---- Table of authorities (Rule 5:28(a); year of each citation in the cite text) ----------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the TOA is built from those records.
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

// ---- Closing: signature blocks, compliance certificate, certificate of service -----------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted,

  #if "signing_party" in meta [#meta.signing_party \ By Counsel]

  #if "date" in meta [this #meta.date.]

  #signature-blocks(meta)
]

// Pa.R.A.P. 2135(d): the compliance certificate states the word count when a word count is used.
#let compliance-certificate(meta) = [
  #front-title[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I hereby certify that this #doc-noun complies with #compliance-cite of the Pennsylvania Rules of Appellate Procedure.
  #if "word_count" in meta [
    It contains #meta.word_count words, excluding the cover page, table of contents, table of authorities, signature blocks, and this certificate (Pa.R.A.P. 2135(d)).
  ]
]

// Rule 5:1B(c): the e-filed document certifies the date of filing and the date of e-mail service. Dates and
// recipients the filer has not supplied print as blanks; the certificate is required on every filing.
#let certificate-of-service(meta) = {
  let s = meta.at("service", default: (:))
  [
  #front-title[CERTIFICATE OF FILING AND SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I hereby certify that on the #when(s, "filed_date") I electronically filed the foregoing with the Prothonotary of the Supreme Court of Pennsylvania, and that on the #when(s, "service_date") I served true and correct copies of it on the following counsel of record:

  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #if "recipients" in s [
    // Recipients stack one under another: side-by-side columns overflow the right margin with long e-mail addresses.
    #for g in s.recipients [
      #lines-of(g.names)
      #lines-of(g.lines)
      #v(1.2em)
    ]
  ] else [
    #v(3em)
  ]
  ]
}

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------------
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

// ---- Entry -------------------------------------------------------------------------------------
#let pa-brief-on-the-merits(meta, body) = {
  set document(title: "No. " + meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // Cover: no folio. Front matter: roman numerals. Body: restarts at 1 in arabic numerals.
  page(margin: (top: 3in, rest: margin), numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 3, indent: 0pt)
  ]
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF AUTHORITIES]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: false, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #compliance-certificate(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-service(meta)
  ]
}
