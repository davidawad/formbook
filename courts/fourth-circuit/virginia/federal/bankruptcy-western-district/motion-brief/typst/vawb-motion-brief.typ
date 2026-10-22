// Motion with memorandum in support, United States Bankruptcy Court, W.D. Virginia (vawb).
// Rules: FRBP 9013 (a motion must state its grounds with particularity and set out the relief requested),
// 9014(a) (relief in a contested matter is requested by motion), 7012 and 7056 where the motion is in an
// adversary proceeding. W.D. Va. Local Rules (effective 3/14/2025): LR 9013-1(A)-(C) (written motion, grounds
// and relief stated, counsel's name, address, telephone and e-mail lower left of the signature page),
// LR 9013-1(E) (proof of service at the end of each motion, signed by counsel, with date, manner and names
// and addresses), LR 9013-1(I) (caption: court, debtor, case number, motion number, and the Movant,
// Respondent or Trustee designation), LR 5005-3(C) and LR 7001-1(C)(3) (letter size, top margin of not less
// than 1 1/2 in). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman (vendored metric twin Liberation Serif, docs/FONTS.md); the W.D. Va. rules name no typeface or size
#let type-size = 12pt              // convention: 12 pt body, the size the filed motion uses
#let note-size = 10pt              // footnotes
#let footer-size = 10pt            // the page number
#let top-margin = 1.5in            // LR 5005-3(C), LR 7001-1(C)(3): top margin of not less than 1 1/2 inches
#let side-margin = 1in             // convention: one inch left and right
#let bottom-margin = 1in
#let text-width = 8.5in - 2 * side-margin
#let number-indent = 0.5in         // a paragraph number starts half an inch in ...
#let number-box = 0.5in            // ... in a box of its own; the text starts 1 in from the margin and wraps there (docx: Numbered Paragraph)
#let label-box = 0.5in             // a numbered heading's label (I., A., 1., a.) at the margin; the text hangs after it
#let caption-left = 4in            // width of the party column of the caption
#let caption-gutter = 0.25in       // between the party column and the case numbers
#let caption-pad = 10pt            // the party column's rules stand off its text by this much on the right ...
#let caption-pad-bottom = 8pt      // ... and below
#let case-pad = 0.1in              // the case numbers stand off the gutter
#let sig-right = 2.9in             // the signature column (lower right) ...
#let sig-gutter = 0.2in            // ... and the space between it and counsel's column (lower left, LR 9013-1(C))
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF VIRGINIA")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vawb-motion-brief.lua and docx/reference.xml set
// the same twips).
#let pitch-body = 24pt             // double spacing, as in the filed motion: body, court name, title, headings
#let pitch-single = 13.8pt         // caption, signature and service blocks, block quotations
#let pitch-note = 11.5pt           // footnotes
#let pitch-footer = 11.5pt         // the page number's line
#let court-below = 24pt            // the court name to the caption
#let caption-gap = 12pt            // between two debtors' rows of the caption
#let caption-below = 24pt          // the caption to the title
#let title-below = 24pt            // the title to the text
#let signature-above = 24pt        // the last paragraph to the signature block
#let block-gap = 6pt               // the date to the signature columns
#let certificate-above = 24pt      // the signature block to the certificate of service
#let service-gap = 12pt            // the certificate: heading, statement, addresses and signer apart
#let note-gap = 6pt                // between two footnotes (docx: Footnote Text 120 twips after)
#let note-clearance = 8pt          // the text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks a loose list item puts around it (they may not occur inside a
/// paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One line (a paragraph of its own) with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, body)

/// Single-spaced lines, one paragraph each; an empty item is a blank line (the next line sits a line lower).
/// `above`: a space of its own above the first line (padding, which typst keeps at the top of a grid cell, as Word
/// keeps a paragraph's space before at the top of a table cell).
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
  for t in items {
    if t == "" { gap += pitch-single } else {
      line-block(pad(top: gap, inl(t)))
      gap = 0pt
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (LR 9013-1(I)): court name; each debtor's names beside that debtor's chapter and case number; the parties in
// a column ruled right and below, the motion or adversary number beside them; the title.
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  let lines = court-name
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
  let cols = (caption-left, caption-gutter, text-width - caption-left - caption-gutter)
  for (k, d) in meta.caption.in_re.enumerate() {
    block(width: 100%, above: if k == 0 { court-below } else { caption-gap }, below: 0pt, grid(columns: cols,
      line-stack(((if k == 0 { "In re:" } else { "" }),) + d.names + (d.designation,)),
      [],
      pad(left: case-pad, line-stack(("Chapter " + d.chapter, "Case No. " + d.case_number))),
    ))
  }
  // A blank number stays a blank for the filer to fill in.
  let value = meta.caption.number.value
  let party-rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { party-rows.push("v.") }
    party-rows += p.names
    party-rows.push(p.designation)
  }
  block(width: 100%, above: caption-gap, below: caption-below, grid(columns: cols,
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-pad-bottom),
      line-stack(party-rows)),
    [],
    pad(left: case-pad, line-stack((meta.caption.number.label, if value == "" { "________" } else { value }))),
  ))
  line-block(align(center, text(weight: "bold", upper(inl(meta.title)))))
  v(title-below)
}

