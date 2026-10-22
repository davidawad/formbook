// Appellate Court of Maryland (formerly the Court of Special Appeals; mdctspecapp): amicus curiae brief.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Maryland Rules 1-301(c), 8-112, 8-503, 8-504, 8-511; Rules Orders ro215, ro221, ro223, ro227; the
// Supreme Court administrative order on approved fonts, Sept. 27, 2023; see ../../rules.md). No
// case-specific text, no coordinates measured off any filed brief, no forced line breaks. The markdown
// body is rendered by cmarker; the cover, caption, authorities, signature and certificates come from the
// YAML frontmatter of the sample (usage/INPUT-amicus-brief.md).

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 8-112(c)(1) and the approved-font order (Sept. 27, 2023, para. 3): Times New Roman is on the list; Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 13pt                      // Rule 8-112(c)(1): proportionally spaced type in text and footnotes not smaller than 13 point.
#let body-leading = 1.15em                 // Rule 8-112(c)(2): double spacing. Typst adds this gap to the natural line of the face (about 1.1 em), so the pitch is about twice the single line.
#let single-leading = 0.2em                // Rule 8-112(c)(2) exclusions: headings, indented quotations, footnotes and signature blocks may be single-spaced.
#let page-margin = 1in                     // Rule 1-301(c) (Rules Order ro223): margins of not less than one inch on every side.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdctspecapp-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mdctspecapp-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption block: the names centred, then the designation (if any) in italics.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #if side.at("designation", default: "") != "" [ #emph(side.designation) ]
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block. "/s/" and the typed name are the signature (MDEC e-filing).
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
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
/// the authority in the body and footnotes (for example the case name as written). A show rule on
/// that string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<mdctspecapp-toa>]

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
  let pages = query(<mdctspecapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.5em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false,
        // The page reference keeps level with the entry's last line, after the leaders (DEF-TOC-001).
        leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
          hang: 1.5em, dot-gap: 2pt, lead-gap: 0.25em, gutter: 4pt))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mdctspecapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // levels 2 and 3 are argument headings (bold, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same 13 point size as the text, single-spaced. Citations in footnotes count toward the table of authorities.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (unnumbered): court, term, docket number, caption, title, counsel ----
  set page(numbering: none)
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold", upper(inl(need(meta, "court"))))
      #v(0.3in)
      #if "sept_term" in meta [ #inl(meta.sept_term) \ #v(0.2in) ]
      #text(weight: "bold")[No. #need(meta, "case_number")]
      #v(0.2in)
      #line(length: 100%)
      #v(0.2in)
    ]
    #for p in need(meta, "caption") { caption-side(p); v(0.2in) }
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #for l in meta.at("appeal_from", default: ()) [ #inl(l) \ ]
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Front matter: table of contents and table of authorities (roman numbers, from i after the cover) ----
  counter(page).update(1)
  set page(numbering: "i", number-align: center + bottom)
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: arabic numbers from 1 ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature block (Rule 8-504(a)(9), the signature follows the body) ----
  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, [Date: #inl(meta.date)]) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certification of word count and compliance with Rule 8-112 (Rule 8-504(a)(9)(A)) ----
  v(0.6in)
  block(width: 100%, breakable: false)[
    #align(center, text(weight: "bold", "CERTIFICATION OF WORD COUNT AND COMPLIANCE WITH RULE 8-112"))
    #v(0.5em)
    #set par(first-line-indent: 0pt, hanging-indent: 0.4in)
    1.#h(0.1in) This brief contains #if "word_count" in meta [#meta.word_count] else [\_\_\_\_] words, excluding the parts of the brief exempted from the word count by Rule 8-503.
    #v(0.3em)
    2.#h(0.1in) This brief complies with the font, spacing, and type size requirements stated in Rule 8-112.
    #v(0.6em)
    #signature-block(need(meta, "signature"), first-only: true)
  ]

  // ---- Certificate of service (Rule 1-323) ----
  if "service" in meta {
    let svc = meta.service
    v(0.6in)
    block(width: 100%, breakable: false)[
      #align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      #v(0.5em)
      #for p in svc.at("paragraphs", default: ()) { par(first-line-indent: (amount: para-indent, all: true), inl(p)) }
    ]
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    block(width: 100%, breakable: false)[
      #if "closing" in svc { par(first-line-indent: (amount: para-indent, all: true), inl(svc.closing)) }
      #v(0.4em)
      #signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
    ]
  }
}
