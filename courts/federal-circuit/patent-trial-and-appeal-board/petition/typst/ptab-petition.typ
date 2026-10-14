// U.S. Patent and Trademark Office, Patent Trial and Appeal Board: petition for inter partes review.
//
// Rule-driven and content-agnostic. Requirement IDs (PTAB-PET-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed petition, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"     // PTAB-PET-FORM-002: 14-point Times New Roman proportional font. Vendored metric-compatible stand-in (README, gap 1).
#let type-size = 14pt                      // PTAB-PET-FORM-002: footnotes and headers too (no exception).
#let double-leading = 1.64em               // PTAB-PET-FORM-003: double spacing, about 32 pt pitch for 14-point Times (calibrated, see README).
#let single-leading = 0.5em                // single spacing, about 16 pt pitch for 14-point Times (headings, TOC, certificates, footnotes).
#let quote-leading = 1.07em                // PTAB-PET-FORM-003: block quotations 1.5 spaced, about 24 pt pitch.
#let page-margin = 1in                     // PTAB-PET-FORM-004: at least 1 inch (2.5 cm) on all sides.
#let para-indent = 0.5in
#let petition-word-limit = 14000           // PTAB-PET-LEN-001: 37 C.F.R. 42.24(a)(1)(i).
#let toc-depth = 2

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, smart-punctuation: true, raw-typst: false)

/// Heading numbers: I. / A. / 1. / a. (a convention of the form, not a rule).
#let heading-number(..nums) = {
  let n = nums.pos()
  if n.len() == 1 { numbering("I.", n.at(0)) }
  else if n.len() == 2 { numbering("A.", n.at(1)) }
  else if n.len() == 3 { numbering("1.", n.at(2)) }
  else { numbering("a.", n.at(3)) }
}

