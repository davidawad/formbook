// Supreme Court of Montana: motion and supporting memorandum (motion-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the Montana Rules of Appellate Procedure (M.R.App.P.) cited next to it.
// No coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // M.R.App.P. 11(2) names a proportionately spaced face; Times New Roman with Liberation Serif as its metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // M.R.App.P. 11(2): 14-point or larger for text and footnotes (MONT-FORM-003).
#let body-leading = 1.65em                 // M.R.App.P. 11(3)(b): double spaced (MONT-FORM-004). With typst's default line box this gives a
                                           // baseline pitch of about 32.3 pt = 2 x the 1.15 em single line of this face at 14 pt.
#let cover-size = 11pt                    // MONT-FORM-003: the cover is exempt from the 14-point size (M.R.App.P. 11(2)).
#let cover-leading = 0.2em                  // the cover is single-spaced in a tight block so the caption and counsel fit on page 1.
#let single-leading = 0.45em               // M.R.App.P. 11(3)(b) excludes footnotes and quoted or indented material: single-spaced.
#let page-margin = (top: 1in, bottom: 1.1in, left: 1in, right: 1in)  // M.R.App.P. 11(3)(a): at least one inch on all sides (MONT-FORM-002). The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the 1 in line.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).
#let font-label = "Times New Roman"           // M.R.App.P. 11(4)(e): the certificate states the typeface and point size.
// M.R.App.P. 11(4)(e) and 16(3) (MONT-CERT-001, MONT-MOT-003): the certificate of compliance states the line spacing,
// the typeface and point size, and the word count; the certificate itself is not counted in the length (MONT-LEN-003).
#let compliance-text(n) = [I certify that this motion is printed with a proportionately spaced #font-label typeface of #int(type-size.pt()) points, is double-spaced except for footnotes and for quoted and indented material, and contains #n words, excluding the parts exempt under M.R.App.P. 11(4)(d).]

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mont-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mont-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption column: the proceeding line, then each caption side (names, then designation).
/// Sides after the first are joined by "v." (the second side) and "and" (the rest).
#let caption-column(meta) = {
  set par(leading: cover-leading, spacing: 0.4em, first-line-indent: 0pt)
  if "proceeding" in meta {
    inl(meta.proceeding)
    v(0.8em)
  }
  for (i, s) in meta.caption.enumerate() {
    if i > 0 {
      v(0.5em)
      if i == 1 [v.] else [and]
      v(0.5em)
    }
    for n in s.names [ #inl(n) \ ]
    emph(s.designation)
  }
}

/// Counsel group: names then the lines beneath, single-spaced, left aligned.
#let counsel-group(g) = {
  set par(leading: cover-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.at("names", default: ()) [ #inl(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.4em)
}

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines follow.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #s.name] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig {
      if type(sig.firm) == str [ #strong(sig.firm) #v(0.8em) ] else [
        #for l in sig.firm [ #strong(l) \ ]
        #v(0.8em)
      ]
    }
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
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<mont-toa>]

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
  let pages = query(<mont-toa>)
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

#let mont-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // M.R.App.P. 11(3)(b): pages are numbered (MONT-FORM-004); the cover is page 1.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left). The author types the section numbers.
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

  // Block quotations: indented, single-spaced (M.R.App.P. 11(3)(b)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (M.R.App.P. 11(2)), single-spaced (M.R.App.P. 11(3)(b)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (MONT-COVER-001, M.R.App.P. 11(6)(b): court title, cause number, caption with tribunal, counsel, title) ----
  // The cover is exempt from the 14-point size (MONT-FORM-003, M.R.App.P. 11(2)); it is set in 11 pt so the
  // caption, counsel blocks and title fit on the first page.
  page[
    #set text(size: cover-size)
    #set par(leading: cover-leading, first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF MONTANA]]
    #v(0.1in)
    #align(center)[#text(weight: "bold")[#inl(need(meta, "case_number"))]]
    #v(0.1in)
    #caption-column(meta)
    #if "lower_tribunal" in meta {
      v(0.5em)
      inl(meta.lower_tribunal)
    }
    #v(0.15in)
    #grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 0.2em,
      ..need(meta, "counsel").map(g => counsel-group(g)),
    )
    #v(0.1in)
    #align(center)[#text(weight: "bold", inl(need(meta, "brief_title")))]
  ]

  // ---- Table of contents (only when the filing has one) ----
  if meta.at("toc", default: false) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (only when the metadata registers authorities) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), [DATED this #inl(meta.date).]) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (MONT-CERT-001): required for a motion; word count is required ----
  pagebreak(weak: true)
  heading(level: 1)[Certificate of Compliance]
  par(first-line-indent: (amount: para-indent, all: true))[#compliance-text(need(meta, "word_count"))]
  v(0.4em)
  signature-block(need(meta, "signature"), first-only: true)

  // ---- Certificate of service ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[#svc.at("heading", default: "Certificate of Service")]
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
