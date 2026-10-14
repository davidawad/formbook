// U.S. Tax Court: petition for redetermination of a deficiency (Tax Court Rule 34(b)).
//
// Rule-driven and content-agnostic. Rule numbers refer to ../README.md, which cites the primary
// sources. No case-specific text, no coordinates measured off a filed paper, no forced line breaks.
// The body is markdown rendered by cmarker; the caption and signature block come from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"       // Rule 23(d)(2): one consistent proportional typeface. Vendored in fonts/.
#let type-size = 14pt                  // Rule 23(d)(2): 14-point type produced by a proportional print font.
#let double-leading = 1.07em           // Rule 23(d)(2)-(3): double spacing, no more than 3 lines per inch.
                                       // Calibrated so the baseline pitch is 24.1 pt (see README, "Calibration").
#let single-leading = 0.4em            // Rule 23(d)(2)-(3): single spacing (no more than 6 lines per inch) for the
                                       // caption, quotations, headings and signature block.
#let margin-side = 1in                 // Rule 23(d)(1): side margins no less than 1 inch.
#let margin-tb = 1in                   // Rule 23(d)(1): top and bottom margins no less than 3/4 inch.
#let footer-distance = 0.75in + 6pt    // page-number box bottom sits above the 3/4-inch line (6 pt for the line box below the glyph).
#let para-indent = 0.5in
#let caption-width = 4.0in             // left column of the caption (names; the respondent's name fits on one line)
#let caption-gutter = 0.3in            // the ")" column of the caption

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tax-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tax-petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (Rule 23(a)(1): full name and surname of each petitioner)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let names = need(meta, "petitioners")
  if type(names) != array or names.len() == 0 {
    panic("tax-petition: `petitioners` must be a non-empty list of names")
  }
  let designation = if names.len() > 1 { "Petitioners," } else { "Petitioner," }
  let docket = if "docket_no" in meta { "Docket No. " + meta.docket_no } else { "Docket No. __________" }

  // Each row is (left, ")", right). The ")" column makes the caption's edge a straight line.
  let rows = ()
  for n in names { rows.push((n, ")", "")) }
  rows.push(("", ")", ""))
  rows.push((pad(left: 1.2in, designation), ")", ""))
  rows.push(("", ")", ""))
  rows.push((pad(left: 0.6in)[v.], ")", docket))
  rows.push(("", ")", ""))
  rows.push(("COMMISSIONER OF INTERNAL REVENUE,", ")", ""))
  rows.push(("", ")", ""))
  rows.push((pad(left: 1.2in)[Respondent.], ")", ""))

  align(center, text(weight: "bold", [UNITED STATES TAX COURT]))
  v(1.5em)
  grid(
    columns: (caption-width, caption-gutter, 1fr),
    align: (left, center, left),
    row-gutter: single-leading,
    ..rows.flatten(),
  )
}

// ---------------------------------------------------------------------------
// Signature block (Rule 23(a)(2)-(3): date, name, mailing address, email, telephone, bar number)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  let date = need(meta, "date")
  block(breakable: false, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    v(2em)
    grid(
      columns: (1fr, 3.2in),
      [Dated: #date], [
        #v(0.6em)
        #line(length: 100%, stroke: 0.7pt)
        #v(0.6em)
        #sig.signer
        #for l in sig.lines [
          \ #l
        ]
      ],
    )
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let tax-petition(meta, body) = {
  set document(title: "Petition", author: "")
  set page(
    paper: "us-letter",
    margin: (x: margin-side, top: margin-tb, bottom: margin-tb),
    // The page number sits on the 3/4-inch line: placed from the bottom edge, not by typst's footer
    // (whose footer-descent does not place it at a fixed distance from the edge in typst 0.15).
    foreground: context place(bottom + center, dy: -footer-distance, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // spacing = leading: a new paragraph starts one double-spaced pitch below the last line, as a
  // continuing paragraph does (typst's paragraph spacing does not include the leading).
  set par(justify: false, leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true))

  // Headings: bold, centered, double-spaced like the body. Markdown `#` is level 1.
  show heading: it => block(above: 1em, below: 1em, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading)
    set text(size: type-size, weight: "bold")
    align(center, it.body)
  })

  // Quotations longer than five lines are set off and indented, single-spaced (Rule 23(d)(2)).
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(
    left: para-indent, right: para-indent,
    {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
      it.body
    },
  ))

  caption(meta)
  v(2em)
  align(center, text(weight: "bold", [PETITION]))
  v(1em)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature(meta)
}
