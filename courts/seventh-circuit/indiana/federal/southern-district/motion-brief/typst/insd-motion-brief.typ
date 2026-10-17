// Brief in support of a motion for the U.S. District Court for the Southern District of Indiana (insd).
// Rules: S.D. Ind. L.R. 5-1(b) (1-inch margins, 12-point body, double spacing except headings and
// quotations, consecutively numbered pages, title on the first page, filer's name, address, telephone
// and e-mail); Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let numbered = false                   // briefs: paragraphs are not numbered (Fed. R. Civ. P. 10 does not apply)
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md (fonts/); see README.md, known gaps
#let type-size = 12pt                   // L.R. 5-1(b): at least 12-point type in the body
#let margin = 1in                       // L.R. 5-1(b): at least 1-inch margins
#let page-w = 8.5in                     // 8 1/2 x 11 inch paper (L.R. 5-1(d) for paper filings)
#let page-h = 11in
#let body-leading = 1.345em             // L.R. 5-1(b): double spaced; 24 pt pitch at 12 pt (Liberation Serif line box 0.655em)
#let single-leading = 0.5em             // headings, caption, counsel and signature block: single spaced
#let para-indent = 0.5in                // first-line indent of paragraphs
#let text-width = page-w - 2 * margin
#let caption-party-w = 3.4in            // width of the party column of the caption
#let caption-paren-w = 0.3in            // the column of ")" marks between parties and case number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (inline or block) to typst content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading: one block, bold, kept with the text after it.
#let heading(s, align-to: center) = block(width: text-width, above: 12pt, below: body-leading, sticky: true, {
  set par(first-line-indent: 0pt, leading: single-leading)
  align(align-to, strong(md(s)))
})

/// One chunk of the markdown body (chunks are separated by blank lines).
#let chunk(c, num) = {
  let t = c.trim()
  if t.starts-with("### ") {
    heading(t.slice(4), align-to: left)
  } else if t.starts-with("## ") {
    heading(t.slice(3))
  } else if t.starts-with("# ") {
    heading(upper(t.slice(2)))
  } else if t.starts-with("- ") or t.match(regex("^\\d+\\. ")) != none {
    block(width: text-width, below: body-leading, {
      set par(first-line-indent: 0pt)
      md(t)
    })
  } else if t.starts-with(">") {
    block(width: text-width, inset: (left: 0.5in, right: 0.5in), below: body-leading, {
      set par(leading: single-leading, first-line-indent: 0pt)
      md(t)
    })
  } else if num != none {
    block(width: text-width, below: body-leading, {
      h(para-indent)
      [#str(num). #h(0.25in) #md(t)]
    })
  } else {
    block(width: text-width, below: body-leading, {
      h(para-indent)
      md(t)
    })
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading, ..meta.court.map(l => strong([#l]))))
  v(24pt)
  grid(
    columns: (caption-party-w, caption-paren-w, 1fr),
    stack(dir: ttb, spacing: single-leading, ..meta.caption.left.map(l => [#l])),
    stack(dir: ttb, spacing: single-leading, ..range(calc.max(meta.caption.left.len(), meta.caption.right.len())).map(_ => [)])),
    stack(dir: ttb, spacing: single-leading, ..meta.caption.right.map(l => [#l])),
  )
  v(18pt)
  align(center, strong(upper(meta.title)))
  if meta.at("jury_demand", default: false) {
    v(6pt)
    align(center, strong("JURY TRIAL DEMANDED"))
  }
  v(12pt)
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 5-1(b): the filer's name, address, telephone and e-mail)
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(width: text-width, sticky: true, above: 24pt, breakable: false, {
  set par(leading: single-leading, first-line-indent: 0pt)
  [#sig.date]
  v(12pt)
  pad(left: 3.25in, stack(dir: ttb, spacing: single-leading, ..sig.lines.map(l => [#l])))
})

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let insd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  cover(meta)

  // Paragraphs before the first heading (the lead-in) are not numbered.
  let seen = false
  let n = 0
  for c in body.split("\n\n") {
    let t = c.trim()
    if t.starts-with("#") { seen = true }
    let list-or-quote = t.starts-with("- ") or t.starts-with(">") or t.match(regex("^\\d+\\. ")) != none
    let para = seen and not t.starts-with("#") and not list-or-quote and not t.starts-with("WHEREFORE")
    if para and numbered { n += 1 }
    if t != "" { chunk(c, if para and numbered { n } else { none }) }
  }

  signature-block(meta.signature)
}
