// Alabama Court of Civil Appeals (alacivapp): appellant's brief (opening brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Alabama Rules of Appellate Procedure, Rules 28 and 32, see ../../rules.md). No
// case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"       // ARAP 32(a)(7): Century Schoolbook 14 point; TeX Gyre Schola is the vendored clone (docs/FONTS.md).
#let type-size = 14pt                      // ARAP 32(a)(7): 14 point, footnotes included.
#let body-leading = 1.2em                  // ARAP 32(a)(7): double spacing of the text.
#let single-leading = 0.45em               // ARAP 32(a)(7): quotations, headings, footnotes and captions may be single-spaced.
#let page-margin = 1in                     // ARAP 32(a)(6): margins at least one inch on all four sides.
#let page-margin-right = 1in + 1pt         // Justified lines overhang the right frame edge by up to ~3 pt (glyph advance); 1 pt more keeps the ink inside the one-inch margin.
#let page-margin-sides = (top: page-margin, bottom: page-margin, left: page-margin, right: page-margin-right)
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alacivapp-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("alacivapp-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block. ARAP 32 and 28: "s/" and the typed name, then the office and
/// contact lines beneath each signer.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body. A show rule on that string drops a marker after each occurrence;
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<alacivapp-toa>]

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
  let pages = query(<alacivapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(columns: (1fr, auto), column-gutter: 0.5em, inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
      ]
    }
  }
}

/// Words counted for the certificate of compliance (ARAP 32(c)): from the statement of the case
/// through the conclusion, footnotes and quotations included; the cover, oral-argument statement,
/// tables, jurisdiction statement, signature and certificates are excluded.
#let counted-words(body) = {
  let start = body.position("# Statement of the Case")
  let text = if start == none { body } else { body.slice(start) }
  let words = text.split(regex("\\s+")).filter(w => w.len() > 0)
  words.filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let alacivapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // ARAP 28(j)(1) and the cover convention: every page numbered in Arabic numerals; the cover is page 1 and shows no number.
  set page(paper: "us-letter", margin: page-margin-sides, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // Footnote markers stay on the baseline: a raised marker on a page's first line rises into the top margin (DEF-FORM-002).
  set super(baseline: 0em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set heading(numbering: none)

  // Point numbering as the template supplies it (the body is typed without "I." or "A."):
  // level 2 = I, II; level 3 = A, B; level 4 = 1, 2.
  let roman = counter("point-roman")
  let alpha = counter("point-alpha")
  let arabic = counter("point-arabic")

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
    #roman.step()
    #alpha.update(0)
    #arabic.update(0)
    #text(weight: "bold", context numbering("I.", ..roman.get()) + h(0.5em) + it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
    #alpha.step()
    #arabic.update(0)
    #text(weight: "bold", context numbering("A.", ..alpha.get()) + h(0.5em) + it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
    #arabic.step()
    #text(weight: "bold", context numbering("1.", ..arabic.get()) + h(0.5em) + it.body)
  ]

  // Block quotations: indented, single-spaced (ARAP 32(a)(7) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: 14 point like the text, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center)[
      #if "case_number" in meta [ #text(weight: "bold")[No. #meta.case_number] \ #v(0.3in) ]
      #text(weight: "bold")[IN THE COURT OF CIVIL APPEALS OF ALABAMA]
    ]
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
      #if meta.at("oral_argument", default: false) [ \ #v(0.3in) #text(weight: "bold")[ORAL ARGUMENT REQUESTED] ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents (ARAP 28(a)(1)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (ARAP 28(a)(2)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature block (ARAP 28(a)(12)) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl("Dated: " + meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (ARAP 32(d)) ----
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Certificate of Compliance]
  par[
    I hereby certify that this brief complies with the style requirements and word limitations of Alabama Rule of Appellate Procedure 32.
  ]
  par[
    This document is submitted in Century Schoolbook font, size 14, and contains #counted-words(body) words.
  ]
  v(0.4em)
  signature-block(need(meta, "signature"), first-only: true)

  // ---- Certificate of service (ARAP 28(a)(13), 31(b)) ----
  if "service" in meta {
    let svc = meta.service
    heading(level: 1, outlined: true)[Certificate of Service]
    // Ragged right: each counsel entry is a short line, and justifying it spreads the words apart.
    for p in svc.at("paragraphs", default: ()) { par(justify: false, inl(p)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true)
  }
}
