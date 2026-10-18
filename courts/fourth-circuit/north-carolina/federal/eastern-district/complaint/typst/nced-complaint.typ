// Complaint for the U.S. District Court for the Eastern District of North Carolina (nced).
// Rules: Local Civil Rule 10.1 (letter paper, double-spaced, at least 11-point type, one-inch margins, court
// and division, case number after the initial filing, caption, title, attorney block, date, signature with the
// typed name, sequential page numbers); Fed. R. Civ. P. 8(a), 10(a) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Schola"        // Schola matches the audited exemplar (docs/FONTS.md); see README, "Known gaps"
#let type-size = 12pt                   // LR 10.1(a): at least 11 point
#let margin = 1in                       // LR 10.1(a): one inch on all sides
#let body-leading = 1.645em             // LR 10.1(a): double-spaced; measured on the render (README)
#let single-leading = 0.5em             // single spacing: court title, caption, signature block
#let para-indent = 0.5in                // first-line indent of text paragraphs
#let number-gap = 0.3in                 // space after an allegation's number
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.25in             // column of ")" marks, one per caption line
#let title-gap = 0.25in                 // space between the ")" column and the title block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nced-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, bold, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: headings are level 1 to 3 (h1-level 1 keeps "#" a top-level heading).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LR 10.1(j): every page numbered sequentially, centered at the foot of the page.
#let page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court and division (LR 10.1(b)), case number (LR 10.1(c)), caption (LR 10.1(d)), title (LR 10.1(e))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let lines = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE EASTERN DISTRICT OF NORTH CAROLINA",
    upper(meta.division) + " DIVISION",
  )
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, l)))
}

#let case-number-line(meta) = {
  // LR 10.1(c): the case number is assigned by the clerk; an initial filing leaves it blank.
  let num = meta.at("case_number", default: none)
  align(center, if num == none { [No. #("_" * 14)] } else { [No. #num] })
}

/// One caption line. The line is a list entry: `"text"`, or `{t: "text", i: indent in half inches}`.
#let caption-item(x) = if type(x) == str { (t: x, i: 0) } else { (t: x.at("t", default: ""), i: x.at("i", default: 0)) }

#let caption-cell(r) = context {
  let c = [#h(r.i * 0.5in)#r.t]
  assert(measure(c).width <= caption-left, message: "nced-complaint: a caption line must fit on one line: " + r.t)
  c
}

/// The title block, to the right of the ")" column: the paper's title and any jury legend.
#let title-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  text(weight: "bold", inl(meta.brief_title))
  if "jury_demand" in meta and meta.jury_demand {
    v(single-leading)
    text(weight: "bold", "(JURY TRIAL DEMANDED)")
  }
}

#let caption(meta) = {
  let rows = meta.caption.lines.map(caption-item)
  grid(
    columns: (caption-left, caption-paren, 1fr),
    row-gutter: single-leading,
    // The title sits beside the whole caption, centered on it; the caption rows fill columns 1 and 2.
    grid.cell(x: 2, y: 0, rowspan: rows.len(), align(horizon, pad(left: title-gap, title-block(meta)))),
    ..rows.map(r => (caption-cell(r), [)])).flatten(),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  case-number-line(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (LR 10.1(f), (g), (h), (i)): date, firm, "BY: /s/" line, the typed name under it,
/// address and telephone, state bar numbers and e-mail, and the party represented.
#let line-stack(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))

#let signature-block(meta) = block(breakable: false, width: 100%, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  [This the #meta.date.]
  v(body-leading)
  let sig = meta.signature
  let firm = sig.at("firm", default: ())
  pad(left: 3in, {
    if firm.len() > 0 {
      line-stack(firm)
      v(single-leading)
    }
    let by = sig.at("by", default: sig.signers.at(0).name)
    line-stack((if firm.len() > 0 { "BY: /s/ " + by } else { "/s/ " + by },))
    v(single-leading)
    for s in sig.signers {
      line-stack((s.name,) + s.lines)
      v(single-leading)
    }
    line-stack(sig.at("address", default: ()))
    v(single-leading)
    line-stack(sig.at("counsel_for", default: ()))
  })
})

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading, a list nor a WHEREFORE clause is one numbered paragraph. Headings and lists are not
/// numbered; the prayer's WHEREFORE clause is not numbered (it is not an allegation).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
/// Footnote definitions (`[^key]: text`) are not paragraphs: each chunk carries them so that a
/// reference in any chunk resolves.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let notes = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  let n = 0
  for t in chunks.filter(c => not c.starts-with("[^")) {
    let src = if notes == "" { t } else { t + "\n\n" + notes }
    if t.starts-with("#") {
      md(src)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list follows the paragraph before it at a double-spaced gap; a list's items are spaced by body-leading.
      block(above: body-leading, width: 100%, md(src))
    } else if t.starts-with("WHEREFORE") {
      [#h(para-indent)#md(src)]
      parbreak()
    } else {
      n += 1
      [#h(para-indent)#n.#h(number-gap)#md(src)]
      parbreak()
    }
  }
}

#let nced-complaint(meta, body) = {


  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)
  // LR 10.1(a) "typed matter": footnotes are typed matter too.
  show footnote.entry: set text(size: type-size)

  // Lettered prayer items (A., B., ...) and their hanging indent.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold italic.
  // Each heading is sticky: it never ends a page. A wrapped heading keeps double spacing.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, [#h(para-indent)#inl(meta.lead_in)])
  }

  allegations(body)

  v(body-leading)
  signature-block(meta)
}
