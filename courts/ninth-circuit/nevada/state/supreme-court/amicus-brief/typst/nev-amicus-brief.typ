// Nevada Supreme Court brief template (amicus curiae brief, NRAP 29 and 32). Entry point:
// typst/main.typ, which calls nev-brief-amicus(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to a rule in ../rules.md (IDs in brackets).
// Nothing here is case-specific: case text comes from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- NRAP 32(a)(4)-(6): paper, margins, typeface, type style, spacing ------------------------
// NRAP 32(a)(5): proportionally spaced face of 14 points or larger (NEV-FORM-004). Times New Roman
// is the face; Liberation Serif is its metric-compatible vendored substitute (docs/FONTS.md).
#let face = ("Times New Roman", "Liberation Serif")
#let face-name = "Times New Roman" // named in the certificate of compliance (NRAP 32(a)(9)(A))
#let body-size = 14pt // NRAP 32(a)(5)(A); also court eval.yaml (font.size_pt)
#let note-size = 14pt // NRAP 32(a)(5)(B): footnotes the same size and typeface as the body
#let margin = 1in // NRAP 32(a)(4): at least one inch on all four sides (NEV-FORM-002)
#let indent = 0.5in
// NRAP 32(a)(4): double spacing (NEV-FORM-003). Liberation Serif has a natural line pitch of about
// 1.1em, so double spacing is one natural pitch added as leading (about 2.2em per line).
#let leading-double = 1.6em
#let leading-tight = 0.46em // lists of authorities and the table of contents
#let leading-single = 0.46em // NRAP 32(a)(4) allows single spacing for headings, quotations, footnotes

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-line = "IN THE NEVADA SUPREME COURT" // NEV-COVER-001: name of the court
#let kinds = (
  (key: "us-case", title: "SUPREME COURT CASES"),
  (key: "fed-case", title: "FEDERAL CASES"),
  (key: "state-case", title: "STATE CASES"),
  (key: "statute", title: "STATUTES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nev-brief-amicus: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the footer; none on the cover. NEV-FORM-006: lowercase Roman numerals before the
// statement of the case, Arabic from page 1 of the body.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: face, size: body-size, counter(page).display(n))) }
}

// One paragraph per line: the lines of an address block, a caption or a signature.
#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (NEV-COVER-001 to 002) -------------------------------------------------------------
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  lines-of(side.names)
  block(width: 100%, [#h(0.5in)#side.designation])
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, text(weight: "bold", court-line))
  v(1.6em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.4in,
    [
      #caption-side(meta.caption.at(0))
      #v(0.8em)
      #block(width: 100%, [#h(0.5in) v.])
      #v(0.8em)
      #caption-side(meta.caption.at(1))
    ],
    [
      No. #meta.case_number
      #if "proceeding" in meta [
        #v(0.8em)
        On Appeal from #meta.proceeding
      ]
    ],
  )
  v(2.2em)
  align(center, text(weight: "bold", meta.brief_title))
  v(2.4em)
  grid(
    columns: range(meta.counsel.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
}

// ---- Disclosure statement (NRAP 26.1; NEV-AMIC-003) -------------------------------------------
#let disclosure(meta) = {
  set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  cmarker.render(meta.disclosure.text, raw-typst: false, smart-punctuation: true)
  v(1.2em)
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  block(width: 100%, pad(left: 3.2in, lines-of(meta.disclosure.signature)))
}

