// Third District Court of Appeal (fladistctapp3): motion and supporting memorandum.
// Form: Fla. R. App. P. 9.045(b) (Arial or Bookman Old Style, 14 point, double-spaced, black);
// margins at least 1 inch (Fla. R. Gen. Prac. & Jud. Admin. 2.520(a)(3)). See ../../rules.md.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it.
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"        // Rule 9.045(b): Arial 14 point. Liberation Sans is the metric-compatible Arial (docs/FONTS.md).
#let type-size = 14pt                       // Rule 9.045(b): 14 point, footnotes and quotations included.
#let body-leading = 1.2em                   // Rule 9.045(b): double-spaced text.
#let single-leading = 0.45em                // Rule 9.045(b): footnotes, quotations and headings may be single-spaced.
#let page-margin = (top: 1.05in, bottom: 1in, left: 1in, right: 1.1in)   // Rule 2.520(a)(3): at least 1 inch. Top and right are deeper so that footnote marks and justified overhang stay inside the margin.
#let para-indent = 0.5in
#let sig-indent = 3.2in
#let court-name = ("STATE OF FLORIDA", "THIRD DISTRICT COURT OF APPEAL")   // Court's name as it appears on the caption.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp3-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp3-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: party names, then the designation indented beneath.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.5em)
  for n in side.names [ #inl(n) \ ]
  pad(left: 1.2in)[#emph(inl(side.designation))]
}

/// Signature block: "/s/" typed signature, then the counsel lines.
#let signature-block(sig) = block(width: 100%, breakable: false, pad(left: sig-indent)[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  /s/ #inl(sig.signer) \
  #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
])

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp3-motion(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #text(weight: "bold", it.body)
  ]
  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: the same size as the text, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption ----
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", court-name.at(0)) \
    #text(weight: "bold", court-name.at(1))
  ]
  v(0.3in)
  grid(
    columns: (1fr, 2.7in),
    gutter: 0.2in,
    [
      #for side in need(meta, "caption") [
        #caption-side(side)
        #v(0.2in)
      ]
      #set par(leading: single-leading, first-line-indent: 0pt)
      #line(length: 3.3in, stroke: 0.5pt)
    ],
    [
      #set par(leading: single-leading, first-line-indent: 0pt)
      #v(0.6in)
      Case No. #need(meta, "case_number") \
      #if "lt_case_number" in meta [ L.T. Case No. #meta.lt_case_number ]
    ],
  )

  // ---- Title ----
  v(0.4in)
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
  ]
  v(0.4in)

  // ---- Body ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #pad(left: sig-indent)[#set par(first-line-indent: 0pt); Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (content from the sample metadata) ----
  if "service" in meta {
    block(breakable: false)[
      #heading(level: 1, numbering: none)[Certificate of Service]
      #par(first-line-indent: (amount: para-indent, all: true), inl(meta.service))
      #v(0.4em)
      #signature-block((signer: need(meta, "signature").signer, lines: need(meta, "signature").at("lines", default: ()).slice(0, 2)))
    ]
  }
}
