// Vermont Supreme Court amicus curiae brief template. Entry point: typst/main.typ, which calls
// vt-brief-amicus(meta, body) with the sample's frontmatter and markdown. Nothing here is
// case-specific: case text comes from the sample's frontmatter only.
// Layout conventions are taken from the Vermont filed exemplars (usage/SOURCE.md); no rule number
// is cited here because the Vermont rules were not retrievable for this template.
#import "@preview/cmarker:0.1.10"

// ---- Typography -----------------------------------------------------------------------------
// Times New Roman, body 12 pt, footnotes 11 pt, one-inch margins, US Letter (Convention from the
// Vermont exemplars, usage/SOURCE.md).
#let font-family = "Times New Roman"
#let body-size = 12pt
#let note-size = 11pt
#let margin = 1in
#let indent = 0.5in
// Double spacing for text; the font's own pitch is 0.72em, so each `leading` adds to it.
// Single spacing = 1.2em pitch; double = 2.4em pitch (Convention from the Vermont exemplars).
#let leading-double = 1.68em // pitch 2.4em: double spacing for text
#let leading-tight = 0.72em // pitch 1.44em: the TOC and TOA
#let leading-single = 0.48em // pitch 1.2em: headings, captions, quotations, footnotes, signatures

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("IN THE SUPREME COURT", "OF THE STATE OF VERMONT")
#let kinds = (
  (key: "case", title: "Cases"),
  (key: "statute", title: "Statutes and Regulations"),
  (key: "constitution", title: "Constitutional Provisions"),
  (key: "rule", title: "Rules"),
  (key: "other", title: "Other Authorities"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vt-brief-amicus: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a caption or a signature.
#let lines-of(list) = for l in list {
  block(width: 100%, [#l])
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
  align(center, [Docket No. #meta.case_number])
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
      #if "lower_court" in meta [
        Appeal from #meta.lower_court
        #v(0.8em)
      ]
      #if "lower_court_case" in meta [
        Case No. #meta.lower_court_case
      ]
    ],
  )
  v(2.2em)
  align(center, block(width: 100%, text(weight: "bold", meta.brief_title)))
  v(2.4em)
  grid(
    columns: range(meta.counsel.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
}

// ---- Table of authorities ------------------------------------------------------------------
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

// ---- Closing: signature blocks and certificates ----------------------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
  v(0.6em)
  align(right, meta.date)
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted,

  #signature-blocks(meta)
]

#let certificate-of-compliance(meta) = [
  #front-title[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #meta.compliance
  #v(1.2em)
  #signature-blocks(meta)
]

#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #meta.service.text
  #if "recipients" in meta.service [
    #v(1.2em)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    #grid(
      columns: 1fr,
      gutter: 0.3in,
      ..meta.service.recipients.map(g => {
        lines-of(g.names)
        lines-of(g.lines)
      }),
    )
  ]
  #v(1.2em)
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
  show footnote: f => text(font: font-family, size: 0.8em, f) // reference marker: smaller, so it does not rise above the text box
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
#let vt-brief-amicus(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document, not only inside the page wrappers: footnote areas are laid
  // out with the page's own style.
  set text(font: font-family, size: body-size, lang: "en")
  // Each section is its own page(): the cover has no folio; the front matter is roman; the body
  // restarts at 1 in Arabic numerals.
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
  if "compliance" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-compliance(meta)
    ]
  }
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
