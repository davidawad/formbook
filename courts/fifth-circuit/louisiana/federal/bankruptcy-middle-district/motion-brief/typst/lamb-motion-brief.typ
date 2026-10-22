// U.S. Bankruptcy Court, M.D. La.: motion with incorporated memorandum (FRBP 9013; the court's
// Local Rules 9013-1 (motions), 9013-2 (memoranda), 5005-2 (format), 9013-4 (service), 9013-5 (orders)).
//
// Rule-driven and content-agnostic. Requirement IDs (LAMB-...) refer to ../README.md and ../../rules.md.
// No case-specific text, no coordinates measured off any filed pleading, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                   // LAMB-FORM-004: LR 5005-2(b), 12-point font (footnotes too)
#let page-margin = 1in                  // LAMB-FORM-004: 8.5 x 11 page (LR 5005-2(a)); margins are a style choice
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let list-indent = 0.5in                // a markdown list item's label box (docx: List Item)
#let quote-indent = 0.5in               // a block quotation's indent on both sides
#let caption-gutter = 0.25in            // caption and signature: between the two columns
#let caption-col = (text-width - caption-gutter) / 2
#let caption-stroke = 0.75pt            // the rules at the right and foot of the party column (docx: w:sz 6)
#let caption-pad = 8.65pt               // the rules stand off the party column (docx: 173 twips)
#let case-pad = 0.1in                   // the case numbers stand off the gutter
#let label-indent = 1.5in               // caption: "Debtor.", "Plaintiff,", "Defendant."
#let v-indent = 0.75in                  // caption: "v."
#let table-inset = 5pt                  // the table's cell padding, left and right (docx: 100 twips)
#let table-pad = 3pt                    // the table's cell padding, top and bottom (docx: 60 twips)
#let table-rule = 0.5pt                 // the table's rules (docx: w:sz 4)
#let table-cap = 40                     // a column's width: its longest cell, at most this many characters

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lamb-motion-brief.lua sets the same twips,
// 20 x pt).
#let pitch-body = 24pt                  // LAMB-FORM-004, -005: LR 5005-2(b), 9013-2, double-spaced
#let pitch-single = 15.65pt             // caption, headings, quotations, table, footnotes, signature: single-spaced
#let court-below = 18pt                 // court name to the caption
#let in-re-gap = 2.4pt                  // caption: "In re:" to the debtor; between the case numbers
#let group-gap = 10.8pt                 // caption: the debtor group to the plaintiff
#let v-gap = 5.4pt                      // caption: above and below "v."
#let caption-below = 16.8pt             // the caption's rule to the title
#let title-below = 10.8pt               // the title to the notice; the notice to the body
#let heading-above = 11pt               // headings: the space above them
#let heading-below = 6pt                // headings: the space below them
#let quote-space = 6pt                  // a block quotation's space above and below it
#let table-space = 6pt                  // the table's space above and below it
#let note-gap = 4pt                     // between two footnotes
#let note-clearance = 12pt              // the body text to the footnote rule
#let signature-above = 12pt             // the last paragraph to the signature block
#let signature-gap = 10.8pt             // signature: "Respectfully submitted," to the /s/ line
#let contact-gap = 2.4pt                // signature: the counsel lines to the contact lines

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Fail loudly when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("lamb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A metadata value that may be one string or a list of strings, as a list.
#let lines-of(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line (a paragraph of its own; a string as plain text), with an explicit space above it.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt, pad(left: left, body))

/// Caption (Form 416 style for an adversary proceeding; the main-case caption when no parties are given).
#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  line-block(align(center, strong[UNITED STATES BANKRUPTCY COURT]))
  line-block(align(center, strong[MIDDLE DISTRICT OF LOUISIANA]))
  let left = {
    line-block("In re:")
    line-block(above: in-re-gap, need(meta, "debtor"))
    line-block(left: label-indent, "Debtor.")
    if "plaintiff" in meta {
      for (i, l) in lines-of(meta.plaintiff).enumerate() {
        line-block(above: if i == 0 { group-gap } else { 0pt }, l)
      }
      line-block(left: label-indent, "Plaintiff,")
      line-block(above: v-gap, left: v-indent, "v.")
      for (i, l) in lines-of(need(meta, "defendants")).enumerate() {
        line-block(above: if i == 0 { v-gap } else { 0pt }, l)
      }
      line-block(left: label-indent, "Defendant.")
    }
  }
  let right = {
    line-block("Case No. " + need(meta, "case_no"))
    line-block(above: in-re-gap, need(meta, "chapter"))
    if "adv_no" in meta { line-block(above: in-re-gap, "Adversary Proceeding No. " + meta.adv_no) }
  }
  // The rules beside and under the party column run the height of the caption (docx: the cell's borders).
  block(above: court-below, below: 0pt, grid(
    columns: (caption-col, caption-gutter, caption-col),
    grid.cell(stroke: (right: caption-stroke, bottom: caption-stroke), inset: (right: caption-pad, bottom: caption-pad),
      left),
    [],
    pad(left: case-pad, right),
  ))
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// Notice of motion and opportunity for hearing (LR 9013-1(b)(2)(i)-(iii)). The wording of the
/// objection deadline follows the rule; the hearing details come from metadata.
#let notice(meta) = {
  let h = need(meta, "hearing")
  block(width: 100%, sticky: true, above: title-below, below: 0pt,
    align(center, strong[NOTICE OF MOTION AND OPPORTUNITY FOR HEARING]))
  body-par[PLEASE TAKE NOTICE that the motion titled "#need(meta, "title")" has been filed. The motion seeks #need(meta, "relief")]
  body-par[A hearing on the motion is set for #need(h, "date") at #need(h, "time"), in #need(h, "place").]
  body-par[Any party opposing the motion must file an objection or response no later than eight days before the scheduled hearing and must at the same time serve a copy of the objection or response on the mover or its counsel, and on all other parties entitled to notice of the objection.]
}

/// Headings are body size (LAMB-FORM-002), single-spaced and kept with the block after them: "#" centred bold
/// capitals, "##" bold, "###" bold italic.
#let heading-block(level, s) = block(width: 100%, sticky: true, above: heading-above, below: heading-below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(s))) }
  else if level == 2 { strong(inl(s)) }
  else { strong(emph(inl(s))) }
})

