// Complaint for the U.S. District Court for the Western District of Missouri (mowd).
// Rules: Fed. R. Civ. P. 8(a) and 10 (caption, numbered paragraphs), 5.2 (privacy redaction, by the author);
// W.D. Mo. L.R. 3.1 (civil cover sheet) and 3.2 (divisional venue), 7.1 (certificate of interest): separate filings.
// The local rules set no typeface, margin or spacing rule for this court; the choices below are conventions
// and are recorded in ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/ (the only serif face vendored here)
#let type-size = 13pt                   // EB Garamond at 13 pt has about the x-height of Times New Roman at 12 pt (the Johnson exemplar)
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives about 2 lines of pitch
#let single-leading = 0.5em             // counsel, caption and signature: single spaced
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let margin = 1in                       // all four margins (no rule in the local rules; the exemplars use 1 inch)
#let caption-left = 3.25in              // width of the party column of the caption
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mowd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading kept with the paragraph after it (a heading never ends a page).
#let heading-block(c) = block(width: text-width, above: body-leading, below: body-leading, sticky: true, text(size: type-size, c))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading,
    align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")),
    align(center, text(weight: "bold", "FOR THE WESTERN DISTRICT OF MISSOURI")),
  )
  if "division" in meta and meta.division != none {
    v(single-leading)
    align(center, text(weight: "bold", upper(meta.division)))
  }
  v(body-leading * 1.5)
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  },
  {
    set par(leading: single-leading, spacing: 0pt)
    [Case No. #meta.case_number]
    v(body-leading)
    text(weight: "bold", inl(meta.title))
    if "jury_demand" in meta and meta.jury_demand {
      v(single-leading * 2)
      text(weight: "bold", "JURY TRIAL DEMANDED")
    }
  },
)

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  v(body-leading * 1.5)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block: date at the left, "Respectfully submitted" and the signer at the right; one block per firm.
#let signature-block(meta) = block(width: text-width, breakable: false, {
  let sig = meta.signature
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #sig.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      [Respectfully submitted,]
      v(body-leading)
      text(weight: "bold", sig.signer)
      v(single-leading)
      for firm in sig.blocks {
        line-stack(firm)
        v(single-leading * 2)
      }
    },
  )
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph. Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let num = 0
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(">") {
      // Block quotation: indented and single spaced (the class definition in the sample).
      let piece = block(width: text-width, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading, spacing: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are spaced by body-leading. Lettered (A., B., ...) by the template.
      let items = block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; items }) } else { items }
      pending = []
      has-pending = false
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is an unnumbered paragraph (the exemplar's "WHEREFORE" line); see README.md.
      let piece = block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    } else {
      // A numbered paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      // Each paragraph is its own block, so the blocks stack with no overlap and the numbers stay in order.
      let piece = block(width: text-width, above: 0pt, below: 0pt, {
        num += 1
        set par(leading: body-leading)
        [#h(para-indent)#str(num).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let mowd-complaint(meta, body) = {

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered caps; level 2 centered bold; level 3 bold, left.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", it.body))

  cover(meta)

  // Body: numbered paragraphs; markdown lists become (A), (B), ...
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body)

  v(body-leading)
  signature-block(meta)
}
