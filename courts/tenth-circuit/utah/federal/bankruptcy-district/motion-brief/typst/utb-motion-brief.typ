// Motion with supporting memorandum for the United States Bankruptcy Court for the District of Utah (utb).
// LBR 9013-1: the motion and any supporting memorandum are one document; DUCivR 10-1 (format; applies in
// bankruptcy through LBR 1001-1(a)); DUCivR 7-1 (word limit and certificate of compliance). See ../README.md
// for the citations and the status of each rule. Content-agnostic: every case-specific word comes from the sample.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // DUCivR 10-1: clearly legible; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                     // DUCivR 10-1 and LBR 5005-3(a)(4): minimum 12 point
#let pitch = 24pt                         // DUCivR 10-1: double-spaced; a 24 pt baseline pitch at 12 pt
#let body-leading = 1.345em               // Liberation Serif's line box is 0.655em (measured), so 1.345em leading = 24 pt pitch
#let single-leading = 0.65em              // typst's default leading: single-spaced (caption, counsel, signature)
#let top-margin = 1.5in                   // DUCivR 10-1: top margin of at least 1 1/2 inches
#let side-margin = 1in                    // DUCivR 10-1, LBR 5005-3(a)(3): left and right at least 1 inch
#let bottom-margin = 1in                  // holds the page number
#let text-width = 8.5in - 2 * side-margin
#let para-indent = 0.5in                  // first-line indent of body paragraphs
#let caption-left = 3.3in                 // width of the party column of the caption
#let footnote-size = 12pt                 // DUCivR 10-1: the 12 point minimum includes footnotes

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Headings are blocks kept with the text after them.
// Typst adds leading only between lines, so a block's bottom edge is one descent above the baseline: `below`
// restores the leading, which keeps the next line on the 24 pt pitch.
#let heading-block(c) = block(width: text-width, above: pitch, below: body-leading, sticky: true, c)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Arabic page number at the bottom center.
#let folio() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: counsel block, court title, caption (Form 416D), title
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = (
    text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"),
    text(weight: "bold", "DISTRICT OF UTAH"),
  )
  if "division" in meta and meta.division != none {
    lines.push(text(weight: "bold", upper(meta.division) + " DIVISION"))
  }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines))
}

/// Form 416D: the debtor, then the adversary parties (and any third-party claim);
/// on the right the case numbers and the judge.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let parts = ([In re:], [ ])
    for d in meta.caption.debtors {
      parts.push(inl(d))
    }
    parts += ([ ], [#inl(meta.caption.debtor_designation)], [ ])
    let groups = meta.caption.parties
    if "third_party" in meta.caption and meta.caption.third_party != none {
      groups = groups + meta.caption.third_party
    }
    for (k, p) in groups.enumerate() {
      if k > 0 { parts += ([ v. ], [ ]) }
      for n in p.names { parts.push(inl(n)) }
      parts += ([ ], [#inl(p.designation)], [ ])
    }
    set par(leading: single-leading, spacing: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading, ..parts)
  }),
  block(inset: (left: 0.15in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    let bk = if meta.case.bankruptcy_number == "" { "________" } else { meta.case.bankruptcy_number }
    let adv = if meta.case.adversary_number == "" { "________" } else { meta.case.adversary_number }
    stack(dir: ttb, spacing: single-leading,
      [Bankruptcy No. #bk],
      [Chapter #meta.case.chapter],
      [ ],
      [Adversary Proceeding No. #adv],
      [ ],
      [Hon. #(meta.case.judge)],
    )
  }),
)

#let cover(meta) = {
  line-stack(meta.counsel)
  v(pitch)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  block(width: text-width, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    align(center, text(weight: "bold", upper(meta.title)))
  })
  v(pitch)
}

// ---------------------------------------------------------------------------
// Signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  v(pitch)
  grid(
    columns: (3.2in, 1fr),
    column-gutter: 0.2in,
    [DATED #(meta.signature.date).],
    stack(dir: ttb, spacing: single-leading,
      [#meta.signature.firm],
      [ ],
      [/s/ #meta.signature.signer],
      ..meta.signature.lines.map(i => inl(i)),
    ),
  )
})

// ---------------------------------------------------------------------------
// Body: the motion and its memorandum, one document (LBR 9013-1)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is a heading (kept with the chunk after it), a markdown
/// list, a body paragraph, or one of two markers: <!-- SIGNATURE --> places the signature block, <!-- PAGEBREAK -->
/// starts a new page (the certificates). Paragraphs are not numbered: a memorandum is not an allegation.
#let body-blocks(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last-para = i + 1 < chunks.len() and chunks.at(i + 1).trim() == "<!-- SIGNATURE -->"
    if t == "<!-- SIGNATURE -->" {
      // Emitted with the paragraph before it (see last-para below): every marker follows a paragraph.
      none
    } else if t == "<!-- PAGEBREAK -->" {
      pagebreak(weak: true)
    } else if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading, first-line-indent: 0pt)
        md(t)
      })
    } else if last-para {
      // The paragraph before a signature stays on the signature's page: a signature alone is not a filing.
      block(width: text-width, above: 0pt, below: 0pt, breakable: false, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        md(t)
        signature-block(meta)
      })
    } else {
      // A leading space, not `first-line-indent`: cmarker's paragraphs do not take the par setting.
      block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        md(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let utb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    footer: folio(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading)

  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", it.body))

  cover(meta)
  body-blocks(meta, body)
}