/// A pipe table (GitHub markdown), ruled and single-spaced, the width of the text. A column's width is in proportion
/// to its longest cell (characters, emphasis marks not counted), at most `table-cap`, rounded to the twip; the last
/// column takes the rest (docx: the same arithmetic in docx/lamb-motion-brief.lua). The header row repeats on every
/// page; a row longer than the rest of a page splits there, between two lines.
#let pipe-table(t, width) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let lines = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let rows = lines.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let need = range(ncol).map(j => calc.min(table-cap, calc.max(..rows.map(r => chars(r.at(j, default: ""))))))
  let total = need.sum()
  let widths = need.slice(0, -1).map(n => calc.round(width.pt() * n / total * 20) / 20 * 1pt)
  widths.push(width - widths.sum(default: 0pt))
  let cells(r) = range(ncol).map(j => inl(r.at(j, default: "")))
  // Word sets each rule in a height of its own above a row (and below the last): the cell pads above by the rule.
  table(columns: widths, inset: (x: table-inset, top: table-pad + table-rule, bottom: table-pad), stroke: table-rule,
    table.header(..cells(rows.first())),
    ..rows.slice(1).map(cells).flatten())
}

/// The footnote definitions of the body ("[^n]: text"). They are appended to each chunk that refers to them, because
/// cmarker resolves a reference only against the definitions in the same string.
#let footnote-definitions(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c.starts-with("[^")).join("\n\n")

/// The motion and the incorporated memorandum (LR 9013-2), in document order: headings, paragraphs (the author's
/// own paragraph numbers are text), block quotations, the table, markdown lists.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = footnote-definitions(body)
  let with-notes(t) = t + if t.contains("[^") and defs != none { "\n\n" + defs } else { "" }
  for t in chunks {
    if t.starts-with("[^") {
      // A footnote definition is rendered with the paragraph that refers to it.
    } else if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with("|") {
      // The table is single-spaced and ruled; the space around it is spacing of its own (docx: empty paragraphs).
      v(table-space)
      block(width: 100%, above: 0pt, below: 0pt, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pipe-table(t, text-width)
      })
      v(table-space + table-rule)
    } else if t.starts-with(">") {
      // A block quotation is single-spaced and indented on both sides; its paragraphs follow each other.
      block(width: 100%, above: quote-space, below: quote-space, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        inl(with-notes(t.replace(regex("(?m)^>[ \t]?"), "")))
      }))
    } else if t.starts-with("- ") or t.starts-with("* ") or t.match(regex("^\\d+[.)] ")) != none {
      // A markdown list: the label in its box at the margin, the text hanging (lib/typst/xengine.typ).
      block(width: 100%, above: 0pt, below: 0pt, {
        set par(first-line-indent: 0pt)
        inl(with-notes(t))
      })
    } else {
      body-par(inl(with-notes(t)), sticky: t.starts-with("WHEREFORE"))
    }
  }
}

/// Signature block with the contact details LR 9013-1(a) requires on a motion. The space above it is spacing of its
/// own (docx: an empty paragraph of that height); the block is kept whole.
#let signature(meta) = {
  let sig = need(meta, "signature")
  let contact = need(meta, "contact")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  v(signature-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (caption-col, caption-gutter, caption-col),
    line-block("Dated: " + need(meta, "date")),
    [],
    {
      line-block("Respectfully submitted,")
      line-block(above: signature-gap, "/s/ " + sig.signer)
      for l in lines-of(sig.lines) { line-block(emph(l)) }
      // The address is one string, or a list of lines when the filed block breaks it.
      for (i, l) in lines-of(need(contact, "address")).enumerate() {
        line-block(above: if i == 0 { contact-gap } else { 0pt }, emph(l))
      }
      line-block(emph("Telephone: " + need(contact, "phone")))
      line-block(emph("Email: " + need(contact, "email")))
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry: the whole motion
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("title", "relief", "hearing", "debtor", "case_no", "chapter", "date", "signature", "contact") {
    let _ = need(meta, k)
  }
  if "plaintiff" in meta { let _ = need(meta, "defendants") }

  // ---- document-wide settings ----
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // Every page numbered, bottom centre (LR 9013-2: paginated); the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number, list labels in a box of list-indent.
  show: xengine.with(pitch: pitch-body, list-indent: list-indent)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // ---- first page: caption, title, notice ----
  caption(meta)
  block(width: 100%, above: caption-below, below: 0pt, align(center, strong(upper(need(meta, "title")))))
  notice(meta)

  // ---- body: the motion and the incorporated memorandum (LR 9013-2) ----
  v(title-below)
  body-content(md)

  // ---- signature ----
  signature(meta)
}
