// Supreme Court of Iowa (iowa): application for interlocutory appeal (rule 6.104).
// Cover is a caption table followed by an introductory paragraph and the table of contents.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to
// it (Iowa Court Rules, Chapter 6, Iowa Rules of Appellate Procedure, Feb. 2026 edition, rules
// 6.903, 6.1007, 6.1103, 6.1205; see ../../rules.md). No case-specific text, no coordinates measured
// off any filed brief, no forced line breaks. The markdown body is rendered by cmarker; the metadata
// is the YAML frontmatter of the sample.
//
// Frontmatter keys (see usage/INPUT-*.md for examples):
//   cover_head: [lines]            centred bold line(s) at the top (court)
//   caption_numbers: [lines]       right column above the title (court numbers)
//   intro: "..."                   paragraph under the caption table, before the contents
//   caption: [{names: [...], designation: "..."}]   parties, "v." between entries
//   proceeding: [lines]            nature of proceeding, court and judge under review
//   notice: [lines]                optional centred lines (e.g. date of court of appeals decision)
//   brief_title: [lines] or "..."  title of the document
//   counsel: [{lines: [...]}]      counsel blocks (columns: counsel_columns, default 1)
//   counsel_footer: "..."          optional centred bold line under the counsel blocks
//   signature: {firm, signer, lines}, lead_in          optional signature block after the body
//   authorities: [{heading, entries: [{cite, find}]}]   optional table of authorities
//   toc: false                     no table of contents page
//   toc_depth: 3                   deepest heading level listed (default 3)
//   before_toc: N                  N leading body sections go on their own page before the TOC

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 6.903(1)(g)(1): serif, proportional; Times New Roman is a listed example. Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 14pt                      // Rule 6.903(1)(g)(1): 14-point or larger for all text, footnotes included.
#let double-leading = 1.61em               // Rule 6.903(1)(e): double-spaced. Measured pitch = 9.7 pt natural + leading = 32.2 pt, twice the 16.1 pt single line (1.15 em) of Times at 14 pt.
#let single-leading = 0.46em               // Rule 6.903(1)(e): quotations over 50 words, headings and footnotes may be single-spaced (16.1 pt at 14 pt).
#let page-margin = 1in                     // Rule 6.903(1)(e): 1 inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style; exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iowa-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("iowa-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let as-lines(v) = if type(v) == str { (v,) } else { v }

/// One caption side: the names centred, then the designation (italic) beneath.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #for n in side.names [ #inl(n) \ ]
    #if "designation" in side [ #inl(side.designation) ]
  ]
}

/// Counsel block: its lines, single-spaced, left aligned.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block: the firm lines, then "/s/" and the typed name, underlined, then the party the
/// signer represents.
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
#let toa-marker(key) = [#metadata(key)<iowa-toa>]

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
  let pages = query(<iowa-toa>)
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

#let iowa-brief(meta, body) = {
  let title-lines = as-lines(need(meta, "brief_title"))
  set document(title: title-lines.join(" "))
  // Rule 6.903(1)(f): page numbers bottom centre, consecutive Arabic numerals, the cover is page one.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
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

  // Block quotations: indented, single-spaced (Rule 6.903(1)(e)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt (Rule 6.903(1)(g)(1)), single-spaced (Rule 6.903(1)(e)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover: caption table (parties left; court numbers and title right), then the
  // introductory paragraph; the table of contents follows on the same page (Rule 6.104(1)(f);
  // 6.1007(2); 6.903(1)(c)). ----
  {
    set par(leading: single-leading, spacing: 0.8em, first-line-indent: 0pt)
    align(center, strong[#for l in as-lines(need(meta, "cover_head")) [ #inl(l) \ ]])
    v(0.2in)
    let sides = need(meta, "caption")
    grid(columns: (1fr, 1fr), column-gutter: 0.2in, row-gutter: 1em,
      {
        for (i, side) in sides.enumerate() {
          if i > 0 { [v.]; v(0.6em) }
          for n in side.names [ #inl(n) \ ]
          v(0.4em)
          if "designation" in side { inl(side.designation) }
          v(0.4em)
        }
      },
      {
        for l in as-lines(need(meta, "caption_numbers")) [ #inl(l) \ ]
        v(1.2em)
        strong[#for l in title-lines [ #inl(l) \ ]]
      })
    v(0.3in)
    set par(leading: single-leading, spacing: 0.8em, first-line-indent: (amount: para-indent, all: true))
    inl(need(meta, "intro"))
    v(0.2in)
  }

  // ---- Body chunks. before_toc leading sections go on their own page ahead of the TOC; footnote
  // definitions sit at the end of the body; they go with the main text, where their references are.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# Certificate")
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  let chunks = main-part.split("\n# ")
  let first = chunks.first()
  let rest = chunks.slice(1).map(c => "\n# " + c)
  let before = meta.at("before_toc", default: 0)
  for c in rest.slice(0, before) {
    mark-authorities(meta, cmarker.render(c, raw-typst: false, smart-punctuation: true))
    pagebreak()
  }
  let after = rest.slice(before).join("")

  // ---- Table of contents (Rule 6.903(2)(a)(1)) ----
  if meta.at("toc", default: true) {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, strong[TABLE OF CONTENTS])
    v(0.4em)
    show outline.entry: it => block(above: 0.5em, below: 0.5em, it)
    outline(title: none, depth: meta.at("toc_depth", default: 3), indent: 1em)
    pagebreak(weak: true)
  }

  // ---- Table of authorities (Rule 6.903(2)(a)(2)) follows the contents ----
  if "authorities" in meta {
    authorities-table(meta)
    pagebreak(weak: true)
  }
  mark-authorities(meta, cmarker.render(first + after, raw-typst: false, smart-punctuation: true))

  // ---- Signature block ----
  if "signature" in meta {
    v(0.4in)
    block(width: 100%, breakable: false)[
      #if "lead_in" in meta { par(first-line-indent: 0pt, inl(meta.lead_in)) }
      #v(0.4em)
      #signature-block(meta.signature)
    ]
  }

  // ---- Certificates: transcribed from the filed document, on a new page ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
