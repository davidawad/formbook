// Complaint for the U.S. District Court for the District of North Dakota (ndd).
// Rules: D.N.D. Civil Rule 5.1(B) (12-point type or larger, double-spaced, one-inch margins, page numbers at
// the bottom); Civil Rule 3.1(A) (the division is designated in the caption of a complaint); Fed. R. Civ. P. 10(a)
// (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Civil Rule 5.1(B)(2) sets a size, not a typeface; the vendored face is used
#let type-size = 12pt                   // Civil Rule 5.1(B)(2): 12-point font or larger
#let page-w = 8.5in                     // Civil Rule 5.1(B)(1): standard size paper
#let page-h = 11in
#let margin = 1in                       // Civil Rule 5.1(B)(2): minimum one-inch margin
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // Civil Rule 5.1(B)(2): double-spaced (measured, see README.md)
#let single-leading = 0.5em             // single-spaced: caption, title, signature block, quotations
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.3in              // the ")" column

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ndd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines: each item is one block; the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = stack(dir: ttb, spacing: single-leading,
  ..(meta.court, meta.district, meta.division).map(s => align(center, text(weight: "bold", upper(s)))),
)

/// Party column (names, designation, "v." between parties), a column of ")" marks, and the case
/// number, title and jury legend. Each row is one single-spaced line, so the two columns align.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  grid(
    columns: (caption-left, caption-paren, 1fr),
    column-gutter: 0pt,
    line-stack(rows),
    line-stack(rows.map(r => ")")),
    block(inset: (left: 0.2in), {
      set par(leading: single-leading, spacing: 0pt)
      let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
      [Case No. #case-no]
      v(body-leading)
      text(weight: "bold", upper(meta.title))
      if "jury_demand" in meta and meta.jury_demand {
        v(single-leading)
        text(weight: "bold", "JURY DEMAND")
      }
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  if "date" in meta and meta.date != "" {
    block(width: text-width, breakable: false, above: body-leading, below: 0pt, [Dated: #meta.date])
  }
  block(width: text-width, breakable: false, above: body-leading, below: 0pt,
    pad(left: 3.25in, {
      set par(leading: single-leading, spacing: 0pt)
      if "closing" in meta {
        [#meta.closing]
        v(body-leading)
      }
      line-stack(meta.signature.firm)
      v(body-leading)
      line-stack(meta.signature.lines)
    }))
}

/// Blank-line-separated markdown chunks become: a heading (unnumbered), a list (lettered (a), (b), ...),
/// a WHEREFORE paragraph (unnumbered, the prayer), or else a numbered allegation (Fed. R. Civ. P. 10(b)).
/// Numbering is per chunk, not a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      heading(level: lvl, t.slice(lvl).trim())
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; the trailing v() closes the last item.
      {
        set par(leading: body-leading, spacing: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with("WHEREFORE") {
      block(width: text-width, above: 0pt, below: body-leading, {
        h(para-indent)
        inl(t)
      })
    } else {
      para-counter.step()
      block(width: text-width, above: 0pt, below: body-leading, context {
        h(para-indent)
        [#para-counter.display(). #h(0.3in)]
        inl(t)
      })
    }
  }
}

#let ndd-complaint(meta, body) = {
  assert("division" in meta, message: "ndd-complaint: the caption must designate the division (Civil Rule 3.1(A))")
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps heading; level 2 a centered bold sub-heading; level 3 bold, left.
  // Each heading is sticky: it stays with the text after it, never at the foot of a page.
  show heading.where(level: 1): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, above: 0pt, below: body-leading, {
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
