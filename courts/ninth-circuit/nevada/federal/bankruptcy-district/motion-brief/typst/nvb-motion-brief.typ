// U.S. Bankruptcy Court, District of Nevada: motion with memorandum of points and authorities.
//
// Rule-driven and content-agnostic. Requirement IDs (LBR ...) refer to the Local Bankruptcy Rules of
// the District of Nevada, as cited in ../README.md. No case-specific text, no coordinates measured off
// any filed paper, no forced line breaks. The body is markdown rendered by cmarker; the metadata comes
// from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-lines = ("UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF NEVADA")
#let font-family = "EB Garamond"        // vendored in /fonts; no system fonts
#let type-size = 12pt                    // LBR 9004(b): proportional fonts at least 12 points.
#let line-pitch = 24pt                   // LBR 9004(a)(1): double-spaced; each line numbered in the margin.
#let line-count = 28                     // numbered lines per page (pleading format).
#let body-leading = 1.35em               // EB Garamond's line box is about 0.65em; this gives a 24 pt baseline pitch (measured).
#let single-leading = 0.35em             // single spacing (about 12 pt pitch): quotations, footnotes, counsel and caption (LBR 9004(a)(2)).
#let page-top = 1in                      // top of the numbered grid.
#let first-page-top = 1.5in              // LBR 9004(a)(2): the title page begins at least 1.5 in from the top.
#let page-left = 1.5in                   // room for the line numbers and the rules.
#let page-right = 1in
#let page-bottom = 0.67in               // 28 lines x 24 pt = 9.33 in; the rest is margin and footer.
#let para-indent = 0.5in
#let caption-left = 3.3in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline or block markdown string.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nvb-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvb-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// The numbered grid: 28 line numbers at a 24 pt pitch, in the left margin, on every page (LBR 9004(a)(1)).
/// Two vertical rules sit to the right of the numbers. Placed relative to the page, so it is independent of the body.
#let line-grid() = {
  for i in range(line-count) {
    place(top + left, dx: 0.8in, dy: page-top + i * line-pitch,
      box(width: 0.4in, align(right, text(font: font-family, size: type-size, str(i + 1)))))
  }
  place(top + left, dx: 1.34in, line(start: (0pt, 0pt), end: (0pt, 11in), stroke: 0.5pt))
  place(top + left, dx: 1.37in, line(start: (0pt, 0pt), end: (0pt, 11in), stroke: 0.5pt))
}

// ---------------------------------------------------------------------------
// Caption and signature (both outside the body's double-spacing rule: LBR 9004(a)(2))
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  for block in need(meta, "counsel") {
    for l in block.at("lines", default: ()) {
      l
      linebreak()
    }
    v(body-leading)
  }
}

#let court-title() = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, {
    for l in court-lines {
      strong(l)
      linebreak()
    }
  })
}

#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  let debtor = need(meta, "debtor")
  let left-cell = {
    debtor.heading
    linebreak()
    linebreak()
    for n in debtor.names {
      n
      linebreak()
    }
    v(body-leading)
    line(length: 100%, stroke: 0.6pt)
    pad(left: 1.4in, debtor.designation)
  }
  let right-cell = {
    "Case No. " + need(meta, "case_number")
    linebreak()
    need(meta, "chapter")
    linebreak()
    v(body-leading)
    strong(need(meta, "title"))
    linebreak()
    v(body-leading)
    "Hearing Date: " + need(meta, "hearing").date
    linebreak()
    "Hearing Time: " + need(meta, "hearing").time
  }
  grid(
    columns: (caption-left, 1fr), column-gutter: 0.25in,
    left-cell, right-cell,
  )
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: body-leading, below: body-leading, {
    par(first-line-indent: 0pt, leading: body-leading)[Respectfully submitted #need(meta, "date").]
    pad(left: 3in, par(leading: single-leading, first-line-indent: 0pt, {
      sig.firm
      linebreak()
      linebreak()
      "/s/ " + sig.signer
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) {
        linebreak()
        emph(md(l))
      }
    }))
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nvb-brief(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: (top: page-top, bottom: page-bottom, left: page-left, right: page-right),
    background: line-grid(),
    footer: align(center, text(font: font-family, size: type-size, context counter(page).display())),
    footer-descent: 0.25in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    par(first-line-indent: 0pt, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    pad(left: 0.5in, strong(it.body)))
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in,
    block(above: body-leading, below: body-leading, par(leading: single-leading, first-line-indent: 0pt, it.body)))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading)
  set footnote.entry(indent: 0pt)

  // The certificate of service starts a new page and follows the signature block.
  let m = body.match(regex("(?m)^#[ \t]+CERTIFICATE OF SERVICE[^\n]*$"))
  let main = if m == none { body } else { body.slice(0, m.start) }
  let cert = if m == none { "" } else { body.slice(m.start) }

  // Title page: starts at least 1.5 in from the top (LBR 9004(a)(2)); this offset is the first page only.
  v(first-page-top - page-top)
  counsel-block(meta)
  court-title()
  v(body-leading)
  align(center, [\*\*\*\*\*])
  v(body-leading)
  caption(meta)
  v(body-leading)

  md(main)
  signature-block(meta)
  if m != none {
    pagebreak()
    align(center, strong(upper("Certificate of Service")))
    md(cert.slice(cert.match(regex("\n")).end))
  }
}
