// California Superior Court (calsuperct): civil complaint on pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119
// (see ../README.md and ../../rules.md for the rule numbers, URLs and the date each was verified). No case-specific
// text, no coordinates measured off a filed complaint, no forced line breaks. Every case word comes from the
// sample's frontmatter or its markdown body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/pleading-paper.typ": line-numbers as shared-line-numbers, pleading-rules as shared-pleading-rules
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters: each traces to a rule or is a named layout choice.
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // CRC 2.105: essentially equivalent to Times New Roman
#let type-size = 12pt              // CRC 2.104: not smaller than 12 points
#let page-w = 8.5in                // CRC 2.103: 8 1/2 by 11 inches
#let page-h = 11in
#let lines-per-page = 28           // numbered lines per page (pleading convention, tier 2; CRC 2.108(4): at least
                                   // three per vertical inch)
#let top-margin = 1in              // line 1 starts 1 inch from the top (CRC 2.111(1))
#let left-margin = 1.5in           // CRC 2.107: at least 1 inch; room for the line numbers and the rules
#let right-margin = 0.5in          // CRC 2.107: at least 1/2 inch
#let para-indent = 0.5in           // first-line indent of a paragraph
#let clerk-lines = 7               // CRC 2.111(2): lines 1-7 right of center are the clerk's; CRC 2.111(3): the court
                                   // title on line 8 or below
#let caption-col = 50%             // CRC 2.111(4): the case title left of the center of the page
#let caption-inset = 0.12in        // the party column's text stands off its right rule
#let caption-right = 0.2in         // the right column stands off the party column's rule
#let space-indent = 0.25em         // a caption line's leading spaces: an indent of this much per space
#let sig-col = 3.1in               // the signature column ("Dated:" at the margin, the rest from here)
#let sig-name = 0.3in              // the signer's name and role stand this far into the signature column
#let sig-rule = 2.7in              // the signature line after "By:"
#let footer-size = 10pt            // CRC 2.110(c): the footer title at least 10 points
#let number-size = 12pt            // the page number (CRC 2.109)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is set here (Word's exact
// line spacing; docx/calsuperct.lua sets the same twips).
#let pitch = 24pt                  // CRC 2.108(1): double spacing; the numbered lines are this pitch
#let pitch-single = 12pt           // CRC 2.108(3): single-spaced lines (attorney block, caption, signature, footnotes),
                                   // two to a numbered line
#let gap = pitch                   // between the groups of the caption's right column
// A group of single lines starts this far below a numbered line's top, so every other single line stands level with
// a line number.
#let single-drop = 0.8 * (pitch - pitch-single)
#let caption-foot = 6pt              // the party column's last line box to its bottom rule
#let caption-clear = pitch-single   // the caption's foot to the body: at least this, then the next numbered line
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let footer-gap = 2pt              // the last numbered line to the page number
#let footer-rule-gap = 4pt         // the page number to the footer rule (docx: an underlined tab in a 4 pt line)
#let footer-rule-pad = 0pt         // the footer rule to the title's line box
#let note-gap = 6pt                // between two footnotes
#let note-clearance = 12pt         // the body text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline markdown (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let as-list(v) = if v == none { () } else if type(v) == array { v } else { (v,) }

/// Single-spaced lines, one paragraph per item. An empty item is a blank single line; an item's leading spaces are
/// an indent of `space-indent` each (so a caption's "Plaintiff," and "v." stand where the filer put them).
#let line-stack(items, above: 0pt, weight: "regular") = block(width: 100%, above: above, below: 0pt, {
  // no widow or orphan rule: a column that runs over a page end breaks at the last line that fits (docx: the same)
  set text(..edges(pitch-single), weight: weight, costs: (widow: 0%, orphan: 0%))
  set par(first-line-indent: 0pt)
  for it in as-list(items) {
    let s = str(it)
    let m = s.match(regex("^( *)(.*)$"))
    let n = m.captures.at(0).len()
    if m.captures.at(1).trim() == "" {
      block(height: pitch-single)
    } else {
      block(pad(left: n * space-indent, inl(m.captures.at(1))))
    }
  }
})

// ---------------------------------------------------------------------------
// Pleading paper (CRC 2.108): numbers 1 to 28 down the left margin on the body's line boxes, a double rule left of
// the text and a single rule right of it; the footer (CRC 2.109, 2.110): the page number, below it a printed line,
// below that the paper's title.
// ---------------------------------------------------------------------------

#let line-numbers() = shared-line-numbers(left-margin, top-margin, pitch, lines-per-page, type-size, ..edges(pitch))

#let pleading-rules() = shared-pleading-rules(page-w, page-h, left-margin, right-margin)

#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-gap,
  block(width: page-w - left-margin - right-margin, {
    set par(first-line-indent: 0pt)
    set text(size: number-size, ..edges(pitch-single))
    align(center, context counter(page).display("1"))
    block(above: footer-rule-gap, below: 0pt, width: 100%, stroke: (top: 0.5pt), inset: (top: footer-rule-pad),
      align(center, text(size: footer-size, upper(title))))
  }),
)

// ---------------------------------------------------------------------------
// First page (CRC 2.111): attorney block from line 1, court title on line 8 or below, caption
// ---------------------------------------------------------------------------

