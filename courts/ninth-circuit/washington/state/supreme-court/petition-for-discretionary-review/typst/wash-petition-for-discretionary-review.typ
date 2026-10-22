// Supreme Court of the State of Washington filings (wash): briefs, motions and petitions under RAP 10.3, 10.4,
// 13.4, 17.4 and 18.17 and GR 14. Content-agnostic: every number is a named parameter below and traces to the rule
// cited next to it (rules.md, IDs WASH-FORM-*, WASH-COVER-*, WASH-ORDER-*, WASH-CERT-*, WASH-LEN-*); no coordinates
// measured off any filed document, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the input (see the
// court's README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // WASH-FORM-004: 14-point serif equivalent to Times New Roman (RAP 18.17(a)(2)); Liberation Serif is the metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // WASH-FORM-004: 14 point for all text, footnotes and block quotations (RAP 18.17(a)(2)).
#let body-leading = 1.65em                 // WASH-FORM-005: double spaced (RAP 18.17(a)(2)). With typst's default line box this gives a baseline pitch of about 32 pt, twice the single line of this face at 14 pt.
#let single-leading = 0.45em               // WASH-FORM-005: footnotes and block quotations may be single spaced (RAP 18.17(a)(2)); also used for headings and the cover.
#let page-margin = (top: 1.5in, bottom: 1.6in, left: 2in, right: 1.5in)  // WASH-FORM-002: left 2 in, right, top and bottom at least 1 1/2 in (RAP 18.17(a)(1)). The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the margin (DEF-FORM-002). The first-page top margin conflict with GR 14(a) is open (WASH-FORM-003).
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // the signature block starts right of centre (style; the exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wash-brief: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("wash-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// The caption: one row per party line, a ")" column, and the case number and title beside the rows.
#let caption-table(meta, title) = {
  let rows = ()
  let first = true
  for side in meta.caption {
    if not first { rows.push((align(center)[vs.], false)) }
    first = false
    for n in side.names { rows.push((inl(n), false)) }
    rows.push((pad(left: 1.4in)[#emph(side.designation)], false))
  }
  let cells = ()
  let nrows = rows.len()
  for (i, r) in rows.enumerate() {
    cells.push(r.at(0))
    cells.push([)])
    if i == 0 {
      cells.push(grid.cell(rowspan: nrows, align: horizon + left, pad(left: 0.2in)[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #if "case_number" in meta [ #inl(meta.case_number) \ \ ]
        #title
      ]))
    }
  }
  grid(columns: (2.7in, 0.25in, 1fr), align: (left, center, left), row-gutter: 0.1em,
    ..cells,
  )
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block: "/s/" and the typed name, underlined, with the typed name again below;
/// counsel lines (WSBA number, address, telephone, e-mail) follow.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  // An e-mail address cannot wrap: a block that carries one starts further left so it stays inside the margin.
  let ind = if sig.at("lines", default: ()).any(l => l.contains("@")) { 2.4in } else { sig-indent }
  block(width: 100%, breakable: false, pad(left: ind)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of the authority in
/// the body. A show rule on that string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<wash-toa>]

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

/// Dot leaders and a page reference as one unbreakable box: the page reference always sits on the same line as the
/// leaders that lead to it (no break can fall between them), and it fills the rest of the entry's last line.
#let leader-page(body, p) = grid(columns: (1fr, auto), column-gutter: 0.1in, align: (left, bottom),
  [#body#box(width: 1fr, repeat[.#h(2pt)])],
  [#p],
)

/// One authorities entry. A short page list sits after the citation's leaders on its last line. A long list (more
/// than five pages) would wrap onto lines of its own, so the citation is set first and the leaders with the list
/// follow on a line of their own, right-aligned: the page reference always shares a line with its dot leaders.
#let toa-entry(e) = context {
  let pages = query(<wash-toa>)
    .filter(m => m.value == e.find)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  let txt = if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
  if pages.len() > 5 {
    [#inl(e.cite)\ #grid(columns: (1fr, auto), column-gutter: 0.1in, align: (left, bottom), repeat[.#h(2pt)], [#txt])]
  } else {
    leader-page(inl(e.cite), txt)
  }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #if "find" in e { toa-entry(e) } else { leader-page(inl(e.cite), e.at("pages", default: "--")) }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let wash-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // RAP 18.17(a)(1)-(2) and WASH-FORM-002/-004/-005: one-sided letter pages, 14 point serif, double spaced.
  // Front pages (contents, authorities) lowercase Roman, the cover unnumbered, the body Arabic from page 1.
  set page(paper: "us-letter", margin: page-margin, numbering: none, number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
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

  // Block quotations: indented, single-spaced (RAP 18.17(a)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size as the text, single-spaced (RAP 18.17(a)(2)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (RAP 10.3(a)(1); RAP Form 5; RAP 13.4(c)(1) for a petition; WASH-COVER-001, -004) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF WASHINGTON])
    #v(0.5in)
    #caption-table(meta, [#upper(inl(need(meta, "brief_title")))])
    #if "proceeding" in meta [ #v(0.4in) #inl(meta.proceeding) ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      // Two columns when every line is short; a long line (an e-mail address) sets the groups one under another.
      if need(meta, "counsel").any(g => g.lines.any(l => l.len() > 33)) {
        for g in need(meta, "counsel") { counsel-group(g) }
      } else {
        grid(columns: (1fr, 1fr), column-gutter: 0.4in, row-gutter: 0.6em,
          ..need(meta, "counsel").map(g => counsel-group(g)),
        )
      }
    }
  ]

  // ---- Table of contents (RAP 10.3(a)(2); RAP 13.4(c)(2); WASH-ORDER-001) ----
  if meta.at("toc", default: true) {
    page(numbering: "i", number-align: center + bottom)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      // Each entry: the heading text, then dot leaders and the page number with no space in between (as in the
      // authorities table), so a page number never wraps off its entry; the indent follows the heading level.
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, width: 100%)[
        #pad(left: (it.level - 1) * 1.5em)[#leader-page(it.element.body, context counter(page).at(it.element.location()).first())]
      ]
      #outline(title: none, depth: toc-depth)
    ]
  }

  // ---- Table of authorities (RAP 10.3(a)(2)) ----
  if "authorities" in meta {
    page(numbering: "i", number-align: center + bottom, authorities-table(meta))
  }

  // ---- Body: Arabic page numbers from the first page of the body ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Word count statement above the signature (RAP 18.17(b); WASH-CERT-001, -002) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "word_count" in meta {
      par(first-line-indent: (amount: para-indent, all: true))[This document contains #meta.word_count words, excluding the parts of the document exempted from the word count by RAP 18.17(b).]
    }
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), cmarker.render(meta.date, smart-punctuation: true)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (GR 30; Appellate Courts' Portal e-filing instructions) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#svc.at("heading", default: "Certificate of Service")]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true))
  }
}
