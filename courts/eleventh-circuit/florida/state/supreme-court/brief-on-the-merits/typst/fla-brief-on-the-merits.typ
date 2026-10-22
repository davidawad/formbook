// Supreme Court of Florida (fla): one template for the filings of this court (answer brief, reply, brief on the merits,
// motions, petitions, rehearing motions, amicus briefs). Rules: ../../rules.md (IDs in the comments below).
// Content-agnostic: every case fact comes from the markdown frontmatter; no coordinates, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample
// (schema: docs/MARKDOWN-CONTRACT.md).

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"    // RAP 9.045(b): Arial 14 point. Liberation Sans is the metric-compatible Arial clone (fonts/).
#let type-size = 14pt                   // RAP 9.045(b): 14 point, footnotes and quotations included (FLA-FORM-004, -006).
#let body-leading = 1.2em               // FLA-FORM-005: double-spaced text.
#let single-leading = 0.45em            // FLA-FORM-006, -007: footnotes, quotations and headings may be single-spaced.
#let page-margin = (top: 1in, bottom: 1in, left: 1in, right: 1.05in)   // GPJA 2.520(a)(3): at least 1 inch on all sides (FLA-FORM-003). Right is 0.05 in deeper: justified glyph boxes overhang the margin by about 3 pt.
#let para-indent = 0.5in
#let sig-indent = 3.2in
#let court-name = "IN THE SUPREME COURT OF FLORIDA"   // RAP 9.210(a)(1) (FLA-COV-001, FLA-COV-002).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fla-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fla-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #v(0.4em)
    #inl(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath (RAP 9.210(a)(1): name, address, e-mail of the filing attorney).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(inl(n)) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block: the "s/" form; the typed name sits under the signature line.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)] \
    #inl(sig.signer)
    #for l in sig.at("lines", default: ()) [ \ #inl(l) ]
  ])
}

/// Table of citations (RAP 9.210(b)(2)). Each entry carries `find`: a string that appears in every citation of the
/// authority in the body. A show rule on that string drops a marker after each occurrence; the table lists the pages.
#let toa-marker(key) = [#metadata(key)<fla-toa>]

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
  let pages = query(<fla-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF CITATIONS])
  v(0.5em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }, hang: 1.5em)
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fla-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // RAP 9.210(a)(2)(E): all pages not excluded from the count are consecutively numbered; the cover shows no number.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)

  // Headings: level 1 centred and bold; levels 2-5 bold at the text size, single-spaced, hanging.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size, weight: "bold")
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #it.body
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size, weight: "bold")
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #it.body
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size, style: "italic")
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #it.body
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #it.body
  ]

  // Block quotations: indented, single-spaced, same size (FLA-FORM-006).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: the same 14-point type, single-spaced (FLA-FORM-006).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (RAP 9.210(a)(1); FLA-COV-001) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center)[
      #text(weight: "bold")[#court-name] \
      #if "case_number" in meta [ #v(0.2in) CASE NO.: #need(meta, "case_number") ]
    ]
    #v(0.3in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #if meta.caption.len() > 1 [ #align(center)[v.] ]
    #v(0.2in)
    #if meta.caption.len() > 1 [ #caption-side(meta.caption.at(1)) ]
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta {
        let lines = if type(meta.proceeding) == str { (meta.proceeding,) } else { meta.proceeding }
        for p in lines [ #inl(p) \ ]
      }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents (RAP 9.210(b)(1)): generated from the headings, with the page of each ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: 3, indent: 1.5em)
    ]
  }

  // ---- Table of citations (RAP 9.210(b)(2)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: the filing as written (the sample's own headings, citations and certificates) ----
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (RAP 9.045(d); GPJA 2.515 not retrieved) ----
  if "signature" in meta {
    v(0.3in)
    block(width: 100%, breakable: false, signature-block(meta.signature))
  }
}
