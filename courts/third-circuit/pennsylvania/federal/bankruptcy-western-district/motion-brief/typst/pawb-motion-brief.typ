// Brief in support of a motion (memorandum) in an adversary proceeding, U.S. Bankruptcy Court, W.D. Pennsylvania (pawb).
// Rules: Fed. R. Bankr. P. 9013 (a request for an order is made by written motion; grounds stated with particularity), 7010 (FRCP 10 applies; caption per
// Official Form 416D), W.PA LBR 7010-1(a)-(b) (caption with the judge's initials; short descriptive title), 7008-1(c)
// (proposed order attached to a motion: a separate filing), 7008-1(e) (briefs limited to 20 pages), 5005-13(b) (8.5 x 11,
// sequential page numbers, 12-point type or larger including footnotes, text-searchable PDF; paragraph numbering does
// not apply to briefs), 5005-6(d) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; the only fonts typst may see (--ignore-system-fonts)
#let type-size = 12pt                   // LBR 5005-13(b)(4): "no smaller than 12 Courier or an equivalent font size", footnotes included; 12 pt Liberation Serif (a Times New Roman substitute) is the usual equivalent
#let page-w = 8.5in                     // LBR 5005-13(b)(1): 8.5 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // convention (the exemplar); no W.PA rule sets margins
#let body-leading = 1.345em             // double spacing: Liberation Serif line box 0.655em + 1.345em = 24 pt at 12 pt
#let single-leading = 0.5em             // single spacing: caption, blocks, quotations, footnotes, signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the debtor and party column of the caption
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Sequential page numbers, centered in the bottom margin (LBR 5005-13(b)(2)); page 1 is numbered too.
#let page-footer() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, Form 416D caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => text(i)))
}

#let caption(meta) = {
  align(center, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    text(weight: "bold", [IN THE UNITED STATES BANKRUPTCY COURT])
    linebreak()
    text(weight: "bold", [FOR THE WESTERN DISTRICT OF PENNSYLVANIA])
  })
  v(1.5em)
  // Form 416D layout: a boxed left column (debtor, then the parties) and a right column (case number and
  // chapter, then the adversary number). Each row is one grid row, so the boxes meet with no gap.
  let parties = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { parties.push(v(single-leading)) }
    for n in p.names { parties.push(text(n) + linebreak()) }
    parties.push(h(1.5in) + text(p.designation))
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, top: 0.75pt), inset: (right: 10pt, top: 6pt), {
      [In re:]
      linebreak()
      [#meta.debtor.name]
      linebreak()
      [#h(1.5in)#meta.debtor.designation]
    }),
    block(inset: (top: 6pt), [Case No. #meta.bankruptcy_case]
      + linebreak() + [#meta.chapter]),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, top: 1em, bottom: 6pt), {
      parties.join()
    }),
    block(inset: (top: 1.5em), if "adversary_number" in meta and meta.adversary_number != "" {
      [Adv. Proc. No. #meta.adversary_number]
    } else {
      [Adv. Proc. No. \_\_\_\_\_\_\_\_\_\_\_\_\_\_]
    }),
  )
  v(1.5em)
  // LBR 7010-1(b): a short, concise descriptive title in addition to the adversary caption.
  align(center, text(weight: "bold", inl(meta.title)))
  v(1em)
}

// ---------------------------------------------------------------------------
// Signature block (LBR 5005-6(d)): the filing user's name is preceded by "/s/"; the firm, then each attorney's
// Bar ID, address, phone and e-mail. Only the filing user's name carries "/s/".
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  v(body-leading)
  [Respectfully submitted,]
  v(body-leading)
  if "firm" in meta.signature {
    line-stack(meta.signature.firm)
    v(body-leading)
  }
  for (k, b) in meta.signature.blocks.enumerate() {
    if k > 0 { v(body-leading) }
    let first = if b.sign { "/s/" + b.signer } else { b.signer }
    line-stack((first, b.pa_id) + b.lines)
  }
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let pawb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-footer(),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // Paragraph spacing equals the leading, so consecutive paragraphs keep the double-spaced pitch.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em, justify: false)

  // Headings (the sample's markdown levels): level 2 is a centered bold caps section ("I. OVERVIEW",
  // "CONCLUSION"); level 3 a bold heading at the margin ("A. ..."); level 4 a bold italic heading ("1. ...").
  // Each stays on the page with the text after it. Headings are not indented, justified or hyphenated.
  show heading.where(level: 2): it => block(width: text-width, above: 1.35em, below: 0.6em, sticky: true,
    align(center, par(first-line-indent: 0pt, justify: false, text(weight: "bold", size: type-size, hyphenate: false, upper(it.body)))))
  show heading.where(level: 3): it => block(width: text-width, above: 1em, below: 0.6em, sticky: true,
    par(first-line-indent: 0pt, justify: false, text(weight: "bold", size: type-size, hyphenate: false, it.body)))
  show heading.where(level: 4): it => block(width: text-width, above: 1em, below: 0.6em, sticky: true,
    par(first-line-indent: 0pt, justify: false, text(weight: "bold", style: "italic", size: type-size, hyphenate: false, it.body)))

  // Block quotations are single-spaced and indented half an inch on each side.
  show quote.where(block: true): it => {
    v(0.5em)
    pad(x: 0.5in, {
      set par(leading: single-leading, spacing: 0.6em, first-line-indent: 0pt)
      it.body
    })
    v(0.5em)
  }

  caption(meta)

  // Body: one markdown pass, so footnote references and their definitions stay linked (no paragraph numbering).
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
}
