// Massachusetts Appeals Court (massappct): brief of an appellant or appellee (opening and answering briefs).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to
// it (Massachusetts Rules of Appellate Procedure, Rules 16, 20 and 21, as posted on mass.gov;
// see ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no
// forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML
// frontmatter of the sample (fields listed in ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 14pt                      // MRAP 20 (a) (4) (B) (ii): proportionally spaced font of 14 point or larger, footnotes included.
#let body-leading = 1.65em                 // MRAP 20 (a) (4) (C): double-spaced (not more than 3 lines per vertical inch, 27 lines per page).
#let single-leading = 0.45em               // MRAP 20 (a) (4) (C): headings, footnotes, indented quotations and visual aids may be single-spaced.
#let page-margin = 1in                     // MRAP 20 (a) (4) (A): top, bottom, left and right margins at least 1 inch.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // style: the signature block and counsel block start right of centre.
#let court-name = "COMMONWEALTH OF MASSACHUSETTS"  // MRAP 20 (a) (6) (B) (i): name of the court (fixed for this court).
#let court-division = "Appeals Court"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("massappct-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("massappct-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
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

/// The signature block: an optional introduction (for example "Respectfully Submitted,"), the
/// firm, the signer with the typed name, then the lines beneath (address, telephone, e-mail).
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("intro", default: ()) [ #inl(l) \ ]
    #if "firm" in sig [ #v(0.6em) #strong(sig.firm) \ ]
    #for s in sig.signers [
      #v(1.2em)
      #underline[#inl(s.name)] \
      #for l in s.at("lines", default: ()) [ #inl(l) \ ]
    ]
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body. A show rule on that string drops a marker after each occurrence;
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<massappct-toa>]

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
  let pages = query(<massappct-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The page references sit in their own column aligned to the last line of the citation, so a long
      // citation can never push a page reference onto a line of its own.
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(
          columns: (1fr, auto),
          column-gutter: 0.25in,
          align: (left + top, right + bottom),
          inl(e.cite),
          if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let massappct-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // MRAP 20 (a) (4) (A): page numbers in the margin; the cover is page 1 and numbering runs to the last page.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (MRAP 20 (a) (4) (C) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same 14 point face as the text, single-spaced (MRAP 20 (a) (4) (B), (C)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (MRAP 20 (a) (6) (B)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[#court-name] \
      #court-division \
      #v(0.15in)
      #text(weight: "bold")[No. #need(meta, "case_number")]
    ]
    #v(0.15in)
    #caption-side(meta.caption.at(0))
    #v(0.1in)
    #align(center)[v.]
    #v(0.1in)
    #caption-side(meta.caption.at(1))
    #v(0.15in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #inl(need(meta, "lower_court"))
      #v(0.15in)
      #inl(need(meta, "date"))
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents (MRAP 16 (a) (3)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (MRAP 16 (a) (4)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: everything before the addendum sentinel ----
  let parts = body.split("\n# ADDENDUM\n")
  mark-authorities(meta, cmarker.render(parts.at(0), raw-typst: false, smart-punctuation: true))

  // ---- Signature block (MRAP 16 (a) (12)) ----
  v(0.4em)
  block(width: 100%, breakable: false, signature-block(need(meta, "signature")))

  // ---- Addendum (MRAP 16 (a) (13)): its own table of contents, then the documents ----
  if parts.len() > 1 {
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[Addendum]
    mark-authorities(meta, cmarker.render(parts.at(1), raw-typst: false, smart-punctuation: true))
  }

  // ---- Certificate of compliance (MRAP 16 (a) (14), 16 (k)) ----
  if "compliance" in meta {
    let c = meta.compliance
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[Certificate of Compliance]
    for p in c.paragraphs { par(inl(p)) }
    v(0.4em)
    signature-block(c.signature)
  }

  // ---- Certificate of service (MRAP 16 (a) (15), 13 (e)) ----
  if "service" in meta {
    let svc = meta.service
    v(1.2em)
    block(breakable: false)[
      #heading(level: 1, outlined: false)[Certificate of Service]
      #for p in svc.paragraphs { par(inl(p)) }
    ]
    v(0.4em)
    signature-block(svc.signature)
  }
}
