// Massachusetts Supreme Judicial Court: reply brief (MRAP 16(c)). Requirement IDs (MA-...) refer to ../../rules.md.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited beside it
// (Massachusetts Rules of Appellate Procedure 16, 20 and 21, as posted on mass.gov). No case-specific text,
// no coordinates measured off any filed brief, no forced line breaks. The markdown body is rendered by
// cmarker; cover, counsel, authorities, signature and certificates come from the YAML frontmatter of
// usage/INPUT-reply-brief.md.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"          // MRAP 20(a)(4)(B) (MA-FORM-002): proportionally spaced face
#let type-size = 14pt                         // MRAP 20(a)(4)(B) (MA-FORM-002): 14 point or larger, footnotes included
#let body-leading = 1.6em                    // MRAP 20(a)(4)(C) (MA-FORM-004): double-spaced, not more than 3 lines per inch
                                              //   and not more than 27 lines per page; a line pitch of about 25 pt at 14 pt
#let single-leading = 0.46em                   // MRAP 20(a)(4)(C): single-spaced (not more than 6 lines per inch): a line pitch of about 16 pt at 14 pt
#let para-gap = 1.6em                       // space between paragraphs so that a paragraph break keeps the double-spaced pitch (style)
#let para-indent = 0.5in                      // first-line indent (style choice)
#let page-margin = 1in                        // MRAP 20(a)(4)(A) (MA-FORM-003): top, bottom, left and right at least 1 inch
#let cover-fill = rgb("#D9D9D9")              // MRAP 20(a)(6)(A) (MA-COVER-004): a reply brief cover is gray
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mass-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = align(center)[
  #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  #for n in side.at("names") [ #inl(n) \ ]
  #side.at("designation")
]

/// One counsel group: its lines, single-spaced.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0em, first-line-indent: 0pt)
  for l in g.at("lines") [ #inl(l) \ ]
}

// ---------------------------------------------------------------------------
// Cover (MA-COVER-001 to 003; MRAP 20(a)(6)(B)). The cover is paginated as page 1 (MA-COVER-002) but
// carries no printed number; the body pages print their number from 2 on, in the bottom margin.
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0em, first-line-indent: 0pt)
  align(center)[
    #for l in need(meta, "court") [ #text(weight: "bold")[#l] \ ]
    #v(0.6em)
    #need(meta, "docket")
    #v(0.5em)
    #line(length: 30%, stroke: 0.5pt)
    #v(0.5em)
    #for (i, side) in need(meta, "case_title").enumerate() [
      #if i > 0 [ #v(0.4em) v. #v(0.4em) ]
      #caption-side(side)
    ]
    #v(0.5em)
    #line(length: 30%, stroke: 0.5pt)
    #v(0.6em)
    #text(weight: "bold")[#need(meta, "title")]
    #v(0.6em)
    #line(length: 30%, stroke: 0.5pt)
  ]
  v(1.5em)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.4in,
    row-gutter: 0.8em,
    ..need(meta, "counsel").map(g => counsel-group(g)),
  )
}

// ---------------------------------------------------------------------------
// Table of contents (MRAP 16(a)(2)) and table of authorities (MRAP 16(a)(3)).
// A citation is marked in the body as a Markdown link to toa:<key>; the link text is the citation as
// printed. The authority list in frontmatter gives the entries; pages come from the rendered body.
// ---------------------------------------------------------------------------

#let toc-page() = {
  align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
  v(1em)
  outline(title: none, depth: toc-depth, indent: 2em)
}

