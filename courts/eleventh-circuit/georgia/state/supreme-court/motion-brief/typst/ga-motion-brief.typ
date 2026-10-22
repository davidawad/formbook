// Supreme Court of Georgia: motion or response to a motion (Ga. Sup. Ct. R. 20, 26).
//
// Rule-driven and content-agnostic. Requirement IDs (GA-SC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed petition, no forced
// line breaks. The markdown body is rendered by cmarker; metadata comes from the YAML
// frontmatter of the sample (schema: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ga-motion.lua sets the same twips, 20 x pt).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // GA-SC-FONT-001: a proportionally spaced serif (Rule 16(1)); the filed exemplars' face (docs/FONTS.md rule 6)
#let type-size = 13pt                      // GA-SC-FONT-002: body and headings no smaller than 13 point (Rule 16(2))
#let note-size = 11pt                      // GA-SC-FONT-002: footnotes no smaller than 11 point (Rule 16(2))
#let page-margin = 1in                     // GA-SC-MARGIN-001: at least one inch top, bottom and sides (Rule 16(5))
#let para-indent = 0.5in
#let toc-depth = 3

// Pitches (GA-SC-SPACE-001, Rule 16(4): between 1.2 times and double; block quotations, headings, captions and
// footnotes may be single-spaced).
#let pitch-body = 19.5pt                   // 1.5 x the type size: body paragraphs, contents rows, questions presented
#let pitch-single = 15.9pt                 // 1.22 x the type size: cover, headings, quotations, signature, certificate lines, page number
#let pitch-note = 13.5pt                   // 1.23 x the footnote size
#let para-gap = 7.8pt                      // between body paragraphs (0.6 x the type size; style choice)
#let h1-above = 19.5pt                     // a level-1 heading: a body line above it
#let h1-below = 9.75pt                     // and half a body line below it
#let h-above = 15.6pt                      // a level-2 or level-3 heading
#let h-below = 7.8pt
#let quote-gap = 9.75pt                    // around a block quotation and between its paragraphs
#let note-gap = 6pt                        // between footnotes
#let note-clearance = 8.95pt               // above the footnote rule: with note-gap, Word's separator line (13 pt single, 14.95 pt)
#let footer-descent = 21.6pt               // the page-number line's top below the text area (Word's footer distance 34.5 pt)
#let rule-stroke = 0.75pt                  // the cover's rules
#let cap-left = 3.2in                      // caption: the parties' column
#let cap-paren = 0.3in                     // caption: the column of the close-parenthesis
#let counsel-gutter = 15.6pt               // cover: between the two columns of counsel
#let served-gutter = 13pt                  // certificate of service: between the two columns of the served
#let row-gap = 13pt                        // between the rows of those columns
#let toc-col = 36pt                        // contents: the page column
#let sig-width = 4.2in                     // the signature block's measure

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ga-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ga-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A block of single lines, `above` and `below` it (pt).
#let line-block(above: 0pt, below: 0pt, sticky: false, pitch: pitch-single, body) = block(width: 100%,
  above: above, below: below, sticky: sticky, {
    set text(..edges(pitch))
    set par(first-line-indent: 0pt)
    body
  })

/// A full-width rule, `above` it: below a 1 pt line, as Word draws a paragraph's bottom border.
#let rule(above) = block(width: 100%, above: above, below: 0pt, height: 1pt + rule-stroke,
  place(top + left, dy: 1pt + rule-stroke / 2, line(length: 100%, stroke: rule-stroke)))

/// Columns of groups of single lines (names, then lines), two to a row, `gutter` apart, `row-gap` between rows.
#let groups(gs, gutter) = {
  let n = calc.min(gs.len(), 2)
  let rows = calc.ceil(gs.len() / n)
  let cell(i) = if i >= gs.len() { [] } else {
    let g = gs.at(i)
    block(width: 100%, above: 0pt, below: 0pt, breakable: false,
      inset: (bottom: if calc.floor(i / n) < rows - 1 { row-gap } else { 0pt }), {
        for x in g.at("names", default: ()) { line-block(inl(x)) }
        for x in g.at("lines", default: ()) { line-block(inl(x)) }
      })
  }
  let cols = if n == 1 { (1fr,) } else { (1fr, gutter, 1fr) }
  grid(columns: cols, ..range(rows).map(r => if n == 1 { (cell(r),) } else { (cell(2 * r), [], cell(2 * r + 1)) }).flatten())
}

