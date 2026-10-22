// Memorandum of law in support of a motion, for the District Court of the Virgin Islands (vid).
// Rules: LRCi 5.1 (double-spaced, numbered pages, 8 1/2 x 11), LRCi 7.1(c) (a motion is accompanied by a
// brief stating reasons and authorities), LRCi 7.1(d) (20-page limit, not checked here); Fed. R. Civ. P.
// 10(a) (caption) and 12(b) (the defense by motion). See ../README.md for the sources and what is not asserted.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // LRCi 5.1(a) names no face; the exemplars' face (vendored, docs/FONTS.md)
#let type-size = 12pt                  // LRCi 5.1(a): at least 12-point type
#let margin = 1in                      // LRCi 5.1(a): at minimum one-inch margins on all sides
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let item-indent = 0.5in               // a list item "1." starts half an inch in ...
#let item-box = 0.5in                  // ... its number in a box of its own; the text hangs 1 in from the margin
#let quote-indent = 0.5in              // a quotation is indented this much from both margins
#let court-name = "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS"   // Fed. R. Civ. P. 10(a): the court's name
#let caption-left = 3.5in              // the party column, its rule included
#let caption-pad = 14.4pt              // the party column's text stops 0.2 in from its right rule ...
#let caption-pad-bottom = 9pt          // ... and this far above its bottom rule
#let caption-rule = 0.75pt             // the caption's rules; the bottom one takes its own room below the row, as
                                       // LibreOffice sets a cell's bottom border (the row is the taller column plus
                                       // the rule in both engines)
#let caption-right-inset = 0.3in       // the case number starts this far into the right column
#let designation-indent = 1.2in        // "Plaintiffs," / "Defendants." under the names
#let sig-col = 3.4in                   // the signature's column starts here; "Dated:" sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vid-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                 // LRCi 5.1(a): double-spaced; 27 lines fill the 9-inch text height
#let pitch-single = 13.8pt             // single spacing: court title, caption, quotations, signature, footer
#let caption-above = 13.8pt            // the court title to the caption: a blank single line
#let designation-above = 6pt           // the names to their designation
#let versus-gap = 7pt                  // around the "v." between the parties
#let title-above = 24pt                // the caption to the title: a blank double line
#let quote-gap = 12pt                  // above and below a quotation
#let sig-above = 24pt                  // the last paragraph to the signature block
#let sig-gap = 7pt                     // the signature's preamble to the "/s/" line
#let cert-above = 24pt                 // the signature to the certificate of service: a blank double line
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body (line endings normalised first).
#let split-frontmatter(src) = {
  let s = src.replace("\r\n", "\n")
  let m = s.match(regex("^---\n([\\s\\S]*?)\n---[ \t]*\n"))
  if m == none { panic("vid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), s.slice(m.end))
}

/// Inline markdown (case names in *italics*, footnote-free text).
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
/// (markdown) or content; `align`: the lines' alignment; `left`: their indent.
#let line-stack(items, above: 0pt, align: left, left: 0pt) = {
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

/// What a markdown chunk (text between blank lines) is.
#let chunk-kind(c) = {
  if c.starts-with("#") { "heading" }
  else if c.starts-with("> ") { "quote" }
  else if c.match(regex("^\\d+\\.[ \\t]")) != none { "list" }
  else { "para" }
}

// ---------------------------------------------------------------------------
// Page one: court title, caption, title
// ---------------------------------------------------------------------------

/// The court's name (bold) and division, centred single lines.
#let court-header(division) = line-stack((text(weight: "bold", court-name), "DIVISION OF " + upper(division)),
  align: center)

/// The caption: the parties on the left, closed by a rule on the right and below (each name single-spaced, the
/// designation under it, "v." centred between the parties); the civil action number on the right.
#let caption(parties, label, case-number) = {
  let left = {
    for (i, p) in parties.enumerate() {
      if i > 0 { line-stack(above: versus-gap, ("v.",), align: center) }
      line-stack(above: if i > 0 { versus-gap } else { 0pt }, p.names)
      line-stack(above: designation-above, (p.designation,), left: designation-indent)
    }
  }
  let number = if case-number == "" { "____________" } else { case-number }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    grid.cell(stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-pad, bottom: caption-pad-bottom - caption-rule), left),
    pad(left: caption-right-inset, line-stack((label + " " + number,))),
  ))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept whole and with the block after