#let toa-page(meta) = {
  set par(leading: single-leading, spacing: 0em, first-line-indent: 0pt)
  align(center)[#text(weight: "bold")[TABLE OF AUTHORITIES]]
  v(1em)
  context {
    let cites = query(<toa-cite>)
    for (cat, title) in (
      ("cases", "Cases"),
      ("statutes", "Statutes"),
      ("rules", "Rules"),
      ("other", "Other Authorities"),
    ) {
      let items = meta.at("authorities", default: ()).filter(a => a.at("category") == cat)
      if items.len() > 0 {
        block(sticky: true)[#text(weight: "bold")[#title]]
        v(0.4em)
        for a in items {
          let ps = cites.filter(c => c.value == a.at("key")).map(c => c.location().page()).dedup()
          let pg = if ps.len() == 0 { "NOT CITED" } else if ps.len() > 5 { "passim" } else { ps.map(str).join(", ") }
          grid(
            columns: (1fr, auto),
            column-gutter: 0.3in,
            block(inl(a.at("text"))),
            align(top + right)[#pg],
          )
          v(0.5em)
        }
        v(0.6em)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (MA-SIG-001; MRAP 16(a)(12)): printed and signed names, BBO numbers, addresses,
// telephone, office, and the date of signing. Two blocks per row.
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: 0em, first-line-indent: 0pt)
    #v(body-leading)
    Respectfully,
    #v(body-leading)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.4in,
      row-gutter: 1.6em,
      ..sig.map(b => [
        #if "signer" in b [ #text[/s/ #b.at("signer")] \ #v(0.6em) ]
        #for l in b.at("lines") [ #inl(l) \ ]
      ]),
    )
    #v(body-leading)
    #need(meta, "date")
  ]
}

// ---------------------------------------------------------------------------
// Certificates (MA-CERT-001 compliance, MA-CERT-002 service; MRAP 16(k), 13(e), 16(a)(14)-(15)).
// Each certificate carries the filer's text; the template supplies the heading and the signature line.
// ---------------------------------------------------------------------------

#let certificate(c) = block(breakable: true)[
  #set par(leading: body-leading, spacing: para-gap, first-line-indent: para-indent)
  #v(1.5em)
  #align(center)[#text(weight: "bold")[#c.at("heading")]]
  #v(body-leading)
  #inl(c.at("text"))
  #if "signer" in c [
    #v(1.2em)
    #set par(leading: single-leading, spacing: 0em, first-line-indent: 0pt)
    #block(width: 3.2in)[
      #if "date" in c [ Dated: #c.at("date") \ #v(0.6em) ]
      #text[/s/ #c.at("signer")] \
      #for l in c.at("lines", default: ()) [ #inl(l) \ ]
    ]
  ]
]

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mass-reply-brief(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  set page(paper: "us-letter", margin: page-margin, numbering: none, fill: cover-fill)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-gap, first-line-indent: para-indent)

  // Headings: level 1 centred bold (INTRODUCTION, ARGUMENT, CONCLUSION); level 2 and 3 bold, single-spaced
  // with a hanging indent for the heading numbers typed by the author (MRAP 20(a)(4)(C) allows single spacing).
  show heading.where(level: 1): it => {
    v(body-leading)
    block(sticky: true, width: 100%, align(center, text(weight: "bold", it.body)))
    v(body-leading)
  }
  show heading.where(level: 2): it => {
    v(body-leading)
    block(sticky: true, width: 100%, par(
      leading: single-leading, spacing: 0em, first-line-indent: 0pt, hanging-indent: 0.5in,
      text(weight: "bold", it.body),
    ))
    v(body-leading)
  }
  show heading.where(level: 3): it => {
    v(body-leading)
    block(sticky: true, width: 100%, par(
      leading: single-leading, spacing: 0em, first-line-indent: 0pt, hanging-indent: 0.5in,
      text(weight: "bold", it.body),
    ))
    v(body-leading)
  }

  // Block quotations are indented on both sides and single-spaced (MA-FORM-004).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: body-leading)[
    #set par(leading: single-leading, spacing: 0.7em, first-line-indent: 0pt)
    #it.body
  ]

  // Footnotes keep the 14-point size (MA-FORM-002) and are single-spaced (MA-FORM-004).
  // bottom-edge keeps the descenders of the last footnote line inside the 1 in bottom margin (MRAP 20(a)(4)(A), MA-FORM-003).
  show footnote.entry: set text(size: type-size, bottom-edge: -4pt)
  show footnote.entry: set par(leading: single-leading, spacing: 0.5em, first-line-indent: 0pt)

  // A toa: link keeps its text and records one citation for the table of authorities.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-cite>]
    } else {
      it.body
    }
  }

  // Cover: page 1, no printed number, gray (MA-COVER-004).
  cover(meta)
  pagebreak()

  // Body pages are numbered in the bottom margin, consecutively from the cover (MA-FORM-005).
  set page(numbering: "1", fill: none)
  if meta.at("toc", default: true) {
    toc-page()
    if "authorities" in meta {
      pagebreak()
      toa-page(meta)
    }
    pagebreak()
  }

  // Body: the reply (MRAP 16(c)): argument, conclusion.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Signature block, then the certificates in MRAP 16(a)(14)-(15) order.
  signature(meta)
  let certs = meta.at("certificates", default: ())
  if certs.len() > 0 { pagebreak(weak: true) }
  for c in certs { certificate(c) }
}