// ---------------------------------------------------------------------------
// Cover page (Rule 16 applies; no page number on the cover)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  line-block(align(center, strong(need(meta, "case_number"))))
  line-block(above: 15.6pt, align(center, strong[IN THE]))
  line-block(align(center, strong[SUPREME COURT OF GEORGIA]))

  // Caption: names on the left, a close-parenthesis column, the docket on the right (each centered on the rows).
  let sides = need(meta, "caption")
  let left = {
    for (i, side) in sides.enumerate() {
      for (j, n) in side.at("names").enumerate() {
        line-block(above: if j == 0 and i > 0 { 15.6pt } else { 0pt }, inl(n))
      }
      line-block(above: 5.2pt, align(right, inl(side.at("designation"))))
      if i < sides.len() - 1 { line-block(above: 15.6pt, align(center, inl("v."))) }
    }
  }
  block(width: 100%, above: 19.5pt, below: 0pt, grid(
    columns: (cap-left, cap-paren, 1fr),
    align: horizon,
    left,
    line-block(align(center)[)]),
    { for d in need(meta, "docket") { line-block(inl(d)) } },
  ))
  rule(19.5pt)
  // Title and filer: the cover title is set in capitals and wraps naturally.
  line-block(above: 11.7pt, align(center, strong(upper(inl(need(meta, "title"))))))
  if "filed_by" in meta { line-block(above: 7.8pt, align(center, inl(meta.at("filed_by")))) }
  rule(11.7pt)

  // Counsel: groups side by side, as the exemplar sets them (not a rule-mandated layout).
  block(width: 100%, above: 15.6pt, below: 0pt, groups(need(meta, "counsel"), counsel-gutter))
  line-block(above: 15.6pt, align(center, strong(inl(need(meta, "attorneys_for")))))
}

// ---------------------------------------------------------------------------
// Questions presented (a petition: Rule 41(2), before the table of contents; a motion has none)
// ---------------------------------------------------------------------------

#let questions-page(meta) = {
  line-block(below: 13pt, align(center, strong[QUESTIONS PRESENTED]))
  for (i, q) in need(meta, "questions_presented").enumerate() {
    block(width: 100%, above: if i == 0 { 0pt } else { pitch-body }, below: 0pt, {
      set text(..edges(pitch-body))
      par(first-line-indent: 0pt, hanging-indent: para-indent)[#box(width: para-indent)[#str(i + 1).]#inl(q)]
    })
  }
}

// ---------------------------------------------------------------------------
// Table of contents (rows of the body pitch: the text wraps before a page column, a dot leader to the number)
// ---------------------------------------------------------------------------

