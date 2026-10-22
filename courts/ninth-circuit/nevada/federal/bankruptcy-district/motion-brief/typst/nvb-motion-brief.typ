// Motion with memorandum of points and authorities for the United States Bankruptcy Court, District of Nevada (nvb).
// Rules (../../rules.md, ../README.md): LR 9004(a)-(c) and (g) (form: 8 1/2 by 11, double-spaced, every line
// numbered in the left margin, a proportional font of 12 point or larger, consecutive page numbers, title page
// begins 1 1/2 inches from the top, attorney identification at the upper left, "/s/" signatures); LR 7010 (caption);
// LR 9014(b)-(c) (notice of hearing, the legal memorandum in the motion); LR 9014(e)(1) (20-page limit for an opening
// brief); LR 7008 (consent statement). Content-agnostic: every case word comes from the sample's frontmatter and body.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its
// pitch with the baseline at 0.8 of it, boxes touching, first fit, no kerning, ligatures or hyphenation. The docx
// engine (docx/nvb-motion-brief.lua, docx/reference.xml) sets the same pitches, indents and spaces in twips.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named layout choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // LR 9004(b): a proportional font; no face named, Times New Roman the house standard
#let type-size = 12pt                     // LR 9004(b): at least 12 point, footnotes included (the exemplar's size)
#let pitch = 24pt                         // LR 9004(a): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                  // single-spaced lines (LR 9004(a) exempts the counsel block, caption, quotations, footnotes): half a numbered line, so they keep to the grid
#let lines-per-page = 27                  // LR 9004(a): each line numbered in the left margin; 27 lines inside 1 in margins
#let top-margin = 72pt                    // line 1 sits on the top margin
#let bottom-margin = 72pt                 // 11 in - 1 in - 27 x 24 pt: the page number sits in it
#let left-margin = 1.5in                  // the line numbers and the rule stand in it
#let right-margin = 1in
#let number-col = 1in                     // the line numbers end 1 in from the left edge
#let number-drop = 1.2pt                  // a number sits this far below its double-spaced line's baseline, as far above the single line at the
                                          // foot of its slot: every line beside a number is one text line with it in every engine's PDF
#let rule-in = 0.2in                      // the pleading rule stands this far left of the text
#let title-page-lines = 2                 // LR 9004(a): the title page begins 1 1/2 in down; the counsel block starts on line 3 (1.67 in)
#let counsel-gutter = 0.25in              // between counsel columns
#let caption-left = 3.2in                 // the party column of the caption
#let box-pad = 8pt                        // the party column's text stands at least this far above its foot rule
#let rule-pad = 8pt                       // and this far left of its right rule
#let caption-gutter = 0.2in               // the right column's text starts this far right of the rule
#let caption-gap = 12pt                   // between the parts of the caption's right column
#let rule-width = 0.75pt                  // the caption rules; the row keeps room for its foot rule below the right column too
#let para-indent = 0.5in                  // first-line indent of body paragraphs
#let list-left = 1in                      // a list's label stands 1 in from the margin
#let label-box = 0.25in                   // and its text hangs a quarter inch further in
#let quote-inset = 0.5in                  // block quotations indented on both sides
#let quote-gap = 12pt                     // around and between the paragraphs of a quotation
#let sig-col = caption-left               // the "Dated" column of the signature block; [sig] lines stand right of it
#let sig-gutter = 0.2in
#let note-clearance = 12pt                // the body text to the footnote rule
#let note-rule-gap = 6pt                  // the rule to the footnotes: with note-clearance between 12 and 24 pt, as in LibreOffice,
                                          // so a numbered line stops above a footnote in both engines (notes are whole 12 pt lines)
#let note-rule = 1.5in                    // the footnote rule's length

#let text-width = 8.5in - left-margin - right-margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, emphasis).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required frontmatter field: a missing one stops the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("nvb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Whole numbered lines: a height rounded up to a multiple of the pitch, so what follows stays on the grid.
#let snap(h) = calc.ceil(h / pitch - 0.001) * pitch

