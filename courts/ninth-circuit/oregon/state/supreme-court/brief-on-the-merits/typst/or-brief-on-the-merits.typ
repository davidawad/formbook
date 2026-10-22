// Oregon Supreme Court (or): brief-on-the-merits in the form of a brief (ORAP 5.05(3); ORAP 9.17 briefs on the merits; ORAP 8.15 amicus).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Oregon Rules of Appellate Procedure, ORAP 2019 compilation effective 2019-04-15, see ../rules.md rows
// OR-FORM-001 to -014, OR-LEN-006). No case-specific text, no coordinates measured off any filed brief,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter.
//
// Layout: cover (and the page behind it carrying the counsel, when the filer puts them there), table of
// contents, optional indexes, table of authorities (lowercase roman page numbers), then the body (arabic
// page numbers from 1), signature block, certificate of compliance and certificate of filing and service.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // OR-FORM-003 (ORAP 5.05(3)(b)(ii)): proportionally spaced Times New Roman; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 14pt                      // OR-FORM-003: not smaller than 14 point, text and footnotes.
#let body-leading = 1.65em                 // OR-FORM-006 (ORAP 5.05(3)(b)(iv)): double-spaced; about 2 x the 1.15 em single line of this face at 14 pt.
#let single-leading = 0.45em               // OR-FORM-006 excludes quotations, headings and tables: single-spaced.
#let margin-top = 0.75in                   // OR-FORM-002 (ORAP 5.05(3)(a)(ii)): top 3/4 inch.
#let margin-bottom = 0.75in                // OR-FORM-002: bottom 3/4 inch.
#let margin-inside = 1.25in                // OR-FORM-002: inside 1 1/4 inch; single-sided print puts the inside on the left edge.
#let margin-outside = 1in                  // OR-FORM-002: outside 1 inch (the right edge).
#let page-number-ascent = 0.375in          // OR-FORM-007 (ORAP 5.05(3)(c)): page numbers at the top, within 3/8 inch of the top edge.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; the exemplars do the same).
#let cover-title-size = 14pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let as-array(x) = if type(x) == array { x } else { (x,) }

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("or-brief-on-the-merits: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("or-brief-on-the-merits: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let lines-of(xs) = as-array(xs).map(inl).join(linebreak())

/// One caption side: names, then designation lines (indented), as the filer sets them.
#let caption-side(side, centred) = {
  set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  let names = as-array(need(side, "names")).map(inl).join(linebreak())
  let desig = as-array(need(side, "designation")).map(inl).join(linebreak())
  if centred {
    align(center)[#names \ #desig]
  } else {
    [#names]
    pad(left: 0.5in)[#desig]
  }
}

#let counsel-group(g, role-style) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading,
    block(width: 100%, lines-of(g.lines)),
    if "role" in g { block(width: 100%, inset: (left: if role-style == "italic" { 0pt } else { 0.5in }), if role-style == "italic" { emph(inl(g.role)) } else { inl(g.role) }) },
  )
}

#let counsel-list(groups, role-style) = for g in groups {
  block(breakable: false, below: 1.1em, counsel-group(g, role-style))
}

/// Signature block: the sign mark and the typed name, then the lines beneath (bar number, role, address).
#let signature-block(sig, first-only: false, with-closing: true) = {
  let all = if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: sig.at("lines", default: ())),) }
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if with-closing and "closing" in sig [ #inl(sig.closing) #v(0.8em) ]
    #if "firm" in sig [ #sig.firm #v(0.8em) ]
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      [#sig.at("mark", default: "s/") #s.name]
      for l in s.at("lines", default: ()) { linebreak() + inl(l) }
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of the authority in
/// the body. A show rule on that string drops a marker after each occurrence; the table lists the pages of the
/// markers.
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

#let leader-row(content, trailing) = block(above: 0.9em, below: 0.9em, breakable: false)[
  #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  #content #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #trailing
]

#let front-title(t) = align(center, block(below: 1.2em)[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #text(weight: "bold", t)
])

#let authorities-table(meta) = {
  front-title[TABLE OF AUTHORITIES]
  if meta.at("toa_page_label", default: false) { align(right)[Page(s)] }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
    }
  }
}

