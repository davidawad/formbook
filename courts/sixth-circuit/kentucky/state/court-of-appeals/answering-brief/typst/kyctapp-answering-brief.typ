// Kentucky Court of Appeals (kyctapp): a brief of a party (RAP 31, 32), used for the appellant's brief here.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited beside it:
// Kentucky Rules of Appellate Procedure, created by Supreme Court of Kentucky Order 2022-49, effective
// January 1, 2023 (Internet Archive capture of the court-posted order; see ../../rules.md). No case text, no
// coordinates measured off a filed brief, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata is the YAML frontmatter of the sample (fields documented in ../README.md).
//
// Page layout: letter, 1 in top, right and bottom, 1 1/2 in left (RAP 31 (A) (1) (e)); text and footnotes 12 pt,
// double spaced (RAP 31 (A) (1) (b)-(d)). Cover, then the front matter (introduction, statement concerning oral
// argument, statement of points and authorities) numbered in lowercase roman after the cover, then the body in Arabic
// numerals from 1 (RAP 32 (A) (1)-(2) order; exemplar convention).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // RAP 31 (A) (2): readable serif; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 12pt                                       // RAP 31 (A) (1) (c)-(d): text and footnotes no smaller than 12 point.
#let body-leading = 1.2em                                   // RAP 31 (A) (1) (b): double spaced (pitch about 2.35 em, about 28 pt).
#let single-leading = 0.46em                                // Captions, cover blocks, headings, block quotations, footnotes and authorities: single spaced (0.46 em on the cap-height line: a 1.15 em, 13.8 pt pitch).
#let para-indent = 0.5in
#let sig-indent = 3.0in                                     // signature blocks start right of centre (exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyctapp-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("kyctapp-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// The page number, as displayed, of a location (roman in the front matter, Arabic in the body).
#let pg(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// Split the markdown body at the heading that opens the body (frontmatter `body_start`, for example
/// "STATEMENT OF THE CASE"). Everything before it is front matter.
#let split-body(body, start) = {
  let m = body.match(regex("(?im)^# +" + start + " *$"))
  if m == none { panic("kyctapp-opening-brief: the body has no level-1 heading `" + start + "`") }
  (body.slice(0, m.start), body.slice(m.start))
}

// ---------------------------------------------------------------------------
// Authorities (table of authorities with page references)
// ---------------------------------------------------------------------------

/// Each authority entry carries `find`: one string, or a list of strings, that appears in every citation of
/// the authority in the body (full cite and short form). A show rule on that string drops an invisible marker
/// after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<kyctapp-toa>]

#let finds-of(e) = if type(e.find) == array { e.find } else { (e.find,) }

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      for key in finds-of(e) {
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(finds) = context {
  let pages = query(<kyctapp-toa>)
    .filter(m => m.value in finds)
    .map(m => pg(m.location()))
    .dedup()
  if pages.len() == 0 { [--] } else { pages.join(", ") }
}

#let authorities-list(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.6em, sticky: true, text(weight: "bold", group.heading))
    for e in group.entries {
      block(above: 0.7em, below: 0.7em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #toa-pages(finds-of(e))
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Cover
// ---------------------------------------------------------------------------

#let caption-lines(names) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  for n in names [ #inl(n) \ ]
}

#let cover-body(meta, s) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  align(center)[
    #text(weight: "bold")[COMMONWEALTH OF KENTUCKY] \
    #text(weight: "bold")[COURT OF APPEALS] \
    #v(0.1in)
    CASE NO. #need(meta, "case_number")
  ]
  v(0.3in * s)
  let sides = need(meta, "caption")
  grid(
    columns: (2.5in, 2.5in, 1.0in),
    row-gutter: 0.16in,
    gutter: 0pt,
    [#caption-lines(sides.at(0).names)],
    [#align(center, {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      for l in need(meta, "appeal_from") [ #inl(l) \ ]
    })],
    [#align(right, text(weight: "bold")[#sides.at(0).designation])],
    [V.], [], [],
    [#caption-lines(sides.at(1).names)],
    [],
    [#align(right, text(weight: "bold")[#sides.at(1).designation])],
  )
  v(0.35in * s)
  line(length: 100%, stroke: 0.75pt)
  v(0.12in * s)
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #text(weight: "bold")[#inl(need(meta, "brief_title"))] \
    #text(weight: "bold")[#inl(need(meta, "brief_party"))]
  ]
  v(0.12in * s)
  line(length: 100%, stroke: 0.75pt)
  v(0.3in * s)
  pad(left: sig-indent, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    [Respectfully submitted,]
    v(0.5em)
    for g in need(meta, "counsel") {
      for n in g.names {
        if g.at("bold", default: false) { strong(inl(n)) } else { inl(n) }
        linebreak()
      }
      for l in g.at("lines", default: ()) {
        inl(l)
        linebreak()
      }
      v(0.5em)
    }
  })
  if "service" in meta {
    v(0.25in * s)
    let svc = meta.service
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.5em)
    align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
    v(0.1in)
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 0.4em, below: 0.4em, breakable: false, pad(left: 0.5in, {
        set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        for l in r [ #inl(l) \ ]
      }))
    }
    v(0.1em)
    pad(left: sig-indent)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #underline[/s/ #emph(svc.signer.name)] \
      #svc.signer.name
    ]
  }
}

