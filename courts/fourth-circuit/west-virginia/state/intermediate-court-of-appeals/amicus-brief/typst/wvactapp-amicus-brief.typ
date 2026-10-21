// Intermediate Court of Appeals of West Virginia (wvactapp): amicus curiae brief.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it:
// West Virginia Rules of Appellate Procedure, as posted on courtswv.gov, fetched 2026-10-21 (see
// ../../rules.md, section "Amicus curiae brief"). No case-specific text, no coordinates measured off
// any filed brief, no forced line breaks. The markdown body is rendered by cmarker; the metadata is
// the YAML frontmatter of the INPUT (fields listed in ../usage/INPUT-amicus-brief.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Times New Roman is the standard face; Liberation Serif is its metric-compatible substitute (docs/FONTS.md). Rule 38(a): proportionally spaced serif.
#let type-size = 12pt                     // Rule 38(a): text no smaller than twelve-point proportionally spaced type.
#let footnote-size = 12pt                 // Rule 38(a): footnote text no smaller than eleven-point proportional (12 pt chosen, as the text).
#let body-leading = 1.6em                 // Rule 38(a): double-spaced text. Typst leading is the gap added to one natural line.
#let single-leading = 0.46em              // Rule 38(a): footnotes and indented quotations may be single-spaced.
#let page-margin = 1in                    // Rule 38(a): margins no less than one inch.
#let para-indent = 0.5in                  // style: first-line indent of body paragraphs (the exemplar does the same).
#let toc-depth = 3
#let sig-indent = 3.2in                  // style: counsel and signature blocks start right of centre (the exemplar does the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvactapp brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("wvactapp brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: the party names, then the trial-court designation, left aligned.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  pad(left: 0.5in, emph(side.designation))
}

/// Counsel group for the cover: names then the lines beneath (Rule 38(b)(5)).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(inl(n)) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block (Rule 38A(j): typographic signature and the attorney's
/// address, telephone, e-mail and West Virginia State Bar identification number).
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  [/s/ #s.name] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #sig.firm #v(0.8em) ]
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

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
/// authority in the body (e.g. a reporter cite or a short case name). A show rule on that string drops
/// a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<wvactapp-toa>]

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
  let pages = query(<wvactapp-toa>)
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

#let wvactapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented on both sides, single-spaced (Rule 38(a)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: single-spaced, no smaller than eleven-point (Rule 38(a)). The disclosure of
  // authorship and funding goes in the first footnote on the first page of text (Rule 30(e)(5)).
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (Rule 38(b)): court, docket number, caption, title, counsel ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE INTERMEDIATE COURT OF APPEALS OF WEST VIRGINIA]
    ]
    #v(0.5in)
    #grid(
      columns: (1fr, 2.2in),
      gutter: 0.3in,
      [
        #caption-side(meta.caption.at(0))
        #v(0.2in)
        v.
        #v(0.2in)
        #caption-side(meta.caption.at(1))
      ],
      [
        #align(right + horizon)[#text(weight: "bold")[No. #need(meta, "docket")]]
      ],
    )
    #v(0.6in)
    #align(center)[
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

  // ---- Table of contents (RAP 30(e)(2)) and table of authorities (RAP 30(e)(3)) ----
  // Front matter is numbered in lower-case roman; the cover is not numbered.
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

  // ---- Body: numbered from 1 ----
  set page(numbering: "1")
  counter(page).update(1)
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block and date (RAP 38A(j)) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (RAP 37, 38A(q)); not counted toward the page limit ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
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
