// Adversary complaint for the United States Bankruptcy Court, Northern District of Florida (flnb).
// Rules (primary sources, verified 2026-10-14 against the Local Rules effective Feb. 26, 2024 and the
// District Local Rules, PDF version effective Nov. 24, 2015): Bankr. N.D. Fla. LBR 1001-1(B)-(C) (the
// District Local Rules apply in all bankruptcy cases, adversary proceedings included); LBR 7001-1 (complaint
// begins with an adversary proceeding cover sheet, caption conforms to the Official Form); LBR 9004-1(A)-(B)
// (caption and title, designation of the party, prayer for injunctive relief in the title); District LR
// 5.1(B)-(D) (case style, heading, 14-point double-spaced, 1-inch margins, numbered pages, signature block).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif" // District LR 5.1 names no face; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 14pt              // District LR 5.1(C): at least 14-point font
#let body-leading = 1.65em         // District LR 5.1(C): double spaced; baseline pitch about 32 pt at 14 pt, as in the filed exemplar
#let single-leading = 0.45em       // caption, counsel block, signature block
#let margin = 1in                  // District LR 5.1(C): at least one inch on all four sides
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One caption block: a stack of single-spaced lines, each taken from the frontmatter.
#let lines-block(items) = stack(dir: ttb, spacing: single-leading, ..items.map(t => [#t]))

/// The caption (LBR 9004-1(A); Official Form B 416D layout): court name, then the case style.
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, lines-block(meta.court.map(t => upper(t))))
  v(1.5em)
  grid(
    columns: (text-width * 0.62, 1fr),
    gutter: 1em,
    lines-block(meta.debtor_style),
    lines-block(meta.debtor_numbers),
  )
  v(1em)
  grid(
    columns: (text-width * 0.62, 1fr),
    gutter: 1em,
    lines-block(meta.adversary_style),
    lines-block(meta.adversary_numbers),
  )
  v(1.5em)
}

/// Signature block (District LR 5.1(D)): counsel block plus the attorney's signature and bar details.
#let signature(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  v(1.5em)
  pad(left: text-width * 0.45, lines-block(meta.signature))
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,         // District LR 5.1(C): pages must be numbered
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: 0.5in)
  // Headings stay with the paragraph that follows them (sticky), so none is left alone at a page foot.
  show heading.where(level: 2): it => block(sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    v(0.8em)
    align(center, text(weight: "bold", it.body))
    v(0.4em)
  })
  show heading.where(level: 3): it => block(sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    v(0.6em)
    align(center, text(weight: "bold", it.body))
    v(0.3em)
  })
  show heading.where(level: 4): it => block(sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, it.body)
    v(0.6em)
  })

  caption(meta)

  // Title (LBR 9004-1(A)): designation, the contents of the paper, and the required words.
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, text(weight: "bold", lines-block(meta.title_lines)))
  v(1.5em)

  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0.5in)
  inl(body)

  signature(meta)
}
