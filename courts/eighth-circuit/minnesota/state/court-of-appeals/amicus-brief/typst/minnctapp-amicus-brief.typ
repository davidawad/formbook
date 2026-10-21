// Minnesota Court of Appeals (minnctapp): appellant's brief (opening-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Minnesota Rules of Civil Appellate Procedure, Rules 128.02 and 132.01, Revisor of
// Statutes, https://www.revisor.mn.gov/court_rules/ap/subtype/rcap/id/132/; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 132.01 subd. 1 names no face; Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 132.01 subd. 1: proportional font at least 13-point, headings and footnotes included.
#let double-leading = 1.61em               // Rule 132.01 subd. 1: double-spaced. Pitch = natural line box + leading = 2 x the single pitch (1.15 em).
#let single-leading = 0.46em               // Rule 132.01 subd. 1: tables, issues, headings and footnotes may be single-spaced (1.15 em pitch).
#let page-margin = 1in                     // Rule 132.01 subd. 1: written matter not over 6-1/2 x 9-1/2 in on 8-1/2 x 11 paper.
#let cover-top-margin = 0.5in              // Rule 132.01 subd. 2(a): docket number one-half inch from the top center of the cover.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style; exemplars do the same).
#let toc-depth = 3                         // Rule 128.02 subd. 1(a): table of contents with page references.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("minnctapp-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("minnctapp-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One party block: names, then the designation on its own centred line.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #for n in side.names [ #inl(n) \ ]
    #inl(side.designation)
  ]
}

/// One counsel column: a list of lines (names with registration numbers, firm, address, role).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block: the firm lines, then "/s/" and the typed name, underlined, then the bar number
/// and the party the signer represents.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
    #v(0.6em)
    #underline[/s/ #inl(sig.signer)] \
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<minnctapp-toa>]

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
  let pages = query(<minnctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.7em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.7em, below: 0.7em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let minnctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Front matter (cover, contents, authorities) is numbered in roman; the body restarts at 1.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "i", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, capitals, bold, single-spaced. Level 2: point heading, bold.
  // Level 3: sub-heading, bold italic. Headings are typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: single-spaced (Rule 132.01 subd. 1 permits), same 13 pt size.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Rule 132.01 subd. 2: docket number half an inch from the top, court, title of the
  // case, title of the document, counsel with registration numbers) ----
  page(margin: (x: page-margin, top: cover-top-margin, bottom: page-margin + 4pt), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #strong[#need(meta, "case_number")]
      #v(0.1in)
      #strong[#inl(need(meta, "court_line"))]
    ]
    #v(0.1in)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #align(center)[v.] #v(0.4em) ]
      #caption-side(side)
      #v(0.4em)
    ]
    #v(0.1in)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #v(0.1in)
    #grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 0.5em,
      ..need(meta, "counsel").map(counsel-group))
  ]

  // ---- Table of contents (Rule 128.02 subd. 1(a)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
    #outline(title: none, depth: toc-depth, indent: 1.5em)
  ]

  // ---- Body. The table of authorities (alphabetical, Rule 128.02 subd. 1(a)) follows the table of
  // contents; the signature follows the conclusion and the certificates start on a new page.
  // Footnote definitions sit at the end of the body; they go with the main text.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# Certificat")
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  if "authorities" in meta {
    page(authorities-table(meta))
  }
  set page(numbering: "1")
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the conclusion; Rule 132.04) ----
  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificates: transcribed from the filed brief, on a new page ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
