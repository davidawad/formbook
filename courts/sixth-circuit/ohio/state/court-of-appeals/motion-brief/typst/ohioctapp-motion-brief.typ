// Ohio Court of Appeals: motion and supporting memorandum (motion-brief). Rule-driven and content-agnostic.
//
// Rules: ../../rules.md (Ohio Rules of Appellate Procedure, amended through July 1, 2026; read from the
// Internet Archive copy of the Supreme Court of Ohio PDF, see the court root usage/SOURCE.md and rules.md).
//   OHIOCTAPP-FORM-001..003: letter paper, margins of at least one inch at each side and 1 1/2 in top and
//     bottom combined, at least 12-point type (footnotes and captions included), double spacing except quoted matter.
//   OHIOCTAPP-CERT-002: caption shows the court, the title of the case, the case number and a descriptive title.
//   OHIOCTAPP-MOT-001: the motion states its grounds with particularity; the memorandum supports it.
//   OHIOCTAPP-CERT-001: the signature block. OHIOCTAPP-SVC-001: service on all other parties.
// Motions carry no App.R. word or page limit, so the template sets none. The motion and the memorandum each
// have their own caption and page numbering (pages restart at 1 for the memorandum, as in the filed example).
//
// Input (usage/INPUT-<id>.md): YAML frontmatter, then the motion body, then a line `* * *` alone, then the
// memorandum body. Nothing in this file is case-specific; no coordinates measured off an exemplar; no forced
// line breaks. Body text goes through cmarker (raw-typst: false, smart-punctuation: true).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // no face named by the rules; Times New Roman declared (docs/FONTS.md), Liberation Serif fallback
#let type-size = 12pt                   // OHIOCTAPP-FORM-002: at least twelve-point type, footnotes and captions included
#let body-leading = 1.6em              // OHIOCTAPP-FORM-003: double spaced (27.5 pt baseline pitch at 12 pt, Word's double spacing for Times New Roman)
#let single-leading = 0.45em            // quoted matter, caption, counsel, certificates, footnotes: single spaced (about 13.8 pt pitch at 12 pt)
#let margins = (top: 1in, bottom: 1in, x: 1in)  // OHIOCTAPP-FORM-001: at least 1 in at each side; top and bottom 1 in each (2 in combined, above the 1 1/2 in minimum)
#let para-indent = 0.5in
#let sig-indent = 3.25in
#let memo-marker = "\n* * *\n"          // separates the motion body from the memorandum body in the input

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ohioctapp-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohioctapp-motion-brief: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block for counsel, caption and certificates.
#let single(body) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  body
}

// ---------------------------------------------------------------------------
// Caption (court head, caption grid, title) for the motion and for the memorandum
// ---------------------------------------------------------------------------

#let court-head(meta) = align(center, single[
  #strong(need(meta, "court")) \
  #strong(need(meta, "district")) \
  #strong(need(meta, "county"))
])

#let party(p) = block(above: 0.5em, below: 0.5em, width: 100%, breakable: false, single[
  #inl(p.name)
  #if "role" in p and p.role != "" [ \ #box(width: 100%, align(right, pad(right: 0.15in, inl(p.role)))) ]
])

#let caption(meta) = {
  court-head(meta)
  v(1.2em)
  grid(
    columns: (3.3in, 1fr),
    column-gutter: 0.2in,
    block(width: 100%, stroke: (right: 0.75pt), inset: (right: 0.2in, bottom: 0.4em), {
      for p in need(meta, "parties") { party(p) }
      block(above: 0.5em, below: 0.5em, pad(left: 1.2in, single[v.]))
      for p in need(meta, "against") { party(p) }
    }),
    block(width: 100%, {
      single[Case No. #need(meta, "case_number")]
      v(0.9em)
      single(inl(need(meta, "lower_court")))
    }),
  )
}

#let title-block(t) = block(width: 85%, above: 1.2em, below: 1.2em, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (y: 0.5em), align(center, single(strong(inl(t)))))

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let counsel-block(b) = block(above: 0.7em, breakable: false, single[
  #for l in b.at("names", default: ()) [ #inl(l) \ ]
  #for l in b.at("lines", default: ()) [ #inl(l) \ ]
])

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let counsel = need(meta, "counsel")
  block(breakable: false, above: 1.2em, {
    par(first-line-indent: 0pt)[Respectfully submitted,]
    v(0.8em)
    single[#inl(sig.signer_line)]
    v(0.4em)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 0.2in,
      single[#for b in counsel.at("left", default: ()) { counsel-block(b) }],
      single[#for b in counsel.at("right", default: ()) { counsel-block(b) }],
    )
    if "note" in sig [ #v(0.6em) #single[#inl(sig.note)] ]
    v(0.8em)
    pad(left: sig-indent - 0.5in, single[#inl(sig.role)])
  })
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak(weak: true)
  align(center, strong[CERTIFICATE OF SERVICE])
  v(0.5em)
  par(first-line-indent: para-indent)[
    I hereby certify that on #inl(svc.date), the foregoing was electronically filed via the Court's e-filing system. I further certify that a copy of the foregoing was served by email upon the following:
  ]
  for r in svc.at("recipients", default: ()) {
    block(above: 0.6em, pad(left: 0.5in, single[#inl(r)]))
  }
  v(1.2em)
  block(breakable: false, pad(left: sig-indent - 0.5in, single[
    #inl(sig.signer_line) \
    #inl(sig.role)
  ]))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let ohioctapp-motion-brief(meta, body) = {
  set document(title: need(meta, "motion_title"))
  // Pages numbered in Arabic numerals at the bottom centre; the memorandum restarts at 1 (see below).
  set page(paper: "us-letter", margin: margins, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), width: 100%, above: 0.8em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }
  // Section headings: level 1 centred bold; level 2 and 3 bold with a hanging indent (the numerals are typed in the input);
  // level 4 underlined.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(weight: "bold", it.body))
  })
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 4): it => block(width: 100%, above: 0.8em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    underline(it.body)
  })

  // The motion: caption, title, body, signature block. Page numbers 1, 2, ...
  let parts = body.split(memo-marker)
  let motion-body = parts.at(0)
  let memo-body = if parts.len() > 1 { parts.at(1) } else { "" }

  caption(meta)
  title-block(need(meta, "motion_title"))
  cmarker.render(motion-body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)

  // The memorandum in support: its own caption, title and page numbering from 1.
  if memo-body != "" {
    pagebreak()
    counter(page).update(1)
    caption(meta)
    title-block(need(meta, "memorandum_title"))
    cmarker.render(memo-body, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
    certificate-of-service(meta)
  }
}
