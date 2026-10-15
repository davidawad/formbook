// Georgia Supreme Court brief template (opening brief, Ga. Sup. Ct. R. 16-22). Entry point:
// typst/main.typ, which calls ga-brief(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to a rule in ../README.md. Nothing here is
// case-specific: case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Rule 16: typography -------------------------------------------------------------------
// Rule 16(1) names the Century family; the rule sizes the body by Century Schoolbook (Rule 16(2)).
// TeX Gyre Schola is the vendored Century Schoolbook substitute (docs/FONTS.md): proportional serif.
#let face = "TeX Gyre Schola"
#let body-size = 13pt // Rule 16(2): body text and headings no smaller than 13-pt Century Schoolbook
#let note-size = 11pt // Rule 16(2): footnotes no smaller than 11-pt Century Schoolbook
#let margin = 1in // Rule 16(5), Rule 17(2): no margin smaller than one inch
#let indent = 0.5in
// Rule 16(4): line spacing from 1.2x to double. The font's own pitch is 0.72em, so each
// `leading` adds to that. Single spacing = 1.2em pitch; double = 2 x that = 2.4em pitch.
#let leading-double = 1.68em // pitch 2.4em: double spacing for text
#let leading-tight = 0.72em // pitch 1.44em: 1.2x, the floor for text such as the TOC and TOA
#let leading-single = 0.48em // pitch 1.2em: single, allowed for quotations, headings, captions, footnotes

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("IN THE SUPREME COURT", "STATE OF GEORGIA")
#let closing-sentence = "This submission does not exceed the word-count limit imposed by Rule 20." // Rule 20(7)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ga-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover. Rule 21: Arabic numerals for counted pages.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: face, size: body-size, counter(page).display(n))) }
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
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(1.6em)
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
      Case No. #meta.case_number
      #if "lower_court_case" in meta [
        #v(0.8em)
        Lower Court Case No. #meta.lower_court_case
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
}

// ---- Table of authorities (Rule 19(1)(a)) ----------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the TOA is built from
// those records. Every other link prints its text only (Rule 17(3): no links to other documents).
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
          par(leading: leading-tight, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: word-count statement, signature blocks, certificate of service ----------------
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
  #closing-sentence

  Respectfully submitted, this #meta.date.

  #signature-blocks(meta)
]

#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  // Rule 14: name the manner of service in the certificate; e-mail needs the prior-agreement certification.
  #if meta.service.at("email", default: false) [
    I certify that there is a prior agreement with counsel to allow documents in a PDF format sent via e-mail to suffice for service under Supreme Court Rule 14. I further certify that I have on this day served true and correct copies of the foregoing upon the following counsel of record via e-mail:
  ] else [
    I certify that I have on this day served true and correct copies of the foregoing upon the following counsel of record by #meta.service.method:
  ]

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
  Respectfully submitted, this #meta.date.

  #signature-blocks(meta)
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------
#let style-body(it) = {
  set text(font: face, size: body-size, lang: "en")
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
  show footnote: f => text(font: face, f)
  show footnote.entry: n => {
    set text(font: face, size: note-size)
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
#let ga-brief(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document, not only inside the page wrappers: footnote areas are laid
  // out with the page's own style, and otherwise fall back to typst's default serif.
  set text(font: face, size: body-size, lang: "en")
  // Each section is its own page(): the cover has no folio; the front matter is roman; the body
  // restarts at 1 in Arabic numerals (Rule 21).
  page(numbering: none, footer: none)[
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
      #front-title[TABLE OF AUTHORITIES]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
