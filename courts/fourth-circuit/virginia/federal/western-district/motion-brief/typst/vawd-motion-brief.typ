// Brief in support of a motion (Rule 12(b)) for the U.S. District Court for the Western District of Virginia.
// Rules: Fed. R. Civ. P. 7(b)(1) (a request for a court order is made by motion, stated with particularity);
// W.D. Va. Local Rule 11(a) (attorney's office address, telephone, e-mail and bar number on every motion);
// Local Rule 11(c)(1) (a motion is accompanied by a brief stating the facts and the authorities relied on).
// The local rules set no type size, margin, spacing, page limit or table-of-contents requirement for briefs:
// the values below are the convention both filed exemplars show (see ../README.md). Content-agnostic: every
// case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the exemplars; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                   // no rule sets a size; 12 pt, the size of the Times used by the exemplars (docs/FONTS.md)
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let para-indent = 0.5in                // first line of a paragraph of text
#let label-box = 0.4in                  // a numbered heading's label; each deeper level half an inch further in
#let level-indent = 0.5in
#let quote-indent = 0.5in               // block quotations, both sides
#let caption-width = 3.3in              // width of the party block in the caption
#let caption-inset = 0.125in            // the party text off the box caption's right and bottom rules
#let caption-gutter = 0.15in            // between the box and the file number
#let number-inset = 0.1in               // the file number off the gutter
#let parens-width = 0.4in               // the ")" column of the parens caption
#let versus-indent = 0.6in              // "v." in the caption
#let designation-indent = 1.5in         // a party's designation under its names
#let signature-indent = 3.25in          // the signer's block
#let recipient-indent = 0.5in           // the certificate's recipients
#let footnote-size = 11pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips). An INPUT's
// `word:` map (justify, shrink; lib/typst/word-compat.typ) is not read: the model sets the text ragged right.
#let pitch-body = 27.6pt                // double spacing: Word's double line at 12 pt (2 x 1.15 x 12 pt), as both exemplars set it
#let pitch-single = 13.8pt              // single spacing (court title, caption, headings, quotations, signature): 1.15 x 12 pt
#let pitch-note = 12.65pt               // a footnote line: 1.15 x 11 pt
#let gap = pitch-single                 // a blank single line: around quotations, under the title, in the signature
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 7pt              // between the text and the footnote rule: with the 7 pt gap, the room LibreOffice keeps above a
                                        // note in this docx (a page of text and one note breaks within 1 pt of the same height in both)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A frontmatter field the template cannot do without: a missing one stops the build.
#let need(meta, key) = {
  if key in meta and meta.at(key) != none { meta.at(key) } else { panic("vawd-motion-brief: the sample frontmatter needs `" + key + "`") }
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// Heading labels: level 2 is "1.", level 3 is "a.", level 4 is "(i)"; level 1 (a section) is unnumbered.
#let heading-num(..n) = {
  let nums = n.pos()
  if nums.len() == 2 { str(nums.at(1)) + "." }
  else if nums.len() == 3 { numbering("a.", nums.at(2)) }
  else if nums.len() == 4 { "(" + numbering("i", nums.at(3)) + ")" }
  else { none }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF VIRGINIA", upper(need(meta, "division")))
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, l))
  }
}

/// The party lines of the caption, in order: (content, left indent, is "v.").
#let party-lines(meta) = {
  let items = ()
  for (i, p) in need(meta, "caption").parties.enumerate() {
    if i > 0 { items.push(([v.], versus-indent, true)) }
    for n in p.names { items.push((inl(n), 0pt, false)) }
    items.push((inl(p.designation), designation-indent, false))
  }
  items
}

/// Box caption: the party lines closed by a rule at their right and under the last; the file number opposite, on the
/// first "v." row. One grid row per party line, a blank single line between rows.
#let caption-box(meta) = {
  let lines = party-lines(meta)
  let cells = ()
  let numbered = false
  for (k, (c, ind, versus)) in lines.enumerate() {
    let last = k == lines.len() - 1
    let top = if k > 0 { gap } else { 0pt }
    cells.push(grid.cell(stroke: (right: 0.75pt, bottom: if last { 0.75pt } else { none }),
      inset: (top: top, right: caption-inset, bottom: if last { caption-inset } else { 0pt }), line-block(left: ind, c)))
    cells.push([])
    let right = if versus and not numbered {
      numbered = true
      line-block(left: number-inset)[#need(meta, "case_label") #need(meta, "case_number")]
    } else { [] }
    cells.push(grid.cell(inset: (top: top), right))
  }
  grid(columns: (caption-width, caption-gutter, 1fr), ..cells)
}

/// ")" caption: a column of ")" marks beside the party lines, one per line of text (a name can wrap), and the file
/// number to the right of the marks on the first "v." row.
#let caption-parens(meta) = {
  let cells = ()
  let numbered = false
  for (c, ind, versus) in party-lines(meta) {
    let text-cell = line-block(left: ind, c)
    let marks = context {
      let n = calc.max(1, calc.round(measure(width: caption-width, text-cell).height / pitch-single))
      for _ in range(n) { line-block(align(center)[)]) }
    }
    let right = if versus and not numbered {
      numbered = true
      line-block[#need(meta, "case_label") #need(meta, "case_number")]
    } else { [] }
    cells += (text-cell, marks, right)
  }
  grid(columns: (caption-width, parens-width, 1fr), ..cells)
}

