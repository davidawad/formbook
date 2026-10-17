// Memorandum of law for a motion in the United States District Court for the District of Minnesota.
// Rules: D. Minn. LR 5.2(a) (double-spaced, pages numbered at the bottom, case number and judge
// initials on the front page above the title), LR 7.1(f) (12,000-word limit; certificate of
// compliance), LR 7.1(h) (13-point type including footnotes, 8 1/2 by 11 in, text inside 6 1/2 by 9 in).
// Fed. R. Civ. P. 10(a) caption. See ../README.md for the verified rule text and the open choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 7.1(f)(1)(A): word limit for a proportional font; vendored in fonts/
#let type-size = 13pt                   // LR 7.1(h)(1): at least 13-point, footnotes included
#let page-w = 8.5in                     // LR 7.1(h)(1): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // LR 7.1(h)(1): no text outside 6 1/2 by 9 inches, so 1 inch on every side
#let text-width = page-w - 2 * margin
#let body-leading = 1.65em              // LR 7.1(h)(1) double spacing: 0.65em natural line + 1.65em = 2.3em (two 1.15em lines)
#let single-leading = 0.5em             // headings, footnotes and long quotations may be single-spaced: 0.5em + 0.65em = 1.15em
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let word-limit = 12000                 // LR 7.1(f)(1)(A)
#let court-lines = ("UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA")  // the court's name, not the case's

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names in captions and signature blocks).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture: page number at the bottom centre, inside the bottom margin (LR 5.2(a)).
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Front page: court name, caption (party column, case number and title), no cover page
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading, ..court-lines.map(l => text(weight: "bold", l))))
}

#let caption(meta) = grid(
  columns: (3.3in, 1fr),
  column-gutter: 0.3in,
  block(width: 3.3in, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: 8pt, bottom: 8pt), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.enumerate() {
      if k > 0 { rows.push(block(width: 100%, inset: (left: 0.3in), [v.])) }
      rows.push(line-stack(p.names))
      rows.push(block(width: 100%, inset: (left: 1.2in), inl(p.designation)))
    }
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading, ..rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    [Court File No. #meta.case_number]
    v(body-leading)
    align(center, text(weight: "bold", upper(meta.brief_title)))
    v(body-leading)
    align(right, [#meta.rule_line])
  }),
)

#let front-page(meta) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: markdown with numbered-free paragraphs, indented first lines, double-spaced
// ---------------------------------------------------------------------------

/// Signature block: the date on the left, the firm and signer on the right (single-spaced).
#let signature-block(meta) = block(width: 100%, breakable: false, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    line-stack(meta.signature.map(l => if l == "" { "\u{00A0}" } else { l })),
  )
})

/// Certificate of compliance: its own page; excluded from the word count (LR 7.1(f)(1)(C)(v)).
#let certificate(meta) = {
  assert(int(meta.word_count) <= word-limit, message: "mnd-motion-brief: word_count is over the LR 7.1(f)(1)(A) limit of 12,000")
  pagebreak()
  align(center, text(weight: "bold", "CERTIFICATE OF COMPLIANCE"))
  v(body-leading)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: true)
  [I hereby certify that this memorandum complies with the word limit of D. Minn. LR 7.1(f)(1)(A) and the type-size requirement of D. Minn. LR 7.1(h)(1). The memorandum contains #meta.word_count words, counted with #meta.word_software, which was applied to include all text, including headings, footnotes, and quotations. The count excludes the caption, the signature block, and this certificate (LR 7.1(f)(1)(C)).]
  v(body-leading)
  block(width: 100%, breakable: false, {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    grid(columns: (2.6in, 1fr), column-gutter: 0.2in, [Dated: #meta.date], [#inl(meta.certificate_signer)])
  })
}

#let mnd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // spacing is the gap between paragraphs: it must equal the leading, or a new paragraph starts one line too high
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: true)

  // Headings: level 1 centred and bold (INTRODUCTION, CONCLUSION); level 2 and 3 bold, hanging,
  // single-spaced, kept with the text after them.
  show heading: set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    par(hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    pad(left: 0.5in, par(hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body))))

  // Block quotations longer than two lines: indented and single-spaced (LR 7.1(h)(1)).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in,
    block(width: 100%, above: body-leading, below: body-leading, {
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, justify: true)
      it.body
    }))

  // Footnotes are text too: 13-point, single-spaced (LR 7.1(h)(1)).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt, justify: true)

  front-page(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  v(body-leading)
  signature-block(meta)
  certificate(meta)
}
