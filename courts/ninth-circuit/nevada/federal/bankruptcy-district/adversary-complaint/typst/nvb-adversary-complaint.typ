// Adversary complaint for the United States Bankruptcy Court, District of Nevada (nvb).
// Rules (../../rules.md, ../README.md): LR 9004(a)-(c) and (g) (form: 8 1/2 by 11, double-spaced, every line
// numbered in the left margin, a proportional font of 12 point or larger, consecutive page numbers, title page
// begins 1 1/2 inches from the top, attorney identification at the upper left, "/s/" signatures); LR 7010(b)
// (caption includes the adversary proceeding); FRBP 7008 and LR 7008 (consent statement); FRBP 7010 (form per
// Fed. R. Civ. P. 10: numbered paragraphs, separate claims). Content-agnostic: every case word comes from the
// sample's frontmatter and body.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its
// pitch with the baseline at 0.8 of it, boxes touching, first fit, no kerning, ligatures or hyphenation. The docx
// engine (docx/nvb-adversary-complaint.lua, docx/reference.xml) sets the same pitches, indents and spaces in twips.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named layout choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // LR 9004(b): a proportional font; no face named, Times New Roman the house standard
#let type-size = 12pt                     // LR 9004(b): at least 12 point (the exemplar's size)
#let pitch = 24pt                         // LR 9004(a): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                  // single-spaced lines (LR 9004(a) exempts the counsel block, caption, quotations): half a numbered line, so they keep to the grid
#let lines-per-page = 27                  // LR 9004(a): each line numbered in the left margin; 27 lines inside 1 in margins
#let top-margin = 72pt                    // line 1 sits on the top margin
#let bottom-margin = 72pt                 // 11 in - 1 in - 27 x 24 pt: the page number sits in it
#let left-margin = 1.5in                  // the line numbers and the rule stand in it
#let right-margin = 1in
#let number-col = 1in                     // the line numbers end 1 in from the left edge
#let number-drop = 1.2pt                 // a number sits this far below its double-spaced line's baseline, as far above the single line at the
                                          // foot of its slot: every line beside a number is one text line with it in every engine's PDF
#let rule-in = 0.2in                      // the pleading rule stands this far left of the text
#let title-page-lines = 2                 // LR 9004(a): the title page begins 1 1/2 in down; the counsel block starts on line 3 (1.67 in)
#let counsel-gutter = 0.25in              // between counsel columns
#let caption-left = 3.2in                 // the party column of the caption
#let box-pad = 8pt                        // the party column's text stands at least this far above its foot rule
#let rule-pad = 8pt                       // and this far left of its right rule
#let caption-gutter = 0.2in               // the right column's text starts this far right of the rule
#let caption-gap = 12pt                   // between the parts of the caption's right column
#let para-indent = 0.5in                  // the paragraph number stands half an inch in
#let number-box = 0.5in                   // the text after the number starts 1 in from the margin (as filed)
#let list-left = 1in                      // a list's label stands 1 in from the margin (as filed)
#let label-box = 0.25in                   // and its text hangs a quarter inch further in
#let quote-inset = 0.5in                  // block quotations indented on both sides
#let quote-gap = 12pt                     // around and between the paragraphs of a quotation
#let sig-col = 2.6in                      // the "Dated" column of the signature block
#let sig-gutter = 0.2in
#let signer-gap = 12pt                    // between two signers' blocks

#let text-width = 8.5in - left-margin - right-margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required frontmatter field: a missing one stops the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("nvb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Whole numbered lines: a height rounded up to a multiple of the pitch, so what follows stays on the grid.
#let snap(h) = calc.ceil(h / pitch - 0.001) * pitch

/// A blank numbered line.
#let blank-line() = block(width: 100%, height: pitch, above: 0pt, below: 0pt)

/// One single-spaced line block; an empty string is a blank single line.
#let single(s, above: 0pt, indent: 0pt, weight: "regular") = block(width: 100%, above: above,
  below: 0pt, {
    set text(..edges(pitch-single), weight: weight)
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: indent, if s == "" { box(height: pitch-single) } else { inl(s) })
  })

/// Single lines, one per item: a string, or (text:, bold:, above:).
#let stack(items) = for it in items {
  if type(it) == str { single(it) } else {
    single(it.text, above: it.at("above", default: 0pt), weight: if it.at("bold", default: false) { "bold" } else { "regular" })
  }
}

