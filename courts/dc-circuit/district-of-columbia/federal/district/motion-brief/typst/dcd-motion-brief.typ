// Memorandum of points and authorities in support of a motion, for the U.S. District Court for the
// District of Columbia (dcd). Rules: LCvR 7(a) (statement of points and authorities with each motion),
// 7(c) (proposed order, not part of this file), 7(e) (45-page limit); LCvR 5.1(c) (party and attorney
// identification), 5.1(d) (8 1/2 by 11, typed, double-spaced, 12-point, case number with judge initials).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no typeface is required by LCvR 5.1(d); the vendored serif in fonts/
#let type-size = 12pt                   // LCvR 5.1(d): all pleadings in 12-pt type, footnotes too
#let page-w = 8.5in                     // LCvR 5.1(d): standard 8 1/2 by 11 inch format
#let page-h = 11in
#let margin = 1in                       // convention (no margin figure in LCvR 5.1); 1-inch margins all round
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // LCvR 5.1(d): double-spaced; 1.35em leading on EB Garamond's 0.65em line box is a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption and the signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let pitch = 24pt                       // the double-spaced line pitch, used for vertical gaps between blocks

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dcd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading: kept with the text after it, so a heading never ends a page.
#let heading-block(c) = block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, c)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title() = {
  set par(leading: body-leading)
  align(center, text(weight: "bold", [UNITED STATES DISTRICT COURT\ FOR THE DISTRICT OF COLUMBIA]))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    // LCvR 5.1(d): the case number is followed by the judge's initials once a judge is assigned.
    let number = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
    line-stack(("Civil Action No. " + number,))
  }),
)

#let cover(meta) = {
  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
  // The title of the paper, centered under the caption (LCvR 5.1(d): a heading under the caption).
  block(width: text-width, {
    set par(leading: body-leading, justify: false)
    align(center, text(weight: "bold", inl(meta.brief_title)))
  })
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(pitch)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack((meta.signature.firm,))
      v(pitch * 0.5)
      line-stack(("________________________________",))
      line-stack((meta.signature.signature,))
      for lines in meta.signature.blocks {
        v(pitch * 0.5)
        line-stack(lines)
      }
    },
  )
})

/// Body paragraphs. Each blank-line-separated chunk of markdown is one paragraph, first-line indented and
/// unnumbered (a memorandum is not a numbered pleading). A heading stays with the chunk after it. A `>` line
/// is a block quotation, indented from both margins. Numbering is not applied: a memorandum is not numbered.
#let paragraphs(body, tail: []) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      has-pending = true
    } else {
      let piece = if t.starts-with(">") {
        block(width: text-width, inset: (left: 0.5in, right: 0.5in), par(leading: body-leading, first-line-indent: 0pt, cmarker.render(t.slice(1).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)))
      } else {
        block(width: text-width, par(leading: body-leading, first-line-indent: 0pt, [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]))
      }
      let last = chunks.last() == c
      if last {
        // The last paragraph stays with the signature block, so a signature never stands alone on a page.
        block(breakable: false, width: text-width, { pending; piece; tail })
      } else if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let dcd-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Typst leading sits between lines only: a block ends one leading short of its last line, so the gap
  // between blocks is the leading again, which keeps every block on the double-spaced pitch.
  set block(spacing: body-leading)

  // Headings: level 1 centered bold caps; level 2 and 3 bold, left-aligned (argument headings and sub-headings).
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", it.body))

  cover(meta)

  // Front matter (the table of contents) is numbered in lower-case roman; the body starts again at 1.
  if "toc" in meta and meta.toc {
    pagebreak()
    set page(numbering: "i")
    counter(page).update(1)
    align(center, text(weight: "bold", "TABLE OF CONTENTS"))
    v(pitch)
    set par(leading: single-leading, spacing: 0.6em)
    outline(title: none, depth: 3, indent: 1.5em)
    pagebreak()
  } else {
    pagebreak()
  }

  set page(numbering: "1")
  counter(page).update(1)
  paragraphs(body, tail: signature-block(meta))
}
