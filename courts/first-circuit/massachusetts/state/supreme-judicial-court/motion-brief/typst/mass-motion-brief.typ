// Massachusetts Supreme Judicial Court: motion-brief template (a motion and its supporting memorandum,
// or any other document addressed to the court). Requirement IDs (MA-...) refer to ../../rules.md.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Massachusetts Rules of Appellate Procedure, as amended effective September 1, 2026; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed document, no forced line breaks. The
// markdown body is rendered by cmarker; the caption, signature and certificate come from the YAML
// frontmatter of the INPUT (keys documented in the frontmatter of usage/INPUT-motion-brief.md).
//
// A motion has no separate cover: the caption is on the first page (MA-MOT-001, MRAP 20(b)(2)(A)) and
// that page is page 1 (MA-FORM-005). No table of contents or table of authorities is generated: MRAP 16
// does not apply to a motion, and the filed exemplar has neither.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"
#let type-size = 14pt                      // MRAP 20 (a) (4) (B): proportionally spaced font of 14 point or larger, footnotes included. (MRAP 20 (b) (2) (A) floor: 12 point.)
#let body-leading = 1.15em                 // MRAP 20 (a) (4) (C), 20 (b) (2) (A): double-spaced text (a single line is about 1.15 em in this face; leading of one line is double spacing).
#let single-leading = 0.2em                // MRAP 20 (a) (4) (C): caption, signature, certificate and footnote blocks may be single-spaced.
#let page-margin = 1in                     // MRAP 20 (a) (4) (A), 20 (b) (2) (A): side and top margins at least 1 inch (bottom too).
#let para-indent = 0.5in                   // style choice matching the filed exemplar's first-line indent.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mass-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A stack of single-spaced lines (each entry is one line; the line breaks come from the wrap, not from the template).
#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(l => if bold { text(weight: "bold", inl(l)) } else { inl(l) }),
)

// ---------------------------------------------------------------------------
// Caption on the first page (MA-MOT-001, MRAP 20(b)(2)(A)): court name, county and docket number,
// the case title (each side with its designation), then the descriptive title of the document.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, text(weight: "bold", lines-of(need(meta, "court"))))
  v(body-leading)
  grid(
    columns: (1fr, auto),
    align(left)[#meta.at("county", default: "")],
    align(right)[#need(meta, "docket")],
  )
  v(body-leading)
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 {
      align(center)[v.]
      v(single-leading)
    }
    align(center, lines-of(side.at("names")))
    v(single-leading)
    align(right, pad(right: 1.25in, inl(side.at("designation"))))
    v(body-leading * 0.5)
  }
  v(body-leading * 0.5)
  align(center, text(weight: "bold", need(meta, "title")))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature block (MA-SIG-001, MA-MOT-002, MRAP 16(a)(12), 20(b)(2)(B)): the date of signing, the
// introduction, and each signer's signature with printed name, BBO number, office, address, telephone
// and e-mail address.
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  let columns = need(sig, "columns")
  block(width: 100%, breakable: false)[
    #v(body-leading)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.4in,
      row-gutter: body-leading,
      [#set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
       Dated: #need(meta, "date")],
      [#set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
       #sig.at("intro", default: "Respectfully submitted,")],
      ..columns.map(c => block(breakable: false)[
        #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
        #block(width: 100%)[/s/ #inl(c.at("signer"))]
        #v(single-leading)
        #lines-of(c.at("lines", default: ()))
      ]),
    )
  ]
}

// ---------------------------------------------------------------------------
// Certificate of service (MA-CERT-002, MRAP 13(e), 16(a)(15)). The heading and the signature line are
// the template's; the statement of service and the recipients are filer-supplied (frontmatter `certificate`).
// ---------------------------------------------------------------------------

#let certificate(meta) = {
  let c = need(meta, "certificate")
  block(width: 100%)[
    #v(body-leading)
    #align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
    #v(body-leading)
    #set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent)
    #inl(c.at("text"))
    #v(body-leading * 0.5)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      row-gutter: body-leading,
      ..c.at("recipients", default: ()).map(r => lines-of(r)),
    )
    #v(body-leading)
    #align(right, block(width: 3in)[
      #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      #block(width: 100%)[/s/ #inl(c.at("signer"))]
      #v(single-leading)
      #inl(c.at("signer"))
    ])
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mass-motion-brief(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  // MA-FORM-005: pages are numbered in the bottom margin, consecutively from the first page (the caption page).
  // The bottom margin is 1 inch plus 4 pt: a footnote's last line at the foot of a page then sits inside the
  // 1-inch margin (MA-FORM-003, MRAP 20 (a) (4) (A)); the page number is printed in that margin.
  set page(paper: "us-letter", margin: (top: page-margin, left: page-margin, right: page-margin, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  // MA-FORM-002: Times New Roman, 14 point, for all text.
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // MA-FORM-004: double spacing for text; first-line indent for paragraphs.
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: para-indent)

  // Headings, if the filer uses any: level 1 centred bold; level 2 and 3 bold at the left. Same spacing as the text.
  show heading.where(level: 1): it => {
    v(body-leading)
    block(sticky: true, width: 100%, align(center, text(weight: "bold", it.body)))
    v(body-leading)
  }
  show heading.where(level: 2): it => {
    v(body-leading)
    block(sticky: true, par(first-line-indent: 0pt, text(weight: "bold", it.body)))
    v(body-leading)
  }
  show heading.where(level: 3): it => {
    v(body-leading)
    block(sticky: true, par(first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body)))
    v(body-leading)
  }

  // MA-FORM-004: indented quotations may be single-spaced; they are indented on both sides.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: body-leading, {
    set par(leading: single-leading, spacing: body-leading, first-line-indent: 0pt)
    it.body
  })

  // MA-FORM-002 covers footnotes at the same face and size; single-spaced (MA-FORM-004).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.6em)

  // First page: the caption (no separate cover, MA-MOT-001).
  caption(meta)

  // Body.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Signature block, then the certificate of service (MA-SIG-001, MA-CERT-002).
  signature(meta)
  certificate(meta)
}
