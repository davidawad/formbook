// Brief in support of a motion for the U.S. District Court for the Middle District of Pennsylvania (pamd).
// Rules: M.D. Pa. LR 5.1 (form: 14 point type, double spacing, one inch margins; footnotes in the same
// face and size as the text), LR 7.1 (written motion, certificate of non-concurrence, proposed order),
// LR 7.5 (brief within 14 days), LR 7.8 (contents, 15 page or 5,000 word limit, tables above 15 pages).
// See ../README.md for the quoted text and the open questions.
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
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-colon = 0.4in              // the column of ":" marks between the parties and the right column
#let sig-col = 2.8in                    // the signature column starts here (the date at the left of its first line)
#let sig-rule = 3.2in                   // "By:" and the signature line after it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pamd-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 32pt                  // LR 5.1(c): double-spaced; 32 pt is the pitch of the 14 pt filed exemplars
#let pitch-single = 16pt                // single spacing: court title, caption (one line per caption row), the
                                        // single-spaced blocks (questions, service list), signature
#let pitch-footer = 13.8pt              // the 12 pt page number's single line
#let caption-above = 16pt               // the court title to the caption: a blank single line
#let title-above = 32pt                 // the caption to the title
#let text-above = 16pt                  // the title to the text
#let block-gap = 16pt                   // around a single-spaced block: a blank single line
#let sig-above = 32pt                   // the last block to the signature
#let firm-above = 6pt                   // "Respectfully submitted," to the firm
#let by-above = 32pt                    // the firm to "By:"
#let lines-above = 6pt                  // "By:" to the signer's lines
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin-all - 0.5in - pitch-footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamd-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Single-spaced lines, one paragraph each, from `left`. `above`: the space before the first line.
#let line-stack(items, above: 0pt, left: 0pt, align: left) = {
  set text(..edges(pitch-single))
  set std.align(align)
  set par(first-line-indent: 0pt)
  for (k, i) in items.enumerate() {
    block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt,
      pad(left: left, par(unloose(if type(i) == str { inl(i) } else { i }))))
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
/// `right`, the right column: the civil action number, the judge), a ":" on every row between them.
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

/// The title: bold capitals, centred single lines.
#let title(meta) = line-stack(above: title-above, (text(weight: "bold", upper(unloose(inl(meta.title)))),), align: center)

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, single-spaced blocks, signature block
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, flush left, with no space of their own, kept whole and with the
/// block after them: level 1 bold capitals (I., II. ...); level 2 bold (A., B. ...); level 3 bold italic.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false,
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) }))

/// A single-spaced block (a question with its suggested answer, a service-list address): a chunk whose lines end
/// in a hard break (a trailing backslash); no first-line indent, a blank single line around it, kept whole.
#let single-block(t) = block(width: 100%, above: block-gap, below: block-gap, breakable: false, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, unloose(inl(t)))
})

/// The signature block, single-spaced: "Dated:" at the left of the first line and "Respectfully submitted," in a
/// column from `sig-col` (docx: a tab and a hanging indent), the firm, "By:" and the signature line, the signer's
/// lines.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let date = if "date" in meta and meta.date != none [Dated: #meta.date] else []
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
    [#box(width: sig-col, date)Respectfully submitted,]))
  line-stack(above: firm-above, left: sig-col, meta.signature.at("firm", default: ()))
  line-stack(above: by-above, left: sig-col,
    ([#box(width: sig-rule)[By:#box(width: 1fr, height: 0pt, baseline: 1.5pt, stroke: (bottom: 0.5pt))]],))
  line-stack(above: lines-above, left: sig-col, meta.signature.lines)
})

/// The markdown body, chunk by chunk (blank-line separated): a heading, a single-spaced block, or a paragraph.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      // a number that opens the heading ("1.  The ...") is text, not a list
      let s = t.slice(level).trim().replace(regex("^(\\d+)\\."), m => m.captures.at(0) + "\\.")
      heading-block(calc.min(level, 3), s)
    } else if t.contains("\\\n") {
      single-block(t)
    } else {
      body-par(inl(t))
    }
  }
}

#let pamd-motion-brief(meta, body) = {
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
  body-chunks(body)
  signature-block(meta)
}
