// Complaint for the U.S. District Court for the Northern District of Texas (txnd).
// Rules: Fed. R. Civ. P. 8(a), 10(a) (caption, title, file number), 10(b) (numbered paragraphs, one set of
// circumstances each); N.D. Tex. LR 10.1 (required form: typed, 8 1/2 by 11, numbered pages, title, signature block
// with bar number, telephone, fax and email). See ../README.md for the rule text, the date verified and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the rules name no typeface for a complaint; Times New Roman (vendored), the exemplars' face
#let type-size = 12pt                   // N.D. Tex. LR 7.2 sets 12-point or larger for briefs; applied to the complaint too
#let margin-all = 1in                   // LR 7.2 margins (at least one inch); applied to the complaint too
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number in a box of this width after it
#let item-indent = 0.5in                // prayer items: the number half an inch in, the text a box of this width after it
#let heading-hang = 0.5in               // a level-2 heading's label ("I.") in a box of this width, the text hanging after it
#let caption-left = 3.6in               // width of the party column of the caption
#let caption-sign = 0.4in               // the column of section marks (§) that separates the parties from the case data
#let sig-left = 3.0in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing (LR 7.2): the body's baseline-to-baseline distance at 12 pt
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size; court title, caption, headings, signature
#let cover-gap = 18pt                   // between the court title, the caption and the title of the paper
#let title-after = 10pt                 // between the title of the paper and the first paragraph
#let heading-above = 16pt               // a heading stands off the text above it (consecutive headings: the larger applies)
#let heading-below = 2pt                // and sits on the double-spaced grid of the text below it
#let sig-gap = 6pt                      // between the groups of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, quotations, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: each party name and designation is one row, with a section mark beside it; the case number and
/// the jury legend sit in the right-hand column, on the middle rows. A name that wraps makes its row taller.
#let caption(meta) = {
  let lines = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { lines.push("v.") }
    lines += p.names + (p.designation,)
  }
  let mid = calc.floor(lines.len() / 2)
  let cells = ()
  for (i, l) in lines.enumerate() {
    cells.push(line-block(inl(l)))
    cells.push(line-block(align(center, "§")))
    if i == mid - 1 {
      cells.push(line-block[CIVIL ACTION NO. #meta.case_number])
    } else if i == mid and "jury_demand" in meta and meta.jury_demand {
      cells.push(line-block(text(weight: "bold", "JURY TRIAL DEMANDED")))
    } else {
      cells.push(line-block[])
    }
  }
  block(width: 100%, above: cover-gap, below: cover-gap,
    grid(columns: (caption-left, caption-sign, 1fr), ..cells))
}

#let cover(meta) = {
  let court-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS")
  if "court_division" in meta and meta.court_division != none {
    court-lines.push(upper(meta.court_division))
  }
  for l in court-lines { line-block(align(center, text(weight: "bold", l))) }
  caption(meta)
  line-block(below: title-after, align(center, text(weight: "bold", upper(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings, single spaced, bold, kept with the text after them: level 1 centered capitals; level 2 at the margin,
/// its label ("I.", "A.") in a box with the text hanging after it; level 3 centered.
#let heading-block(level, t) = block(width: 100%, sticky: true, breakable: false, above: heading-above,
  below: heading-below, {
  set text(..edges(pitch-single), weight: "bold")
  set par(first-line-indent: 0pt)
  if level == 1 {
    align(center, upper(inl(t)))
  } else if level == 2 {
    let m = t.match(regex("^([IVXLC]+|[A-Z]|\\d+)\\.\\s+"))
    if m == none { inl(t) } else {
      par(hanging-indent: heading-hang, [#box(width: heading-hang, m.captures.at(0) + ".")#inl(t.slice(m.end))])
    }
  } else {
    align(center, inl(t))
  }
})

/// The signature block: the date at the left; "Respectfully submitted," the firm, the signature (/s/, the name,
/// the bar number), the address and the role at the right, single spaced, the groups a little apart. It never
/// breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let sig = meta.signature
  let group(items) = for (i, l) in items.enumerate() { line-block(above: if i == 0 { sig-gap } else { 0pt }, inl(l)) }
  grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block[Dated: #meta.date],
    {
      line-block[Respectfully submitted,]
      group(sig.firm)
      group(("/s/ " + sig.signer, sig.signer, sig.bar))
      group(sig.address)
      group(sig.lines)
    },
  )
})

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (Fed. R. Civ. P. 10(b): the
/// number in a box of the paragraph indent after the first-line indent, the text after it). `keep`: kept on the
/// page of the block after it (the last paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading, a list nor the
/// WHEREFORE lead-in of the prayer is one numbered paragraph (Fed. R. Civ. P. 10(b)).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let num = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    let h = t.match(regex("^(#{1,6})[ \\t]+(.*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items: numbered 1., 2., ... by the template, the number half an inch in, double spaced.
      pad(left: item-indent, md(t))
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is an unnumbered paragraph, as in the exemplar.
      body-par(none, md(t), keep: last)
    } else {
      num += 1
      body-par(num, md(t), keep: last)
    }
  }
}

#let txnd-complaint(meta, body) = {
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced); lists as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  // A doubled section sign stays with its number too ("§§ 45.50.471"; xengine binds a single sign; the docx filter
  // binds both).
  show regex("[§¶]+ \\S+"): it => box(it)
  // Body: prayer items are numbered 1., 2., ... (the markdown numbers are not printed).
  set enum(numbering: "1.")

  cover(meta)
  allegations(body)
  signature-block(meta)
}
