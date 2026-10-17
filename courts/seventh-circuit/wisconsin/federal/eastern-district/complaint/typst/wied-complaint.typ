// Complaint for the U.S. District Court for the Eastern District of Wisconsin (wied).
// Rules (texts in ../README.md): General L.R. 5(a) (8½ x 11 paper, one-inch margins, double spacing,
// 12-point proportional serif type), General L.R. 5(c) (signature block), Civil L.R. 8 (diversity
// pleading), Civil L.R. 10(a) (numbered paragraphs), Fed. R. Civ. P. 8(a), 10(a)-(b), 38.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // General L.R. 5(a)(6): proportional serif; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                   // General L.R. 5(a)(6)(A): 12-point or larger
#let page-w = 8.5in                     // General L.R. 5(a)(5): 8½ by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // General L.R. 5(a)(5): at least one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // General L.R. 5(a)(5): double-spaced; 1.345em leading on Liberation Serif's
                                        // 0.655em line box gives a 24 pt baseline pitch at 12 pt (measured, ../README.md)
#let single-leading = 0.5em             // single spacing: caption, headings, signature block, quotations
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wied-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a chunk of the body (heading, list or paragraph).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// A stack of single-spaced lines (caption, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items)
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

#let court-title() = line-stack((
  align(center, text(weight: "bold", [UNITED STATES DISTRICT COURT])),
  align(center, text(weight: "bold", [FOR THE EASTERN DISTRICT OF WISCONSIN])),
))

/// Party names on the left, the case number and jury legend on the right (no ruled box: the
/// pleading form in General L.R. 5 has no line numbers, and the caption is a plain two-column block).
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push(pad(left: 0.75in, [v.])) }
      rows += p.names.map(n => inl(n))
      rows.push(pad(left: 1.5in, inl(p.designation)))
    }
    line-stack(rows)
  },
  block(inset: (left: 0.1in), {
    let num = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
    line-stack((
      [Case No. #num],
      if meta.at("jury_demand", default: false) { [JURY TRIAL DEMANDED] } else { [] },
    ))
  }),
)

#let cover(meta) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.document_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b); Civil L.R. 10(a))
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one paragraph (numbered), a list (lettered, A., B., ...)
/// or a heading. Paragraphs under a level-1 heading "PRAYER..." or "DEMAND..." are not numbered: the prayer
/// and the jury demand are conventionally unnumbered. Numbering is applied per chunk, not with a `show par`
/// rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbered = true
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      if t.starts-with("# ") {
        let title = upper(t.trim("#", at: start).trim())
        numbered = not (title.starts-with("PRAYER") or title.starts-with("DEMAND"))
      }
      md(t)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A list may break across pages, like any body text.
      md(t)
      v(body-leading)
    } else if numbered {
      n += 1
      [#h(para-indent)#n.#h(0.3in)#md(t)]
      parbreak()
    } else {
      [#h(para-indent)#md(t)]
      parbreak()
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (General L.R. 5(c): "s/ name", attorney name, bar number, role, firm, address,
// telephone, e-mail)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  let lines = (inl(s.firm), inl(s.role), block(height: body-leading * 0.5))
  for sg in s.signers {
    lines.push(inl("s/ " + sg.name))
    lines.push(inl(sg.name))
    lines.push(inl(sg.bar))
    lines.push(block(height: single-leading))
  }
  for a in s.address { lines.push(inl(a)) }
  lines.push(inl("Telephone: " + s.telephone))
  for sg in s.signers { lines.push(inl("E-mail: " + sg.email)) }
  block(width: text-width, breakable: false, above: body-leading, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Dated this #meta.date.]
    v(body-leading)
    pad(left: 3.0in, line-stack(lines))
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let wied-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 centered bold caps (a section); level 2 centered bold (a count); level 3 bold italic.
  // Each is single-spaced and stays with the text after it.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: body-leading * 0.5, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading * 0.5, below: body-leading * 0.5, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    [#h(para-indent)#inl(meta.lead_in)]
    parbreak()
  }

  allegations(body)

  signature-block(meta)
}
