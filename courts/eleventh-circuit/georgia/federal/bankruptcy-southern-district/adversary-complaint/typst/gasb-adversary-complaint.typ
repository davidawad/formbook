// U.S. Bankruptcy Court, S.D. Georgia: adversary complaint (FRBP 7001, 7008, 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (GASB-...) refer to ../README.md, which quotes
// the rules and records the dates verified. No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes
// from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"    // Font: not set by any S.D. Ga. rule found (see ../README.md); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Convention: 12 pt, the size of the filed exemplars (no rule sets a size).
#let line-pitch = 24pt                   // GASB-FORM-002: double-spaced (LR 10.1, incorporated by the Uniformity of Practice clause).
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is line-pitch.
#let single-leading = 0.398em            // caption, counsel block, headings, footnotes, certificate.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // Style choice: no margin rule in the S.D. Ga. rules found; 1 inch is the usual floor.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let page-number-size = 11pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gasb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gasb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b); FRCP 10(a) through FRBP 7010)
// ---------------------------------------------------------------------------

/// Court title, centered, one line per entry of `court` (FRBP 9004(b)(1)).
#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(for l in need(meta, "court") { upper(inl(l)); linebreak() }))
}

/// Left cell: the debtor ("In re") block, then the parties of the adversary proceeding.
/// FRCP 10(a): the title of the complaint must name all the parties.
#let caption-left(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "in_re") { inl(l); linebreak() }
  pad(left: 1.2in, inl(meta.at("debtor_role", default: "Debtor.")))
  v(line-pitch * 0.5)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for n in side.names { inl(n); linebreak() }
    pad(left: 1.8in, inl(side.designation))
    if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
  }
}

/// Right cell: the case number, chapter, judge (if any) and adversary number (FRBP 9004(b)(3)).
/// A blank adversary number is printed as a blank to be filled in by the clerk.
#let caption-right(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [CASE NO. #need(meta, "case_number")]
  v(line-pitch * 0.5)
  [CHAPTER #need(meta, "chapter")]
  v(line-pitch * 0.5)
  if "judge" in meta { inl(meta.judge); v(line-pitch * 0.5) }
  let adv = meta.at("adversary_number", default: "")
  [ADV. PRO. NO. #if adv == "" { "_" * 11 } else { adv }]
}

#let caption-table(meta) = table(
  columns: (3.4fr, 2fr),
  inset: 0pt,
  stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
  pad(right: 1.2em, bottom: 1em, caption-left(meta)),
  pad(left: 1.2em, top: 0.3em, caption-right(meta)),
)

// ---------------------------------------------------------------------------
// Headings: unnumbered (complaint headings are titles, FRCP 10(b) numbers paragraphs, not headings)
// ---------------------------------------------------------------------------

// The author writes the paragraph numbers ("1.", "2.", ...) in the markdown. cmarker keeps them
// across headings, so the complaint's paragraphs run on through the claims.

// ---------------------------------------------------------------------------
// Signature block (LR 11.1: counsel name, address, telephone, State Bar number; FRBP 9011)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Respectfully submitted this #need(meta, "submitted_on").], {
      strong(sig.firm)
      v(line-pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("signer_lines", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      for l in sig.at("other_counsel_lines", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      emph(inl(need(sig, "role")))
      linebreak()
      for l in need(sig, "address") { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let gasb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "chapter", "in_re", "caption", "title", "signature", "submitted_on") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: context align(center, text(
    size: page-number-size, counter(page).display("1"),
  )))  // LR 10.1: every page is numbered from the first, the caption page included.
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set enum(numbering: "1.", indent: para-indent, body-indent: 0.4em)
  set heading(numbering: none)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  show heading: it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))

  // ---- caption page: the complaint starts on page 1 under the caption ----
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
}
