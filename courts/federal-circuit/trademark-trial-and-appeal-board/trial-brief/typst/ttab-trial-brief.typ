// Trademark Trial and Appeal Board: brief on the case (main, reply or rebuttal) at final hearing.
//
// Rule-driven and content-agnostic. Rule IDs (TTAB-TB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The body is rendered by cmarker; the caption, authorities registry, signature and certificate
// come from the YAML frontmatter of the same sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a stated choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"           // vendored in /fonts; no system fallback (render.sh)
#let type-size = 12pt                       // TTAB-TB-FORM-001: at least 11-point (37 CFR 2.126(a)(1), TBMP 801.03)
#let body-leading = 0.695em                 // TTAB-TB-FORM-002: double-spaced (24 pt pitch at 12 pt); measured in ../README.md
#let single-leading = 0em                   // caption, headings, block quotations, footnotes, signature, authorities
#let page-margin = 1in                      // TTAB-TB-FORM-003: convention for 8.5 x 11 paper (tier 2)
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let passim-threshold = 7                   // an authority cited on this many pages or more prints "passim"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ttab-trial-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-trial-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Caption page (TBMP 309.02(a) heading, party caption, opposition number, title, counsel)
// ---------------------------------------------------------------------------

#let board-heading() = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, strong[
    IN THE UNITED STATES PATENT AND TRADEMARK OFFICE\
    BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD
  ])
}

/// Party caption: one row per line of names, a ")" column, and the proceeding numbers on the right.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for name in side.names { rows.push(inl(name)) }
    rows.push(pad(left: 2.1in, inl(side.designation)))
    if i < sides.len() - 1 {
      rows.push([])
      rows.push(pad(left: 1.2in, [v.]))
      rows.push([])
    }
  }
  let n = rows.len()
  let right = need(meta, "caption_right")
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(r)
    cells.push([)])
    if i == 0 {
      cells.push(table.cell(rowspan: n, align(horizon, stack(
        dir: ttb, spacing: 0.9em, ..right.map(l => inl(l)),
      ))))
    }
  }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  table(
    columns: (3.4in, 0.35in, 2.4in),
    stroke: none,
    inset: (x: 0pt, y: 0.12em),
    align: (left, center, left),
    ..cells,
  )
}

/// The caption page: heading, caption, title, the version line, the date and the counsel block.
#let caption-page(meta) = {
  set par(first-line-indent: 0pt)
  board-heading()
  v(1.5em)
  caption-table(meta)
  v(2.2em)
  align(center, strong(inl(need(meta, "brief_title"))))
  if "version" in meta {
    v(0.6em)
    align(center, inl(meta.version))
  }
  v(1fr)
  align(left, pad(left: 3.0in, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false, spacing: 0.5em)
    for g in need(meta, "counsel") {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        for l in g.at("lines", default: ()) { l; linebreak() }
      })
    }
    need(meta, "phone")
  }))
  v(1.6em)
  align(left, need(meta, "date"))
}

// ---------------------------------------------------------------------------
// Table of authorities (37 CFR 2.128(b): an alphabetical index of the cases cited)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// The page list of one authority, in the displayed (body) numbering. The body starts at the
/// <body-start> label; front matter is numbered in roman numerals and is not counted.
#let pages-for(key) = {
  let start = query(<body-start>).first().location().page()
  let found = ()
  for m in query(<toa-cite>) {
    if m.value.key == key {
      let p = m.location().page() - start + 1
      if p not in found { found.push(p) }
    }
  }
  found.sorted()
}

/// One entry: the name (if any), the citation, and the pages. An authority that is not cited prints nothing.
#let toa-entry(key, a) = context {
  let pages = pages-for(key)
  if pages.len() > 0 {
    let shown = if pages.len() >= passim-threshold { "passim" } else { pages.map(str).join(", ") }
    block(width: 100%, breakable: false, below: 0.85em, hang(0.5in, {
      if "name" in a { inl(a.name); [, ] }
      inl(a.cite)
      h(0.5em)
      dot-leader
      h(0.3em)
      shown
    }))
  }
}

