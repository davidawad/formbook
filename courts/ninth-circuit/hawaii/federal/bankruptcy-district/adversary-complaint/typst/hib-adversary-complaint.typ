// U.S. Bankruptcy Court, District of Hawaii: complaint initiating an adversary proceeding.
//
// Rule-driven and content-agnostic. The rules are quoted in ../README.md. No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The body is rendered by cmarker from the
// markdown after the YAML frontmatter of the sample (schema: ../README.md).
//
// The Adversary Proceeding Cover Sheet (Official Form 1040) is a separate form (LBR 7003-1) and is not
// part of this template.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // vendored in /fonts; the local rules name no typeface
#let type-size = 14pt                     // LBR 9004-1(b)(1) sets 14-point for memoranda (not complaints); 14 pt matches the filed exemplar
#let body-leading = 1em                   // LBR 9004-1(b)(2): double spacing. Line pitch 2.3 em, as in the motion template
#let single-leading = 0em                 // counsel block, caption, quotations, footnotes (LBR 9004-1(b)(2) exceptions)
#let blank-line = 1.31em                  // one single-spaced blank line
#let margin = 1in                         // LBR 9004-1(b)(3): margins 1 inch from the edge
#let para-indent = 0.5in
#let page-number-size = 12pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hib-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption, title of the paper (LBR 9004-1; FRBP 7010)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (identification of counsel is exempt from double spacing).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
  if "counsel_role" in meta { v(blank-line); emph(inl(meta.counsel_role)) }
}

/// One party group: its names, then its designation, indented under the names.
#let caption-side(side) = {
  for n in side.names { inl(n); parbreak() }
  pad(left: 1.8in, inl(side.designation))
}

/// Caption. Left: the bankruptcy case lines, then the adversary parties ("v." between groups). Right:
/// the adversary number and the title of the paper. One unbreakable table, so no cell is torn.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let bankruptcy = meta.at("bankruptcy", default: ())
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for l in bankruptcy { inl(l); linebreak() }
    if bankruptcy.len() > 0 { v(blank-line) }
    for (i, side) in sides.enumerate() {
      if i > 0 {
        align(center)[v.]
        v(blank-line)
      }
      caption-side(side)
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "adversary_number")]
    v(blank-line)
    strong(upper(inl(need(meta, "title"))))
  }
  // The left cell may break across pages: the caption is long and follows the counsel block on page 1.
  table(
    columns: (1fr, 1fr), inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    table.cell(breakable: true, pad(right: 1.2em, bottom: 1em, left)),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

/// First page: counsel, court title and caption. The complaint's text follows on the same page and
/// runs on past the caption, as in the filed exemplar; there is no page break after the caption.
#let cover-content(meta) = {
  counsel-block(meta)
  v(blank-line)
  {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(center, strong(upper(
      need(meta, "court").map(l => [#l]).join(linebreak())
    )))
  }
  v(blank-line)
  caption-table(meta)
  v(blank-line)
}

// ---------------------------------------------------------------------------
// Signature block (no local rule text on signatures; convention per the exemplar)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  block(breakable: false, above: blank-line, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [DATED: #need(meta, "date")]
    v(blank-line)
    grid(columns: (1fr, 3.2in), [], {
      for (i, b) in blocks.enumerate() {
        if i > 0 { v(blank-line) }
        for l in b { inl(l); linebreak() }
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let running-footer = context {
  set text(size: page-number-size)
  align(center, numbering(here().page-numbering(), ..counter(page).get()))
}

#let hib-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "counsel", "adversary_number", "title", "signature", "date") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter")   // LBR 9004-1(a)(2): 8 1/2 x 11 inch
  set document(title: need(meta, "title"))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings in the body are centered and bold, as in the filed complaint (Counts, sections).
  show heading: it => block(width: 100%, above: blank-line, below: blank-line, sticky: true,
    align(center, strong(it.body)))

  // Quotations are single-spaced and indented from both margins (LBR 9004-1(b)(2) exception).
  show quote.where(block: true): it => block(width: 100%, above: blank-line, below: blank-line,
    pad(left: 0.5in, right: 0.5in,
      par(first-line-indent: 0pt, leading: single-leading, it.body)))

  page(numbering: "1", footer: running-footer, margin: margin, {
    counter(page).update(1)
    cover-content(meta)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
