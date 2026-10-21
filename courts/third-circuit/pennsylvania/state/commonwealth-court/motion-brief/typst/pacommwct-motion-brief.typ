// Commonwealth Court of Pennsylvania (pacommwct): briefs, applications, petitions and amicus briefs.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Pa.R.A.P., 210 Pa. Code, text current through 56 Pa.B. 5370, August 8, 2026; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Official Note to Pa.R.A.P. 124: Times New Roman is the Commonwealth Court's face; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 14pt                      // Pa.R.A.P. 124(a)(4): text no smaller than 14 point.
#let footnote-size = 12pt                  // Pa.R.A.P. 124(a)(4): footnotes no smaller than 12 point (the rule minimum; at 14 pt the footnote box overhangs the bottom margin).
#let body-leading = 1.65em                 // Pa.R.A.P. 124(a)(3): double spacing. Gives a baseline pitch of about 2x the single line of this face.
#let single-leading = 0.45em               // Pa.R.A.P. 124(a)(3) excludes long quotations and footnotes: single spaced.
#let page-margin = 1in                     // Pa.R.A.P. 124(a)(3): margins at least one inch on all four sides.
#let first-page-top = 3in                  // Pa.R.A.P. 124(a)(2): first page keeps a three-inch space from the top for court stampings.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).

// Certificate of compliance with the Case Records Public Access Policy: Pa.R.A.P. 127(a) and its Comment
// (Public Access Policy Sections 7.0(D) and 8.0(D)): the substantially required form.
#let public-access-text = "I certify that this filing complies with the provisions of the Case Records Public Access Policy of the Unified Judicial System of Pennsylvania that require filing confidential information and documents differently than non-confidential information and documents."

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pacommwct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("pacommwct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0pt)
    #for n in side.names [ #n \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.35em)
}

/// Signers of the signature block. "/s/" and the typed name, underlined, with the typed name again below.
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
/// authority in the body. A show rule on that string drops a marker after each occurrence.
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
  heading(level: 1, outlined: true)[Table of Authorities]
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

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let pacommwct-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Every page numbered with an Arabic numeral at the bottom; the cover is page 1 (exemplars do the same).
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

  // Block quotations: indented, single-spaced (Pa.R.A.P. 124(a)(3) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes single-spaced (Pa.R.A.P. 124(a)(3)); citations in footnotes count toward the table of authorities.
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: 0.7em, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Pa.R.A.P. 124(a)(2): three-inch clear space at the top of the first page) ----
  page(margin: (top: first-page-top, bottom: page-margin, left: page-margin, right: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COMMONWEALTH COURT OF PENNSYLVANIA] \
      #v(0.15in)
      #text(weight: "bold")[#need(meta, "docket_number")]
    ]
    #if "proceeding" in meta [ #v(0.15in) #align(center, inl(meta.proceeding)) ]
    #if "caption" in meta {
      v(0.15in)
      caption-side(meta.caption.at(0))
      v(0.1in)
      align(center)[v.]
      v(0.1in)
      caption-side(meta.caption.at(1))
    }
    #if "lower_court" in meta [ #v(0.15in) #align(center, inl(meta.lower_court)) ]
    #v(0.1in)
    #align(center)[
      #text(weight: "bold", size: 14pt, inl(need(meta, "brief_title")))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: 2.0in, {
        for g in need(meta, "counsel") { counsel-group(g) }
        if "phone" in meta [ #meta.phone ]
      })
    }
  ]

  // ---- Table of contents (generated from the body headings) ----
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

  // ---- Certificates of compliance (Pa.R.A.P. 127; 2135(d); 531(b)(2)), date, signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #heading(level: 1)[Certificate of Compliance]
    #par(first-line-indent: (amount: para-indent, all: true))[#public-access-text]
    #for c in meta.at("certificates", default: ()) {
      if c.at("type", default: "compliance") == "compliance" {
        par(first-line-indent: (amount: para-indent, all: true), inl(c.text))
      }
    }
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Other certificates or verifications the filing carries (type "service" or "other") ----
  for c in meta.at("certificates", default: ()) {
    if c.at("type", default: "compliance") != "compliance" {
      pagebreak(weak: true)
      heading(level: 1)[#inl(c.at("heading", default: "Certificate of Service"))]
      for p in c.at("paragraphs", default: ()) { par(inl(p)) }
      for r in c.at("recipients", default: ()) {
        block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
          #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
          #for l in r [ #inl(l) \ ]
        ])
      }
      if "closing" in c { par(inl(c.closing)) }
      v(0.4em)
      signature-block(need(meta, "signature"), first-only: c.at("first_signer_only", default: true))
    }
  }
}
