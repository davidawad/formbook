// Court of Appeals of Iowa (iowactapp): appellant's reply brief (reply-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Iowa Court Rules, Chapter 6, Iowa Rules of Appellate Procedure, December 2025,
// https://www.legis.iowa.gov/docs/ACO/CR/LINC/09-30-2026.chapter.6.pdf; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 6.903(1)(g)(1): serif, proportional; Times New Roman is a listed example. Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 14pt                      // Rule 6.903(1)(g)(1): 14-point or larger for all text, footnotes included.
#let double-leading = 1.61em               // Rule 6.903(1)(e): double-spaced. Pitch = 9.7 pt natural + leading = 32.2 pt, twice the 16.1 pt single line (1.15 em) at 14 pt.
#let single-leading = 0.46em               // Rule 6.903(1)(e): quotations over 50 words, headings and footnotes may be single-spaced (16.1 pt).
#let page-margin = 1in                     // Rule 6.903(1)(e): 1 inch on all sides.
#let para-indent = 0.5in
#let counsel-indent = 3in                  // counsel block sits right of centre (style; the exemplars do the same).
#let toc-depth = 1                         // Rule 6.903(2)(a)(1): contents with page references.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iowactapp-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("iowactapp-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: names, then the designation, all centred (Rule 6.152(2): parties identified as appellant and appellee).
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #for n in side.names [ #inl(n) \ ]
    #inl(side.designation)
  ]
}

/// Counsel block: names, then the firm, address, telephone and email lines (Rule 6.903(1)(c)(5)).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block: the signer on a line, then name and bar number, firm and contact lines.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: counsel-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #v(0.4in)
    #line(length: 3in, stroke: 0.5pt)
    #v(0.5em)
    #for l in sig.lines [ #inl(l) \ ]
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<iowactapp-toa>]

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
  let pages = query(<iowactapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

// A TOA entry: the page reference follows the leaders on the entry's last line, never alone on a line. The
// pages sit in their own column, bottom-aligned; a list wider than `toa-page-col` runs on after a leader of at
// least `toa-min-leader` and wraps after a comma.
#let toa-page-col = 2.25in
#let toa-min-leader = 0.75in
#let toa-entry(cite, pages) = context {
  let leader(width) = box(width: width, repeat[.#h(2pt)])
  if measure([#pages]).width <= toa-page-col {
    grid(columns: (1fr, auto), column-gutter: 4pt, par[#cite#h(4pt)#leader(1fr)], align(bottom, [#pages]))
  } else {
    par[#cite#h(4pt)#leader(1fr)#leader(toa-min-leader)#h(4pt)#pages]
  }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.7em, sticky: true)[#strong(upper(group.heading)) #h(1fr) #strong[PAGE]]
    for e in group.entries {
      block(above: 0.7em, below: 0.7em, breakable: false)[
        #toa-entry(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let iowactapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 6.903(1)(f): page numbers at bottom centre, consecutive Arabic numerals, the cover is page one.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, capitals, bold, single-spaced. Level 2: point heading, capitals,
  // hanging. Level 3: sub-heading, bold italic. Headings are typed with their own lettering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(upper(it.body))
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced (Rule 6.903(1)(e)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size as the text (Rule 6.903(1)(g)(1)), single-spaced (Rule 6.903(1)(e)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Rule 6.903(1)(c)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #strong[#need(meta, "court_line")] \
      #need(meta, "case_number")
    ]
    #v(0.1in)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #align(center)[vs.] ]
      #caption-side(side)
      #v(0.1em)
    ]
    #line(length: 100%, stroke: 0.5pt)
    #align(center)[
      #for l in need(meta, "proceeding") [ #inl(l) \ ]
      #if "judge" in meta [ #inl(meta.judge) ]
    ]
    #line(length: 100%, stroke: 0.5pt)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #line(length: 100%, stroke: 0.5pt)
    #v(0.1in)
    #pad(left: counsel-indent)[
      #for g in need(meta, "counsel") { counsel-group(g) }
    ]
  ]

  // ---- Table of contents (Rule 6.903(2)(a)(1)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
    #outline(title: none, depth: toc-depth, indent: 0pt)
  ]

  // ---- Body. The table of authorities follows the table of contents (Rule 6.903(2)(a)(2)); the
  // signature follows the request for oral argument and the certificates start on a new page
  // (as filed). Footnote definitions sit at the end of the body; they go with the main text,
  // where their references are.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# Certificate")
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  if "authorities" in meta {
    page(authorities-table(meta))
  }
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the request for oral argument) ----
  if "signature" in meta {
    block(width: 100%, breakable: false)[
      #signature-block(meta.signature)
    ]
  }

  // ---- Certificates: transcribed from the filed brief, on a new page ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
