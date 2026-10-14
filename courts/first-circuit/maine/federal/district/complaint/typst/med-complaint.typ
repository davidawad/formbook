// Complaint for the United States District Court for the District of Maine (med).
// Rules: D. Me. Local Rule 3 (filing items), 10(a) (caption and title), 10(b) (form): 12-point or larger type;
// text double-spaced; 8 1/2 x 11 inch paper; page numbers at the bottom; 1-inch margins. Fed. R. Civ. P. 10(a)
// (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // the only font vendored in fonts/ (README.md, known gaps)
#let type-size = 13pt                   // LR 10(b)(1): 12-point or larger. 13 pt EB Garamond has about the x-height of 12 pt Times, the face in the filed exemplars (README.md)
#let page-w = 8.5in                     // LR 10(b)(3): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // LR 10(b)(5): 1-inch margins on all four sides
#let body-leading = 27.6pt - 0.65em    // LR 10(b)(2): double-spaced: 27.6 pt baseline pitch (Word double spacing for 12 pt Times; the filed exemplars measure 27.6 pt) less EB Garamond's 0.65 em line box
#let single-leading = 0.5em             // caption, title, block quotes, signature: single-spaced (about 14 pt)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party block of the caption
#let designation-indent = 1.5in         // "Plaintiff," / "Defendants." set in from the party names

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("med-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (names, paragraphs, headings; smart quotes).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 10(a); FRCP 10(a))
// ---------------------------------------------------------------------------

/// The party column: each party's names, then its designation set in from the names; "v." between parties.
#let party-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let items = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { items.push([v.]) }
    for n in p.names { items.push(md(n)) }
    items.push(block(width: 100%, inset: (left: designation-indent), md(p.designation)))
  }
  stack(dir: ttb, spacing: single-leading, ..items)
}

/// Party column closed by a rule at its right and bottom; the case number (or a blank for the clerk) at right.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 8pt), party-block(meta)),
  align(horizon, block(inset: (left: 0.1in), {
    // With no case number yet (a new complaint), a blank is left for the clerk to fill in.
    if meta.case_number == "" [Civil Action No. #box(width: 1.6in, height: 0.9em, stroke: (bottom: 0.6pt))]
    else [Civil Action No. #meta.case_number]
  })),
)

/// The court's name, two centered bold lines (LR 10(a): the caption names the court).
#let court-title() = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")),
  align(center, text(weight: "bold", "DISTRICT OF MAINE")),
)

/// The title of the paper, and its subtitle, under the caption (LR 10(a)).
#let title-block(meta) = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", upper(meta.title))),
  if "subtitle" in meta and meta.subtitle != none { align(center, md(meta.subtitle)) },
)

#let cover(meta) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  title-block(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), headings, lettered lists, block quotes
// ---------------------------------------------------------------------------

/// Signature block: the date, then the signing attorney's /s/ line and the lines of the block.
#let signature-block(meta) = block(width: 100%, sticky: true, {
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    stack(dir: ttb, spacing: single-leading,
      [/s/ #meta.signature.signer],
      ..meta.signature.lines.map(l => [#l]),
    ),
  )
})

/// Walk the markdown body. Blank lines separate chunks. `#` headings are styled by show rules below;
/// `N.` list items are lettered A., B., ... by the template (the prayer); `>` block quotes are single-spaced
/// and unnumbered; `~ ` paragraphs are unnumbered (the WHEREFORE clause); every other paragraph is numbered.
/// The counter is stepped in markup, not in a code block, so the number is read after the step.
#let body-pieces(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let out = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Items fill whole lines at double spacing; the trailing v() closes the list.
      out.push({
        set par(leading: body-leading)
        md(t)
        v(body-leading)
      })
    } else if t.starts-with(">") {
      out.push(block(width: 100%, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading)
        md(t)
      }))
    } else if t.starts-with("~ ") {
      out.push({
        set par(leading: body-leading)
        [#h(para-indent)#md(t.slice(2))]
      })
    } else {
      out.push({
        set par(leading: body-leading)
        [#para-counter.step()#context [#h(para-indent)#para-counter.display()\.#h(0.25in)#md(t)]]
      })
    }
  }
  out
}

#let med-complaint(meta, body) = {
  let para-counter = counter("paragraph")

  set page(
    paper: "us-letter",
    margin: margin,
    // LR 10(b)(4): each page numbered at the bottom.
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in)

  // Headings: level 1 is a centered bold section; level 2 a centered bold sub-heading (a bracketed
  // statute line under a claim); level 3 bold italic at the left. Each is kept with what follows it.
  show heading.where(level: 1): it => block(width: 100%, above: single-leading * 2, below: single-leading * 2, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: single-leading, below: single-leading * 2, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: single-leading, below: single-leading, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)
  let pieces = body-pieces(body, para-counter)
  let last = pieces.pop()
  for p in pieces { p }
  // The last paragraph (the jury demand) stays on the page with the signature block.
  block(width: 100%, breakable: false, {
    last
    v(body-leading)
    signature-block(meta)
  })
}
