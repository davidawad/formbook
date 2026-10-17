// Memorandum of law supporting a motion in an adversary proceeding, United States Bankruptcy Court
// for the District of Delaware. Rules: Del. Bankr. L.R. 7007-1 (no notice of motion in an adversary
// proceeding; opening brief filed with the motion), 7007-2(a)(i) (cover contents), 7007-2(a)(ii) (format),
// 7007-2(a)(iv) (length), 7007-2(b) (contents, in order); Del. Bankr. L.R. 9004-1(a) (caption contents);
// Fed. R. Bankr. P. 9004(a) (legible), 7008 (consent statement, see ../README.md). Content-agnostic:
// every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
// LR 7007-2(a)(ii) requires Courier New or Times New Roman. Times New Roman is set through its
// vendored substitute, Liberation Serif (metric-compatible; docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                    // LR 7007-2(a)(ii): at least 12-point typeface
#let body-leading = 1.345em              // LR 7007-2(a)(ii): double-spaced: Liberation Serif line box 0.655em + 1.345em = 24 pt at 12 pt
#let single-leading = 0.5em              // single spacing for captions, cover, block quotes, counsel and signature
#let page-w = 8.5in                      // FRBP 9004 / LR 7007-2: letter-size paper
#let page-h = 11in
#let margin = 1in                        // LR 7007-2(a)(ii): side margins not less than 1 inch (all sides used here)
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                 // first-line indent of body text
#let caption-left = 3.4in                // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("deb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let page-setup(body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1",
    footer: context align(center, text(size: type-size, counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, justify: false)
  body
}

// ---------------------------------------------------------------------------
// Cover (LR 7007-2(a)(i)): caption, title, date of filing, party, counsel
// ---------------------------------------------------------------------------

/// Caption (FRBP 7010 applies FRCP 10 and Official Form 416; LR 9004-1(a): debtor, case number, judge
/// initials, adversary number). One block per proceeding: the bankruptcy caption, then the adversary.
#let caption-block(parties, right) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    for (k, p) in parties.enumerate() {
      if k > 0 { rows.push("") }
      rows += p.names
      if "designation" in p { rows.push(p.designation) }
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.15in), line-stack(right)),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", upper(meta.court)))
  v(body-leading)
  caption-block(meta.caption.bankruptcy.parties, meta.caption.bankruptcy.right)
  v(body-leading)
  caption-block(meta.caption.adversary.parties, meta.caption.adversary.right)
  v(body-leading * 1.5)
  align(center, text(weight: "bold", inl(meta.title)))
  v(body-leading)
  align(center, text(meta.party_designation))
  v(1fr)
  grid(
    columns: (1fr, 3.3in),
    [Dated: #meta.date],
    line-stack(meta.counsel),
  )
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(body-leading)
  block(breakable: false, grid(
    columns: (2.4in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date \ #meta.signature.place],
    {
      for b in meta.signature.blocks {
        line-stack(b.firm)
        v(single-leading)
        line-stack(b.attorneys)
        v(body-leading)
      }
    },
  ))
}

/// Body styles: centred bold section headings (level 1), bold left headings (level 2 and 3), body text
/// double-spaced with a first-line indent, block quotes single-spaced and indented.
#let body-styles(body) = {
  show heading.where(level: 1): it => block(above: body-leading, below: body-leading, width: text-width,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: body-leading, below: body-leading, width: text-width,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(above: body-leading, below: body-leading, width: text-width,
    align(center, text(weight: "bold", upper(it.body))))
  show quote: it => block(width: text-width, inset: (x: 0.5in), above: body-leading * 0.5, below: body-leading,
    {
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      it.body
    })
  set par(first-line-indent: para-indent, spacing: body-leading)
  body
}

/// Table of contents (LR 7007-2(b)(i)(A)): generated from the body's level 1 and 2 headings, with page
/// numbers. Level 3 headings (the table of authorities) stay out of it.
#let toc() = {
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(body-leading)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  outline(title: none, depth: 2, indent: 0.5in)
  pagebreak()
}

#let deb-motion-brief(meta, body) = {
  page-setup({
    cover(meta)
    toc()
    body-styles({
      cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    })
    signature-block(meta)
  })
}
