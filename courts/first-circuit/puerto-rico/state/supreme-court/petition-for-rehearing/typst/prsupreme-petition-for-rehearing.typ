// Supreme Court of Puerto Rico (Tribunal Supremo de Puerto Rico) alegato template: cover, indice de
// materias, indice legal, body, signature block. Entry point: typst/main.typ calls pr-brief(meta, body).
// Every number is a named constant below and traces to a rule in ../rules.md. Nothing here is
// case-specific: case text comes from the sample's frontmatter and body only.
#import "@preview/cmarker:0.1.10"

// ---- Rule 40(b): typography, paper, spacing and margins -----------------------------------------
// Rule 40(b) names Times New Roman, Courier New or Arial; the template uses Times New Roman
// (Liberation Serif is its metric twin, per docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 12pt // Rule 40(b): size 12
#let paper-size = "us-legal" // Rule 40(b): 8 1/2 x 14 in legal paper
#let margin = 1in // Rule 40(b): left and right not less than 1/2 in; convention 1 in all sides
#let indent = 0.5in
#let leading-double = 1.15em // Rule 40(b): double spaced (font pitch roughly 2 x single)
#let leading-single = 0em // quotations, headings, captions, signature blocks, footnotes

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-lines = ("ESTADO LIBRE ASOCIADO DE PUERTO RICO", "TRIBUNAL SUPREMO DE PUERTO RICO")
#let kinds = (
  (key: "case", title: "JURISPRUDENCIA"),
  (key: "statute", title: "LEYES Y ESTATUTOS"),
  (key: "rule", title: "REGLAMENTOS Y REGLAS"),
  (key: "other", title: "OTRAS FUENTES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pr-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (Rule 33(b)) -----------------------------------------------------------------------
#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(1.6em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.4in,
    lines-of(meta.caption_left),
    lines-of(meta.caption_right),
  )
  v(1.6em)
  align(center, text(weight: "bold", meta.brief_title))
  v(1.6em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    row-gutter: 1em,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
}

// ---- Indice legal (Rule 38(b)) ----------------------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page. Other links print text only.
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

// ---- Signature block (Rule 40(a)) ---------------------------------------------------------------
#let signature-block(meta) = block(breakable: false)[
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(1.2em)
  #align(right, block(width: 3.3in, lines-of(meta.signature)))
]

// ---- Body styling (applied with `#show: style-body`) -------------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "es")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  // cmarker output sets its own paragraph leading; the show rule keeps the double spacing of Rule 40(b).
  show par: set par(leading: leading-double)
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
  show footnote.entry: n => {
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
#let pr-brief(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: paper-size, margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "es")
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[ÍNDICE DE MATERIAS]
    #outline(title: none, depth: 2, indent: 0pt)
  ]
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[ÍNDICE LEGAL]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: false, h1-level: 1)
    #signature-block(meta)
  ]
}
