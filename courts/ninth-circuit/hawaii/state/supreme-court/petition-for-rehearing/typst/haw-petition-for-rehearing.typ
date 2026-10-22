// Supreme Court of the State of Hawaii (haw): motion for reconsideration of an opinion (HRAP 40), in the
// form of HRAP 32. Content-agnostic: the parameters below are the ones HRAP 32(a) (flyleaf: 3-inch top
// margin, 1-inch margins, US letter) and HRAP 32(b) (12 point Times New Roman, footnotes and quotations in
// the text's face and size, double spacing except headings, quotations, footnotes) set; see
// ../../rules.md (HAW-FORM-001..006, HAW-FLY-001/002, HAW-SIG-001, HAW-REC-001..004).
// No case-specific text, no coordinates measured off any filed document, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
// The cover (HAW-FLY-001) and the signature block (HAW-SIG-001) are generated from the metadata.
// HAW-REC-002: the declaration of counsel and the certificate of service are rendered from
// frontmatter `certificates` (type `other` for the declaration, `service` for the certificate), each
// on its own page after the signature block. No table of authorities is generated (no `toa:` links).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // the exemplars' face (HAW-TYPE-001); Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 12pt                    // HRAP 32(b): 12 point pica, footnotes and quotations included.
#let body-leading = 1.6em                // double spacing at 12 pt: with the face's natural pitch (about 0.69 em here) the line pitch is 27.6 pt.
#let single-leading = 0.46em            // single spacing: line pitch 13.8 pt (headings, quotations, footnotes, caption, counsel).
#let page-margin = 1in                   // HRAP 32(a): margins not less than one inch.
#let flyleaf-top = 3in                   // HRAP 32(a) / HAW-FLY-002: 3-inch top margin on the flyleaf.
#let para-indent = 0.5in
#let sig-indent = 3.25in                 // signature block starts right of centre, as the exemplar does.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-petition-for-rehearing: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One side of the caption: names, then the designation.
#let caption-side(side) = {
  set par(leading: single-leading, spacing: 0.9em, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  v(0.4em)
  h(1.5in)
  emph(side.designation)
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #underline[/s/ #sig.signer] \
    #sig.signer
    #if "lines" in sig {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let haw-petition-for-rehearing(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Headings in the body (the exemplar has none beyond the document's own title): single-spaced, bold.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
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

  // Block quotations: indented, single-spaced (HRAP 32(b)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the text's size, single-spaced (HAW-FORM-004).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    // a table in a note (the exemplar tabulates revenue there) is set without rules, as the note is.
    show table: set table(stroke: none, inset: (x: 4pt, y: 0.5pt))
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HAW-FLY-001, HAW-FLY-002): 3-inch top margin, no page number ----
  page(margin: (top: flyleaf-top, left: page-margin, right: page-margin, bottom: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF HAWAI'I])
    #v(0.3in)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      [
        #caption-side(need(meta, "caption").at(0))
        #v(0.2in)
        #align(left)[vs.]
        #v(0.2in)
        #caption-side(need(meta, "caption").at(1))
      ],
      [
        #if "case_number" in meta [ #meta.case_number \ ]
        #if "trial_case_number" in meta [ #meta.trial_case_number \ ]
        #v(0.3em)
        #for p in meta.at("proceeding", default: ()) [ #inl(p) \ ]
        #if "judges" in meta [
          #v(0.6em)
          #for j in meta.judges [ #inl(j) \ ]
        ]
      ],
    )
    #v(1fr)
    #align(center)[
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
      #v(0.6em)
      #for c in meta.at("cover_items", default: ()) [ #text(weight: "bold", c) \ ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) ; v(0.6em) }
        if "phone" in meta [ #meta.phone ]
      })
    }
  ]

  // ---- Body: the motion ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the conclusion ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificates (HAW-REC-002 declaration of counsel; certificate of service), each on its own page ----
  for c in meta.at("certificates", default: ()) {
    pagebreak()
    align(center, text(weight: "bold", upper(inl(c.title))))
    v(0.6em)
    cmarker.render(c.text, raw-typst: false, smart-punctuation: true)
    v(0.3in)
    block(width: 100%, breakable: false)[
      #if "date" in c { par(first-line-indent: (amount: para-indent, all: true), inl(c.date)) }
      #v(0.4em)
      #if "signature" in c { signature-block(c.signature) }
    ]
  }
}
