// Oregon Supreme Court (or): petition (ORAP 9.05(3) petition for review, 9.25 petition for reconsideration, 11.05 mandamus
// petition). Each is "in the form of a brief" under ORAP 5.05(3) (rules.md OR-FORM-001 to -009), so the page, type and spacing
// parameters follow the Court of Appeals brief template of the same rules.
//
// Content-agnostic: every number is a named parameter below and traces to a rule; no case-specific text, no measured
// coordinates, no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter.
// Layout: cover (page 1, unnumbered), back of cover with the counsel (page 2, unnumbered; OR-FORM-008 litigant contact
// information, ORAP 1.30), table of contents and of authorities (roman numerals, when `toc`/`authorities` are present),
// body (arabic numerals from 1), signature block, certificates.

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // OR-FORM-003 (ORAP 5.05(3)(b)(ii)): proportionally spaced serif; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 14pt                      // OR-FORM-003: not smaller than 14 point, text and footnotes.
#let body-leading = 1.65em                 // OR-FORM-006 (ORAP 5.05(3)(b)(iv)): double-spaced.
#let single-leading = 0.45em               // OR-FORM-006: quotations, headings and tables single-spaced.
#let margin-top = 0.75in                   // OR-FORM-002 (ORAP 5.05(3)(a)(ii)): top 3/4 inch.
#let margin-bottom = 0.75in                // OR-FORM-002: bottom 3/4 inch.
#let margin-inside = 1.25in                // OR-FORM-002: inside 1 1/4 inch (single-sided: the left edge).
#let margin-outside = 1in                  // OR-FORM-002: outside 1 inch (single-sided: the right edge).
#let page-number-ascent = 0.375in          // OR-FORM-007 (ORAP 5.05(3)(c)): page numbers at the top, within 3/8 inch of the top edge.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block right of centre (style; the exemplars do the same).
#let h1-centered = true                    // style: first-level headings centred (false: left, hanging)
#let rule-width = 0.5pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("or-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("or-petition-for-rehearing: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let lines-of(xs) = xs.map(l => inl(l)).join(linebreak())

/// Caption, left column: parties; entries are {names, designation} or {connector}.
#let caption-left(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  for (i, e) in need(meta, "caption").enumerate() {
    if i > 0 { v(1.1em) }
    if "connector" in e {
      pad(left: 0.5in, inl(e.connector))
    } else {
      stack(dir: ttb, spacing: 0pt, block(width: 100%, inset: (bottom: 0.3em), text(weight: if meta.at("caption_bold", default: false) { "bold" } else { "regular" }, e.names.join(linebreak()))), block(width: 100%, inset: (left: 0.5in), e.designation.join(linebreak())))
    }
  }
}

/// Caption, right column: groups of lines (court of origin, appellate and Supreme Court numbers).
#let caption-right(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  for (i, g) in need(meta, "case_lines").enumerate() {
    if i > 0 { v(1.1em) }
    lines-of(g)
  }
}

#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #n \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.9em)
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)]
  if not s.at("bare", default: false) { linebreak(); [#s.name] }
  for l in s.at("lines", default: ()) { linebreak(); inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "closing" in sig [ #inl(sig.closing) #v(0.8em) ]
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #for (i, s) in list.enumerate() {
      if i > 0 { v(1.1em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// Table of authorities: each entry carries `find`, a string present in every citation of the authority in the body; a show
// rule drops a marker after each occurrence and the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<or-toa>]

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
  let pages = query(<or-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  align(right, strong[Page])
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false,
        leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }, hang: 1.5em))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let or-petition-for-rehearing(meta, body) = {
  set document(title: need(meta, "title").join(" "))
  // OR-FORM-001, -002, -007: US letter; margins as above; consecutive page numbers at the top right
  // (page-number-ascent). The cover and the back of the cover carry no number.
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside),
    header-ascent: page-number-ascent,
    header: context {
      if here().page-numbering() != none { align(right, counter(page).display()) }
    },
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: if h1-centered { 0pt } else { 0.5in })
    #if h1-centered { align(center, text(weight: "bold", upper(it.body))) } else { text(weight: "bold", upper(it.body)) }
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, mark-authorities(meta, it))
  }

  // ---- Cover (OR-FORM-008, OR-FORM-010; ORAP 9.05(3)(a), 9.25, 11.05(2)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF OREGON])
    #v(0.3in)
    #grid(
      columns: (3.6in, 1fr),
      column-gutter: 0pt,
      block(inset: (right: 0.15in, bottom: 0.2in), stroke: (right: rule-width, bottom: rule-width), width: 100%, caption-left(meta)),
      block(inset: (left: 0.15in), caption-right(meta)),
    )
    #v(0.3in)
    #align(center)[
      #text(weight: "bold", lines-of(need(meta, "title")))
      #if "subtitle" in meta [ #v(0.9em) #lines-of(meta.subtitle) ]
    ]
    #v(0.5em)
    #line(length: 100%, stroke: rule-width)
    #if "notices" in meta {
      align(center, lines-of(meta.notices))
      v(0.5em)
      line(length: 100%, stroke: rule-width)
    }
    #v(1fr)
    #if "cover_note" in meta [ #lines-of(meta.cover_note) \ ]
    #if "counsel_note" in meta [ #emph(meta.counsel_note) ]
    #align(right, block(inset: (bottom: 0.08in), inl(need(meta, "filed_month_year"))))
  ]

  // ---- Back of the cover: counsel (ORAP 1.30 litigant contact information) ----
  page[
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      ..need(meta, "counsel_columns").map(col => col.map(counsel-group).join()),
    )
  ]

  // ---- Table of contents and authorities, lower-case roman numerals ----
  let front = meta.at("toc", default: false) or "authorities" in meta
  if front {
    set page(numbering: "i")
    pagebreak(weak: true)
    counter(page).update(1)
    if meta.at("toc", default: false) {
      page[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #align(center, text(weight: "bold")[TABLE OF CONTENTS])
        #v(0.5em)
        #align(right, strong[Page])
        #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
        #outline(title: none, depth: toc-depth, indent: 1.5em)
      ]
    }
    if "authorities" in meta { page(authorities-table(meta)) }
  }

  // ---- Body, arabic numerals from 1 ----
  set page(numbering: "1")
  pagebreak(weak: true)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (OR-FORM-009) ----
  v(0.3in)
  block(width: 100%, breakable: false)[#signature-block(need(meta, "signature"))]

  // ---- Certificate of compliance (OR-LEN-006; ORAP 5.05(1)(d)(i)) ----
  if "compliance" in meta {
    let cc = meta.compliance
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#inl(cc.at("heading", default: "Certificate of Compliance"))]
    for p in cc.at("paragraphs", default: ()) { par(inl(p)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true)
  }

  // ---- Certificate of filing and service (ORAP 16.45) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#inl(svc.at("heading", default: "Certificate of Filing and Service"))]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
  }
}