/// A blank numbered line.
#let blank-line(keep: false) = block(width: 100%, height: pitch, above: 0pt, below: 0pt, sticky: keep)

/// One single-spaced line block; an empty string is a blank single line.
#let single(s, above: 0pt, weight: "regular") = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single), weight: weight)
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  if s == "" { box(height: pitch-single) } else { inl(s) }
})

/// Single lines, one per item: a string, or (text:, bold:, above:).
#let stack(items) = for it in items {
  if type(it) == str { single(it) } else {
    single(it.text, above: it.at("above", default: 0pt), weight: if it.at("bold", default: false) { "bold" } else { "regular" })
  }
}

/// A row of columns whose height is rounded up to whole numbered lines (the docx engine sets the same row height:
/// docx/nvb-motion-brief.lua). `cells`: (width, content, stroke, inset).
#let grid-row(cells) = context {
  let h = calc.max(..cells.map(c => measure(block(width: c.at(0), inset: c.at(3), c.at(1))).height))
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
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

/// Court title: the same on every caption of this court, one numbered line each.
#let court-title() = for t in ("UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF NEVADA") {
  block(width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", t)))
}

/// The caption: the debtor (or alleged debtor) on the left, ruled at the right and foot; the case number, chapter,
/// title of the paper and any hearing date and time on the right.
#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let left-rows = ()
  if "heading" in debtor { left-rows.push(debtor.heading) }
  left-rows += debtor.names
  left-rows.push(debtor.designation)
  let right = ("Case No.: " + need(meta, "case_number"),)
  if "chapter" in meta { right.push(meta.chapter) }
  right.push((text: need(meta, "title"), bold: true, above: caption-gap))
  if "hearing" in meta {
    right.push((text: "Hearing Date: " + need(meta.hearing, "date"), above: caption-gap))
    right.push("Hearing Time: " + need(meta.hearing, "time"))
  }
  grid-row((
    (caption-left, stack(left-rows), (right: rule-width, bottom: rule-width), (right: rule-pad, bottom: box-pad)),
    (text-width - caption-left, stack(right), none, (left: caption-gutter, bottom: rule-width)),
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
/// level 2 centered bold, level 3 bold at the margin. `new-page`: the heading opens a page (the certificate of
/// service after the signature).
#let heading-item(level, t, new-page: false) = {
  // a heading that starts with its own number ("1. The ...") is text, not a list
  t = t.replace(regex("^(\\d+)\\. "), m => m.captures.at(0) + "\\. ")
  if new-page { pagebreak(weak: true) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    if level == 1 { align(center, underline(text(weight: "bold", upper(inl(t))))) } else if level == 2 {
      align(center, text(weight: "bold", inl(t)))
    } else { text(weight: "bold", inl(t)) }
  })
}

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

/// A paragraph's text, with its footnote references turned into footnotes. Definitions (`[^id]: text`) are collected
/// from the whole body first (body-flow), since a definition can sit after the reference that uses it.
#let para-content(t, defs) = {
  let out = ()
  let last = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    let id = m.captures.at(0)
    if id not in defs { panic("nvb-motion-brief: footnote [^" + id + "] has no definition") }
    let before = t.slice(last, m.start)
    if last > 0 and before.starts-with(" ") { out.push([ ]) }
    out.push(inl(before))
    if before.ends-with(" ") { out.push([ ]) }
    out.push(footnote(inl(defs.at(id))))
    last = m.end
  }
  let rest = t.slice(last)
  if last > 0 and rest.starts-with(" ") { out.push([ ]) }
  out.push(inl(rest))
  out.join()
}

/// A body paragraph: double-spaced, first-line indent. Motions are not numbered paragraphs.
/// `keep`: kept whole with what follows (the paragraph before a signature: a signature never stands alone on a page).
#let paragraph-item(t, defs, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), hanging-indent: 0pt, para-content(t, defs)))

