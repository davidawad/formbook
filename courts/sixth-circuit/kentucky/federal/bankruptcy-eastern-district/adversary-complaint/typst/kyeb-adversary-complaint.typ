// U.S. Bankruptcy Court, Eastern District of Kentucky: adversary complaint (FRBP 7001).
//
// Rule-driven and content-agnostic. Requirement IDs (KYEB-...) refer to ../README.md, which quotes the
// rule text (FRBP 7001, 7003, 7008, 7010, 9004, 9011; FRCP 5.2 and 10). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // KYEB-FORM-001: no E.D. Ky. bankruptcy rule sets a typeface; Times New Roman, the default per docs/FONTS.md
#let type-size = 12pt                    // KYEB-FORM-001: a legible size (FRBP 9004(a)); 12 pt, the usual floor (footnotes too)
#let note-size = 10pt                    // the debtors' note under the caption (KYEB-FOOT-001)
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let text-width = 8.5in - margins.left - margins.right
#let para-indent = 0.5in                 // first-line indent of paragraphs; an allegation's number stands there
#let num-box = 0.5in                     // an allegation's number "1." in a box of this width, the text after it
#let item-box = 0.5in                    // a lettered item's "a." in a box of this width, half an inch in, the text hanging
#let caption-left = 3.3in                // width of the debtor and party column of the caption
#let caption-stroke = 0.75pt             // the rules beside and under the party column (docx: w:sz 6)
#let cell-pad = 10.8pt                   // the caption's text stands off the rule (docx: 216 twips)
#let designation-indent = 1.8in          // caption: "Debtors.", "Plaintiff,", "Defendant."
#let signature-col = 3.2in               // signature: the firm, the signer and counsel lines

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kyeb-adversary-complaint.lua sets the same
// twips, 20 x pt).
#let pitch-body = 24pt                   // KYEB-FORM-003: double-spaced numbered paragraphs
#let pitch-single = 14pt                 // KYEB-FORM-003: caption, title, footnotes, signature single-spaced
#let pitch-note = 12pt                   // the debtors' note at 10 pt, single-spaced
#let half-line = 12pt                    // caption: between its groups; the caption to the title, the title to the text
#let court-below = 24pt                  // the court's name to the caption
#let row-pad = 6pt                       // caption: the rule under the debtors stands off the text above and below it
#let caption-foot = 12pt                 // caption: the text to the closing rule
#let note-above = 6pt                    // the caption's rule to the debtors' note
#let note-gap = 7pt                      // between two footnotes
#let note-clearance = 12pt               // the body text to the footnote rule
#let signature-above = 24pt              // the last paragraph to the signature block
#let signature-gap = 24pt                // signature: the firm to the /s/ line
#let footer-distance = 0.3in            // the page number line stands this far above the foot of the page (docx: footer 432 twips)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("kyeb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, left: 0pt, center: false, body) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, align(if center { std.center } else { start },
    par(first-line-indent: 0pt, hanging-indent: 0pt, unloose(body)))))

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), 7010 and Official Form 416A, substantially conformed)
// ---------------------------------------------------------------------------

/// Court name lines, centered and bold, at the top of the first page (FRBP 9004(b)(1)).
#let court-title(meta) = {
  for l in need(meta, "court") { line-block(center: true, strong(inl(l))) }
}

