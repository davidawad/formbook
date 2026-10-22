// Motion with memorandum of law, United States Bankruptcy Court, District of the Virgin Islands (vib).
//
// Rule-driven and content-agnostic. Requirement IDs (VIB-MB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // VIB-MB-FONT: LBR 5005-1(B) names no face; Times New Roman (vendored, docs/FONTS.md), the exemplar's face
#let type-size = 12pt                    // VIB-MB-FONT: LBR 5005-1(B) "no smaller than 12 Courier or an equivalent"; 12 pt Times New Roman, footnotes and footer too
#let page-margin = 1in                   // VIB-MB-PAGE: letter paper, one-inch margins on every side
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                 // first-line indent of body paragraphs
#let level-step = 0.5in                  // VIB-MB-HEADINGS: each heading level below the second one step further in; the label's box
#let cap-left = 3.9in                    // VIB-MB-CAPTION: the caption's party column (Form 416), ruled right and below
#let cap-pad = 0.2in                     // the text off the caption's vertical rule, on both sides
#let cap-top = 6pt                       // a caption row's text below its top
#let cap-bottom = 10pt                   // a caption row's text above its rule
#let cap-rule = 0.75pt                   // the caption's rules
#let designation-indent = 0.5in          // "Debtor.", "Plaintiffs," and "Defendants." in from the party names
#let counsel-col = 2.3in                 // the cover's counsel blocks start here (lower right, as the filed brief)
#let sig-col = 3.0in                     // VIB-MB-SIGNATURE: the signature column starts here
#let toc-page-col = 36pt                 // contents: the page numbers keep the last 36 pt of the line
#let footer-page = 1.3in                 // the footer's "Page n of N" column, at the right; the short title wraps before it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vib-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                   // VIB-MB-SPACING: double spaced, as the exemplar
#let pitch-single = 13.8pt               // court header, caption, title, counsel, contents, headings, signature,
                                         // footnotes, footer
#let caption-above = 24pt                // the court header to the caption
#let title-above = 24pt                  // the caption to the title
#let counsel-above = 24pt                // the title to the first counsel block
#let counsel-gap = 13.8pt                // between two counsel blocks: a blank single line
#let toc-above = 24pt                    // the contents' title to its first row
#let row-gap = 12pt                      // between two rows of the contents
#let heading-gap = 12pt                  // above and below a heading
#let sig-above = 24pt                    // the last paragraph to "Dated:"
#let sig-gap = 13.8pt                    // a blank single line between the parts of the signature block
#let note-gap = 7pt                      // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 6pt                // the text to the footnote rule (LibreOffice reserves no more above a note)
// The footer: its last line box ends 0.3 in above the bottom edge and further lines stack upward, as Word sets a
// footer (docx: footer 432 twips); the footer area starts `footer-descent` below the text.
#let footer-descent = 6pt
#let footer-height = page-margin - footer-descent - 0.3in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("vib-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-pitch lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first; `left`: an indent of every line.
#let lines(items, above: 0pt, centered: false, left: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set align(center) if centered
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, pad(left: left, par(if type(i) == str { inl(i) } else { i })))
      gap = 0pt
    }
  }
}

/// The label of a numbered heading (the author never types numbers): level 2 is I., level 3 is A., level 4 is 1.,
/// level 5 is a. (VIB-MB-HEADINGS). Level 1 is unnumbered. Each level counts within the heading above it, whatever
/// its level (a level-3 heading under a level-1 section counts A., B., ...).
#let label-for(level, i) = {
  if level == 2 { numbering("I.", i) } else if level == 3 { numbering("A.", i) }
  else if level == 4 { numbering("1.", i) } else { numbering("a.", i) }
}
#let hcount = (counter("vib-h2"), counter("vib-h3"), counter("vib-h4"), counter("vib-h5"))
/// A heading's label from the counters after its own step (none for level 1 and below level 5).
#let heading-label(level, loc) = {
  if level == 1 or level > 5 { none } else { label-for(level, hcount.at(level - 2).at(loc).first()) }
}

// ---------------------------------------------------------------------------
// Cover: court header, caption, title, counsel (VIB-MB-CAPTION: Form 416 layout, FRBP 7010, 9004(b), LBR 7008-1(A))
// ---------------------------------------------------------------------------

#let court-header(meta) = lines(centered: true, (
  "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS",
  "DIVISION OF " + upper(need(meta, "division")) + ", BANKRUPTCY DIVISION",
).map(l => text(weight: "bold", l)))

/// A party: its names, then its designation in from them.
#let party(p) = {
  lines(p.names)
  lines((p.designation,), left: designation-indent)
}

/// The caption: two rows, the parties at the left in a column ruled on the right and below each row (Form 416), the
/// case information at the right: the chapter and case number beside the debtor, the adversary number (and a note)
/// beside the adversary parties.
#let caption-block(meta) = {
  let debtor = need(meta, "debtor")
  let adv = need(meta, "adversary")
  let sides = need(meta, "caption")
  let left-cell(body) = grid.cell(stroke: (right: cap-rule, bottom: cap-rule),
    inset: (top: cap-top, bottom: cap-bottom, right: cap-pad), body)
  let right-cell(body) = grid.cell(inset: (top: cap-top, bottom: cap-bottom, left: cap-pad), body)
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    left-cell({ lines(("In re:", "")); party(debtor) }),
    right-cell(lines((need(meta, "chapter"), "", "Case No. " + need(meta, "case_number")))),
    left-cell({ party(sides.at(0)); lines(("", "v.", "")); party(sides.at(1)) }),
    right-cell(lines(("Adv. Proc. No. " + adv.number,) + if "note" in adv { ("", adv.note) } else { () })),
  ))
}

