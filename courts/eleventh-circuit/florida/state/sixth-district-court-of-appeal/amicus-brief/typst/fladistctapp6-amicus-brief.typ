// Sixth District Court of Appeal (fladistctapp6): computer-generated paper under Fla. R. App. P. 9.045.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (see ../../rules.md). No case-specific text, no coordinates measured off any filed paper, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"        // Arial (Fla. R. App. P. 9.045(b)); Liberation Sans is the metric-compatible Arial in fonts/liberation-sans (docs/FONTS.md).
#let type-size = 14pt                       // Fla. R. App. P. 9.045(b): Arial 14-point for computer-generated documents.
#let footnote-size = 14pt                   // Fla. R. App. P. 9.045(b): footnotes and quotations in the same size type as the body.
#let body-leading = 1.15em                  // Fla. R. App. P. 9.045(b): text double-spaced (set against the single line below).
#let single-leading = 0.45em                // Fla. R. App. P. 9.045(b): footnotes, quotations and headings may be single-spaced.
#let page-margin = 1in                      // Fla. R. Gen. Prac. & Jud. Admin. 2.520(a)(3): at least a 1-inch margin on all sides.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                     // signature block starts right of centre (style; exemplars do the same).
#let word-limit-cite = "Fla. R. App. P. 9.370(b)"   // see rules.md; "none" = no word limit, so no certificate of compliance.
#let doc-label = "brief"                    // the noun used in the certificate of compliance.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp6: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp6: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #inl(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block. Rule 9.045 leaves the form to the filer: "/s/" and the typed name,
/// then the attorney identification, address and e-mail.
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

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
/// authority in the body. A show rule on that string drops a marker after each occurrence; the table
/// lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<fladistctapp6-toa>]

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
  let pages = query(<fladistctapp6-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false, numbering: none)[Table of Authorities]
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

/// Heading numbering of the argument: level 2 = "I.", level 3 = "A.", level 4 = "1." (the template
/// numbers them; the markdown carries no numerals). Level 1 is an unnumbered section.
#let point-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 2 { numbering("I.", n.last()) }
  else if n.len() == 3 { numbering("A.", n.last()) }
  else if n.len() == 4 { numbering("1.", n.last()) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp6-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: point-numbering)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // levels 2-4 are numbered points and sub-points (bold, hanging). Headings are at least the body size
  // (Rule 9.045(b)).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold")[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(0.5in)#it.body]
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold")[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(0.5in)#it.body]
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(style: "italic")[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(0.5in)#it.body]
  ]

  // Block quotations: indented, single-spaced, same size as the body (Rule 9.045(b)).
  show quote.where(block: true): it => block(inset: (left: 1in, right: 1in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size as the body, single-spaced (Rule 9.045(b)).
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (page 1, not numbered; Fla. R. App. P. 9.210(a)(1)) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE DISTRICT COURT OF APPEAL] \
      #text(weight: "bold")[OF THE STATE OF FLORIDA] \
      #text(weight: "bold")[SIXTH DISTRICT]
      #v(0.3in)
      #text(weight: "bold")[CASE NO.: #need(meta, "case_number")]
    ]
    #v(0.3in)
    #{ let cap = need(meta, "caption"); caption-side(cap.at(0)); v(0.2in); align(center)[v.]; v(0.2in); caption-side(cap.at(1)) }
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #inl(need(meta, "lower_tribunal"))
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
      #if "filed_for" in meta [ \ #v(0.3em) #inl(meta.filed_for) ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents and table of authorities (roman numerals) ----
  set page(numbering: "i")
  counter(page).update(1)
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

  // ---- Body (Arabic numerals from the first page of the body) ----
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature block (after the conclusion) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (Rule 9.045(e) reference; Rule 9.420 not retrieved) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
  }

  // ---- Certificate of compliance: immediately after the certificate of service (Rule 9.045(e)).
  // Only a paper subject to a word limit has one. ----
  if word-limit-cite != none {
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[Certificate of Compliance]
    par(inl("I certify that this " + doc-label + " complies with the font and word count requirements of Fla. R. App. P. 9.045(b) and " + word-limit-cite + ". The certificate relies on the word count of the word-processing system used to prepare the " + doc-label + ", as Fla. R. App. P. 9.045(e) permits."))
    block(width: 100%, breakable: false)[
      #v(0.4em)
      #signature-block(need(meta, "signature"))
    ]
  }
}
