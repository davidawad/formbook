// Missouri Court of Appeals, Western District (moctappwd): respondent's brief (answering-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Missouri Supreme Court Rules 84.03, 84.04, 84.06; see ../../rules.md). No case-specific
// text, no coordinates measured off any filed brief, no forced line breaks. The markdown body is
// rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 84.03(b)(3): Times New Roman, not smaller than 13 point. Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 84.03(b)(3): not smaller than 13 point, footnotes included.
#let body-leading = 1.03em                 // Rule 84.03(b)(2): line spacing not less than 1.5. Single line = 1.15 em of 13 pt = 14.95 pt; 1.5 lines = 22.4 pt = 9.0 pt natural + 13.4 pt leading.
#let single-leading = 0.46em               // Rule 84.03(b)(2) allows single spacing for caption, headings, quotations over two lines, footnotes, certificates and the signature block: 14.95 pt.
#let page-margin = 1in                     // Rule 84.03(b)(2): not less than one inch on every side.
#let para-indent = 0.5in
#let sig-indent = 3.0in                    // signature block sits right of centre (style; exemplars do the same).
#let toc-depth = 3                         // Rule 84.04(a)(1): a detailed table of contents.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moctappwd-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("moctappwd-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side, centred: the names, then the designation.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #for n in side.names [ #inl(n) \ ]
    #v(0.3em)
    #inl(side.designation)
  ]
}

/// Signature block: the intro line, the head lines, "/s/" and the signer, then the contact lines.
/// The foot lines (the parties the signer represents) follow.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "intro" in sig [ #inl(sig.intro) \ #v(0.8em) ]
    #for l in sig.at("head", default: ()) [ #inl(l) \ ]
    #v(0.8em)
    #inl("/s/ " + sig.signer) \
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
    #if "foot" in sig [ #v(0.8em) #for l in sig.foot [ #inl(l) \ ] ]
  ])
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
      block(above: 0.5em, below: 0.5em, breakable: false)[
        #grid(columns: (1fr, auto), column-gutter: 4pt, align: (left, bottom + right),
          [#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])],
          if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let moctappwd-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 84.03(b)(1): Arabic numerals at the bottom, consecutive, the cover included.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
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
  // Footnotes: same size (Rule 84.03(b)(3)), single-spaced (Rule 84.03(b)(2)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover: case number, court, caption, origin of the appeal, title, counsel (as the Western District briefs are laid out) ----
  page(margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1")[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #set align(center)
    #strong[No. #need(meta, "case_number")]
    #v(0.3em)
    #line(length: 40%, stroke: 0.5pt)
    #v(0.3em)
    #for l in need(meta, "court_lines") [ #strong(inl(l)) \ ]
    #v(0.3em)
    #line(length: 40%, stroke: 0.5pt)
    #v(0.6em)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #v(0.4em) v. #v(0.6em) ]
      #caption-side(side)
    ]
    #v(0.6em)
    #line(length: 40%, stroke: 0.5pt)
    #v(0.3em)
    #for l in need(meta, "proceeding") [ #inl(l) \ ]
    #v(0.3em)
    #line(length: 40%, stroke: 0.5pt)
    #v(0.6em)
    #strong(upper(inl(need(meta, "brief_title"))))
    #v(0.3em)
    #line(length: 40%, stroke: 0.5pt)
    #v(1em)
    #set align(left)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Table of contents (Rule 84.04(a)(1)): sections and argument headings, with page references ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.6em, below: 0.6em, it)
    #outline(title: none, depth: toc-depth, indent: 0.5in)
  ]

  // ---- Body. The table of authorities follows the points on appeal (Rule 84.04(a)(1)); the
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

  // ---- Certificates: transcribed from the filed brief, on a new page; single-spaced (Rule 84.03(b)(2)) ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    set par(leading: single-leading, spacing: 1.2em)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
