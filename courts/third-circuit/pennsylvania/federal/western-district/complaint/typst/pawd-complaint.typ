// pawd-complaint.typ: complaint for the United States District Court for the Western District of Pennsylvania.
// Rules (fetched 2026-10-14, see ../README.md): LCvR 5.1.A-B (paper, type, spacing, margins),
// LCvR 5.2.B (signature block: name, address, telephone, email, bar number with the PA prefix),
// Fed. R. Civ. P. 8(a), 10(a), 10(b), 38(b) (jury demand).
// Content-agnostic: no case text here. The sample supplies the frontmatter and the markdown body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- LCvR 5.1 format ----
#let font-family = ("Times New Roman", "Liberation Serif") // LCvR 5.1.B names no face; the exemplar's (vendored, docs/FONTS.md)
#let type-size = 12pt                   // LCvR 5.1.B: not smaller than 12 pt
#let margin = 1in                       // LCvR 5.1.B: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-indent = 0.5in              // a lettered item "a." starts half an inch in ...
#let letter-box = 0.5in                 // ... its letter in a box of its own; the text hangs 1 in from the margin
#let caption-paren = 0.4in              // the ")" column between the parties and the right column
#let caption-right = 2.9in              // the right column: case number, jury demand, "Electronically Filed."
#let sig-col = 3.0in                    // the signature's column starts here

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pawd-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                  // LCvR 5.1.B: double-spaced
#let pitch-single = 13.8pt              // headings may be single-spaced (LCvR 5.1.B): court title, caption, signature, footer
#let caption-above = 24pt               // the court title to the caption
#let title-above = 24pt                 // the caption to the title, the title to the lead-in
#let sig-above = 24pt                   // the last block to the signature; the gaps inside it
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

#let md(s) = cmarker.render(s, smart-punctuation: true, raw-typst: false)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawd-complaint: the sample must start with a YAML frontmatter block") }
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

/// Single-spaced lines, one paragraph each. `above`: the space before the first line. An item is a string
/// (markdown) or content; `align`: the lines' alignment.
#let line-stack(items, above: 0pt, align: left) = {
  set text(..edges(pitch-single))
  set std.align(align)
  set par(first-line-indent: 0pt)
  for (k, i) in items.enumerate() {
    block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt,
      par(unloose(if type(i) == str { md(i) } else { i })))
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(content)))

/// The caption: parties in a left column with a ")" per single line, the case number on the first line of the right
/// column, then (when the sample asks) "JURY TRIAL DEMANDED" and "Electronically Filed.", a blank single line apart.
#let caption(meta) = {
  let rows = ()
  for (i, p) in meta.caption.enumerate() {
    if i > 0 { rows.push("v.") }
    for n in p.names { rows.push(n) }
    rows.push(p.designation)
  }
  let right = {
    line-stack(([Civil Action No. #meta.case_number],))
    if meta.at("jury_demand", default: false) { line-stack(above: pitch-single, (strong[JURY TRIAL DEMANDED],)) }
    if meta.at("electronically_filed", default: false) { line-stack(above: pitch-single, ([Electronically Filed.],)) }
  }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (1fr, caption-paren, caption-right),
    line-stack(rows),
    line-stack(rows.map(_ => ")"), align: center),
    right,
  ))
}

/// Headings at the type size on the body pitch, with no space of their own, kept whole and with the block after
/// them: `#` centred bold capitals, `##` centred bold (each source line its own line: a count's statute and theory),
/// `###` bold at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, par(strong(upper(unloose(md(s)))))) }
  else if level == 2 { for l in s.split("\n") { align(center, par(strong(unloose(md(l.trim()))))) } }
  else { par(strong(unloose(md(s)))) }
})

/// A lettered item "a.": the letter half an inch in, in a box of its own, the text hanging after it (docx: a tab
/// and a hanging indent).
#let lettered(label, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: letter-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box, [#box(width: letter-box, label)#unloose(md(s))])))

/// The signature block, single-spaced: "Dated:" at the margin, then "Respectfully submitted," the firm, the signer's
/// "s/" line and the attorney lines in a column from `sig-col`, a blank double line between the groups.
#let signature(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  let sig = meta.signature
  let date = meta.at("date", default: none)
  if date != none { line-stack(([Dated: #date],)); v(sig-above) }
  pad(left: sig-col, {
    line-stack((sig.lead,))
    if sig.at("firm", default: none) != none { line-stack(above: sig-above, sig.firm) }
    line-stack(above: sig-above, (sig.signer,) + sig.lines)
  })
})

/// List items of a chunk: a line that starts "- " opens an item; other lines continue it.
#let list-items(chunk) = {
  let items = ()
  for line in chunk.split("\n") {
    if line.starts-with("- ") { items.push(line.slice(2)) }
    else if items.len() > 0 { items.last() += " " + line.trim() }
  }
  items
}

/// The body, chunk by chunk (blank-line separated): a heading (# section, ## count, ### sub), a run of lettered
/// items ("- " lines: the prayer, or the sub-paragraphs of the paragraph above), "JURY TRIAL DEMANDED" (centred
/// bold), an unnumbered "WHEREFORE" paragraph, or a numbered paragraph (Fed. R. Civ. P. 10(b)). The last piece is
/// set with `closing` (the signature block) in one unbreakable block, so the signature never stands alone.
#let body-content(body, closing) = {
  let n = 0
  let pieces = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "") {
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).end
      pieces.push(heading-block(calc.min(level, 3), c.slice(level).trim()))
    } else if c.starts-with("- ") {
      for (i, item) in list-items(c).enumerate() { pieces.push(lettered(numbering("a.", i + 1), item)) }
    } else if c.starts-with("JURY TRIAL DEMANDED") {
      pieces.push(block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, strong(c)))))
    } else if c.starts-with("WHEREFORE") {
      pieces.push(body-par(md(c)))
    } else {
      n += 1
      pieces.push(body-par[#box(width: number-box)[#n.]#unloose(md(c))])
    }
  }
  for (i, it) in pieces.enumerate() {
    if i == pieces.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { it; closing })
    } else { it }
  }
}

/// The complaint. Page 1 carries the court title and the caption, and the body follows on.
#let pawd-complaint(meta, body) = {
  set document(title: meta.case_number + " " + meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 2611"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  line-stack(([*IN THE UNITED STATES DISTRICT COURT*], [*FOR THE WESTERN DISTRICT OF PENNSYLVANIA*]), align: center)
  caption(meta)
  line-stack(above: title-above, (strong(meta.title),), align: center)
  v(title-above)
  if meta.at("lead_in", default: none) != none { body-par(md(meta.lead_in)) }
  body-content(body, signature(meta))
}
