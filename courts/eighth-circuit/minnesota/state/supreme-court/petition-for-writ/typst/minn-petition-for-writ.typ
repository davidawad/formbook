// Minnesota Supreme Court (minn): petition-for-writ.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Minnesota Rules of Civil Appellate Procedure, https://www.revisor.mn.gov/court_rules/ap/, Rules 120 and 132;
// see ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 132.01 subd. 1 names no face; Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 132.01 subd. 1: proportional font of at least 13 points, headings and footnotes included.
#let double-leading = 1.61em               // Rule 132.01 subd. 1: double-spaced. Pitch = 9.7 pt natural + leading = 2 x the single line (1.15 em).
#let single-leading = 0.46em               // Rule 132.01 subd. 1: tables, statements of issues, headings and footnotes may be single-spaced (1.15 em line).
#let page-margin = 1in                     // Rule 132.01 subd. 1: written matter not over 6-1/2 by 9-1/2 inches on 8-1/2 by 11 paper; one inch is within it.
#let cover-top-margin = 0.5in              // Rule 132.01 subd. 2(a): the docket number sits one-half inch from the top center of the cover.
#let para-indent = 0.5in
#let sig-indent = 3in                      // signature block sits right of centre (style; the exemplars do the same).
#let toc-depth = 4

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("minn-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("minn-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: the names centred, the designation flush right on its own line.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[#for n in side.names [ #inl(n) \ ]]
  if "designation" in side { align(right, emph(inl(side.designation))) }
}

/// A cover column of counsel lines; "" is a blank line, markdown is allowed.
#let counsel-column(col) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for l in col.lines { if l == "" { v(0.45em) } else [ #inl(l) \ ] }
}

/// Signature block: the firm lines, then "/s/" and the typed name, underlined, then the lines below.
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
#let toa-marker(key) = [#metadata(key)<minn-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        // A find that starts with "re:" is a regular expression (to keep 13.39 apart from 13.392).
        let pat = if key.starts-with("re:") { regex(key.slice(3)) } else { key }
        out = {
          show pat: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<minn-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else if pages.len() > 5 { [_passim_] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.25in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.7em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.6em, below: 0.6em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let minn-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, bold, single-spaced. Levels 2-4: point headings, bold, hanging, single-spaced
  // (Rule 132.01 subd. 1 allows single-spaced headings). Headings are typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, strong(it.body))
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 1in, strong(it.body))
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show list: set par(leading: single-leading, first-line-indent: 0pt)
  set list(marker: ([•], [–]))
  show table.cell: set par(leading: single-leading, first-line-indent: 0pt, spacing: single-leading)
  show table: set block(breakable: true)
  // Footnotes: single-spaced (Rule 132.01 subd. 1), same 13-point size.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Rule 132.01 subd. 2) ----
  page(margin: (x: page-margin, top: cover-top-margin, bottom: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(size: 1.15em, strong[#meta.at("docket_label", default: "NO. ")#need(meta, "case_number")])
      #v(0.3em)
      #for l in need(meta, "court_lines") [ #strong(inl(l)) \ ]
    ]
    #v(0.1in)
    #align(center, line(length: 1.6in, stroke: 0.5pt))
    #v(0.1in)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 and side.at("joiner", default: meta.at("caption_joiner", default: "vs.")) != "" [ #align(center)[#side.at("joiner", default: meta.at("caption_joiner", default: "vs."))] #v(0.2em) ]
      #caption-side(side)
      #v(0.3em)
    ]
    #v(0.1in)
    #align(center, line(length: 1.6in, stroke: 0.5pt))
    #v(0.15in)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #if "subtitle" in meta [ #v(0.1in) #align(center, inl(meta.subtitle)) ]
    #v(0.15in)
    #align(center, line(length: 1.6in, stroke: 0.5pt))
    #v(0.25in)
    #if "counsel" in meta [ #grid(columns: (1fr, 1fr), column-gutter: 0.3in, ..meta.counsel.map(counsel-column)) ]
  ]

  // ---- Table of contents (Rule 128.02 subd. 1(a)); front matter is numbered in roman numerals ----
  page(numbering: "i")[
    #counter(page).update(1)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
    #outline(title: none, depth: toc-depth, indent: n => 0.3in * n)
  ]

  // ---- Table of authorities, then the body. The signature follows the conclusion and the
  // certificates start on a new page (as filed). Footnote definitions sit at the end of the body;
  // they go with the main text, where their references are.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position(regex("(?i)\n# (certif|acknowledg)"))
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  // The body restarts at page 1 in arabic numerals.
  counter(page).update(1)
  set page(numbering: "1")
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the conclusion), then the declaration lines ----
  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
  if "after_signature" in meta {
    v(0.2in)
    set par(leading: double-leading, first-line-indent: 0pt)
    for p in meta.after_signature { par(inl(p)) }
  }

  // ---- Acknowledgment: transcribed from the filed petition, on a new page, with the signature again ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
    v(0.3in)
    block(width: 100%, breakable: false)[
      #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
      #v(0.4em)
      #signature-block(need(meta, "signature"))
    ]
  }
}
