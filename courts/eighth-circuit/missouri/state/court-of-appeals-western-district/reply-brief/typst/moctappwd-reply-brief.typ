// Missouri Court of Appeals, Western District (moctappwd): appellant's reply brief (reply-brief).
//
// Content-agnostic. Numbers trace to Mo. Sup. Ct. R. 84.03(b) and 84.06 (see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 84.03(b)(3): Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 84.03(b)(3): not smaller than 13 point, footnotes included.
#let double-leading = 1.03em              // Rule 84.03(b)(2): line spacing not less than 1.5. Natural 0.69 em + 1.03 em = 1.725 em = 1.5 x the 1.15 em single line.
#let single-leading = 0.46em              // Rule 84.03(b)(2): single spacing allowed for caption, headings, long quotations, footnotes, certificates, signature block.
#let page-margin = 1in                     // Rule 84.03(b)(2): not less than one inch on all sides.
#let para-indent = 0.5in
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moctappwd-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("moctappwd-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A horizontal rule across the cover.
#let cover-rule() = {
  v(0.3em)
  line(length: 100%, stroke: 0.5pt)
  v(0.3em)
}

/// Counsel on the cover and in the signature block: one column per lawyer, single-spaced.
#let counsel-columns(cols) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  grid(columns: (1fr,) * cols.len(), column-gutter: 0.3in,
    ..cols.map(c => [#for l in c.lines [ #inl(l) \ ]]))
}

/// Signature block: opening line, optional capacity line, then one column per signer.
#let signature-block(sig) = {
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #if "intro" in sig [ #inl(sig.intro) \ ]
    #if "capacity" in sig [ #inl(sig.capacity) \ ]
    #v(0.5em)
    #counsel-columns(need(sig, "signers"))
  ]
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<moctappwd-toa>]

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
  let pages = query(<moctappwd-toa>)
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

#let moctappwd-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 84.03(b)(1): paginated consecutively, the cover is page one.
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

  // Block quotations: indented, single-spaced (Rule 84.03(b)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: text size, single-spaced lines (Rule 84.03(b)(2): footnotes may be single-spaced;
  // the point size stays 13).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover: court, case numbers, caption, appeal-from lines, title, counsel ----
  page(margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1")[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #strong[#for l in need(meta, "court_lines") [ #inl(l) \ ]]
    ]
    #cover-rule()
    #align(center)[#for l in need(meta, "numbers") [ #strong(inl(l)) \ #v(0.4em) ]]
    #cover-rule()
    #align(center)[
      #for (i, side) in need(meta, "caption").enumerate() [
        #if i > 0 [ v. \ ]
        #strong(inl(side)) \
      ]
    ]
    #cover-rule()
    #align(center)[#for l in need(meta, "appeal_from") [ #inl(l) \ ]]
    #cover-rule()
    #v(0.6em)
    #align(center)[#strong[#for l in need(meta, "brief_title_lines") [ #inl(l) \ ]]]
    #v(0.6em)
    #cover-rule()
    #v(1fr)
    #par(first-line-indent: 0pt)[#inl(need(meta, "submitted"))]
    #v(0.4em)
    #counsel-columns(need(meta, "counsel"))
  ]

  // ---- Table of contents (Rule 84.04(a)(1)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
    #outline(title: none, depth: toc-depth, indent: 0.5in)
  ]

  // ---- Body. The table of authorities follows the points on appeal (Rule 84.04(a)(1)); the
  // signature follows the request for relief and the certificates start on a new page (as filed).
  // Footnote definitions sit at the end of the body; they go with the main text, where their
  // references are.
  let notes-cut = body.position("\n[^")
  let text = if notes-cut == none { body } else { body.slice(0, notes-cut) }
  let notes = if notes-cut == none { "" } else { body.slice(notes-cut) }
  let cut = text.position("\n# Certif")
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

  // ---- Signature block (after the conclusion) ----
  v(0.3in)
  signature-block(need(meta, "signature"))

  // ---- Certificates: transcribed from the filed brief, on a new page ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
