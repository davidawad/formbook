// Complaint for a United States District Court in Oklahoma (alias okd; the district is named by the sample).
// Rules: Fed. R. Civ. P. 10(a) (caption), 10(b) (numbered paragraphs), 10(c) (exhibits); W.D. Okla. LCvR3.1 (each
// party numbered in the caption), LCvR5.2(a) (8 1/2 by 11 inch paper, double-spaced, legible), LCvR7.1(d) (13-point
// type, footnotes included; margins at least one inch). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 13pt                   // LCvR7.1(d): not less than 13-point type, footnotes included
#let page-w = 8.5in                     // LCvR5.2(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LCvR7.1(d): at least one inch on the top, bottom and sides
#let text-width = page-w - 2 * margin
#let pitch = 27.5pt                     // double-spaced baseline pitch, the same as the filed exemplar's (measured, README.md)
#let body-leading = 1.46em              // leading that gives that pitch: 27.5 pt minus Liberation Serif's 0.655 em line box at 13 pt
#let single-leading = 0.495em            // single spacing for the caption, quotations and signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.6in               // party column of the caption (each party line must fit it: see caption-row)
#let caption-mark = 0.3in               // column of ")" marks between the parties and the case information

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, a footnote mark, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Stack single-spaced lines; every caption, quotation and signature line uses this one pitch, so the
/// caption's party column and its ")" column stay level with each other.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Fill whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so whatever follows it
/// stays on the grid. Used for the cover and headings, which must not break across a page.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: one grid block that stays on the page of the block after it, so a heading never ends a page.
#let heading-block(c) = block(width: text-width, above: 0pt, below: 0pt, sticky: true, on-grid(c))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let footer-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court name, caption, title of the paper (Fed. R. Civ. P. 10(a); LCvR3.1)
// ---------------------------------------------------------------------------

/// Party rows: each party's names (one row per line), its designation indented, "v." between the parties.
#let party-rows(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names
    rows.push((designation: p.designation))
  }
  rows
}

#let caption-row(r) = context {
  if type(r) == dictionary {
    pad(left: 1.5in, inl(r.designation))
  } else if r == "v." {
    pad(left: 0.9in, [v.])
  } else {
    assert(measure(inl(r)).width <= caption-left, message: "okd-complaint: a caption line must fit the party column; split it into two rows")
    inl(r)
  }
}

#let caption(meta) = {
  let rows = party-rows(meta)
  let right = ("Case No. " + meta.case_number,)
  if "jury_demand" in meta and meta.jury_demand { right.push("") ; right.push("JURY TRIAL DEMANDED") }
  grid(
    columns: (caption-left, caption-mark, 1fr),
    stack(dir: ttb, spacing: single-leading, ..rows.map(caption-row)),
    stack(dir: ttb, spacing: single-leading, ..rows.map(_ => [)])),
    pad(left: 0.1in, line-stack(right)),
  )
}

#let cover(meta) = {
  on-grid(align(center, stack(dir: ttb, spacing: single-leading, ..meta.court.map(l => text(weight: "bold", upper(l))))))
  v(pitch)
  on-grid(caption(meta))
  on-grid(align(center, text(weight: "bold", upper(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a heading
/// nor a list is one numbered paragraph. Headings and lists are not numbered. A paragraph is a block that may break
/// across pages; the counter steps once per paragraph, outside the block.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Paragraphs under a PRAYER or JURY heading are not numbered: the prayer (the WHEREFORE paragraph) and the
  // demand are not allegations (Fed. R. Civ. P. 10(b) numbers the claims). A quotation (">") is not numbered either.
  let unnumbered = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      unnumbered = t.contains("PRAYER") or t.contains("JURY")
      // The heading show rules (below) keep it with the block after it.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(">") {
      block(width: text-width, above: 0pt, below: 0pt, {
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are spaced by body-leading; the trailing v() closes the last one. A list may break across pages.
      block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else {
      if not unnumbered { para-counter.step() }
      block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        h(para-indent)
        if unnumbered {
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        } else {
          context [#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        }
        // The last line has no leading below it: this closes the gap to the next block (one full pitch).
        v(body-leading)
      })
    }
  }
}

#let signature-block(meta) = block(breakable: false, width: text-width, grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    if "party" in meta.signature { line-stack(meta.signature.party) }
    v(body-leading)
    for g in meta.signature.groups {
      line-stack(g.lines)
      v(single-leading * 2)
    }
    if "note" in meta.signature { line-stack(meta.signature.note) }
  },
))

#let okd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 a centered bold section; level 2 bold; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  // Quotations are indented and single-spaced; footnotes are set at the body size (LCvR7.1(d)).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(breakable: true, {
    set par(leading: single-leading)
    it.body
  }))
  show footnote.entry: set text(size: type-size)

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, above: 0pt, below: 0pt, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
      v(body-leading)
    })
  }

  // Prayer and other lists are numbered 1., 2., ... with the same double spacing.
  set enum(numbering: "1.", indent: 0pt, body-indent: 0.5in, spacing: body-leading)
  set list(indent: 0pt, body-indent: 0.5in, spacing: body-leading)
  allegations(body, para-counter)

  v(body-leading)
  signature-block(meta)
}
