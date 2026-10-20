// Complaint for the U.S. District Court for the Northern Mariana Islands (nmid).
// Rules: D.N.M.I. LR 5.2 (paper, numbered lines down the left margin, double spacing, 12-point serif
// type, margins, top-right corner blank on page one, court title, caption, hearing date where it applies);
// Fed. R. Civ. P. 10(a) and 10(b) (caption; numbered paragraphs). See ../README.md for the rule text
// and its source. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 5.2.a: a serif font. Vendored in fonts/; see README.md (Known gaps).
#let type-size = 12pt                   // LR 5.2.a: 12-point type or larger, everywhere but the footer.
#let pitch = 24pt                       // LR 5.2.a: double-spaced; the numbered lines are this pitch.
#let page-w = 8.5in                     // LR 5.2.a: 8.5 x 11 inch paper.
#let page-h = 11in
#let top-margin = 1.5in                 // LR 5.2.a: not less than 1.5 inches on the top.
#let left-margin = 1in                  // LR 5.2.a: one inch on the left-hand side (line numbers sit in it).
#let right-margin = 0.5in               // LR 5.2.a: one-half inch on the right-hand side.
#let text-width = page-w - left-margin - right-margin
// LR 5.2.a sets the top and bottom margins, not the line count. 1.5 in top + 1 in bottom leaves 8.5 in,
// which holds 25 double-spaced lines (25 x 24 pt = 600 pt). The footer sits in the remaining bottom margin.
#let lines-per-page = 25
#let bottom-margin = page-h - top-margin - lines-per-page * pitch
#let body-leading = 1.35em              // a 24 pt baseline pitch at 12 pt in EB Garamond (measured; see README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption and signature (about 13.8 pt at 12 pt)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.1in               // width of the party column of the caption
#let counsel-lines = 7                  // counsel block takes at least lines 1 to 7; the court title follows it

// The court's title, LR 5.2.d.1: two lines, single-spaced and centered, at least 1.5 inches from the top.
#let court-title-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN MARIANA ISLANDS")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmid-complaint: the sample must start with a YAML frontmatter block") }
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
  assert(measure(width: text-width, c).height <= pitch, message: "nmid-complaint: a heading must fit on one numbered line")
  c
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 25 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.3in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.12in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 48pt,
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
// First page: counsel (lines 1-7), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Counsel identification, upper left (LR 5.2.c). Kept narrower than the top-right three inches,
/// which LR 5.2.a leaves blank for the clerk.
#let counsel-block(meta) = context {
  let h = measure(width: 3.6in, line-stack(meta.counsel)).height
  block(width: 3.6in, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title() = on-grid(align(center, text(weight: "bold", {
  court-title-lines.join(linebreak())
})))

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties (LR 5.2.d.2).
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    // The file number and the designation of the proceeding, then the title of the paper (LR 5.2.d.3).
    line-stack(("CIVIL CASE NO. " + meta.case_number,))
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
))

#let first-page(meta) = {
  counsel-block(meta)
  court-title()
  v(pitch)
  caption(meta)
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
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  },
))

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph. Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter, tail: none) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Each emitted unit goes into `units`. The last unit is kept together with `tail` (the signature block),
  // so the signature never stands alone at the top of a page.
  let units = ()
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
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      units.push(if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      })
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      // A chunk that starts with "~ " is an unnumbered paragraph (the prayer's lead-in is one).
      let unnumbered = t.starts-with("~ ")
      let text-body = if unnumbered { t.slice(2) } else { t }
      let piece = {
        if unnumbered {
          on-grid({ set par(leading: body-leading); context [#h(para-indent)#cmarker.render(text-body, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
        } else {
          para-counter.step()
          on-grid({ set par(leading: body-leading); context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
        }
      }
      if unnumbered {
        // An unnumbered lead-in stays with the unit after it (the prayer's "WHEREFORE" stays with its items).
        pending += piece
        has-pending = true
      } else {
        units.push(if has-pending {
          block(breakable: false, width: text-width, { pending; piece })
        } else {
          piece
        })
        pending = []
        has-pending = false
      }
    }
  }
  if pending != [] { units.push(block(breakable: false, width: text-width, pending)) }
  let n = units.len()
  for (i, u) in units.enumerate() {
    if i == n - 1 and tail != none {
      block(breakable: false, width: text-width, { u; tail })
    } else {
      u
    }
  }
}

#let nmid-complaint(meta, body) = {
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

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold italic.
  // Each must fit on one numbered line (heading-line asserts it); a cause of action's title and
  // subtitle are therefore two headings.
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(text(size: type-size, weight: "bold", style: "italic", it.body))

  first-page(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered paragraphs; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter, tail: signature-block(meta))
}