#let contents() = {
  line-block(below: 10.4pt, align(center, strong[TABLE OF CONTENTS]))
  context {
    for h in query(heading.where(outlined: true)) {
      if h.level <= toc-depth {
        let page = str(counter(page).at(h.location()).first())
        block(width: 100%, above: 0pt, below: 0pt, {
          set text(..edges(pitch-body))
          listing-row(h.location(), h.body, page, toc-col, 0pt, 0pt)
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Rule 20(7): the word-count certification sits immediately above it)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  line-block(above: 19.5pt, [This submission does not exceed the word-count limit imposed by Rule 20.])
  if "date" in meta { line-block(above: 15.9pt, inl(meta.at("date"))) }
  line-block(above: 10.4pt, [Respectfully submitted,])
  block(width: sig-width, above: 13pt, below: 0pt, {
    line-block[/s/ #sig.at("signer")]
    line-block(upper(sig.at("signer")))
    for l in sig.at("lines") { line-block(inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (Rule 20(6): excluded from the count)
// ---------------------------------------------------------------------------

#let service-certificate(meta) = {
  let svc = need(meta, "service")
  pagebreak()
  heading(level: 1, outlined: true, numbering: none)[Certificate of Service]
  block(width: 100%, above: 0pt, below: 0pt, par(inl(svc.at("statement"))))
  block(width: 100%, above: 10.4pt, below: 0pt, groups(svc.at("served"), served-gutter))
  if "note" in svc { block(width: 100%, above: 10.4pt, below: 0pt, par(inl(svc.at("note")))) }
  let signer = need(meta, "signature").at("signer")
  line-block(above: 19.5pt)[/s/ #signer]
  line-block(upper(signer))
}

// ---------------------------------------------------------------------------
// The body: the markdown, its last paragraph kept with the signature block
// ---------------------------------------------------------------------------

/// The body's blocks split at blank lines; the last block that is not a footnote definition is set with the
/// signature block in one unbreakable block (the closing never stands alone on a page). Footnote definitions go
/// with both parts (cmarker sets only the notes a part refers to).
#let body-with-tail(body, tail) = {
  let blocks = body.trim().split(regex("\r?\n[ \t]*\r?\n")).filter(b => b.trim() != "")
  let is-note(b) = b.starts-with("[^")
  let notes = blocks.filter(is-note).join("\n\n", default: "")
  let idx = blocks.enumerate().filter(p => not is-note(p.at(1))).last().at(0)
  let last = blocks.at(idx)
  let main = blocks.slice(0, idx).filter(b => not is-note(b))
  let render(s) = cmarker.render(s + "\n\n" + notes, raw-typst: false, smart-punctuation: true)
  render(main.join("\n\n"))
  // the last block is indented as typst indents it in the flow: after a paragraph, not after a heading or quotation
  let prev = main.at(-1, default: "")
  let after-par = not (prev.starts-with("#") or prev.starts-with(">") or prev.match(regex("^([-*+]|[0-9]+[.)]) ")) != none)
  block(width: 100%, breakable: false, above: para-gap, below: 0pt, {
    set par(first-line-indent: (amount: para-indent, all: after-par))
    render(last)
    tail
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ga-motion-brief(meta, body) = {
  set document(title: upper(need(meta, "title")), author: "")
  set page(paper: "us-letter", margin: page-margin, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: para-indent)
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 21-2-385(b)"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Headings: level 1 centered bold; level 2 bold; level 3 bold italic. Single lines, kept with the text after them.
  show heading: set text(size: type-size)
  show heading: it => {
    let (above, below, body) = if it.level == 1 { (h1-above, h1-below, align(center, strong(it.body))) }
      else if it.level == 2 { (h-above, h-below, strong(it.body)) }
      else { (h-above, h-below, strong(emph(it.body))) }
    line-block(above: above, below: below, sticky: true, body)
  }

  // Block quotations: single lines, half an inch in on both sides.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: quote-gap)
    pad(left: para-indent, right: para-indent, it.body)
  })
  // Rule 17(3): e-filed documents carry no hyperlinks to other documents or external sites.
  // A link keeps its text and loses its target; outline entries (internal) are unaffected.
  show link: it => if type(it.dest) == location { it } else { it.body }

  // Footnotes: 11 pt single lines; the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Cover (no number), then the questions presented (a petition), the table of contents and body, numbered from 1.
  cover(meta)

  // Rule 21: every counted page is numbered in Arabic numerals, from the first page after the cover.
  // The cover is the only unnumbered page. The number sits in a single line below the text area.
  set page(footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  counter(page).update(1)
  if "questions_presented" in meta {
    questions-page(meta)
    pagebreak()
  }
  contents()
  pagebreak()

  {
    set par(spacing: para-gap)
    body-with-tail(body, signature(meta))
  }
  service-certificate(meta)
}
