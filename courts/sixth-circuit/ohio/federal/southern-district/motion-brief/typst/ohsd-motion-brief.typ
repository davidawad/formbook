// Motion to dismiss with its memorandum in support, for the U.S. District Court for the Southern District of Ohio (ohsd).
// Rules: S.D. Ohio Civ. R. 5.1(a) (8 1/2 x 11 paper, double-spaced, consecutive page numbers, one-inch
// margins on all sides); Civ. R. 7.2(a)(1) (memorandum in support); Civ. R. 7.2(a)(3) (20-page preference); Civ. R.
// 5.2 (certificate of service); Fed. R. Civ. P. 10(a) (caption), 12(b) (defenses). See ../README.md for the rule
// text and the layout choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // S.D. Ohio Civ. R. 5.1 sets no typeface; Times New Roman (vendored, docs/FONTS.md)
#let type-size = 12pt                   // S.D. Ohio Civ. R. 5.1 sets no point size; 12 pt is the working standard (README.md)
#let page-w = 8.5in                     // Civ. R. 5.1(a): 8 1/2 by 11 inch paper
#let margin = 1in                       // Civ. R. 5.1(a): one-inch margins on all sides (the electronic-filing rule)
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-indent = 0.5in              // a lettered item (the prayer) starts half an inch in ...
#let letter-box = 0.5in                 // ... its letter in a box of its own; the text hangs 1 in from the margin
#let caption-left = 3.3in               // width of the party column of the caption (its rules included)
#let caption-gutter = 0.2in             // between the party column and the right column
#let caption-pad = 10pt                 // the party column's text stops this far from its right and bottom rules
#let caption-rule = 0.75pt              // the caption's rules; the bottom one takes its own room below the row, as
                                        // LibreOffice sets a cell's bottom border (so the row is the taller column
                                        // plus the rule in both engines)
#let caption-right-inset = 0.1in        // the right column's text starts this far in
#let sig-col = 3.1in                    // the signature's right column starts here; the date sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/motion-brief.lua and docx/reference.xml set the
// same twips: 20 x pt).
#let pitch-body = 24pt                  // Civ. R. 5.1(a): double-spaced; 27 lines fill the 9-inch text height
#let pitch-single = 13.8pt              // single spacing: court title, caption, signature, footer
#let caption-above = 12pt               // the court title to the caption
#let title-above = 12pt                 // the case number (or judge) to the title, the title to the legend
#let text-above = 24pt                  // the caption to the text
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // "Respectfully submitted," to the signer's lines
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names in italics, and so on).
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
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The court's name as centred bold single-spaced lines; the division line is the sample's.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF OHIO")
  if "division" in meta and meta.division != none { lines.push(meta.division) }
  line-stack(lines.map(l => text(weight: "bold", l)), align: center)
}

/// The caption (Fed. R. Civ. P. 10(a)): the parties on the left, ruled on the right and below, as S.D. Ohio filings
/// set it; the case number, the judge, the title of the paper and the legend on the right.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k == 1 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let right = ("Case No. " + meta.case_number,)
  if "judge" in meta and meta.judge != none { right.push(meta.judge) }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    grid.cell(stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-pad, bottom: caption-pad - caption-rule), line-stack(rows)),
    [],
    pad(left: caption-right-inset, {
      line-stack(right)
      line-stack(above: title-above, (text(weight: "bold", inl(meta.brief_title)),))
      if "legend" in meta and meta.legend != none {
        line-stack(above: title-above, (text(weight: "bold", upper(meta.legend)),))
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body, signature, certificate
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept whole and with the block after
/// them: level 1 centred bold capitals (the memorandum's title); level 2 bold at the margin (the roman-numeral
/// sections); level 3 bold italic at the margin (the lettered sub-sections).
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
  set align(center) if level == 1
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) })
})

/// A lettered item (the prayer for relief, "A. ..."): the author's letter half an inch in, in a box of its own,
/// the text hanging after it (docx: a tab and a hanging indent).
#let lettered(label, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: letter-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box, [#box(width: letter-box, label)#unloose(inl(s))])))

/// The signature block, single-spaced: "Dated:" and the date at the left of the first line (when `dated`),
/// "Respectfully submitted," and the signer's lines in a column from `sig-col` (docx: a tab and a hanging indent).
#let signature-block(meta, dated: true) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let date = if dated and "date" in meta and meta.date != none [Dated: #meta.date] else []
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
    [#box(width: sig-col, date)Respectfully submitted,]))
  for (k, l) in meta.signature.lines.enumerate() {
    block(width: 100%, above: if k == 0 { sig-gap } else { 0pt }, below: 0pt,
      pad(left: sig-col, par(first-line-indent: 0pt, unloose(inl(l)))))
  }
})

/// The body, chunk by chunk (blank-line separated). A `#` chunk is a heading (levels 1 to 3); a chunk that starts
/// with a capital letter and a full stop ("A. ") is a lettered item; every other chunk is a body paragraph,
/// numbered (Fed. R. Civ. P. 10(b)) when the sample is numbered, except after a heading the sample lists in
/// `unnumbered` (the prayer for relief, the jury demand). A heading named by `new_page_before` opens a page.
/// The last chunk is set with `closing` (the signature block) in one unbreakable block, so the signature never
/// stands alone on a page. `after-first`: set after the first paragraph (the motion's own signature).
#let body-chunks(body, meta, closing, after-first: none) = {
  let n = 0
  let numbered-now = meta.numbered
  let unnumbered = if "unnumbered" in meta { meta.unnumbered } else { () }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, t) in chunks.enumerate() {
    let it = if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      numbered-now = meta.numbered and not unnumbered.contains(title)
      if "new_page_before" in meta and title == meta.new_page_before { pagebreak(weak: true) }
      heading-block(calc.min(level, 3), title)
    } else if t.match(regex("^[A-Z]\\. ")) != none {
      lettered(t.slice(0, 2), t.slice(3))
    } else if numbered-now {
      n += 1
      body-par[#box(width: number-box)[#n.]#unloose(inl(t))]
    } else {
      body-par(inl(t))
    }
    if i == chunks.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { it; closing })
    } else { it }
    if i == 0 and after-first != none and not t.starts-with("#") { after-first }
  }
}

/// The certificate of service (S.D. Ohio Civ. R. 5.2): heading, text and signature lines in one unbreakable block.
#let certificate(meta) = block(width: 100%, above: 0pt, below: 0pt, breakable: false, {
  heading-block(1, "Certificate of Service")
  body-par(inl(meta.certificate.text))
  block(width: 100%, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for l in meta.certificate.lines {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: sig-col, par(first-line-indent: 0pt, unloose(inl(l)))))
    }
  })
})

#let ohsd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // Civ. R. 5.1(a): each page numbered consecutively, centred at the foot.
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("¶¶ 31"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  v(caption-rule + text-above)
  let last-chunk = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n")).last()
  assert(not last-chunk.starts-with("#"), message: "ohsd-motion-brief: the body must end with a paragraph (the signature is set with it)")
  // The motion's own signature block (undated) follows its first paragraph when the sample asks for it.
  let motion-sig = if "motion_signature" in meta and meta.motion_signature == true { signature-block(meta, dated: false) }
  body-chunks(body, meta, signature-block(meta), after-first: motion-sig)
  if "certificate" in meta and meta.certificate != none {
    v(pitch-body)
    certificate(meta)
  }
}
