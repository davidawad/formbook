// Brief in support of a dispositive motion for the U.S. District Court for the Western District of Michigan (miwd).
// Rules: LCivR 10.1 (double spaced, 8 1/2 x 11, one side, type 12 point or larger, margins at least 1 inch);
// LCivR 7.2(b) (a brief in support of a dispositive motion is at most 25 pages, exclusive of cover sheet, tables
// and indices: enforced below); LCivR 7.2(d) (a request for oral argument goes in the caption); LCivR 7.1(a)
// (a brief states the reasons and cites the rules and authorities relied on); LCivR 10.3 and Fed. R. Civ. P. 11(a)
// (date, address, e-mail and telephone of the signing attorney). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only font typst can see (tools/render.sh)
#let type-size = 12pt                   // LCivR 10.1: type no smaller than 12 point (footnotes included)
#let pitch = 24pt                       // LCivR 10.1: double spaced; a 24 pt baseline pitch at 12 pt
#let page-w = 8.5in                     // LCivR 10.1: 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LCivR 10.1: all margins at least one inch
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so this gives a 24 pt pitch (README.md)
#let single-leading = 0.5em             // single spacing for caption, block quotations, footnotes and signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let max-body-pages = 25                // LCivR 7.2(b): dispositive-motion brief, exclusive of cover, tables and indices
#let caption-left = 3.25in
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines; each item is one line of text (markdown inline).
#let single(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Heading numbers: I. (level 1), A. (level 2), 1. (level 3), a. (level 4). Numbers are never typed in the sample.
#let brief-numbering(..nums) = {
  let lvl = nums.pos().len()
  let n = nums.pos().last()
  if lvl == 1 { numbering("I.", n) } else if lvl == 2 { numbering("A.", n) } else if lvl == 3 { numbering("1.", n) } else { numbering("a.", n) }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LCivR 7.2(d); Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "UNITED STATES DISTRICT COURT"),
    text(weight: "bold", "WESTERN DISTRICT OF MICHIGAN"),
    if "division" in meta and meta.division != none { text(weight: "bold", upper(meta.division)) },
  ))
}

#let caption(meta) = {
  let cn = if meta.case_number == "" { "__________________" } else { meta.case_number }
  let hon = if meta.judge == "" { "__________________" } else { meta.judge }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      // Each party: its names, then its designation; "v." between the parties.
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      single(rows)
    }),
    block(inset: (left: 0.1in), {
      single(("Case No. " + cn, "Hon. " + hon))
      if "oral_argument_requested" in meta and meta.oral_argument_requested {
        v(pitch * 0.5)
        text(weight: "bold", "ORAL ARGUMENT REQUESTED")
      }
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch * 3)
  align(center, block(width: 80%, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Table of contents (generated from the headings; LCivR 7.2(b) excludes it from the page limit)
// ---------------------------------------------------------------------------

#let contents() = {
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(pitch)
  align(right, text("Page"))
  v(body-leading * 0.5)
  set par(leading: single-leading, spacing: 0pt)
  show outline.entry: set block(spacing: body-leading)
  outline(title: none, depth: 2, indent: 0.5in)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      single(meta.signature.firm)
      v(pitch * 0.5)
      single(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// The body, one blank-line-separated markdown chunk at a time. A heading is kept in one unbreakable block with
/// the chunk after it. The last chunk is kept with the signature block, so the signature never stands alone.
#let body-flow(body, tail) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions (`[^key]: text`) are rendered with the chunk that holds their reference, since each
  // chunk is converted on its own; the marker stays in the body where the author put it.
  let is-def = c => c.trim().match(regex("^\\[\\^([^\\]]+)\\]:")) != none
  let defs = (:)
  for c in all.filter(is-def) {
    defs.insert(c.trim().match(regex("^\\[\\^([^\\]]+)\\]:")).captures.at(0), c.trim())
  }
  let chunks = all.filter(c => not is-def(c))
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    let keys = c.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    let t = c.trim() + keys.map(k => "\n\n" + defs.at(k)).join("")
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = {
        set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
      let keep-tail = last and tail != none
      if has-pending or keep-tail {
        block(breakable: false, width: text-width, {
          pending
          piece
          if keep-tail { tail }
        })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let miwd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // Page numbers follow each page's own numbering: none on the cover, roman on the contents, arabic in the brief.
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0pt)
  show quote.where(block: true): it => block(width: text-width, inset: (left: 0.5in, right: 0.5in), {
    set par(leading: single-leading, spacing: pitch * 0.5, first-line-indent: 0pt)
    it.body
  })

  // Headings: level 1 bold capitals with a hanging number; level 2 bold with its number indented 0.5 in;
  // levels 3 and 4 are indented further. Numbers come from the template (brief-numbering).
  set heading(numbering: brief-numbering)
  show heading.where(level: 1): it => block(width: text-width, sticky: true, above: body-leading, below: body-leading, {
    grid(columns: (0.5in, 1fr), numbering(it.numbering, ..counter(heading).at(it.location())),
      text(weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: text-width, sticky: true, above: body-leading * 0.5, below: body-leading, {
    pad(left: 0.5in, grid(columns: (0.5in, 1fr), numbering(it.numbering, ..counter(heading).at(it.location())),
      text(weight: "bold", it.body)))
  })
  show heading.where(level: 3): it => block(width: text-width, sticky: true, above: body-leading * 0.5, below: body-leading, {
    pad(left: 1in, grid(columns: (0.5in, 1fr), numbering(it.numbering, ..counter(heading).at(it.location())), it.body))
  })
  show heading.where(level: 4): it => block(width: text-width, sticky: true, above: body-leading * 0.5, below: body-leading, {
    pad(left: 1.5in, grid(columns: (0.5in, 1fr), numbering(it.numbering, ..counter(heading).at(it.location())), it.body))
  })

  // Front matter: caption page (no number), contents (roman numerals).
  set page(numbering: none)
  cover(meta)
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  contents()
  pagebreak()

  // The brief itself starts at page 1. The page limit counts from here to the last page (LCivR 7.2(b)).
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata(none) <brief-start>]
  body-flow(body, signature-block(meta))

  context {
    let start-loc = query(<brief-start>).first().location()
    let first = counter(page).at(start-loc).first()
    let last = counter(page).final().first()
    let pages = last - first + 1
    assert(pages <= max-body-pages, message: "miwd-motion-brief: the brief is " + str(pages) + " pages; LCivR 7.2(b) allows " + str(max-body-pages) + " for a dispositive-motion brief")
  }
}
