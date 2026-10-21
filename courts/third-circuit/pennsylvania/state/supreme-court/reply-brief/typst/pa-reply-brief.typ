// Supreme Court of Pennsylvania brief template, reply brief (Pa.R.A.P. 2113). Entry point:
// typst/main.typ, which calls pa-brief(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to a rule in ../../rules.md. Nothing here is
// case-specific: case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Pa.R.A.P. 124: form ---------------------------------------------------------------------
// Times New Roman is the face of the filed exemplars; Liberation Serif is its metric clone.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt // Pa.R.A.P. 124(a)(4): text no smaller than 14 point
#let note-size = 12pt // Pa.R.A.P. 124(a)(4): footnotes no smaller than 12 point
#let margin = 1in // Pa.R.A.P. 124(a)(3): margins at least one inch on all four sides
#let top-first-page = 3in // Pa.R.A.P. 124(a)(2): three-inch space at the top of the first page
#let indent = 0.5in
// Pa.R.A.P. 124(a)(3): double spacing. Times New Roman's natural line height is 0.655 em, so
// 1.645 em gives a 32.2 pt pitch at 14 pt (Word "double"); 0.5 em gives a 16.2 pt single pitch.
#let leading-double = 1.645em
#let leading-single = 0.5em

// ---- Pa.R.A.P. 2135: length -----------------------------------------------------------------


// ---- Pa.R.A.P. 2135: length -----------------------------------------------------------------
#let word-limit = 7000 // Pa.R.A.P. 2135(a)(1): reply brief (principal brief: 14,000)

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-line = "IN THE SUPREME COURT OF PENNSYLVANIA"
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pa-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Words of the body. Table, cover and signature matter is generated and not counted; a link
// target `(toa:KEY)` is markup, not text. Pa.R.A.P. 2135(b).
#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
#let body-words(body) = count-words(body.replace(regex("\\(toa:[^)]*\\)"), ""))

// Page number in the footer; none on the cover. Arabic numerals for counted pages.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a caption or a signature.
#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover ------------------------------------------------------------------------------------
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  lines-of(side.names)
  block(width: 100%, [#h(0.5in)#side.designation])
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-line))
  v(0.3in)
  align(center, text(weight: "bold", [No. #meta.case_number]))
  v(1.2em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.4in,
    [
      #caption-side(meta.caption.at(0))
      #v(0.8em)
      #block(width: 100%, [#h(0.5in) v.])
      #v(0.8em)
      #caption-side(meta.caption.at(1))
    ],
    [
      #if "proceeding" in meta [
        #meta.proceeding
      ]
    ],
  )
  v(2.2em)
  align(center, text(weight: "bold", meta.brief_title))
  v(2.4em)
  grid(
    columns: range(meta.counsel.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines, italic: true)
    }),
  )
  if "date" in meta [
    #v(1.6em)
    #align(center)[Dated: #meta.date]
  ]
}

// ---- Table of citations (Pa.R.A.P. 2111(a)) -------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the table is built
// from those records. Every other link prints its text only.
#let authority-line(a) = if a.kind == "case" {
  [#emph(a.name), #a.cite]
} else if "cite" in a {
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
          par(leading: leading-single, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: date, signature blocks, certificates -----------------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

// Markup blocks, not code blocks: a blank line separates paragraphs only in markup.
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date

  Respectfully submitted,

  #signature-blocks(meta)
]

// Pa.R.A.P. 2135(d): word-count certificate; Pa.R.A.P. 127(a) and Comment: Public Access Policy
// certification in the form the Comment quotes (Sections 7.0(D) and 8.0(D)).
#let certificate-of-compliance(meta, words) = [
  #front-title[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I hereby certify that this brief complies with the word-count limit of Pa.R.A.P. 2135(a)(1). Excluding the cover, tables, proof of service and signature block, it contains #str(words) words, as computed by the word-processing template that prepared it.

  I certify that this filing complies with the provisions of the Case Records Public Access Policy of the Unified Judicial System of Pennsylvania that require filing confidential information and documents differently than non-confidential information and documents.

  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date

  #signature-blocks(meta)
]

#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I certify that I have on this day served a true and correct copy of the foregoing upon the following counsel of record by #meta.service.method:

  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #grid(
    columns: range(meta.service.recipients.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )

  #v(1.4em)
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date

  #signature-blocks(meta)
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------
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
  show footnote: f => text(font: font-family, f)
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
#let pa-brief(meta, body) = {
  let words = body-words(body)
  assert(
    words <= word-limit,
    message: "Pa.R.A.P. 2135(a)(1): the brief has " + str(words) + " words; the limit is " + str(word-limit),
  )
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document: footnote areas are laid out with the page's own style.
  set text(font: font-family, size: body-size, lang: "en")
  // Each section is its own page(): the cover (first page, with the three-inch space) has no
  // folio; the front matter is roman; the body restarts at 1 in Arabic numerals.
  page(margin: (top: top-first-page, rest: margin), numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 2, indent: 0pt)
  ]
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CITATIONS]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-compliance(meta, words)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
