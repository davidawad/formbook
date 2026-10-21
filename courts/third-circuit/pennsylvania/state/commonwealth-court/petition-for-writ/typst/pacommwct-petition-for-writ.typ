// Commonwealth Court of Pennsylvania (pacommwct): petition for review in the court's appellate or original
// jurisdiction (Pa.R.A.P. 1513, 1514; rules.md PACOMMWCT-CONT-008..011, PACOMMWCT-CERT-005, PACOMMWCT-ELEC-002).
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Pa.R.A.P., 210 Pa. Code, text current through 56 Pa.B. 5370, August 8, 2026; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed petition, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Official Note to Pa.R.A.P. 124: Times New Roman is the Commonwealth Court's face; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 14pt                      // Pa.R.A.P. 124(a)(4) as applied by rules.md PACOMMWCT-FORM-003: text no smaller than 14 point (eval.yaml).
#let footnote-size = 12pt                  // Pa.R.A.P. 124(a)(4): footnotes no smaller than 12 point.
#let body-leading = 1.65em                 // Pa.R.A.P. 124(a)(3): double spacing (about 2x the single line of this face).
#let single-leading = 0.45em               // Pa.R.A.P. 124(a)(3): block quotations and footnotes single spaced.
#let page-margin = 1in                     // Pa.R.A.P. 124(a)(3): margins at least one inch on all four sides.
#let first-page-top = 3in                  // Pa.R.A.P. 124(a)(2): first page keeps a three-inch clear space from the top (cover).
#let para-indent = 0.5in
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).

// Certificate of compliance with the Case Records Public Access Policy: Pa.R.A.P. 127(a) and its Comment
// (Public Access Policy Sections 7.0(D) and 8.0(D)): the substantially required form.
#let public-access-text = "I certify that this filing complies with the provisions of the Case Records Public Access Policy of the Unified Judicial System of Pennsylvania that require filing confidential information and documents differently than non-confidential information and documents."

// Paragraph counter for the numbered paragraphs of the petition (Pa.R.A.P. 1513(c)): the markdown is an
// ordered list, numbered here across headings.
#let para-no = counter("pacommwct-para")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pacommwct-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("pacommwct-petition-for-writ: missing required metadata field `" + key + "`") }
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

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[/s/ #emph(sig.signer)] \
    #sig.signer
    #if "firm" in sig [ \ #strong(sig.firm) ]
    #v(0.6em)
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let pacommwct-writ(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a part (centred, capitals, bold);
  // level 2 is a sub-heading or count (bold, left); level 3 is bold italic.
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

  // Numbered paragraphs: the number sits at the paragraph indent, the text follows it.
  show enum.item: it => {
    para-no.step()
    block(width: 100%, breakable: true)[
      #set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt)
      #h(para-indent) #context numbering("1.", ..para-no.get()) #h(0.3em) #it.body
    ]
  }

  // Block quotations: indented, single-spaced (Pa.R.A.P. 124(a)(3) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes single-spaced at the rule minimum (Pa.R.A.P. 124(a)(3), (4)).
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: 0.7em, first-line-indent: 0pt)
    it
  }

  // ---- Cover (Pa.R.A.P. 124(a)(2): three-inch clear space at the top of the first page) ----
  page(margin: (top: first-page-top, bottom: page-margin, left: page-margin, right: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COMMONWEALTH COURT OF PENNSYLVANIA] \
      #v(0.15in)
      #text(weight: "bold")[#need(meta, "docket_number")]
    ]
    #v(0.15in)
    #if "caption" in meta {
      caption-side(meta.caption.at(0))
      v(0.1in)
      align(center)[v.]
      v(0.1in)
      caption-side(meta.caption.at(1))
    }
    #v(0.1in)
    #align(center)[
      #text(weight: "bold", size: type-size, upper(inl(need(meta, "brief_title"))))
      #if "subtitle" in meta [ \ #text(weight: "bold", inl(meta.subtitle)) ]
    ]
    #v(0.12in)
    // Counsel side by side: the cover has 7 in of body height after the three-inch clear space.
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      grid(
        columns: range(need(meta, "counsel").len()).map(_ => 1fr),
        column-gutter: 0.3in,
        ..need(meta, "counsel").map(g => block(width: 100%, counsel-group(g))),
      )
    }
  ]

  // ---- Notice to plead (Pa.R.A.P. 1513(e)(6); rules.md PACOMMWCT-CONT-014): its own page before the body ----
  if "notice_to_plead" in meta {
    let np = meta.notice_to_plead
    page(numbering: none)[
      #set par(leading: body-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold", "NOTICE TO PLEAD"))
      #v(0.6em)
      #set par(leading: single-leading, first-line-indent: 0pt)
      #for r in np.at("respondents", default: ()) [ TO: #inl(r) \ ]
      #v(0.8em)
      #set par(leading: body-leading, first-line-indent: (amount: para-indent, all: true))
      #inl(np.text)
      #v(0.6em)
      #set par(leading: single-leading, first-line-indent: 0pt)
      #signature-block(need(meta, "signature"))
    ]
  }

  // ---- Body: numbered paragraphs under the petition's headings ----
  page(numbering: "1", number-align: center + bottom)[
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true)
  ]

  // ---- Closing: prayer, date, signature block ----
  block(width: 100%, breakable: false)[
    #v(0.3in)
    #set par(leading: body-leading, first-line-indent: 0pt)
    #if "date" in meta [Dated: #meta.date]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Verification by the party (Pa.R.A.P. 1513(e)(6); rules.md PACOMMWCT-CONT-014) ----
  if "verification" in meta {
    let vf = meta.verification
    pagebreak()
    heading(level: 1)[Verification]
    par(first-line-indent: (amount: para-indent, all: true), inl(vf.text))
    v(1.2em)
    pad(left: sig-indent, block(width: 100%, breakable: false)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #underline[#emph(vf.signer)] \
      #vf.signer
    ])
  }

  // ---- Certificates (Pa.R.A.P. 127; 1514): compliance first, then the other certificates ----
  pagebreak()
  heading(level: 1)[Certificate of Compliance]
  par(first-line-indent: (amount: para-indent, all: true))[#public-access-text]
  v(0.4em)
  signature-block(need(meta, "signature"))

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
      signature-block(need(meta, "signature"))
    }
  }
}