// ---------------------------------------------------------------------------
// Signature block (counsel lower left, LR 9013-1(C)) and certificate of service (LR 9013-1(E)). The space above each
// is spacing of its own (docx: an empty paragraph of that height), so it stays behind when the block moves on.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(signature-above)
  let dated = "date" in meta.signature and meta.signature.date != none
  let right-above = if dated { pitch-single + block-gap } else { 0pt }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (text-width - sig-right - sig-gutter, sig-gutter, sig-right),
    {
      if dated { line-stack(("Dated: " + meta.signature.date,)) }
      line-stack(meta.counsel.names + meta.counsel.lines, above: if dated { block-gap } else { 0pt })
    },
    [],
    line-stack(("Respectfully submitted,", "", upper(meta.signature.party), "", "BY: /s/ " + meta.signature.signer)
      + meta.signature.lines, above: right-above),
  ))
}

#let certificate-of-service(meta) = if "service" in meta and meta.service != none {
  v(certificate-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    set par(first-line-indent: 0pt)
    line-block(align(center, text(weight: "bold", [CERTIFICATE OF SERVICE])))
    line-block(above: service-gap, inl(meta.service.statement))
    for g in meta.service.parties { line-stack(g.names + g.lines, above: service-gap) }
    line-stack(("/s/ " + meta.service.signer,) + meta.service.lines, above: service-gap)
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let vawb-motion-brief(meta, body) = {
  // Every page numbered, bottom centre; the number in a line box of its own (Word's footer).
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-footer), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. Lists are the numbered paragraphs,
  // below (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Footnotes: 10 pt, single-spaced, a short rule above them (docx: Footnote Text).
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings, all on the body pitch with no space of their own, kept with the text after them (docx: Heading 1 to 5
  // in docx/reference.xml). Level 1: a centred section in capitals (Argument, Conclusion). Levels 2 to 5 numbered
  // I. / A. / 1. / a. (the sample writes no numbers), the label in a half-inch box at the margin, the text hanging
  // after it; 2 and 3 bold, 4 italic, 5 plain.
  let counters = (2, 3, 4, 5).map(l => counter("vawb-h" + str(l)))
  let formats = ("I.", "A.", "1.", "a.")
  show heading: it => {
    let lvl = calc.min(it.level, 5)
    if lvl >= 2 {
      counters.at(lvl - 2).step()
      for c in counters.slice(lvl - 1) { c.update(0) }
    }
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
      set par(first-line-indent: 0pt)
      set text(size: type-size, weight: if lvl <= 3 { "bold" } else { "regular" },
        style: if lvl == 4 { "italic" } else { "normal" })
      if lvl == 1 { align(center, upper(it.body)) } else {
        par(hanging-indent: label-box,
          [#box(width: label-box, context counters.at(lvl - 2).display(formats.at(lvl - 2)))#it.body])
      }
    })
  }

  // Numbered paragraphs: the number half an inch in, the text 1 in from the margin and wrapped there; the sample's
  // own numbers.
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(width: 100%, above: 0pt, below: 0pt, pad(left: number-indent,
        par(first-line-indent: 0pt, hanging-indent: number-box, [#box(width: number-box)[#n.]#unloose(item.body)])))
      n += 1
    }
  }
  // Block quotations: single-spaced, half an inch in on both sides, 12 pt above and below (docx: Block Text).
  show quote.where(block: true): it => block(width: 100%, above: 12pt, below: 12pt, inset: (x: 0.5in), {
    set text(..edges(pitch-single))
    it.body
  })

  cover(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate-of-service(meta)
}
