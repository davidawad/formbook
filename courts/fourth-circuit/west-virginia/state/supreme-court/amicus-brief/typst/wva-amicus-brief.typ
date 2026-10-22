// Supreme Court of Appeals of West Virginia (wva): amicus curiae briefs (RAP 30, form per RAP 38).
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it:
// the Rules of Appellate Procedure, sources and dates in ../../rules.md (WVA-FORM, WVA-COVER, WVA-CONT,
// WVA-LEN, WVA-AMI, WVA-CERT). No case-specific text, no coordinates measured off any filed brief,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML
// frontmatter of the INPUT (contract: ../README.md).
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // WVA-TPL-002: Times New Roman, Liberation Serif as its metric twin (RAP 38(a) names no face).
#let type-size = 12pt                     // WVA-FORM-003: text no smaller than 12-point proportionally spaced type.
#let note-size = 11pt                     // WVA-FORM-004: footnote text no smaller than 11-point proportionally spaced type.
#let body-leading = 1.15em                // WVA-FORM-002: double-spaced text. Times has a natural line of about 1.15 em, so this leading gives a double pitch.
#let single-leading = 0.5em               // WVA-FORM-002: single spacing for footnotes, indented quotations, headings, captions and signature blocks.
#let page-margin = 1in                    // WVA-FORM-005: margins no less than one inch on all sides.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                   // signature blocks start right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wva-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("wva-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption (WVA-COVER-001 (3)): each party block is centred: its names, then its designation in italics.
#let caption-party(p) = {
  set par(leading: single-leading, spacing: 0.6em, first-line-indent: 0pt)
  align(center)[
    #for n in p.names [ #inl(n) \ ]
    #if p.designation != "" [ #emph(inl(p.designation)) ]
  ]
}

/// Counsel group (WVA-COVER-001 (5)): the name, bar number and contact lines beneath it.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.6em)
}

/// Signature entry (WVA-CERT-001): "/s/ name" is the typographical signature; the bar number follows.
#let signer-entry(s) = {
  [/s/ #s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig) = {
  let list = need(sig, "signers")
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if "cosigners" in sig {
      v(0.6em)
      for s in sig.cosigners {
        [#s.name]
        for l in s.at("lines", default: ()) { linebreak() + inl(l) }
        v(0.6em)
      }
    }
    #if "address" in sig {
      v(0.3em)
      for l in sig.address { [#inl(l) \ ] }
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (for example the case name). A show rule on that string drops a
/// marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<wva-toa>]

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
  let pages = query(<wva-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let toa-entry(e) = {
  let pages = if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
  block(above: 0.9em, below: 0.9em, breakable: false)[
    #grid(
      columns: (1fr, auto),
      column-gutter: 0.1in,
      par(hanging-indent: 0.5in, first-line-indent: 0pt)[#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])],
      align(right + bottom, pages),
    )
  ]
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.3em)
  align(right, text(weight: "bold")[Page(s)])
  v(0.2em)
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, text(weight: "bold", group.heading))
    for e in group.entries { toa-entry(e) }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let wva-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are argument headings (bold, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: footnote size, single-spaced. Citations in footnotes count toward the table of authorities.
  show footnote.entry: it => {
    set text(size: note-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (WVA-COVER-001): court, docket number, caption, title, counsel ----
  set page(numbering: none)
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[#need(meta, "court")]
      #v(0.4in)
      #text(weight: "bold")[#need(meta, "appellate_case_no")]
      #v(0.1in)
      #align(center, line(length: 2.4in, stroke: 0.5pt))
    ]
    #v(0.3in)
    #for p in need(meta, "caption") { caption-party(p); v(0.3in) }
    #v(1fr)
    #align(center)[
      #align(center, line(length: 3.6in, stroke: 0.5pt))
      #v(0.1in)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
      #v(0.1in)
      #align(center, line(length: 3.6in, stroke: 0.5pt))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      for g in meta.at("counsel", default: ()) { counsel-group(g) }
    }
  ]

  // ---- Front matter: table of contents and table of authorities (roman page numbers) ----
  set page(numbering: "i")
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #show footnote: it => []
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: restart page numbering at 1 ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (WVA-CERT-001): the typographical signature and counsel's details ----
  v(0.4in)
  block(width: 100%, breakable: false)[
    #if "signature" in meta and "preamble" in meta.signature {
      par(first-line-indent: (amount: para-indent, all: true), inl(meta.signature.preamble))
    } else if "date" in meta {
      par(first-line-indent: (amount: para-indent, all: true), inl(meta.date))
    }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (WVA-CONT-010; RAP 37): no page number, no page limit ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    if svc.at("caption", default: false) {
      set par(leading: single-leading, first-line-indent: 0pt)
      align(center)[
        #text(weight: "bold")[#need(meta, "court")]
        #v(0.3in)
      ]
      for p in need(meta, "caption") { caption-party(p); v(0.3in) }
    }
    align(center, text(weight: "bold", upper(svc.at("heading", default: "Certificate of Service"))))
    v(0.5em)
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    if svc.at("signature", default: true) {
      v(0.4em)
      signature-block(need(meta, "signature"))
    }
  }
}
