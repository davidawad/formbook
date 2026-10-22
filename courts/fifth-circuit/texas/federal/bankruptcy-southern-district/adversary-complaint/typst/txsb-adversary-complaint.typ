// Adversary complaint, United States Bankruptcy Court, Southern District of Texas (txsb).
// Rules (see ../README.md): FRBP 7001 and 7010 (caption: FRCP 10(a), applied by FRBP 7010), FRCP 10(b)
// (numbered paragraphs), FRBP 7008(a) and BLR 7008-1 (core and consent statement, in the body), FRBP 9004(a)-(b)
// (legibility, caption), LR10.1 (caption), LR10.2 (8 1/2 x 11, double spaced, paginated).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no typeface is set by the S.D. Tex. rules; Times New Roman, the exemplar's face (docs/FONTS.md)
#let type-size = 12pt                   // no point size is set by the S.D. Tex. rules; 12 pt is the usual minimum
#let note-size = 10pt                   // the debtors note under the caption
#let page-w = 8.5in                     // LR10.2: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // not set by the rules; a 1 inch convention (see README.md)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number's box after it
#let item-indent = 0.5in                // lettered items: the letter half an inch in
#let item-label = 0.4in                 // ... in a box of this width, the text hanging after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case block
#let caption-inset = 12pt               // the party column's text stands off its right rule
#let caption-pad = 10pt                 // the party column's bottom rule stands off its last line
#let right-inset = 0.1in                // the case block stands off the gutter
#let designation-indent = 1.25in        // "Debtors.", "Plaintiff,", "Defendants."
#let versus-indent = 0.5in              // "v."
#let note-gap = 6pt                     // between the caption and the debtors note

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // LR10.2 double spacing: twice the 12 pt type size (the template's pitch)
#let pitch-single = 13.8pt              // caption, title, signature and footer lines: 1.15 x the type size
#let pitch-note = 11.5pt                // the debtors note: 1.15 x its size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (lead-in, body).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. Caption and signature
/// text is set as written (no markdown).
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

// ---------------------------------------------------------------------------
// Cover: court, division, caption, debtors note, title
// ---------------------------------------------------------------------------

/// Right column of the caption: chapter, case number, adversary number; "" is a blank line.
#let right-rows(meta) = {
  let rows = (meta.chapter, "", meta.case_number)
  if "joint_admin" in meta { rows.push(meta.joint_admin) }
  rows + ("", "", meta.adversary_number)
}

#let caption(meta) = {
  let c = meta.caption
  block(width: 100%, above: pitch-single, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
      line-block("In re:")
      // The debtor names, the note's mark on the last one.
      for (i, n) in c.debtor_names.enumerate() {
        let last = i == c.debtor_names.len() - 1
        line-block(if last and "debtor_footnote" in c { [#n#super[\*]] } else { n })
      }
      line-block(indent: designation-indent, c.debtor_designation)
      for (i, n) in c.plaintiff_names.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, n) }
      line-block(indent: designation-indent, c.plaintiff_designation)
      line-block(indent: versus-indent, "v.")
      for n in c.defendant_names { line-block(n) }
      line-block(indent: designation-indent, c.defendant_designation)
    }),
    pad(left: right-inset, for r in right-rows(meta) { line-block(if r == "" { [~] } else { r }) }),
  ))
  // The debtors note sits under the caption, in the flow (not a page-foot footnote), single spaced at its size.
  if "debtor_footnote" in c {
    block(width: 100%, above: note-gap, below: 0pt, {
      set text(size: note-size, ..edges(pitch-note))
      set par(first-line-indent: 0pt)
      [\* #c.debtor_footnote]
    })
  }
}

#let cover(meta) = {
  for l in ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS", upper(meta.division)) {
    line-block(align(center, text(weight: "bold", l)))
  }
  caption(meta)
  line-block(above: pitch-single, below: pitch-single, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (FRCP 10(b): the number in a
/// box of the paragraph indent after the first-line indent, the text after it). `keep`: kept whole on the page of
/// the block after it (the last paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Numbered paragraphs (FRCP 10(b)). Each blank-line-separated chunk that is neither a heading, a list nor a ">"
/// chunk is one numbered paragraph; headings and lists are not numbered. Numbering is applied per chunk, not with
/// a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let n = 0
  let chunks = body-chunks(body)
  for (i, c) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if c.starts-with("#") {
      md(c)
    } else if c.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A list: lettered (a), (b), ... by the template, the letter half an inch in, the text hanging after it.
      pad(left: item-indent, md(c))
    } else if c.starts-with(">") {
      // An unnumbered paragraph (a WHEREFORE or prayer clause the filing does not number): markdown "> text".
      body-par(none, inl(c.slice(1).trim()), keep: last)
    } else {
      n += 1
      body-par(n, inl(c), keep: last)
    }
  }
}

/// "Dated:" at the left; "Respectfully submitted," and the first signing block at the right, a blank single line
/// below the last paragraph; each further block at the signature column, a single line apart around "-and-". Each
/// part is kept whole on one page (a page may fall between two signing blocks, as in a filed motion).
#let signature(meta) = {
  let blocks = meta.signature.blocks
  let lines(b) = for (i, l) in b.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, l) }
  block(breakable: false, width: 100%, above: pitch-single, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    line-block([Dated: #meta.dated]),
    { line-block[Respectfully submitted,]; lines(blocks.first()) },
  ))
  for b in blocks.slice(1) {
    block(breakable: false, width: 100%, above: pitch-single, below: 0pt, pad(left: caption-left + caption-gutter, {
      line-block("-and-")
      lines(b)
    }))
  }
}

#let txsb-adversary-complaint(meta, body) = {
  // Page numbers centered, arabic, on every page (LR10.2 "paginated"); the number in a single-spaced line box, so
  // it sits at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced); lists as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  set enum(numbering: "(a)")

  // Headings at the body size and pitch, as written: level 1 and 2 centered bold (count headings); level 3 bold at
  // the margin (A., B., ...). No space of their own (the double pitch sets them off); sticky, so a heading never
  // ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level <= 2 { align(center, text(weight: "bold", it.body)) } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  cover(meta)

  // Unnumbered lead-in paragraph, if the filing has one.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  allegations(body)
  signature(meta)
}