/// A row of columns whose height is rounded up to whole numbered lines (the docx engine sets the same row height:
/// docx/nvb-adversary-complaint.lua). `cells`: (width, content, stroke, inset); `breakable`: the row may split.
#let grid-row(cells, breakable: false) = context {
  let h = calc.max(..cells.map(c => measure(block(width: c.at(0), inset: c.at(3), c.at(1))).height))
  block(width: 100%, above: 0pt, below: 0pt, breakable: breakable, grid(
    columns: cells.map(c => c.at(0)),
    ..cells.map(c => block(width: c.at(0), height: snap(h), stroke: c.at(2), inset: c.at(3), c.at(1))),
  ))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, each on its numbered line (LR 9004(a)).
#let line-numbers() = for i in range(1, lines-per-page + 1) {
  place(top + left, dy: top-margin + (i - 1) * pitch + number-drop, block(width: number-col, height: pitch, {
    set text(..edges(pitch))
    align(right, str(i))
  }))
}

/// The pleading rule at the left of the text.
#let pleading-rule() = place(top + left, dx: left-margin - rule-in, line(start: (0pt, 0pt), end: (0pt, 11in), stroke: 0.75pt))

// ---------------------------------------------------------------------------
// Cover: attorney identification, court title, caption
// ---------------------------------------------------------------------------

/// The attorney identification: one column per counsel group (LR 9004(g)), single-spaced, on the grid.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  let n = groups.len()
  let w = (text-width - (n - 1) * counsel-gutter) / n
  grid-row(groups.enumerate().map(((k, g)) => {
    let left = if k == 0 { 0pt } else { counsel-gutter }
    (w + left, stack(need(g, "lines")), none, (left: left))
  }))
}

/// Court title (LR 9004(g)): the same on every caption of this court, one numbered line each.
#let court-title() = for t in ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEVADA") {
  block(width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", t)))
}

/// The caption (LR 7010(b)): the debtor and the adversary parties on the left, ruled at the right and foot; the
/// case number, chapter, adversary number and title of the paper on the right.
#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let left-rows = ()
  if "heading" in debtor { left-rows.push(debtor.heading) }
  left-rows += debtor.names
  left-rows.push(debtor.designation)
  if "caption_parties" in meta {
    left-rows.push("")
    for (k, p) in meta.caption_parties.enumerate() {
      if k > 0 { left-rows.push("v.") }
      left-rows += p.names + (p.designation,)
    }
  }
  let right = ("Case No.: " + need(meta, "case_number"),)
  if "chapter" in meta { right.push(meta.chapter) }
  right.push((text: "Adversary No.: " + meta.at("adversary_number", default: ""), above: caption-gap))
  right.push((text: need(meta, "title"), bold: true, above: caption-gap))
  if "subtitle" in meta { right.push((text: meta.subtitle, bold: true)) }
  if meta.at("jury_demand", default: false) == true {
    right.push((text: "DEMAND FOR JURY TRIAL", bold: true, above: caption-gap))
  }
  grid-row((
    (caption-left, stack(left-rows), (right: 0.75pt, bottom: 0.75pt), (right: rule-pad, bottom: box-pad)),
    (text-width - caption-left, stack(right), none, (left: caption-gutter)),
  ))
}

#let cover(meta) = {
  for _ in range(title-page-lines) { blank-line() }
  counsel-block(meta)
  blank-line()
  court-title()
  blank-line()
  caption(meta)
  blank-line()
}

// ---------------------------------------------------------------------------
// Body: double-spaced on the numbered lines, no space between paragraphs
// ---------------------------------------------------------------------------

/// A heading on the numbered lines, kept with what follows. Level 1 centered bold capitals underlined (as filed),
/// level 2 centered bold, level 3 bold at the margin.
#let heading-item(level, t) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  if level == 1 { align(center, underline(text(weight: "bold", upper(inl(t))))) } else if level == 2 {
    align(center, text(weight: "bold", inl(t)))
  } else { text(weight: "bold", inl(t)) }
})

