// Court of Appeals of the State of Washington, answering brief (washctapp-answering-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the Rules of Appellate Procedure (RAP)
// cited next to it, or to the court's eval.yaml for the type size. No coordinates measured off any filed brief,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// input (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // RAP 18.17(a)(2): 14-point serif equivalent to Times New Roman (WASHCTAPP-FORM-004). Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // RAP 18.17(a)(2): 14 point for all text, footnotes and block quotations (WASHCTAPP-FORM-004). Court eval.yaml: font.size_pt 14.
#let body-leading = 1.65em                 // RAP 18.17(a)(2): double spaced (WASHCTAPP-FORM-005).
#let single-leading = 0.45em               // Single spaced: footnotes, block quotations, headings, caption and counsel blocks (WASHCTAPP-FORM-005).
#let page-margin = (top: 1.5in, bottom: 1.6in, left: 2in, right: 1.5in)  // RAP 18.17(a)(1) (WASHCTAPP-FORM-002): 2 in left, 1.5 in right, top and bottom, on every page. The bottom is 0.1 in deeper so the page number stays inside the margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; the exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("washctapp-answering-brief: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("washctapp-answering-brief: missing required metadata field `" + key + "`") }
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

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines (bar number, address, phone, e-mail) follow.
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
/// the authority in the body (e.g. a party name or the reporter cite). A show rule on that
/// string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<washctapp-toa>]

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

/// Page label of a location as the page is numbered on the page itself (Roman in the front matter, Arabic after).
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

#let toa-pages(key) = context {
  let pages = query(<washctapp-toa>)
    .filter(m => m.value == key)
    .map(m => page-label(m.location()))
    .dedup()
  if pages.len() == 0 { [--] } else { pages.join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The cite wraps in its own column; the page references sit in a fixed column with leaders, so a
      // long cite never pushes the page references onto a line of their own.
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(columns: (1fr, 2.3in), column-gutter: 0.1in,
          inl(e.cite),
          [#box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }],
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let washctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // RAP 18.17: page numbers at the bottom. Front matter is Roman; the body is Arabic from the statement of the case.
  set page(paper: "us-letter", margin: page-margin, numbering: "i", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left). Plain roman type, emphasis only where a rule allows.
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
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (RAP 18.17(a)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size and typeface as the body (RAP 18.17(a)(2)), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (no page number; RAP 10.3(a)(1), RAP Form 5) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[COURT OF APPEALS OF THE STATE OF WASHINGTON] \
      #text(weight: "bold")[DIVISION #need(meta, "division")] \
      #v(0.3in)
      #text(weight: "bold")[NO. #need(meta, "case_number")]
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
      #if "trial_court_case" in meta [ \ #inl(meta.trial_court_case) ]
    ]
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
  // The Roman count starts with the first page after the cover.
  counter(page).update(1)

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

  // ---- Body, Arabic from 1 ----
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Word-count statement, date and signature block (RAP 18.17(b)): above the signature line ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: (amount: para-indent, all: true))[
      This document contains #need(meta, "word_count") words, excluding the parts of the document exempted from the word count by RAP 18.17.
    ]
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

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
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true))
  }
}
