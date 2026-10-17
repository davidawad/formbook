// U.S. District Court, Middle District of Tennessee: memorandum of law supporting a motion (Fed. R. Civ. P. 7(b), 12(b);
// M.D. Tenn. LR 7.01(a)(2), 7.03). The memorandum is one of the "motion and supporting memorandum" documents of LR 7.01(a)(2).
//
// Rule-driven and content-agnostic. Requirement IDs (TNMD-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                      // TNMD-FORM-002: 12-point or larger.
// Liberation Serif's natural line box is 0.655 em (7.86 pt at 12 pt), so the leading is set in points.
#let body-leading = 19.74pt                // TNMD-FORM-003: double spacing, a 27.6 pt baseline pitch (measured; README).
#let single-pitch = 13.8pt                 // Single spacing: headings, caption, signature, service lists, footnotes. 1.15 x type size.
#let single-leading = 5.94pt               // single-pitch minus the natural line box.
#let page-margin = 1in                     // TNMD-FORM-001: one-inch margins.
#let para-indent = 0.5in                   // First-line indent of body paragraphs (TNMD-MEMO-002).
#let caption-left = 3.3in                  // Party column of the caption.
#let caption-gap = 0.3in                   // Width of the ")" column.
#let signature-indent = 3.25in             // Signature block starts at the middle of the page.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (italics, footnotes, etc.) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnmd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced stack: lines one under another at the single pitch.
#let single-stack(items) = stack(dir: ttb, spacing: single-leading, ..items)

// ---------------------------------------------------------------------------
// Court heading and caption (TNMD-MEMO-001: caption; TNMD-MEMO-004: JURY DEMAND and judges)
// ---------------------------------------------------------------------------

/// Caption party text: a block exactly as tall as its lines (measured at the column width).
#let cap-text(c) = context {
  let k = calc.max(1, int(calc.round(measure(block(width: caption-left, { set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt); c })).height / single-pitch)))
  block(height: k * single-pitch, width: 100%, { set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt); c })
}

/// The ")" column for one caption row: one ")" per line of that row, so it matches the text.
#let cap-paren(c) = context {
  let k = calc.max(1, int(calc.round(measure(block(width: caption-left, { set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt); c })).height / single-pitch)))
  block(height: k * single-pitch, single-stack(range(k).map(_ => [)])))
}

#let caption-block(meta) = {
  let cap = need(meta, "caption")

  // Party column rows: names, designation, and "v." between parties. Blank rows keep the ")".
  let rows = ()
  for (i, p) in cap.parties.enumerate() {
    if i > 0 {
      rows.push([])
      rows.push(pad(left: 1in, [v.]))
      rows.push([])
    }
    rows.push([#p.names])
    rows.push(pad(left: 1in, [#p.designation]))
  }

  // Right column: case number, JURY DEMAND legend, judge lines (LR 7.03(a), (c)).
  let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "_" * 16 }
  let right-items = ([Case No. #case-no],)
  if "jury_demand" in meta and meta.jury_demand {
    right-items.push([])
    right-items.push([JURY DEMAND])
  }
  if "judges" in meta and meta.judges.len() > 0 {
    right-items.push([])
    for j in meta.judges { right-items.push([#j]) }
  }
  let right = single-stack(right-items)

  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(cap-text(r))
    cells.push(cap-paren(r))
    if i == 0 {
      cells.push(grid.cell(rowspan: rows.len(), align: horizon, right))
    }
  }
  grid(
    columns: (caption-left, caption-gap, 1fr),
    column-gutter: 0pt,
    row-gutter: 0pt,
    ..cells,
  )
}

// ---------------------------------------------------------------------------
// Signature and certificate of service (TNMD-MEMO-005, TNMD-MEMO-006)
// ---------------------------------------------------------------------------

#let signature-block(sig) = {
  // The opening line is printed for a signature on the body; a certificate of service omits it (opening: false).
  let opening = if sig.at("opening", default: true) { [Respectfully submitted,] } else { [] }
  block(breakable: false, width: 100%, pad(left: signature-indent, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    stack(dir: ttb, spacing: 0pt,
      opening, v(single-pitch),
      [#sig.signer], v(single-pitch / 2),
      single-stack(sig.lines),
    )
  }))
}

/// Certificate of service: each service entry is a list of lines, single-spaced, one entry after another.
#let service-block(cert) = {
  let items = ()
  for (i, s) in cert.service.enumerate() {
    if i > 0 { items.push(v(single-pitch)) }
    items.push(single-stack(s))
  }
  block(breakable: false, width: 100%, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    stack(dir: ttb, spacing: 0pt, ..items)
  })
  signature-block((signer: cert.signer, lines: cert.lines, opening: false))
}

// ---------------------------------------------------------------------------
// Body: paragraphs are unnumbered; "@signature" and "@service" place the blocks (footnotes stay in one render call)
// ---------------------------------------------------------------------------

/// Render the body. Blank-line-separated chunks are gathered into one markdown render per run of text,
/// so footnote definitions resolve. "@signature" and "@service" lines are replaced by the blocks.
#let body-blocks(meta, body) = {
  let out = ()
  let buf = ""
  for raw in body.split(regex("\n[ \t]*\n")) {
    let c = raw.trim()
    if c == "@signature" or c == "@service" {
      if buf != "" { out.push(md(buf)); buf = "" }
      if c == "@signature" {
        out.push(signature-block(need(meta, "signature")))
      } else {
        out.push(service-block(need(meta, "certificate")))
      }
    } else if c != "" {
      buf += c + "\n\n"
    }
  }
  if buf != "" { out.push(md(buf)) }
  out.join()
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let tnmd-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: (top: page-margin, bottom: page-margin, left: page-margin, right: page-margin),
    footer-descent: 0.45in,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, first-line-indent: (amount: para-indent, all: true), spacing: body-leading)

  // Headings: level 1 centered bold (ARGUMENT, CONCLUSION); level 2 bold, flush left (argument points);
  // level 3 bold, indented (sub-points). Each heading has a blank double-spaced line above and below.
  show heading: set text(weight: "bold")
  show heading.where(level: 1): it => block(above: body-leading, below: body-leading, width: 100%, align(center, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, it.body)))
  show heading.where(level: 2): it => block(above: body-leading, below: body-leading, width: 100%, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, it.body))
  show heading.where(level: 3): it => block(above: body-leading, below: body-leading, width: 100%, pad(left: para-indent, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, it.body)))

  // Footnotes: single-spaced, at the type size (TNMD-FORM-003).
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  show footnote.entry: set text(size: type-size)

  // Court name and division, caption, title. Each line is its own block (no forced breaks).
  {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    align(center, single-stack((
      [IN THE UNITED STATES DISTRICT COURT],
      [FOR THE MIDDLE DISTRICT OF TENNESSEE],
      [#need(meta, "division")],
    )))
  }
  v(single-pitch * 2)
  caption-block(meta)
  v(single-pitch * 2)
  {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    block(width: 100%, align(center, text(weight: "bold", need(meta, "title"))))
  }
  v(single-pitch)

  body-blocks(meta, body)
}
