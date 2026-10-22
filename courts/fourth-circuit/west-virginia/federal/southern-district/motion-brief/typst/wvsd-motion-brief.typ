// Memorandum of law in support of a motion to dismiss, United States District Court, S.D. W. Va. (wvsd).
// Rules: LR Civ P 7.1(a)(2) (length), (a)(3) (paper, double spacing, margins), (a)(4) (typeface),
// (a)(6) (a motion to dismiss is a separate pleading); Fed. R. Civ. P. 10(a) (caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 7.1(a)(4): proportional face; Times New Roman is on the presumed-legible list; Liberation Serif is its metric twin (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // LR 7.1(a)(4): 12-point or larger; footnotes and headings included
#let margin = 1in                       // LR 7.1(a)(3): at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in                // a heading's number box; each deeper level starts this much further in
#let quote-indent = 0.5in               // block quotations, both sides
#let caption-left = 3.0in               // width of the party column of the caption
#let caption-paren = 0.3in              // the column of ")" marks between parties and the case number
#let caption-right-pad = 0.2in          // the case number and judge stand this far right of the ")" column
#let block-indent = 3.25in              // counsel block and signature block start here

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/reference.xml and the filter set the same twips).
#let pitch-body = 24pt                  // LR 7.1(a)(3) double spacing: a 24 pt pitch at 12 pt
#let pitch-single = 13.8pt              // single spacing (LR 7.1(a)(3) allows it for headings, quotations, footnotes; caption, counsel, signature): Word's single line, 1.15 x 12 pt
#let h1-above = 18pt                    // space above a level-1 heading
#let h-above = 12pt                     // space above a deeper heading
#let h-below = 12pt                     // space below every heading
#let quote-gap = 12pt                   // above and below a block quotation
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the text and the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line (or paragraph) with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// Single-spaced lines at `left`; "" is a blank line (the next line stands one single line lower).
#let lines-block(items, left: 0pt, above: 0pt) = {
  let skip = above
  for i in items {
    if i == "" { skip += pitch-single } else {
      line-block(above: skip, left: left, inl(i))
      skip = 0pt
    }
  }
}

/// Heading numbers, set by the template (never typed in the sample). Level 1 is unnumbered.
/// Level 2 I., level 3 A., level 4 1., level 5 a.
#let heading-numbering(..n) = {
  let level = n.pos().len()
  let num = n.pos().last()
  if level == 2 { numbering("I.", num) }
  else if level == 3 { numbering("A.", num) }
  else if level == 4 { numbering("1.", num) }
  else if level == 5 { numbering("a.", num) }
  else { none }
}

// ---------------------------------------------------------------------------
// Cover page: court title, caption, title of the paper, counsel (the caption page carries no page number)
// ---------------------------------------------------------------------------

/// The caption: one row per party line, a column of ")" marks, and the case number and judge at the right, in
/// the rows at the middle of the caption. A side's `lead` is printed before it ("v." by default between sides;
/// "" for none). A blank row separates the sides.
#let caption(meta) = {
  let rows = ()
  for (k, side) in meta.caption.enumerate() {
    let lead = side.at("lead", default: if k == 0 { "" } else { "v." })
    if lead != "" { rows.push((0.5in, lead)) }
    for n in side.names { rows.push((0pt, n)) }
    rows.push((1.0in, side.designation))
    rows.push(none)
  }
  rows = rows.slice(0, rows.len() - 1)
  let right = ()
  if "civil_action" in meta { right.push(meta.civil_action) }
  if "judge" in meta { right.push(meta.judge) }
  let first = calc.floor((rows.len() - right.len()) / 2)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(if r == none { line-block[] } else { line-block(left: r.at(0), inl(r.at(1))) })
    cells.push(line-block[)])
    let j = i - first
    cells.push(if j >= 0 and j < right.len() { line-block(left: caption-right-pad, inl(right.at(j))) } else { line-block[] })
  }
  block(above: 0pt, below: 0pt, grid(columns: (caption-left, caption-paren, 1fr), ..cells))
}

#let cover(meta) = {
  let court = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA",
    upper(meta.division))
  for (i, l) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { pitch-body } else { 0pt }, align(center, text(weight: "bold", l)))
  }
  caption(meta)
  line-block(above: pitch-body, align(center, text(weight: "bold", inl(meta.brief_title))))
  let items = ()
  for g in meta.counsel {
    items += g.names
    items += g.lines
    items.push("")
  }
  while items.len() > 0 and items.last() == "" { items = items.slice(0, -1) }
  lines-block(items, left: block-indent, above: 36pt)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

/// "Dated:" at the left margin, then the signature lines at the block indent, kept together.
#let signature-block(meta) = block(breakable: false, width: 100%, above: 24pt, below: 0pt, {
  line-block[Dated: #meta.date]
  lines-block(meta.signature, left: block-indent, above: pitch-body)
})

// ---------------------------------------------------------------------------
// The memorandum: cover (no number), then the body numbered from 1, then the signature block
// ---------------------------------------------------------------------------

#let memorandum(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set heading(numbering: heading-numbering)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("¶¶ 19-22"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Headings: single-spaced, 12 pt bold (levels 4 and 5 roman); level 1 centered, deeper levels with the number in
  // a box at the level's indent and the text hanging after it; kept with the text after them.
  show heading: it => context {
    let lv = it.level
    let above = if lv == 1 { h1-above } else { h-above }
    block(width: 100%, above: above, below: h-below, sticky: true, {
      set text(size: type-size, weight: if lv <= 3 { "bold" } else { "regular" }, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if lv == 1 { align(center, it.body) } else {
        let ind = (lv - 2) * heading-tab
        pad(left: ind, par(hanging-indent: heading-tab,
          [#box(width: heading-tab, counter(heading).display(it.numbering))#it.body]))
      }
    })
  }
  show quote.where(block: true): it => block(above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-indent, it.body)
  })
  // Footnotes: 12 pt (LR 7.1(a)(4)), single-spaced (LR 7.1(a)(3)): the mark, a space, the note (Word's footnote
  // layout), 7 pt between notes.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }
  cover(meta)
  pagebreak()
  set page(numbering: "1", number-align: center,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature-block(meta)
}
