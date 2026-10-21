// Supreme Court of Montana amicus curiae brief (mont): cover, table of contents, body, compliance
// certificate, certificate of service.
// Entry point: typst/main.typ, which calls mont-brief-amicus(meta, body) with the sample's frontmatter
// and markdown. Every number is a named constant below and traces to a rule in ../rules.md.
// Nothing here is case-specific: case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- M.R.App.P. 11: typography ----------------------------------------------------------------
// MONT-FORM-003 (MRAP 11(2)): proportionately spaced typeface of 14 points or more. Times New Roman
// is the named face; Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let face = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt // MONT-FORM-003: body text, headings and footnotes, 14 points or more
#let note-size = 14pt // MONT-FORM-003: footnotes are text too; no smaller than 14 points
// MONT-FORM-001 / MONT-FORM-002 (MRAP 11(3)(a)): US letter, at least 1 inch on every side.
#let margin = 1in
#let indent = 0.5in
// MONT-FORM-004 (MRAP 11(3)(b)): double spaced. Typst adds leading to the face's natural line box, which
// is about 0.69 em for Liberation Serif here; measured baseline pitch is 0.69 em + leading (2.39 em at 1.7 em).
#let leading-double = 1.7em
// Single spacing (about 1.2 em pitch): allowed for footnotes, quotations, headings, captions,
// the TOC and TOA (MONT-FORM-004 excludes them from double spacing).
#let leading-tight = 0.5em
#let leading-single = 0.5em

// ---- Court constants (not case text) ----------------------------------------------------------
// MONT-COVER-001 (MRAP 11(6)(b)): the title of this court on the cover.
#let court-line = "IN THE SUPREME COURT OF MONTANA"
// MONT-TMPL-002: the typeface and size are declared here, not in the body.
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mont-brief-amicus: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover. MRAP 11(3)(b): pages are numbered.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: face, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a caption or a signature.
#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (MONT-COVER-001) ---------------------------------------------------------------------
// Order: court title; cause number (blank on a first filing); caption with party designations;
// the lower tribunal, venue and judge; the document title; counsel for each party with address,
// telephone, fax and e-mail.
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  for n in side.names { align(center, [#n]) }
  align(center, emph[#side.designation])
}

#let cover(meta) = {
  set text(size: 12pt)
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-line))
  v(1.2em)
  align(right, [Case Number: #meta.at("case_number", default: "")])
  v(1.2em)
  caption-side(meta.caption.at(0))
  v(0.6em)
  align(center, [v.])
  v(0.6em)
  caption-side(meta.caption.at(1))
  v(1.2em)
  if "lower_court" in meta {
    align(center, meta.lower_court)
    v(1.2em)
  }
  align(center, text(weight: "bold", meta.brief_title))
  v(1.6em)
  // MRAP 11(2) exempts the cover from the 14-point size, so the whole cover is set at 12 point to fit one page.
  grid(
    columns: (1fr, 1fr),
    gutter: 0.4in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
  if "cover_note" in meta {
    v(1em)
    meta.cover_note
  }
}

// ---- Table of authorities (MRAP 12) ------------------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the TOA is built from
// those records. Every other link prints its text only.
#let authority-line(a) = if a.kind == "case" {
  [#emph(a.name), #a.cite]
} else if "cite" in a {
  [#a.name, #a.cite]
} else {
  [#a.name]
}

#let table-of-authorities(auths) = context {
  let hits = query(<mont-toa-hit>)
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

// ---- Closing: date, signature blocks ------------------------------------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

// Markup blocks, not code blocks: a blank line separates paragraphs only in markup.
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date.

  Respectfully submitted,

  #signature-blocks(meta)
]

// ---- Certificates -----------------------------------------------------------------------------
// MONT-CERT-001 (MRAP 11(4)(e)): line spacing, typeface and point size, and the word count. The
// certificate is excluded from the length limit. The word count is supplied in the frontmatter.
#let certificate-of-compliance(meta) = [
  #heading(level: 1)[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  Pursuant to Rule 11 of the Montana Rules of Appellate Procedure, I certify that this brief is printed with a proportionately spaced Times New Roman text typeface of 14 points; is double spaced except for footnotes and for indented material; and the word count is #meta.compliance.word_count, excluding those sections exempted under Rule 11(4)(d).

  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  DATED this #meta.compliance.date.

  #v(1.2em)
  #pad(left: 3.2in)[
    #lines-of((meta.compliance.signer, meta.compliance.name))
  ]
]

// MONT-AMICUS-001 and MRAP 11: the service certificate names the manner of service and the date.
#let certificate-of-service(meta) = [
  #heading(level: 1)[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I, #meta.service.signer, hereby certify that I have served true and accurate copies of the foregoing document via #meta.service.method on #meta.service.date to the following:

  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #grid(
    columns: 1fr, // one column: long e-mail addresses must not overrun the margin
    gutter: 0.3in,
    ..meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
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
  show footnote: f => text(font: face, size: body-size, f) // the marker keeps the body size (MONT-FORM-003)
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
      [#l.body#metadata((key: l.dest.slice(4)))<mont-toa-hit>]
    } else if type(l.dest) == str {
      l.body
    } else {
      l
    }
  }
  it
}

// ---- Entry -------------------------------------------------------------------------------------
#let mont-brief-amicus(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document, not only inside the page wrappers: footnote areas are laid
  // out with the page's own style, and otherwise fall back to typst's default serif.
  set text(font: face, size: body-size, lang: "en")
  // Each section is its own page(): the cover has no folio; the front matter is roman; the body
  // restarts at 1 in Arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #set par(leading: leading-tight, spacing: 0.9em)
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
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-compliance(meta)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
