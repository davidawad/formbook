// Complaint for the U.S. District Court for the District of Idaho (idd).
// Rules: Dist. Idaho Loc. Civ. R. 5.2 (8 1/2 x 11, double-spaced, 1-inch margins, 12-point type including
// footers and footnotes, numbered pages, counsel block, caption four inches down, CM/ECF file number);
// Loc. Civ. R. 38.1 (jury demand notation after the title); Fed. R. Civ. P. 10(b) (numbered paragraphs).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no face named by LR 5.2(a), so EB Garamond (fonts/eb-garamond); see README.md, typeface row
#let type-size = 12pt                   // LR 5.2(a): at least 12 point, footnotes and footer included
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // LR 5.2(a): top, bottom and side margins at least one inch
#let body-leading = 1.35em              // LR 5.2(a): double-spaced; 24 pt baseline pitch at 12 pt (measured, README.md)
#let pitch = 24pt                       // one double-spaced line; headings fill whole slots of this height
#let single-leading = 0.5em             // counsel, caption, signature block: single-spaced
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-top = 4in                  // LR 5.2(b): caption commences four inches below the top of the first page
#let caption-left = 3.25in              // width of the party column of the caption
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("idd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Whole numbered-line slots: the block is rounded up to a multiple of `pitch`, so whatever follows it starts
/// on the grid and never overlaps (a block sized to its text leaves the next line too close).
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// Single-spaced lines, one per item; the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  // An empty item is a line-high gap (between counsel groups, for example).
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i.trim() == "" { block(height: 1em) } else { inl(i) }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number and paper title, each page (LR 5.2(a): each page numbered consecutively).
#let footer-block(title) = context {
  set text(size: type-size)
  align(left, [#counter(page).display() - #upper(title)])
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title and caption (four inches down), title and jury notation
// ---------------------------------------------------------------------------

#let counsel-block(meta) = line-stack(meta.counsel)

#let court-title(meta) = stack(dir: ttb, spacing: single-leading, ..meta.caption.court.map(l => align(center, text(weight: "bold", l))))

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
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
    // LR 5.2(b)(3): the file number as it appears in CM/ECF.
    line-stack(("Case No. " + meta.case_number,))
    v(body-leading * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "jury_demand" in meta and meta.jury_demand {
      // LR 38.1: the notation goes on the front page immediately following the title.
      v(body-leading * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
)

#let cover(meta) = context {
  counsel-block(meta)
  // The caption starts four inches below the top of the page; counsel that needs more room pushes it down
  // (LR 5.2(b): "except where additional space is required for identification").
  let used = measure(width: text-width, counsel-block(meta)).height
  v(calc.max(caption-top - margin - used, 12pt))
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(sticky: true, width: text-width, above: body-leading, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (2.9in, 1fr),
    column-gutter: 0.2in,
    [DATED this #meta.date.],
    {
      [Respectfully submitted,]
      v(single-leading * 2)
      line-stack(meta.signature.firm)
      v(single-leading * 2)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; headings and lists are unnumbered. Numbering is per chunk, not
/// with a `show par` rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is sticky (its show rule): it moves to the next page together with the chunk after it.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; each item is spaced by body-leading.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading * 0.5)
    } else {
      para-counter.step()
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      context [#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      v(body-leading * 0.5)
    }
  }
}

#let idd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading * 0.5)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading * 0.5, marker: [•])

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold, left.
  // Each heading fills whole numbered-line slots, so the paragraph after it starts on the grid.
  show heading.where(level: 1): it => {
    v(body-leading * 0.5, weak: true)
    on-grid(align(center, text(weight: "bold", upper(it.body))))
  }
  show heading.where(level: 2): it => {
    v(body-leading * 0.25, weak: true)
    on-grid(align(center, text(weight: "bold", it.body)))
  }
  show heading.where(level: 3): it => {
    v(body-leading * 0.25, weak: true)
    on-grid(text(weight: "bold", it.body))
  }

  cover(meta)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
    v(body-leading * 0.5)
  }

  allegations(body, para-counter)

  signature-block(meta)
}
