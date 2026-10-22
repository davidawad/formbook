// U.S. Navy-Marine Corps Court of Criminal Appeals: appellant's brief and assignments of error.
//
// Rule-driven and content-agnostic. Requirement IDs (NMCCA-...) refer to ../README.md, which cites
// the NMCCA Rules of Appellate Procedure (2022) and Appendix I. No case-specific text, no
// coordinates measured off any filed brief, no forced line breaks. The markdown body is rendered
// by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): this render is the
// reference the docx engine (../docx/nmcca.lua) breaks every line and page alike with. Every line is a box of its
// pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the two
// explicit spaces (dropped at the top of a page). The numbers below are the docx filter's too (pt x 20 = twips).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Mono"       // the face data/exemplar-fonts.json audits for the filed exemplar (Courier New metrics; `fb lint fonts` requires it). NMCCA-FORM-001 (Rule 17(c)) bars Courier and similar non-proportional type: an open question for David (README).
#let type-size = 14pt                      // NMCCA-FORM-001: 14-point type, footnotes included.
#let pitch-double = 33.6pt                 // NMCCA-FORM-002: double-spaced body, 2 x the single pitch.
#let pitch-single = 16.8pt                 // single pitch (1.2 em): caption, headings, index, quotations, footnotes, signature blocks.
#let side-margin = 1in                     // NMCCA-FORM-003 (margins are not stated; 1 inch is conventional).
#let top-margin = 1in
#let bottom-margin = 1in + 4pt             // NMCCA-FORM-003: 1 inch bottom margin after the first page (+4 pt: footnote descenders stay above it, DEF-FORM-002).
#let first-page-bottom-margin = 2in        // NMCCA-FORM-003: first page, for filing stamps.
#let para-indent = 0.5in
#let label-box = 28.35pt                   // heading labels (I., A., 1., a., (1)): the text hangs after them
#let toc-indent = 21pt                     // index: level-2 entries
#let toc-page-col = 36pt                   // index: the page numbers keep the last 36 pt of the line to themselves
#let space = (
  section: 19.6pt,                         // above a level-1 heading
  sub: 15.4pt,                             // above a deeper heading
  quote: 11.2pt,                           // above and below a block quotation
  note-gap: 7pt,                           // between two footnotes
  note-clearance: 12.6pt,                  // between the body and the footnote rule
  toc-row: 8.4pt,                          // between two index entries
  cover-small: 16.8pt,                     // between the parts of the caption: a blank single line, so both columns keep one line grid
  cover-mid: 16.8pt,                       // after the court name, before the tried-at paragraph
  cover-large: 25.2pt,                     // around the caption
  sig: 16.8pt,                             // above "Respectfully submitted."
  sig-line: 33.6pt,                        // above the signature line
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("nmcca-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmcca-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// True when the level-1 section that contains `loc` is the Argument (NMCCA-CONT-004).
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// A single-spaced line (or lines) as its own block, `above` the space before it.
#let line-block(above, body, align-to: left, inset: 0pt) = block(above: above, below: 0pt, width: 100%,
  pad(left: inset, align(align-to, par(first-line-indent: 0pt, body))))

/// The signature line: 3 in, drawn under the baseline of a single-spaced line box (Word: an underlined tab).
#let signature-line(above) = block(above: above, below: 0pt, width: 100%, height: pitch-single,
  place(top + left, dx: 3in, dy: 0.8 * pitch-single + 1.5pt, line(length: 3in, stroke: 0.5pt)))

// ---------------------------------------------------------------------------
// Cover (Appendix I, first page; NMCCA-FORM-004)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set text(..edges(pitch-single))
  line-block(0pt, strong[IN THE UNITED STATES NAVY-MARINE CORPS], align-to: center)
  line-block(0pt, strong[COURT OF CRIMINAL APPEALS], align-to: center)
  line-block(space.cover-mid, [Before #inl(need(meta, "panel"))], align-to: center)
  block(above: space.cover-large, below: 0pt, width: 100%, grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    {
      line-block(0pt, inl(need(meta, "appellee")))
      line-block(space.cover-small, inl(need(meta, "appellee_role")), align-to: center)
      line-block(space.cover-small, [v.])
      line-block(space.cover-small, inl(need(meta, "appellant")))
      for l in need(meta, "appellant_lines") { line-block(0pt, emph(inl(l))) }
      line-block(space.cover-small, inl(need(meta, "appellant_role")), align-to: center)
    },
    {
      line-block(0pt, [NMCCA No. #inl(need(meta, "nmcca_no"))])
      line-block(space.cover-small, strong(upper(inl(need(meta, "title")))))
    },
  ))
  line-block(space.cover-large, strong[TO THE HONORABLE, THE JUDGES OF THE UNITED STATES], align-to: center)
  line-block(0pt, strong[NAVY-MARINE CORPS COURT OF CRIMINAL APPEALS], align-to: center)
  line-block(space.cover-mid, inl(need(meta, "tried_at")))
  // Counsel: at the foot of the cover, in the right half from 3 in (Appendix I).
  place(bottom + left, dx: 3in, block(width: 100% - 3in, {
    for l in need(meta, "counsel") { line-block(0pt, inl(l)) }
  }))
}

// ---------------------------------------------------------------------------
// Signature block and certificate (Appendix I; NMCCA-FORM-008, NMCCA-FORM-009)
// ---------------------------------------------------------------------------

#let signature-lines(meta) = {
  let sig = need(meta, "signature")
  line-block(0pt, inl(sig.signer), inset: 3in)
  for l in sig.lines { line-block(0pt, emph(inl(l)), inset: 3in) }
}

#let signature-block(meta) = {
  set text(..edges(pitch-single))
  line-block(space.sig, [Respectfully submitted.], inset: 3in)
  signature-line(space.sig-line)
  signature-lines(meta)
}

