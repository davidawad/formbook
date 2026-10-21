// Nebraska Court of Appeals (nebctapp): amicus curiae brief (amicus-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Neb. Ct. R. App. P. § 2-103 and § 2-109, https://supremecourt.nebraska.gov/supreme-court-rules/;
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
#let sig-indent = 2.6in                       // signature block sits right of centre (convention in the exemplars).
#let toc-depth = 3                          // § 2-109(D)(1)(b): table of contents with page references.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nebctapp-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nebctapp-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Divider between cover blocks.
#let cover-rule() = align(center, block(above: 0.5em, below: 0.5em, line(length: 70%, stroke: 0.5pt)))

/// One caption side: names, then the designation flush right.
#let caption-side(side) = {
  set par(first-line-indent: 0pt, spacing: 0pt)
  align(center)[#for n in side.names [ #inl(n) ]]
  if "designation" in side { v(0.3em); align(right, inl(side.designation)) }
}

/// Counsel block: lines, left-aligned.
#let counsel-block(g) = {
  set par(first-line-indent: 0pt, spacing: 0pt)
  set text(size: 11pt)
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block (§ 2-103(C)(1) identifies the filer): rows of an optional label and lines.
#let signature-block(rows) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(first-line-indent: 0pt, spacing: 0pt, hanging-indent: 0pt)
    #for r in rows {
      let label = r.at("label", default: "")
      block(above: 0.9em, below: 0pt, grid(columns: (0.5in, 1fr), column-gutter: 0pt,
        if label != "" { strong(label) } else { [] },
        [#for l in r.lines [ #inl(l) \ ]]))
    }
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<nebctapp-toa>]

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
  let pages = query(<nebctapp-toa>)
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

#let nebctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // § 2-103(A)(1): letter, portrait. § 2-103(C)(2): numbered from the cover as page one, number in the bottom
  // margin on every page except the cover.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt),
    numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // § 2-103(A)(3): left-aligned, not justified.
  set par(leading: line-leading, spacing: para-gap + line-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, bold. Level 2: point heading, bold, hanging. Level 3: sub-point, bold.
  // Level 4: centred numeral heading (propositions). Headings are typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true)[
    #set par(first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true)[
    #set par(first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1.1em, below: 0.9em, sticky: true)[
    #set par(first-line-indent: 0pt, hanging-indent: 1in)
    #h(0.5in)#strong(it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.6em, sticky: true)[
    #set par(first-line-indent: 0pt)
    #align(center, it.body)
  ]

  // Block quotations: indented.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 1em, below: 1em)[
    #set par(first-line-indent: 0pt, spacing: para-gap + line-leading)
    #it.body
  ]
  // Footnotes: § 2-103(A)(3) does not permit them; a sample that has one keeps it at text size.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (§ 2-103(C)(1)): the cover is the title page and page one ----
  page(numbering: none)[
    #set par(first-line-indent: 0pt, spacing: 0pt)
    #align(center)[
      #strong[#need(meta, "case_number")]
      #v(0.8em)
      #strong[#need(meta, "court_line")]
    ]
    #cover-rule()
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #align(center)[v.] #v(0.3em) ]
      #caption-side(side)
      #v(0.4em)
    ]
    #cover-rule()
    #align(center)[#inl(need(meta, "proceeding")) #if "judge" in meta [ \ #inl(meta.judge)]]
    #cover-rule()
    #align(center)[#strong(inl(need(meta, "brief_title")))]
    #cover-rule()
    #v(0.5em)
    #grid(columns: (1fr,) * need(meta, "counsel").len(), column-gutter: 0.3in, ..need(meta, "counsel").map(counsel-block))
  ]

  // ---- Table of contents (§ 2-109(D)(1)(b)) ----
  {
    set par(first-line-indent: 0pt, spacing: 0pt)
    heading(level: 1)[Table of Contents]
    show outline.entry: it => block(above: 0.35em, below: 0pt, it)
    outline(title: none, depth: toc-depth, indent: 0.5in)
  }
  pagebreak(weak: true)

  // ---- Table of authorities, then the body ----
  if "authorities" in meta {
    authorities-table(meta)
    pagebreak(weak: true)
  }

  // Footnote definitions sit at the end of the body; they go with the main text, where their
  // references are. The signature follows the body; the certificates (transcribed as filed) follow it.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position(regex("\n# (Certificate|CERTIFICATE|Proof|PROOF)"))
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the conclusion) ----
  if "signature" in meta {
    v(1.2em)
    signature-block(meta.signature)
  }
  // Two-column signature of several counsel: the date on the left, "Respectfully submitted," on the right.
  if "signature_columns" in meta {
    v(1.2em)
    block(breakable: false)[
      #set par(first-line-indent: 0pt, spacing: 0pt)
      #if "date" in meta [ #grid(columns: (1fr, 1fr), column-gutter: 0.3in, inl(meta.date), inl(meta.at("submitted", default: ""))) #v(0.8em) ]
      #grid(columns: (1fr,) * meta.signature_columns.len(), column-gutter: 0.3in,
        ..meta.signature_columns.map(g => [#for l in g.lines [ #inl(l) \ ]]))
    ]
  }

  // ---- Certificates ----
  if certs.len() > 0 {
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
  if "cert_signature" in meta {
    v(1em)
    signature-block(meta.cert_signature)
  }
}
