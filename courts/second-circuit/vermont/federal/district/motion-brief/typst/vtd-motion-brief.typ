// Memorandum of law supporting a motion, for the U.S. District Court for the District of Vermont (vtd).
// Rules: D. Vt. L.R. 7(a)(1) (the title names the motion), 7(a)(2) (memorandum of law), 7(a)(4)(A) (a memorandum
// supporting a dispositive motion is at most 25 pages, excluding exhibits and attachments), 10(a) (paper, margins,
// type size, consecutive page numbers, double spacing, footnotes used sparingly); Fed. R. Civ. P. 10(a) (caption).
// See ../README.md for the rule text, the dates verified, and the known gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 10(a)(2), (4): plainly legible, 12 point or more; the rule names no face, so the default applies: Times New Roman substitute (docs/FONTS.md, "No face named"); vendored in fonts/
#let type-size = 12pt                   // L.R. 10(a)(4): 12 point or more, footnotes included; the rule floor
#let body-leading = 1.345em             // L.R. 10(a)(6): double-spaced. Liberation Serif's line box is 0.655em, so 1.345em of leading gives a 2.0em baseline pitch
#let single-leading = 0.5em             // footnotes, caption, headings of several lines, signature: single-spaced (1.15em pitch)
#let page-margin = 1in                  // L.R. 10(a)(3): at least 1 inch on every side
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.1in               // width of the party column of the caption
#let page-limit = 25                    // L.R. 7(a)(4)(A): memorandum supporting a dispositive motion, excluding exhibits and attachments

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vtd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, footnote references, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a heading, a list or a paragraph; `#` is level 1.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced stack of lines (caption, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (no separate cover page). Pages are numbered in the
// footer (L.R. 10(a)(5)), set in #vtd-motion-brief below.
// ---------------------------------------------------------------------------

#let court-title() = stack(
  dir: ttb,
  spacing: single-leading,
  align(center, text(weight: "bold", [UNITED STATES DISTRICT COURT])),
  align(center, text(weight: "bold", [FOR THE DISTRICT OF VERMONT])),
)

/// Caption: parties on the left (closed by a rule at the right and the bottom), docket number, title on the
/// right. Each party: its names, then its designation; "v." between the parties.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 10pt), {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows += ("", "v.", "") }
      rows += p.names + ("", p.designation)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.15in), {
    let label = meta.at("case_label", default: "Civil Action No.")
    line-stack((label + " " + meta.case_number,))
    v(body-leading)
    text(weight: "bold", inl(meta.brief_title))
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists, signature
// ---------------------------------------------------------------------------

/// A heading is one block kept with the text after it (sticky), so it never ends a page.
#let heading-block(c) = block(width: text-width, above: body-leading, below: body-leading, sticky: true, c)

/// The body in order. A `#` heading is unnumbered. A list is numbered 1., 2., ... A paragraph is not numbered:
/// it is indented and double-spaced, and followed by a `v(body-leading)` gap (a paragraph's last line box is
/// 0.655em in Liberation Serif, so the gap makes the next line 2.0em below it).
#let argument(body) = {
  // A footnote definition (`[^n]: ...`) belongs to the paragraph that refers to it: each chunk is rendered by its own
  // cmarker call, so the definition is folded into the chunk before it, not left as a chunk of its own.
  let chunks = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    if c.trim().starts-with("[^") and chunks.len() > 0 {
      let last = chunks.pop()
      chunks.push(last + "\n\n" + c.trim())
    } else {
      chunks.push(c.trim())
    }
  }
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; not wrapped in a fixed-height block.
      set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      block(width: text-width, {
        set par(leading: body-leading, spacing: 0pt)
        md(t)
      })
      v(body-leading)
    } else {
      // Not a block: inside a block, typst 0.15 places a footnote on a later page than its reference.
      {
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
        h(para-indent)
        md(t)
      }
      v(body-leading)
    }
  }
}

/// Signature block: the date line, then the firm, the signature line, and each counsel's block, kept on one page.
#let signature(meta) = {
  let s = meta.signature
  block(width: text-width, above: body-leading, below: 0pt, sticky: true, {
    set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
    h(para-indent)
    inl(s.date_line)
  })
  let rows = ()
  if "firm" in s { rows.push(s.firm) }
  rows.push("_" * 34)
  for b in s.blocks {
    rows.push("")
    rows += b
  }
  if "counsel_for" in s {
    rows.push("")
    rows.push(s.counsel_for)
  }
  block(width: text-width, breakable: false, above: body-leading, pad(left: 2.9in, line-stack(rows)))
}

#let vtd-motion-brief(meta, body) = {
  // L.R. 7(a)(1): a motion's title contains the word "motion". The memorandum names the motion it supports.
  assert(lower(meta.brief_title).contains("motion"), message: "vtd-motion-brief: L.R. 7(a)(1): the title must name the motion (the word \"motion\")")

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 is a centered section; level 2 a bold heading at the margin (argument headings);
  // level 3 bold italic, indented.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(pad(left: 0.5in, text(weight: "bold", style: "italic", it.body)))

  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)

  argument(body)

  signature(meta)

  // L.R. 7(a)(4)(A): the memorandum's length, counted in pages after the render. A failure here is a rule failure.
  context {
    let pages = counter(page).final().first()
    assert(pages <= page-limit, message: "vtd-motion-brief: L.R. 7(a)(4)(A): the memorandum is " + str(pages) + " pages; the limit is " + str(page-limit))
  }
}
