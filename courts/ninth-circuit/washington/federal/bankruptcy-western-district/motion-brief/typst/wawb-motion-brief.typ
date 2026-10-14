// U.S. Bankruptcy Court, W.D. Washington: motion with memorandum in support (LBR 9013-1(c)(3)(A)).
//
// Rule-driven and content-agnostic. Requirement IDs (LBR 9004-1, LBR 9013-1, ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // LBR 9004-1: a standard embedded font. Vendored in /fonts.
#let type-size = 12pt                      // LBR 9004-1: 11 or 12 point.
#let body-leading = 0.84em                 // double spacing: a baseline pitch of about 2.1 x type size (LBR 9004-1).
#let single-leading = 0.12em               // caption, notations, block quotations, service list: single-spaced.
#let page-margin = 1in                     // Margins are not dimensioned in the rule text fetched; 1 inch used. See README.
#let para-indent = 0.5in
#let footer-size = 10pt                    // LBR 9004-1: footer carries the abbreviated title, page number and counsel block.
#let caption-pitch = 1.38em                // one line of caption text, single-spaced (body-leading is not used there).
#let notation-width = 60%                  // the top-right judge/hearing notations (LBR 9004-1; LBR 9013-1(d)).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("wawb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One label/value line of the top-right notation block: "Label: value".
#let notation(label, value) = [*#label:* #inl(value)]

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// First-page notations, right side (LBR 9004-1: judge's name; LBR 9013-1(d)(1)(B): judge, chapter,
/// location, hearing date, time and response date). Single-spaced.
#let top-notations(meta) = {
  let h = need(meta, "hearing")
  align(right, block(width: notation-width, {
    set par(leading: single-leading, first-line-indent: 0pt)
    stack(
      dir: ttb, spacing: 0.2em,
      inl(need(meta, "judge")),
      inl(need(meta, "chapter")),
      v(0.3em),
      notation("Hearing Location", h.location),
      notation("Hearing Date", h.date),
      notation("Hearing Time", h.time),
      notation("Response Date", h.response_date),
    )
  }))
}

/// Pleading footer: abbreviated title and page number on the left, preparer's name, address and
/// telephone on the right (LBR 9004-1, bottom notation).
#let pleading-footer(meta) = context {
  set text(size: footer-size)
  set par(leading: single-leading, first-line-indent: 0pt)
  grid(
    columns: (1fr, 1fr), column-gutter: 1em,
    align(left + bottom, stack(
      dir: ttb, spacing: 0.4em,
      inl(need(meta, "footer_title")),
      counter(page).display(),
    )),
    align(right + bottom, stack(
      dir: ttb, spacing: 0.1em,
      ..need(meta, "footer_counsel").map(inl),
    )),
  )
}

// ---------------------------------------------------------------------------
// Caption: the ")" column between the party block and the case block
// ---------------------------------------------------------------------------

/// A column of ")" as tall as `h`, one per caption line, so the rule column reaches the last caption line.
#let paren-column(h) = {
  let n = calc.ceil(h.to-absolute().pt() / caption-pitch.to-absolute().pt())
  stack(
    dir: ttb, spacing: 0pt,
    ..range(n).map(_ => block(height: caption-pitch, width: 0.8em, align(center, ")"))),
  )
}

#let caption(meta) = context {
  set par(leading: single-leading, first-line-indent: 0pt)
  let d = need(meta, "debtor")
  let left = pad(right: 0.2em, {
    stack(
      dir: ttb, spacing: 0.9em,
      ..d.names.map(inl),
      pad(left: 2em, inl(d.designation)),
    )
  })
  let right = pad(left: 0.7em, stack(
    dir: ttb, spacing: 0.9em,
    inl(need(meta, "case_number")),
    inl(need(meta, "brief_title")),
  ))
  // Measure each cell at its column width (1fr of the text block, less the rule column), or the
  // rule column comes out as tall as the unwrapped text, not as the wrapped one.
  let col-width = (page.width - 2 * page-margin - 0.8em) / 2
  let h = calc.max(measure(left, width: col-width).height, measure(right, width: col-width).height)
  grid(columns: (1fr, 0.8em, 1fr), left, paren-column(h), right)
}

// ---------------------------------------------------------------------------
// Entry: the motion
// ---------------------------------------------------------------------------

#let motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("judge", "chapter", "hearing", "division", "debtor", "case_number", "brief_title", "footer_title", "footer_counsel", "signature") {
    let _ = need(meta, k)
  }

  // ---- the certificate of service begins on its own page (its heading is level 1) ----
  let cert = md.match(regex("(?mi)^#[ \t]+certificate of service[ \t]*$"))
  let body-md = if cert == none { md } else { md.slice(0, cert.start) }
  let cert-md = if cert == none { none } else { md.slice(cert.start) }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(
    paper: "us-letter", margin: (top: page-margin, left: page-margin, right: page-margin, bottom: 1.4in),
    numbering: "1", footer: pleading-footer(meta), footer-descent: 0pt,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // Pleading line numbers in the left margin (LBR 9004-1: "each pleading shall bear line numbers in the left margin").
  set par.line(numbering: n => text(size: 10pt, str(n)), numbering-scope: "page", number-margin: left, number-clearance: 0.6em)
  set heading(numbering: none)
  show heading.where(level: 1): it => block(above: 1.2em, below: 0.9em, width: 100%,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => block(above: 1em, below: 0.7em, text(weight: "bold", it.body))
  show quote.where(block: true): it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(left: 0.5in, right: 0.5in, top: 0.3em, bottom: 0.9em, it)
  }

  // ---- first page: court, caption, notations ----
  top-notations(meta)
  v(1.2em)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT WESTERN DISTRICT OF WASHINGTON]))
  align(center, [#need(meta, "division")])
  v(1.2em)
  caption(meta)
  v(1.2em)

  // ---- body: the notice and motion, then the memorandum, signature block ----
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  // The signature block never stands alone: the last two paragraphs (the date line and the
  // signature block) are kept on one page.
  let text-md = body-md.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() >= 2 { breaks.at(breaks.len() - 2).end } else { 0 }
  if cut > 0 {
    render(text-md.slice(0, cut))
    block(breakable: false, render(text-md.slice(cut)))
  } else {
    render(text-md)
  }

  // ---- certificate of service, on a new page; its address blocks are set flush left ----
  if cert-md != none {
    pagebreak(weak: true)
    set par(first-line-indent: 0pt)
    render(cert-md)
  }
}
