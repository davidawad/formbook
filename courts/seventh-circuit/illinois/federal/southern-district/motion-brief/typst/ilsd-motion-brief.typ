// U.S. District Court, Southern District of Illinois: motion to dismiss with a brief in support
// (Fed. R. Civ. P. 12(b)(6); SDIL-LR 7.1).
//
// Rule-driven and content-agnostic. Requirement IDs (ILSD-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")       // Times New Roman substitute per docs/FONTS.md, vendored in /fonts; no system font can be used (tools/render.sh)
#let type-size = 12pt                  // ILSD-FORM-002: "12-point font" (SDIL-LR 7.1(a)(3)); footnotes too
#let margins = (top: 1in, bottom: 1in, x: 1in)   // 1-inch margins (convention; the exemplar's are the same; see README)
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let heading-tab = 0.5in               // label of a level 2 or 3 heading in a box this wide; the text hangs after it
#let caption-left = 3.5in              // the party column of the caption
#let caption-marks = 0.4in             // the column of ")" marks
#let caption-right = 0.25in            // the civil action number stands this far right of the marks
#let designation-indent = 1.4in        // "Plaintiff," / "Defendant." under the party names
#let title-inset = 10%                 // the title is centered in the middle 80 % of the line
#let quote-indent = 0.5in              // block quotations, both sides
#let sig-indent = 2.75in               // signature block starts here; 2.75 in keeps "LAW OFFICES OF IWANA RADEMAEKERS, P.C." on one line in Times New Roman
#let recipient-indent = 1in            // the certificate's recipients

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips). The INPUT's
// `word:` map (justify, shrink; lib/typst/word-compat.typ) is not read: the model sets the text ragged right.
#let pitch-body = 24pt                 // double spacing at 12 pt (SDIL-LR 7.1(a)(3))
#let pitch-single = 13.8pt             // single spacing (court name, caption, title, headings, quotations, signature, certificate lines, footnotes): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                // a blank single line: in the caption and signature block
#let h1-above = 18pt                   // a level 1 heading (label line and text line): space above and below
#let h1-below = 12pt
#let h2-gap = 12pt                     // a level 2 or 3 heading: space above and below
#let title-below = 12pt                // the title to the body
#let quote-gap = 14pt                  // around a block quotation
#let cert-gap = 12pt                   // the certificate's title to its text, the recipients to the date line
#let recipient-gap = 6pt               // around each recipient
#let note-gap = 7pt                    // between footnotes
#let note-clearance = 7pt            // between the text and the footnote rule: with the 7 pt gap, the room LibreOffice keeps above a note (12.6 pt moved five page ends)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ilsd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Render an inline markdown string (italics, links) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

// ---------------------------------------------------------------------------
// Headings: numbering and styles (SDIL-LR 7.1(a)(2): a brief states its position with citations)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 1 "I.", 2 "A.", 3 "1.", 4 "a.".
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a): court name, title, file number)
// ---------------------------------------------------------------------------

