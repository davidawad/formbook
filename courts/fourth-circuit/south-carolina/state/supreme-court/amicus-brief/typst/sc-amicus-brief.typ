// Supreme Court of South Carolina (sc): principal brief (opening brief, respondent's brief,
// reply brief, amicus brief, motion memorandum). This file is shared by the doc folders of
// this court; the doc type comes from the INPUT frontmatter (`brief_title`, `toc`, `authorities`).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it: South Carolina Appellate Court Rules, sources and dates in ../../rules.md. No
// case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the INPUT.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 267(c) sets a size, not a face; Times is the standard serif (docs/FONTS.md).
#let type-size = 12pt                     // Rule 267(c): standard 12-point or larger, footnotes included.
#let body-leading = 1.15em                // Rule 267(c): double spaced. Typst adds this gap to the natural line of the face (about 1.15 em): the line pitch is about 2 x single.
#let single-leading = 0.5em                 // Single spacing (block quotations, headings, captions, footnotes, counsel block).
#let page-margin = 1in                    // Rule 267(d): a blank margin of one inch on all sides.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                   // signature and counsel blocks start right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sc-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("sc-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption: each party block is its names, centred, then the designation at the right ("Appellant.").
#let caption-party(p) = {
  set par(leading: single-leading, spacing: 0.6em, first-line-indent: 0pt)
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    align: (left + horizon, right + horizon),
    [#for n in p.names [ #inl(n) \ ]],
    [#p.designation],
  )
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block (Rule 267(b): "/s/ [typed name]" is a signature; counsel's name, address and
/// telephone appear with it).
#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let list = if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
  if first-only { list = (list.first(),) }
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
/// the authority in the body (for example the case name). A show rule on that string drops a
/// marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<sc-toa>]

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
  let pages = query(<sc-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.5em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, text(weight: "bold", upper(group.heading)))
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

#let sc-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 267(d): letter paper (8 1/2 x 11), one-inch margins on all sides.
  set page(paper: "us-letter", margin: page-margin)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are argument headings (bold, hanging), set in distinctive type (Rule 208(b)(1)(E)).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: text size, single-spaced. Citations in footnotes count toward the table of authorities.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // Rule 240(c) and 211: consecutive page numbers, Arabic numerals at the bottom centre.
  // Front matter (tables) uses roman numerals; the body restarts at 1 (see below).
  set page(numbering: none)

  // ---- Cover (Rule 267(a), (e)): the caption and the title only, plus counsel ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[#need(meta, "state")] \
      #need(meta, "court")
      #v(0.3in)
      #for l in meta.at("appeal_from", default: ()) [ #inl(l) \ ]
      #v(0.3in)
      Appellate Case No. #need(meta, "appellate_case_no")
      #v(0.2in)
      #line(length: 3in, stroke: 0.6pt)
    ]
    #v(0.3in)
    #for p in need(meta, "caption") { caption-party(p); v(0.3in) }
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Front matter (Rule 208(b)(1)(A), (b)(3)) ----
  set page(numbering: "i")
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: restart page numbering at 1 ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (Rule 211(a), 267(b)) ----
  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (Rule 262(b); Rule 240(c)(1) for motions) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    align(center, text(weight: "bold", upper(svc.at("heading", default: "Certificate of Service"))))
    v(0.5em)
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    if svc.at("signature", default: true) {
      v(0.4em)
      signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
    }
  }
}
