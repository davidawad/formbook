// Complaint for the U.S. District Court for the Middle District of Pennsylvania (pamd).
// Rules: M.D. Pa. LR 5.1 (form: 14 point type, double spacing, one inch margins), LR 5.2 (personal
// identifiers, author's responsibility), LR 8.1 (no specific sum for unliquidated damages); Fed. R.
// Civ. P. 8(a), 10(a)-(b), 38(b). See ../README.md for the quoted text and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // LR 5.1 names no face; Times New Roman (vendored, docs/FONTS.md)
#let type-size = 14pt                   // LR 5.1(c): typeface not smaller than 14 point
#let footer-size = 12pt                 // the page number, in the margin (LR 5.1(c): page numbers in the margins)
#let margin-all = 1in                   // LR 5.1(c): margins at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-indent = 0.5in              // a lettered item "(a)" starts half an inch in ...
#let letter-box = 0.4in                 // ... its letter in a box of its own; the text hangs 0.9 in from the margin
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-colon = 0.4in              // the column of ":" marks between the parties and the right column
#let sig-col = 2.8in                    // the signature column starts here (the date at the left of its first line)
#let sig-rule = 3.2in                   // the signature line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pamd-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 32pt                  // LR 5.1(c): double-spaced; 32 pt is the pitch of the 14 pt filed exemplars
#let pitch-single = 16pt                // single spacing (LR 5.1(c): headings may be single-spaced): court title,
                                        // caption (one line per caption row), signature
#let pitch-footer = 13.8pt              // the 12 pt page number's single line
#let caption-above = 16pt               // the court title to the caption: a blank single line
#let title-above = 32pt                 // the caption to the title
#let text-above = 16pt                  // the title to the text
#let sig-above = 32pt                   // the last paragraph to the signature block
#let rule-above = 16pt                  // "Respectfully submitted," to the signature line's box
#let lines-above = 6pt                  // the signature line to the signer's lines
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin-all - 0.5in - pitch-footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, citations with section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each. `above`: the space before the first line. An item is a string
/// (markdown) or content; `align`: the lines' alignment.
#let line-stack(items, above: 0pt, align: left) = {
  set text(..edges(pitch-single))
  set std.align(align)
  set par(first-line-indent: 0pt)
  for (k, i) in items.enumerate() {
    block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt,
      par(unloose(if type(i) == str { inl(i) } else { i })))
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(content)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 5.1; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title = line-stack(("IN THE UNITED STATES DISTRICT COURT", "FOR THE MIDDLE DISTRICT OF PENNSYLVANIA"),
  align: center)

/// The caption: one single line per row of the sample's `caption` (`left`, the party text, `indent` in inches;
/// `right`, the right column: the civil action number, the jury demand), a ":" on every row between them.
#let caption(meta) = {
  // every row a single line's box, an empty one too (an empty paragraph has no line of its own)
  let rows(items, align: left) = {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    for i in items { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt, std.align(align, par(i))) }
  }
  let cap = meta.caption
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-colon, 1fr),
    rows(cap.map(r => [#h(r.at("indent", default: 0) * 1in)#unloose(inl(r.at("left", default: "")))])),
    rows(cap.map(_ => [:]), align: center),
    rows(cap.map(r => unloose(inl(r.at("right", default: ""))))),
  ))
}

#let title(meta) = line-stack(above: title-above, (text(weight: "bold", upper(meta.title)),), align: center)

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lettered lists, signature block
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept whole and with the block after
/// them: level 1 centred bold capitals; level 2 centred bold; level 3 bold italic at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
  set align(center) if level <= 2
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) })
})

/// A lettered item "(a)": the letter half an inch in, in a box of its own, the text hanging after it (docx: a tab
/// and a hanging indent).
#let lettered(label, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: letter-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box, [#box(width: letter-box, label)#unloose(inl(s))])))

/// The signature block, single-spaced: "Date:" at the left of the first line and "Respectfully submitted," in a
/// column from `sig-col` (docx: a tab and a hanging indent), the signature line, the signer's lines.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let date = if "date" in meta and meta.date != none [Date: #meta.date] else []
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
    [#box(width: sig-col, date)Respectfully submitted,]))
  block(above: rule-above, below: 0pt, pad(left: sig-col,
    block(width: sig-rule, height: pitch-single, stroke: (bottom: 0.5pt))))
  for (k, l) in meta.signature.lines.enumerate() {
    block(width: 100%, above: if k == 0 { lines-above } else { 0pt }, below: 0pt,
      pad(left: sig-col, par(first-line-indent: 0pt, unloose(inl(l)))))
  }
})

/// The body, chunk by chunk (blank-line separated). A `#` chunk is a heading (levels 1 to 3); a chunk of `1.` items
/// is a lettered list, "(a)", "(b)", ...; a chunk marked with a leading "^" is an unnumbered paragraph (the
/// WHEREFORE clause, the jury demand); every other chunk is a numbered paragraph (Fed. R. Civ. P. 10(b)). The last
/// piece is set with `closing` (the signature block) in one unbreakable block, so the signature never stands alone.
#let body-chunks(body, closing) = {
  let n = 0
  let pieces = ()
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      pieces.push(heading-block(calc.min(level, 3), t.slice(level).trim()))
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      // one item per "1." line; a line without a number continues the item before it
      let items = ()
      for l in t.split(regex("\\r?\\n")) {
        if l.match(regex("^\\d+\\.[ \\t]")) != none { items.push(l.replace(regex("^\\d+\\.[ \\t]+"), "")) }
        else { items.last() += " " + l.trim() }
      }
      for (k, s) in items.enumerate() { pieces.push(lettered("(" + numbering("a", k + 1) + ")", s)) }
    } else if t.starts-with("^") {
      pieces.push(body-par(inl(t.slice(1).trim())))
    } else {
      n += 1
      pieces.push(body-par[#box(width: number-box)[#n.]#unloose(inl(t))])
    }
  }
  for (i, it) in pieces.enumerate() {
    if i == pieces.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { it; closing })
    } else { it }
  }
}

#let pamd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt,
      text(size: footer-size, ..edges(pitch-footer), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 1331"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title
  caption(meta)
  title(meta)
  v(text-above)
  if "lead_in" in meta and meta.lead_in != none { body-par(inl(meta.lead_in)) }
  let last-chunk = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n")).last()
  assert(not last-chunk.starts-with("#"), message: "pamd-complaint: the body must end with a paragraph or a list (the signature is set with it)")
  body-chunks(body, signature-block(meta))
}
