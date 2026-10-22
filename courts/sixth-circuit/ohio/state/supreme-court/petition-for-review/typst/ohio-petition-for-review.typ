// Ohio Supreme Court filing template (RoP 3.07, 3.09, 7.02). Entry point:
// typst/main.typ, which calls ohio-brief(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to ../rules.md. Nothing here is case-specific:
// case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Per-document constants (set by the doc type; see the header of each doc folder's README) --
#let cover-color = none      // no cover color is required by the RoP
#let margin-left = 1in      // RoP 3.09(B)(2)(c): at least one inch on all sides; the left margin is flush left
#let has-pa = true                // RoP 7.02(C)(1): the table of contents of propositions of law (no table of authorities)
#let cover-service = false  // RoP 3.11(B)(1)(a): the certificate of service follows the signature, not the cover
#let cover-page = true        // RoP 3.07: a white cover page with the case, court, title, party and counsel

// ---- Rule 5(B)(4), 31(A)(1): typography and page -------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // RoP 3.09(B)(1)(b): Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md)
#let body-size = 12pt // RoP 3.09(B)(1)(b), (B)(3): at least 12-point type
#let note-size = 12pt // RoP 3.09(B)(1)(b): footnotes are at least 12-point type
#let margin-other = 1in // RoP 3.09(B)(2)(c): 1-inch margins on all other sides
#let indent = 0.5in
// RoP 3.09(B)(3): double-spaced text. Pitch is the font's line height plus leading.
#let leading-double = 1.61em  // pitch 27.6 pt for 12-pt type (leading + the face's 0.69 em line height), double spaced
#let leading-single = 0.46em // single spacing for captions, lists, quotations and footnotes (RoP 3.09(B)(3) allows single spacing for footnotes and quotations)

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("IN THE SUPREME COURT OF OHIO",)
#let pa-title = "TABLE OF CONTENTS" // RoP 7.02(C)(1)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohio-brief: the sample must start with a YAML frontmatter block") }
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

// Certificate of service (RoP 3.11(B)(1)(a)): the method, the date and the counsel served are the filer's.
#let service-text(meta) = {
  set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  [A copy of the foregoing was served by #meta.service.method on #meta.service.date upon the following counsel of record:]
}

#let service-list(meta) = grid(
  columns: (1fr, 1fr),
  gutter: 0.3in,
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

  v(0.5em)
  align(center, [Case No. #meta.case_number])
  // The lower court's line(s): the case number of the action appealed from (RoP 3.07(C)).
  if "lower_court" in meta {
    for l in meta.lower_court { align(center, l) }
  }
  v(1.0em)
  caption-side(meta.caption.at(0))
  v(0.5em)
  block(width: 100%, [#h(0.5in) -VS-])
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

  v(0.4em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines, italic: true)
    }),
  )
  if cover-service {
    v(0.9em)
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(0.4em)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: indent)
    [I certify that a true and accurate copy of the foregoing document has been served by
    #meta.service.method on #meta.service.date upon the following:]
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

// Word-count certificate: none is required by the RoP (the page limit applies); kept for a filer who supplies word_count.
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
  set par(justify: false, leading: leading-double, spacing: 0pt, first-line-indent: indent)
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
#let ohio-brief(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: (top: margin-other, bottom: margin-other, left: margin-left, right: margin-other), footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // The cover: no folio.
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
      #counter(page).update(1)
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
