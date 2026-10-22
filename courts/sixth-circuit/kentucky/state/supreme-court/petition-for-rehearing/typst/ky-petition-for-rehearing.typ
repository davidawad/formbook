// Kentucky Supreme Court filing template (RAP 5, 15, 31, 32, 34, 43, 44, 60). Entry point:
// typst/main.typ, which calls ky-brief(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to ../rules.md. Nothing here is case-specific:
// case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Per-document constants (set by the doc type; see the header of each doc folder's README) --
#let cover-color = rgb("#b7e1b1")      // RAP 31(C)(2), 43(B)(4), 34(B)(4); none where the RAP sets no cover color
#let margin-left = 1.5in      // RAP 31(A)(1)(e): 1.5 in left for briefs; RAP 5(B)(4), 44(G), 60(B): 1 in otherwise
#let has-pa = false                // RAP 32(A)(2), 32(B)(2), 32(C)(1), 32(D): statement of points and authorities
#let cover-service = true  // RAP 31(C)(1)(b): the signed certificate of service sits on the front cover
#let cover-page = true        // briefs: a cover page (RAP 31(C)); motions and petitions open page 1 with the caption

// ---- Rule 5(B)(4), 31(A)(1): typography and page -------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // RAP 31(A)(2): Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md)
#let body-size = 12pt // RAP 5(B)(4), 31(A)(1)(c): black type no smaller than 12 point
#let note-size = 12pt // RAP 31(A)(1)(d), 44(G): footnotes no smaller than 12 point
#let margin-other = 1in // RAP 5(B)(4), 31(A)(1)(e): 1-inch margins on all other sides
#let indent = 0.5in
// RAP 5(B)(4): at least a double space between lines. Pitch is the font's line height plus leading.
#let leading-double = 0.9em
#let leading-single = 0.3em // single spacing for captions, lists, quotations and footnotes (RAP 5(B)(4) allows single only where a rule does not require double)

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("COMMONWEALTH OF KENTUCKY", "SUPREME COURT OF KENTUCKY")
#let pa-title = "STATEMENT OF POINTS AND AUTHORITIES" // RAP 32(A)(2), 32(B)(2)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ky-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover.
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
  block(width: 100%, align(right, [#side.designation]))
}

// Certificate of service: the same wording on the cover (RAP 31(C)(1)(b)) or on its own page.
#let service-text(meta) = {
  set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  [I certify that a true and accurate copy of the foregoing document has been served by
  #meta.service.method on #meta.service.date upon the following:]
}

#let service-list(meta) = grid(
  columns: (1fr, 1fr),
  column-gutter: 0.3in,
  row-gutter: 0.6em, // about half a blank line between recipients: the 0.3-in row gap pushed the cover certificate past one page (DEF-COVER-001)
  ..meta.service.recipients.map(g => {
    lines-of(g.names)
    lines-of(g.lines)
  }),
)

// The caption block: court, case number, parties, title. A brief opens with it on its cover; a motion
// or petition opens its first page with it (no separate cover).
#let caption-header(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(0.5em)
  align(center, [CASE NO. #meta.case_number])
  // The lower court's line(s): the case number of the action appealed from (RAP 31(C)(1)(a)).
  if "lower_court" in meta {
    for l in meta.lower_court { align(center, l) }
  }
  v(1.0em)
  caption-side(meta.caption.at(0))
  v(0.5em)
  block(width: 100%, [#h(0.5in) V.])
  v(0.5em)
  caption-side(meta.caption.at(1))
  v(0.8em)
  align(center, text(weight: "bold", meta.brief_title))
  if "party_line" in meta {
    v(0.5em)
    meta.party_line
  }
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  caption-header(meta)
  v(0.8em)
  block(width: 100%, [Submitted by:])
  v(0.4em)
  grid(
    columns: if meta.counsel.len() == 1 { 1 } else { (1fr, 1fr) }, // a lone counsel block takes the full width, so its lines do not wrap (DEF-COVER-001)
    column-gutter: 0.3in,
    row-gutter: 0.6em, // as the service list (DEF-COVER-001)
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines, italic: true)
    }),
  )
  if cover-service {
    v(0.9em)
    block(sticky: true, width: 100%, below: 0.4em + leading-single, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))) // the title stays with its text when the certificate carries over (RAP 31(C)(1)(b))
    set par(leading: leading-single, spacing: leading-single, first-line-indent: indent)
    par(first-line-indent: (amount: indent, all: true))[I certify that a true and accurate copy of the foregoing document has been served by
    #meta.service.method on #meta.service.date upon the following:] // indented after the title block too
    v(0.6em)
    service-list(meta)
    if "record_certificate" in meta {
      v(0.6em)
      meta.record_certificate
    }
    v(0.5em)
    lines-of(meta.service.signer)
  }
}

// ---- Table of authorities ---------------------------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page (the TOA lists the pages
// where the authority is cited). Every other link prints its text only.
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

// ---- Closing: signature blocks and certificate page -------------------------------------------
// One signature block sits on the right half of the page; several share two columns.
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  if meta.signature.len() == 1 {
    pad(left: 3in, lines-of(meta.signature.at(0).lines))
  } else {
    grid(
      columns: (1fr, 1fr),
      gutter: 0.3in,
      ..meta.signature.map(g => lines-of(g.lines)),
    )
  }
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  #if "dated" in meta [DATE: #meta.dated]

  Respectfully submitted,
  #signature-blocks(meta)
]

// The filer's word-count certificate (RAP 15(E)), when the document carries one; the words are the filer's.
#let word-count-page(meta) = [
  #front-title[WORD-COUNT CERTIFICATE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #meta.word_count
  #v(0.8em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #lines-of(meta.word_count_signer)
]

#let certificate-page(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #service-text(meta)
  #v(0.8em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #service-list(meta)
  #v(1.4em)
  #lines-of(meta.service.signer)
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------
#let style-body(it) = {
  set list(marker: [•]) // one bullet at every level: the nested marker (U+2023) is not in Liberation Serif
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
#let ky-brief(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: (top: margin-other, bottom: margin-other, left: margin-left, right: margin-other), footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // The cover (briefs only): colored where the RAP sets a cover color; no folio.
  if cover-page {
    page(
      numbering: none,
      footer: none,
      background: context if cover-color != none and counter(page).get().first() == 1 {
        place(top + left, rect(width: 100%, height: 100%, fill: cover-color, stroke: none))
      },
    )[
      #show: style-body
      #cover(meta)
    ]
  }
  if has-pa {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[#pa-title]
      #outline(title: none, depth: 2, indent: 0pt)
      #if "authorities" in meta {
        pagebreak(weak: true)
        table-of-authorities(meta.authorities)
      }
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #if not cover-page {
      caption-header(meta)
      v(1.4em)
    }
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  if not cover-service {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-page(meta)
    ]
  }
  if "word_count" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #word-count-page(meta)
    ]
  }
}