/// CRC 2.111(1)-(2): the attorney block from line 1, left of center, one line per item (an item that does not fit
/// left of center stops the build: split it into two items); the court title on line 8, or on the first numbered
/// line below a longer block.
#let attorney-block(meta) = {
  let items = as-list(need(meta, "attorney"))
  layout(size => {
    for it in items {
      let w = measure(text(size: type-size, inl(str(it)))).width
      if w > size.width * caption-col {
        panic("calsuperct-complaint: the attorney line `" + str(it) + "` does not fit left of center (CRC 2.111(1)-(2)); split it")
      }
    }
  })
  let n = calc.max(clerk-lines, calc.ceil((single-drop + items.len() * pitch-single) / pitch))
  block(width: 100%, height: n * pitch, above: 0pt, below: 0pt, inset: (top: single-drop), line-stack(items))
}

/// CRC 2.111(3): the title of the court, centered, bold, one numbered line each.
#let court-title(meta) = {
  for l in as-list(need(meta, "court")) {
    block(width: 100%, align(center, text(weight: "bold", inl(str(l)))))
  }
}

/// CRC 2.111(4)-(9): the case title left of center (the column ruled at its right and foot), and to its right the
/// case number, the nature of the paper, the details and the amount demanded, a numbered line apart; one numbered
/// line below the court title.
#let caption(meta) = {
  let cap = need(meta, "caption")
  block(width: 100%, above: pitch, below: 0pt, grid(
    columns: (caption-col, 1fr),
    // The column may run over a page end: its space above and below are blocks (an inset would repeat on each page).
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset), {
      block(height: single-drop)
      line-stack(cap.at("left", default: ()))
      block(height: caption-foot)
    }),
    grid.cell(inset: (left: caption-right), {
      block(height: single-drop)
      let first = true
      for (key, weight) in (("case_number", "regular"), ("title", "bold"), ("details", "regular"), ("amount_demanded", "regular")) {
        if key in cap {
          line-stack(cap.at(key), above: if first { 0pt } else { gap }, weight: weight)
          first = false
        }
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Signature block: "Dated:" at the margin, the rest in the signature column; never split across pages
// ---------------------------------------------------------------------------

#let sig-row(lead, body, above: 0pt, indent: 0pt) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: sig-col + indent, { box(width: sig-col + indent, lead); body }))

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch, below: 0pt, breakable: false, inset: (top: single-drop), {
    set text(..edges(pitch-single))
    let lines = as-list(sig.at("lines", default: ()))
    let dated = if "dated" in sig [Dated: #inl(sig.dated)] else []
    for (k, l) in lines.enumerate() { sig-row(if k == 0 { dated } else { [] }, inl(str(l))) }
    if lines.len() == 0 { sig-row(dated, []) }
    sig-row([], box(width: sig-rule, [By: #box(width: 1fr, line(length: 100%, stroke: 0.5pt))]), above: pitch)
    sig-row([], strong(upper(inl(need(sig, "signer")))), indent: sig-name)
    if "role" in sig { sig-row([], inl(sig.role), indent: sig-name) }
  })
}

// ---------------------------------------------------------------------------
// The body: each blank-line-separated chunk of markdown is a heading or a paragraph (the author numbers the
// allegations). Footnote definitions are kept apart from the chunks: each chunk is rendered alone, with the
// definitions of the notes it refers to.
// ---------------------------------------------------------------------------

/// A body paragraph, its first line indented. One that anchors a footnote may leave a single line on a page (no
/// widow or orphan rule), so that the line with the mark moves on with its note (docx: Body Text Note).
#let body-par(note: false, c) = {
  set text(costs: (widow: 0%, orphan: 0%)) if note
  block(width: 100%, par(first-line-indent: (amount: para-indent, all: true), c))
}

#let body-pieces(body) = {
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
    .filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  chunks.map(t => {
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    // a heading in a block: its own space above and below is dropped at the ends of the block
    if t.starts-with("#") { block(width: 100%, sticky: true, render(t + defs)) } else { body-par(note: defs != "", render(t + defs)) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let calsuperct-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(need(meta, "footer_title")),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  set block(above: 0pt, below: 0pt)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes (CRC 2.108(3): may be single-spaced) at the type size, the mark, a space, the text (docx: Footnote
  // Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Headings, one numbered line each, kept with the text: levels 1 and 2 centered bold capitals; level 3 bold;
  // deeper levels bold italic.
  show heading: it => block(width: 100%, sticky: true, {
    set text(size: type-size, weight: "bold")
    if it.level <= 2 { align(center, upper(it.body)) } else if it.level == 3 { it.body } else { emph(it.body) }
  })

  attorney-block(meta)
  court-title(meta)
  caption(meta)
  // The body starts on the first numbered line at least caption-clear below the caption, wherever the party column
  // ended (docx/calsuperct.lua counts the column's lines to set the same space).
  context {
    let y = here().position().y
    let k = calc.ceil((y + caption-clear - top-margin) / pitch - 0.001)
    block(width: 100%, height: top-margin + k * pitch - y)
  }
  let pieces = body-pieces(body)
  if "jury_demand" in meta {
    pieces.push(block(width: 100%, above: pitch, align(center, strong(upper(inl(meta.jury_demand))))))
  }
  for p in pieces.slice(0, calc.max(0, pieces.len() - 1)) { p }
  // The last block stays whole with the signature block after it.
  block(width: 100%, breakable: false, {
    if pieces.len() > 0 { pieces.last() }
    signature-block(meta)
  })
}