#let indexes-block(meta) = for ix in meta.indexes {
  front-title(lines-of(as-array(ix.heading)))
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for e in ix.entries {
    block(above: 0.9em, below: 0.9em, breakable: false)[
      #if "label" in e {
        grid(columns: (1.4in, 1fr), column-gutter: 0.2in, inl(e.label), inl(e.text))
      } else {
        [#inl(e.text) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #strong(e.at("pages", default: ""))]
      }
    ]
  }
  v(1em)
}

// ---------------------------------------------------------------------------
// Cover (OR-FORM-008, OR-FORM-010: ORAP 5.05(3)(d), 1.45(1))
// ---------------------------------------------------------------------------

#let cover-rule(meta) = align(center, line(length: meta.at("rule_width_pct", default: 100) * 1%, stroke: 0.6pt))

#let caption-centred(meta) = {
  for (i, side) in meta.caption.enumerate() {
    if i > 0 { align(center, block(above: 0.9em, below: 0.9em)[v.]) }
    caption-side(side, true)
  }
  if "lower_court" in meta {
    for g in meta.lower_court { align(center, block(above: 1em, below: 0pt, lines-of(g))) }
  }
}

#let caption-columns(meta) = {
  let paren = meta.at("parens", default: false)
  let left = {
    for (i, side) in meta.caption.enumerate() {
      if i > 0 { block(above: 0.9em, below: 0.9em, pad(left: 0.5in)[v.]) }
      caption-side(side, false)
    }
  }
  let right = {
    set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    for g in meta.at("lower_court", default: ()) { block(below: 1em, lines-of(g)) }
  }
  layout(size => {
    let paren-w = if paren { 0.3in } else { 0pt }
    let left-w = size.width * 0.54
    if paren {
      let h = measure(width: left-w, left).height
      let stack-of(k) = { set par(leading: single-leading, spacing: 0pt); for _ in range(k) [) \ ] }
      let pitch = measure(stack-of(2)).height - measure(stack-of(1)).height
      let n = calc.ceil(h / pitch)
      grid(
        columns: (left-w, paren-w, 1fr),
        left,
        stack-of(n),
        right,
      )
    } else {
      grid(columns: (left-w, 1fr), column-gutter: 0.15in, left, right)
    }
  })
}

#let cover-page(meta) = page(header: none, margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside))[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.6em)
  #if "case_number_above" in meta [ #align(center, inl(meta.case_number_above)) #v(0.3em) ]
  #align(center)[IN THE SUPREME COURT OF THE STATE OF OREGON]
  #v(0.25in)
  #if meta.at("caption_rule", default: false) { cover-rule(meta); v(0.12in) }
  #if meta.at("cover_style", default: "centred") == "centred" { caption-centred(meta) } else { caption-columns(meta) }
  #v(0.2in)
  #cover-rule(meta)
  #v(0.15in)
  #align(center, text(weight: "bold", size: cover-title-size, lines-of(need(meta, "brief_title"))))
  #v(0.15in)
  #cover-rule(meta)
  #v(0.2in)
  #if "review_lines" in meta {
    align(center, lines-of(meta.review_lines))
    if meta.at("review_rule", default: false) { v(0.15in); cover-rule(meta) }
  }
  #v(0.2in)
  #if "counsel_cover" in meta {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    set text(size: meta.at("counsel_size", default: 12pt))
    grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 0.8em,
      ..meta.counsel_cover.map(g => counsel-group(g, meta.at("role_style", default: "indent"))))
  }
  #v(1fr)
  #grid(columns: (1fr, auto),
    if "cover_note" in meta { emph(inl(meta.cover_note)) },
    inl(need(meta, "filed_month_year")))
  #v(0.1in)
]

