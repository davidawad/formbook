// Complaint for the U.S. District Court for the Northern Mariana Islands (nmid).
// Rules: D.N.M.I. LR 5.2 (paper, numbered lines down the left margin, double spacing, 12-point serif
// type, margins, top-right corner blank on page one, court title, caption, hearing date where it applies);
// Fed. R. Civ. P. 10(a) and 10(b) (caption; numbered paragraphs). See ../README.md for the rule text
// and its source. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // LR 5.2.a: a serif font; Times New Roman (vendored) per docs/FONTS.md
#let type-size = 12pt                   // LR 5.2.a: 12-point type or larger
#let footer-size = 10pt                 // the footer (page number, title, case number) below the numbered lines
#let page-w = 8.5in                     // LR 5.2.a: 8.5 x 11 inch paper
#let page-h = 11in
#let top-margin = 1.5in                 // LR 5.2.a: not less than 1.5 inches on the top
#let left-margin = 1in                  // LR 5.2.a: one inch on the left-hand side (line numbers sit in it)
#let right-margin = 0.5in               // LR 5.2.a: one-half inch on the right-hand side
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent; a paragraph number starts here
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let label-box = 0.5in                  // a prayer item's label box after the indent; the text hangs after it
#let counsel-width = 3.6in              // LR 5.2.a: the counsel block stays clear of the clerk's three top-right inches
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-pad = 10pt                 // the party text stops this far left of the caption's rule
#let caption-gutter = 0.25in            // between the caption's rule and the file number column
#let sig-left = 2.8in                   // the signature grid: "Dated" column, then the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nmid-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch = 24pt                       // LR 5.2.a: double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // single-spaced lines (counsel, court title, caption, signature): half a numbered line, so each
                                        // line number stands on the baseline of every second one (docx: exact 12 pt)
#let single-drop = 0.4 * pitch          // a single-spaced block starts this far below the top of a numbered line: its 1st, 3rd, ...
                                        // lines then stand on the numbered lines' baselines (0.4 x 24 + 0.8 x 12 = 0.8 x 24)
#let pitch-footer = 12pt                // a footer line (10 pt type)
// LR 5.2.a sets the top and bottom margins, not the line count. 1.5 in top and 1 in bottom leave 8.5 in, which
// holds 25 double-spaced lines (25 x 24 pt = 600 pt); the bottom margin is what is left (84 pt, more than 1 in).
#let lines-per-page = 25
#let bottom-margin = page-h - top-margin - lines-per-page * pitch
#let counsel-lines = 7                  // the counsel block takes at least numbered lines 1 to 7; the court title follows
#let footer-top = top-margin + lines-per-page * pitch + 48pt // the page number's line box (docx: the footer distance)
#let footer-gap = 4pt                   // between the page number and the title line

// The court's title, LR 5.2.d.1: two lines, single-spaced and centered, at least 1.5 inches from the top.
#let court-title-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN MARIANA ISLANDS")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmid-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (inline or a chunk) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  par(first-line-indent: 0pt, unloose(c))
})

/// The height of a single-spaced block of `n` lines (after its drop) rounded up to whole numbered lines: it then ends on the grid
/// of numbered lines (docx: the same arithmetic, as a table row's minimum height or a paragraph's space).
#let grid-height(n) = calc.ceil((single-drop + n * pitch-single) / pitch) * pitch

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 25 down the left margin, one per numbered line, on the baselines of the body's lines.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.3in, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.12in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// The footer: "-N-" centered, then the paper's title at the left and the case number at the right, in 10 pt lines.
#let footer-block(title, case-number) = place(top + left, dx: left-margin, dy: footer-top,
  block(width: text-width, {
    set text(size: footer-size, ..edges(pitch-footer))
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display("-1-")))
    block(width: 100%, above: footer-gap, below: 0pt, grid(columns: (1fr, auto), upper(title), [CASE NO. #case-number]))
  }))

// ---------------------------------------------------------------------------
// First page: counsel (lines 1-7), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel identification, upper left (LR 5.2.c), single-spaced, at least `counsel-lines` numbered lines tall
/// (docx: a table row of that minimum height). Kept narrower than the top-right three inches (LR 5.2.a).
#let counsel-block(meta) = context {
  let c = block(width: counsel-width, above: 0pt, below: 0pt, inset: (top: single-drop), for l in meta.counsel { sline(md(l)) })
  block(width: counsel-width, above: 0pt, below: 0pt,
    height: calc.max(counsel-lines * pitch, measure(c).height), c)
}

