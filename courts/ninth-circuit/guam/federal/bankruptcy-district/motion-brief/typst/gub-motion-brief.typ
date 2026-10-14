// Motion with memorandum for the United States Bankruptcy Court, District of Guam (gub).
// Rules: GNLR 5.1 (8 1/2 x 11, page numbers at the bottom, double spacing except counsel, title, footnotes,
// quotations; counsel block upper left; court title at least 3 inches from the top; right-hand case
// information including the designation and a mention of the memorandum in support); Fed. R. Bankr. P. 9013
// (written motion, grounds stated with particularity), 9011(a) (signer's address and telephone), 7010 (caption).
// Local Bankruptcy Rule 9013-1(b): a motion with its memorandum is limited to 15 pages (not checked here).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no typeface is named by GNLR 5.1; a proportional serif, vendored in fonts/
#let type-size = 13pt                   // EB Garamond sets smaller than Times at the same size; 13 pt matches the exemplar's visual size
#let footnote-size = 11pt               // footnotes are exempt from double spacing (GNLR 5.1(a)); the size is a layout choice
#let page-w = 8.5in                     // GNLR 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // all four sides (the exemplar's ECF page has 1 in margins)
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // GNLR 5.1(a): double-spaced; with EB Garamond's line box this is a 2 em baseline pitch
#let single-leading = 0.5em             // counsel, caption, block quotations, footnotes, signature
#let para-indent = 0.5in
#let counsel-height = 2in               // GNLR 5.1(b): the court title starts 3 in from the top; the counsel block fills the first 2 in below the margin
#let caption-left = 3.3in               // the party column, left of the page's centre (GNLR 5.1(c)(1))

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gub-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item; the stack keeps the single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Counsel identification, upper left (GNLR 5.1(c)(1)). Its height is fixed, so the court title below it
/// starts exactly 3 in from the top of the page (GNLR 5.1(b)).
#let counsel-block(meta) = context {
  let h = measure(width: text-width / 2, line-stack(meta.counsel)).height
  assert(h <= counsel-height, message: "gub-motion-brief: the counsel block must end above the court title (GNLR 5.1(b))")
  block(width: text-width / 2, height: counsel-height, line-stack(meta.counsel))
}

/// GNLR 5.1(b): the court title, centred. Not case-specific.
#let court-title() = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "DISTRICT COURT OF GUAM"),
    text(weight: "bold", "TERRITORY OF GUAM"),
    text(weight: "bold", "BANKRUPTCY DIVISION"),
  ))
  v(0.5 * 2em)
}

/// The caption's party column: the lead lines, then each party with "vs." between the parties.
#let party-rows(caption) = {
  let rows = caption.lead
  for (k, p) in caption.parties.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  rows
}

/// The right-hand case information (GNLR 5.1(c)(3)): case number, chapter, the designation "Adversary
/// Proceeding", the adversary number, the title of the paper, and the memorandum in support.
#let case-info(meta) = {
  set par(first-line-indent: 0pt)
  let rows = ()
  rows.push("Case No. " + meta.case_number)
  if "chapter" in meta { rows.push(meta.chapter) }
  rows.push(" ")
  rows.push("Adversary Proceeding")
  rows.push("Adv. Proc. No. " + meta.adversary_number)
  line-stack(rows)
  v(0.5 * 2em)
  text(weight: "bold", inl(meta.brief_title))
  if "memorandum" in meta and meta.memorandum {
    v(0.5 * 2em)
    text(weight: "bold", "With Memorandum in Support")
  }
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(party-rows(meta.caption))
  }),
  block(inset: (left: 0.1in), case-info(meta)),
)

// ---------------------------------------------------------------------------
// Signature (GNLR 5.1(d): typed names below the signature line; Fed. R. Bankr. P. 9011(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [],
    {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
      [Respectfully submitted this #meta.date.]
      v(0.5 * 2em)
      line-stack(("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
    },
  )
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let gub-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Body paragraphs: double spaced, first-line indent (the caption, counsel and signature reset it below).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)

  // Headings: level 1 centred bold capitals; level 2 and 3 bold, left, the number typed by the author.
  show heading.where(level: 1): it => block(above: body-leading, below: body-leading, sticky: true, width: text-width,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: body-leading, below: body-leading, sticky: true, width: text-width,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(above: body-leading, below: body-leading, sticky: true, width: text-width,
    pad(left: 0.5in, par(hanging-indent: 0.5in, text(weight: "bold", it.body))))

  // Block quotations are single-spaced and indented (GNLR 5.1(a) exempts quotations from double spacing).
  show quote.where(block: true): it => block(width: text-width, inset: (left: 0.5in, right: 0.5in), above: 1em, below: 1em, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it.body
  })

  // Footnotes: single-spaced, smaller.
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Cover: counsel (upper left), court title (3 in from the top), caption, title of the paper.
  counsel-block(meta)
  court-title()
  v(1em)
  caption(meta)
  v(2em)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
}
