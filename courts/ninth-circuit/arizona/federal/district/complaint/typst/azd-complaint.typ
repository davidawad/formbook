// Complaint for the U.S. District Court for the District of Arizona (azd).
// Rules: LRCiv 7.1(a) (first page: counsel from line 1, court title on or below line 6, caption with the case
// number, description and jury demand to the right of center), 7.1(b)(1) (double-spaced, no more than 28 lines
// per page, proportional font of at least 13 point, numbered pages, left margin at least 1 1/2 inches, right at
// least 1/2 inch); Fed. R. Civ. P. 8(a) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // LRCiv 7.1(b)(1): proportional font; vendored in fonts/ (see README.md, gap 2)
#let type-size = 13pt                   // LRCiv 7.1(b)(1): a proportional font of no less than 13 point, footnotes included
#let pitch = 24pt                       // LRCiv 7.1(b)(1): double-spaced body; the numbered lines are this pitch
#let lines-per-page = 28                // LRCiv 7.1(b)(1): no more than 28 lines per page
#let page-w = 8.5in                     // LRCiv 7.1(b)(1): letter size
#let page-h = 11in
#let top-margin = 72pt                  // line 1 sits on the top margin; the 28 lines end at 10 1/3 inches
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the page number
#let left-margin = 1.5in                // LRCiv 7.1(b)(1): not less than 1 1/2 inches (room for the line numbers)
#let right-margin = 0.75in              // LRCiv 7.1(b)(1): not less than 1/2 inch
#let text-width = page-w - left-margin - right-margin
// Line box of EB Garamond is 0.65em (measured, see README.md); the leading closes the rest of the pitch,
// so one line of body text is exactly `pitch` (13 pt type gives 15.55 pt of leading).
#let body-leading = pitch - 0.65 * type-size
#let single-leading = 0.5em             // counsel block, caption, signature, certificate: about 15 pt at 13 pt
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 5                  // LRCiv 7.1(a)(2): the court title begins on or below line 6

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("azd-complaint: the sample must start with a YAML frontmatter block") }
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
  assert(measure(width: text-width, c).height <= pitch, message: "azd-complaint: a heading must fit on one numbered line")
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

/// Page number centered in the bottom margin (LRCiv 7.1(b)(1): pages must be numbered).
#let page-number-block() = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, align(center, text(size: type-size, context counter(page).display()))),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-5 or more), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1 to 5 at least; a longer counsel block pushes the court title down, which the rule allows only
  // on or below line 6 (LRCiv 7.1(a)(2)).
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title() = {
  on-grid(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "FOR THE DISTRICT OF ARIZONA")))
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
    // LRCiv 7.1(a)(3), right of center: (A) the number of the action, (B) a brief description of the paper,
    // including a demand for jury trial if made.
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Case No. #meta.case_number]
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

// LRCiv 7.1 gives no signature form; the "DATED this ... day of ..." line is the form of the local rules' Appendix C.
#let signature-block(meta) = {
  on-grid([DATED this #(meta.date).])
  on-grid(align(right, box(width: 3.4in, line-stack(meta.signature.firm + ("",) + ("By: /s/ " + meta.signature.signer,) + meta.signature.lines))))
}

#let certificate(meta) = if "certificate" in meta {
  heading-line(align(center, text(weight: "bold", meta.certificate.heading)))
  on-grid({
    set par(leading: body-leading)
    h(para-indent)
    meta.certificate.text
  })
  on-grid(align(right, box(width: 3.6in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [/s/ #meta.certificate.signer]
  })))
}

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

#let azd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: page-number-block(),
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

  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists become A., B., C., ... (prayer items).
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
  certificate(meta)
}