/// The caption: one row per party line (names, a blank line, the designation, a blank line, "v.", a blank line, ...),
/// a column of ")" marks (one per line of text: a name can wrap), the civil action number on the "v." row.
#let caption(parties, case-number) = {
  let left = ()
  for (i, p) in parties.enumerate() {
    for n in p.names { left.push((inl(n), 0pt, false)) }
    left.push((none, 0pt, false))
    left.push((inl(p.designation), designation-indent, false))
    if i < parties.len() - 1 {
      left.push((none, 0pt, false))
      left.push((align(center, [v.]), 0pt, true))
      left.push((none, 0pt, false))
    }
  }
  let v = left.position(l => l.at(2))
  let cells = ()
  for (k, (c, ind, _)) in left.enumerate() {
    let text-cell = if c == none { [] } else { line-block(left: ind, c) }
    let marks = context {
      let n = if c == none { 1 } else { calc.max(1, calc.round(measure(width: caption-left, text-cell).height / pitch-single)) }
      for _ in range(n) { line-block(align(center)[)]) }
    }
    let right = if k == v { line-block(left: caption-right)[Civil Action No. #case-number] } else { [] }
    cells += (text-cell, marks, right)
  }
  grid(columns: (caption-left, caption-marks, 1fr), ..cells)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

/// The date line at the margin, then at 3.0 in: "Respectfully submitted,", the e-signature with the signer's lines,
/// the role; a blank single line between the groups. Kept on one page.
#let signature(meta) = {
  let sig = need(meta, "signature")
  let s(above: 0pt, body) = line-block(above: above, left: sig-indent, body)
  block(width: 100%, breakable: false, above: gap, below: 0pt, {
    line-block(inl(need(meta, "date_line")))
    s(above: gap)[Respectfully submitted,]
    s(above: gap)[By: /s/ #inl(sig.signer)]
    for l in sig.lines { s(inl(l)) }
    if "role" in sig { s(above: gap, strong(inl(sig.role))) }
  })
}

/// Fed. R. Civ. P. 5(b)(2)(E): service through the court's electronic-filing system. On its own page.
#let certificate(meta) = {
  let svc = need(meta, "service")
  pagebreak(weak: true)
  line-block(below: cert-gap, align(center, strong[CERTIFICATE OF SERVICE]))
  block(width: 100%, above: 0pt, below: recipient-gap, par(first-line-indent: (amount: para-indent, all: true), [
    I certify that a true and correct copy of the foregoing pleading was electronically filed with the clerk for the U.S. District Court, Southern District of Illinois, using the electronic case filing system of the court, and the electronic case filing system sent a "Notice of Electronic Filing" to the following attorneys of record who have consented in writing to accept this Notice as service of this document by electronic means, as follows:
  ]))
  for r in svc.recipients {
    line-block(above: recipient-gap, left: recipient-indent, inl(r.name))
    line-block(below: recipient-gap, left: recipient-indent)[Email: #inl(r.email)]
  }
  line-block(above: cert-gap, sticky: false, grid(
    columns: (1fr, 1fr),
    inl(svc.date),
    align(right)[/s/ #inl(svc.signer)],
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let ilsd-motion-brief(meta, body) = {
  set document(title: need(meta, "title") + " (Civil Action No. " + need(meta, "case_number") + ")")
  // ILSD-LR-5.1(a): letter paper, every page numbered; the number centered in the bottom margin, in a single-spaced
  // line box (Word's footer).
  set page(paper: "us-letter", margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 1, 3"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  set heading(numbering: (..n) => heading-num(..n))
  show heading: set text(size: type-size)

  // Footnotes: 12 pt, single-spaced (the entry sets its own leading: it does not inherit the body's); the mark, a
  // space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // LibreOffice splits a note anywhere (it keeps no widow or orphan line in a footnote): so does typst here.
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Level 1 (I., II., III.): centered, bold; the label on a line of its own above the heading text.
  show heading.where(level: 1): it => {
    let nums = counter(heading).at(it.location())
    line-block(above: h1-above, sticky: true, align(center, strong(heading-num(..nums.slice(0, 1)))))
    line-block(below: h1-below, sticky: true, align(center, strong(it.body)))
  }
  // Level 2 (A., B.) at the margin, level 3 (1., 2.) half an inch in: bold, the label in a box, the text hanging after it.
  show heading: it => if it.level == 1 { it } else {
    let nums = counter(heading).at(it.location())
    line-block(above: h2-gap, below: h2-gap, sticky: true, left: if it.level >= 3 { heading-tab } else { 0pt },
      par(hanging-indent: heading-tab, [#box(width: heading-tab, strong(heading-num(..nums.slice(0, calc.min(it.level, 4)))))#strong(it.body)]))
  }
  // Block quotations: single-spaced, half an inch in on both sides.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-indent, it.body)
  })

  // Court name (Fed. R. Civ. P. 10(a))
  line-block(align(center)[IN THE UNITED STATES DISTRICT COURT])
  line-block(below: pitch-body, align(center)[FOR THE SOUTHERN DISTRICT OF ILLINOIS])

  caption(need(meta, "caption"), need(meta, "case_number"))

  line-block(above: pitch-body, below: title-below, sticky: true,
    pad(x: title-inset, align(center, strong(inl(need(meta, "title"))))))

  // The body: headings, paragraphs and footnotes, rendered as one document; its last paragraph is kept on one page
  // with the signature block, so the signature never stands alone on a page. Every footnote definition goes with
  // both parts (a reference and its definition must be in the same render).
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^"))
  let text-chunks = chunks.filter(c => not c.starts-with("[^"))
  let tail = if text-chunks.len() > 0 and not text-chunks.last().starts-with("#") { text-chunks.last() } else { none }
  let head = if tail == none { text-chunks } else { text-chunks.slice(0, -1) }
  inl((head + defs).join("\n\n"))
  if tail == none {
    signature(meta)
  } else {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      inl(((tail,) + defs).join("\n\n"))
      signature(meta)
    })
  }
  certificate(meta)
}