/// Sort key for an authority: its name without emphasis markers, or the citation.
#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.cite)).replace("*", ""))

#let toa-section(meta) = {
  let auth = need(meta, "authorities")
  heading(level: 1, numbering: none, outlined: false)[TABLE OF AUTHORITIES]
  align(right, block(above: 0.2em, below: 0.9em, strong[Page(s)]))
  let groups = (
    ("case", "Cases"),
    ("constitution", "Constitutional Provisions"),
    ("statute", "Statutes"),
    ("regulation", "Regulations"),
    ("rule", "Rules"),
    ("other", "Other Authorities"),
  )
  for (kind, label) in groups {
    let keys = auth.keys().filter(k => auth.at(k).kind == kind)
    if kind == "case" { keys = keys.sorted(key: k => sort-key(auth.at(k))) }
    if keys.len() == 0 { continue }
    block(width: 100%, sticky: true, above: 0.9em, below: 0.7em, strong(label))
    for k in keys { toa-entry(k, auth.at(k)) }
  }
}

// ---------------------------------------------------------------------------
// Body styles
// ---------------------------------------------------------------------------

/// Level 1: a section, centered and bold. Level 2 and below: bold, left, with the typed label.
#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 1.4em, below: 1em, align(center, strong(it.body)))
  } else if it.level == 2 {
    block(width: 100%, sticky: true, above: 1.1em, below: 1em, hang(0.5in, strong(it.body)))
  } else {
    block(width: 100%, sticky: true, above: 1em, below: 0.9em, hang(1.0in, strong(emph(it.body))))
  }
}

/// Signature block (37 CFR 2.193(c): the electronic signature is "s/Name").
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.6em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 3.0in, [
      #sig.party
      #linebreak()
      By its attorneys,
      #v(1.2em)
      s/#sig.signer
      #linebreak()
      #for l in sig.lines [#inl(l)#linebreak()]
    ])
  })
}

/// Certificate of service (37 CFR 2.119(a) and (b): service by email, stating the date and manner).
#let certificate-of-service(meta) = {
  let c = need(meta, "service")
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong[CERTIFICATE OF SERVICE])
  v(1.4em)
  block(breakable: false, {
    set par(first-line-indent: para-indent, leading: body-leading)
    [I hereby certify that a true and correct copy of the foregoing #inl(need(meta, "brief_title")) was filed electronically and served on this #c.date, via email to:]
  })
  v(0.6em)
  pad(left: 0.5in, {
    set par(leading: single-leading, first-line-indent: 0pt)
    for r in c.recipients { r; linebreak() }
  })
  v(2.0em)
  align(left, pad(left: 3.0in, [
    s/#c.signer
    #linebreak()
    #c.signer
  ]))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ttab-trial-brief(meta, md) = {
  let authorities = need(meta, "authorities")
  set document(title: need(meta, "brief_title").replace("*", ""))
  set page(paper: "us-letter", margin: page-margin, numbering: "i", number-align: center)
  set text(
    font: font-family, size: type-size, lang: "en",
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false, spacing: 0pt)
  show heading: it => style-heading(it)
  show quote.where(block: true): it => block(
    width: 100%, above: 0.6em, below: 1.4em, inset: (left: 0.5in, right: 0.5in),
    par(leading: single-leading, first-line-indent: 0pt, it.body),
  )
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Every citation link to toa:KEY is tagged with its key, so the table of authorities can list
  // the pages on which it is cited. A key that is not in the authorities registry stops the build.
  show link: it => {
    let d = it.dest
    if type(d) == str and d.starts-with("toa:") {
      let key = d.slice(4)
      if key not in authorities { panic("ttab-trial-brief: `" + key + "` is not in authorities") }
      [#metadata((key: key)) <toa-cite>#it]
    } else { it }
  }

  // Front matter: the caption page, then the table of authorities, numbered i, ii, ...
  caption-page(meta)
  pagebreak()
  toa-section(meta)
  pagebreak()

  // Body: numbered from 1 again, as in a filed brief.
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata("body") <body-start>]

  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  render(md)

  signature-block(meta)
  certificate-of-service(meta)
}
