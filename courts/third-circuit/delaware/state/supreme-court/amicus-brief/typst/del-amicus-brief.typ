// Delaware Supreme Court amicus curiae brief template (amicus-brief; rules.md DEL-FORM-30x, DEL-LEN-301,
// DEL-CERT-301). Entry point: typst/main.typ, which calls del-amicus-brief(meta, body) with the sample's
// frontmatter and markdown. Every number is a named constant below and traces to rules.md (DEL-* ids).
// Nothing here is case-specific: case text comes from frontmatter and the markdown body only.
#import "@preview/cmarker:0.1.10"

// ---- Supreme Court Rules 13(a), 28(c): typography ---------------------------------------------
// Rule 13(a)(i): Times New Roman 14-point, footnotes included; Rule 13(a)(ii): double spaced, single for
// quotations and footnotes; margins of at least one inch on all four sides.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt // Rule 13(a)(i)
#let note-size = 14pt // Rule 13(a)(i): footnotes are in the same 14-point face
#let margin = 1in // Rule 13(a)(ii)
#let indent = 0.5in
// Measured on the render (14 pt Liberation Serif, typst 0.15): the natural line is 0.69 em; a leading of 1.6 em
// gives a 32 pt pitch (double), 0.46 em a 16 pt pitch (single), 0.5 em a 17 pt pitch (TOC and TOA entries).
#let leading-double = 1.6em
#let leading-single = 0.46em // single spacing for headings, quotations, footnotes, caption and signature lines
#let leading-tight = 0.5em // TOC and TOA entries

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-lines = ("IN THE", "SUPREME COURT OF THE STATE OF DELAWARE") // DEL-CONV-001
#let compliance-cite = "Supreme Court Rules 13(a)(i) and 28(d)" // cited in the certificate; rules.md DEL-CERT-301
#let word-limit = 5000 // Rule 28(d): one-half of the 10,000-word limit for a party's principal brief (DEL-LEN-301)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("del amicus: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---- Word count (Rule 28(d)): the brief text from the statement of identity through the conclusion. The cover,
// the tables and the signature block are not counted. Footnote labels and authority links are not words.
#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
#let body-words(md) = count-words(
  md.replace(regex("\\[\\^[^\\]]*\\]"), " ").replace(regex("\\(toa:[^)]*\\)"), " "),
)
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

// Page number in the bottom margin; none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// Consecutive lines of one block: one paragraph with line breaks, so the lines take the single leading.
#let lines-of(list, italic: false) = block(width: 100%, {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  for (i, l) in list.enumerate() {
    if i > 0 { linebreak() }
    if italic { emph[#l] } else { [#l] }
  }
})

#let when(d, key) = if key in d { d.at(key) } else { "____________" }

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (Rule 14(a)): court, caption and number, trial court, title, counsel, date ------------
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
  align(center, text(weight: "bold", "No. " + meta.case_number))
  v(1.6em)
  // Style of the case: the appellant is named first (Supreme Court Rule 14(a)).
  caption-side(meta.caption.at(0))
  v(0.8em)
  block(width: 100%, [#h(0.5in) v.])
  v(0.8em)
  caption-side(meta.caption.at(1))
  if "proceeding" in meta [
    #v(1.2em)
    #align(center, lines-of(meta.proceeding))
  ]
  v(2.2em)
  align(center, text(weight: "bold", meta.brief_title))
  v(2.4em)
  align(left, [Dated: #meta.date])
  v(1.2em)
  for g in meta.counsel [
    #lines-of(g.names)
    #lines-of(g.lines)
    #v(1.2em)
  ]
}

// ---- Table of authorities (Rule 14(b)(ii)) ----------------------------------------------------------
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
  #v(0.4em)
  #signature-blocks(meta)
]

// Rule 14(d)(ii) and 28(d): the certificate states the word count the program computes for the brief.
#let compliance-certificate(words) = [
  #front-title[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I certify that this brief complies with the typeface requirement of Supreme Court Rule 13(a)(i) and the length limitation of Supreme Court Rule 28(d). The brief is set in Times New Roman 14-point type. It contains #group-digits(words) words, counted from the statement of identity through the conclusion, excluding the cover, the tables and the signature block.
]

// Rule 10(c): proof of service, the date and manner of service and the persons served.
#let certificate-of-service(meta) = {
  let s = meta.at("service", default: (:))
  [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I certify that on #when(s, "service_date") I caused a true and correct copy of the foregoing to be served on the following counsel of record by #when(s, "service_method"):
  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #if "recipients" in s [
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
#let del-amicus-brief(meta, body) = {
  let words = body-words(body)
  assert(words <= word-limit, message: "word count " + str(words) + " exceeds the " + str(word-limit) + "-word limit of Rule 28(d)")
  set document(title: "No. " + meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // Cover: no folio. Tables: roman numerals. Body: restarts at 1 in arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 5, indent: 0pt)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CITATIONS]
    #table-of-authorities(meta.at("authorities", default: (:)))
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #compliance-certificate(words)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
