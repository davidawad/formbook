// U.S. Bankruptcy Court, N.D. Georgia: motion with memorandum of law (adversary proceeding or contested matter).
//
// Rule-driven and content-agnostic. Requirement IDs (GANB-...) refer to ../README.md, which quotes or cites the
// rules (Fed. R. Bankr. P. 7008, 7010, 9004, 9013; Bankr. N.D. Ga. BLR 5005-1 and 7007-1). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // GANB-FORM-002: legible proportional serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // GANB-FORM-002: no size in FRBP 9004(a); 12 pt, the usual floor (Times New Roman substitute, docs/FONTS.md).
#let single-leading = 0.495em            // single spacing: Liberation Serif's line box is 0.655em, so the pitch is 1.15em
#let body-leading = 1.07em              // GANB-FORM-003: one and one-half spacing, 1.5 x single pitch = 1.725em = 0.655em + this gap
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.3in              // the ")" column between parties and case information
#let page1-caption-gap = 0.4in          // GANB-FORM-001: page 1 leaves a 2 in x 2 in clear area at the upper right for the filing stamp
#let footer-size = 11pt                 // page number only (GANB-FORM-005)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (body, footnotes, inline markup) to content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ganb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block: counsel, caption, title and signature blocks.
#let single-spaced(body) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  body
}

// ---------------------------------------------------------------------------
// Parts of the first page
// ---------------------------------------------------------------------------

/// Court title, centred, from `court_title:` (one list item per line).
#let court-title(meta) = align(center, single-spaced(stack(
  dir: ttb, spacing: 0.5em, ..meta.at("court_title").map(l => strong(upper(l))),
)))

/// Caption: each row of `caption:` is [left, right]; a ")" column separates them (GANB-FIRST-001).
#let caption(meta) = {
  let cells = ()
  for r in meta.at("caption") {
    cells += (r.at(0), [)], r.at(1))
  }
  single-spaced(grid(
    columns: (caption-left, caption-paren, 1fr),
    row-gutter: 0.5em,
    ..cells,
  ))
}

/// Document title, centred and capitalised, from `title:` (one list item per line).
#let doc-title(meta) = align(center, block(above: 1.1em, below: 1.1em, single-spaced(stack(
  dir: ttb, spacing: 0.5em, ..meta.at("title").map(l => strong(upper(l))),
))))

// ---------------------------------------------------------------------------
// Signature and certificate (GANB-SIG-001, GANB-SIG-002)
// ---------------------------------------------------------------------------

/// Counsel signature block: `signature.dated` (optional), then `signature.lines` (firm, "/s/" line,
/// name, Georgia Bar number, address, telephone, e-mail, "Attorney for ...") indented to the right half.
#let signature-block(sig, dated: true) = block(width: 100%, above: 1.2em, breakable: false, single-spaced({
  if dated and "dated" in sig {
    [#sig.at("dated")]
    v(1.2em)
  }
  pad(left: 3.25in, stack(dir: ttb, spacing: 0.5em, ..sig.at("lines").map(l => [#l])))
}))

/// Certificate of service: heading, text from `certificate:` (markdown), and the counsel block.
#let certificate(meta) = if "certificate" in meta {
  block(above: 1.5em, breakable: false, {
    align(center, strong[CERTIFICATE OF SERVICE])
    v(0.6em)
    md(meta.at("certificate"))
    signature-block(meta.at("signature"), dated: false)
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let ganb-motion-brief(meta, body) = {
  set document(title: meta.at("title").join(" ") + " (" + meta.at("court_title").last() + ")")
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, fallback: false, lang: "en")
  set par(leading: body-leading, first-line-indent: para-indent, justify: false)
  set heading(numbering: none)
  set quote(block: true)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0.9em, below: 0.7em, sticky: true,
    single-spaced(strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 0.8em, below: 0.6em, sticky: true,
    single-spaced(strong(emph(it.body))))
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 0.8em,
    single-spaced(it.body))

  // Page 1: court title, then the caption below the 2 in filing-stamp area, then the title of the paper.
  court-title(meta)
  v(page1-caption-gap)
  caption(meta)
  v(0.6em)
  line(length: 100%, stroke: 0.8pt)
  doc-title(meta)

  // Body: markdown, paragraphs indented, no numbers (motions are not numbered pleadings).
  md(body)

  signature-block(meta.at("signature"))
  certificate(meta)
}
