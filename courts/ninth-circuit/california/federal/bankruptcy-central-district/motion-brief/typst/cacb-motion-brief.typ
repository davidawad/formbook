// Motion with notice and memorandum of points and authorities, United States Bankruptcy Court, Central District of
// California (cacb). Rules: LBR 9013-1(c)(2) (notice of motion: relief, hearing date/time/place, the 14-day response
// advisement), (c)(3)(A)-(C) (written statement of reasons with a memorandum, declarations, exhibits), (c)(4) (objection to
// the bankruptcy court's authority to enter a final order), (d)(2) (21 days' notice), (f) (responses, 14 days before the
// hearing), (g) (replies, 7 days before the hearing); LBR 9004-1 and The Central Guide Supplement to LBR 9004-1 (Aug.
// 2022): the same page, typeface, spacing, numbered-margin and caption rules as the adversary complaint (Central Guide
// 9004-1(b)-(c)); a motion is listed among the documents that need numbered margins (9004-1(b)(2)(B)(i)).
// See ../README.md for the rule text, the open choices and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Central Guide 9004-1(b)(2)(C): Times New Roman is a listed typeface; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt                   // Central Guide 9004-1(b)(2)(C): not smaller than 12 point (the floor)
#let pitch = 24pt                       // Central Guide 9004-1(b)(2)(F): double-spaced; the numbered lines are this pitch
#let lines-per-page = 28                // Central Guide 9004-1(b)(2)(B)(i): not more than 28 numbered lines per page
#let page-w = 8.5in                     // Central Guide 9004-1(b)(2)(A): 8 1/2 by 11 inch pages
#let page-h = 11in
#let top-margin = 72pt                  // Central Guide 9004-1(b)(2)(C): line 1 at least 1 inch below the top edge
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the page number and footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is about 0.655em, so 1.345em leading makes a 24 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.345em          // single spacing: 12 pt pitch at 12 pt type, so two single lines fit each numbered line (measured, README.md)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.3in               // width of the party column of the caption
#let counsel-lines = 7                  // Central Guide 9004-1(c)(1)(B): lines 1-7 are left for counsel and the clerk; the court title starts on line 8

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacb-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// A heading: whole numbered lines (one, or more when it wraps), kept with the text after it.
#let heading-line(c) = block(width: text-width, above: 0pt, below: 0pt, sticky: true, context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, c)
})

// Heading numbers, from the heading level (not typed by the author): I., A., 1., a., (1).
#let roman-count = counter("cacb-roman")
#let letter-count = counter("cacb-letter")
#let digit-count = counter("cacb-digit")
#let minor-count = counter("cacb-minor")

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

/// Page number at the bottom of every page (Central Guide 9004-1(b)(2)(G)), then the paper's title
/// and the case number on the footer line.
#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: type-size)
    align(center, context counter(page).display("1"))
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title and hearing
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down (Central Guide 9004-1(c)(1)(B)-(C)).
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil((h + 6pt) / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "CENTRAL DISTRICT OF CALIFORNIA")))
  on-grid(align(center, text(weight: "bold", upper(meta.division))))
}

/// The caption for a motion in the bankruptcy case (Central Guide 9004-1(c)(1)(I), the sample caption of a
/// motion): debtor on the left; case number, chapter, title and hearing on the right. The hearing lines
/// come from the sample (date, time, place, courthouse address), as the Central Guide requires on page 1.
#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(("In re:", ..meta.caption.debtor.names, meta.caption.debtor.designation))
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + meta.bankruptcy_case, "Chapter " + meta.chapter))
    v(pitch * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "legend" in meta and meta.legend != none {
      v(pitch * 0.5)
      text(weight: "bold", upper(meta.legend))
    }
    v(pitch * 0.5)
    line-stack(meta.hearing)
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  if "lead_in" in meta {
    v(pitch)
    on-grid({
      set par(leading: body-leading)
      inl(meta.lead_in)
    })
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, upper(meta.signature.signer)) + meta.signature.lines)
  },
))

/// The body: headings numbered from their level, paragraphs indented and double-spaced, lists as (a), (b).
/// Each blank-line-separated chunk of markdown is one paragraph (or heading, or list). A heading is kept in one
/// block with the chunk after it, so it never ends a page. Numbering is applied per chunk, not with a `show par`
/// rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let body-chunks(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    let piece = none
    // Markers from the sample: where the filing has its signature block, or starts a new page.
    if t == "<!-- signature -->" {
      piece = signature-block(meta)
    } else if t == "<!-- pagebreak -->" {
      piece = pagebreak(weak: true)
    } else if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      piece = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else {
      piece = on-grid({ set par(leading: body-leading); h(para-indent); cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1) })
    }
    if has-pending {
      block(breakable: false, width: text-width, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let cacb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.bankruptcy_case),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Tables (the listings and the service list) are unruled and single-spaced, as in the filed forms.
  set table(stroke: none, inset: (x: 4pt, y: 3pt))
  show table: set par(leading: single-leading)

  // Headings. Level 1: a centered section (NOTICE OF MOTION, MEMORANDUM OF POINTS AND AUTHORITIES, ...), which
  // restarts the numbering. Levels 2-5: I., A., 1., a. from the level, counted by the template.
  show heading.where(level: 1): it => {
    roman-count.update(0)
    letter-count.update(0)
    digit-count.update(0)
    minor-count.update(0)
    heading-line(align(center, text(weight: "bold", upper(it.body))))
  }
  show heading.where(level: 2): it => {
    roman-count.step()
    letter-count.update(0)
    digit-count.update(0)
    minor-count.update(0)
    // Filed form: a blank line, the numeral, then the title on the next line, centered.
    v(pitch)
    heading-line(align(center, text(weight: "bold", context [#numbering("I.", roman-count.get().first()) \ #upper(it.body)])))
  }
  show heading.where(level: 3): it => {
    letter-count.step()
    digit-count.update(0)
    minor-count.update(0)
    heading-line(pad(left: 0.5in, text(weight: "bold", context [#numbering("A.", letter-count.get().first()) #it.body])))
  }
  show heading.where(level: 4): it => {
    digit-count.step()
    minor-count.update(0)
    heading-line(pad(left: 1in, text(weight: "bold", context [#numbering("1.", digit-count.get().first()) #it.body])))
  }
  show heading.where(level: 5): it => {
    minor-count.step()
    heading-line(pad(left: 1.5in, text(style: "italic", context [#numbering("a.", minor-count.get().first()) #it.body])))
  }

  cover(meta)

  // Lists are numbered 1., 2., ...; markdown list items are single paragraphs spaced by body-leading.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  body-chunks(meta, body)
}
