// Supreme Court of the State of New York: verified complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NYSC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced
// line breaks. The body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"   // convention: the one vendored serif (fonts/eb-garamond)
#let type-size = 12pt              // NYSC-FORM-002: 22 NYCRR 202.5(a) print no smaller than 12-point
#let footnote-size = 10pt          // NYSC-FORM-003: 22 NYCRR 202.5(a) footnotes no smaller than 10-point
#let page-margin = 1in             // NYSC-FORM-004: 22 NYCRR 202.5(a) margins no smaller than one inch
#let para-indent = 0.5in           // convention: numbered paragraphs begin with a first-line indent
#let body-leading = 1.65em         // NYSC-FORM-005: double space (202.5(a)); tuned so the baseline pitch matches a double-spaced 12-point page, see README
#let single-leading = 0.52em       // block quotations, caption, signature block, TOC: single-spaced (pitch about 14 pt)
#let toc-depth = 2

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nysupct-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A run of single-spaced address or signature lines, one item per line (no manual breaks).
#let address(lines, italic: false) = stack(
  dir: ttb,
  spacing: single-leading,
  ..lines.map(l => if italic { text(style: "italic")[#inl(l)] } else { inl(l) }),
)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysupct-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (NYSC-CAP-001..003: court, county, parties, index number, title)
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let parties = need(meta, "parties")
  block(width: 100%, breakable: false)[
    #block(width: 100%)[#align(center)[#text(weight: "bold")[SUPREME COURT OF THE STATE OF NEW YORK]]]
    #block(width: 100%)[#align(left)[#text(weight: "bold")[#need(meta, "county")]]]
    #v(0.8em)
    #grid(
      columns: (3.6in, 1fr),
      column-gutter: 0.2in,
      block(
        width: 100%,
        stroke: (top: 0.7pt, bottom: 0.7pt, right: 0.7pt),
        inset: (top: 0.7em, bottom: 0.7em, right: 0.6em),
      )[
        #for (i, group) in parties.enumerate() {
          if i > 0 {
            v(0.6em)
            align(center)[#text(style: "italic")[-against-]]
            v(0.6em)
          }
          for name in group.names {
            pad(left: 0.2in, right: 0.2in)[#set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
              #inl(name)]
            v(0.1em)
          }
          align(right)[#pad(right: 0.2in)[#set par(leading: single-leading, spacing: single-leading)
            #inl(group.designation)]]
        }
      ],
      block(width: 100%, inset: (top: 0.7em))[
        #set par(leading: single-leading, spacing: single-leading)
        #need(meta, "index_no")
        #v(2.2em)
        #text(weight: "bold")[#need(meta, "title")]
      ],
    )
    #v(1.2em)
  ]
}

// ---------------------------------------------------------------------------
// Verification (NYSC-VER-001..002: CPLR 3020(a) and 2106, affirmation form)
// ---------------------------------------------------------------------------

#let verification-block(meta) = {
  let ver = need(meta, "verification")
  align(center)[#text(weight: "bold")[VERIFICATION]]
  v(1.2em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))
  [
    #inl(ver.verifier), #inl(ver.capacity), affirms under the penalties of perjury under the laws of New
    York, which may include a fine or imprisonment, that the foregoing #inl(need(meta, "title")) is true
    to the knowledge of the affirmant, except as to matters alleged on information and belief, and as to
    those matters the affirmant believes them to be true. The affirmant understands that this document
    may be filed in an action or proceeding in a court of law.
  ]
  v(2.4em)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(left)[Dated: #need(meta, "date")]
    #v(2.4em)
    #align(right)[#block(width: 3.2in)[
      #line(length: 100%, stroke: 0.6pt)
      #v(0.2em)
      #inl(ver.verifier)
    ]]
  ]
}

// ---------------------------------------------------------------------------
// Signature block (NYSC-SIG-001..003: dated, signed, printed name beneath, CPLR 2101(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    #grid(
      columns: (1fr, 3.2in),
      [Dated: #need(meta, "date")],
      [
        Respectfully submitted,
        #v(1.2em)
        #if "firm" in sig [
          #address(sig.firm)
          #v(1.2em)
        ]
        By: #line(length: 2.6in, stroke: 0.6pt)
        #v(0.2em)
        #stack(dir: ttb, spacing: single-leading, inl(sig.signer), address(sig.lines, italic: true))
      ],
    )
  ]
}

#let service-block(meta) = {
  if "to" not in meta { return }
  v(1.6em)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    To:
    #for group in meta.to [
      #v(0.6em)
      #address(group.names)
      #address(group.lines, italic: true)
    ]
  ]
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nysupct-complaint(meta, body) = {
  let title = need(meta, "title")
  let _ = need(meta, "parties")

  set document(title: title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true),
    justify: false,
  )

  // Headings: level 1 centered bold capitals (the author types the numbering).
  show heading.where(level: 1): it => block(
    width: 100%, above: 1.4em, below: 1.2em, sticky: true,
    align(center, text(weight: "bold", it.body)),
  )
  show heading.where(level: 2): it => block(
    width: 100%, above: 1.2em, below: 1em, sticky: true,
    par(first-line-indent: 0pt, text(weight: "bold", it.body)),
  )
  show heading.where(level: 3): it => block(
    width: 100%, above: 1em, below: 0.8em, sticky: true,
    par(first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body)),
  )

  // Footnotes at the 10-point minimum; the marks sit in the body text.
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)

  // Block quotations: indented, single-spaced (convention; the exemplar quotes are set this way).
  show quote: it => block(
    width: 100%, inset: (left: 0.5in, right: 0.5in), above: 1em, below: 1em,
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt),
    it.body,
  )

  // Caption on page 1, then the table of contents if requested.
  caption-block(meta)

  if meta.at("toc", default: false) {
    align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
    v(1.2em)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    outline(title: none, depth: toc-depth, indent: 0.4in)
    pagebreak()
  }

  // The body, rendered from markdown.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  service-block(meta)

  pagebreak()
  verification-block(meta)
}
