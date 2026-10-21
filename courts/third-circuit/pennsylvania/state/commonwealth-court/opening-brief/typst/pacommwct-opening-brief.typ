// Commonwealth Court of Pennsylvania (pacommwct): brief of the appellant (opening brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Pennsylvania Rules of Appellate Procedure, Pa. Code Title 210, as shown on pacodeandbulletin.gov, current
// through 56 Pa.B. 5370; see ../../rules.md). No case-specific text, no coordinates measured off any filed
// brief, no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML
// frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Official Note to Pa.R.A.P. 124: Times New Roman is one of the faces it accepts; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 14pt                       // Pa.R.A.P. 124(a)(4): text no smaller than 14 point.
#let footnote-size = 12pt                   // Pa.R.A.P. 124(a)(4): footnotes no smaller than 12 point.
#let body-leading = 1.15em                  // Pa.R.A.P. 124(a)(3): text double spaced (set against the single line below).
#let single-leading = 0.45em                // Pa.R.A.P. 124(a)(3): block quotations, footnotes and headings may be single spaced.
#let page-margin = 1in                      // Pa.R.A.P. 124(a)(3): margins at least one inch on all four sides.
#let first-page-top = 3in                   // Pa.R.A.P. 124(a)(2): first page keeps a three-inch space at the top for court stampings.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                     // signature block starts right of centre (style; exemplars do the same).
#let word-count-cite = "Pa.R.A.P. 2135(a)(1)"   // word limit: 14,000 words for a principal brief (Pa.R.A.P. 2135(a)(1)).
#let public-access-cert = "I certify that this filing complies with the provisions of the Case Records Public Access Policy of the Unified Judicial System of Pennsylvania that require filing confidential information and documents differently than non-confidential information and documents."   // Pa.R.A.P. 127, Comment (form in the Public Access Policy 7.0(D), 8.0(D)).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pacommwct-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("pacommwct-opening-brief: missing required metadata field `" + key + "`") }
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

/// Signers of the signature block. Pa.R.A.P. 2111 and 127 leave the form to the filer: "/s/" and the typed
/// name, underlined, with the typed name again below, then attorney identification, address and telephone.
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
/// authority in the body (e.g. "373 Pa. Super."). A show rule on that string drops a marker after each
/// occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<pacommwct-toa>]

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
  let pages = query(<pacommwct-toa>)
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

#let pacommwct-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: point-numbering)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // levels 2-4 are numbered points and sub-points (bold, hanging).
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

  // Block quotations: indented, single-spaced (Pa.R.A.P. 124(a)(3)).
  show quote.where(block: true): it => block(inset: (left: 1in, right: 1in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 12 point, single spaced (Pa.R.A.P. 124(a)(3)-(4)).
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (page 1: three-inch space at the top, Pa.R.A.P. 124(a)(2); not numbered) ----
  page(margin: (top: first-page-top, rest: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COMMONWEALTH COURT OF PENNSYLVANIA] \
      #if "district" in meta { text(weight: "bold")[#upper(meta.district)] }
      #v(0.3in)
      #text(weight: "bold")[No. #need(meta, "case_number")]
    ]
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #if meta.at("versus", default: true) { align(center)[v.] }
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
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
        if "phone" in meta [ #meta.phone ]
      })
    }
  ]

  // ---- Table of contents and table of authorities (roman numerals; Pa.R.A.P. 124 does not fix them) ----
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

  // ---- Body (Arabic numerals from the first page of the brief, Pa.R.A.P. 2111(a)) ----
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

  // ---- Certificates (Pa.R.A.P. 2111(a)(12); 127(a); 2135(d)) ----
  pagebreak(weak: true)
  heading(level: 1, outlined: false, numbering: none)[Certificate of Compliance]
  par(inl(public-access-cert))
  par(inl("I certify that this brief complies with the word count limit of " + word-count-cite + ". The certificate relies on the word count of the word processing system used to prepare the brief, as Pa.R.A.P. 2135(d) permits."))
  block(width: 100%, breakable: false)[
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Proof of service (Pa.R.A.P. 121(d)) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[Proof of Service]
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
}