#let back-page(meta, groups) = page(header: none, margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside))[
  #set text(size: meta.at("counsel_size", default: 12pt))
  #let role-style = meta.at("role_style", default: "indent")
  #if meta.at("counsel_back_columns", default: 1) == 2 {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 1.1em, ..groups.map(g => counsel-group(g, role-style)))
  } else {
    counsel-list(groups, role-style)
  }
]

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let or-brief-on-the-merits(meta, body) = {
  set document(title: lines-of(need(meta, "brief_title")))
  // Heading numbers: `number_sections: true` (default) numbers level 1 as I., II. and the levels below as A., 1., a.;
  // `false` leaves level 1 unnumbered (INTRODUCTION) and numbers level 2 as I., level 3 as A.; `"typed"` numbers
  // nothing: the filer types the numbers in the heading text.
  let number-sections = meta.at("number_sections", default: true)
  let typed = number-sections == "typed"

  // OR-FORM-001, -002, -007: US letter; margins as above; consecutive page numbers at the top.
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside),
    header-ascent: page-number-ascent,
    header: context {
      let n = numbering(page.numbering, counter(page).get().first())
      // Body pages (arabic): top right; front matter (roman): top centre. Real text: gate0.awk drops a page number alone in the top margin.
      if page.numbering == "1" { align(right, n) } else { align(center, n) }
    },
    footer: none,
    numbering: "i",
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: if typed { none } else { (..nums) => {
    let n = nums.pos()
    let level = n.len()
    let kinds = ("I.", "A.", "1.", "a.", "(i)")
    let k = if number-sections == true { level - 1 } else { level - 2 }
    if k < 0 { [] } else { numbering(kinds.at(calc.min(k, kinds.len() - 1)), n.last()) }
  } })

  // Heading levels in the markdown body: level 1 is a section (centred, bold); deeper levels are bold, left,
  // with the number hanging.
  show heading: it => {
    let num = if it.numbering != none { counter(heading).display(it.numbering) } else { [] }
    if it.level == 1 {
      block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
        #set text(size: type-size)
        #set par(leading: single-leading, first-line-indent: 0pt)
        #align(center, text(weight: "bold", if number-sections == true and it.numbering != none { [#num #h(0.5em) #it.body] } else { it.body }))
      ]
    } else {
      block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
        #set text(size: type-size)
        #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
        #pad(left: (it.level - 2) * 0.5in, text(weight: "bold", style: if it.level >= 4 { "italic" } else { "normal" }, [#if it.numbering != none { box(width: 0.5in, num) }#it.body]))
      ]
    }
  }

  // Block quotations: indented, single-spaced, double space above and below (OR-FORM-006).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: body-leading, below: body-leading)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (OR-FORM-003), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, mark-authorities(meta, it))  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover, and the page behind it when the counsel are listed there ----
  cover-page(meta)
  if "counsel_back" in meta { back-page(meta, meta.counsel_back) }

  // ---- Table of contents ----
  counter(page).update(1)
  page[
    #front-title[TABLE OF CONTENTS]
    #set par(leading: single-leading, first-line-indent: 0pt)
    #show outline.entry.where(level: 1): it => block(above: 1.1em, below: 0.9em, strong(it))
    #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
    #outline(title: none, depth: toc-depth, indent: auto)
  ]

  // ---- Indexes of the excerpt of record and appendices; table of authorities ----
  if "indexes" in meta { page(indexes-block(meta)) }
  if "authorities" in meta { page(authorities-table(meta)) }

  // ---- Body: arabic page numbers from 1 ----
  counter(page).update(1)
  page(numbering: "1", {
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (OR-FORM-009): name and signature of the author, firm, party ----
  v(0.3in)
  block(width: 100%, breakable: false)[#signature-block(need(meta, "signature"))]

  // ---- Certificate of compliance (OR-LEN-006, ORAP 5.05(1)(d)(i)): wording is filer-supplied ----
  if "compliance" in meta {
    let cc = meta.compliance
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[#inl(cc.at("heading", default: "CERTIFICATE OF COMPLIANCE"))]
    for p in cc.at("paragraphs", default: ()) { par(inl(p)) }
    if "date" in cc { par(inl(cc.date)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true, with-closing: false)
  }

  // ---- Certificate of filing and service (ORAP 16.45) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[#inl(svc.at("heading", default: "CERTIFICATE OF FILING AND SERVICE"))]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #lines-of(r)
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true), with-closing: false)
  }
  })
}
