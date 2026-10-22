// Supreme Court of Louisiana brief template (briefs under Rule VII; writ applications under Rule X share the layout).
// Entry point: typst/main.typ calls la-petition-for-rehearing(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to a rule in ../../rules.md (LA-* IDs). Nothing here is
// case-specific: case text comes from the sample's frontmatter and body only.
#import "@preview/cmarker:0.1.10"

// ---- Rules VII 2 and X 2(b): typography, paper, spacing and margins -----------------------------
#let font-family = "Times New Roman" // the rules name no face (LA-FORM-006); the filed exemplars are Times
#let body-size = 12pt // LA-FORM-006: no less than 11 and no more than 12 point
#let paper-size = "us-legal" // LA-FORM-001, LA-FORM-002: legal paper (8 1/2 x 14 in)
#let side-margin = 1in // LA-FORM-004: left, right and bottom at least 3/4 in and at most 1 1/4 in
#let bottom-margin = 1in
#let top-margin = 1.5in // LA-FORM-005: top at least 1 1/2 in and at most 2 in
#let indent = 0.5in
// Line pitch (LA-FORM-003). Measured on this font: the natural line box is about 0.69 em, so 1.6 em of
// leading gives a 27.5 pt pitch for 12 point (Word double spacing for Times 12 pt is 27.6 pt); 0.5 em gives
// 14.3 pt (single).
#let leading-double = 1.6em
#let leading-single = 0.5em // quotations, headings, captions, footnotes, cover and signature blocks

// ---- Court constants (not case text) -----------------------------------------------------------
#let court-line = "SUPREME COURT OF LOUISIANA" // LA-COV-001(1)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("la-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Folio: Arabic or roman per section; none on the cover (LA-FORM-007).
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (LA-COV-001 to 003) -----------------------------------------------------------------
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  lines-of(side.names)
  block(width: 100%, [#h(0.5in)#side.designation])
}

// Optional frontmatter keys (the exemplar's own wording): docket_label ("No." unless given), versus ("V."
// unless given). counsel: false and show-title: false give the caption-only cover of a proposed order.
#let cover(meta, counsel: true, show-title: true) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-line))
  v(1.2em)
  align(center, [#meta.at("docket_label", default: "No.") #meta.docket_number])
  v(1.6em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.4in,
    [
      #caption-side(meta.caption.at(0))
      #v(0.8em)
      #block(width: 100%, [#h(0.5in) #meta.at("versus", default: "V.")])
      #v(0.8em)
      #caption-side(meta.caption.at(1))
    ],
  )
  v(1.2em)
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  for l in meta.court_origin {
    align(center, block(width: 100%, l))
  }
  v(1.6em)
  if show-title {
    align(center, text(weight: "bold", meta.brief_title))
    v(2.2em)
  }
  if counsel {
    grid(
      columns: range(meta.counsel.len()).map(_ => 1fr),
      gutter: 0.3in,
      ..meta.counsel.map(g => {
        lines-of(g.names)
        lines-of(g.lines, italic: false)
      }),
    )
  }
}

// Proposed order (optional frontmatter key `order`: title, text, signature.lines), on the caption page.
#let order-page(meta) = {
  let o = meta.order
  cover(meta, counsel: false, show-title: false)
  v(1.6em)
  align(center, text(weight: "bold", o.at("title", default: "ORDER")))
  v(1.2em)
  set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  cmarker.render(o.text, raw-typst: false, smart-punctuation: true, h1-level: 1)
  v(1.2em)
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(right, block(width: 3.3in, lines-of(o.signature.lines)))
}

// ---- Index of authorities (LA-TOA-001) --------------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; other links print text only.
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
        below: 0.6em,
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

// ---- Closing: "Respectfully submitted" and the signature blocks -------------------------------
// Optional frontmatter key `dated`: printed on the left of the closing line, as in the motion exemplar.
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  #if "dated" in meta [#grid(columns: (1fr, 1fr), [Dated: #meta.dated], [Respectfully submitted,])] else [Respectfully submitted,]
  #v(0.6em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
]

// ---- Certificate of service (LA-CERT, LA-BRF-005): a page of its own after the signature -----
#let certificate(meta) = {
  let c = meta.certificate
  front-title[#c.at("title", default: "CERTIFICATE OF SERVICE")]
  set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  cmarker.render(c.text, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if "recipients" in c {
    v(1.2em)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    // Two recipients to a row, so each address block keeps a readable measure.
    let items = c.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    })
    for r in range(0, items.len(), step: 2) {
      grid(
        columns: (1fr, 1fr),
        gutter: 0.3in,
        items.at(r),
        if r + 1 < items.len() { items.at(r + 1) } else { [] },
      )
      v(1.2em)
    }
  }
  if "signature" in c {
    v(1.4em)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    align(right, block(width: 3.3in, lines-of(c.signature.lines)))
  }
}

// ---- Body styling (applied with `#show: style-body`) -----------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "en")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  // Level-1 headings are centered bold capitals (SUMMARY, ARGUMENT, CONCLUSION, CERTIFICATE OF SERVICE).
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  // Level-2 headings are bold, hanging under their numeral (I., II.).
  show heading.where(level: 2): h => block(above: 1.2em, below: 1em, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(
    above: 1.1em,
    below: 1em,
    text(weight: "bold", style: "italic", h.body),
  )
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote: f => text(font: font-family, f)
  show footnote.entry: n => {
    set text(font: font-family, size: body-size)
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
  it
}

// Links to `toa:KEY` record a page hit for the index of authorities. The rule is set once for the whole
// document (not per page), so links inside footnotes are recorded too.
#let toa-link(l) = {
  if type(l.dest) == str and l.dest.starts-with("toa:") {
    [#l.body#metadata((key: l.dest.slice(4)))<toa-hit>]
  } else if type(l.dest) == str {
    l.body
  } else {
    l
  }
}

// ---- Entry -------------------------------------------------------------------------------------
#let la-petition-for-rehearing(meta, body) = {
  set document(title: meta.docket_number + " " + meta.brief_title)
  set page(
    paper: paper-size,
    margin: (left: side-margin, right: side-margin, top: top-margin, bottom: bottom-margin),
    footer-descent: 0.4in,
  )
  // Set once for the whole document: footnote areas are laid out with the page's own style.
  set text(font: font-family, size: body-size, lang: "en")
  show link: toa-link
  // Cover: no folio. Index pages: roman. Body: restarts at 1 in Arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  // Optional frontmatter key `contents: false` drops the table of contents (a motion has no headings).
  if meta.at("contents", default: true) {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CONTENTS]
      #outline(title: none, depth: 2, indent: 0pt)
    ]
  }
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[INDEX OF AUTHORITIES]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  if "certificate" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate(meta)
    ]
  }
  if "order" in meta {
    page(numbering: none, footer: none)[
      #show: style-body
      #order-page(meta)
    ]
  }
}
