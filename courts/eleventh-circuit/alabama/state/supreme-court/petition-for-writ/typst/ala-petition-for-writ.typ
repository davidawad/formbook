// Supreme Court of Alabama (ala): petition for an extraordinary writ filed in the Supreme Court, ARAP 21(d), 32(b)(3); cover white.
// Cover stock is red (ARAP 28(d)); the PDF shows the cover text on white, as filed electronically.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited
// next to it (Alabama Rules of Appellate Procedure, Rules 21, 27, 28, 29, 32, 39, 52 and 56; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"       // ARAP 32(a)(7) names Century Schoolbook; TeX Gyre Schola is its Century Schoolbook clone (docs/FONTS.md).
#let type-size = 14pt                      // ARAP 32(a)(7): Century Schoolbook 14, footnotes included.
#let body-leading = 1.2em                  // ARAP 32(a)(6): double-spaced text (baseline pitch about twice the single leading below).
#let single-leading = 0.45em               // ARAP 32(a)(6) excludes headings, footnotes and long quotations: single-spaced.
#let page-margin = (top: 1.05in, bottom: 1in, left: 1in, right: 1.1in)   // ARAP 32(a)(6): at least one inch on all four sides. Top and right are 0.05 in and 0.1 in deeper: footnote marks rise about 4 pt above the first line, and justified glyph boxes overhang the right edge by up to 3 pt, and the check counts both.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature and counsel blocks start right of centre.
#let court-name = "IN THE SUPREME COURT OF ALABAMA"   // ARAP 28(d)(2): the name of the appellate court.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ala-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ala-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Heading numbers for argument points: level 2 "I.", level 3 "A.", level 4 "1.", level 5 "a.".
/// The level-1 section headings are unnumbered.
#let heading-number(..nums) = {
  let v = nums.pos()
  let k = v.len()
  if k == 2 { numbering("I.", v.at(1)) }
  else if k == 3 { numbering("A.", v.at(2)) }
  else if k == 4 { numbering("1.", v.at(3)) }
  else if k == 5 { numbering("a.", v.at(4)) }
  else { "" }
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(inl(side.designation))
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(inl(n)) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block. The "s/" form is ARAP-neutral; the typed name sits under the signature line.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)] \
    #inl(sig.signer)
    #for l in sig.at("lines", default: ()) [ \ #inl(l) ]
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. "150 So. 3d"). A show rule on that string drops a marker after
/// each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<ala-toa>]

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
  let pages = query(<ala-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true, numbering: none)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        // The page column is auto-width, so a page list never wraps off the entry; the citation
        // wraps in the left column, and its leaders end at the page column.
        #grid(columns: (1fr, auto), column-gutter: 4pt,
          [#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])],
          align(bottom, if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }),
        )
      ]
    }
  }
}

/// Words that the filer's certificate of compliance counts: from the Statement of the Case through
/// the Conclusion (ARAP 28(j)(1)). Markup is stripped first (citation links, footnote marks).
#let count-words(body) = {
  let parts = ("\n" + body).split("\n# ")
  let from = parts.position(p => lower(p.split("\n").first()).starts-with("statement of the case"))
  let text = if from == none { if parts.len() > 1 { "" } else { body } } else { parts.slice(from).join("\n# ") }
  let t = text.replace(regex("\\(toa:[^)]*\\)"), "").replace(regex("\\[\\^[^\\]]*\\]"), "")
  t.split(regex("\\s+")).filter(w => w.match(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ala-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // ARAP 28(j)(1): pages numbered in Arabic numerals from the cover; the cover shows no number.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set heading(numbering: heading-number)

  // Level 1: a section, centred, bold, capitals. Level 2-5: argument points, numbered automatically.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]

  // Block quotations: indented, single-spaced (ARAP 32(a)(6)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: at the text size and single-spaced (ARAP 32(a)(6)-(7)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (ARAP 28(d)) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center)[
      #text(weight: "bold")[No. #need(meta, "case_number")] \
      #v(0.2in)
      #text(weight: "bold")[#court-name]
    ]
    #v(0.3in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #if meta.caption.len() > 1 [ #align(center)[v.] ]
    #v(0.2in)
    #if meta.caption.len() > 1 [ #caption-side(meta.caption.at(1)) ]
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

  // ---- Statement regarding oral argument: the first section, printed before the TOC (ARAP 28(a)(1)) ----
  let parts = ("\n" + body).split("\n# ")
  let first-section = if parts.len() > 1 { "# " + parts.at(1) } else { "" }
  let rest = if parts.len() > 2 { "\n# " + parts.slice(2).join("\n# ") } else { "" }
  let is-oral = lower(parts.at(1, default: "").split("\n").first()).starts-with("statement regarding oral argument")
  if is-oral {
    page(cmarker.render(first-section, raw-typst: false, smart-punctuation: true))
  }
  let main-body = if is-oral { rest } else { "\n" + body }

  // ---- Table of contents (ARAP 28(a)(2)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (ARAP 28(a)(4)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: pages begin with the Statement of Jurisdiction (or the first section after the TOA) ----
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render(main-body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block, date (ARAP 28(a): after the conclusion) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (ARAP 28(a)(12), 32(d)) ----
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Certificate of Compliance]
  let words = count-words(body)
  par[I hereby certify that this petition complies with the form and word limitations of Alabama Rules of Appellate Procedure 21(d) and 32(b)(3). This document is submitted in Century Schoolbook font, size 14, and contains #words words.]
  v(0.4em)
  signature-block(need(meta, "signature"))

  // ---- Certificate of service (ARAP 28(a)(13), 31(b)) ----
  // Kept on one page with its signature block (ARAP 21(a)(1): proof of service on the respondent and all parties).
  block(width: 100%, breakable: false)[
    #heading(level: 1, numbering: none)[Certificate of Service]
    #par[I hereby certify that I electronically filed the foregoing with the Court using the Alabama Appeals e-File system, which will send notification of such filing to all counsel of record, and that a copy has been served on each party to the proceeding below, as Alabama Rules of Appellate Procedure 21(a)(1) requires.]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