/// The cover is one page. Its fixed vertical spaces are the only thing that gives: the largest scale of them at
/// which the whole cover fits is used (RAP 31 (C) (1) (b) puts the certificate of service on the cover).
#let cover(meta) = layout(size => {
  let fits(s) = measure(block(width: size.width, cover-body(meta, s))).height <= size.height
  let s = (1.0, 0.8, 0.6, 0.4, 0.2, 0.0).find(fits)
  if s == none { panic("kyctapp-answering-brief: the cover does not fit on one page; shorten the counsel or service lines") }
  cover-body(meta, s)
})

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let kyctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, right: 1in, left: 1.5in),
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Headings in the markdown body: level 1 is a section (centred, capitals, bold); level 2 is a numbered
  // argument heading (bold, hanging); level 3 is a sub-heading (bold italic).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.1em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.7em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented both sides, single spaced (RAP 31 (A) (1) (b) excludes them from double spacing
  // only by convention; exemplars single space them).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // Footnotes: 12 pt like the text (RAP 31 (A) (1) (d)), single spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  let (front, main) = split-body(body, need(meta, "body_start"))

  // ---- Cover (RAP 31 (C)): page 1, unnumbered ----
  cover(meta)
  pagebreak()

  // ---- Front matter: introduction and statement concerning oral argument (RAP 32 (A) (1)), roman ----
  set page(numbering: "i")
  mark-authorities(meta, cmarker.render(front, raw-typst: false, smart-punctuation: true))

  // ---- Statement of points and authorities (RAP 32 (A) (2); required above five pages, RAP 32 (D)) ----
  pagebreak()
  align(center, text(weight: "bold")[STATEMENT OF POINTS AND AUTHORITIES])
  v(0.2in)
  {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    show outline.entry: it => block(above: 0.55em, below: 0.55em, it)
    outline(title: none, depth: 3, indent: 0pt)
  }
  if "authorities" in meta {
    v(0.4em)
    authorities-list(meta)
  }

  // ---- Body (RAP 32 (A) (3)-(7)), Arabic from 1 ----
  pagebreak()
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(main, raw-typst: false, smart-punctuation: true))

  // ---- Signature (RAP 32 (A) (6)) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #pad(left: sig-indent)[
      Respectfully submitted,
      #v(0.6em)
      #for (i, s) in need(meta, "signature").signers.enumerate() {
        if i > 0 { v(0.9em) }
        underline[/s/ #emph(s.name)]
        linebreak()
        s.name
        for l in s.at("lines", default: ()) {
          linebreak()
          inl(l)
        }
        linebreak()
      }
    ]
  ]

  // ---- Word-count certificate (RAP 15 (E)), after the signature as filed ----
  if "word_count" in meta {
    let wc = meta.word_count
    v(0.4in)
    block(width: 100%, breakable: false)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #align(center, text(weight: "bold")[WORD COUNT CERTIFICATE])
      #v(0.3in)
      #set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))
      #inl(wc.text)
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #v(0.4em)
      #pad(left: sig-indent)[
        #underline[/s/ #emph(wc.signer)] \
        #wc.signer
      ]
    ]
  }
}
