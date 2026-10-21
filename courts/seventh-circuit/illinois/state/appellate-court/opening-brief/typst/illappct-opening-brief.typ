// Appellate Court of Illinois (illappct): appellant's brief (opening brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it:
// Ill. S. Ct. R. 341 (a) form, (b) length, (c) certificate of compliance, (d) cover, (e) proof of
// service, (h) contents (see ../../rules.md). No case-specific text, no coordinates measured off a
// filed brief, no forced line breaks. The markdown body is rendered by cmarker; the metadata is the
// YAML frontmatter of the input (keys documented in ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rules 341 (a) name no face; house standard is Times New Roman (docs/FONTS.md).
#let type-size = 12pt                      // Rule 341 (a): 12-point or larger throughout, including quotations and footnotes.
#let body-leading = 1.15em                 // Rule 341 (a): double-spaced text. Pitch is about twice the single line of this face.
#let single-leading = 0.25em               // Rule 341 (a) exempts headings, quotations of two or more lines, and footnotes: single-spaced.
#let margin-left = 1.5in                   // Rule 341 (a): left margin at least 1 1/2 inch.
#let margin-other = 1in                    // Rule 341 (a): top, right and bottom margins at least 1 inch.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.0in                    // signature block starts right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("illappct-opening-brief: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("illappct-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: names (centred) and the party designation beneath.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  emph(inl(side.designation))
}

/// Counsel group: names (bold) then the lines beneath (cover and signature use the same shape).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block. Rule 341 (c): the signed certification is by counsel.
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

/// Points and authorities. Each entry carries `find`: a string that appears in every citation of the
/// authority in the body. A show rule on that string drops a marker after each occurrence; the table
/// lists the pages of those markers.
#let toa-marker(key) = [#metadata(key)<illappct-toa>]

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
  let pages = query(<illappct-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-list(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.6em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.6em, below: 0.6em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let illappct-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 341 (a): page numbers in the bottom margin; the cover is page 1.
  set page(
    paper: "us-letter",
    margin: (left: margin-left, right: margin-other, top: margin-other, bottom: margin-other),
    numbering: "1", number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body are typed by the filer (the numbering "I.", "A." is part of the text).
  // Level 1: a section, centred and capitalised. Levels 2 and 3: bold, hanging, single-spaced.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (Rule 341 (a)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 12 pt like the text (Rule 341 (a)), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the points and authorities
  }

  // ---- Cover (Rule 341 (d)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(right)[No. #need(meta, "case_number")]
    #v(0.2in)
    #align(center)[
      #text(weight: "bold")[#need(meta, "court")] \
      #text(weight: "bold")[#need(meta, "district")]
    ]
    #v(0.3in)
    #{
      let left = need(meta, "caption")
      let lines = left.map(s => s.names.len() + 1).sum()
      grid(
        columns: (1fr, 0.3in, 1fr),
        {
          for (i, side) in left.enumerate() {
            if i > 0 { v(0.9em) }
            caption-side(side)
          }
        },
        { for _ in range(lines) [ ) \ ] },
        {
          for l in need(meta, "trial_court") [ #inl(l) \ ]
          if "judge" in meta [ #v(0.4em) #inl(meta.judge) ]
        },
      )
    }
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
      #if meta.at("oral_argument", default: false) [ \ #v(0.5em) ORAL ARGUMENT REQUESTED ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
        if "phone" in meta [ #meta.phone ]
      })
    }
  ]

  // ---- Points and Authorities (Rule 341 (h) (1)): the headings, then the authorities with pages ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[POINTS AND AUTHORITIES])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.8em, below: 0.8em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
      #if "authorities" in meta [
        #v(0.8em)
        #align(center, text(weight: "bold")[Authorities])
        #authorities-list(meta)
      ]
    ]
  }

  // ---- Body (Rule 341 (h)) ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature block, after the Conclusion ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (Rule 341 (c)): the wording is the rule's; the length is the filer's ----
  pagebreak(weak: true)
  heading(level: 1)[Certificate of Compliance]
  par(first-line-indent: (amount: para-indent, all: true))[
    I certify that this brief conforms to the requirements of Rules 341(a) and (b). The length of this brief, excluding the pages or words contained in the Rule 341(d) cover, the Rule 341(h)(1) table of contents and statement of points and authorities, the Rule 341(c) certificate of compliance, the certificate of service, and those matters to be appended to the brief under Rule 342(a), is #inl(need(meta, "length_certificate")).
  ]
  v(0.4em)
  signature-block(need(meta, "signature"), first-only: true)

  // ---- Proof of service (Rule 341 (e)) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(first-line-indent: (amount: para-indent, all: true), inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(first-line-indent: (amount: para-indent, all: true), inl(svc.closing)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
  }
}
