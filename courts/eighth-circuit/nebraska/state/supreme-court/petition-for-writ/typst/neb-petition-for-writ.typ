// Nebraska Supreme Court (neb): application for leave to commence an original action with the attached verified petition for writ (petition-for-writ).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Neb. Ct. R. App. P. § 2-103 and § 2-115, https://supremecourt.nebraska.gov/supreme-court-rules/;
// see ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("TeX Gyre Schola",)     // § 2-103(A)(4): Century Schoolbook preferred; TeX Gyre Schola is its vendored clone (docs/FONTS.md).
#let type-size = 12pt                       // § 2-103(A)(4): no less than 12 nor more than 13 point.
#let line-leading = 0.658em                  // § 2-103(A)(3): lines spaced at 1.15. Pitch = natural line box + leading = 1.15 x the face’s single line (1.2 em) = 16.56 pt at 12 pt.
#let page-margin = 108pt                    // § 2-103(A)(3): margins 1.5 inches on all sides.
#let para-gap = 0.6em                       // § 2-103(A)(3): extra line spacing is allowed between paragraphs and before headings.
#let para-indent = 0.5in
#let sig-indent = 1.5in                       // signature block sits right of centre (convention in the exemplars).
#let toc-depth = 3                          // § 2-109(D)(1)(b): table of contents with page references.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("neb-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("neb-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Divider between cover blocks.
#let cover-rule() = align(center, block(above: 1em, below: 1em, line(length: 70%, stroke: 0.5pt)))

/// One caption side: names, then the designation flush right.
#let caption-side(side) = {
  set par(first-line-indent: 0pt, spacing: 0pt)
  align(center)[#for n in side.names [ #inl(n) \ ]]
  if "designation" in side { align(center, inl(side.designation)) }
}

/// Counsel block: lines, left-aligned.
#let counsel-block(g) = {
  set par(first-line-indent: 0pt, spacing: 0pt)
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block (§ 2-103(C)(1) identifies the filer): rows of an optional label and lines.
#let signature-block(rows) = {
  block(width: 100%, breakable: true, pad(left: sig-indent)[
    #set par(first-line-indent: 0pt, spacing: 0pt, hanging-indent: 0pt)
    #for r in rows {
      let label = r.at("label", default: "")
      block(above: 0.9em, below: 0pt, breakable: false, grid(columns: (0.5in, 1fr), column-gutter: 0pt,
        if label != "" { strong(label) } else { [] },
        [#for l in r.lines [ #inl(l) \ ]]))
    }
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<neb-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<neb-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  for group in meta.authorities {
    block(above: 1.1em, below: 0.5em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.5em, below: 0.5em, breakable: false)[
        #set par(first-line-indent: 0pt, hanging-indent: 0.5in, spacing: 0pt)
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

/// Caption: parties at left, case number and document title at right (pleading style; § 2-115(A) petitions carry no brief cover).
#let caption-block(meta, title) = {
  set par(first-line-indent: 0pt, spacing: 0pt, leading: line-leading)
  align(center, strong(need(meta, "court_line")))
  v(1em)
  grid(columns: (1fr, 1fr), column-gutter: 0.3in,
    {
      for c in need(meta, "caption") {
        block(above: 0pt, below: 0.9em, pad(left: if c.indent { 0.5in } else { 0pt }, inl(c.text)))
      }
    },
    {
      inl(need(meta, "case_ref"))
      v(1.5em)
      strong(title)
    })
  v(1em)
}

#let neb-brief(meta, body) = {
  set document(title: need(meta, "part_titles").first())
  // § 2-103(A)(1): letter, portrait; (A)(3) 1.5 inch margins.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt),
    numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // § 2-103(A)(3): left-aligned, not justified.
  set par(leading: line-leading, spacing: para-gap + line-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true)[
    #set par(first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true)[
    #set par(first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1.1em, below: 0.9em, sticky: true)[
    #set par(first-line-indent: 0pt)
    #strong(it.body)
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 1em, below: 1em)[
    #set par(first-line-indent: 0pt, spacing: para-gap + line-leading)
    #it.body
  ]

  let parts = body.split("<!-- part -->")
  let titles = need(meta, "part_titles")
  for (i, part) in parts.enumerate() {
    if i > 0 {
      pagebreak()
      counter(page).update(1)
    }
    caption-block(meta, titles.at(i))
    cmarker.render(part, raw-typst: false, smart-punctuation: true)
    if "signature" in meta {
      v(1.2em)
      if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
      signature-block(meta.signature)
    }
  }
}
