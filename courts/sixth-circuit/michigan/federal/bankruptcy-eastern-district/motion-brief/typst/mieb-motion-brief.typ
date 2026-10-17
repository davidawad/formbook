// U.S. Bankruptcy Court, E.D. Michigan: motion with a brief in support (Fed. R. Bankr. P. 9013, 9014;
// Local Bankruptcy Rules 9004-1, 9014-1 and 9029-1(h)).
//
// Rule-driven and content-agnostic. Requirement IDs (MIEB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker in one piece per document (so footnotes work); the metadata comes
// from the YAML frontmatter of the same file (schema: ../README.md). A line holding only `---` starts the next
// document of the filing (the motion, the brief in support, the certificate of service), each with its own
// caption and title.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"    // MIEB-FORM-002: proportional serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                    // MIEB-FORM-002: LBR 9029-1(h) "14 point (proportional)" for all text and footnotes.
#let body-leading = 1.345em              // MIEB-FORM-003: double spacing (pitch 28 pt at 14 pt type; see ../README.md).
#let single-leading = 0.3em              // caption, counsel and signature blocks: single spacing (MIEB-FORM-004).
#let footnote-leading = 0.3em            // footnotes and block quotations are exempt from double spacing (LBR 9029-1(h)).
#let margins = 1in                       // MIEB-FORM-001: LBR 9029-1(h) "at least 1 inch on the top, sides and bottom".
#let para-indent = 0.5in                 // first-line indent of body paragraphs.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (italics, links, footnotes, headings) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mieb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mieb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines of text, one per line, single-spaced.
#let lines-of(items) = items.map(x => [#x]).join(linebreak())

/// One block of single-spaced text, full width.
#let single-block(c) = block(width: 100%, par(leading: single-leading, first-line-indent: 0pt, c))

// ---------------------------------------------------------------------------
// Document setup: applied with `#show: motion-doc.with(meta)` in main.typ
// ---------------------------------------------------------------------------

#let motion-doc(meta, doc) = {
  set document(title: need(meta, "titles").at(0))
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: type-size, counter(page).display("1 of 1", both: true))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, first-line-indent: para-indent, spacing: body-leading)
  // Headings in the body (markdown # and ##, ###): centered caps, bold, then bold subsections.
  show heading.where(level: 1): it => block(
    width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, strong(it.body)),
  )
  show heading.where(level: 2): it => block(
    width: 100%, sticky: true, above: body-leading, below: body-leading,
    strong(it.body),
  )
  show heading.where(level: 3): it => block(
    width: 100%, sticky: true, above: body-leading, below: body-leading,
    strong(emph(it.body)),
  )
  // Footnotes: 14 point, single-spaced (MIEB-FORM-002, MIEB-FORM-003 exemption).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: footnote-leading, first-line-indent: 0pt)
  // Block quotations: single-spaced and indented (exempt from double spacing).
  show quote.where(block: true): it => pad(
    x: para-indent,
    par(leading: footnote-leading, first-line-indent: 0pt, it.body),
  )
  doc
}

// ---------------------------------------------------------------------------
// Caption of each document (MIEB-CAP-001, LBR 9004-1(a))
// ---------------------------------------------------------------------------

#let caption(meta, title) = {
  align(center, single-block(lines-of(need(meta, "court"))))
  v(1.2em)
  line(length: 100%, stroke: 0.5pt)
  let ir = need(meta, "in_re")
  let cs = need(meta, "case")
  grid(
    columns: (1fr, 1fr),
    gutter: 0pt,
    single-block([
      In re: #lines-of(ir.names) \
      #ir.role \
      #align(left, [/])
    ]),
    single-block([
      Chapter #cs.chapter \
      Case No. #cs.number \
      #cs.judge
    ]),
  )
  line(length: 100%, stroke: 0.5pt)
  v(1.2em)
  align(center, strong(title))
  v(0.8em)
}

// ---------------------------------------------------------------------------
// Signature block at the end of each document (MIEB-SIG-001)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  v(1.2em)
  block(breakable: false, grid(
    columns: (1fr, 3.2in),
    gutter: 0pt,
    [Dated: #need(meta, "date")],
    single-block([
      Respectfully submitted, \
      #sig.signer \
      #lines-of(sig.lines)
    ]),
  ))
}

// ---------------------------------------------------------------------------
// Entry point: one document per `---`-separated part of the body
// ---------------------------------------------------------------------------

#let motion-body(meta, md-src) = {
  let parts = md-src.split("\n---\n")
  let titles = need(meta, "titles")
  if parts.len() != titles.len() {
    panic("mieb-motion-brief: the body has " + str(parts.len()) + " documents but `titles` lists " + str(titles.len()))
  }
  for i in range(parts.len()) {
    if i > 0 { pagebreak(weak: true) }
    caption(meta, titles.at(i))
    md(parts.at(i).trim())
    signature(meta)
  }
}
