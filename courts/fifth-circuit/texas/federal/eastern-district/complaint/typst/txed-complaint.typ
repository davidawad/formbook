// Complaint for the U.S. District Court for the Eastern District of Texas (txed).
// Rules: Local Rule CV-10(a) (style and number, caption with party designation, double spacing,
// 12-point minimum type, 8 1/2 x 11 paper), CV-7(a) (separate document, searchable PDF), CV-4(c) (party
// names in the caption); Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt              // CV-10(a)(5): no smaller than 12-point
#let page-w = 8.5in                // CV-10(a)(4): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let body-leading = 1.645em        // CV-10(a)(5): double spaced. Liberation Serif's line box is 0.655em, so this gives a 27.6 pt baseline pitch at 12 pt (the exemplar's pitch, measured in README.md)
#let body-gap = body-leading       // space above each block: typst's leading only goes between lines, so a block needs this above it to stay on the grid
#let single-pitch = 13.8pt         // single spacing (caption, counsel, signature): half the double-spaced pitch
#let indent = 0.5in                // first-line indent of numbered paragraphs and the body text
#let caption-right = 2.6in         // width of the right-hand column of the caption (case number, jury demand)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line: a block of exactly one single pitch, so lines stack on a fixed pitch.
#let sline(c) = block(width: 100%, height: single-pitch, above: 0pt, below: 0pt, c)

// ---------------------------------------------------------------------------
// Cover: court (line 1 onward), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(lines) = for l in lines {
  sline(align(center, text(weight: "bold", upper(l))))
}

#let caption(meta) = grid(
  columns: (1fr, caption-right),
  column-gutter: 0.25in,
  {
    // Each party: its names, then its designation; "v." between the parties (Fed. R. Civ. P. 10(a)).
    for (k, p) in meta.caption.enumerate() {
      if k > 0 {
        sline([v.])
      }
      for n in p.names {
        sline(inl(n))
      }
      sline(pad(left: 1.5in, inl(p.designation)))
    }
  },
  align(bottom, {
    sline(inl(meta.case_number))
    v(single-pitch)
    if "jury_demand" in meta { sline(text(weight: "bold", meta.jury_demand)) }
  }),
)

#let title-of-paper(meta) = {
  v(body-gap)
  block(width: 100%, height: single-pitch, align(center, text(weight: "bold", upper(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Signature block (CV-10(a)(3): signed by the lead attorney or with his or her permission)
// ---------------------------------------------------------------------------

#let signature(sig) = block(width: 100%, breakable: false, above: body-gap, {
  pad(left: 3.0in, {
    sline([Respectfully submitted,])
    v(single-pitch)
    for l in sig.firm { sline([#l]) }
    v(single-pitch)
    sline([/s/ #sig.signer])
    sline([#sig.signer])
    for l in sig.lines { sline(inl(l)) }
    v(single-pitch)
    sline(inl(sig.role))
  })
})

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered prayer items
// ---------------------------------------------------------------------------

/// Level-1 headings are sections: centered, bold, capitals, numbered I., II., ... by the template.
#let section-heading(it) = block(width: 100%, above: body-gap, sticky: true, {
  align(center, text(size: type-size, weight: "bold", [#counter("section").step()#context counter("section").display("I.") #upper(it.body)]))
})

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the number at the first-line indent, the text after it.
/// The number comes from one counter for the whole pleading; markdown's own numbers are ignored.
#let numbered(items) = for item in items {
  block(width: 100%, above: body-gap, {
    set par(first-line-indent: 0pt, leading: body-leading)
    h(indent)
    [#counter("para").step()#context counter("para").display("1.")]
    h(indent)
    item.body
  })
}

/// A lettered list (the prayer): (a) at the indent, the text hangs after it.
#let lettered(items) = for (i, item) in items.enumerate() {
  block(width: 100%, above: body-gap, {
    set par(first-line-indent: 0pt, leading: body-leading)
    grid(
      columns: (indent * 2, 1fr),
      pad(left: indent, numbering("a.", i + 1)),
      item.body,
    )
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let txed-complaint(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer: context align(center, text(size: 11pt, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-gap, first-line-indent: indent)
  set heading(numbering: none)
  show heading.where(level: 1): it => section-heading(it)
  show enum: it => numbered(it.children)
  show list: it => lettered(it.children)

  court-title(meta.court)
  v(body-gap)
  caption(meta)
  title-of-paper(meta)

  set par(first-line-indent: indent)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature(meta.signature)
}
