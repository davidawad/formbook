// Supreme Court of Pennsylvania application for extraordinary relief (King's Bench; Pa.R.A.P. 3309; rules.md
// PA-CONT-017, PA-CONT-018, PA-CERT-006). Entry point: typst/main.typ, which calls pa-petition-for-writ(meta, body)
// with the sample's frontmatter and markdown. Every number below is a named constant that traces to rules.md.
// Nothing here is case-specific: case text comes from frontmatter.
#import "@preview/cmarker:0.1.10"

// ---- Pa.R.A.P. 124: form of documents -----------------------------------------------------------
// Rule 124(a)(4): lettering no smaller than 14 point in the text; footnotes 12 point (PA-FORM-004).
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt // Pa.R.A.P. 124(a)(4): 14-point text
#let note-size = 12pt // Pa.R.A.P. 124(a)(4): footnotes 12-point
#let margin = 1in // Pa.R.A.P. 124(a)(2): margins at least one inch on all four sides (PA-FORM-002)
// Pa.R.A.P. 124(a)(2): the first page keeps a three-inch space from the top for court stampings (PA-FORM-002); it is
// the 1 in margin plus this gap, so a cover that runs on starts its next page at the 1 in margin.
#let stamp-space = 3in - margin
#let indent = 0.5in
// Measured on the render at 14 pt: a leading of 1.6 em gives a double-spaced pitch (Pa.R.A.P. 124(a)(3)); 0.46 em
// gives single spacing for headings, block quotations, footnotes, caption and signature lines.
#let leading-double = 1.6em
#let leading-single = 0.46em
#let leading-tight = 0.5em // table of contents entries

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-lines = ("IN THE", "SUPREME COURT OF PENNSYLVANIA")
#let public-access-cert = "I certify that this filing complies with the provisions of the Case Records Public Access Policy of the Unified Judicial System of Pennsylvania that require filing confidential information and documents differently than non-confidential information and documents." // Pa.R.A.P. 127(a); PA-CERT-001

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pa filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the bottom margin (Pa.R.A.P. 124(a)(3)); none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover ---------------------------------------------------------------------------------------
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  lines-of(side.names)
  block(width: 100%, [#h(0.5in)#side.designation])
}

// Pa.R.A.P. 2172(a)(6) (PA-COVER-001): the names of all counsel, and the office address and telephone of the one to
// be served. When a group is marked `service: true`, the cover gives that group's lines without e-mail addresses
// and the other groups' names only; every group's full contact lines stay in the signature block.
#let cover-counsel(meta) = {
  let served = meta.counsel.any(c => c.at("service", default: false))
  meta.counsel.map(c => {
    if not served { c.lines } else if c.at("service", default: false) { c.lines.filter(l => not l.contains("@")) } else {
      ()
    }
  })
}

// Front cover, Pa.R.A.P. 2172(a)(1)-(4), (6): court, number, caption, title, counsel. `g` scales the gaps only.
#let cover-front(meta, g) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  v(stamp-space)
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(1.2em * g)
  if meta.case_number != "" [
    #align(center, text(weight: "bold", "No. " + meta.case_number))
    #v(1.6em * g)
  ]
  caption-side(meta.caption.at(0))
  v(0.8em * g)
  block(width: 100%, [#h(0.5in) v.])
  v(0.8em * g)
  caption-side(meta.caption.at(1))
  if "proceeding" in meta [
    #v(1.2em * g)
    #align(center, meta.proceeding)
  ]
  v(2.2em * g)
  align(center, text(weight: "bold", meta.brief_title))
  v(2.4em * g)
  // Two columns of counsel groups.
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.25in,
    row-gutter: 0.8em * g,
    ..meta.counsel.zip(cover-counsel(meta)).map(((c, ls)) => block(width: 100%, [
      #lines-of(c.names)
      #lines-of(ls)
    ])),
  )
}

// The gaps between the cover's parts are the only thing that gives (type size never shrinks): the largest scale, down
// to 0.6, at which the front cover fits one page. The rest of the caption (Pa.R.C.P. 1018 via Pa.R.A.P. 106,
// PA-COVER-002: the names of all the parties), which the caption refers to as the back cover, follows the counsel
// block; a long caption or counsel list runs the cover onto more pages (eval.yaml params.cover_pages).
#let cover(meta) = {
  layout(size => {
    let fits(g) = measure(block(width: size.width, cover-front(meta, g))).height <= size.height
    let g = (1.0, 0.8, 0.6).find(fits)
    cover-front(meta, if g == none { 0.6 } else { g })
  })
  if "back_cover" in meta [
    #v(1.2em)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt, justify: true)
    #meta.back_cover
  ]
}


// ---- Closing: signature blocks ------------------------------------------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.4in,
    row-gutter: 1.4em,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Dated: #meta.date
  #v(0.6em)
  Respectfully submitted,
  #v(0.6em)
  #signature-blocks(meta)
]

// Pa.R.A.P. 127(a) and PA-CERT-001: certification of compliance with the Public Access Policy.
#let compliance-certificate(meta) = [
  #front-title[CERTIFICATE OF COMPLIANCE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #public-access-cert
  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #align(right, meta.compliance_signer)
]

// Verification of facts not of record (Pa.R.A.P. 123(c); PA-CONT-010): one page per verifier.
#let verification(meta, ver) = [
  #front-title[VERIFICATION]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I verify that the statements made in the foregoing #meta.verification_subject are true and correct to the best of my knowledge, information and belief. I understand that false statements made herein are subject to the penalties of 18 Pa. C.S. § 4904 relating to unsworn falsification to authorities.
  #v(2.4em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #block(width: 100%, [Dated: #ver.date])
  #v(2.4em)
  #block(width: 60%, line(length: 100%))
  #lines-of((ver.name, ver.title, ver.org))
]

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------------
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
#let pa-petition-for-writ(meta, body) = {
  set document(title: meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // Cover: no folio. Front matter: roman numerals. Body: restarts at 1 in arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 3, indent: 0pt)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: false, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #compliance-certificate(meta)
  ]
  for ver in meta.verifications {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #verification(meta, ver)
    ]
  }
}