/// A block quotation: single-spaced, indented on both sides (LR 9004(a) exempts quotations); the space after it
/// brings the text after it back onto the numbered lines.
#let quote-item(t) = {
  let ps = t.split("\n").map(l => l.trim().trim(">").trim()).join("\n").split(regex("\\n[ \\t]*\\n"))
    .filter(l => l.trim() != "")
  let body = for (k, q) in ps.enumerate() {
    block(width: 100%, above: if k == 0 { 0pt } else { quote-gap }, below: 0pt, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, hanging-indent: 0pt)
      pad(x: quote-inset, inl(q.trim()))
    })
  }
  context {
    let h = measure(block(width: text-width, body)).height
    block(width: 100%, above: quote-gap, below: 0pt, body)
    block(width: 100%, height: snap(h + 2 * quote-gap) - h - quote-gap, above: 0pt, below: 0pt)
  }
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)): the number is the template's, not the author's.
#let para-counter = counter("nvb-complaint-para")

#let numbered-item(t) = block(width: 100%, above: 0pt, below: 0pt, {
  para-counter.step()
  par(first-line-indent: (amount: para-indent, all: true), hanging-indent: 0pt,
    context box(width: number-box, para-counter.display() + ".") + inl(t))
})

/// An unnumbered paragraph (the lead-in, the prayer's introductory sentence): marked `[unnumbered]`.
#let plain-item(t) = block(width: 100%, above: 0pt, below: 0pt, {
  par(first-line-indent: (amount: para-indent, all: true), hanging-indent: 0pt, inl(t))
})

/// A list item: the label 1 in from the margin, the text hanging after it.
#let list-item(lab, t) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-left, {
  par(first-line-indent: 0pt, hanging-indent: label-box, box(width: label-box, lab) + inl(t))
}))

/// A markdown list: `1.` items are lettered (a., b., ...) as in the exemplar; `-` items have no marker (the
/// exemplar's indented lines under a paragraph). A list line that does not begin with a marker is a continuation
/// this template does not support, so it stops the build rather than being dropped.
#let list-items(t) = {
  let letters = "abcdefghijklmnopqrstuvwxyz"
  let idx = 0
  for line in t.split("\n") {
    let l = line.trim()
    if l == "" { continue }
    let num = l.match(regex("^(\\d+)\\.[ \\t]+(.*)$"))
    let bul = l.match(regex("^[-*+][ \\t]+(.*)$"))
    if num != none {
      list-item(letters.at(idx) + ".", num.captures.at(1))
      idx += 1
    } else if bul != none {
      list-item([], bul.captures.at(0))
    } else {
      panic("nvb-adversary-complaint: list continuation lines are not supported: " + l)
    }
  }
}

/// The whole body, chunk by chunk (blank-line separated). A chunk is a heading (one per line), a quotation, a
/// list, an unnumbered paragraph, or a numbered paragraph.
#let body-flow(body) = {
  let raw = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // consecutive quotation chunks are one quotation (its paragraphs a quote-gap apart)
  let chunks = ()
  for c in raw {
    if c.trim().starts-with(">") and chunks.len() > 0 and chunks.last().trim().starts-with(">") {
      chunks.at(-1) += "\n\n" + c
    } else { chunks.push(c) }
  }
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      for line in t.split("\n") {
        let l = line.trim()
        if l == "" { continue }
        if not l.starts-with("#") {
          panic("nvb-adversary-complaint: text directly under a heading is not supported: " + l)
        }
        let m = l.match(regex("^(#+)\\s+(.*)$"))
        heading-item(m.captures.at(0).len(), m.captures.at(1))
      }
    } else if t.starts-with(">") {
      quote-item(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else if t.starts-with("[unnumbered]") {
      plain-item(t.slice("[unnumbered]".len()).trim())
    } else {
      numbered-item(t)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (LR 9004(c)): the signer's name typed under "/s/ Name" in the signature space.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let right = ()
  for (k, s) in need(meta, "signature").enumerate() {
    let gap = if k == 0 { 0pt } else { signer-gap }
    if "firm" in s { right.push((text: s.firm, bold: true, above: gap)); gap = 0pt }
    right.push((text: "", above: gap))
    right += ("/s/ " + need(s, "signer"), need(s, "signer")) + need(s, "lines")
  }
  grid-row((
    (sig-col, stack(("Dated: " + need(meta, "date"),)), none, (:)),
    (text-width - sig-col, stack(right), none, (left: sig-gutter)),
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nvb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: { line-numbers(); pleading-rule() },
    // LR 9004(b): pages numbered consecutively, centered in a single line box where Word's footer sets it.
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled sign stays with its number too ("§§ 548"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads it as opening; pandoc,
  // the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")

  cover(meta)
  if "lead_in" in meta { plain-item(meta.lead_in) }
  body-flow(body)
  blank-line()
  signature-block(meta)
}
