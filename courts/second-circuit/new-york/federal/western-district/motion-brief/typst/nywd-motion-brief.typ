// Memorandum of law in support of a motion to dismiss, United States District Court for the Western
// District of New York (nywd). Rules: Fed. R. Civ. P. 7(b)(1) and 12(b)(6); W.D.N.Y. Local Civil Rule 7(a)
// (notice of motion and memorandum of law; a memorandum is limited to 25 pages, and tables of contents and
// authorities are not counted, Rule 7(a)(2)(C)); Local Civil Rule 10(a) (12-point type, double spacing,
// one-inch margins, consecutive page numbers). The table of authorities is not generated (known gap, README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; see README.md, known gaps
#let type-size = 12pt              // Local Rule 10(a)(1): all text and footnotes at least 12-point
#let body-leading = 1.345em        // Local Rule 10(a)(2): double-spaced; 0.655em line box + 1.345em = 24 pt pitch at 12 pt
#let single-leading = 0.65em       // block quotations, caption, counsel and signature blocks
#let margin = 1in                  // Local Rule 10(a)(4): at least one inch on all four sides
#let para-indent = 0.5in           // first-line indent of body paragraphs
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown: *italic* runs (case names, *Id.*, *et al.*). Plain strings stay inline (cmarker's
/// output is block-level and breaks a paragraph's first line, so it is not used).
#let inl(s) = {
  let t = s.replace("\\*", "\u{E000}")
  for (i, p) in t.split("*").enumerate() {
    let q = p.replace("\u{E000}", "*")
    if calc.odd(i) { emph(q) } else { q }
  }
}

/// A block of single-spaced lines (caption, counsel, signature); fills its container.
#let sgl(c) = block(width: 100%, above: 0pt, below: 0pt, {
  set par(leading: single-leading, spacing: 0pt)
  c
})

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties left; case number and title right), counsel block
// ---------------------------------------------------------------------------

#let court-title() = sgl(align(center, stack(
  dir: ttb,
  spacing: single-leading,
  text(weight: "bold", "UNITED STATES DISTRICT COURT"),
  text(weight: "bold", "WESTERN DISTRICT OF NEW YORK"),
)))

#let party-stack(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows.push(pad(left: 1.2in, "v.")) }
    rows.push(inl(p.names.join(" ")))
    rows.push(pad(left: 2.2in, inl(p.designation)))
  }
  stack(dir: ttb, spacing: single-leading, ..rows)
}

#let caption(meta) = block(width: text-width, breakable: false, above: body-leading, below: body-leading, grid(
  columns: (3.4in, 0.3in, 1fr),
  block(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.1in, bottom: 8pt), sgl(party-stack(meta.caption.parties))),
  [],
  sgl({
    text("Case No. " + meta.case_number)
  }),
))

#let cover-title(meta) = block(width: text-width, breakable: false, above: body-leading * 1.5, below: body-leading,
  align(center, text(weight: "bold", upper(meta.title))))

#let counsel-block(meta) = block(width: text-width, breakable: false, above: body-leading, below: 0pt, align(right, pad(left: 3in, sgl(
  stack(dir: ttb, spacing: single-leading * 2, ..meta.counsel.map(g => stack(
    dir: ttb,
    spacing: single-leading,
    text(weight: "bold", inl(g.names.first())),
    ..g.names.slice(1).map(inl),
    ..g.lines.map(inl),
  ))),
))))

// ---------------------------------------------------------------------------
// Headings: level 1 is a section (centered, bold, unnumbered); level 2 is numbered I., II. and level 3
// A., B. (numbers reset at each higher level). Each heading is a real heading, so the table of contents
// is generated from them.
// ---------------------------------------------------------------------------

#let roman = ("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV")
#let letter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

/// A heading; `label` is its number ("I.", "A."), or none for a section. The numbers are counted in
/// render-body, not with counters, so the table of contents reads the same text.
#let md-heading(lvl, label, t) = {
  if lvl == 1 {
    heading(level: 1, outlined: true)[#t]
  } else {
    heading(level: lvl, outlined: true)[#label#h(0.5em)#t]
  }
}

// ---------------------------------------------------------------------------
// Body: blank-line-separated blocks; a block is a heading (#, ##, ###), a block quotation (>), a list of
// "1." items (lettered (a), (b) ...), an unnumbered paragraph ("::" prefix), or a body paragraph.
// Memorandum paragraphs are not numbered.
// ---------------------------------------------------------------------------

#let body-par(t) = {
  h(para-indent)
  inl(t)
  parbreak()
}

#let item-list(items) = for (i, t) in items.enumerate() {
  let letter = "abcdefghijklmnopqrstuvwxyz".at(i)
  pad(left: 0.5in, grid(
    columns: (0.5in, 1fr),
    [(#letter)],
    inl(t),
  ))
  parbreak()
}

#let quote-block(t) = {
  pad(left: 0.5in, right: 0.5in, sgl(inl(t)))
  parbreak()
}

#let render-body(body) = {
  let h2 = 0
  let h3 = 0
  for c in body.split("\n\n").map(s => s.trim()).filter(s => s != "") {
    if c.starts-with("#") {
      let lvl = 0
      while c.at(lvl) == "#" { lvl += 1 }
      let t = c.slice(lvl).trim()
      if lvl == 1 {
        h2 = 0
        h3 = 0
        md-heading(1, none, t)
      } else if lvl == 2 {
        h2 += 1
        h3 = 0
        md-heading(2, roman.at(h2 - 1) + ".", t)
      } else {
        h3 += 1
        md-heading(3, letter.at(h3 - 1) + ".", t)
      }
    } else if c.starts-with(">") {
      quote-block(c.split("\n").map(l => l.trim(">", at: start).trim()).join(" "))
    } else if c.split("\n").all(l => l.match(regex("^\\d+\\. ")) != none) {
      item-list(c.split("\n").map(l => l.match(regex("^\\d+\\. (.*)$")).captures.at(0)))
    } else if c.starts-with("::") {
      h(para-indent)
      inl(c.slice(2).trim())
      parbreak()
    } else {
      body-par(c.replace("\n", " "))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a): signer, address, telephone, email)
// ---------------------------------------------------------------------------

#let signature(meta) = block(width: text-width, breakable: false, above: body-leading, below: 0pt, grid(
  columns: (1fr, 3.2in),
  sgl([Dated: #meta.date]),
  sgl(stack(
    dir: ttb,
    spacing: single-leading,
    text(weight: "bold", meta.signature.firm.join(" ")),
    [By: #meta.signature.by],
    ..meta.signature.lines.map(inl),
  )),
))

// ---------------------------------------------------------------------------
// Entry point: cover (unnumbered), table of contents (roman), body (arabic, from 1)
// ---------------------------------------------------------------------------

#let nywd-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, justify: false)
  court-title()
  caption(meta)
  cover-title(meta)
  counsel-block(meta)
  pagebreak()

  set page(numbering: "i", number-align: center)
  counter(page).update(1)
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(body-leading)
  outline(title: none, depth: 3)
  pagebreak()

  counter(page).update(1)
  set page(numbering: "1", number-align: center)
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    pad(left: 0.5in, par(hanging-indent: 0.5in, text(weight: "bold", it.body))))
  render-body(body)
  signature(meta)
}
