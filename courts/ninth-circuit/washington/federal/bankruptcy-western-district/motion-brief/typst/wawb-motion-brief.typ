// Motion with memorandum for the U.S. Bankruptcy Court, W.D. Washington (wawb).
// Rules: LBR 9004-1 (8-1/2 x 11, embedded font 11 or 12 point, double spaced, numbered lines, judge's name
// top right, bottom notation: abbreviated title and page number left, counsel right); LBR 9013-1(c)(3)(A)
// (the notice may be combined with the motion: the caption says so and the notice is the first part of the
// text); LBR 9013-1(d)(1)(B) (judge, chapter, location, date, time and response date noted top right);
// LBR 9013-1(d)(1)(C) (length of memoranda: 12 pages, or 24 for dispositive motions, without approval).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LBR 9004-1(a): standard embedded font; vendored in fonts/
#let type-size = 12pt                   // LBR 9004-1(a): 11 or 12 point
#let footer-size = 11pt                 // LBR 9004-1(a): the bottom notation is held to the same 11 point minimum
#let pitch = 24pt                       // LBR 9004-1(a): double spaced; the numbered lines are this pitch
#let lines-per-page = 28                // LBR 9004-1(b)(1): numbered paper; 28 lines (as in the sibling complaint template)
#let page-w = 8.5in                     // LBR 9004-1(a): 8-1/2 x 11 inch
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the bottom notation
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: a 24 pt baseline pitch at 12 pt (as in the sibling template)
#let single-leading = 0.5em             // single spacing for the notation, caption and footer
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations are indented on both sides, still double spaced
#let caption-left = 3.0in               // width of the party column of the caption
#let notation-width = 3.6in             // the top-right notation (LBR 9013-1(d)(1)(B))

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *aka*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole numbered lines, kept with the paragraph after it so a heading never ends a page.
#let heading-line(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line (LBR 9004-1(b)(1)).
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.42in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Bottom notation (LBR 9004-1(b)(3)): on the left, the abbreviated title and the page number; on the
/// right, the name, address and telephone of the firm preparing the paper.
#let footer-block(title, firm-lines) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 4pt,
  block(width: text-width, {
    set text(size: footer-size)
    set par(leading: 0.45em, spacing: 0pt)
    grid(
      columns: (1fr, 2.7in),
      column-gutter: 0.2in,
      [#upper(title) - #context counter(page).display()],
      align(right, stack(dir: ttb, spacing: 3pt, ..firm-lines.map(l => [#l]))),
    )
  }),
)

// ---------------------------------------------------------------------------
// First page: notation (top right), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items, align-to: left) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => align(align-to, inl(i))))
}

/// LBR 9013-1(d)(1)(B): the name of the judge, the chapter, and the location, date and time of the hearing,
/// and the response date, in the top right-hand corner of the first page. LBR 9004-1(b)(2): the judge's name
/// is on the front page's right side. The notation sits on the numbered lines from line 1 down.
#let notation(meta) = context {
  let h = meta.hearing
  let rows = (
    meta.at("judge", default: none),
    meta.at("chapter", default: none),
    "Hearing location: " + h.location,
    "Hearing date: " + h.date,
    "Hearing time: " + h.time,
    "Response date: " + h.response_date,
  ).filter(x => x != none)
  block(width: text-width, height: calc.ceil(
    measure(width: notation-width, line-stack(rows, align-to: right)).height / pitch) * pitch,
    align(right, block(width: notation-width, line-stack(rows, align-to: right))))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "FOR THE WESTERN DISTRICT OF WASHINGTON")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

/// The caption: the debtor's case in the left column ("In re:", one entry per line of the debtor names, the
/// designation), a column of ")" beside it with one ")" per entry (the convention in both filed exemplars),
/// and the case number and the title of the paper at the right. Each entry is one line: the sample breaks
/// the debtor names into entries, so the ")" column and the names stay on the same lines.
#let caption(meta) = on-grid({
  let left-items = meta.debtor.names + (meta.debtor.designation,)
  grid(
    columns: (caption-left, 0.25in, 1fr),
    block(width: caption-left, inset: (bottom: 6pt), stroke: (bottom: 0.75pt), line-stack(left-items)),
    line-stack(left-items.map(i => ")")),
    block(inset: (left: 0.1in), {
      line-stack((meta.case_number,))
      v(pitch * 0.5)
      [#text(weight: "bold", inl(meta.brief_title))]
    }),
  )
})

#let cover(meta) = {
  notation(meta)
  v(pitch)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body blocks: each blank-line-separated chunk of markdown is one paragraph (first-line indent), one
/// block quotation (indented both sides), or a list. A heading is kept with the chunk after it. Paragraphs
/// are not numbered: the motion practice of LBR 9013-1 does not number them.
/// Numbering is not done with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let blocks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(">") {
      let piece = on-grid({
        set par(leading: body-leading)
        pad(left: quote-indent, right: quote-indent, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      })
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending { pending; items } else { items }
      pending = []
      has-pending = false
    } else {
      let piece = on-grid({
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      // The signature block (its chunk starts "Dated:") is kept whole on one page.
      if t.starts-with("Dated:") { piece = block(breakable: false, width: text-width, piece) }
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let wawb-motion-brief(meta, body) = {
  let firm-lines = meta.footer_counsel

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, firm-lines),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section (RELIEF REQUESTED, MEMORANDUM OF LAW); level 2 a bold
  // left-aligned subsection; level 3 an italic left-aligned sub-subsection.
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => heading-line(text(size: type-size, style: "italic", it.body))

  cover(meta)

  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  blocks(body)
}
