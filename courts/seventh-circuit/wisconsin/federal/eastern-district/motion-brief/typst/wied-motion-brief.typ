// Brief supporting a motion for the U.S. District Court for the Eastern District of Wisconsin (wied).
// Rules (texts in ../README.md): General L.R. 5(a) (8½ x 11 paper, one-inch margins, double spacing,
// single-spaced quotations of more than two lines, 12-point proportional serif type, case names italicized),
// General L.R. 5(c) (signature block), Civil L.R. 7(a) (a motion is accompanied by a supporting memorandum),
// Civil L.R. 7(f) (30-page limit for a principal memorandum, 15 for a reply; the caption, signature block and
// tables are excluded), Civil L.R. 7(j) (citations). Fed. R. Civ. P. 12(b).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // General L.R. 5(a)(6): proportional serif; vendored in fonts/
#let type-size = 12pt                   // General L.R. 5(a)(6)(A): 12-point or larger
#let page-w = 8.5in                     // General L.R. 5(a)(5): 8½ by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // General L.R. 5(a)(5): at least one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // General L.R. 5(a)(5): double-spaced; 1.35em leading on EB Garamond's
                                        // 0.65em line box gives a 24 pt baseline pitch at 12 pt (measured, ../README.md)
#let single-leading = 0.5em             // single spacing: caption, headings, quotations, signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wied-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a chunk of the body (heading, quotation or paragraph).
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

/// Party names on the left, the case number on the right (no ruled box).
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
    line-stack(([Case No. #num],))
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
// Body: unnumbered paragraphs (briefs are not numbered; Civil L.R. 10(a) applies to pleadings)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one of: a section heading (`#`, centered caps), an argument
/// heading (`##`, "I. TEXT" with a hanging numeral), a sub-heading (`###`, "a. TEXT"), a block quotation
/// (`>`, single-spaced and indented, General L.R. 5(a)(5)), or a paragraph (first-line indent, double-spaced).
/// Numbering is not applied: a brief's paragraphs are not numbered. Chunks are placed as separate paragraphs
/// (parbreak); a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("## ") {
      let m = t.match(regex("^##\\s+([IVX]+\\.)\\s+([\\s\\S]*)$"))
      if m != none {
        // Argument heading: the numeral sits in a hanging column; wrapped lines align with the text.
        block(width: text-width, above: body-leading, below: body-leading * 0.5, sticky: true, {
          set par(leading: single-leading, spacing: 0pt)
          grid(columns: (0.5in + 0.5in, 1fr), text(weight: "bold", m.captures.at(0)),
            text(weight: "bold", inl(m.captures.at(1))))
        })
      } else {
        md(t)
      }
      parbreak()
    } else if t.starts-with("#") {
      md(t)
      parbreak()
    } else if t.starts-with(">") {
      // Block quotation: single-spaced, indented on both sides, with double spacing around it.
      block(width: text-width, above: body-leading, below: body-leading, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
        inl(t.replace(">", "").trim())
      })
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

#let wied-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Section headings (level 1): centered bold caps. Sub-headings (level 3): bold italic, indented.
  // Level 2 ("I. TEXT") is handled in body-chunks with a hanging numeral.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => pad(left: 0.5in, block(width: text-width - 0.5in, above: body-leading * 0.5,
    below: body-leading * 0.5, sticky: true, text(weight: "bold", style: "italic", it.body)))

  cover(meta)

  body-chunks(body)

  signature-block(meta)
}
