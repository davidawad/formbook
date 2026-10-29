// Supreme Judicial Court of Massachusetts: answering (appellee's principal) brief template, mass-answering-brief.
// Requirement IDs (MA-...) refer to ../../rules.md; each number below cites the Mass. R. A. P. rule it comes from.
// Content-agnostic: every case-specific word comes from the markdown INPUT and its YAML frontmatter. No case text,
// no coordinates measured off any filing, no forced line breaks in this file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 14pt                       // MRAP 20(a)(4)(B) (MA-FORM-002): proportional font of 14 point or larger, footnotes included.
#let page-margin = 1in                      // MRAP 20(a)(4)(A) (MA-FORM-003): top, bottom, left and right margins at least 1 inch.
#let body-leading = 1.02em                  // MRAP 20(a)(4)(C) (MA-FORM-004): double spacing, at most 3 lines per vertical inch.
#let single-leading = 0.46em                // MRAP 20(a)(4)(C): argument headings, footnotes, indented quotations may be single-spaced (0.46 em on the cap-height line: a 1.15 em pitch).
#let para-indent = 0.5in                    // style: first-line indent of text paragraphs.
#let toc-depth = 3
#let sig-indent = 3.2in                     // style: signature and counsel blocks start right of centre.
#let court-lines = ("SUPREME JUDICIAL COURT", "FOR THE COMMONWEALTH OF MASSACHUSETTS")  // MRAP 20(a)(6)(B)(i): name of the court.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mass-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Items one per line, flush left, single-spaced.
#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(l => if bold { text(weight: "bold", inl(l)) } else { inl(l) }),
)

/// One caption side: the party names, then the designation (none for the "v." line between the sides).
#let caption-side(side) = align(center)[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #stack(dir: ttb, spacing: single-leading, ..side.names.map(n => inl(n)))
  #if "designation" in side [
    #v(0.25em)
    #emph(side.designation)
  ]
]

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  stack(
    dir: ttb,
    spacing: single-leading,
    ..g.names.map(n => text(weight: "bold", inl(n))),
    ..g.at("lines", default: ()).map(l => inl(l)),
  )
  v(0.3em)
}

/// The signature block: an optional introduction, the firm, the signer with the typed name, then the
/// lines beneath (address, telephone, e-mail, date).
#let signature-block(sig) = block(width: 100%, breakable: false, pad(left: sig-indent)[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  #lines-of(sig.at("intro", default: ()))
  #if "firm" in sig [ #v(0.6em) #strong(sig.firm) ]
  #for s in sig.at("signers", default: ()) [
    #v(1.2em)
    #underline[#inl(s.name)]
    #v(single-leading)
    #lines-of(s.at("lines", default: ()))
  ]
  #if sig.at("lines", default: ()).len() > 0 [
    #v(0.6em)
    #lines-of(sig.lines)
  ]
])

// Table of authorities. Each entry carries `find`: one string, or a list of strings, that appears in every
// citation of the authority in the body (a full cite or a short form). A show rule on that string drops a marker
// after each occurrence; the table lists the pages of the markers, or "passim" for more than five pages.
#let toa-marker(key) = [#metadata(key)<mass-toa>]

#let finds-of(e) = if type(e.find) == str { (e.find,) } else { e.find }

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        for key in finds-of(e) {
          out = {
            show key: it => it + toa-marker(key)
            out
          }
        }
      }
    }
  }
  out
}

#let toa-pages(finds) = context {
  let pages = query(<mass-toa>)
    .filter(m => m.value in finds)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else if pages.len() > 5 { [passim] } else { pages.sorted().map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The page references sit in their own column aligned to the last line of the citation.
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(
          columns: (1fr, auto),
          column-gutter: 0.25in,
          align: (left + top, right + bottom),
          inl(e.cite),
          box(if "find" in e { toa-pages(finds-of(e)) } else { e.at("pages", default: "") }),
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mass-answering-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // MRAP 20(a)(4)(A) (MA-FORM-005): page numbers in the margin, consecutive from the cover (page 1). The top and
  // bottom margins are 1 inch plus 4 pt so that a footnote reference on the first line of a page stays inside the margin.
  set page(
    paper: "us-letter",
    margin: (top: page-margin + 4pt, bottom: page-margin + 4pt, left: page-margin, right: page-margin),
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold); levels 2 and 3 are
  // sub-headings (bold, left, hanging). Argument headings may be single-spaced (MRAP 20(a)(4)(C)).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented on both sides, single-spaced (MRAP 20(a)(4)(C)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same 14 point face as the text, single-spaced (MRAP 20(a)(4)(B), (C)). Citations in
  // footnotes count toward the table of authorities.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (MRAP 20(a)(6)(B)): the cover is page 1 ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #lines-of(court-lines, bold: true)
      #v(0.2in)
      #text(weight: "bold")[NO. #need(meta, "case_number")]
    ]
    #v(0.2in)
    #for side in need(meta, "caption") [
      #caption-side(side)
      #v(0.15in)
    ]
    #align(center)[
      #inl(need(meta, "lower_court"))
      #v(0.15in)
      #inl(need(meta, "date"))
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 15pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #pad(left: sig-indent, {
      for g in need(meta, "counsel") { counsel-group(g) }
    })
  ]

  // ---- Table of contents (MRAP 16(a)(3)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (MRAP 16(a)(4)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: everything before the addendum sentinel ----
  let parts = body.split("\n# ADDENDUM\n")
  mark-authorities(meta, cmarker.render(parts.at(0), raw-typst: false, smart-punctuation: true))

  // ---- Signature block (MRAP 16(a)(12)) ----
  v(0.4em)
  signature-block(need(meta, "signature"))

  // ---- Addendum (MRAP 16(a)(13)) ----
  if parts.len() > 1 {
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[Addendum]
    mark-authorities(meta, cmarker.render(parts.at(1), raw-typst: false, smart-punctuation: true))
  }

  // ---- Certificate of compliance (MRAP 16(a)(14), 16(k)) ----
  if "compliance" in meta {
    let c = meta.compliance
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[Certificate of Compliance]
    for p in c.paragraphs { par(inl(p)) }
    v(0.4em)
    signature-block(c.signature)
  }

  // ---- Certificate of service (MRAP 16(a)(15), 13(d)) ----
  if "service" in meta {
    let svc = meta.service
    v(1.2em)
    block(breakable: false)[
      #heading(level: 1, outlined: false)[Certificate of Service]
      #for p in svc.paragraphs { par(inl(p)) }
    ]
    v(0.4em)
    signature-block(svc.signature)
  }
}
