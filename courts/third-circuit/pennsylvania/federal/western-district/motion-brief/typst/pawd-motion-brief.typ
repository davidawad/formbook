// pawd-motion-brief.typ: memorandum of law in support of a motion, for the United States District Court
// for the Western District of Pennsylvania (a Rule 12(b) motion is the case the sample covers).
// Rules (fetched 2026-10-14, see ../README.md): LCvR 5.1.A-B (paper, type, spacing, margins, footnotes),
// LCvR 5.1.F (a motion and its brief are separate documents), LCvR 5.2.B (signature block with the
// PA bar number prefix), LCvR 7.D (a proposed order accompanies every motion, filed separately).
// Content-agnostic: no case text here. The sample supplies the frontmatter and the markdown body.
#import "@preview/cmarker:0.1.10"

// ---- LCvR 5.1 format ----
#let type-size = 12pt // LCvR 5.1.B: not smaller than 12 pt.
#let double = 24pt // LCvR 5.1.B: double-spaced, a baseline pitch of two type sizes (0.655 em line + 1.345 em leading).
#let para-indent = 0.5in
#let single-leading = 0.6em // headings, block quotations, footnotes, the caption and the signature block may be single-spaced.

#let md(s) = cmarker.render(s, smart-punctuation: true, raw-typst: false)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The caption: parties in a left column with a ")" column, the case number and the judge in a
/// right column that spans the rows. Names are plain text (no markdown).
#let caption(meta) = {
  let rows = ()
  for (i, p) in meta.caption.enumerate() {
    if i > 0 { rows.push("v.") }
    for n in p.names { rows.push(n) }
    rows.push(p.designation)
  }
  let right = block(width: 100%)[
    #set par(leading: single-leading)
    #meta.at("case_label", default: "Civil Action No.") #meta.case_number
    #if meta.at("judge", default: none) != none [
      #v(double)
      #meta.judge
    ]
    #if meta.at("electronically_filed", default: false) [
      #v(double)
      Electronically Filed
    ]
  ]
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells.push(block(width: 100%)[#set par(leading: single-leading); #r])
    cells.push(block(width: 100%)[#set par(leading: single-leading); #align(center)[)]])
    if k == 0 {
      cells.push(grid.cell(rowspan: rows.len(), align: horizon, right))
    }
  }
  grid(
    columns: (1fr, 0.4in, 2.9in),
    row-gutter: single-leading,
    ..cells,
  )
}

/// Each chunk of the markdown body is a block of text between blank lines.
#let chunks(body) = body.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// The heading level and text of a chunk: "# " is level 1 (a section), "## " level 2, and so on.
#let heading-level(c) = {
  let level = 0
  while c.starts-with("#") and c.len() > level and c.at(level) == "#" { level += 1 }
  level
}

/// Front matter and the body. Section headings are numbered by the template, not the sample:
/// level 1 I., II. (centered); level 2 A., B.; level 3 1., 2.; level 4 a., b. Each heading is a
/// real heading element, so the table of contents built from them carries the same numbers.
#let body-content(body) = {
  let c1 = 0
  let c2 = 0
  let c3 = 0
  let c4 = 0
  // A footnote is defined by a line "[^key]: text". Each paragraph carries the definitions of the keys it cites,
  // so cmarker can resolve the reference; definition lines are not paragraphs of their own.
  let defs = body.split("\n").filter(l => l.starts-with("[^")).map(l => l.trim())
  for c in chunks(body).filter(c => not c.starts-with("[^")) {
    let level = heading-level(c)
    if level > 0 {
      if level == 1 { c1 += 1; c2 = 0; c3 = 0; c4 = 0 }
      else if level == 2 { c2 += 1; c3 = 0; c4 = 0 }
      else if level == 3 { c3 += 1; c4 = 0 }
      else { c4 += 1 }
      let text = c.slice(level).trim()
      let prefix = if level == 1 { numbering("I.", c1) } else if level == 2 { numbering("A.", c2) } else if level == 3 { numbering("1.", c3) } else { numbering("a.", c4) }
      heading(level: level, outlined: true, numbering: none)[#prefix #h(0.5in) #text]
    } else if c.starts-with("> ") {
      // A block quotation: single-spaced, indented on both sides (LCvR 5.1.B).
      block(width: 100%, above: double, below: double)[
        #pad(left: 1in, right: 1in)[#set par(leading: single-leading); #md(c.slice(2))]
      ]
    } else {
      let cited = defs.filter(d => c.contains(d.slice(0, d.position(":"))))
      let src = c + cited.map(d => "\n\n" + d).join("")
      block(width: 100%)[#h(para-indent)#md(src)]
    }
  }
}

/// The signature block after the body. Single-spaced, set at the right half of the page.
#let signature(sig, date) = {
  block(breakable: false, width: 100%, above: double)[
    #set par(leading: single-leading)
    #if date != none [Date: #date \ ]
    #v(double)
    #pad(left: 3.0in)[
      #sig.lead
      #v(double)
      #if sig.at("firm", default: none) != none [#for f in sig.firm [#f \ ]]
      #v(double)
      #sig.signer \
      #for l in sig.lines [#md(l) \ ]
    ]
  ]
}

/// The memorandum. Page 1 is the caption page (no number). The table of contents is numbered in
/// roman numerals, and the body in arabic from 1 at the Introduction.
#let pawd-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(paper: "us-letter", margin: 1in, numbering: none)
  set text(font: "Liberation Serif", size: type-size, lang: "en", ligatures: true)
  set par(leading: 1.345em, justify: false, spacing: 0pt) // 0.655 em line (Liberation Serif) + 1.345 em leading = a 24 pt pitch at 12 pt
  set block(spacing: 1.345em) // the gap between blocks is the leading again, so the pitch stays 24 pt
  // LCvR 5.1.B: footnotes are single-spaced and in the same type size as the body.
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading)
  // Headings: sections centered in capitals; the lower levels flush left, indented by level.
  show heading: it => block(width: 100%, above: double, below: 0pt, sticky: true)[
    #set par(leading: single-leading)
    #set text(size: type-size)
    #if it.level == 1 [#align(center, strong(it.body))] else [#set par(hanging-indent: 0.5in); #pad(left: (it.level - 2) * 0.5in, strong(it.body))]
  ]

  block(width: 100%, align(center)[*IN THE UNITED STATES DISTRICT COURT*])
  block(width: 100%, above: 0pt, align(center)[*FOR THE WESTERN DISTRICT OF PENNSYLVANIA*])
  block(width: 100%, above: double, caption(meta))
  block(width: 100%, above: double, align(center, strong(meta.title)))

  pagebreak()
  set page(numbering: "i")
  counter(page).update(2) // the caption page is i and is not printed
  align(center, strong[TABLE OF CONTENTS])
  block(width: 100%, above: double, outline(title: none, indent: n => 0.5in * n))

  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  body-content(body)
  signature(meta.signature, meta.at("date", default: none))
}