/// A list item: the label 1 in from the margin, the text hanging after it.
#let list-item(lab, t) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-left,
  par(first-line-indent: 0pt, hanging-indent: label-box, box(width: label-box, lab) + inl(t))))

/// A markdown list: `1.` items are lettered (a., b., ...); `-` items have no marker. A list line that does not begin
/// with a marker is a continuation this template does not support, so it stops the build rather than being dropped.
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
      panic("nvb-motion-brief: list continuation lines are not supported: " + l)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (LR 9004(c)): the signer's name typed under "/s/ Name" in the signature space.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  if type(blocks) == dictionary { blocks = (blocks,) }
  let right = ()
  for (k, s) in blocks.enumerate() {
    let gap = if k == 0 { 0pt } else { caption-gap }
    if "firm" in s { right.push((text: s.firm, bold: true, above: gap)); gap = 0pt }
    right.push((text: "", above: gap))
    right += ("/s/ " + need(s, "signer"), need(s, "signer")) + need(s, "lines")
  }
  grid-row((
    (sig-col, stack(("Dated: " + need(meta, "date"),)), none, (:)),
    (text-width - sig-col, stack(right), none, (left: sig-gutter)),
  ))
}

/// Signature lines (a chunk whose lines begin `[sig]`): single-spaced in the signature column, kept together.
#let sig-item(t) = grid-row(((text-width,
  stack(t.split("\n").map(l => l.trim()).filter(l => l != "").map(l => l.slice(5).trim())),
  none, (left: sig-col + sig-gutter)),))

/// The whole body, chunk by chunk (blank-line separated). A chunk is a heading (one per line), a quotation, a list, a
/// signature line, the `[signature]` marker, a footnote definition, or a paragraph.
#let body-flow(body, meta) = {
  let raw = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // footnote definitions first, so a reference can point to a definition further down the body
  let defs = (:)
  for c in raw {
    let d = c.trim().match(regex("^\\[\\^(\\w+)\\]:[ \\t]*([\\s\\S]*)$"))
    if d != none { defs.insert(d.captures.at(0), d.captures.at(1).trim()) }
  }
  // consecutive quotation chunks are one quotation (its paragraphs a quote-gap apart)
  let chunks = ()
  for c in raw {
    if c.trim().starts-with(">") and chunks.len() > 0 and chunks.last().trim().starts-with(">") {
      chunks.at(-1) += "\n\n" + c
    } else { chunks.push(c) }
  }
  let signed = false
  for (k, c) in chunks.enumerate() {
    let t = c.trim()
    let next = chunks.at(k + 1, default: "").trim()
    if t.match(regex("^\\[\\^(\\w+)\\]:")) != none {
      continue
    } else if t == "[signature]" {
      blank-line(keep: true)
      signature-block(meta)
      signed = true
    } else if t.starts-with("[sig]") {
      blank-line(keep: true)
      sig-item(t)
    } else if t.starts-with("#") {
      for line in t.split("\n") {
        let l = line.trim()
        if l == "" { continue }
        if not l.starts-with("#") {
          panic("nvb-motion-brief: text directly under a heading is not supported: " + l)
        }
        let m = l.match(regex("^(#+)\\s+(.*)$"))
        heading-item(m.captures.at(0).len(), m.captures.at(1), new-page: signed)
        signed = false
      }
    } else if t.starts-with(">") {
      quote-item(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else {
      paragraph-item(t, defs, keep: next == "[signature]" or next.starts-with("[sig]"))
    }
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nvb-motion-brief(meta, body) = {
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
  // Footnotes: 12 point (LR 9004(b)) in single lines, the mark then a space, a rule above them.
  set footnote.entry(separator: block(height: note-rule-gap, line(length: note-rule, stroke: 0.5pt)), gap: 0pt, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // A doubled sign stays with its number too ("§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads it as opening; pandoc,
  // the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")

  cover(meta)
  body-flow(body, meta)
}
