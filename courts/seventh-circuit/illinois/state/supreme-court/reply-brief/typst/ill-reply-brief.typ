// Illinois Supreme Court (ill): one template for the brief, petition for leave to appeal, motion,
// motion for supervisory order and amicus brief. Requirement IDs (ILL-...) refer to ../../rules.md.
//
// Content-agnostic. Every number is a named parameter below and traces to a rule (Illinois Supreme Court
// Rules compiled October 21, 2026, https://ilcourtsaudio.blob.core.windows.net/antilles-resources/resources/7ae8a196-2a43-4484-9666-43098da60282/S_Ct_Rules_full.pdf).
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the INPUT
// (contract: docs/MARKDOWN-CONTRACT.md; field list: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/toa.typ": linked-authorities

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // ILL-FORM-007: no face is named by the rules; Times New Roman, Liberation Serif as its metric twin.
#let type-size = 12pt                  // ILL-FORM-006: 12-point or larger throughout, quotations and footnotes included.
#let double-leading = 1.61em           // ILL-FORM-003: double spacing. Em-based: 1.61 em of leading on the 1.15 em single line gives a 2.3 em baseline pitch, as the ark template measures.
#let single-leading = 0.46em           // ILL-FORM-003: headings, quotations, footnotes, caption, counsel and certificates are single-spaced.
#let margin-left = 1.5in               // ILL-FORM-004: at least 1.5 inch on the left side.
#let margin-other = 1in                // ILL-FORM-004: at least 1 inch on the other three sides.
#let para-indent = 0.5in
#let cover-fill = rgb("#FFF9B0")                 // ILL-FORM-008: cover color of the document type (none = white). Set per doc-type folder.
#let passim-threshold = 6              // authorities cited on this many pages or more are listed as "passim".

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ill-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ill-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Position comparison on the page (a before b in reading order).
#let loc-before(a, b) = {
  let p = a.position()
  let q = b.position()
  p.page < q.page or (p.page == q.page and p.y < q.y)
}

/// Tag the first word of a link's text with a marker, so the marker's page is the page of the citation.
#let tag-after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = tag-after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = tag-after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) }
      else { let r = tag-after-first-word(ch, tag); out.push(r.first()); placed = r.last() }
    }
    return (out.join(), placed)
  }
  (c, false)
}

// ---------------------------------------------------------------------------
// Front matter: the caption block (ILL-CONT-001, ILL-FORM-012)
// ---------------------------------------------------------------------------

/// Caption rows: left column (parties), a column of ")" and the right column (lower court, judge).
#let caption-block(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  let cells = ()
  for row in need(meta, "caption") {
    let left = row.at("left", default: "")
    cells.push(if row.at("indent", default: false) { pad(left: 1.1in, inl(left)) } else { inl(left) })
    cells.push([)])
    cells.push(inl(row.at("right", default: "")))
  }
  grid(columns: (3.0in, 0.25in, 2.75in), align: left, row-gutter: 0.2em, ..cells)
}

#let front-matter(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  if "expedited_caption" in meta {
    align(center, strong(inl(meta.expedited_caption)))
    v(0.9em)
  }
  align(center, [No. #need(meta, "case_number")])
  v(0.9em)
  align(center, strong(inl(upper(need(meta, "court_line")))))
  v(1em)
  caption-block(meta)
  v(1em)
  for line in need(meta, "brief_title").split("\n") {
    align(center, strong(inl(upper(line))))
  }
  v(0.8em)
}

/// Counsel blocks on the cover, stacked in the right half of the page.
#let counsel-block(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  for g in meta.at("counsel", default: ()) {
    block(breakable: false, pad(left: 2.9in, {
      for n in g.at("names", default: ()) [#inl(n) \ ]
      for l in g.at("lines", default: ()) [#inl(l) \ ]
    }))
    v(0.9em)
  }
}

/// Cover page (ILL-FORM-008 colour; ILL-CONT-001). Unnumbered.
#let cover-page(meta) = page(fill: cover-fill, numbering: none)[
  #front-matter(meta)
  #v(1fr)
  #counsel-block(meta)
]

// ---------------------------------------------------------------------------
// Signature and certificates (ILL-CONT-007, ILL-CONT-008)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
    if "date" in meta {
      par(inl(meta.date))
      v(0.6em)
    }
    pad(left: 2.9in, {
      underline[/s/ #inl(sig.signer)]
      linebreak()
      for l in sig.at("lines", default: ()) [#inl(l) \ ]
    })
  })
}

