// U.S. District Court, Southern District of Illinois: complaint.
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
#let type-size = 12pt                  // ILSD-FORM-002: 12-point type; the rule text is SDIL-LR 7.1(a)(3), briefs. Applied to complaints too (see README).
#let margins = (top: 1in, bottom: 1in, x: 1in)  // ILSD-FORM-001: 1-inch margins (convention; see README)
#let para-indent = 0.5in               // first-line indent of paragraphs; a paragraph's number stands in a box this wide after it (Fed. R. Civ. P. 10(b))
#let item-indent = 0.5in               // prayer items: the typed label stands half an inch in ...
#let item-label = 0.5in                // ... in a box this wide; the text hangs after it
#let caption-left = 3.5in              // the party column of the caption
#let caption-marks = 0.4in             // the column of ")" marks
#let caption-right = 0.25in            // the case number and jury demand stand this far right of the marks
#let designation-indent = 1.4in        // "Plaintiffs," / "Defendants." under the party names
#let sig-indent = 3.25in               // signature block starts at the middle of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                 // ILSD-FORM-003: double spacing at 12 pt (SDIL-LR 5.1(a))
#let pitch-single = 13.8pt             // single spacing (court name, caption, headings, signature, footnotes): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                // a blank single line: in the caption and between the groups of the signature block
#let h1-above = 18pt                   // a level 1 heading: space above and below
#let h1-below = 6pt
#let h2-gap = 12pt                     // a level 2 heading: space above and below
#let title-below = 12pt                // the title to the lead-in
#let item-gap = 7.2pt                  // between prayer items
#let note-gap = 7pt                    // between footnotes
#let note-clearance = 12.6pt           // between the text and the footnote rule (the room LibreOffice keeps above a note)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, footnote references, links) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ilsd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// A paragraph at the body pitch; `last` keeps it whole and with the signature block after it.
#let body-par(above: 0pt, last: false, content) = block(width: 100%, above: above, below: 0pt, sticky: last,
  breakable: not last, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a): court name, title, file number; the title of the action)
// ---------------------------------------------------------------------------

/// The caption: one row per party line (names, a blank line, the designation, a blank line, "v.", a blank line, ...),
/// a column of ")" marks (one per line of text: a name can wrap), the case number on the "v." row and the jury
/// demand a blank line below it.
#let caption(parties, case-number, jury) = {
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
    let right = if k == v { line-block(left: caption-right)[Case No. #case-number] }
      else if jury and v != none and k == v + 2 { line-block(left: caption-right, strong[DEMAND FOR JURY TRIAL]) }
      else { [] }
    cells += (text-cell, marks, right)
  }
  grid(columns: (caption-left, caption-marks, 1fr), ..cells)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayer items, unnumbered paragraphs
// ---------------------------------------------------------------------------

/// Headings, single-spaced, bold and centered, kept with the block after them. Level 1 "# ...": 18 pt above, 6 pt
/// below; level 2 "## ...": 12 pt above and below.
#let heading-block(level, s) = {
  let (above, below) = if level == 1 { (h1-above, h1-below) } else { (h2-gap, h2-gap) }
  line-block(above: above, below: below, sticky: true, align(center, strong(inl(s))))
}

/// Prayer items, one per "- " line: the typed label ("1.", "(a)") in a box half an inch in, the text hanging after
/// it. An item without a label hangs in the same place.
#let items(c, last) = {
  let lines = c.split("\n").filter(l => l.starts-with("- "))
  let label = regex("^(\\d+\\\\?\\.|\\(?[A-Za-z0-9]+\\))\\s+")
  for (i, l) in lines.enumerate() {
    let s = l.slice(2)
    let m = s.match(label)
    let lab = if m == none { [] } else { m.captures.at(0).replace("\\", "") }
    let rest = if m == none { s } else { s.slice(m.end) }
    let is-last = last and i == lines.len() - 1
    block(width: 100%, above: item-gap, below: 0pt, sticky: is-last, breakable: not is-last,
      par(hanging-indent: item-indent + item-label, first-line-indent: 0pt,
        [#h(item-indent)#box(width: item-label, lab)#inl(rest)]))
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a): signed by at least one attorney of record)
// ---------------------------------------------------------------------------

/// "Dated:" at the margin, then at the middle of the page: "Respectfully submitted,", the firm, the e-signature with
/// the signer's lines, the other counsel's lines, the role; a blank single line between the groups. Kept on one page.
#let signature(meta) = {
  let sig = need(meta, "signature")
  let s(above: 0pt, body) = line-block(above: above, left: sig-indent, body)
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block[Dated: #need(meta, "date")]
    s(above: gap)[Respectfully submitted,]
    s(above: gap, strong(inl(sig.firm)))
    s(above: gap)[By: /s/ #inl(sig.signer)]
    for l in sig.lines { s(inl(l)) }
    for (i, l) in sig.at("other", default: ()).enumerate() { s(above: if i == 0 { gap } else { 0pt }, inl(l)) }
    if "role" in sig { s(above: gap, emph(inl(sig.role))) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ilsd-complaint(meta, body) = {
  set document(title: need(meta, "title") + " (" + need(meta, "case_number") + ")")
  // ILSD-LR-001: letter paper, every page numbered; the number centered in the bottom margin, in a single-spaced
  // line box (Word's footer).
  set page(paper: "us-letter", margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

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

  // Court name (Fed. R. Civ. P. 10(a))
  line-block(align(center)[UNITED STATES DISTRICT COURT])
  line-block(below: pitch-body, align(center)[FOR THE SOUTHERN DISTRICT OF ILLINOIS])

  caption(need(meta, "caption"), need(meta, "case_number"), meta.at("jury_demand", default: false))

  line-block(above: pitch-body, below: title-below, sticky: true, align(center, strong(inl(need(meta, "title")))))

  // Unnumbered lead-in paragraph ("...for their Complaint against ... allege:")
  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }

  // Body: blank-line-separated chunks; a chunk that cites a footnote carries the footnote definitions with it.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  let chunks = chunks.filter(c => not c.starts-with("[^"))
  let with-notes(s) = if defs != none and s.contains("[^") { s + "\n\n" + defs } else { s }
  let n = 0
  for (k, c) in chunks.enumerate() {
    // the last block stays with the signature block, so the signature never stands alone on a page
    let last = k == chunks.len() - 1
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      heading-block(level, c.replace(regex("^#+\\s*"), ""))
    } else if c.starts-with("- ") {
      items(c, last)
    } else if c.starts-with("~ ") {
      body-par(last: last)[#h(para-indent)#inl(with-notes(c.slice(2)))]
    } else {
      n += 1
      body-par(last: last)[#h(para-indent)#box(width: para-indent)[#n.]#inl(with-notes(c))]
    }
  }

  signature(meta)
}
