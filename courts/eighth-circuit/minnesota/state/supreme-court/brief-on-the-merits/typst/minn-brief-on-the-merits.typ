// Minnesota Supreme Court (minn): brief-on-the-merits.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Minnesota Rules of Civil Appellate Procedure, https://www.revisor.mn.gov/court_rules/ap/, Rules 128 and 132;
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
#let cover-gap = 0.06in                  // the space around the cover's rules and between its blocks (style). It was 0.1-0.25in, which with the single-spaced lines still left the counsel of a many-party case short of room and ran the cover onto a second page (DEF-COVER-001).
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

/// The cover's counsel in two columns that flow, as the exemplars set them (one party's counsel runs on
/// into the second column): the columns of the input in order, the height balanced so both columns end
/// level. A grid with one input column per cell left the longest one alone setting the height and pushed
/// the cover onto a second page (DEF-COVER-001); Rule 132.01 subd. 2 lists the counsel but sets no layout.
#let counsel-gap = 0.9em
#let counsel-columns(cols, render, gutter: 0.3in) = layout(size => {
  let flow = for (i, c) in cols.enumerate() { if i > 0 { v(counsel-gap, weak: true) }; render(c) }
  let half = measure(block(width: (size.width - gutter) / 2, flow)).height / 2
  let line = measure(block(width: (size.width - gutter) / 2, render((lines: ("X",))))).height   // one line's pitch: the slack for a break between lines
  block(height: half + line, columns(2, gutter: gutter, flow))
})

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
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.25in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.7em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.6em, below: 0.6em, breakable: false)[
        #toa-entry(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
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
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show list: set par(leading: single-leading, first-line-indent: 0pt)
  // Footnotes: single-spaced (Rule 132.01 subd. 1), same 13-point size.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Rule 132.01 subd. 2) ----
  page(margin: (x: page-margin, top: cover-top-margin, bottom: page-margin), numbering: none)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)   // single-spaced (Rule 132.01 subd. 1 lets headings and tables be): the body's double paragraph spacing between the cover's blocks pushed it past one page (DEF-COVER-001)
    #align(center)[
      #text(size: 1.15em, strong[NO. #need(meta, "case_number")])
      #v(0.3em)
      #for l in need(meta, "court_lines") [ #strong(inl(l)) \ ]
    ]
    #v(cover-gap)
    #align(center, line(length: 1.6in, stroke: 0.5pt))
    #v(cover-gap)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 and side.at("joiner", default: meta.at("caption_joiner", default: "vs.")) != "" [ #align(center)[#side.at("joiner", default: meta.at("caption_joiner", default: "vs."))] #v(0.2em) ]
      #caption-side(side)
      #v(0.1em)
    ]
    #v(cover-gap)
    #align(center, line(length: 1.6in, stroke: 0.5pt))
    #v(cover-gap)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #if "subtitle" in meta [ #v(cover-gap) #align(center, inl(meta.subtitle)) ]
    #v(cover-gap)
    #align(center, line(length: 1.6in, stroke: 0.5pt))
    #v(cover-gap)
    #counsel-columns(need(meta, "counsel"), counsel-column)
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
  let cut = text.position(regex("(?i)\n# certificate"))
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  if "authorities" in meta {
    page(numbering: "i", authorities-table(meta))
  }
  // The body restarts at page 1 in arabic numerals.
  counter(page).update(1)
  set page(numbering: "1")
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the conclusion) ----
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
