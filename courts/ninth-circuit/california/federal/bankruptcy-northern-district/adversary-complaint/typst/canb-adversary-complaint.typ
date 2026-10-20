// Adversary complaint for the United States Bankruptcy Court, Northern District of California (canb).
// Rules: Fed. R. Bankr. P. 7010 (form of adversary pleadings; caption per Official Form 416A),
// 9004 (caption: court, title, case and adversary numbers, designation of the paper); B.L.R. 1001-2
// (Civil L.R. 3-4 applies in bankruptcy, except 3-4(c)(3) footers and 3-4(e)), B.L.R. 1005-1 (caption
// contents), B.L.R. 7008-1 (statement of consent to final order), B.L.R. 7003-1 (cover sheet, not
// generated here); Fed. R. Civ. P. 10(b) as applied by Fed. R. Bankr. P. 7010 (numbered paragraphs).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // B.L.R. 1001-2 / Civil L.R. 3-4(c)(2)(A): standard proportional font; vendored in fonts/
#let type-size = 12pt                   // Civil L.R. 3-4(c)(2)(B): 12 point type or larger
#let pitch = 24pt                       // Civil L.R. 3-4(c)(2): double-spaced; the numbered lines are this pitch
#let lines-per-page = 28                // Civil L.R. 3-4(c)(2): no more than 28 lines per page
#let page-w = 8.5in                     // Civil L.R. 3-4(c)(1): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing at 12 pt: 24 pt baseline pitch (measured, README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption and signature: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 7                  // Civil L.R. 3-4(a)(3): the court title starts on line 8 unless counsel needs more room

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("canb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A heading: whole numbered lines (one, or two for a long sub-heading as in the exemplar), kept with
/// the paragraph after it (a heading never ends a page).
#let heading-line(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.max(1, calc.ceil(h / pitch)) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer: page number, the paper's title and the case number (a convention the exemplar follows;
/// B.L.R. 1001-2 excludes Civil L.R. 3-4(c)(3) from bankruptcy practice).
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

/// Counsel, upper left (Civil L.R. 3-4(a)(1), applied by B.L.R. 1001-2). `counsel` is a list of
/// columns, each a list of lines: the columns sit side by side, as in the filed exemplar.
#let counsel-block(meta) = context {
  let cols = meta.counsel
  let gutter = 0.3in
  let w = (text-width - gutter * (cols.len() - 1)) / cols.len()
  let grid-of = grid(columns: (w,) * cols.len(), column-gutter: gutter, ..cols.map(c => line-stack(c)))
  // Lines 1-7 at least; more counsel lines push the court title down (Civil L.R. 3-4(a)(3): "except
  // where additional space is required for counsel identification").
  let h = measure(width: text-width, grid-of).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch, grid-of)
}

/// The court name, as given in the frontmatter (B.L.R. 1002-1 and Fed. R. Bankr. P. 9004: court,
/// division). Bold, centered, one numbered line each.
#let court-title(meta) = {
  for line in meta.court {
    on-grid(align(center, text(weight: "bold", upper(line))))
  }
}

/// One side of the caption: its names, then its designation indented to the right.
#let caption-side(side) = stack(
  dir: ttb, spacing: single-leading,
  ..side.names.map(n => inl(n)),
  pad(left: 1.6in, inl(side.designation)),
)

/// Left column of the caption: the debtor (In re:), then the adversary parties with "v." between.
#let caption-parties(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let items = ()
  if "debtor" in meta.caption {
    items.push(caption-side(meta.caption.debtor))
  }
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { items.push(align(center, [v.])) }
    items.push(caption-side(p))
  }
  stack(dir: ttb, spacing: pitch * 0.5, ..items)
}

/// Right column of the caption: case number, chapter, judge, adversary number, then the title of
/// the paper and the jury demand legend (Civil L.R. 3-6; B.L.R. 1005-1).
#let caption-right(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let case-lines = ("Case No. " + meta.case_number,)
  if "chapter" in meta { case-lines.push("Chapter " + str(meta.chapter)) }
  if "judge" in meta and meta.judge != none { case-lines.push(inl(meta.judge)) }
  let adv = if "adversary_number" in meta and meta.adversary_number != "" { meta.adversary_number } else { "____________" }
  case-lines.push("Adversary Case No. " + adv)
  let parts = (
    stack(dir: ttb, spacing: single-leading, ..case-lines.map(l => [#l])),
    strong(upper(meta.brief_title)),
  )
  if "jury_demand" in meta and meta.jury_demand {
    parts.push(strong("DEMAND FOR JURY TRIAL"))
  }
  stack(dir: ttb, spacing: pitch * 0.5, ..parts)
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), caption-parties(meta)),
  block(inset: (left: 0.1in), caption-right(meta)),
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

// The signature block is kept whole: it never splits across a page break.
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
    line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
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

#let canb-adversary-complaint(meta, body) = {
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
