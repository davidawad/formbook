// Supreme Court of North Carolina: motion and supporting memorandum (motion-brief). The form rules
// are those of the court's rules.md (requirement IDs NC-...).
// Rule-driven and content-agnostic: no case text, no measured coordinates, no forced line breaks.
// The body is markdown rendered by cmarker; the cover, lower-court references, signature,
// certificates and authorities come from the YAML frontmatter of the sample. The index (table of
// contents and table of cases and authorities) is generated.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola" // NC-FORM-003: Century Schoolbook (vendored metric clone)
#let type-size = 12pt // NC-FORM-002: proportional serif, 12 to 14 point
#let note-size = 12pt // NC-FORM-002: no smaller than 12 point
#let body-leading = 1.68em // NC-FORM-005: double-spaced text
#let single-leading = 0.3em // single-spaced: cover, index, quotations, footnotes, signature
#let body-gap = 0.6em // space between paragraphs (style choice)
#let page-margin = 1in // NC-FORM-004: one inch on all sides
#let para-indent = 0.5in // style choice
#let toa-passim = 7 // style choice: "passim" when an authority is cited on this many pages or more

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: false)

#let need(meta, key) = {
  if key not in meta { panic("nc-motion: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nc-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Escape a literal string for use inside a regex.
#let escape-re(s) = {
  let out = ""
  for c in s.clusters() {
    if c in ("\\", ".", "^", "$", "*", "+", "?", "(", ")", "[", "]", "{", "}", "|") { out += "\\" }
    out += c
  }
  out
}

/// A row of n asterisks (the rule's asterisk lines on the cover).
#let stars(n) = {
  let s = ""
  for _ in range(n) { s += "*" }
  s
}

// ---------------------------------------------------------------------------
// Cover (NC-CONV-001): docket and district, court name, asterisk rule, caption with the lower-court
// references at right, and the bold brief title between asterisk lines. No folio.
// ---------------------------------------------------------------------------

