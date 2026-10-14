// Complaint for the U.S. District Court for the Middle District of Pennsylvania (pamd).
// Rules: M.D. Pa. LR 5.1 (form: 14 point type, double spacing, one inch margins), LR 5.2 (personal
// identifiers, author's responsibility), LR 8.1 (no specific sum for unliquidated damages); Fed. R.
// Civ. P. 8(a), 10(a)-(b), 38(b). See ../README.md for the quoted text and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // LR 5.1 names no face; EB Garamond is the only serif vendored in fonts/
#let type-size = 14pt                   // LR 5.1: typeface not smaller than 14 point
#let pitch = 32pt                       // LR 5.1: double spacing. 32 pt is the baseline pitch of the 14 pt filed exemplars
#let body-leading = 22.9pt              // gap between lines of body text; with the 0.65 em line box it gives the 32 pt pitch
#let single-leading = 0.5em             // single spacing: headings, caption, signature block
#let caption-line = 16pt                // one row of the caption: single spaced
#let margin-all = 1in                   // LR 5.1: margins at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (number at 0.5 in, text at 1 in)
#let number-width = 0.5in               // width of the paragraph number box
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-colon = 0.4in              // the column of ":" marks between the parties and the right column

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, citations with section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines (signature block lines, etc.).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 5.1; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The caption: one row per line of the party column. Each row is a dict with `left` (party text),
/// optional `indent` (inches), and `right` (the right column: civil action number, jury demand).
/// Every row is a block of fixed height, so the colons and the right column line up with the names.
#let caption(meta) = {
  let cells = ()
  for r in meta.caption {
    let indent = r.at("indent", default: 0) * 1in
    cells.push(block(height: caption-line, width: 100%, [#h(indent)#r.at("left", default: "")]))
    cells.push(block(height: caption-line, width: 100%, align(center, [:])))
    cells.push(block(height: caption-line, width: 100%, [#r.at("right", default: "")]))
  }
  grid(
    columns: (caption-left, caption-colon, 1fr),
    ..cells,
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE MIDDLE DISTRICT OF PENNSYLVANIA],
  ))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", upper(meta.title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lettered lists, signature block
// ---------------------------------------------------------------------------

/// Unnumbered paragraph (the lead-in, the WHEREFORE clause, the jury demand text).
#let plain-paragraph(t) = {
  set par(leading: body-leading, spacing: body-leading)
  h(para-indent)
  cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph. Numbering is applied per chunk, not with a `show par` rule: a show
/// rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered items, (a), (b) ...; a list may break across pages.
      {
        set par(leading: body-leading, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
    } else if t.starts-with("^") {
      // A paragraph that is not an allegation (the WHEREFORE clause, the jury demand): a leading "^" in
      // the sample marks it, and it is not numbered.
      plain-paragraph(t.slice(1).trim())
    } else {
      para-counter.step()
      context {
        set par(leading: body-leading, spacing: body-leading)
        h(para-indent)
        box(width: number-width, [#(para-counter.display()).])
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
    }
  }
}

/// Signature block: date at the left, "Respectfully submitted," and the signer at the right.
#let signature-block(meta) = block(breakable: false, width: 100%, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  v(pitch)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Date: #meta.date] } else { [] },
    {
      [Respectfully submitted,]
      v(pitch)
      line(length: 3.2in, stroke: 0.5pt)
      v(single-leading)
      line-stack(meta.signature.lines)
    },
  )
})

#let pamd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin-all,
    footer: context align(center, text(size: 12pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 a centred bold caps section; level 2 a centred bold sub-heading; level 3 bold italic.
  // Sticky, so a heading never ends a page.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: 100%, align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(sticky: true, width: 100%, text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    plain-paragraph(meta.lead_in)
  }

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
