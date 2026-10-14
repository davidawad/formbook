// Complaint for the U.S. District Court for the Northern District of Georgia (gand).
// Rules (N.D. Ga. Local Rules, LR 5.1): (C) type and spacing, (D) margins, (E) page numbers bottom center,
// (G) counsel identification, (J) captions per Fed. R. Civ. P. 7, (K) case number with judge suffix.
// Fed. R. Civ. P. 10(a) caption, 10(b) numbered paragraphs. See ../README.md for the rule text and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-name = "Liberation Serif"     // LR 5.1(C) names Times New Roman (14 pt); substitute per docs/FONTS.md, metric-compatible.
#let font-family = font-name
#let type-size = 14pt                   // LR 5.1(C): Times New Roman at least 14 point
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // LR 5.1(D): top, bottom, left and right margins at least one inch
#let text-width = page-w - 2 * margin
// LR 5.1(C): double-spaced. Typst's line box for Liberation Serif is about 0.655em, so 1.645em of leading gives a
// 32.2 pt baseline pitch: the pitch of the filed exemplar's body text (Serveco p.2). See README.md.
#let body-leading = 1.645em
#let single-leading = 0.3em             // headings, court title, signature block: single-spaced
#let single-line = 1.4em                // one single-spaced caption line, as a fixed-height block (no overlap possible)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-gap = 0.25in                // gap after the paragraph number
#let caption-party-w = 3.2in            // width of the party column of the caption
#let caption-paren-w = 0.35in           // the column of ")" marks between the parties and the case number
#let list-indent = 0.5in                // hanging indent of lettered prayer items

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gand-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field. A missing one stops the render: the form cannot be left incomplete.
#let need(meta, key) = {
  assert(key in meta, message: "gand-complaint: frontmatter field `" + key + "` is required")
  meta.at(key)
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LR 5.1(E): page numbers at the bottom center of every page.
#let page-footer() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, [
    #text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT") \
    #text(weight: "bold", "FOR THE NORTHERN DISTRICT OF GEORGIA") \
    #text(weight: "bold", upper(need(meta, "division")) + " DIVISION")
  ])
}

/// One caption line: a fixed-height block, so the lines stay evenly spaced. A name that is wider than its
/// column is a render error (split the name over two lines in the frontmatter, as the filed caption does).
#let caption-line(s, indent, w) = block(width: w, height: single-line, {
  context assert(measure(s).width + indent <= caption-party-w, message: "gand caption: a party line is wider than its column; split it in the frontmatter: " + s)
  pad(left: indent, s)
})

/// The caption: party names on the left, a column of ")" marks, and the case number on the right.
/// Each party line is a block of fixed height, so the lines stay evenly spaced and cannot overlap.
#let caption(meta) = {
  let lines = ()
  for (k, p) in need(meta, "caption").at("parties").enumerate() {
    if k > 0 { lines.push(("v.", 0pt)) }
    for n in need(p, "names") { lines.push((n, 0pt)) }
    lines.push((need(p, "designation"), 1.5in))
  }
  let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "______________" }
  let right = {
    set par(leading: single-leading, spacing: 0pt)
    [Civil Action No. #case-no]
    if "jury_demand" in meta and meta.jury_demand {
      v(single-line)
      [JURY TRIAL DEMANDED]
    }
  }
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (caption-party-w, caption-paren-w, 1fr),
    stack(dir: ttb, spacing: 0pt, ..lines.map(l => caption-line(l.at(0), l.at(1), caption-party-w))),
    stack(dir: ttb, spacing: 0pt, ..lines.map(l => block(width: caption-paren-w, height: single-line, [)]))),
    align(horizon, right),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(need(meta, "title"))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lists, signature block
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = need(meta, "signature")
  let attorneys = need(s, "attorneys")
  assert(attorneys.len() > 0, message: "gand-complaint: LR 5.1(G) needs at least one attorney block")
  for a in attorneys {
    // LR 5.1(G): name, complete address, telephone, email and bar number on every document.
    for k in ("name", "bar", "email") {
      assert(k in a, message: "gand-complaint: LR 5.1(G) needs `" + k + "` for every attorney")
    }
  }
  block(breakable: false, {
    set par(leading: single-leading, spacing: 0pt)
    v(body-leading)
    [Dated: #need(meta, "date")]
    v(body-leading)
    grid(
      columns: (2.7in, 1fr),
      [],
      {
        [/s/ #need(s, "signer")]
        linebreak()
        for a in attorneys {
          [#a.name, Georgia Bar No. #a.bar]
          linebreak()
        }
        v(single-leading)
        for l in need(s, "firm") { [#l]; linebreak() }
        for l in need(s, "address") { [#l]; linebreak() }
        [Telephone: #need(s, "phone")]
        linebreak()
        for a in attorneys { [#a.email]; linebreak() }
        v(single-leading)
        [#need(s, "role")]
      },
    )
  })
}

/// The body as one flow of paragraphs. Each blank-line-separated chunk of markdown that is neither a heading
/// nor a list is one numbered paragraph (Fed. R. Civ. P. 10(b)); a chunk starting with "^^ " is unnumbered text
/// (a WHEREFORE clause, a jury demand). A footnote definition is merged into the chunk before it, so its
/// reference and text are rendered together. Paragraph spacing equals the double-spacing pitch, so consecutive
/// paragraphs keep the same baseline grid as the lines inside them. Headings are sticky blocks (kept with the
/// text after them), so nothing is wrapped in a block that could overlap its neighbours.
#let allegations(body) = {
  let raw = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "").map(c => c.trim())
  let chunks = ()
  for t in raw {
    if t.starts-with("[^") and chunks.len() > 0 {
      chunks = chunks.slice(0, -1) + (chunks.last() + "\n\n" + t,)
    } else {
      chunks.push(t)
    }
  }
  let n = 0
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      out += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Markdown list: lettered items (A., B., ...) through the enum rule set in gand-complaint().
      out += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      let unnumbered = t.starts-with("^^ ")
      let text-md = if unnumbered { t.slice(3) } else { t }
      let lead = if unnumbered {
        h(para-indent)
      } else {
        n += 1
        [#h(para-indent)#n.#h(number-gap)]
      }
      out += [#lead#cmarker.render(text-md, raw-typst: false, smart-punctuation: true, h1-level: 1)]
    }
    out += parbreak()
  }
  out
}

#let gand-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-footer(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0.4em)

  // Headings: level 1 is a centered section in capitals; level 2 a centered bold heading; level 3 a bold
  // left-aligned sub-heading. A heading is a sticky block: it stays with the paragraph after it.
  show heading.where(level: 1): it => block(width: text-width, sticky: true, above: body-leading, below: body-leading, breakable: false,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, sticky: true, above: body-leading, below: body-leading, breakable: false,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, sticky: true, above: body-leading, below: body-leading, breakable: false,
    text(weight: "bold", it.body))

  cover(meta)

  if "lead_in" in meta {
    h(para-indent)
    inl(meta.lead_in)
    parbreak()
  }

  // Body: numbered paragraphs; markdown lists become lettered items (A., B., ...).
  set enum(numbering: "A.", indent: list-indent, body-indent: 0.4in, spacing: body-leading)
  set list(indent: list-indent, body-indent: 0.4in, spacing: body-leading)
  allegations(body)

  signature-block(meta)
}
