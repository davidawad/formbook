// Maine Supreme Judicial Court (sitting as the Law Court) motion template: a motion with an incorporated
// memorandum of law (MRAP 10(a), 1D(d)). Entry point: typst/main.typ calls me-motion-brief(meta, body).
// Every number is a named constant below and traces to a rule in ../rules.md. Nothing here is
// case-specific: case text comes from the input's frontmatter and body only.
#import "@preview/cmarker:0.1.10"

// ---- Typography and paper (MRAP 7(g)(2), 1D(d)) --------------------------------------------
// No typeface is named by the rule; Times New Roman is the convention across the exemplars (ME-FORM-006).
#let font-family = "Times New Roman"
#let body-size = 14pt // ME-FORM-001: printed matter at least 14-point (MRAP 1D(d) applies to motions, ME-MOT-006)
#let note-size = 11pt // ME-FORM-001: footnotes may be 11-point
#let margin = 1in // ME-FORM-003, ME-FORM-004: one inch on the top, bottom and both sides
#let indent = 0.5in
// ME-FORM-005: double spacing between lines. Typst's natural pitch for this face is about 0.68em, so
// the leading is set so the baseline-to-baseline pitch is 1.15em (single) and 2.3em (double).
#let leading-double = 1.63em
#let leading-single = 0.47em

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("SUPREME JUDICIAL COURT", "Sitting as the Law Court") // ME-MOT-001

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("me-motion: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Arabic page number in the footer, continuous from the first page (MRAP 7(g)(3)).
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a party name or a signature.
#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Caption (MRAP 1D(d), ME-MOT-001, ME-MOT-005) -----------------------------------------------
// A motion's first page is a caption, not a brief cover: the court, the docket number and the case
// title sit above the descriptive title, and the body starts on the same page.
#let caption-parties(sides) = for side in sides {
  block(width: 100%, lines-of(side.names))
  block(above: 0.6em, below: 0.6em, pad(left: 1.2in, [#side.designation]))
  if side != sides.last() {
    block(below: 0.6em, pad(left: 0.6in, [v.]))
  }
}

#let caption-block(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: (3.4in, 1fr),
    gutter: 0.2in,
    [
      #meta.venue
      #v(1.2em)
      #caption-parties(meta.caption)
    ],
    [
      #lines-of(court-lines)
      #v(0.6em)
      Docket No. #meta.docket
      #v(2.4em)
      #for l in meta.label { block(width: 100%, [#l]) }
    ],
  )
  v(1.6em)
  align(center, text(weight: "bold", meta.brief_title))
  v(1.2em)
}

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "en")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  show heading.where(level: 2): h => block(above: 1.2em, below: 0.8em, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(
    above: 1.1em,
    below: 0.6em,
    text(weight: "bold", style: "italic", h.body),
  )
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote: f => text(font: font-family, f)
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

// ---- Closing: date, signature block (MRAP 1C(b)) -----------------------------------------------
// The filing date sits left and "Respectfully submitted," right, with the signature block below.
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(leading-double)
  #grid(columns: (1fr, 3.4in), [Dated: #meta.date], [Respectfully submitted,])
  #v(1.4em)
  #pad(left: 3.1in, block(width: 3.4in, breakable: false, lines-of(meta.signature.lines)))
]

// ---- Certificate of service (MRAP 1D(e)); emitted only when the input has a `service` key -----
#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I certify that I have on this day served a true and correct copy of the foregoing upon the following counsel of record by #meta.service.method:
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(1.2em)
  #grid(
    columns: range(meta.service.recipients.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
  #v(1.4em)
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date
  #pad(left: 3.1in, block(width: 3.4in, breakable: false, lines-of(meta.signature.lines)))
]

// ---- Entry -------------------------------------------------------------------------------------
#let me-motion-brief(meta, body) = {
  set document(title: meta.docket + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document: footnote areas are laid out with the page's own style.
  set text(font: font-family, size: body-size, lang: "en")
  // One continuous Arabic numbering from the first page (MRAP 7(g)(3)); the caption is page 1.
  page(numbering: "1", footer: folio)[
    #show: style-body
    #caption-block(meta)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
