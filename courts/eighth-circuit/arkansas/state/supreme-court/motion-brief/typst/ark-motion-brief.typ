// Arkansas Supreme Court (ark): brief on the merits and, with the same template, the other Supreme Court filings.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Rules of the Supreme Court and Court of Appeals of the State of Arkansas, current
// through December 15, 2025, https://opinions.arcourts.gov/ark/cr/en/1871/1/document.do; see
// ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter
// of the sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 4-1(d): serif, proportional. No face is named; Times New Roman first, Liberation Serif as its metric twin (docs/FONTS.md).
#let type-size = 14pt                      // Rule 4-1(d): not less than 14 points, footnotes included.
#let double-leading = 1.61em               // Rule 4-1(b): double-spaced. Measured pitch = 9.7 pt natural + leading = 32.2 pt, twice the 16.1 pt single line (1.15 em) of Times at 14 pt.
#let single-leading = 0.46em              // Rule 4-1(b) excludes quoted material and footnotes from double spacing: single line = 16.1 pt at 14 pt.
#let page-margin = 1in                     // Rule 4-1(c): not less than one inch on all sides.
#let cover-top-margin = 2in                // Rule 4-1(c): top margin of the brief cover not less than two inches.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style; exemplars do the same).
#let toc-depth = 1                         // Rule 4-2(a)(2): contents reference the major sections.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ark-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ark-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: names flush left, the designation flush right on the same line.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  align(right, strong(inl(side.designation)))
}

/// Counsel block under "Submitted by:". Names, then the firm, address and contact lines.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.8em)
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
#let toa-marker(key) = [#metadata(key)<ark-toa>]

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
  let pages = query(<ark-toa>)
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

#let ark-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 4-1(e): paginated consecutively, the cover is page one.
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

  // Block quotations: indented, single-spaced (Rule 4-1(b)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: text size, single-spaced lines (Rule 4-1(b): footnote lines double-spaced except quotations;
  // footnotes are used sparingly, so their spacing is a tier-2 choice matching the exemplar).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Caption block (Rule 4-2(a)(1)): court, number and style, court below and its judge, title,
  // counsel. On the cover (briefs) it fills the first page under the two-inch file-mark margin
  // (Rule 4-1(c)); in a paper without a cover (motion, petition) it opens the first page, and
  // 1 in of space is added to the 1 in page margin for the file-mark.
  let has-cover = meta.at("cover", default: true)
  let has-toc = meta.at("toc", default: true)
  let front = [
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(need(meta, "court_line"))))
    #v(0.1in)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [
        #grid(columns: (1fr, auto, 1fr), [v.], [#strong[No. #need(meta, "case_number")]], [])
        #v(0.1em)
      ]
      #caption-side(side)
      #v(0.1em)
    ]
    #v(0.2em)
    #if "proceeding" in meta [ #align(center)[#inl(meta.proceeding)] ]
    #if "judge" in meta [ #align(center)[#inl(meta.judge)] ]
    #v(0.12in)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #v(0.12in)
  ]
  if has-cover {
    page(margin: (x: page-margin, top: cover-top-margin, bottom: page-margin + 4pt), numbering: "1")[
      #front
      #align(left)[
        #for g in need(meta, "counsel") { counsel-group(g) }
      ]
    ]
  } else {
    v(cover-top-margin - page-margin)
    front
  }

  // ---- Table of contents (Rule 4-2(a)(2)) ----
  if has-toc {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, strong[TABLE OF CONTENTS])
      #v(0.4em)
      #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
      #outline(title: none, depth: toc-depth, indent: 0pt)
    ]
  }

  // ---- Body. The table of authorities follows the points on appeal (Rule 4-2(a)(3)-(4)); the
  // signature follows the request for relief and the certificates start on a new page (as filed).
  // Footnote definitions sit at the end of the body; they go with the main text, where their
  // references are.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# Certificate")
  let main-part = (if cut == none { text } else { text.slice(0, cut) }) + notes
  let certs = if cut == none { "" } else { text.slice(cut) }
  let chunks = main-part.split("\n# ")
  let first = chunks.first()
  let rest = chunks.slice(1).map(c => "\n# " + c).join("")
  let has-points = lower(first).contains("points on appeal")
  let intro = if has-points { first } else { "" }
  let after = if has-points { rest } else { main-part }
  mark-authorities(meta, cmarker.render(intro, raw-typst: false, smart-punctuation: true))
  if "authorities" in meta {
    page(authorities-table(meta))
  }
  mark-authorities(meta, cmarker.render(after, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (after the request for relief) ----
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