#let caption-block(groups) = {
  for (i, g) in groups.enumerate() {
    if i > 0 { v(1.0em) }
    if "connector" in g {
      block(width: 100%)[#g.connector]
      v(0.6em)
    }
    for l in g.at("lines", default: ()) { block(width: 100%)[#l] }
    if "role" in g {
      v(0.6em)
      block(width: 100%, pad(left: 1in)[#g.role])
    }
  }
  v(0.6em)
}

#let lower-block(refs) = {
  for (i, r) in refs.enumerate() {
    if i > 0 { v(1.3em) }
    align(center)[#underline[#r.label]]
    align(center)[#r.number]
  }
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  grid(
    columns: (1fr, 1fr),
    align(left)[No. #need(meta, "docket")],
    align(right)[#need(meta, "district")],
  )
  v(1.2em)
  align(center)[#need(meta, "court_name")]
  v(0.8em)
  align(center)[#stars(56)]
  v(0.8em)
  // The party column takes two thirds of the width, as on the filed motion, and the lower-court references the
  // rest: at half the width a long party list ran the cover onto a second unnumbered page (DEF-COVER-001).
  table(
    columns: (2fr, 1fr),
    stroke: none,
    inset: 0pt,
    table.cell(inset: (right: 0.2in, bottom: 0.3em), stroke: (right: 0.75pt, bottom: 0.75pt))[
      #caption-block(need(meta, "caption"))
    ],
    table.cell(inset: (left: 0.3in), align: top)[
      #v(0.9em)
      #lower-block(meta.at("lower_court", default: ()))
    ],
  )
  v(1.2em)
  align(center)[#stars(40)]
  v(0.4em)
  // The title spans the text width, as on the filed motion (a 4 in measure added lines to the cover, DEF-COVER-001).
  align(center)[#text(weight: "bold", need(meta, "brief_title"))]
  v(0.4em)
  align(center)[#stars(40)]
}

// ---------------------------------------------------------------------------
// Signature block and certificates (NC-FORM-005 single-spaced signature; certificate of service)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = meta.at("signature", default: ())
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.0em)
    Respectfully submitted, this #need(meta, "date").
    #v(1.0em)
    #pad(left: 2.5in)[
      #for g in sig {
        for l in g.at("lines", default: ()) { block(width: 100%)[#l] }
        v(0.6em)
      }
    ]
  ]
}

// Each entry of `certificates` is {title, text, recipients?, date?, signer?}. A recipient is
// {lines}; the signer is {lines}. The certificate of service is listed in the index.
#let certificate(meta) = {
  for c in meta.at("certificates", default: ()) {
    heading(level: 1, outlined: true, numbering: none)[#c.title]
    set par(leading: body-leading, spacing: body-gap, first-line-indent: para-indent)
    [#c.text]
    v(0.8em)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    for r in c.at("recipients", default: ()) {
      for l in r.at("lines", default: ()) { block(width: 100%)[#l] }
      v(0.8em)
    }
    if "date" in c { block(width: 100%)[#c.date]; v(0.8em) }
    if "signer" in c {
      pad(left: 2.5in)[
        #for l in c.signer.at("lines", default: ()) { block(width: 100%)[#l] }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Index: table of cases and authorities (NC-BRF-001), built from the authority hits in the body
// ---------------------------------------------------------------------------

#let kinds = (
  (key: "case", title: "Cases"),
  (key: "constitution", title: "Constitutional Provisions"),
  (key: "statute", title: "Statutes"),
  (key: "rule", title: "Rules"),
)

#let table-of-authorities(auths) = context {
  let hits = query(<toa-hit>)
  for k in kinds {
    let rows = auths.pairs().filter(((key, a)) => a.kind == k.key)
    if rows.len() == 0 { continue }
    rows = rows.sorted(key: ((key, a)) => lower(a.name))
    block(above: 1.1em, below: 0.5em, text(weight: "bold", k.title))
    for (key, a) in rows {
      let pages = hits.filter(h => h.value.key == key).map(h => counter(page).at(h.location()).first())
      let pages = pages.dedup().sorted()
      let shown = if pages.len() >= toa-passim { "passim" } else { pages.map(str).join(", ") }
      block(
        above: 0pt,
        below: 0.6em,
        par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)[
          #a.name#if a.at("cite", default: "") != "" [, #a.cite] #box(width: 1fr, repeat[.]) #shown
        ],
      )
    }
  }
}

// ---------------------------------------------------------------------------
// Body styling
// ---------------------------------------------------------------------------

// Authority hits: each `find` string (one or a list per authority) is matched in the text and marked
// with its key; the index reads the marks back with query. Built once per document from the frontmatter.
#let hit-rules(auths) = {
  let pairs = ()
  for (k, a) in auths.pairs() {
    let fs = a.at("find", default: ())
    if type(fs) == str { fs = (fs,) }
    for f in fs { pairs.push((find: f, key: k)) }
  }
  let sorted = pairs.sorted(key: p => -p.find.len())
  let pattern = if sorted.len() > 0 { sorted.map(p => escape-re(p.find)).join("|") } else { "ZZZQQXX" }
  let mark(m) = {
    let hit = sorted.find(p => p.find == m.text)
    if hit == none { m } else { [#m#metadata((key: hit.key))<toa-hit>] }
  }
  (pattern: pattern, mark: mark)
}

#let style-body(auths, it) = {
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-gap, first-line-indent: para-indent)
  // Each main section (Issues Presented, Statement of the Case, Argument, Conclusion, Certificate
  // of Service) starts a new page, as in the filed exemplar.
  show heading.where(level: 1): h => context {
    // Each main section after the first starts a page. The first section already starts the body
    // page, and a weak break there would leave that page blank.
    let start = query(<nc-body-start>).first().location()
    let first = query(heading.where(level: 1).after(start)).first()
    if h.location() != first.location() { pagebreak(weak: true) }
    block(above: 0pt, below: 1.1em, width: 100%, align(center, text(weight: "bold", h.body)))
  }
  show heading.where(level: 2): h => block(above: 1em, below: 0.7em, width: 100%, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(above: 0.9em, below: 0.6em, width: 100%, text(weight: "bold", h.body))
  show heading: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  show quote.where(block: true): q => block(above: 0.8em, below: 1em, pad(
    left: 0.5in,
    right: 0.5in,
    {
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      q.body
    },
  ))
  show link: l => l.body
  let rules = hit-rules(auths)
  show regex(rules.pattern): m => (rules.mark)(m)
  it
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: type-size, counter(page).display(n))) }
}

#let nc-motion(meta, body) = {
  set document(title: need(meta, "brief_title"), author: "")
  set page(paper: "us-letter", margin: page-margin, footer-descent: 0.4in)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  let auths = meta.at("authorities", default: (:))
  // Footnote bodies are not reached by the body rule above, so the same marks are set for them.
  // The reference mark is kept inside the top margin when it falls on a page's first line.
  show footnote: set text(size: 0.6em, baseline: -0.1em)
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  let frules = hit-rules(auths)
  show footnote.entry: n => {
    show regex(frules.pattern): m => (frules.mark)(m)
    [#n]
  }

  // Cover: caption only (no folio).
  page(numbering: none, footer: none)[
    #cover(meta)
  ]
  // Index, roman numerals from i: the generated table of contents.
  page(numbering: "i", footer: folio)[
    #counter(page).update(1)
    #set par(first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[INDEX]]
    #v(0.8em)
    #outline(title: none, depth: 3, indent: n => n * 0.5in)
  ]
  // Table of cases and authorities, generated from the body's hits.
  if auths.len() > 0 {
    page(numbering: "i", footer: folio)[
      #show heading.where(level: 1): h => align(center, text(weight: "bold", h.body))
      #heading(level: 1, outlined: true, numbering: none)[TABLE OF CASES AND AUTHORITIES]
      #v(0.8em)
      #table-of-authorities(auths)
    ]
  }
  // Body, numbered from 1, then the signature and the certificates.
  page(numbering: "1", footer: folio)[
    #counter(page).update(1)
    #metadata(none)<nc-body-start>
    #show: style-body.with(auths)
    #cmarker.render(body, raw-typst: false, smart-punctuation: false)
    #signature(meta)
    // The certificate of service starts its own page, as in the filed exemplar.
    #pagebreak(weak: true)
    #certificate(meta)
  ]
}
