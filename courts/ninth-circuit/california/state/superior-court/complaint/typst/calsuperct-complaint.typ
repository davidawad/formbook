// California Superior Court (calsuperct): civil complaint on pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119
// (see ../README.md for the rule numbers, URLs and the date each was verified). No case-specific
// text, no coordinates measured off a filed complaint, no forced line breaks. The markdown body is
// rendered by cmarker; the metadata comes from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each one traces to a rule or is a named style choice.
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // CRC 2.105 names Times New Roman; vendored substitute per docs/FONTS.md.
#let type-size = 12pt              // CRC 2.104: a font size not smaller than 12 points.
#let box-h = 12pt                  // one text line occupies 1 em of box; the leading sets the pitch.
#let pitch = 24pt                  // double spacing (CRC 2.108(1)); the pleading grid is this pitch.
#let grid-rows = 28                // numbered lines per page (pleading convention, tier 2).
#let top-margin = 1in              // line 1 starts 1 inch from the top (CRC 2.111(1)).
#let bottom-margin = 46pt          // 28 lines (672 pt) fit; 29 lines (696 pt) do not.
#let left-margin = 1.5in           // text starts here; CRC 2.107 requires at least 1 inch.
#let right-margin = 0.5in          // CRC 2.107 requires at least 1/2 inch.
#let clerk-rows = 7                // lines 1-7 keep the right of center clear (CRC 2.111(2)).
#let footer-rise = 14pt            // footer sits above the page edge, clear of the body.
#let para-indent = 0.5in

// Text box settings shared by the body, the line numbers and the footer. A box of exactly one em
// with these edges puts the baseline of every line on the same place, so line numbers align.
#let box-edges = (top-edge: 0.7em, bottom-edge: -0.3em)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines of text joined with line breaks; each list item is one line of inline markdown.
/// Leading spaces in an item are kept as an indent (0.25 em per space), so the caption's
/// "Plaintiff," and "v." can sit where the filer put them.
#let lines(items) = {
  let out = ()
  for (i, it) in items.enumerate() {
    if i > 0 { out.push(linebreak()) }
    let m = it.match(regex("^( *)(.*)$"))
    let n = m.captures.at(0).len()
    if n > 0 { out.push(h(n * 0.25em)) }
    out.push(inl(m.captures.at(1)))
  }
  out.join()
}

// ---------------------------------------------------------------------------
// Pleading paper: 28 numbered lines, two vertical rules, footer below the page number
// ---------------------------------------------------------------------------

#let pleading-background() = {
  for i in range(grid-rows) {
    place(top + left, dx: 0.7in, dy: top-margin + i * pitch, box(width: 0.35in,
      align(right, text(size: type-size, ..box-edges, str(i + 1)))))
  }
  // Vertical rules: a double rule between the numbers and the text, a single rule on the right.
  place(top + left, dx: 1.22in, line(start: (0pt, 0pt), end: (0pt, 792pt), stroke: 0.6pt))
  place(top + left, dx: 1.25in, line(start: (0pt, 0pt), end: (0pt, 792pt), stroke: 0.6pt))
  place(top + left, dx: 8.1in, line(start: (0pt, 0pt), end: (0pt, 792pt), stroke: 0.6pt))
}

/// Footer (CRC 2.109, 2.110): a printed line, the page number, then the title of the paper
/// in at least 10-point type.
#let pleading-footer(title) = context {
  set text(size: type-size, ..box-edges)
  stack(
    spacing: 2pt,
    line(length: 100%, stroke: 0.5pt),
    align(center, counter(page).display()),
    align(center, text(size: 10pt, title)),
  )
}

// ---------------------------------------------------------------------------
// First page (CRC 2.111): attorney block on line 1, court title on line 8, caption
// ---------------------------------------------------------------------------

/// Attorney block: single-spaced lines starting at line 1, left of center.
#let attorney-block(meta) = {
  let items = need(meta, "attorney")
  let body = par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(items))
  // Lines 1 to 7 are reserved for the attorney block and the clerk's space (CRC 2.111(1),(2)).
  layout(size => {
    let h = measure(block(width: size.width, body)).height
    if h > clerk-rows * pitch {
      panic("calsuperct-complaint: the attorney block is taller than lines 1-" + str(clerk-rows))
    }
  })
  block(width: 100%, height: clerk-rows * pitch, body)
}

/// Court title: centered, on line 8 (CRC 2.111(3)). Line 8 begins 7 lines below line 1.
#let court-title(meta) = {
  block(width: 100%, height: 2 * pitch, align(center, par(leading: pitch - box-h, spacing: 0pt,
    first-line-indent: 0pt, strong(lines(need(meta, "court"))))))
}

/// Caption: parties on the left (closed by a right rule and a bottom rule), the case number,
/// the nature of the paper and the judge and department on the right (CRC 2.111(4)-(7)).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left-cell = block(width: 100%, stroke: (right: 0.6pt + black, bottom: 0.6pt + black),
    inset: (right: 0.12in, bottom: 0.12in, top: 0pt),
    par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(cap.left)))
  let right-cell = block(width: 100%, inset: (left: 0.2in, top: 0pt),
    par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, {
      if "case_number" in cap {
        [#cap.case_number]
        linebreak()
        linebreak()
      }
      strong(lines(need(cap, "title")))
      if "details" in cap {
        linebreak()
        linebreak()
        lines(cap.details)
      }
      // CRC 2.111(9): on a complaint, the amount-demanded statement (wording from the frontmatter).
      if "amount_demanded" in cap {
        linebreak()
        linebreak()
        inl(cap.amount_demanded)
      }
    }))
  grid(columns: (3.6in, 2.9in), column-gutter: 0pt, left-cell, right-cell)
}

// ---------------------------------------------------------------------------
// Headings and body text
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set par(first-line-indent: 0pt, leading: 12pt, spacing: 12pt)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      align(center, strong(upper(it.body))))
  } else if it.level == 2 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      align(center, strong(upper(it.body))))
  } else if it.level == 3 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt, strong(it.body))
  } else {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt, strong(emph(it.body)))
  }
}

// ---------------------------------------------------------------------------
// Signature block (CRC 2.111(1); signature under CCP 128.7 is the signer's own)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, sticky: true, above: pitch, {
    par(leading: box-h, spacing: 0pt, first-line-indent: 0pt, {
      if "dated" in sig { [Dated: #sig.dated] }
    })
    pad(left: 3.1in, par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(sig.lines)))
    v(pitch)
    pad(left: 3.1in, par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, {
      [By: #box(width: 2.7in, line(length: 100%, stroke: 0.5pt))]
      linebreak()
      h(0.3in)
      strong(upper(sig.signer))
      if "role" in sig {
        linebreak()
        h(0.3in)
        sig.role
      }
    }))
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let calsuperct-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: pleading-background(),
    footer: pleading-footer(need(meta, "footer_title")),
    footer-descent: footer-rise,
  )
  set text(font: font-family, size: type-size, ..box-edges, lang: "en")
  // Blocks take no automatic spacing: every vertical gap is set explicitly so the grid holds.
  set block(spacing: 0pt)
  set par(leading: box-h, spacing: box-h, first-line-indent: (amount: para-indent, all: true), justify: false)
  show heading: style-heading
  show footnote.entry: set text(size: type-size)
  set footnote.entry(indent: 0pt)

  // Lines 1-7: attorney block (fixed height). Lines 8-9: court title. Line 10 is blank.
  attorney-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  if "jury_demand" in meta {
    block(width: 100%, sticky: true, above: 24pt, below: 12pt,
      align(center, strong(upper(meta.jury_demand))))
  }
  signature-block(meta)
}
