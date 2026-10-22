// Complaint for the U.S. District Court for the Eastern District of Michigan (mied).
// Rules: LR 5.1(a) (double spacing, 1-inch margins, 14-point proportional type, page numbers);
// Fed. R. Civ. P. 10(a) (caption, title, case number), 10(b) (numbered paragraphs), 38(b) (jury demand).
// See ../README.md for the rule text, its source and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1(a)(3) names no face (any proportional type, 14 pt); Times New Roman (vendored, docs/FONTS.md), as the filed exemplar
#let type-size = 14pt                   // LR 5.1(a)(3): 14 point for proportional type, footnotes included
#let margin = 1in                       // LR 5.1(a)(2): at least 1 inch, top, bottom and sides
#let page-number-size = 12pt            // page numbers are not text under LR 5.1(a)(3); style choice
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number's box at the indent: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let letter-box = 0.5in                 // ... in a box of its own; the text hangs 1 in from the margin (docx: a tab)
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-gap = 0.25in               // between the party column's rule and the case number column
#let caption-inset = 10pt               // the party column's text to its right and bottom rules
#let caption-right-inset = 0.1in        // the case number column's left inset
#let designation-indent = 1in           // a party's designation ("Plaintiffs,") is set in from the names
#let sig-left = 3.2in                   // the signature block starts here

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/mied-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt). Double spacing (LR 5.1(a)(2)) is read against Times New Roman's single line box, 1.15 em:
// 16.1 pt single and 32.2 pt double at 14 pt.
#let pitch-body = 32.2pt                // LR 5.1(a)(2): double spaced
#let pitch-single = 16.1pt              // single spacing: court title, caption, title, signature block
#let pitch-footer = 13.8pt              // the 12 pt page number's single line
#let caption-above = 32.2pt             // the court title to the caption: one double line
#let title-above = 32.2pt               // the caption to the title of the paper
#let text-above = 16.1pt                // the title to the text: one single line
#let sig-above = 32.2pt                 // the last paragraph to the signature block
// The page number's line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mied-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. An item is a string (markdown),
/// content, or a pair (item, left indent).
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    let (s, left) = if type(i) == array { i } else { (i, 0pt) }
    if s == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt,
        pad(left: left, par(unloose(if type(s) == str { inl(s) } else { s }))))
      g = 0pt
    }
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(content)))

// ---------------------------------------------------------------------------
// Caption: court title (Fed. R. Civ. P. 10(a)), party column, case number and judge, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF MICHIGAN")
  if "division" in meta { lines.push(upper(meta.division)) }
  align(center, line-stack(lines.map(l => text(weight: "bold", l))))
}

/// The parties single-spaced in a column closed by a rule at its right and foot: each party's names, its
/// designation set in, "v." between the parties with a blank line above and below; at the right the case number and
/// the judge.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }
    rows += p.names
    rows.push("")
    rows.push((p.designation, designation-indent))
  }
  let right = ("Case No. " + meta.case_number,)
  if "judge" in meta { right.push(meta.judge) }
  if "judges" in meta { right += meta.judges }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gap, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-inset, bottom: caption-inset), line-stack(rows)),
    [],
    pad(left: caption-right-inset, line-stack(right)),
  ))
}

/// Cover of a paper: court title, caption, title of the paper (bold, centered, single spaced).
#let cover(meta) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: title-above, below: text-above,
    align(center, line-stack((text(weight: "bold", inl(meta.brief_title)),))))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)); headings; prayer list (A., B., ...)
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept with the block after them:
/// centered; level 1 bold capitals, level 2 bold, level 3 italic.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center,
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(style: "italic", unloose(inl(s))) })))

/// A prayer item, lettered A., B., ... (the markdown numbers are not shown): the letter half an inch in, the text
/// hanging after its box (docx: Lettered).
#let lettered(i, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box,
    [#box(width: letter-box, str.from-unicode(64 + i) + ".")#unloose(inl(s))])))

/// The body. Each blank-line-separated chunk of markdown is a `#` heading (levels 1 to 3), a list (each item
/// lettered A., B., ...) or a paragraph, numbered 1, 2, ... (Fed. R. Civ. P. 10(b)). `n`: the paragraphs numbered
/// before. Returns (content, n).
#let item-re = regex("^(\\d+[.)]|[-*+])[ \\t]+")
#let allegations(chunks, n) = {
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      out += heading-block(calc.min(level, 3), t.slice(level).trim())
    } else if t.starts-with(item-re) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      for (i, item) in items.enumerate() { out += lettered(i + 1, item) }
    } else {
      n += 1
      out += body-par[#box(width: number-box)[#n.]#unloose(inl(t))]
    }
  }
  (out, n)
}

/// Signature block: "Respectfully submitted," a blank line, the attorney's electronic signature and contact lines.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, pad(left: sig-left,
  line-stack(("Respectfully submitted,", "", "/s/ " + meta.signature.signer, meta.signature.signer)
    + meta.signature.lines)))

#let mied-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LR 5.1(a)(2): pages numbered; the number centered at the foot.
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt,
      text(size: page-number-size, ..edges(pitch-footer), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  // The last paragraph (or, when the body ends in a list, its last item) stays on the page with the signature block:
  // a signature never starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let tail = chunks.last()
  let k = 0
  if tail.starts-with(item-re) {
    let starts = tail.matches(regex("(?m)^(\\d+[.)]|[-*+])[ \\t]+"))
    k = starts.len() - 1
    if k > 0 { chunks = chunks.slice(0, -1) + (tail.slice(0, starts.last().start).trim(), tail.slice(starts.last().start)) }
  }
  let (main, n) = allegations(chunks.slice(0, -1), 0)
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    if k > 0 { lettered(k + 1, chunks.last().replace(item-re, "")) } else { allegations(chunks.slice(-1), n).at(0) }
    signature-block(meta)
  })
}
