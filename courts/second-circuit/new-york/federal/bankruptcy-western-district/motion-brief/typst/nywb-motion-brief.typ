// Motion with memorandum of law for the United States Bankruptcy Court, Western District of New York (nywb).
// Rules: Fed. R. Bankr. P. 9004(b) (caption), 9013(a)-(b) (written motion, grounds stated with particularity),
// 7012(b) (Civil Rule 12(b)-(i) applies in an adversary proceeding); W.D.N.Y. LBR 9004-1 (letter-size paper),
// 9004-2 (caption with the judge's initial; date, signature, name, address and telephone), 9013-1 (notice and
// memoranda filed at least five days before the return date). See ../README.md for the source, date and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // no W.D.N.Y. font rule (LBR 9004-1 says only "plainly and legibly written"); Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // convention: 12 point, as the filed exemplar (Times New Roman 12 pt)
#let page-w = 8.5in                     // LBR 9004-1: letter size paper
#let page-h = 11in
#let margin = 1in                       // convention: one-inch margins on every side (no W.D.N.Y. margin rule)
#let body-leading = 1.645em             // convention: double spacing; Liberation Serif line box 0.655em + 1.645em = 2.3em = 27.6 pt at 12 pt, the exemplar's pitch
#let single-leading = 0.5em             // single spacing for the caption, counsel block and signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let block-gap = 1.645em                // space between a heading and the text it introduces (one double-spaced line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item: each item is a block, and the stack keeps the single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, counsel block (W.D.N.Y. LBR 9004-2; Rule 9004(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.court_name {
    align(center, text(weight: "bold", upper(line)))
    linebreak()
  }
  v(single-leading * 2)
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("") ; rows.push("v.") ; rows.push("") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + meta.case_number,) + if "chapter" in meta { (meta.chapter,) } else { () })
    if "adv_number" in meta and meta.adv_number != none {
      v(single-leading * 1.5)
      line-stack(("Adv. Proc. No. " + meta.adv_number,))
    }
    v(single-leading * 2)
    text(weight: "bold", inl(meta.brief_title))
  }),
)

#let counsel-block(meta) = {
  v(single-leading * 3)
  align(left, pad(left: caption-left + 0.25in, line-stack(meta.counsel)))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  if "counsel" in meta and meta.counsel != none { counsel-block(meta) }
  pagebreak()
}

// ---------------------------------------------------------------------------
// Front matter: table of contents (generated from the headings: page numbers are not typed in)
// ---------------------------------------------------------------------------

#let toc() = {
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(single-leading * 2)
  set par(leading: single-leading, spacing: 0pt, justify: false)
  show outline.entry: it => {
    v(single-leading)
    it
  }
  outline(title: none, depth: 3, indent: 0.4in)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(body-leading)
  block(breakable: false, grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(meta.signature.firm)
      v(single-leading * 2)
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  ))
}

#let nywb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing equals the leading: typst applies leading only between the lines of one paragraph, so a
  // zero paragraph spacing lets one-line paragraphs overprint the next (measured, README.md).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered bold caps; level 2 bold; level 3 bold italic. Kept with the text after them.
  show heading.where(level: 1): it => block(width: 100%, above: block-gap, below: block-gap, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: block-gap, below: block-gap, sticky: true,
    par(hanging-indent: 0.5in, first-line-indent: 0pt, spacing: 0pt, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: block-gap, below: block-gap, sticky: true,
    par(hanging-indent: 0.5in, first-line-indent: 0pt, spacing: 0pt, text(weight: "bold", style: "italic", it.body)))

  // Cover: no page number.
  cover(meta)

  // Front matter: table of contents, lower-case roman page numbers from i.
  set page(numbering: "i")
  counter(page).update(1)
  toc()
  pagebreak()

  // Body: arabic page numbers from 1, centered at the foot of each page.
  set page(numbering: "1")
  counter(page).update(1)
  // Every body paragraph is indented, including the first after a heading (the exemplar does the same).
  set par(first-line-indent: (amount: para-indent, all: true))
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
}
