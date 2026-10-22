// Supreme Court of New Jersey filing template (R. 2:6; answering-brief; rules.md). Entry point: typst/main.typ,
// which calls nj-answering-brief(meta, body) with the sample's frontmatter and markdown. Every number is a named
// constant below and traces to rules.md (NJ-* ids). Nothing here is case-specific: case text comes from frontmatter.
#import "@preview/cmarker:0.1.10"

// ---- Rule 2:6-10: typography and paper ---------------------------------------------------------
// Typeface: Times New Roman or a similar face (rules.md NJ-FORM-003). Body and note type are set at 14 pt,
// stricter than the 12-point minimum; see the OPEN item in rules.md.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt
#let note-size = 14pt
#let margin = 1in // rules.md NJ-FORM-004: approximately one inch
#let indent = 0.5in
// Measured on the render (14 pt Liberation Serif, typst 0.15): the natural line is 0.69 em; a leading of 1.6 em
// gives a 32 pt pitch (double), 0.46 em a 16 pt pitch (single), 0.5 em a 17 pt pitch (TOC and TOA entries).
#let leading-double = 1.6em // NJ-FORM-002: double-spaced text
#let leading-single = 0.46em // footnotes, block quotations, captions, headings, signature and address lines
#let leading-tight = 0.5em // TOC and TOA entries

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-line = "SUPREME COURT OF NEW JERSEY" // NJ-COV-001: the appellate court named on the cover
#let versus = "VS." // caption connector used on the cover in the NJ exemplar
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nj filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the bottom margin; none on the cover.
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

// ---- Cover (Rule 2:6-6(a)) -----------------------------------------------------------------------
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  lines-of(side.names)
  block(width: 100%, [#h(0.5in)#side.designation])
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  // DEF-COVER-001: the caption is two columns (parties left; court, docket, nature and court below right), the NJ
  // convention in both filed examples, so the R. 2:6-6(a) cover fits one page at 14 pt.
  let parties = {
    // The party named first is the appellant or petitioner in the trial or appellate record (Rule 2:6-6(a)).
    caption-side(meta.caption.at(0))
    v(0.8em)
    block(width: 100%, [#h(0.5in) #versus])
    v(0.8em)
    caption-side(meta.caption.at(1))
  }
  let court = {
    block(width: 100%, text(weight: "bold", court-line))
    block(width: 100%, text(weight: "bold", "DOCKET NO.: " + meta.case_number))
    if "nature" in meta [
      #v(1.2em)
      #block(width: 100%, [#meta.nature])
    ]
    if "below" in meta [
      #v(1.2em)
      #block(width: 100%, [#meta.at("below_label", default: "On Appeal From:")])
      #lines-of(meta.below)
    ]
  }
  let head = {
    grid(columns: (1fr, 1fr), column-gutter: 0.3in, parties, court)
    v(2.2em)
    align(center, text(weight: "bold", meta.brief_title))
    v(2.4em)
  }
  // Attorney of Record, On the Brief, then the counsel line.
  let group(g) = block(width: 100%, breakable: false, below: 1.2em)[
    #if "heading" in g [#block(width: 100%, text(weight: "bold", g.heading))]
    #lines-of(g.names)
    #lines-of(g.lines)
  ]
  let n-lines(g) = g.names.len() + g.lines.len() + if "heading" in g { 1 } else { 0 }
  let groups = meta.counsel
  layout(size => {
    let stacked = { for g in groups { group(g) }; lines-of((meta.counsel_for,)) }
    if measure(block(width: size.width, { head; stacked })).height <= size.height {
      head
      stacked
    } else {
      // DEF-COVER-001: counsel blocks that do not fit stacked sit in two columns, split where the columns balance.
      let cost(k) = calc.max(groups.slice(0, k).map(n-lines).sum(default: 0), groups.slice(k).map(n-lines).sum(default: 0))
      let k = range(1, calc.max(groups.len(), 2)).sorted(key: cost).first()
      head
      grid(
        columns: (1fr, 1fr),
        column-gutter: 0.3in,
        for g in groups.slice(0, k) { group(g) },
        for g in groups.slice(k) { group(g) },
      )
      lines-of((meta.counsel_for,))
    }
  })
}

// ---- Table of authorities (R. 2:6-2(a)(5)): a link whose target is `toa:KEY` in the body is recorded with its page;
// the TOA is built from those records. Every other link prints its text only.
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

// ---- Closing: signature block and date -----------------------------------------------------------
// The signature groups stack one under another: side-by-side columns overflow the right margin with long names.
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted,
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #for g in meta.signature [
    #lines-of(g.lines)
    #v(1.2em)
  ]
  #if "date" in meta [Dated: #meta.date]
]

// Keys of the toa: links inside a footnote body. Links in a footnote are not queryable, so the footnote rule
// below records each one at the reference point in the body flow.
#let toa-keys(c) = {
  if type(c) == array { return c.map(toa-keys).flatten() }
  if type(c) != content { return () }
  if c.func() == link and type(c.dest) == str and c.dest.starts-with("toa:") { return (c.dest.slice(4),) }
  let f = c.fields()
  let out = ()
  if "children" in f { out += toa-keys(f.children) }
  if "body" in f { out += toa-keys(f.body) }
  out
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
  show heading.where(level: 4): h => block(above: 1.1em, below: 0.6em, text(weight: "bold", h.body))
  show heading.where(level: 5): h => block(above: 1.1em, below: 0.6em, text(weight: "bold", style: "italic", h.body))
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote: f => {
    for k in toa-keys(f.body) { [#metadata((key: k))<toa-hit>] }
    text(font: font-family, size: note-size, f)
  }
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
#let nj-answering-brief(meta, body) = {
  set document(title: "Docket No. " + meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // Cover: no folio. Front matter: roman numerals. Body: restarts at 1 in arabic numerals.
  page(margin: (top: 1in, rest: margin), numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #counter(page).update(1) // front matter starts at i after the unnumbered cover, as both filed examples print
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 5, indent: 0pt)
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
}
