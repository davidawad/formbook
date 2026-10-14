// Complaint for the U.S. District Court for the Western District of New York (nywd).
// Rules: Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs); W.D.N.Y. Local Civil Rule 10(a)
// (12-point type, double spacing, one-inch margins, consecutive page numbers). The civil cover sheet
// (Local Rule 3) is a separate filing and is not produced here. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.


// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"   // vendored in fonts/ (the only vendored family); see README.md, known gaps
#let type-size = 12pt              // Local Rule 10(a)(1): all text and footnotes at least 12-point
#let body-leading = 1.35em         // Local Rule 10(a)(2): double-spaced body; 0.65em line box + 1.35em = 24 pt pitch at 12 pt
#let single-leading = 0.65em       // block quotations, caption, counsel and signature blocks
#let margin = 1in                  // Local Rule 10(a)(4): at least one inch on all four sides
#let para-indent = 0.5in           // first-line indent of numbered paragraphs
#let item-indent = 1in             // lettered sub-items
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown: *italic* runs (case names, *Id.*, *et al.*). Plain strings stay inline (cmarker's
/// output is block-level and breaks a numbered paragraph's first line, so it is not used).
#let inl(s) = {
  let t = s.replace("\\*", "\u{E000}")
  for (i, p) in t.split("*").enumerate() {
    let q = p.replace("\u{E000}", "*")
    if calc.odd(i) { emph(q) } else { q }
  }
}

/// A block of single-spaced lines (caption, counsel, signature).
#let sgl(c) = block(width: 100%, above: 0pt, below: 0pt, {
  set par(leading: single-leading, spacing: 0pt)
  c
})

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties on the left, title on the right)
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
    text(weight: "bold", upper(meta.title))
    v(body-leading)
    text("Civil Action No. __________________")
    if "jury_demand" in meta and meta.jury_demand {
      v(body-leading)
      text(weight: "bold", "JURY TRIAL DEMANDED")
    }
  }),
))

// ---------------------------------------------------------------------------
// Body: blank-line-separated blocks; a block is a heading (#, ##, ###), a block quotation (>), a list
// of "1." items (lettered (a), (b) ...), an unnumbered paragraph ("::" prefix), or a numbered paragraph.
// ---------------------------------------------------------------------------

#let heading-block(lvl, t) = {
  if lvl == 1 {
    block(width: text-width, above: body-leading, below: body-leading, sticky: true,
      align(center, text(weight: "bold", upper(t))))
  } else {
    block(width: text-width, above: body-leading, below: body-leading, sticky: true,
      align(center, text(weight: "bold", t)))
  }
}

#let numbered-par(n, t) = {
  h(para-indent)
  [#n.]
  h(0.5em)
  inl(t)
  parbreak()
}

#let unnumbered-par(t) = {
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
  let n = 0
  for c in body.split("\n\n").map(s => s.trim()).filter(s => s != "") {
    if c.starts-with("#") {
      let lvl = 0
      while c.at(lvl) == "#" { lvl += 1 }
      heading-block(lvl, c.slice(lvl).trim())
    } else if c.starts-with(">") {
      quote-block(c.split("\n").map(l => l.trim(">", at: start).trim()).join(" "))
    } else if c.split("\n").all(l => l.match(regex("^\\d+\\. ")) != none) {
      item-list(c.split("\n").map(l => l.match(regex("^\\d+\\. (.*)$")).captures.at(0)))
    } else if c.starts-with("::") {
      unnumbered-par(c.slice(2).trim())
    } else {
      n += 1
      numbered-par(n, c.replace("\n", " "))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Local Rule 10(a); Fed. R. Civ. P. 11(a): signer, address, telephone, email)
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
// Entry point: the complaint
// ---------------------------------------------------------------------------

#let nywd-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, justify: false)
  court-title()
  caption(meta)
  unnumbered-par(meta.lead_in)
  render-body(body)
  signature(meta)
}
