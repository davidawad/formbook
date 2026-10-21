// Supreme Court of South Carolina: principal brief (respondent's brief), final brief, reply brief,
// amicus brief. SCACR Rules 208, 211, 213, 267. Rule-driven and content-agnostic: no case text, no
// measured coordinates, no forced line breaks. Requirement IDs (SC-...) refer to ../../rules.md.
// The body is markdown rendered by cmarker; caption, counsel, signature, and authorities come from
// the YAML frontmatter of the sample. Table of contents and table of authorities are generated.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // SC-FORM-003: declared face
#let type-size = 12pt // SC-FORM-001, SCACR 267(c): 12-point or larger
#let note-size = 12pt // SCACR 267(c): no type smaller than 12-point
#let body-leading = 1.1em // SC-FORM-001, SCACR 267(c): double-spaced
#let single-leading = 0.35em // single: caption, counsel, quotations, footnotes, TOA entries
#let body-gap = 0.6em // space between paragraphs (style choice)
#let page-margin = 1in // SC-FORM-002, SCACR 267(d): one inch on all sides
#let para-indent = 0.5in
#let toa-passim = 7 // style choice: "passim" when an authority is cited on this many pages or more

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: false)

#let need(meta, key) = {
  if key not in meta { panic("sc-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sc-brief: the sample must start with a YAML frontmatter block") }
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

// ---------------------------------------------------------------------------
// Cover (SC-FORM-004, SC-FORM-005): the caption only; no page number
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center)[THE STATE OF SOUTH CAROLINA]
  v(0.3em)
  align(center)[#need(meta, "court_name")]
  v(0.9em)
  for l in meta.at("lower_court", default: ()) { align(center)[#l] }
  v(0.9em)
  line(length: 45%, stroke: 0.6pt)
  v(0.6em)
  for n in need(meta, "appellate_case_numbers") { align(center)[Appellate Case No. #n] }
  v(0.6em)
  line(length: 45%, stroke: 0.6pt)
  v(1.2em)
  for g in need(meta, "caption") {
    if "connector" in g {
      align(center)[#g.connector]
      v(0.6em)
    }
    let lines = g.lines
    for (j, l) in lines.enumerate() {
      if j < lines.len() - 1 {
        block(width: 100%, inl(l))
      } else {
        block(width: 100%, [#inl(l) #box(width: 1fr, repeat[.]) #g.role])
      }
    }
    v(0.6em)
  }
  line(length: 45%, stroke: 0.6pt)
  v(0.8em)
  align(center)[#text(weight: "bold", need(meta, "brief_title"))]
  v(0.6em)
  line(length: 45%, stroke: 0.6pt)
}

// Counsel page: the counsel blocks and the date (SC-FORM-007, SC-FORM-012).
#let counsel-page(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  let groups = meta.at("counsel", default: ())
  let cols = if groups.len() >= 2 { 2 } else { 1 }
  grid(
    columns: (1fr,) * cols,
    column-gutter: 0.4in,
    row-gutter: 1.2em,
    ..groups.map(g => {
      for n in g.at("names", default: ()) { block(width: 100%, inl(n)) }
      v(0.3em)
      for l in g.at("lines", default: ()) { block(width: 100%, inl(l)) }
      if "note" in g { v(0.4em); block(width: 100%, emph(inl(g.note))) }
    }),
  )
  v(1fr)
  if "date" in meta [ Dated: #meta.date ]
}

// ---------------------------------------------------------------------------
// Signature block (SC-FORM-006, SC-FORM-007): "Respectfully submitted" then the signers
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = meta.at("signature", default: ())
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.0em)
    Respectfully submitted,
    #v(0.8em)
    #grid(
      columns: (1fr,) * calc.min(calc.max(sig.len(), 1), 2),
      column-gutter: 0.4in,
      row-gutter: 1.2em,
      ..sig.map(g => {
        for l in g.lines { block(width: 100%, inl(l)) }
      }),
    )
  ]
}

// Certificates (SC-FORM-010 service; SCACR 267 compliance order). Each entry of `certificates` is
// {title, text, signer?}; a certificate of service is the entry with title "CERTIFICATE OF SERVICE".
#let certificate(meta) = {
  let certs = meta.at("certificates", default: ())
  for c in certs {
    heading(level: 1, outlined: false, numbering: none)[#c.title]
    set par(leading: body-leading, spacing: body-gap, first-line-indent: para-indent)
    inl(c.text)
    v(0.8em)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    for r in c.at("recipients", default: ()) {
      block(width: 100%, inl(r))
      v(0.4em)
    }
    if "signer" in c { v(0.8em); block(width: 100%, inl(c.signer)) }
  }
}

// ---------------------------------------------------------------------------
// Table of authorities (SC-REP-001, SCACR 208(b)(1)(A)): built from the authority hits in the body
// ---------------------------------------------------------------------------

#let kinds = (
  (key: "case", title: "Cases"),
  (key: "statute", title: "Statutes"),
  (key: "rule", title: "Rules"),
  (key: "constitution", title: "Constitutional Provisions"),
  (key: "other", title: "Other Authorities"),
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
        grid(
          columns: (1fr, auto),
          gutter: 1em,
          par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.4in)[
            #(if k.key == "case" { emph(a.name) } else { a.name })#if a.at("cite", default: "") != "" [, #a.cite]
          ],
          shown,
        ),
      )
    }
  }
}

