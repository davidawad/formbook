// Mississippi Supreme Court filing template: briefs, amicus briefs, motions and petitions (one file, copied into each
// doc folder as typst/miss-<doctype>.typ). Entry point: typst/main.typ calls miss-filing(meta, body) with the sample's
// frontmatter and markdown. Rule IDs (MISS-*) and the source of every number are in ../rules.md; the page setup comes
// from ../eval.yaml. Nothing here is case-specific: case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- MRAP 32(a): typography and margins ---------------------------------------------------------
// No typeface is named by the rule (MISS-FORM-005); the exemplar is Times New Roman, so Times New Roman with its metric
// twin Liberation Serif as fallback (docs/FONTS.md rules 3 and 6; fb-9fyu).
#let face = ("Times New Roman", "Liberation Serif")
#let body-size = 12pt // MRAP 32(a): body text at least 12-point (MISS-FORM-002)
#let note-size = 11pt // MRAP 32(a): footnotes at least 11-point (MISS-FORM-002)
#let margin-left = 1.5in // MRAP 32(a): 1 1/2 in left (MISS-FORM-003)
#let margin-top = 1in // MRAP 32(a): 1 in top
#let margin-bottom = 0.75in // MRAP 32(a): 3/4 in bottom (page number sits in this margin)
#let margin-right = 0.5in // MRAP 32(a): 1/2 in right
#let indent = 0.5in
// Double spacing (MRAP 32(a)): line pitch = 1.1em ascent+descent of Liberation Serif plus leading. Single = leading 0.1em.
#let leading-double = 1.2em
#let leading-single = 0.25em

// ---- Constants (court-wide, not case text) ----------------------------------------------------
#let court-name = "IN THE SUPREME COURT OF MISSISSIPPI"
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miss-filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer (MRAP 32(a): all pages numbered). Not shown on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: face, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (MRAP 32(a)(1)-(6); MISS-COV-001, MISS-COV-002) -----------------------------------
#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-name))
  align(center, block(above: 0.8em, below: 1.6em, [No. #meta.case_number]))
  // The style (title) of the case, one entry per line as in the frontmatter.
  block(width: 100%, lines-of(meta.caption))
  v(1.8em)
  align(center, block(below: 1.6em, text(weight: "bold", [#for l in meta.brief_title [#l \ ]])))
  if "proceeding" in meta {
    align(center, block(below: 1.6em, lines-of(meta.proceeding)))
  }
  if "oral_argument" in meta {
    align(center, block(below: 1.6em, text(weight: "bold", meta.oral_argument)))
  }
  grid(
    columns: range(meta.counsel.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines, italic: false)
    }),
  )
}

// ---- Table of authorities (MRAP 28(a)(2), 28(d)); links `toa:KEY` record a page hit -----------
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
          par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: date, signature blocks (MISS-CERT-002) and certificate of service (MRAP 25(d)) --
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
  Respectfully submitted, #meta.date.
  #signature-blocks(meta)
]

#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  // Proof of service (MRAP 25(d)): the wording is the filer's own, carried in frontmatter `service.text`.
  #for t in meta.service.text [#t
  ]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  #meta.service.date
  #signature-blocks(meta)
]

// ---- Body styling -----------------------------------------------------------------------------
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
  show heading.where(level: 4): h => block(above: 1.1em, below: 0.6em, text(weight: "bold", h.body))
  show heading.where(level: 5): h => block(above: 1.1em, below: 0.6em, text(style: "italic", h.body))
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
// frontmatter: case_number, caption (lines), brief_title (lines), optional proceeding (lines), optional oral_argument,
// counsel ([{names, lines}]), date, signature ([{lines}]), optional service ({method, recipients}), optional
// authorities ({key: {kind, name, cite}}), tables (true for briefs: TOC and TOA; false for motions and petitions).
#let miss-filing(meta, body) = {
  set document(title: meta.case_number)
  set page(
    paper: "us-letter",
    margin: (left: margin-left, top: margin-top, bottom: margin-bottom, right: margin-right),
    footer-descent: 0.25in,
  )
  set text(font: face, size: body-size, lang: "en")
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  if meta.at("tables", default: false) {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CONTENTS]
      #outline(title: none, depth: 4, indent: 0pt)
    ]
    if "authorities" in meta {
      page(numbering: "i", footer: folio)[
        #show: style-body
        #front-title[TABLE OF AUTHORITIES]
        #table-of-authorities(meta.authorities)
      ]
    }
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