/// them: level 1 centred bold; level 2 bold; level 3 bold italic, at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
  set align(center) if level == 1
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", unloose(inl(s))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) })
})

/// A numbered item of a list: the author's number half an inch in, in a box of its own, the text
/// hanging after it (docx: a tab and a hanging indent).
#let list-item(label, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
  par(first-line-indent: 0pt, hanging-indent: item-box, [#box(width: item-box, label)#unloose(inl(s))])))

/// A quotation: single-spaced, indented from both margins, with a space above and below.
#let quotation(s) = block(width: 100%, above: quote-gap, below: quote-gap, {
  set text(..edges(pitch-single))
  pad(left: quote-indent, right: quote-indent, par(first-line-indent: 0pt, unloose(inl(s))))
})

/// The signature block, single-spaced: "Dated:" and the date at the left of the first line, the preamble, "/s/"
/// with the signer and counsel's lines in a column from `sig-col` (docx: a tab and a hanging indent).
#let signature-block(sig) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let pre = sig.at("preamble", default: ())
  let first = if pre.len() > 0 { inl(pre.first()) } else { [] }
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
    [#box(width: sig-col)[Dated: #sig.at("date", default: "")]#unloose(first)]))
  line-stack(pre.slice(calc.min(1, pre.len())), left: sig-col)
  line-stack(above: sig-gap, ("/s/ " + sig.signer,) + sig.at("lines", default: ()), left: sig-col)
})

/// The body, chunk by chunk (blank-line separated): headings (levels 1 to 3), quotations ("> "), lists ("1."
/// items, the author's numbers) and paragraphs (a memorandum's are not numbered). The last piece is set with
/// `closing` (the signature block) in one unbreakable block, so the signature never stands alone on a page.
#let body-chunks(body, closing) = {
  let pieces = ()
  for raw in body.split("\n\n") {
    let c = raw.trim()
    if c == "" { continue }
    let k = chunk-kind(c)
    if k == "heading" {
      let level = c.match(regex("^#+")).end
      pieces.push(heading-block(calc.min(level, 3), c.slice(level).trim()))
    } else if k == "quote" {
      pieces.push(quotation(c.split("\n").map(l => l.trim-start(">").trim()).join(" ")))
    } else if k == "list" {
      // one item per numbered line; a line without a number continues the item before it
      let items = ()
      for l in c.split("\n") {
        let m = l.match(regex("^(\\d+\\.)[ \\t]+"))
        if m != none { items.push((m.captures.at(0), l.slice(m.end))) }
        else { items.last().at(1) += " " + l.trim() }
      }
      for (label, s) in items { pieces.push(list-item(label, s)) }
    } else {
      pieces.push(body-par(inl(c)))
    }
  }
  for (i, it) in pieces.enumerate() {
    if i == pieces.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { it; closing })
    } else { it }
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/// The certificate of service (frontmatter `certificate`: title, text, signer), after the signature as filed: the
/// heading centred bold on the body pitch, the text, the "/s/" line single-spaced at the right; one unbreakable
/// block a blank double line below the signature.
#let certificate(c) = block(width: 100%, above: cert-above, below: 0pt, breakable: false, {
  heading-block(1, c.title)
  body-par(inl(c.text))
  line-stack(above: sig-above, ("/s/ " + c.signer,), align: right)
})

#let vid-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LRCi 5.1(a): each page numbered consecutively, centred at the foot.
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 454"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-header(meta.division)
  caption(meta.caption, meta.at("number_label", default: "Civil Action No."), meta.at("case_number", default: ""))
  block(width: 100%, above: caption-rule + title-above, below: 0pt,
    align(center, par(first-line-indent: 0pt, text(weight: "bold", inl(meta.title)))))
  let last = body.trim().split("\n\n").last().trim()
  assert(not last.starts-with("#"), message: "vid-motion-brief: the body must end with a paragraph or a list (the signature is set with it)")
  body-chunks(body, signature-block(meta.signature))
  if "certificate" in meta { certificate(meta.certificate) }
}
