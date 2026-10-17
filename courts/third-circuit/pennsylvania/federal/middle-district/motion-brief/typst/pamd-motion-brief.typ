// Brief in support of a motion for the U.S. District Court for the Middle District of Pennsylvania (pamd).
// Rules: M.D. Pa. LR 5.1 (form: 14 point type, double spacing, one inch margins; footnotes in the same
// face and size as the text), LR 7.1 (written motion, certificate of non-concurrence, proposed order),
// LR 7.5 (brief within 14 days), LR 7.8 (contents, 15 page or 5,000 word limit, tables above 15 pages).
// See ../README.md for the quoted text and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"        // LR 5.1 names no face; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 14pt                   // LR 5.1: typeface not smaller than 14 point
#let pitch = 32pt                       // LR 5.1: double spacing. 32 pt is the baseline pitch of the 14 pt filed exemplars
#let body-leading = 22.83pt             // gap between lines of body text; with the 0.655 em (Liberation Serif) line box it gives the 32 pt pitch
#let single-leading = 0.5em             // single spacing: headings, caption, signature and certificate blocks
#let caption-line = 16pt                // one row of the caption: single spaced
#let margin-all = 1in                   // LR 5.1: margins at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-colon = 0.4in              // the column of ":" marks between the parties and the right column

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, citations with section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines (firm name, signature block lines, etc.).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 5.1; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The caption: one row per line of the party column. Each row is a dict with `left` (party text),
/// optional `indent` (inches), and `right` (the right column: civil action number, judge). Every row
/// is a block of fixed height, so the colons and the right column line up with the names.
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
// Body: unnumbered paragraphs, headings, lettered lists, signature block
// ---------------------------------------------------------------------------

/// A body paragraph: first-line indent, double spaced. Markdown inside is rendered by cmarker.
#let plain-paragraph(t) = {
  set par(leading: body-leading, spacing: body-leading)
  h(para-indent)
  cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// The markdown body, chunk by chunk: a heading, a list (lettered (a), (b) ...), or a paragraph.
/// Chunks are split on blank lines, so a paragraph's lines are joined and a hard line break in the
/// sample is a trailing backslash.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are spaced by body-leading.
      {
        set par(leading: body-leading, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
    } else if t.starts-with("~") {
      // A single-spaced block (a service list, an address): a leading "~" in the sample marks it. Its
      // lines are joined with hard breaks (a trailing backslash); the block has no first-line indent.
      block(breakable: false, width: 100%, {
        set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
        cmarker.render(t.slice(1).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      v(body-leading)
    } else {
      plain-paragraph(t)
    }
  }
}

/// Signature block: the firm, "By:" and the signer, at the right; the date at the left, if given.
#let signature-block(meta) = block(breakable: false, width: 100%, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  v(pitch)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      [Respectfully submitted,]
      v(single-leading)
      line-stack(meta.signature.firm)
      v(pitch)
      [By:]
      line(length: 3.2in, stroke: 0.5pt)
      v(single-leading)
      line-stack(meta.signature.lines)
    },
  )
})

#let pamd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer: context align(center, text(size: 12pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 a flush-left bold caps section (I., II. ...); level 2 a flush-left bold sub-heading
  // (A., B. ...); level 3 bold italic (1., 2. ...). Sticky, so a heading never ends a page.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, text(size: type-size, weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => block(sticky: true, width: 100%, text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(sticky: true, width: 100%, text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  body-chunks(body)

  signature-block(meta)
}
