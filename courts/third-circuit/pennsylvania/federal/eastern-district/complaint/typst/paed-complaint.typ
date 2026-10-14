// Complaint for the U.S. District Court for the Eastern District of Pennsylvania (paed).
// Rules: Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs); E.D. Pa. Local Civil Rule 5.1.1 (no
// dollar amount for unliquidated damages); Local Civil Rule 40.1(b) (civil cover sheet and designation form,
// filed with the complaint, not generated here). The local rules set no typeface, margin or spacing rule; the
// choices below are the convention in the filed exemplar. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the exemplar is Times New Roman (see README.md)
#let type-size = 12pt                   // convention; the local rules set no type size
#let body-leading = 1.35em              // double spacing: 24 pt baseline pitch at 12 pt (measured, README.md)
#let pitch = 24pt                       // one double-spaced line; every block is a whole number of these
#let single-leading = 0.5em             // counsel, caption and signature are single-spaced
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let margin = 1in                       // convention; the local rules set no margin
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.0in               // party column
#let caption-colon = 0.35in             // column of ":" marks between the parties and the case number
#let caption-right = text-width - caption-left - caption-colon

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("paed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so the text after it stays on the
/// same rhythm and paragraphs cannot overlap (measured; a block without a fixed height lays out unreliably here).
#let on-grid(c, breakable: true) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, breakable: breakable, c)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.court_lines {
    align(center, text(weight: "bold", line))
    linebreak()
  }
}

/// The caption: party names on the left, a column of ":" marks, and the civil action number on the right.
/// The column of ":" marks is one mark per single-spaced line of the party column, so it stays aligned.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let count = rows.len()
  grid(
    columns: (caption-left, caption-colon, caption-right),
    line-stack(rows),
    line-stack(range(count).map(_ => ":")),
    align(horizon, block(inset: (left: 0.15in), {
      let number = if meta.case_number == "" { "________________" } else { meta.case_number }
      [Civil Action No. #number]
    })),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  line-stack(meta.signature.firm)
  v(body-leading * 0.5)
  line-stack(("BY: /s/ " + meta.signature.signer,) + meta.signature.lines)
  v(body-leading * 0.5)
  [Date: #meta.date]
})

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered. A paragraph that opens
/// with "WHEREFORE" is the request for relief and is not numbered. A heading is kept in one unbreakable block with
/// the chunk after it, so it never ends a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading * 0.5)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      let piece = if t.starts-with("WHEREFORE") {
        on-grid(breakable: false, {
          set par(leading: body-leading)
          h(para-indent)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
      } else {
        para-counter.step()
        on-grid(breakable: false, {
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      }
      if has-pending {
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

#let paed-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => on-grid(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => on-grid(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => on-grid(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
    v(body-leading * 0.5)
  }

  // Body: numbered allegations; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
