// Supreme Court of New Jersey (nj): motion and supporting letter brief (R. 2:6-2(b), R. 2:6-10; motion-brief).
// Entry: nj-motion-brief(meta, body). Every number is a named constant below and traces to rules.md (NJ-* ids).
// Nothing here is case-specific: case text comes from the frontmatter and the markdown body.
// Letter form: the R. 2:6-6(a) information is carried in the letter heading, so no separate cover is printed.
#import "@preview/cmarker:0.1.10"

// ---- Rule 2:6-10: typography and paper ---------------------------------------------------------
// Typeface: Times New Roman or a similar face (rules.md NJ-FORM-003). Body and note type are set at 14 pt,
// stricter than the 12-point minimum; see the OPEN item in rules.md.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt
#let note-size = 14pt
#let margin = 1in // rules.md NJ-FORM-004: approximately one inch
#let indent = 0.5in
// Measured on the render (14 pt Liberation Serif): leading 1.6 em gives a double pitch; 0.46 em a single pitch.
#let leading-double = 1.6em // NJ-FORM-002: double-spaced text
#let leading-single = 0.46em // footnotes, block quotations, headings, letterhead, address and signature lines

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nj filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nj filing: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// Page number in the bottom margin; none on the first page.
#let folio = context {
  let n = here().page-numbering()
  if n != none and counter(page).get().first() > 1 {
    align(center, text(font: font-family, size: body-size, counter(page).display(n)))
  }
}

#let lines-of(list) = for l in list {
  block(width: 100%, [#l])
}

// ---- Letter heading (Rule 2:6-6(a) information for a letter brief, R. 2:6-2(b)) -------------------
#let letter-head(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  let lh = need(meta, "letterhead")
  align(center, text(weight: "bold", lh.firm))
  align(center, lines-of(lh.lines))
  v(1.6em)
  block(width: 100%, need(meta, "date"))
  v(1.2em)
  block(width: 100%, text(weight: "bold", need(meta, "delivery")))
  v(0.6em)
  lines-of(need(meta, "addressee"))
  v(1.2em)
  // "Re:" with a hanging block: the caption line and the title of the document.
  grid(
    columns: (0.5in, 1fr),
    column-gutter: 0.1in,
    [Re:], lines-of(need(meta, "re")),
  )
  v(1.2em)
  block(width: 100%, need(meta, "salutation"))
}

// ---- Closing: signature block -------------------------------------------------------------------
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully Submitted,
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(0.8em)
  #for g in need(meta, "signature") [
    #lines-of(g.lines)
    #v(1.2em)
  ]
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "en")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  // Argument headings carry their own letters and numerals in the markdown (e.g. "A.", "i."); the template numbers nothing.
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  show heading.where(level: 2): h => block(
    above: 1.2em,
    below: 0.8em,
    width: 100%,
    par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, hanging-indent: 0.5in)[#text(weight: "bold", h.body)],
  )
  show heading.where(level: 3): h => block(
    above: 1.1em,
    below: 0.6em,
    width: 100%,
    par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, hanging-indent: 0.5in)[#text(weight: "bold", style: "italic", h.body)],
  )
  show footnote: f => text(font: font-family, size: note-size, f)
  show footnote.entry: n => {
    set text(font: font-family, size: note-size)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    n
  }
  show quote.where(block: true): q => block(above: 1em, below: 1em, pad(
    left: indent,
    right: indent,
    {
      set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
      q.body
    },
  ))
  it
}

// ---- Entry -------------------------------------------------------------------------------------
#let nj-motion-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in, numbering: "1", footer: folio)
  set text(font: font-family, size: body-size, lang: "en")
  // One continuous letter: the heading and the argument share page 1, which carries no folio.
  show: style-body
  letter-head(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: false, h1-level: 1)
  closing(meta)
}
