// Supreme Court of Arizona heading, petition for discretionary review.
//
// Content-agnostic. No Arizona rule has been retrieved (usage/SOURCE.md and rules.md), so every number below is
// a repo default (US letter, 12 pt, 1 in margins); none is an Arizona requirement. No coordinates measured off
// any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// input (usage/INPUT-petition-for-discretionary-review.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Repo default face; Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 12pt                      // Repo default body size (no Arizona rule retrieved); footnotes match the text.
#let body-leading = 1.65em                 // Repo default: double spaced, as the filed exemplar is laid out (unsourced).
#let single-leading = 0.45em               // Headings, footnotes and block quotations are single-spaced (unsourced convention).
#let page-margin = (top: 1in, bottom: 1in, left: 1in, right: 1in)  // Repo default: 1 inch on all sides (no Arizona rule retrieved).
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).
#let word-count-text(n) = [This petition contains #n words.]  // Optional: rendered only when the INPUT gives `word_count`; no Arizona word-count rule retrieved.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ariz-petition-for-discretionary-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ariz-petition-for-discretionary-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption, as the Supreme Court filings lay it out: party lines on the left, a ")" per row, and the
/// court numbers and title (`caption_right`) on the right. Rows are data-driven; no spacing is set by hand.
#let caption-table(meta) = {
  let rows = ()
  for (si, side) in meta.caption.enumerate() {
    if si > 0 { rows.push((text: [vs.], indent: 0in)) }
    for n in side.names { rows.push((text: inl(n), indent: 0in)) }
    if "designation" in side { rows.push((text: emph(side.designation), indent: 1in)) }
  }
  let right = meta.at("caption_right", default: ())
  let n = calc.max(rows.len(), right.len())
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  table(
    columns: (3.4in, 0.3in, 1fr),
    stroke: none,
    inset: 0pt,
    align: left,
    row-gutter: 0.35em,
    ..range(n).map(i => {
      let l = if i < rows.len() { rows.at(i) } else { (text: [], indent: 0in) }
      let r = if i < right.len() and right.at(i) != "" { inl(right.at(i)) } else { [] }
      (pad(left: l.indent)[#l.text], [)], r)
    }).flatten(),
  )
}

/// Counsel block, top left of the first page: names, then the lines beneath.
#let counsel-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for g in need(meta, "counsel") {
    for n in g.names [ #inl(n) \ ]
    for l in g.lines [ #inl(l) \ ]
    v(0.6em)
  }
}

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines (bar number, address, phone, e-mail) follow.
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
  block(width: 100%, breakable: false, pad(left: sig-indent)[
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

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. the volume and reporter, "324 Ga. App."). A show rule on that
/// string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<ariz-toa>]

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
  let pages = query(<ariz-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ariz-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Page numbers in the bottom margin; the cover is page 1.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", style: "italic", it.body))
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

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size as the text, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Caption page: counsel, court heading, caption. The brief body starts on this page (no separate cover). ----
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    counsel-block(meta)
    v(0.3in)
    align(center)[#text(weight: "bold")[SUPREME COURT OF ARIZONA]]
    v(0.3in)
    caption-table(meta)
    v(0.4in)
  }

  // ---- Table of contents ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date, optional word-count line, signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #if "word_count" in meta { par(first-line-indent: (amount: para-indent, all: true), word-count-text(meta.word_count)); v(0.4em) }
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of mailing (service) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[#svc.at("heading", default: "Certificate of Service")]
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
