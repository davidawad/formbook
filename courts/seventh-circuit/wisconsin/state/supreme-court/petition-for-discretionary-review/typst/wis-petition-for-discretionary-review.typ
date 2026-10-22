// Supreme Court of Wisconsin (wis): petition-for-discretionary-review (petition to bypass, Wis. Stat. 809.60).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Wis. Stat. chapter 809, 2023-24 Wisconsin Statutes published 2025-11-21, read 2026-10-21; see ../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the input.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Liberation Serif",)  // no face named by Wis. Stat. 809.19(8)(b)3.c or 809.81(3); docs/FONTS.md gives Liberation Serif.
#let type-size = 13pt                     // Wis. Stat. 809.19(8)(b)3.c: proportional serif body text at least 13 point.
#let note-size = 11pt                     // Wis. Stat. 809.19(8)(b)3.c: block quotations and footnotes at least 11 point.
#let body-leading = 0.95em              // Wis. Stat. 809.60 (bypass) and 809.62(4) band: 1.15 to 1.5 lines; exemplar pitch is about 1.5 lines.
#let single-leading = 0.5em               // Block quotations, footnotes, headings, captions: single-spaced.
#let margin-lr = 1.25in                   // Wis. Stat. 809.19(8)(b)3.e: at least 1.25 inch right and left.
#let margin-tb = 1in                      // Wis. Stat. 809.19(8)(b)3.e: at least 1 inch top and bottom.
#let para-indent = 0.5in
#let toc-depth = 4
#let sig-indent = 3.2in
#let word-limit = 1000000
#let counted-sections = ()

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wis-petition-for-discretionary-review: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("wis-petition-for-discretionary-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Strip the markdown markup that is not words (emphasis, link targets, footnote markers, quote marks).
#let strip-md(s) = {
  let t = s.replace(regex("\\[\\^[^\\]]*\\]:?"), " ")
  t = t.replace(regex("\\]\\([^)]*\\)"), "] ")
  t = t.replace(regex("[\\[\\]*_>#|`~]"), " ")
  t
}

#let count-words(s) = s.replace(regex("\\s+"), " ").split(" ").filter(w => w != "").len()

/// Words in the level-1 sections the rule counts. The body is split at level-1 headings.
/// An empty `counted-sections` counts the whole body (petitions: the petition and memorandum combined).
#let counted-words(body) = {
  if counted-sections.len() == 0 { return count-words(strip-md(body)) }
  let total = 0
  for part in ("\n" + body).split("\n# ").slice(1) {
    let title = lower(part.split("\n").first().trim().replace("*", ""))
    if title in counted-sections { total += count-words(strip-md(part)) }
  }
  total
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block: "Signed:" line, typed signer name, then the counsel lines.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    Signed:
    #v(2.2em)
    #line(length: 100%, stroke: 0.5pt)
    #v(0.3em)
    #inl(need(sig, "signer"))
    #for l in sig.at("lines", default: ()) { linebreak() + inl(l) }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body. A show rule on that string drops a marker after each occurrence;
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<wis-toa>]

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
  let pages = query(<wis-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.5em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.6em, below: 0.6em, breakable: false)[
        #grid(columns: (auto, 1fr, auto), column-gutter: (0pt, 0.3em), align: (left + bottom, bottom, bottom + right), inl(e.cite), box(width: 100%, repeat[.#h(2pt)]), [#if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }])
      ]
    }
  }
}

/// Heading numbers: level 2 "I.", level 3 "A.", level 4 "1."; level 1 sections are unnumbered.
#let heading-number(..nums) = {
  let v = nums.pos()
  let n = v.last()
  if v.len() == 2 { numbering("I.", n) } else if v.len() == 3 { numbering("A.", n) } else if v.len() == 4 { numbering("1.", n) } else { none }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let wis-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Wis. Stat. 809.19(8)(bm): Arabic page numbers centred in the bottom margin, counting the cover as page 1.
  set page(
    paper: "us-letter",
    margin: (left: margin-lr, right: margin-lr, top: margin-tb, bottom: margin-tb),
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: heading-number)

  // Level 1 is a section: bold, capitals, centred. Levels 2 to 4 are argument headings, numbered by the template.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold")[#numbering("I.", counter(heading).at(it.location()).last()) #h(0.5em) #it.body]
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold")[#numbering("A.", counter(heading).at(it.location()).last()) #h(0.5em) #it.body]
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 0.9em, below: 0.7em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic")[#numbering("1.", counter(heading).at(it.location()).last()) #h(0.5em) #it.body]
  ]

  // Block quotations: indented, single-spaced, 11 point (Wis. Stat. 809.19(8)(b)3.c).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set text(size: note-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnote reference marks: lowered slightly so the superscript stays inside the top margin (Wis. Stat. 809.81(4)).
  show super: it => box(baseline: 0.12em, it)
  // Footnotes: 11 point, single-spaced (Wis. Stat. 809.19(8)(b)3.c).
  show footnote.entry: it => {
    set text(size: note-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Wis. Stat. 809.81(5): numbering starts at 1 on the first page; the cover is page 1) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[STATE OF WISCONSIN] \
      #text(weight: "bold")[IN SUPREME COURT] \
      #v(0.3in)
      No. #need(meta, "case_number")
    ]
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      let groups = need(meta, "counsel")
      grid(columns: (1fr,) * groups.len(), column-gutter: 0.3in, ..groups.map(counsel-group))
      if "phone" in meta [ #meta.phone ]
    }
  ]

  // ---- Table of contents (Wis. Stat. 809.19(1)(a)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (Wis. Stat. 809.19(1)(a)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature (Wis. Stat. 809.14, 809.81). No 809.19(8g) certification: that is for briefs. ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
