// Complaint for the U.S. District Court for the District of Columbia (dcd).
// Rules: LCvR 5.1(c) (party and attorney identification), 5.1(d) (8 1/2 by 11, typed, double-spaced,
// 12-point, case number with judge initials); Fed. R. Civ. P. 8(a), 10(a), 10(b) (numbered paragraphs).
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
#let single-leading = 0.5em             // single spacing for the caption, counsel block and signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let pitch = 24pt                       // the double-spaced line pitch, used for vertical gaps between blocks

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dcd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading: kept with the text after it, so a heading never ends a page.
#let heading-block(c) = block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, c)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (the body follows on the same page)
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
    // Each party: its names (name, residence or official address, as LCvR 5.1(c)(1) requires), then its
    // designation; "v." between the parties.
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
    v(pitch * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
)

#let cover(meta) = {
  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
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
      v(pitch)
      line-stack(("________________________________",))
      line-stack((meta.signature.signer,) + meta.signature.firm + (meta.signature.role,))
    },
  )
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading, a list nor a `>` line is one numbered paragraph. A `>` line is an unnumbered paragraph; a list is
/// lettered (A., B., ...). Numbering is applied per chunk, not with a `show par` rule: a show rule that
/// re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      let piece = if t.starts-with(">") {
        // Unnumbered paragraph (for example a prayer's "WHEREFORE" lead-in).
        let text-only = t.slice(1).trim()
        par(leading: body-leading, first-line-indent: para-indent, cmarker.render(text-only, raw-typst: false, smart-punctuation: true, h1-level: 1))
      } else {
        para-counter.step()
        context {
          set par(leading: body-leading, first-line-indent: para-indent)
          block(width: text-width, [#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)])
        }
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

#let dcd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Typst leading sits between lines only: a block ends one leading short of its last line, so the gap
  // between blocks is the leading again, which keeps every block on the double-spaced pitch.
  set block(spacing: body-leading)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold centered sub-heading; level 3 bold, left.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", it.body))

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, par(leading: body-leading, first-line-indent: para-indent, inl(meta.lead_in)))
  }

  // Lettered list items (prayer for relief): (A), (B) ... set as "A.", "B." on the complaint form.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