// ---------------------------------------------------------------------------
// Body styling
// ---------------------------------------------------------------------------

// Authority hits: a regex over every find-string, marked with its key (the table of authorities
// reads the marks back with query). Built once per document from the frontmatter.
#let hit-rules(auths) = {
  let entries = auths.pairs().filter(((k, a)) => a.at("find", default: "") != "")
  let sorted = entries.sorted(key: ((k, a)) => -a.find.len())
  let pattern = if sorted.len() > 0 { sorted.map(((k, a)) => escape-re(a.find)).join("|") } else { "ZZZQQXX" }
  let mark(m) = {
    let hit = sorted.find(((k, a)) => a.find == m.text)
    if hit == none { m } else { [#m#metadata((key: hit.at(0)))<toa-hit>] }
  }
  (pattern: pattern, mark: mark)
}

#let style-body(auths, it) = {
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-gap, first-line-indent: para-indent)
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 0.9em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  show heading.where(level: 2): h => block(above: 1em, below: 0.7em, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(
    above: 0.9em,
    below: 0.6em,
    text(weight: "bold", style: "italic", h.body),
  )
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

#let sc-brief(meta, body) = {
  set document(title: need(meta, "brief_title"), author: "")
  set page(paper: "us-letter", margin: page-margin, footer-descent: 0.4in)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  let auths = meta.at("authorities", default: (:))
  // Footnote bodies are not reached by the body rule above, so the same marks are set for them.
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  let frules = hit-rules(auths)
  show footnote.entry: n => {
    show regex(frules.pattern): m => (frules.mark)(m)
    [#n]
  }

  // Cover: caption only (no folio).
  page(numbering: none, footer: none)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #cover(meta)
  ]
  // Counsel and date.
  page(numbering: "i", footer: folio)[
    #counsel-page(meta)
  ]
  // Table of contents (generated from the headings).
  page(numbering: "i", footer: folio)[
    #set par(first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
    #v(0.8em)
    #outline(title: none, depth: 3, indent: 0pt)
  ]
  // Table of authorities (generated from the body's hits).
  if auths.len() > 0 {
    page(numbering: "i", footer: folio)[
      #align(center)[#text(weight: "bold")[TABLE OF AUTHORITIES]]
      #v(0.8em)
      #table-of-authorities(auths)
    ]
  }
  // Body, numbered from 1.
  page(numbering: "1", footer: folio)[
    #counter(page).update(1)
    #show: style-body.with(auths)
    #cmarker.render(body, raw-typst: false, smart-punctuation: false)
    #signature(meta)
    #certificate(meta)
  ]
}