/// Caption: debtors on the left, the chapter and case number on the right, then the parties and the
/// adversary number (FRBP 9004(b)(2)-(3)). Rules beside and under the left column.
#let caption-table(meta) = {
  let cap = need(meta, "caption")
  let debtors = cap.debtors
  let left-top = {
    line-block("In re:")
    for (i, n) in debtors.names.enumerate() {
      line-block(above: if i == 0 { half-line } else { 0pt },
        [#inl(n)#if i == 0 and "footnote" in debtors { super[\*] }])
    }
    line-block(left: designation-indent, inl(debtors.designation))
  }
  let right-top = {
    line-block(inl(need(meta, "chapter")))
    line-block(above: half-line, [Case No. #need(meta, "case_number")])
    if need(meta, "jointly_administered") { line-block([(Jointly Administered)]) }
  }
  let left-bottom = {
    for (i, side) in cap.parties.enumerate() {
      for (j, n) in side.names.enumerate() { line-block(above: if i > 0 and j == 0 { half-line } else { 0pt }, inl(n)) }
      if "serve" in side {
        for l in side.serve { line-block(inl(l)) }
      }
      line-block(above: if "serve" in side { half-line } else { 0pt }, left: designation-indent,
        inl(side.designation))
      if i < cap.parties.len() - 1 {
        line-block(above: half-line, [v.])
      }
    }
  }
  let right-bottom = {
    let adv = meta.at("adversary_number", default: "")
    line-block(if adv == "" { [Adv. No. #("_" * 12)] } else { [Adv. No. #adv] })
  }
  block(above: court-below, below: 0pt, grid(
    columns: (caption-left, text-width - caption-left),
    grid.cell(stroke: (right: caption-stroke, bottom: caption-stroke),
      inset: (right: cell-pad, bottom: row-pad), left-top),
    grid.cell(inset: (left: cell-pad, bottom: row-pad), right-top),
    grid.cell(stroke: (right: caption-stroke, bottom: caption-stroke),
      inset: (right: cell-pad, top: row-pad, bottom: caption-foot), left-bottom),
    grid.cell(inset: (left: cell-pad, top: row-pad, bottom: caption-foot), right-bottom),
  ))
  // The debtors' note sits under the caption, in the flow (not a page-foot footnote).
  if "footnote" in debtors {
    block(width: 100%, above: note-above, below: 0pt, {
      set text(size: note-size, ..edges(pitch-note))
      par(first-line-indent: 0pt, [\* #unloose(inl(debtors.footnote))])
    })
  }
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b), applied by FRBP 7010)
// ---------------------------------------------------------------------------

#let footnote-def = regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$")
#let footnote-ref = regex("\\[\\^([^\\]]+)\\]")

/// Inline content of a paragraph. Each `[^key]` becomes a footnote whose text is the definition `key`.
#let with-notes(t, notes) = {
  let out = []
  let rest = t
  let m = rest.match(footnote-ref)
  while m != none {
    out += unloose(inl(rest.slice(0, m.start)))
    out += footnote(unloose(inl(notes.at(m.captures.at(0)))))
    rest = rest.slice(m.end)
    // Markdown trims the leading space of the text after a footnote mark, so the space is put back here.
    if rest.starts-with(" ") {
      out += [ ]
      rest = rest.slice(1)
    }
    m = rest.match(footnote-ref)
  }
  out + unloose(inl(rest))
}

/// A body paragraph on the body pitch, its first line indented half an inch.
#let body-par(content, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Section headings on the body pitch, kept with the block after them: level 1 centred bold capitals; level 2
/// centred bold (Count titles); level 3 bold at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(unloose(inl(s))))) }
  else if level == 2 { align(center, strong(unloose(inl(s)))) }
  else { strong(unloose(inl(s))) }
})

/// A lettered list (KYEB-LIST-001): "a.", "b.", ... (the author writes "1." or "- " items), the letter half an inch
/// in, the text hanging after its box.
#let lettered(c, notes, sticky: false) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(?:-|\\*|\\+|\\d+\\.)\\s+(.*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, sticky: sticky and i == items.len() - 1, pad(left: para-indent,
      par(first-line-indent: 0pt, hanging-indent: item-box,
        [#box(width: item-box)[#numbering("a", i + 1).]#with-notes(it, notes)])))
  }
}

/// The body, one blank-line-separated chunk at a time. Rules (also in ../README.md):
/// - a `#` heading is centered (levels 1 and 2) or bold (level 3) and is kept with the chunk after it;
/// - a chunk in parentheses directly after a heading is its unnumbered subtitle (a Count's title);
/// - a list (`1. ` or `- `) is unnumbered; the template letters the items a., b., c.;
/// - paragraphs before the first heading (the lead-in), paragraphs starting WHEREFORE and paragraphs
///   ending in a colon (they introduce a list) are unnumbered;
/// - every other paragraph is numbered 1, 2, 3 ... in order; the author types no numbers.
#let body-blocks(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let numbering-on = false
  let after-heading = false
  let n = 0
  let last = chunks.filter(c => c.match(footnote-def) == none).len() - 1
  let k = -1
  for t in chunks {
    if t.match(footnote-def) != none { continue }
    k += 1
    // The last block is kept with the signature block after it.
    let keep = k == last
    if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
      numbering-on = true
      after-heading = true
      continue
    }
    if after-heading and t.starts-with("(") and t.ends-with(")") {
      block(width: 100%, above: 0pt, below: 0pt, sticky: true,
        align(center, par(first-line-indent: 0pt, unloose(inl(t)))))
      after-heading = false
      continue
    }
    after-heading = false
    if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      lettered(t, notes, sticky: keep)
    } else if numbering-on and not t.starts-with("WHEREFORE") and not t.ends-with(":") {
      n += 1
      body-par(sticky: keep)[#box(width: num-box)[#n.]#with-notes(t, notes)]
    } else {
      body-par(with-notes(t, notes), sticky: keep)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a): signed by an attorney in the attorney's name, with address and telephone)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  block(width: 100%, breakable: false, above: signature-above, below: 0pt, grid(
    columns: (text-width - signature-col, signature-col),
    line-block([Dated: #need(meta, "date")]),
    {
      line-block(inl(sig.firm))
      line-block(above: signature-gap, [By: /s/ #inl(sig.signer)])
      for l in sig.at("lines", default: ()) { line-block(inl(l)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let kyeb-adversary-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "chapter", "case_number", "jointly_administered", "title", "date", "signature") {
    let _ = need(meta, k)
  }
  // Footnote definitions, collected before the body is rendered (they may follow their reference).
  let notes = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(footnote-def)
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }

  // ---- document-wide settings ----
  // Every page numbered, bottom centre (KYEB-FORM-004); the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center + bottom, pad(bottom: footer-distance, text(..edges(pitch-single), counter(page).display()))),
  )
  set document(
    title: need(meta, "title").join(" ") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. No markdown list reaches typst's list
  // layout (the template letters the items itself).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled section sign stays with its number too ("§§ 1408"; the Word filter binds it too, bind_double): a no-break space after the signs.
  show regex("[§¶]{2,} "): it => it.text.trim() + "\u{00A0}"
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // ---- first page: court, caption, title ----
  {
    set text(..edges(pitch-single))
    court-title(meta)
    caption-table(meta)
    block(width: 100%, above: half-line, below: half-line, {
      for l in need(meta, "title") { line-block(center: true, strong(inl(l))) }
    })
  }

  // ---- body ----
  body-blocks(body, notes)

  signature-block(meta)
}
