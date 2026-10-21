// Missouri Court of Appeals, Western District (moctappwd): amicus curiae brief.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to
// it (Missouri Supreme Court Rules 84.03, 84.04, 84.05(f), 84.06; see ../../rules.md). No
// case-specific text, no coordinates measured off any filed brief, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 84.03(b)(3): Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 13pt                      // Rule 84.03(b)(3): not smaller than 13 point, footnotes included.
#let body-leading = 1.03em                 // Rule 84.03(b)(2): line spacing not less than 1.5. Pitch = 0.693 em natural + 1.03 em = 1.725 em = 1.5 x the 1.15 em single line.
#let single-leading = 0.46em               // Rule 84.03(b)(2): captions, headings, long quotations, footnotes, certificates and signature block may be single-spaced (1.15 em pitch).
#let page-margin = 1in                     // Rule 84.03(b)(2): not less than one inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block sits right of centre (style).
#let toc-depth = 4                         // Rule 84.04(a)(1): a detailed table of contents.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moctappwd-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("moctappwd-amicus-brief: missing required metadata field `" + key + "`") }
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
    #if "intro" in sig [ #inl(sig.intro) \ #v(0.6em) ]
    #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
    #v(0.6em)
    #underline[/s/ #inl(sig.signer)] \
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
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
  // Rule 84.03(b)(1): paginated consecutively with Arabic numerals at the bottom, the cover included.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, bold, single-spaced. Level 2: point heading, bold.
  // Level 3: sub-heading, bold. Headings are typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]

  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]

  // Block quotations: indented, single-spaced (Rule 84.03(b)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size as the text (Rule 84.03(b)(3)), single-spaced (Rule 84.03(b)(2)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #strong[No. #need(meta, "case_number")]
      #v(1.2em)
      #for l in need(meta, "court_lines") [ #strong(inl(l)) \ ]
      #v(1.2em)
      #for (i, side) in need(meta, "caption").enumerate() [
        #if i > 0 [ #v(0.6em) v. #v(0.6em) ]
        #for n in side.names [ #inl(n) \ ]
        #inl(side.designation)
      ]
      #v(1.2em)
      #inl(need(meta, "proceeding"))
      #v(1.6em)
      #strong(inl(need(meta, "brief_title")))
    ]
    #v(1fr)
    #grid(columns: (1fr, 1fr), column-gutter: 0.4in,
      ..need(meta, "counsel").map(g => [
        #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
        #for l in g.lines [ #inl(l) \ ]
      ]))
    #v(0.8em)
    #inl(need(meta, "counsel_role"))
  ]

  // ---- Table of contents (Rule 84.04(a)(1)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[Table of Contents])
    #v(0.4em)
    #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
    #outline(title: none, depth: toc-depth, indent: 1em)
  ]

  // ---- Table of authorities (Rule 84.04(a)(1)), then the body. Footnote definitions sit at the
  // end of the body; they go with the main text, where their references are. The signature block
  // follows the conclusion and the certificate starts on a new page.
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

  // ---- Signature block (after the conclusion; single-spaced, Rule 84.03(b)(2)) ----
  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service and compliance (Rule 84.06(c)), transcribed from the filed brief ----
  if certs.len() > 0 {
    pagebreak(weak: true)
    set par(leading: single-leading, spacing: 1em)
    mark-authorities(meta, cmarker.render(certs, raw-typst: false, smart-punctuation: true))
  }
}