/// The court title: two single lines, centered and bold, on one numbered line, then a blank one (docx: the space
/// below).
#let court-title() = block(width: 100%, above: 0pt, below: 0pt, height: 2 * pitch, inset: (top: single-drop), {
  for l in court-title-lines { sline(centered: true, text(weight: "bold", l)) }
})

/// The caption: the parties (names, designation, "v." between them) left of a right and bottom rule; the file
/// number and the title of the paper right of it (LR 5.2.d.2, 5.2.d.3). The row is at least the party lines plus
/// two, rounded up to whole numbered lines (docx: the table row's minimum height), so the text below stays on the
/// grid unless a name wraps.
#let caption(meta) = context {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let left = block(width: caption-left - caption-pad, above: 0pt, below: 0pt, inset: (top: single-drop), for r in rows { sline(md(r)) })
  let right = block(width: text-width - caption-left - caption-gutter, above: 0pt, below: 0pt, inset: (top: single-drop), {
    sline[CIVIL CASE NO. #meta.case_number]
    sline(above: pitch-single, text(weight: "bold", md(meta.brief_title)))
    if "jury_demand" in meta and meta.jury_demand {
      sline(above: pitch-single, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
    }
  })
  let h = calc.max(grid-height(rows.len() + 1), measure(left).height, measure(right).height)
  block(width: 100%, above: 0pt, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    rows: (h,),
    block(width: caption-left, height: h, stroke: (right: 0.75pt, bottom: 0.75pt), left),
    [],
    right,
  ))
}

#let first-page(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
  // a blank numbered line between the caption and the text (docx: a paragraph of one numbered line)
  block(width: 100%, above: 0pt, below: 0pt, height: pitch)
  if "lead_in" in meta {
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), unloose(md(meta.lead_in))))
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block, single-spaced, one blank numbered line below the text: the date left, the signature column
/// right (docx: a one-row table that never splits).
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, above: pitch, below: 0pt, breakable: false, grid(
    columns: (sig-left, 1fr),
    pad(top: single-drop, sline[Dated: #meta.date]),
    pad(top: single-drop, {
      sline[Respectfully submitted,]
      for (i, f) in sig.firm.enumerate() { sline(above: if i == 0 { pitch-single } else { 0pt }, md(f)) }
      sline(above: pitch-single)[/s/ #sig.signer]
      sline(md(sig.signer))
      for l in sig.lines { sline(md(l)) }
    }),
  ))
}

/// A heading: one numbered line, kept with the text after it (docx: Heading 1 to 3, keep with next).
/// Level 1 centered bold capitals; level 2 centered bold; level 3 bold italic.
#let heading-line(level, t) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, context {
  let c = par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(md(t)))) }
    else if level == 2 { text(weight: "bold", unloose(md(t))) }
    else { text(weight: "bold", style: "italic", unloose(md(t))) })
  assert(measure(c, width: text-width).height <= pitch, message: "nmid-complaint: a heading must fit on one numbered line")
  if level <= 2 { align(center, c) } else { c }
})

/// A body paragraph on the double pitch, its first line indented; `number` in a box after the indent, or none.
#let body-par(number, c, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: para-indent, all: true),
    if number == none { unloose(c) } else [#box(width: number-box, str(number) + ".")#unloose(c)]))

/// A prayer item: its label in a box after the indent, the text hanging after it (docx: a tab and a hanging indent).
#let list-item(label, c) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: para-indent + label-box,
    [#h(para-indent)#box(width: label-box, label)#unloose(c)]))

/// The body. Each blank-line-separated chunk of markdown is a heading, a list (its items lettered (a), (b), ...),
/// an unnumbered paragraph ("~ " in front: the prayer's lead-in, kept with what follows), or a numbered paragraph
/// (Fed. R. Civ. P. 10(b)). The last chunk is kept on one page with the signature block.
#let render-body(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  let n = 0
  let units = ()
  for t in chunks {
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      units.push(heading-line(m.captures.at(0).len(), m.captures.at(1)))
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      units.push(for (i, item) in items.enumerate() { list-item(numbering("(a)", i + 1), md(item)) })
    } else if t.starts-with("~ ") {
      units.push(body-par(none, md(t.slice(2)), sticky: true))
    } else {
      n += 1
      units.push(body-par(n, md(t)))
    }
  }
  for (i, u) in units.enumerate() {
    if i == units.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { u; signature-block(meta) })
    } else { u }
  }
}

#let nmid-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch, list-indent: none)

  first-page(meta)
  render-body(body, meta)
}
