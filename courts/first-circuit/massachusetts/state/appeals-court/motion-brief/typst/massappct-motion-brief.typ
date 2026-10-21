// Massachusetts Appeals Court (massappct): motion with supporting argument (Mass. R.A.P. 15(a), 20(b)(2)).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it (Massachusetts
// Rules of Appellate Procedure, Rules 13, 15 and 20(b), as posted on mass.gov; see ../../rules.md). No case-specific
// text, no coordinates measured off any filed motion, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata is the YAML frontmatter of the INPUT (fields listed in ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 12pt                    // MRAP 20 (b) (2) (A): text of a motion 12 point or larger.
#let body-leading = 1.2em                // MRAP 20 (b) (2) (A): double-spaced (not more than 3 lines per vertical inch).
#let single-leading = 0.45em             // headings, counsel and signature blocks: single-spaced (style choice).
#let page-margin = 1in                   // MRAP 20 (b) (2) (A): top and side margins no less than 1 inch.
#let para-indent = 0.5in
#let court-name = "COMMONWEALTH OF MASSACHUSETTS"  // MRAP 20 (b) (2) (A): caption names the court (fixed for this court).
#let sig-indent = 3.2in                  // style: the signature block starts right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("massappct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("massappct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// The signature block: an optional introduction (for example "Respectfully submitted,"), the signer with the
/// typed name, then the lines beneath (BBO number, addresses, telephone, e-mail, date of signing).
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("intro", default: ()) [ #inl(l) \ ]
    #for s in sig.signers [
      #v(1.2em)
      #underline[#inl(s.name)] \
      #for l in s.at("lines", default: ()) [ #inl(l) \ ]
    ]
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let massappct-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // MRAP 20 (b) (2) (A): margins; page numbers in the margin.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold); level 2 and 3 are
  // sub-headings (bold, left; bold italic for level 3).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.6em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.6em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 0.9em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // ---- Caption (MRAP 20 (b) (2) (A)): court, county and docket, case title, descriptive title, on the first page ----
  align(center)[#text(weight: "bold")[#court-name]]
  v(0.3em)
  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    [#inl(need(meta, "county"))], [#inl(need(meta, "case_number"))],
  )
  v(0.6em)
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(left: 0.5in, for l in need(meta, "caption") [ #inl(l) \ ])
  }
  v(0.6em)
  align(center)[#text(weight: "bold", inl(need(meta, "title")))]
  v(0.6em)

  // ---- Body: the motion and its supporting argument ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block (MRAP 20 (b) (2) (B)): printed and signed name, BBO number, addresses, telephone, date ----
  v(0.6em)
  block(width: 100%, breakable: false, signature-block(need(meta, "signature")))

  // ---- Certificate of service (MRAP 13 (d) (2)) ----
  if "service" in meta {
    let svc = meta.service
    v(1.2em)
    block(breakable: false)[
      #heading(level: 1, outlined: false)[Certification of Service]
      #for p in svc.paragraphs { par(inl(p)) }
    ]
    v(0.4em)
    signature-block(svc.signature)
  }
}
