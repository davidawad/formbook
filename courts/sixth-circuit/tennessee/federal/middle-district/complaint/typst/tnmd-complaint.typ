// U.S. District Court, Middle District of Tennessee: complaint (Fed. R. Civ. P. 8, 10; M.D. Tenn. LR 3.01, 3.03, 7.03).
//
// Rule-driven and content-agnostic. Requirement IDs (TNMD-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // Vendored in /fonts; the only serif font in the repo (README: Known gaps).
#let type-size = 13pt                      // TNMD-FORM-002: 12-point or larger. 13 pt because EB Garamond's x-height is smaller than Times 12 pt.
// EB Garamond's natural line box is about 0.65 em (8.45 pt at 13 pt), so the leading is set in points.
#let body-leading = 19.15pt                // TNMD-FORM-003: double spacing, a 27.6 pt baseline pitch (measured; README).
#let single-pitch = 15pt                   // Single spacing: headings, caption, signature, service lists, footnotes.
#let single-leading = 6.55pt               // single-pitch minus the natural line box.
#let page-margin = 1in                     // TNMD-FORM-001: one-inch margins.
#let para-indent = 0.5in                   // First-line indent of unnumbered paragraphs.
#let number-indent = 0.5in                 // Where the paragraph number sits (TNMD-COMP-002).
#let caption-left = 3.3in                  // Party column of the caption.
#let caption-gap = 0.3in                   // Width of the ")" column.
#let signature-indent = 3.25in             // Signature block starts at the middle of the page.
#let list-indent = 0.5in                   // Lettered prayer items (TNMD-COMP-004).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (italics etc.) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnmd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced stack: lines one under another at the single pitch.
#let single-stack(items) = stack(dir: ttb, spacing: single-leading, ..items)

// ---------------------------------------------------------------------------
// Court heading and caption (TNMD-COMP-001: caption; TNMD-COMP-005: JURY DEMAND legend)
// ---------------------------------------------------------------------------


/// Caption party text: a block exactly as tall as its lines.
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
// Signature block (TNMD-COMP-006)
// ---------------------------------------------------------------------------

#let signature-block(sig) = {
  block(breakable: false, width: 100%)[
    #pad(left: signature-indent)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #if "date" in sig [#sig.date #v(single-pitch)] else [Respectfully submitted,] #v(single-pitch)
      #sig.signer
      #v(single-pitch / 2)
      #single-stack(sig.lines)
    ]
  ]
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), headings, lettered prayer items
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks and render each one.
/// "#" chunks are headings (style below); "1. " chunks are lettered lists; "~ " chunks are
/// unnumbered paragraphs; any other chunk is a numbered paragraph. The template counts the
/// paragraphs, so the sample carries no numbers.
#let body-blocks(body) = {
  let n = 0
  let out = ()
  let prev-head = false
  for raw in body.split(regex("\n[ \t]*\n")) {
    let c = raw.trim()
    if c == "" { continue }
    if c.starts-with("#") {
      // A heading starts a block with a blank double-spaced line above it, unless it follows
      // another heading (count headings stack single-spaced).
      if not prev-head { out.push(v(body-leading)) }
      out.push(md(c))
      prev-head = true
      continue
    }
    // Text after a heading starts with the same blank line.
    if prev-head { out.push(v(body-leading)) }
    prev-head = false
    if c.starts-with("1. ") {
      out.push({
        set par(leading: body-leading, first-line-indent: 0pt)
        set enum(numbering: "A.", indent: list-indent, body-indent: list-indent)
        md(c)
      })
    } else if c.starts-with("~ ") {
      // Unnumbered paragraph (WHEREFORE clause): the "~ " marker is stripped.
      out.push(par(leading: body-leading, first-line-indent: para-indent, md(c.slice(2))))
    } else {
      n += 1
      out.push(par(leading: body-leading, first-line-indent: 0pt, [#h(number-indent)#n.#h(number-indent)#md(c)]))
    }
  }
  out.join()
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let tnmd-complaint(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: (top: page-margin, bottom: page-margin, left: page-margin, right: page-margin),
    footer-descent: 0.45in,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, first-line-indent: para-indent, spacing: body-leading)

  // Headings: level 1 centered bold (section and count headings), level 2 centered bold as a sub-line.
  show heading: set text(weight: "bold")
  show heading.where(level: 1): it => block(width: 100%, align(center, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, it.body)))
  show heading.where(level: 2): it => block(above: single-leading, width: 100%, align(center, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, it.body)))

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

  // Unnumbered lead-in paragraph (the opening paragraph before paragraph 1).
  if "lead_in" in meta {
    par(leading: body-leading, first-line-indent: para-indent, md(meta.lead_in))
  }

  body-blocks(body)

  // Signature block, after the body (TNMD-COMP-006).
  v(single-pitch)
  signature-block(need(meta, "signature"))
}
