// Complaint for the U.S. District Court for the Central District of California (cacd).
// Rules: L.R. 11-3.1 to 11-3.8 (legibility, 14-point font, paper and numbered lines, pagination,
// double spacing, quotations, title page); Fed. R. Civ. P. 10(a)-(b) (caption, numbered paragraphs);
// Fed. R. Civ. P. 8(a) (short and plain statement); Fed. R. Civ. P. 38 (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 11-3.1.1: proportionally spaced font; vendored in fonts/ (README.md, Known gaps)
#let type-size = 14pt                   // L.R. 11-3.1.1: standard (non-condensed) 14-point or larger
#let pitch = 24pt                       // L.R. 11-3.2 and 11-3.6: double spaced; the numbered lines are this pitch
#let lines-per-page = 28                // L.R. 11-3.2: not more than 28 lines per page
#let page-w = 8.5in                     // L.R. 11-3.2: 8 1/2 x 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // L.R. 11-3.2: line 1 begins at least one inch below the top edge
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
// Line pitch = line box (0.65 em for EB Garamond) + leading. 24 pt pitch at 14 pt: 24 - 0.65 * 14 = 14.9 pt of leading.
#let body-leading = 1.064em
#let single-leading = 0.5em             // single spacing for counsel, caption and signature (L.R. 11-3.8(a))
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 7                  // L.R. 11-3.8(a)-(c): counsel from line 1; the court title on or below line 8

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: one numbered line, kept with the paragraph after it (a heading never ends a page).
#let heading-line(c) = block(width: text-width, height: pitch, above: 0pt, below: 0pt, sticky: true, context {
  assert(measure(width: text-width, c).height <= pitch, message: "cacd-complaint: a heading must fit on one numbered line")
  c
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
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

#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: 10pt)
    align(center, context counter(page).display("-1-"))
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down (L.R. 11-3.8(c): "except where
  // additional space is required for counsel identification").
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "CENTRAL DISTRICT OF CALIFORNIA")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = on-grid(grid(
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
    let rows = ("Case No. " + meta.case_number,)
    line-stack(rows)
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    if "legend" in meta and meta.legend != none {
      v(pitch * 0.5)
      text(weight: "bold", upper(meta.legend))
    }
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  },
)))

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      // Items are spaced by body-leading, so each item fills whole lines; the trailing v() closes the last one.
      // Not wrapped in on-grid: a fixed-height block cannot break between pages, and a list must.
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
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      let piece = {
        para-counter.step()
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
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

#let cacd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
