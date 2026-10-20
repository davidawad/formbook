// Adversary complaint for the U.S. Bankruptcy Court, W.D. Washington (wawb).
// Rules: Fed. R. Bankr. P. 7001 (what is an adversary proceeding), 7010 (Civil Rule 10 applies, but the
// caption must substantially conform to the appropriate Form 416), 9004(a) (caption: court, title, number,
// designation); LBR 9004-1 (8-1/2 x 11, embedded font 11 or 12 point, double spaced, numbered lines,
// judge's name top right, bottom notation: abbreviated title and page number left, attorney name,
// address and telephone right); Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LBR 9004-1(a): standard embedded font; vendored in fonts/
#let type-size = 12pt                   // LBR 9004-1(a): 11 or 12 point
#let footer-size = 11pt                 // LBR 9004-1(a): the bottom notation is printed in the same 11 point minimum
#let pitch = 24pt                       // LBR 9004-1(a): double spaced; the numbered lines are this pitch
#let lines-per-page = 28                // LBR 9004-1(b)(1): numbered paper; 28 lines (the W.D. Wash. convention, as in the exemplar)
#let page-w = 8.5in                     // LBR 9004-1(a): 8-1/2 x 11 inch
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the bottom notation
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: a 24 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption and signature (about 13.8 pt)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.0in               // width of the party column of the caption
#let counsel-width = 3.9in              // counsel block at the left of lines 1 to 10; the judge line sits at the right
#let counsel-lines = 7                  // at least 7 numbered lines are reserved for counsel

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A heading: whole numbered lines (one line for most; a long count title takes two), kept with the
/// paragraph after it so a heading never ends a page.
#let heading-line(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line (LBR 9004-1(b)(1)).
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

/// Bottom notation (LBR 9004-1(b)(3)): on the left, the abbreviated title and the page number; on the
/// right, the name, address and telephone of the firm preparing the paper.
#let footer-block(title, firm-lines) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 4pt,
  block(width: text-width, {
    set text(size: footer-size)
    set par(leading: 0.45em, spacing: 0pt)
    grid(
      columns: (1fr, 2.7in),
      column-gutter: 0.2in,
      [#upper(title) - #context counter(page).display()],
      align(right, stack(dir: ttb, spacing: 3pt, ..firm-lines.map(l => [#l]))),
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (top left), judge (top right), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items, align-to: left) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => align(align-to, inl(i))))
}

/// Counsel at the top left (LBR 9004-1(b)(3) and FRCP 10: the preparer is identified); the judge's
/// name and chapter at the top right (LBR 9004-1(b)(2)). Lines 1 to 7 at least; more counsel lines
/// push the court title down.
#let top-block(meta) = context {
  let c = line-stack(meta.counsel)
  let j = line-stack(
    (meta.at("judge", default: none), meta.at("chapter", default: none)).filter(x => x != none),
    align-to: right,
  )
  let h = calc.max(measure(width: counsel-width, c).height, measure(width: text-width - counsel-width, j).height)
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch, grid(
    columns: (counsel-width, 1fr),
    c,
    j,
  ))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "FOR THE WESTERN DISTRICT OF WASHINGTON")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

/// The caption (Form 416, substantially: the appropriate version named in Rule 7010): the debtor's case in the left column with the
/// parties beneath it, closed by a rule; the adversary number and the title of the paper at the right.
#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    if "debtor" in meta and meta.debtor != none {
      rows += meta.debtor.names
      rows += (meta.debtor.at("case_number", default: none), meta.debtor.at("note", default: none))
        .filter(x => x != none)
      rows.push("")
    }
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Adversary No. " + meta.adversary_number,))
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
  }),
))

#let cover(meta) = {
  top-block(meta)
  v(pitch)
  court-title(meta)
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The date, then one signature per firm (LBR and Civil Rule 11: a signature for each attorney).
/// Kept in one block so the block never breaks across a page.
#let signature-block(meta) = block(breakable: false, width: text-width, {
  on-grid(grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      for s in meta.signature {
        line-stack((s.firm,))
        v(pitch * 0.5)
        line-stack((("/s/ " + s.signer,) + s.lines))
        v(pitch)
      }
    },
  ))
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), made applicable by Rule 7010). Each blank-line-separated
/// chunk of markdown that is neither a heading nor a list is one numbered paragraph. Headings are
/// rendered unnumbered; a list is lettered A., B., C. (the exemplar's prayer convention).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one block with the chunk after it, so it never ends a page.
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
      let piece = {
        para-counter.step()
        on-grid({
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

#let wawb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  let firm-lines = meta.footer_counsel

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, firm-lines),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a centered bold heading (count titles);
  // level 3 a bold italic line under it (the statutory basis).
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(align(center, text(size: type-size, style: "italic", it.body)))

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
