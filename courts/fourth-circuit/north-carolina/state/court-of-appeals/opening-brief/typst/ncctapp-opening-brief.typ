// Court of Appeals of North Carolina (ncctapp): principal and other briefs, motions and petitions.
// This file is shared by the doc folders of this court; the doc type comes from the INPUT
// frontmatter (`brief_title`, `toc`, `authorities`, `compliance`, `service`).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it: North Carolina Rules of Appellate Procedure, sources and dates in ../../rules.md. No
// case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the INPUT.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 26(g)(1) requires a proportionally spaced serif face; Times is the standard serif (docs/FONTS.md).
#let type-size = 12pt                     // Rule 26(g)(1): printed matter no smaller than 12-point and no larger than 14-point. 12-point is the floor.
#let body-leading = 1.15em                // Double spacing of the body text (exemplars). Typst adds this gap to the natural line of the face (about 1.15 em): the line pitch is about 2 x single.
#let single-leading = 0.5em               // Single spacing (block quotations, headings, captions, footnotes, signature blocks).
#let page-margin = 1in                    // One-inch margins on all sides (exemplars; no retrieved rule states another).
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
  if m == none { panic("ncctapp-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ncctapp-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption: each party block is its names, then the designation at the right ("Defendant.").
#let caption-party(p) = {
  set par(leading: single-leading, spacing: 0.6em, first-line-indent: 0pt)
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    align: (left + horizon, right + horizon),
    [#for n in p.names [ #inl(n) \ ]],
    [#p.designation],
  )
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.6em)
}

/// Signature entry: "/s/ [typed name]" is the signature; counsel's bar number and address follow.
#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let list = if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
  if first-only { list = (list.first(),) }
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
    #if not first-only and "certification" in sig {
      v(0.8em)
      [#inl(sig.certification)]
    }
    #if not first-only and "cosigners" in sig {
      v(0.6em)
      for s in sig.cosigners {
        [#s.name \ ]
        for l in s.at("lines", default: ()) { [#inl(l) \ ] }
        v(0.6em)
      }
    }
    #if not first-only and "address" in sig {
      v(0.3em)
      for l in sig.address { [#inl(l) \ ] }
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (for example the case name). A show rule on that string drops a
/// marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<ncctapp-toa>]

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
  let pages = query(<ncctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.5em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, text(weight: "bold", upper(group.heading)))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ncctapp-brief(meta, body) = {
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
  // Footnotes: text size, single-spaced. Citations in footnotes count toward the table of authorities.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover: court, county, docket number, caption and title ----
  set page(numbering: none)
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [NO. #need(meta, "appellate_case_no")],
      [#need(meta, "district")],
    )
    #v(0.4in)
    #align(center)[
      #text(weight: "bold")[#need(meta, "court")]
      #v(0.3in)
      #for l in meta.at("appeal_from", default: ()) [ #inl(l) \ ]
    ]
    #v(0.3in)
    #for p in need(meta, "caption") { caption-party(p); v(0.3in) }
    #v(1fr)
    #align(center)[
      #box(width: 3.6in, [#repeat[\*]])
      #v(0.1in)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
      #v(0.1in)
      #box(width: 3.6in, [#repeat[\*]])
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in meta.at("counsel", default: ()) { counsel-group(g) }
      })
    }
  ]

  // ---- Front matter: index (table of contents) and table of authorities ----
  set page(numbering: "i")
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[INDEX])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
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

  // ---- Signature block (Rule 28(j); date line and signature as the filer supplies them) ----
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

  // ---- Certificate of compliance (Rule 28(j)): placed right before the certificate of service ----
  if "compliance" in meta {
    let cc = meta.compliance
    pagebreak(weak: true)
    align(center, text(weight: "bold", upper(cc.at("heading", default: "Certificate of Compliance"))))
    v(0.5em)
    par(inl(need(cc, "text")))
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true)
  }

  // ---- Certificate of service ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
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
      signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
    }
  }
}