// ---- Table of authorities (NRAP 29(c)(3)) -----------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the TOA is built from
// those records. Every other link prints its text only (no links to other documents).
#let authority-line(a) = if a.kind.ends-with("case") {
  [#emph(a.name), #a.cite]
} else if "cite" in a {
  [#a.name, #a.cite]
} else {
  [#a.name]
}

#let table-of-authorities(auths) = context {
  let hits = query(<toa-hit>)
  for k in kinds {
    let rows = auths.pairs().filter(((key, a)) => a.kind == k.key)
    if rows.len() == 0 { continue }
    rows = rows.sorted(key: ((key, a)) => lower(a.at("sort", default: if "name" in a { a.name } else { a.cite })))
    block(above: 1.1em, below: 0.5em, text(weight: "bold", k.title))
    for (key, a) in rows {
      let pages = hits.filter(h => h.value.key == key).map(h => counter(page).at(h.location()).first())
      let pages = pages.dedup().sorted()
      let shown = if pages.len() >= 7 { "passim" } else { pages.map(str).join(", ") }
      block(
        above: 0pt,
        below: 0.5em,
        grid(
          columns: (1fr, auto),
          gutter: 1em,
          par(leading: leading-tight, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: date, signature blocks (NRAP 32(a)(9)) -----------------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

// Markup blocks, not code blocks: a blank line separates paragraphs only in markup.
#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated #meta.date.

  Respectfully submitted,

  #signature-blocks(meta)
]

// Certificate of compliance, NRAP 32(a)(9)(A). The typeface and size are the template's own face
// and body size; the word count is the filer's (frontmatter word_count).
#let numbered(n, body) = block(width: 100%, par(first-line-indent: indent, [#n. #body]))

#let certificate-of-compliance(meta) = [
  #heading(level: 1)[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #numbered(1)[I hereby certify that this brief complies with the formatting requirements of NRAP 32(a)(4), the typeface requirements of NRAP 32(a)(5) and the type style requirements of NRAP 32(a)(6) because this brief has been prepared in a proportionally spaced typeface, #face-name, #int(body-size.pt()) point font.]
  #numbered(2)[I further certify that this brief complies with the page- or type-volume limitations of NRAP 32(a)(7) because, excluding the parts of the brief exempted by NRAP 32(a)(7)(C), it is proportionately spaced, has a typeface of 14 points or more, and contains #meta.word_count words.]
  #numbered(3)[I hereby certify that I have read this appellate brief, and to the best of my knowledge, information, and belief, it is not frivolous or interposed for any improper purpose. I further certify that this brief complies with all applicable Nevada Rules of Appellate Procedure, in particular NRAP 28(e)(1), which requires every assertion in the brief regarding matters in the record to be supported by a reference to the page and volume number, if any, of the transcript or appendix where the matter relied on is to be found. I understand that I may be subject to sanctions in the event that the accompanying brief is not in conformity with the requirements of the Nevada Rules of Appellate Procedure.]

  #v(0.4em)
  #closing(meta)
]

// Certificate of service, NRAP 25(d). Electronic service through the appellate system.
#let certificate-of-service(meta) = [
  #heading(level: 1)[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I hereby certify that on #meta.date, I electronically filed the foregoing with the Clerk of the Nevada Supreme Court by using the appellate electronic filing system. Participants in the case who are registered users in the appellate electronic filing system will be served by the system and include:

  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #grid(
    columns: 1fr, // one column: long e-mail addresses must not overrun the margin
    gutter: 0.3in,
    ..meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )

  #v(1.4em)
  #pad(left: 3.2in, lines-of(meta.service.signature))
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------
#let style-body(it) = {
  set text(font: face, size: body-size, lang: "en")
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
  show footnote: f => text(font: face, size: 0.8em, f) // reference marker: smaller, so it does not rise above the text box
  show footnote.entry: n => {
    set text(font: face, size: note-size)
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
  show link: l => {
    if type(l.dest) == str and l.dest.starts-with("toa:") {
      [#l.body#metadata((key: l.dest.slice(4)))<toa-hit>]
    } else if type(l.dest) == str {
      l.body
    } else {
      l
    }
  }
  it
}

// ---- Entry -------------------------------------------------------------------------------------
#let nev-brief-amicus(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  // Set once for the whole document, not only inside the page wrappers: footnote areas are laid
  // out with the page's own style, and otherwise fall back to typst's default serif.
  set text(font: face, size: body-size, lang: "en")
  // Each section is its own page(): the cover has no folio; the front matter is roman; the body
  // restarts at 1 in Arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  if "disclosure" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #heading(level: 1)[NRAP 26.1 DISCLOSURE]
      #disclosure(meta)
    ]
  }
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 2, indent: 0pt)
  ]
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF AUTHORITIES]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-compliance(meta)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
