// U.S. Bankruptcy Court, District of Hawaii: complaint initiating an adversary proceeding.
// Fed. R. Bankr. P. 7010 (FRCP 10 applies; the caption follows Form 416), 7008 (jurisdiction and
// consent to final orders), LBR 9004-1 (form of papers), LBR 7003-1 (cover sheet, filed separately).
//
// Rule-driven and content-agnostic. Requirement IDs (HIB-ADV-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // vendored in /fonts; the local rules name no typeface
#let type-size = 12pt                    // HIB-ADV-FORM-002: no local rule sets the type size of a complaint
                                         // (LBR 9004-1(b)(1) covers memoranda only); tier 2: a clerk's 12-point convention
#let body-leading = 1em                  // HIB-ADV-FORM-003: double spacing. Line pitch is 2.3 em (natural line 1.31 em + this gap)
#let single-leading = 0em                // counsel block, caption, block quotations, footnotes
#let blank-line = 1.31em                 // one single-spaced blank line
#let margin = 1in                        // HIB-ADV-FORM-004: LBR 9004-1(b)(3): margins 1 inch from the edge
#let para-indent = 0.5in
#let quote-indent = 0.75in
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
// Cover: counsel, court title, caption, title of the paper (HIB-ADV-FORM-001, -005)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (identification of counsel is exempt from double spacing;
/// LBR 9004-1(b)(2)).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
  if "counsel_role" in meta { emph(inl(meta.counsel_role)) }
}

/// One party: its names, then its designation.
#let caption-side(side) = {
  for n in side.names { inl(n); parbreak() }
  pad(left: 1.8in, inl(side.designation))
}

/// Caption (FRBP 7010; FRCP 10(a); FRBP 9004(b)). Row 1: the bankruptcy case lines (if any), the first
/// party, and on the right the adversary number and the title of the paper. Row 2: the remaining
/// parties ("v."), with the rule closing the party column. The rows are separate unbreakable blocks,
/// so a row moves whole to the next page and no cell is torn.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let bankruptcy = meta.at("bankruptcy", default: ())
  let row1-left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for l in bankruptcy { inl(l); linebreak() }
    if bankruptcy.len() > 0 { v(blank-line) }
    caption-side(sides.at(0))
  }
  let row1-right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "adversary_number")]
    v(blank-line)
    strong(upper(inl(need(meta, "paper_title"))))
  }
  let row2-left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for side in sides.slice(1) {
      align(center)[v.]
      v(blank-line)
      caption-side(side)
    }
  }
  let cols = (1fr, 1fr)
  stack(
    dir: ttb, spacing: 0pt,
    block(breakable: false, table(
      columns: cols, inset: 0pt,
      stroke: (x, y) => if x == 0 { (right: 0.7pt) } else { none },
      pad(right: 1.2em, bottom: 1em, row1-left),
      pad(left: 1.2em, top: 0.3em, row1-right),
    )),
    if sides.len() > 1 {
      block(breakable: false, table(
        columns: cols, inset: 0pt,
        stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
        pad(right: 1.2em, bottom: 1em, row2-left),
        pad(left: 1.2em, top: 0.3em, []),
      ))
    },
  )
}

#let cover(meta) = {
  counsel-block(meta)
  v(blank-line)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(blank-line)
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Signature block (HIB-ADV-FORM-007: convention; no local rule text on signatures)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  block(breakable: false, above: blank-line, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [DATED: #need(meta, "date")], {
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
  let p = counter(page).get().first()
  // The caption page carries no number (the first page is page 1, as in the filed exemplar).
  if p > 1 {
    set text(size: page-number-size)
    align(center, numbering("1", p))
  }
}

#let hib-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "counsel", "adversary_number", "paper_title", "signature", "date") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margin, numbering: "1", footer: running-footer)   // LBR 9004-1(a)(2)
  set document(title: need(meta, "paper_title"))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: centered and bold (the filed exemplar's section and count headings). Level 1 is a title.
  show heading: it => block(width: 100%, above: blank-line, below: blank-line, sticky: true,
    align(center, par(first-line-indent: 0pt, leading: single-leading, strong(
      if it.level == 1 { upper(it.body) } else { it.body }
    ))))

  // Block quotations of a lease or statute: single-spaced, indented both sides (HIB-ADV-FORM-003).
  show quote.where(block: true): it => block(
    width: 100%, above: blank-line, below: blank-line,
    inset: (left: quote-indent - para-indent, right: quote-indent - para-indent),
    par(first-line-indent: 0pt, leading: single-leading, justify: false, it.body),
  )

  cover(meta)
  v(blank-line)
  align(center, strong(upper(inl(need(meta, "paper_title")))))
  v(blank-line)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
}