#let cover(meta) = {
  court-title(meta)
  if need(meta, "caption").at("style", default: "box") == "parens" { caption-parens(meta) } else { caption-box(meta) }
  line-block(above: pitch-body, below: gap, align(center, strong(upper(inl(need(meta, "brief_title"))))))
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (Fed. R. Civ. P. 11(a); Local Rule 11(a))
// ---------------------------------------------------------------------------

/// The signer's block: an optional preamble (the parties, or "Respectfully submitted,"), the e-signature line, then
/// one group per counsel (names, then the firm, address, telephone, fax and e-mail lines), then the role lines. Each
/// group is a blank line from the one before.
#let signer-block(sig, preamble: true, above: 0pt) = {
  let groups = ()
  let pre = if preamble { sig.at("preamble", default: ()) } else { () }
  if pre.len() > 0 { groups.push(pre) }
  let first = (sig.signed_by,)
  for (k, g) in sig.counsel.enumerate() {
    let lines = g.names + g.at("lines", default: ())
    if k == 0 { first += lines } else { groups.push(first); first = lines }
  }
  groups.push(first)
  let role = sig.at("role", default: ())
  if role.len() > 0 { groups.push(role) }
  for (k, g) in groups.enumerate() {
    for (i, l) in g.enumerate() {
      line-block(above: if i == 0 { if k == 0 { above } else { gap } } else { 0pt }, left: signature-indent, inl(l))
    }
  }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch-body, below: 0pt, width: 100%, {
    if "date" in meta and meta.date != none {
      line-block[Dated: #meta.date]
      signer-block(sig, above: gap)
    } else {
      signer-block(sig)
    }
  })
}

#let certificate(meta) = {
  if "service" in meta and meta.service != none {
    let svc = meta.service
    block(breakable: false, above: pitch-body, below: 0pt, width: 100%, {
      line-block(below: gap, align(center, strong("CERTIFICATE OF SERVICE")))
      block(width: 100%, above: 0pt, below: gap, par(first-line-indent: (amount: para-indent, all: true), inl(svc.text)))
      for l in svc.recipients { line-block(left: recipient-indent, inl(l)) }
      signer-block(need(meta, "signature"), preamble: false, above: gap)
    })
  }
}

/// Splits the markdown body where the final section (its last level-1 heading and what follows) starts, so
/// that a short final section can be kept on one page with the signature block. Footnote definitions stay in
/// the head: a reference and its definition must be in the same render. Returns (head: str, tail: str or none).
#let final-section(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let body-chunks = chunks.filter(c => not c.trim().starts-with("[^"))
  let last = none
  for (i, c) in body-chunks.enumerate() {
    if c.trim().starts-with("# ") { last = i }
  }
  let tail = if last == none { () } else { body-chunks.slice(last) }
  let tail-text = tail.join("\n\n")
  let keep = last != none and tail-text.len() < 1200 and not tail-text.contains("[^")
  let head = if keep { body-chunks.slice(0, last) } else { body-chunks }
  let head-text = head.join("\n\n") + if defs != "" { "\n\n" + defs } else { "" }
  (head: head-text, tail: if keep { tail-text } else { none })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let vawd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "case_label", "division", "caption", "brief_title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signed_by,
  )
  // The page number centered at the foot of every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 55–57"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  set heading(numbering: heading-num)

  // Footnotes: 11 pt, single-spaced (1.15 x 11 pt boxes), the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }

  // Headings, kept with the text after them. Level 1: a centered bold capital section (no number) in a double-spaced
  // line, half a line below the text above (so a footnote mark on it stays inside the top margin). Levels 2 to 4: bold
  // and single-spaced, the number in a label box hung from the margin (each level half an inch further in), a single line
  // below the text above.
  show heading: it => {
    if it.level == 1 {
      block(width: 100%, above: gap, below: 0pt, sticky: true, {
        set text(size: type-size)
        set par(first-line-indent: 0pt)
        align(center, strong(upper(it.body)))
      })
    } else {
      let lab = numbering(it.numbering, ..counter(heading).at(it.location()).slice(0, it.level))
      block(width: 100%, above: gap, below: 0pt, sticky: true, {
        set text(size: type-size, ..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: (it.level - 2) * level-indent,
          par(hanging-indent: label-box, [#box(width: label-box, strong(lab))#strong(it.body)]))
      })
    }
  }

  // Block quotations: single-spaced, indented on both sides, a single line apart from the text.
  show quote.where(block: true): it => block(width: 100%, above: gap, below: gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-indent, it.body)
  })

  cover(meta)
  let parts = final-section(md)
  cmarker.render(parts.head, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if parts.tail == none {
    signature-block(meta)
  } else {
    block(breakable: false, width: 100%, above: gap, below: 0pt, {
      cmarker.render(parts.tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
      signature-block(meta)
    })
  }
  certificate(meta)
}
