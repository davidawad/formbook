// Nevada Supreme Court brief (appellant's opening brief and the same layout for the answering and reply briefs):
// disclosure statement, cover, table of contents, table of authorities, body, certificate of compliance,
// signature block, certificate of service. Content-agnostic: every number is a named parameter below and traces to
// the NRAP text in ../../rules.md (IDs in the comments). No coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // NEV-FORM-004: proportionally spaced face, 14 pt or larger. Liberation Serif is the metric-compatible substitute (docs/FONTS.md).
#let typeface-name = "Times New Roman"                       // Named in the certificate of compliance (NEV-CERT-001).
#let type-size = 14pt                                        // NEV-FORM-004 (NRAP 32(a)(5)(A)); the court-level eval.yaml sets the same 14 pt.
#let body-leading = 1.65em                                   // NEV-FORM-003: double spaced. About 32 pt baseline pitch at 14 pt.
#let single-leading = 0.45em                                 // NEV-FORM-003 excludes quotations over two lines, headings and footnotes.
#let page-margin = (top: 1in, bottom: 1.1in, left: 1in, right: 1in)  // NEV-FORM-002: at least 1 in on all four sides. The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                                      // Signature block starts right of centre (style).
#let cover-column = 3.0in                                    // NEV-COVER-002: the caption stays left of the file-stamp area (upper right quadrant).

// NEV-CERT-001 wording. The number of words is the one the filer's count gives (NRAP 32(a)(7)).
#let compliance-text(n) = (
  [I hereby certify that this brief complies with the formatting requirements of NRAP 32(a)(4), the typeface requirements of NRAP 32(a)(5), and the type style requirements of NRAP 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using #typeface-name in 14-point type.],
  [I further certify that this brief complies with the page- or type-volume limitations of NRAP 32(a)(7) because, excluding the parts of the brief exempted by NRAP 32(a)(7)(C), it contains #n words.],
  [Finally, I hereby certify that I have read this appellate brief, and to the best of my knowledge, information, and belief, it is not frivolous or interposed for any improper purpose. I further certify that this brief complies with all applicable Nevada Rules of Appellate Procedure, in particular NRAP 28(e)(1), which requires every assertion in the brief regarding matters in the record to be supported by a reference to the page and volume number, if any, of the transcript or appendix where the matter relied on is to be found. I understand that I may be subject to sanctions in the event that the accompanying brief is not in conformity with the requirements of the Nevada Rules of Appellate Procedure.],
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nev-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nev-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Page numbers (NEV-FORM-006): cover unnumbered; pages before the statement of the case in lowercase
// Roman numerals; from the statement of the case on, Arabic numerals starting at 1.
// The statement of the case is the level-1 heading named by frontmatter `arabic_from`.
// ---------------------------------------------------------------------------

#let arabic-marker-label = <nev-arabic>
#let toa-label = <nev-toa>

/// Physical page of the first Arabic-numbered page, or none when no heading marks it.
#let arabic-start() = {
  let marks = query(arabic-marker-label)
  if marks.len() == 0 { none } else { marks.first().location().page() }
}

/// Displayed label of a physical page, given the Arabic start page (or none).
#let page-label(pg, start) = {
  if pg == 1 { "" }
  else if start != none and pg >= start { numbering("1", pg - start + 1) }
  else { numbering("i", pg - 1) }
}

#let nev-page-number(pg, ..rest) = context page-label(pg, arabic-start())

// ---------------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------------

/// One caption side: names flush left, then the designation indented.
#let caption-side(side) = {
  set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  pad(left: 1.2in, emph(side.designation))
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signers of the signature block: "/s/" and the typed name, underlined, with the counsel lines below.
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
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
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
/// the table lists the displayed pages of the markers.
#let toa-marker(key) = [#metadata(key)<nev-toa>]

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
  let start = arabic-start()
  let pages = query(toa-label)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(pg => page-label(pg, start)).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

/// Certificate of compliance (NEV-CERT-001): the template wording, the filer's word count, the date and signature.
#let compliance-block(meta) = {
  heading(level: 1, outlined: false)[Certificate of Compliance]
  for p in compliance-text(need(meta, "word_count")) { par(first-line-indent: (amount: para-indent, all: true), p) }
  v(0.4em)
  if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
  v(0.4em)
  signature-block(need(meta, "signature"))
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nev-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // NEV-FORM-006: page numbers at the bottom; cover is page 1 and carries none.
  set page(paper: "us-letter", margin: page-margin, numbering: nev-page-number, number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
  show heading.where(level: 1): it => {
    // The statement of the case starts the Arabic page sequence (NEV-FORM-006).
    let mark = if "arabic_from" in meta and repr(it.body).contains(meta.arabic_from) { [#metadata("nev-arabic")<nev-arabic>] } else { [] }
    block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
      #mark
      #set text(size: type-size)
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold", upper(it.body)))
    ]
  }
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

  // Block quotations: indented, single-spaced (NEV-FORM-003).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size and face as the text (NEV-FORM-004), single-spaced (NEV-FORM-003).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (NEV-COVER-001, -002, -004) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF NEVADA])
    #v(0.5in)
    #grid(columns: (cover-column, 1fr), column-gutter: 0.2in,
      [
        #caption-side(meta.caption.at(0))
        #v(0.2em)
        #pad(left: 0.5in)[v.]
        #v(0.2em)
        #caption-side(meta.caption.at(1))
        #v(0.5in)
        #need(meta, "case_number")
        #if "proceeding" in meta [ \ #inl(meta.proceeding) ]
        #if "trial_court_case" in meta [ \ #inl(meta.trial_court_case) ]
      ],
      [],
    )
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      grid(columns: (1fr, 1fr), column-gutter: 0.4in, row-gutter: 0.6em,
        ..need(meta, "counsel").map(g => counsel-group(g)),
      )
    }
  ]

  // ---- Disclosure statement (NEV-ORDER-005), before the table of contents ----
  if "disclosure" in meta {
    let d = meta.disclosure
    page[
      #set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))
      #heading(level: 1, outlined: false)[#d.at("heading", default: "N.R.A.P. 26.1 Disclosure")]
      #for p in d.at("paragraphs", default: ()) { par(inl(p)) }
      #if "date" in d { par(inl(d.date)) }
      #v(0.4em)
      #signature-block(d.signature)
    ]
  }

  // ---- Table of contents ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (NEV-CERT-001, not counted toward length: NEV-CERT-003) ----
  pagebreak(weak: true)
  compliance-block(meta)

  // ---- Certificate of service ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#svc.at("heading", default: "Certificate of Service")]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    if "signature" in svc {
      v(0.4em)
      signature-block(svc.signature, first-only: svc.at("first_signer_only", default: true))
    }
  }
}