#let certificate(meta) = {
  pagebreak(weak: true)
  set text(..edges(pitch-single))
  line-block(0pt, strong[CERTIFICATE OF FILING AND SERVICE], align-to: center)
  block(above: space.cover-mid, below: 0pt, breakable: false, {
    set text(..edges(pitch-double))
    par(first-line-indent: (amount: para-indent, all: true))[I certify that the foregoing was delivered to the Navy-Marine Corps Court of Criminal Appeals, and that a copy was served on #inl(need(meta, "served_on")) on #inl(need(meta, "date")).]
    set text(..edges(pitch-single))
    signature-line(space.sig-line)
    signature-lines(meta)
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/// The required level-1 sections (NMCCA-CONT-001). Issues may be titled either way (see README).
#let required-sections = (
  "statement of statutory jurisdiction",
  "statement of the case",
  "statement of facts",
  "summary of argument",
  "argument",
  "conclusion",
)

/// Headings that take no label and do not advance the count (the filed brief leaves them bare;
/// "Discussion" is followed by the labelled A., B. sub-headings).
#let unlabelled = ("standard of review", "principles of law", "discussion", "conclusion")

/// The label of every heading, in document order (NMCCA-CONT-004). Labels are computed from a
/// query of all headings, so an unlabelled heading does not shift the numbering of the others.
/// Must be called inside `context`.
#let heading-labels() = {
  let counts = (0, 0, 0, 0, 0, 0)
  let arg = false
  let out = ()
  for h in query(heading) {
    let t = lower(plain(h.body)).trim()
    let lvl = h.level
    if lvl == 1 {
      arg = t == "argument"
      counts = (0, 0, 0, 0, 0, 0)
      out.push(none)
      continue
    }
    if lvl > 5 { panic("nmcca-opening-brief: headings deeper than level 5 are not supported") }
    for j in range(lvl + 1, 6) { counts.at(j) = 0 }
    if t in unlabelled {
      out.push(none)
      continue
    }
    counts.at(lvl) = counts.at(lvl) + 1
    let pat = if arg { ("I.", "A.", "1.", "a.").at(lvl - 2) } else { ("A.", "1.", "a.", "(1)").at(lvl - 2) }
    out.push(numbering(pat, counts.at(lvl)))
  }
  out
}

/// The label of heading `h` (none for level 1 and the bare headings). Inside `context`.
#let label-of(h) = {
  let loc = h.location()
  heading-labels().at(query(heading).position(x => x.location() == loc))
}

/// Level-2 headings of the Argument are its points: bold italic (NMCCA-CONT-004, Appendix I).
#let heading-text(h) = {
  if h.level == 2 and in-argument(h.location()) { strong(emph(h.body)) } else { strong(h.body) }
}

#let style-heading(it) = context {
  set text(size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  if it.level == 1 {
    // A section: centered bold capitals.
    block(above: space.section, below: 0pt, width: 100%, sticky: true,
      align(center, strong(upper(it.body))))
  } else {
    let lab = label-of(it)
    block(above: space.sub, below: 0pt, width: 100%, sticky: true, if lab == none {
      heading-text(it)
    } else {
      par(hanging-indent: label-box, { box(width: label-box, strong(lab)); heading-text(it) })
    })
  }
}

/// The Index of Brief (NMCCA-CONT-001(b)(1)): the level-1 and level-2 headings with their body pages.
#let index-of-brief() = {
  set text(..edges(pitch-single))
  line-block(0pt, strong[INDEX OF BRIEF], align-to: center)
  context {
    let labels = heading-labels()
    let first = true
    for (i, hd) in query(heading).enumerate() {
      if hd.level > 2 { continue }
      let lab = labels.at(i)
      let ind = if hd.level == 1 { 0pt } else { toc-indent }
      let lw = if lab == none { 0pt } else { label-box }
      let page = numbering("1", ..counter(page).at(hd.location()))
      listing-row(hd.location(), {
        h(ind)
        if lab != none { box(width: label-box, lab) }
        hd.body
      }, page, toc-page-col, ind + lw, if first { space.cover-mid } else { space.toc-row })
      first = false
    }
  }
}

