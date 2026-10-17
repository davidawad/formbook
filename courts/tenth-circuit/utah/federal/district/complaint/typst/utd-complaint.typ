// Complaint for the U.S. District Court for the District of Utah (utd).
//
// Rule-driven and content-agnostic. Requirement IDs (DUCivR-..., FRCP-...) refer to ../README.md, which
// quotes the rule text: D. Utah Local Civil Rules (December 2023 edition) DUCivR 10-1; Fed. R. Civ. P.
// 8(a), 10(a)-(b), 38(b). No case-specific text, no coordinates measured off the exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"    // DUCivR 10-1(3) names no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // DUCivR 10-1(3): minimum 12 point, footnotes included.
#let line-pitch = 24pt                   // DUCivR 10-1(4): double spacing, two lines of 12 pt type per line.
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is line-pitch.
#let single-leading = 0.198em            // caption, counsel block, signature block: single spacing (a 1.305em pitch, about 15.7 pt at 12 pt)
#let top-margin = 1.5in                  // DUCivR 10-1(1): top margin at least 1 1/2 inches
#let bottom-margin = 1in                 // DUCivR 10-1(1): remaining margins at least 1 inch
#let side-margin = 1in
#let margins = (top: top-margin, bottom: bottom-margin, x: side-margin)
#let para-indent = 0.5in                 // first-line indent of numbered paragraphs
#let heading-gap = line-pitch            // one full double-spaced line above and below a heading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("utd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Stack of single-spaced lines (counsel block, caption sides, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title, caption (DUCivR 10-1(6), (7))
// ---------------------------------------------------------------------------

#let counsel-block(meta) = block(width: 100%, line-stack(need(meta, "counsel")))

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  v(line-pitch * 0.5)
  align(center, strong(upper(need(meta, "court").map(l => [#l]).join(linebreak()))))
  if "division" in meta {
    linebreak()
    align(center, strong(upper(meta.division)))
  }
  v(line-pitch * 0.5)
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    let rows = ()
    for (k, p) in sides.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    strong(upper(inl(need(meta, "brief_title"))))
    if "jury_demand" in meta and meta.jury_demand {
      v(line-pitch * 0.5)
      strong("JURY DEMANDED")
    }
    v(line-pitch * 0.5)
    [Case No. #need(meta, "case_number")]
    v(line-pitch * 0.5)
    if "judge" in meta [Judge #meta.judge]
    if "magistrate" in meta [\ Magistrate Judge #meta.magistrate]
  }
  table(
    columns: (1.8fr, 1fr),              // the party column takes the longer side; keeps the caption on page 1
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption-table(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), headings, prayer list, jury demand, signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [DATED this #need(meta, "date").], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      line-stack(sig.at("firm", default: ()))
      v(line-pitch * 0.5)
      line-stack(("By: /s/ " + sig.signer, sig.signer) + sig.at("lines", default: ()))
    })
  })
}

/// Blank-line-separated chunks of the body become parts of the document. A heading is kept with the
/// chunk after it (never ends a page). A markdown list is not numbered, and neither is a paragraph that
/// introduces one, nor any paragraph under a "Prayer for Relief" or "Jury Demand" heading: only
/// allegations are numbered (FRCP 10(b)). The last plain paragraph is kept on the page with the
/// signature block, so a signature never stands alone on a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let is-list(c) = c.trim().starts-with(regex("^(\\d+\\.|[-*+])[ \\t]"))
  let parts = ()
  let pending = []
  let has-pending = false
  let unnumbered = false
  let last-plain = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let next-is-list = i + 1 < chunks.len() and is-list(chunks.at(i + 1))
    if t.starts-with("#") {
      let lower-t = lower(t)
      unnumbered = lower-t.contains("prayer") or lower-t.contains("jury demand")
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    }
    let piece = if is-list(t) {
      last-plain = false
      {
        set par(leading: body-leading)
        set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else {
      last-plain = true
      // Each paragraph is its own block: inline pieces would run together with the next paragraph.
      if unnumbered or next-is-list {
        block(width: 100%, [#h(para-indent)#inl(t)])
      } else {
        para-counter.step()
        block(width: 100%, context [#h(para-indent)#para-counter.display().#h(0.3in)#inl(t)])
      }
    }
    if has-pending {
      parts.push(block(breakable: false, width: 100%, above: heading-gap, { pending; piece }))
    } else {
      parts.push(piece)
    }
    pending = []
    has-pending = false
  }
  if pending != [] { parts.push(block(breakable: false, width: 100%, above: heading-gap, pending)) }
  if last-plain and parts.len() > 0 {
    let last = parts.pop()
    for p in parts { p }
    block(breakable: false, width: 100%, { last; tail })
  } else {
    for p in parts { p }
    tail
  }
}

#let utd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "counsel", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let para-counter = counter("allegation")

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",                  // DUCivR 10-1(1): 8 1/2 x 11 inch
    margin: margins,
    numbering: "1",                      // DUCivR 10-1(5): pages numbered consecutively
    footer: context align(center, counter(page).display()),
  )
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered bold caps; level 2 centered bold (cause-of-action headings); level 3 bold, left.
  show heading.where(level: 1): it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true,
    align(center, text(size: type-size, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true,
    align(center, text(size: type-size, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true,
    text(size: type-size, strong(it.body)))

  cover(meta)

  if "lead_in" in meta {
    par(first-line-indent: para-indent, inl(meta.lead_in))
  }

  allegations(body, para-counter, signature-block(meta))
}