/// The cover's counsel blocks, lower right (as the filed brief has them; LBR 9013-1, FRBP 9011): the firm in bold
/// capitals, then the lines; a blank single line between two blocks.
#let counsel-block(meta) = {
  for (i, g) in need(meta, "counsel").enumerate() {
    lines(above: if i == 0 { counsel-above } else { counsel-gap }, left: counsel-col,
      (text(weight: "bold", upper(g.firm)),) + g.lines)
  }
}

#let cover(meta) = {
  court-header(meta)
  caption-block(meta)
  lines(above: title-above, centered: true, (text(weight: "bold", upper(need(meta, "title"))),))
  counsel-block(meta)
}

// ---------------------------------------------------------------------------
// Table of contents: every heading of levels 1-4, dot leaders, page numbers
// ---------------------------------------------------------------------------

/// A contents row: the label in a `level-step` box after the level's step (a level-1 title at the first step), the
/// title hanging after it, a dot leader to the page in the page column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = calc.max(hd.level - 2, 0) * level-step
  // the counters at the heading's own location are those before its show rule steps them: its number is one more
  let lab = if hd.level == 1 or hd.level > 5 { none }
    else { label-for(hd.level, hcount.at(hd.level - 2).at(hd.location()).first() + 1) }
  block(width: 100%, above: row-gap, below: 0pt, {
    set text(..edges(pitch-single))
    listing-row(hd.location(), { h(ind); box(width: level-step, if lab == none [] else [#lab]); hd.body },
      it.page(), toc-page-col, ind + level-step, 0pt)
  })
}

#let toc-section() = {
  lines(centered: true, (text(weight: "bold", "TABLE OF CONTENTS"),))
  v(toc-above - row-gap)
  show outline.entry: toc-entry
  outline(title: none, depth: 4, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Signature block (VIB-MB-SIGNATURE, FRBP 9011 signing convention)
// ---------------------------------------------------------------------------

/// "Dated:" at the margin, "Respectfully submitted," in the signature column, then each counsel group ("/s/" the
/// signer and the lines), "- and –" between two groups; single-spaced, a blank single line between the parts.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  lines(([Dated: #need(meta, "date")],))
  lines(above: sig-gap, left: sig-col, ("Respectfully submitted,",))
  for (i, g) in need(meta, "signature").enumerate() {
    if i > 0 { lines(above: sig-gap, left: sig-col, ([\- and –],)) }
    let ls = if "signer" in g { ("/s/ " + g.signer,) } else { () }
    lines(above: sig-gap, left: sig-col, ls + g.lines)
  }
})

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let motion(meta, md) = {
  let short-title = upper(if "footer" in meta { meta.footer } else { need(meta, "title") })
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    // VIB-MB-PAGE: "Page n of N" at the right, the short title at the left (the exemplar's footer).
    footer-descent: footer-descent,
    footer: context block(width: 100%, height: footer-height, align(bottom, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      grid(columns: (1fr, footer-page),
        par(short-title),
        align(right + bottom, par[Page #counter(page).display() of #counter(page).final().first()]))
    })),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. Lists are laid out here.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("¶¶ 36"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size, single-spaced (docx: Footnote Text in 13.8 pt boxes, 7 pt after), a short rule above.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings single-spaced at the type size, 12 pt above and below, kept with the next block. Level 1 centred bold
  // capitals; below it the label in a `level-step` box after the level's step, the title hanging after it, levels 2
  // and 3 bold (VIB-MB-HEADINGS).
  show heading: it => {
    if it.level >= 2 and it.level <= 5 {
      hcount.at(it.level - 2).step()
      for k in range(it.level - 1, 4) { hcount.at(k).update(0) }
    }
    context {
      let lab = heading-label(it.level, here())
      block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, breakable: false, {
        set text(size: type-size, weight: "regular", ..edges(pitch-single))
        set par(first-line-indent: 0pt)
        if it.level == 1 {
          align(center, par(text(weight: "bold", upper(it.body))))
        } else {
          let body = if it.level <= 3 { text(weight: "bold", it.body) } else { it.body }
          pad(left: calc.max(it.level - 2, 0) * level-step, par(hanging-indent: level-step,
            [#box(width: level-step, if lab == none [] else [#lab])#body]))
        }
      })
    }
  }

  cover(meta)
  pagebreak()
  toc-section()
  pagebreak()

  // The body, then the signature block; the last paragraph is kept on one page with the signature (a signature never
  // stands alone on a page). Footnote definitions stay with the rest of the body.
  let chunks = md.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let is-def(c) = c.trim().match(regex("^\\[\\^\\w+\\]:")) != none
  let last = chunks.len() - 1
  while last >= 0 and is-def(chunks.at(last)) { last -= 1 }
  assert(last >= 0 and not chunks.at(last).trim().starts-with("#"),
    message: "vib-motion-brief: the body must end with a paragraph (the signature is set with it)")
  let tail = chunks.at(last)
  assert(tail.match(regex("\\[\\^\\w+\\]")) == none,
    message: "vib-motion-brief: the last paragraph (set with the signature) may not carry a footnote")
  let head = chunks.slice(0, last) + chunks.slice(last + 1)
  cmarker.render(head.join("\n\n"), raw-typst: false, smart-punctuation: true, set-document-title: false)
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, {
    par(inl(tail))
    signature-block(meta)
  })
}
