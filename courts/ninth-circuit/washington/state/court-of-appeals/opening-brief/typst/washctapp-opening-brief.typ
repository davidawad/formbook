// Court of Appeals of the State of Washington, opening brief (washctapp-opening-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the Washington Rules of Appellate
// Procedure cited next to it (RAP 10.3, 10.4, 18.17 and RAP Form 5, as listed in rules.md), or to the court's
// eval.yaml for the type size and margins. No coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample (see
// usage/INPUT-opening-brief.md and rules.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // RAP 18.17(a)(2): 14-point serif equivalent to Times New Roman. Times New Roman where installed (docs/FONTS.md); Liberation Serif is its metric twin in fonts/.
#let type-size = 14pt                      // RAP 18.17(a)(2): 14 point for all text, footnotes and block quotations (WASHCTAPP-FORM-004). Court eval.yaml: font.size_pt 14.
#let body-leading = 1.65em                 // RAP 18.17(a)(2): double spaced (WASHCTAPP-FORM-005).
#let single-leading = 0.45em               // Single spaced: footnotes, block quotations, headings, caption and counsel blocks (WASHCTAPP-FORM-005).
#let page-margin = (top: 1.5in, bottom: 1.6in, left: 2in, right: 1.5in)  // RAP 18.17(a)(1) (WASHCTAPP-FORM-002): 2 in left, 1.5 in right, top and bottom, at least. The bottom is 0.1 in deeper than the minimum so the 14 pt descenders of the last line stay inside the margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 2.5in                    // signature and counsel blocks start right of centre (exemplar convention).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("washctapp-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("washctapp-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split the body in two at the first heading whose text contains `key` (frontmatter, upper case). The part
/// from that heading on is the appendix, set after the certificate and signature (RAP 10.3(a)(8)).
#let split-appendix(meta, body) = {
  let key = meta.at("appendix_from_heading", default: none)
  if key == none { return (body, "") }
  let lines = body.split("\n")
  let idx = lines.position(l => l.starts-with("#") and key in upper(l))
  if idx == none { panic("washctapp-opening-brief: no heading contains `" + key + "`") }
  (lines.slice(0, idx).join("\n"), lines.slice(idx).join("\n"))
}

/// Lines of a block of text, one block per item, no extra space between them.
// A block holds only its own lines, so the single-spacing gap between two items is placed explicitly.
#let stacked(items, weight: "regular") = {
  set block(spacing: 0pt)
  for (i, it) in items.enumerate() {
    if i > 0 { v(single-leading) }
    block(width: 100%, par(leading: single-leading, text(weight: weight, it)))
  }
}

/// One caption side: names, then the designation.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #stacked(side.names)
    #v(0.2em)
    #inl(side.designation)
  ]
}

/// Counsel group for the title page: names (bold), then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  stacked(g.names)
  v(0.1in)
  stacked(g.at("lines", default: ()))
}

/// Signature block of the brief: "Respectfully submitted," then the signer and the counsel lines beneath.
#let signature-block(sig) = block(width: 100%, breakable: false, pad(left: sig-indent)[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  Respectfully submitted,
  #v(0.9in)
  #stacked((sig.signer, ..sig.at("lines", default: ())))
])

/// Table of authorities. Each entry carries `find` (one string) or `finds` (several): strings that appear in
/// every citation of the authority in the body. A show rule on each string drops a marker after it; the table
/// lists the pages of the markers.
#let finds-of(e) = {
  if "finds" in e { e.finds } else if "find" in e { (e.find,) } else { () }
}

#let toa-marker(key) = [#metadata(key)<washctapp-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      for key in finds-of(e) {
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

/// Page label of a location as the page is numbered on the page itself.
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

#let toa-pages(keys) = context {
  let pages = query(<washctapp-toa>)
    .filter(m => m.value in keys)
    .map(m => page-label(m.location()))
    .dedup()
  if pages.len() == 0 { [--] } else { pages.join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.4em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.6em, sticky: true, text(weight: "bold", group.heading))
    for e in group.entries {
      let keys = finds-of(e)
      // The cite wraps in its own column; the page references sit in a fixed column with leaders, so a
      // long cite never pushes the page references onto a line of their own.
      block(above: 0.8em, below: 0.8em, breakable: false)[
        #grid(columns: (1fr, 1.5in), column-gutter: 0.1in,
          inl(e.cite),
          [#box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if keys.len() > 0 { toa-pages(keys) } else { e.at("pages", default: "") }],
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let washctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Page numbers at the bottom. Front matter is lower-case Roman; the body is Arabic from its first page.
  set page(paper: "us-letter", margin: page-margin, numbering: "i", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Section headings: level 1 is a major part (A. INTRODUCTION.), level 2 an issue or argument heading,
  // level 3 a sub-argument. Bold throughout; single spaced.
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.1em, below: 0.9em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.9em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, text(weight: "bold", it.body))
  ]

  // Block quotations: indented on both sides, single spaced (RAP 18.17(a)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size and typeface as the body, single spaced (RAP 18.17(a)(2)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Title page (RAP 10.3(a)(1), RAP Form 5; no page number) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #need(meta, "case_number")
    #v(0.3in)
    #align(center, text(weight: "bold")[COURT OF APPEALS OF THE STATE OF WASHINGTON])
    #align(center, text(weight: "bold")[DIVISION #need(meta, "division")])
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(1fr)
    #align(center, text(weight: "bold", inl(need(meta, "brief_title"))))
    #v(1fr)
    #pad(left: sig-indent, {
      set par(leading: single-leading, first-line-indent: 0pt)
      for g in need(meta, "counsel") { counsel-group(g) }
    })
    #v(0.25in)
  ]
  // The Roman count starts with the first page after the title page.
  counter(page).update(1)

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

  // ---- Body (Arabic from 1), then the appendix ----
  let (main, appendix) = split-appendix(meta, body)
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(main, raw-typst: false, smart-punctuation: true))

  // ---- Word-count certificate, date and signature (RAP 18.17(b); CERT-001, CERT-002) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: (amount: para-indent, all: true))[
      Counsel certifies this brief complies with RAP 18.17 and contains #need(meta, "word_count") words.
    ]
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.2em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Appendix (RAP 10.3(a)(8)); excluded from the word count (RAP 18.17(c)) ----
  if appendix != "" {
    pagebreak(weak: true)
    cmarker.render(appendix, raw-typst: false, smart-punctuation: true)
  }
}
