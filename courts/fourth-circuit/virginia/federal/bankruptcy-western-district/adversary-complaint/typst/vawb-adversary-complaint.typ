// Complaint commencing an adversary proceeding, United States Bankruptcy Court, W.D. Virginia (vawb).
// Rules: FRBP 7001 (adversary proceedings), 7008(a) (jurisdiction allegation names the case, number, chapter,
// district and division; the pleader states whether it consents to final orders by the bankruptcy court),
// 7010 (caption substantially conforms to Official Form 416; Fed. R. Civ. P. 10(b) numbered paragraphs).
// W.D. Va. Local Rules (effective 3/14/2025): LR 5005-3(C) and LR 7001-1(C)(3) (letter size, top margin
// of not less than 1 1/2 in), LR 7001-1(C)(4) (name, address, telephone and e-mail lower left of the
// signature page), LR 7001-1(D) (filing fee and Form B-104 cover sheet, not generated here). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman (vendored metric twin Liberation Serif, docs/FONTS.md); the W.D. Va. rules name no typeface or size
#let type-size = 12pt              // convention: 12 pt body, the size the filed complaint uses
#let footer-size = 10pt            // the page number
#let top-margin = 1.5in            // LR 5005-3(C), LR 7001-1(C)(3): top margin of not less than 1 1/2 inches
#let side-margin = 1in             // convention: one inch left and right
#let bottom-margin = 1in
#let text-width = 8.5in - 2 * side-margin
#let number-indent = 0.5in         // a paragraph number starts half an inch in ...
#let number-box = 0.5in            // ... in a box of its own; the text starts 1 in from the margin and wraps there (docx: Numbered Paragraph)
#let caption-left = 4in            // width of the party column of the caption; wide enough that "(n/k/a" does not break
#let caption-gutter = 0.25in       // between the party column and the case numbers
#let caption-pad = 10pt            // the party column's rules stand off its text by this much on the right ...
#let caption-pad-bottom = 8pt      // ... and below
#let case-pad = 0.1in              // the case numbers stand off the gutter
#let sig-right = 2.9in             // the signature column (lower right) ...
#let sig-gutter = 0.2in            // ... and the space between it and counsel's column (lower left, LR 7001-1(C)(4))
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF VIRGINIA")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vawb-adversary-complaint.lua and
// docx/reference.xml set the same twips).
#let pitch-body = 24pt             // double spacing, as in the filed complaint: body, court name, title, headings
#let pitch-single = 13.8pt         // caption, signature, counsel and service blocks
#let pitch-footer = 11.5pt         // the page number's line
#let court-below = 24pt            // the court name to the caption
#let caption-below = 24pt          // the caption to the title
#let signature-above = 24pt        // the last paragraph to the signature block
#let block-gap = 6pt               // the date to the signature columns; between two service addresses
#let service-above = 24pt          // the signature block to the service addresses

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
// Cover: court name, caption ("In re" block and parties left, chapter, case number and adversary number right;
// Form 416), title, salutation
// ---------------------------------------------------------------------------

#let caption-left-rows(meta) = {
  let rows = ()
  for (k, d) in meta.caption.in_re.enumerate() {
    rows.push(if k == 0 { "In re:" } else { "" })
    rows += d.names
    rows.push(d.designation)
    rows.push("")
  }
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names
    rows.push(p.designation)
  }
  rows
}

#let caption-right-rows(meta) = {
  let rows = ()
  for d in meta.caption.in_re {
    rows.push("Chapter " + d.chapter)
    rows.push("Case No. " + d.case_number)
    rows.push("")
  }
  // A blank number stays a blank to be filled in by the filer.
  let value = meta.caption.number.value
  rows.push(meta.caption.number.label + " " + (if value == "" { "________" } else { value }))
  rows
}

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  let lines = court-name
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
  block(width: 100%, above: court-below, below: caption-below, grid(
    columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-pad-bottom),
      line-stack(caption-left-rows(meta))),
    [],
    pad(left: case-pad, line-stack(caption-right-rows(meta))),
  ))
  if "title" in meta and meta.title != none {
    line-block(align(center, text(weight: "bold", upper(inl(meta.title)))))
  }
  if "salutation" in meta and meta.salutation != none {
    line-block(inl(meta.salutation))
  }
}

// ---------------------------------------------------------------------------
// Signature page: counsel lower left (LR 7001-1(C)(4)), party and signer lower right. The space above the block is
// spacing of its own (docx: an empty paragraph of that height), so it stays behind when the block moves on.
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

/// Service addresses under the signature, when the sample gives them; kept on one page.
#let service-block(meta) = if "service" in meta and meta.service != none {
  v(service-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    line-stack(("Service:",))
    for g in meta.service { line-stack(g.names + g.lines, above: block-gap) }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let vawb-adversary-complaint(meta, body) = {
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
  // body pitch, a section sign kept with its number. Lists are the numbered allegations, below (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Headings: level 1 a centred section, level 2 and 3 bold sub-headings, all on the body pitch with no space of
  // their own, kept with the text after them (docx: Heading 1 to 3 in docx/reference.xml).
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    set text(size: type-size, weight: "bold")
    if it.level == 1 { align(center, upper(it.body)) } else if it.level == 2 { it.body } else { emph(it.body) }
  })

  // Numbered allegations (Fed. R. Civ. P. 10(b)): the number half an inch in, the text 1 in from the margin and
  // wrapped there; the sample's own numbers.
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
  service-block(meta)
}