#let certificates-block(meta) = {
  for c in meta.at("certificates", default: ()) {
    if c.type == "compliance" {
      pagebreak(weak: true)
      align(center, strong[CERTIFICATE OF COMPLIANCE])
      v(0.8em)
      set par(first-line-indent: para-indent, leading: double-leading, spacing: double-leading, justify: false)
      [I certify that this brief conforms to the requirements of Rules 341(a) and (b). The length of this brief, excluding the pages or words contained in the Rule 341(d) cover, the Rule 341(h)(1) table of contents and statement of points and authorities, the Rule 341(c) certificate of compliance, the certificate of service, and those matters to be appended to the brief under Rule 342(a), is #inl(c.text).]
      v(1.2em)
      signature-block(meta)
    } else if c.type == "service" or c.type == "other" {
      pagebreak(weak: true)
      align(center, strong(inl(upper(c.at("heading", default: "CERTIFICATE OF SERVICE")))))
      v(0.8em)
      set par(first-line-indent: para-indent, leading: double-leading, spacing: double-leading, justify: false)
      inl(c.text)
      v(1.2em)
      signature-block(meta)
    }
  }
}

// ---------------------------------------------------------------------------
// Table of contents and Points and Authorities (ILL-CONT-002(1), Rule 341(h)(1))
// ---------------------------------------------------------------------------

#let toc-page() = page(numbering: "i")[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #align(center, strong[TABLE OF CONTENTS])
  #v(0.6em)
  #show outline.entry: it => block(above: 0.45em, below: 0.45em, it)
  #outline(title: none, depth: 3, indent: level => level * 0.35in)
]

/// Pages on which one authority is cited among the given hits (first-citation order), or passim.
#let authority-page-labels-of(hits, key) = {
  let pages = ()
  for hit in hits.filter(hit => hit.value == key) {
    let loc = hit.location()
    let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
    if label not in pages { pages.push(label) }
  }
  if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
}

/// Points and Authorities: each Argument heading (levels 2 and 3) with its page, then the authorities
/// cited under it (cited between that heading and the next heading of the same or higher level), with
/// the pages of their citations. Citations come from the `toa:` links in the body.
#let points-and-authorities(meta) = context {
  let authorities = meta.at("authorities", default: (:))
  let heads = query(heading)
  let hits = query(<ill-toa-hit>)
  let _ = linked-authorities(authorities, error-prefix: "ill-brief")
  align(center, strong[POINTS AND AUTHORITIES])
  v(0.6em)
  let started = false
  for (i, h) in heads.enumerate() {
    if h.level == 1 {
      if lower(repr(h.body)).contains("argument") { started = true }
      continue
    }
    if not started or h.level > 3 { continue }
    let end = none
    for j in range(i + 1, heads.len()) {
      if heads.at(j).level <= h.level {
        end = heads.at(j)
        break
      }
    }
    let inr = hits.filter(m => (not loc-before(m.location(), h.location())) and (end == none or loc-before(m.location(), end.location())))
    let keys = ()
    for m in inr {
      if m.value not in keys { keys.push(m.value) }
    }
    let hp = numbering(h.location().page-numbering(), ..counter(page).at(h.location()))
    block(above: 1em, below: 0.35em, sticky: true, grid(columns: (1fr, auto), column-gutter: 0.4em,
      {
        set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: 0.4in, justify: false)
        strong(h.body)
      },
      hp,
    ))
    for key in keys {
      let a = authorities.at(key)
      block(above: 0.4em, below: 0.4em, breakable: false, pad(left: 0.3in, grid(columns: (1fr, auto), column-gutter: 0.4em,
        {
          set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: 0.3in, justify: false)
          if "name" in a [#emph(inl(a.name)), ]
          inl(a.cite)
        },
        authority-page-labels-of(inr, key),
      )))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ill-brief(meta, body) = {
  set document(title: need(meta, "brief_title").split("\n").join(" "))
  // Pages: 1 in top, bottom and right; 1.5 in left (ILL-FORM-004). Page numbers sit in the bottom margin (ILL-FORM-005).
  set page(paper: "us-letter", margin: (left: margin-left, right: margin-other, top: margin-other, bottom: margin-other), numbering: none, number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: para-indent, justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, capitals, bold. Level 2: a point, bold, hanging. Level 3: a subpoint, bold italic.
  // Headings carry the numbering as filed ("I.", "A.").
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced (ILL-FORM-003).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // Footnotes: text size, single-spaced (ILL-FORM-003, ILL-FORM-006).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // Each citation of a registry authority is a link `toa:<key>`; the marker it leaves feeds the Points and Authorities.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<ill-toa-hit>]).first()
    } else { it.body }
  }

  let cover = meta.at("cover", default: true)
  let toc = meta.at("toc", default: true)

  if cover { cover-page(meta) }

  if toc {
    counter(page).update(1)
    toc-page()
    if meta.at("authorities", default: (:)).len() > 0 {
      page(numbering: "i")[#points-and-authorities(meta)]
    }
  }

  // Body: arabic from 1.
  set page(numbering: "1")
  counter(page).update(1)
  if not cover { front-matter(meta) }
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  v(0.6em)
  signature-block(meta)
  certificates-block(meta)
}