#let need(meta, key) = {
  if key not in meta { panic("ptab-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Cover (not numbered)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  set block(spacing: 0pt)
  align(center)[
    UNITED STATES PATENT AND TRADEMARK OFFICE

    BEFORE THE PATENT TRIAL AND APPEAL BOARD
  ]
  v(2.4em)
  align(center)[#text(weight: "bold")[#inl(need(meta, "petitioner").at("name"))]]
  align(right)[#need(meta, "petitioner").at("role")]
  v(1.2em)
  align(center)[v.]
  v(1.2em)
  align(center)[#text(weight: "bold")[#inl(need(meta, "patent-owner").at("name"))]]
  align(right)[#need(meta, "patent-owner").at("role")]
  v(2.4em)
  align(center)[
    #need(meta, "patent-number")

    #need(meta, "patent-title")

    #v(0.6em)
    #need(meta, "case-number")
  ]
  v(2.4em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
}

// ---------------------------------------------------------------------------
// Signature block and certificates (PTAB-PET-FORM-008, -009)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(leading: single-leading, first-line-indent: 0pt)
  block(width: 100%, breakable: false, above: 1.5em)[
    #if "date" in meta [Dated: #meta.date]
    #v(1.2em)
    #align(right)[
      #block(width: 3.4in)[
        /s/ #sig.signer \
        #sig.signer-name (Reg. No. #sig.reg-no)
        #for line in sig.at("lines", default: ()) [ \ #line]
      ]
    ]
  ]
}

/// 10543 -> "10,543".
#let thousands(n) = {
  let s = str(n)
  let groups = ()
  while s.len() > 3 {
    groups.insert(0, s.slice(s.len() - 3))
    s = s.slice(0, s.len() - 3)
  }
  groups.insert(0, s)
  groups.join(",")
}

#let certificate-of-word-count(meta) = {
  let words = need(meta, "word-count")
  if words > petition-word-limit {
    panic("ptab-petition: word count " + str(words) + " exceeds the " + str(petition-word-limit) + "-word limit (42.24(a)(1)(i))")
  }
  pagebreak(weak: true)
  align(center)[#text(weight: "bold")[CERTIFICATION UNDER 37 C.F.R. § 42.24]]
  v(1em)
  block(breakable: false)[
    #set par(leading: double-leading, first-line-indent: para-indent)
    Under the provisions of 37 C.F.R. § 42.24, the undersigned hereby certifies that the word count for the foregoing Petition for inter partes review (excluding the table of contents, table of authorities, mandatory notices, certificate of service or word count, and appendix of exhibits or claim listing) totals #thousands(words) words, which is within the word limit allowed under 37 C.F.R. § 42.24(a)(i).
  ]
  signature-block(meta)
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  pagebreak(weak: true)
  align(center)[#text(weight: "bold")[CERTIFICATE OF SERVICE]]
  v(1em)
  block(breakable: false)[
    #set par(leading: double-leading, first-line-indent: para-indent)
    Pursuant to 37 C.F.R. §§ 42.6(e) and 42.105(a), the undersigned hereby certifies service on the Patent Owner of a copy of this Petition and its respective exhibits, by #svc.manner, on the following at the addresses shown:
  ]
  set par(leading: single-leading, first-line-indent: 0pt)
  for party in svc.recipients [
    #v(0.8em)
    #block(breakable: false)[
      #party.name \
      #for line in party.lines [#line \ ]
    ]
  ]
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// The petition
// ---------------------------------------------------------------------------

#let petition(meta, body) = {
  // Page setup: letter, 1-inch margins, 14-point Times New Roman everywhere.
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double-leading, first-line-indent: para-indent, justify: false)
  set block(spacing: 0pt)
  // Items are spaced like double-spaced lines; a zero gap lets an item's last line run into the next.
  set list(indent: 0.5in, body-indent: 0.5in, spacing: double-leading)
  set enum(indent: 0.5in, body-indent: 0.5in, spacing: double-leading)
  show list: set block(spacing: double-leading)
  show enum: set block(spacing: double-leading)
  set heading(numbering: heading-number)

  // Headings: level 1 centered and in capitals; levels 2 and 3 flush left, bold.
  show heading.where(level: 1): it => block(above: 1.2em, below: 0.9em, sticky: true, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #set text(size: type-size)
    #align(center)[#text(weight: "bold")[
      #if it.numbering != none [#counter(heading).display(it.numbering) ]
      #upper(it.body)
    ]]
  ]
  show heading.where(level: 2): it => block(above: 1em, below: 0.9em, sticky: true, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #set text(size: type-size)
    #text(weight: "bold")[
      #if it.numbering != none [#counter(heading).display(it.numbering)~]#it.body
    ]
  ]
  show heading.where(level: 3): it => block(above: 1em, below: 0.9em, sticky: true, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #set text(size: type-size)
    #text(weight: "bold", style: "italic")[
      #if it.numbering != none [#counter(heading).display(it.numbering)~]#it.body
    ]
  ]

  // Block quotations: indented from both margins, 1.5 spaced (42.6(a)(2)(iii)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.1em)[
    #set par(leading: quote-leading, first-line-indent: 0pt, justify: false)
    #it.body
  ]

  // Footnotes: 14-point, single spaced.
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Cover: no page number, no header.
  cover(meta)
  pagebreak()

  // Table of contents, roman page numbers.
  set page(numbering: "i")
  counter(page).update(1)
  align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
  v(1em)
  // Scoped: the single-spaced contents must not leak into the double-spaced body.
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    outline(title: none, depth: toc-depth, indent: 0.5in)
  }
  pagebreak()

  // Body: arabic page numbers from 1, running header naming the patent.
  set page(
    numbering: "1",
    header: align(right)[Petition for Inter Partes Review of #need(meta, "patent-number")],
  )
  counter(page).update(1)
  counter(heading).update(0)
  // The last paragraph of the body (the conclusion) is kept on the same page as the signature block,
  // so the signature never stands alone on a page.
  let paragraphs = body.trim().split(regex("\n\\s*\n"))
  let last = paragraphs.last()
  cmarker.render(paragraphs.slice(0, -1).join("\n\n"), smart-punctuation: true, raw-typst: false)
  block(breakable: false)[
    #cmarker.render(last, smart-punctuation: true, raw-typst: false)
    #signature-block(meta)
  ]

  // Then the two certificates.
  certificate-of-word-count(meta)
  certificate-of-service(meta)
}
