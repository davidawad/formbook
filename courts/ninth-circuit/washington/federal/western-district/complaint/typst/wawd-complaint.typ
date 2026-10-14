// Complaint for the U.S. District Court for the Western District of Washington (wawd).
// Rules: W.D. Wash. LCR 10(d)-(e) (page size, first-page space, margins, font, title, bottom notation,
// numbered paper); Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // LCR 10(e)(1): proportionally spaced font; vendored in fonts/
#let type-size = 12pt                   // LCR 10(e)(1): 12 point or larger
#let pitch = 24pt                       // LCR 10(e)(1): double spaced or exactly 24 points; the numbered lines are this pitch
#let lines-per-page = 27                // LCR 10(e)(5): numbered paper; 27 numbered lines fill the text block
#let page-w = 8.5in                     // LCR 10(d): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // LCR 10(e)(1): one-inch margins; line 1 sits on the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the bottom notation
#let left-margin = 1.5in                // room for the line numbers (LCR 10(e)(5): at least 1/2 inch to their left)
#let right-margin = 1in                 // LCR 10(e)(1): at least one inch
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, footer and signature: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.1in               // width of the party column of the caption
#let first-page-blank = 6               // LCR 10(e)(1): no less than three inches above the court title (lines 1-6 blank)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c, sticky: false) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

/// A heading: one numbered line, kept with the paragraph after it (a heading never ends a page).
#let heading-line(c) = on-grid(sticky: true, c)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line.
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

/// LCR 10(e)(3): bottom notation. Left: abbreviated title, case number and page number.
/// Right: the firm, mailing address and telephone of the preparing attorney.
#let footer-block(title, case-number, firm) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, grid(
    columns: (1fr, auto),
    column-gutter: 0.3in,
    {
      set text(size: 10pt)
      set par(leading: 0.6em, spacing: 0pt)
      stack(dir: ttb, spacing: 3pt,
        upper(title),
        [(Case No. #case-number) -- #context counter(page).display()],
      )
    },
    {
      set text(size: 9pt)
      set par(leading: 0.75em, spacing: 0pt, justify: false)
      align(right, stack(dir: ttb, spacing: 2.5pt, ..firm.map(l => [#l])))
    },
  )),
)

// ---------------------------------------------------------------------------
// Cover: judge (line 1), court title (line 7), caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "WESTERN DISTRICT OF WASHINGTON")))
  on-grid(align(center, text(weight: "bold", upper(meta.location))))
}

#let caption(meta) = on-grid(grid(
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
    line-stack(("Case No. " + meta.case_number,))
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    // Further caption lines (jury demand, noting date, oral argument), in the order given.
    for note in meta.at("caption_notes", default: ()) {
      v(pitch * 0.5)
      text(weight: "bold", inl(note))
    }
  }),
))

#let cover(meta) = {
  // Lines 1-6: the judge's name on line 1 (LCR 10(e)(1) lets the judge's name sit in the margin), then blank.
  block(width: text-width, height: first-page-blank * pitch, align(top + right, text(weight: "bold",
    if "judge" in meta { meta.judge } else { "" })))
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: the date, the firm, the signers (LCR 10(e)(4): dated and signed),
/// then the rest of the counsel list.
#let signature-block(meta) = {
  let sig = meta.signature
  on-grid(grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    [#sig.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      [#sig.firm]
      v(pitch * 0.5)
      line-stack(sig.signers.enumerate().map(((k, s)) => if k == 0 { "By: " + s } else { s }))
    },
  ))
  if "additional" in sig {
    v(pitch)
    let rows = sig.additional
    if "role" in sig { rows.push(sig.role) }
    on-grid(line-stack(rows))
  }
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // The prayer and the jury demand are not allegations: the paragraphs under them are not numbered.
  let unnumbered = false
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      unnumbered = t.contains("PRAYER FOR RELIEF") or t.contains("DEMAND FOR JURY TRIAL")
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are spaced by body-leading, so each item fills whole lines;
      // the trailing v() closes the last one. Not wrapped in on-grid: a fixed-height block cannot break.
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
      let piece = if unnumbered {
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
      } else {
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

#let wawd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number, meta.footer_firm),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section (bold); level 2 a centered sub-heading (roman, as in
  // the cause-of-action captions); level 3 bold, left.
  show heading.where(level: 1): it => heading-line(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, it.body))
  show heading.where(level: 3): it => heading-line(text(weight: "bold", it.body))

  cover(meta)

  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists are numbered 1., 2., ... (prayer items).
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
