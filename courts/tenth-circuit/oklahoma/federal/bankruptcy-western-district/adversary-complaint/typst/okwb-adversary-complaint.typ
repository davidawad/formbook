// Adversary complaint for the U.S. Bankruptcy Court, Western District of Oklahoma (okwb).
// Rules: Fed. R. Bankr. P. 7001(f) (dischargeability is an adversary proceeding), 7008(a) (jurisdiction,
// consent to final orders, demand for relief), 7010 (Fed. R. Civ. P. 10 applies: caption, numbered
// paragraphs); Fed. R. Bankr. P. 9004(a)-(b) (legibility, caption); Local Rules 9004-1.A (paper, font,
// margins, spacing), 7003-1 (cover sheet), 7040-1 (assignment). See ../README.md for the quoted text.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 9004-1.A: a standard font; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // LR 9004-1.A: no less than 12 point, footnotes included
#let page-margin = 1in                  // LR 9004-1.A: margins no less than one inch
#let body-leading = 0.893em             // LR 9004-1.A: double spaced; Liberation Serif line box 1.107em (hhea ascender to descender) + 0.893em = 24 pt pitch at 12 pt
#let single-leading = 0.698em           // caption, headings that wrap, signature block (single spaced)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.3in               // party column of the caption
#let caption-paren = 0.25in             // ")" column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, footnote references) as inline content.
#let inl(s) = if s.trim() == "" { [] } else { cmarker.render(s, raw-typst: false, smart-punctuation: true) }

/// Fill whole double-spaced lines so whatever follows stays on the 24 pt grid.
#let on-grid(c) = layout(size => {
  let h = measure(width: size.width, c).height
  block(width: 100%, height: calc.ceil(h / 24pt) * 24pt, above: 0pt, below: 0pt, c)
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, document title
// ---------------------------------------------------------------------------

/// Caption rows: each row is [left, right]. The ")" column is printed on every row (LR 9004-1.D is the
/// signature rule; the caption form follows Fed. R. Bankr. P. 9004(b) and Official Form 416).
/// A left entry starting with a space is indented; "" leaves the cell empty.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let cells = ()
  for row in meta.caption.rows {
    let left = row.at(0)
    let right = if row.len() > 1 { row.at(1) } else { "" }
    let indent = if left.starts-with(" ") { 1.0in } else { 0pt }
    cells += (
      box(width: 100%, pad(left: indent, inl(left.trim()))),
      [)],
      inl(right),
    )
  }
  grid(
    columns: (caption-left, caption-paren, 1fr),
    align: (left + top, center + top, left + top),
    row-gutter: 0pt,
    ..cells,
  )
}

#let cover(meta) = {
  align(center, text(weight: "bold", [IN THE UNITED STATES BANKRUPTCY COURT]))
  align(center, text(weight: "bold", [FOR THE WESTERN DISTRICT OF OKLAHOMA]))
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered items, signature
// ---------------------------------------------------------------------------

/// Markdown contract (see README.md): `#` heading (centered, bold, caps); plain paragraph (numbered 1., 2., ...
/// by the template); `> ` paragraph (unnumbered, e.g. the lead-in to a cause of action); `- ` items (lettered
/// (a), (b), ...). Footnote definitions stay with the chunk that references them.
#let is-numbered(t) = not t.starts-with("#") and not t.starts-with(">") and not t.starts-with("- ")

#let list-items(t) = {
  let items = ()
  for line in t.split("\n") {
    if line.starts-with("- ") {
      items.push(line.slice(2))
    } else if items.len() > 0 {
      let last = items.pop()
      items.push(last + " " + line.trim())
    }
  }
  items
}

#let letter(i) = "(" + str.from-unicode(96 + i) + ")"

/// Headings are capitals, but a statute cited after "§" keeps its lowercase subsections: 523(a)(2)(A), not 523(A).
#let heading-caps(t) = {
  let parts = t.split("§")
  if parts.len() == 1 { upper(t) } else { upper(parts.first()) + "§" + parts.slice(1).join("§") }
}

#let allegations(body) = {
  // Blank-line chunks; a footnote definition chunk joins the chunk before it.
  let raw = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let chunks = ()
  for c in raw {
    if c.starts-with("[^") and chunks.len() > 0 {
      let last = chunks.pop()
      chunks.push(last + "\n\n" + c)
    } else {
      chunks.push(c)
    }
  }
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      // A heading is a single centered line, kept with the chunk after it (it never ends a page).
      block(width: 100%, sticky: true, above: body-leading, below: 0pt,
        align(center, text(weight: "bold", heading-caps(t.trim("#").trim()))))
    } else if t.starts-with("- ") {
      let items = list-items(t)
      set par(leading: body-leading)
      for (j, it) in items.enumerate() {
        grid(columns: (para-indent + 0.5in, 1fr), inl(letter(j + 1)), inl(it))
      }
    } else if t.starts-with(">") {
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        inl(t.slice(1).trim())
      })
    } else {
      // Numbered paragraph: the number is the count of numbered chunks so far (Fed. R. Civ. P. 10(b)).
      let k = chunks.slice(0, i).filter(is-numbered).len() + 1
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        [#k.#h(0.3in)]
        inl(t)
      })
    }
  }
}

#let signature(meta) = {
  // LR 9004-1.D: the signature block follows the filer's CM/ECF profile.
  on-grid(align(right, box(width: 3.4in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully Submitted,]
    v(body-leading)
    for ln in meta.signature.lines { [#ln \ ] }
  })))
  if "approval" in meta {
    v(body-leading)
    on-grid({
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Approved by:]
      v(body-leading)
      for ln in meta.approval { [#ln \ ] }
    })
  }
}

#let okwb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", top-edge: 0.891em, bottom-edge: -0.216em)  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body)

  signature(meta)
}