#let nmcca-opening-brief(meta, body) = {
  set document(title: "NMCCA " + need(meta, "nmcca_no") + " " + need(meta, "title"))
  // The page number: centered in a single-spaced line box (Word's footer), lower roman on the index, arabic after.
  set page(
    paper: "us-letter",
    margin: (top: top-margin, left: side-margin, right: side-margin, bottom: bottom-margin),
    numbering: none,
    footer-descent: 30%,
    footer: context {
      let n = here().page-numbering()
      if n != none { align(center, text(..edges(pitch-single), counter(page).display(n))) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set block(spacing: 0pt)
  // The cross-engine layout model: first fit, no kerning or ligatures, no hyphenation, line boxes of the body
  // pitch, footnote marks at 58 %, lists with the number in a half-inch box.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // LibreOffice (the docx engine's PDF) sets a face's standard ligatures and ignores w14:ligatures, so typst sets them
  // too (Liberation Mono has none); footnote marks are scaled and raised as LibreOffice does, not a face's sups glyphs.
  set text(ligatures: true)
  set super(typographic: false)
  // No widow or orphan control in either engine: typst's is a cost that footnotes can override, LibreOffice's a rule,
  // so the two would break pages apart (docx: w:widowControl off).
  set text(costs: (widow: 0%, orphan: 0%))
  set par(first-line-indent: para-indent)   // NMCCA-FORM-002: a paragraph that follows another is indented
  set heading(numbering: none)
  // Footnotes: 14 pt (NMCCA-FORM-001), single-spaced, the mark then a space (as Word's footnote).
  set footnote.entry(gap: space.note-gap, clearance: space.note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // the entries are laid out with the page's styles, outside the xengine rule: its settings again
    set text(size: type-size, ..edges(pitch-single), hyphenate: false, kerning: false, ligatures: true)
    set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, hanging-indent: 0pt, linebreaks: "simple", justify: false)
    super(num) + [ ] + note.body
  }
  show quote.where(block: true): it => block(above: space.quote, below: space.quote,
    pad(left: para-indent, right: para-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))
  // Headings: level 1 is a centered bold capital section; deeper levels are labelled per
  // NMCCA-CONT-004 (Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1)).
  show heading: style-heading

  // 1. Cover: its own first page, with the 2-inch bottom margin (NMCCA-FORM-003). Unnumbered.
  page(margin: (top: top-margin, left: side-margin, right: side-margin, bottom: first-page-bottom-margin),
    numbering: none, cover(meta))

  // 2. Index of Brief (NMCCA-CONT-001(b)(1)): generated from the headings, with page references; the cover is
  //    counted, so the index is page ii.
  set page(numbering: "i")
  index-of-brief()

  // 3. Body, numbered from 1. Cover and index are not counted in the page numbers of the body.
  pagebreak()
  counter(page).update(1)
  set page(numbering: "1")
  // Required sections must be present (NMCCA-CONT-001), in either the 2013 or the 2022 wording of issues.
  context {
    let names = query(heading.where(level: 1)).map(h => lower(plain(h.body)).trim())
    for req in required-sections {
      if req not in names { panic("nmcca-opening-brief: missing required section `" + req + "`") }
    }
    if "issue(s) presented" not in names and "assignments of error" not in names {
      panic("nmcca-opening-brief: missing required section `Issue(s) Presented` or `Assignments of Error`")
    }
    let subs = query(heading).map(h => lower(plain(h.body)).trim())
    if not subs.any(s => s.contains("standard of review")) {
      panic("nmcca-opening-brief: a `Standard of Review` heading is required in the Argument (NMCCA-CONT-005)")
    }
  }
  // The signature block never stands alone on a page: the brief's last paragraph is kept with it. Footnote
  // definitions (at the end of the markdown) go with both parts; each part renders the ones it references.
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
  let blocks = body.trim(at: end).split(regex("\n[ \t]*\n"))
  let notes = blocks.filter(b => b.trim().starts-with("[^"))
  let text-blocks = blocks.filter(b => not b.trim().starts-with("[^"))
  let tail = text-blocks.last()
  let keep = not tail.trim().starts-with("#")
  let note-md = "\n\n" + notes.join("\n\n", default: "")
  if keep {
    // the last paragraph is indented when it follows a paragraph (not a heading, list or quotation)
    let prev = if text-blocks.len() > 1 { text-blocks.at(-2).trim() } else { "#" }
    let after-par = prev.match(regex("^(#|>|[-*+] |\\d+[.)] )")) == none
    render(text-blocks.slice(0, -1).join("\n\n") + note-md)
    block(breakable: false, {
      set par(first-line-indent: (amount: para-indent, all: after-par))
      render(tail + note-md)
      signature-block(meta)
    })
  } else {
    render(text-blocks.join("\n\n") + note-md)
    block(breakable: false, signature-block(meta))
  }

  certificate(meta)
}
