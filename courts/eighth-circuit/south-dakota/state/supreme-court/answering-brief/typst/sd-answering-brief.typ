// Supreme Court of South Dakota (sd): appellate brief (appellant, appellee, reply).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (SDCL ch. 15-26A, https://sdlegislature.gov/api/Statutes/<section>.html, verified 2026-10-21; see
// ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // SDCL 15-26A-66(b): proportional serif face, no face named. Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // SDCL 15-26A-66(b): 12-point or larger, body text and footnotes.
#let double-leading = 1.61em               // SDCL 15-26A-69(2): double-spaced. Measured pitch = natural line box + leading = 2 x the 13.8 pt single line (1.15 em) of Times at 12 pt.
#let single-leading = 0.46em               // Lengthy quotations may be single-spaced (15-26A-69(2)): 13.8 pt at 12 pt.
#let margin-left = 1.5in                   // SDCL 15-26A-69(3): left margin one and one-half inches.
#let margin-other = 1in                    // SDCL 15-26A-69(3): all other margins not less than one inch.
#let para-indent = 0.5in
#let sig-indent = 3in                      // signature block sits right of centre (style; exemplars do the same).
#let toc-depth = 2                         // SDCL 15-26A-60(1): contents with page references.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sd-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("sd-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A rule line across the text width.
#let rule-line = line(length: 100%, stroke: 0.75pt)

/// One counsel group: lines, single-spaced, flush left.
#let counsel-group(g) = block(width: 100%, below: 1em, breakable: false)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #g.map(l => inl(l)).join(linebreak())
]

/// Signature block: blocks of lines, single-spaced, right of centre.
#let signature-block(meta) = {
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "closing" in meta { par(first-line-indent: para-indent, inl(meta.closing)); v(0.9em) }
    #for b in need(meta, "signature") {
      block(above: 0.9em, pad(left: sig-indent, for l in b [ #inl(l) \ ]))
    }
  ]
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body (or `re:` followed by a regular expression). A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<sd-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show (if key.starts-with("re:") { regex(key.slice(3)) } else { key }): it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<sd-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[TABLE OF AUTHORITIES]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.6em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.6em, below: 1em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let sd-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // SDCL 15-26A-69(3): left margin 1.5 in, all other margins 1 in. The bottom carries 4 pt extra so
  // body text stays clear of the 1 in margin.
  set page(paper: "us-letter", margin: (left: margin-left, right: margin-other, top: margin-other, bottom: margin-other + 4pt), numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // SDCL 15-26A-69(2): double-spaced; 15-26A-69(3): not right-justified.
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Page footer: the number centred at the bottom (SDCL 15-26A-69(4)); an optional italic running
  // label above it, and optional dashes around the number, as in some filers' style.
  let footer-for(fmt) = context {
    let n = counter(page).display(fmt)
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center)[
      #if "running_footer" in meta [#emph(meta.running_footer) \ ]
      #if meta.at("number_dashes", default: false) [#"-" #n #"-"] else [#n]
    ]
  }

  // Level 1: a section name, centred, bold. Level 2: argument heading, bold, hanging. Level 3: bold italic.
  // Headings are typed with their own numbering and capitals, as filed (SDCL 15-26A-66(b)(1)).
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
    #strong(emph(it.body))
  ]

  // Block quotations: indented, single-spaced (SDCL 15-26A-69(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.8em)
    #it.body
  ]
  // Footnotes: same size as the text (SDCL 15-26A-66(b): 12 points or larger), single-spaced lines.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (SDCL 15-26A-69(5)): title of the action with party designations, the court appealed
  // from and the judge, the brief's party and title, counsel's names and addresses, the date the
  // notice of appeal was filed. The cover carries no page number.
  page[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #align(center)[
      #for l in need(meta, "court_line") [ #strong(inl(l)) \ ]
    ]
    #v(0.17in)
    #rule-line
    #v(0.17in)
    #align(center)[
      #for l in need(meta, "caption") { if l == "" { v(0.9em) } else [ #inl(l) \ ] }
    ]
    #v(0.17in)
    #rule-line
    #v(0.17in)
    #align(center)[
      #for l in need(meta, "appeal_number") [ #inl(l) \ ]
    ]
    #v(0.17in)
    #rule-line
    #v(0.17in)
    #align(center)[
      #for l in need(meta, "appeal_from") [ #inl(l) \ ]
    ]
    #v(0.17in)
    #rule-line
    #v(0.17in)
    #align(center)[#strong(inl(need(meta, "brief_title")))]
    #v(0.17in)
    #rule-line
    #v(0.17in)
    #grid(columns: (1fr, 1fr), column-gutter: 0.25in,
      [#for g in need(meta, "counsel_left") { counsel-group(g) }],
      [#for g in need(meta, "counsel_right") { counsel-group(g) }])
    #v(0.3em)
    #line(length: 100%, stroke: 0.5pt)
    #v(0.17in)
    #align(center)[#inl(need(meta, "notice"))]
  ]

  // ---- Front matter: contents, then authorities, numbered in lower-case roman (as filed; the rule
  // exempts the front index from the Arabic sequence, SDCL 15-26A-69(4)). ----
  set page(numbering: "i", footer: footer-for("i"))
  counter(page).update(1)
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
    #outline(title: none, depth: toc-depth, indent: 0.5in)
  ]

  // Footnote definitions sit at the end of the body; they go with the main text, where their
  // references are. Certificates start on a new page (as filed); the signature follows the conclusion.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# CERTIFICATE")
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }

  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: Arabic numbering restarts at 1.
  set page(numbering: "1", footer: footer-for("1"))
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(main-part, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the conclusion) ----
  if "signature" in meta {
    v(0.3in)
    signature-block(meta)
  }

  if certs.len() > 0 {
    pagebreak(weak: true)
    // Certificates are single-spaced (as filed; they are not part of the argued text).
    set par(leading: single-leading, spacing: 1.1em)
    let app-cut = certs.position("\n# APPENDIC")
    let cert-part = if app-cut == none { certs } else { certs.slice(0, app-cut) }
    mark-authorities(meta, cmarker.render(cert-part, raw-typst: false, smart-punctuation: true))
    // An appendices index, when the brief has one, starts its own page.
    if app-cut != none {
      pagebreak()
      mark-authorities(meta, cmarker.render(certs.slice(app-cut), raw-typst: false, smart-punctuation: true))
    }
  }
}
