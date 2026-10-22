// Complaint for the U.S. District Court for the Western District of New York (nywd).
// Rules: Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs); W.D.N.Y. Local Civil Rule 10(a)
// (12-point type, double spacing, one-inch margins, consecutive page numbers). The civil cover sheet
// (Local Rule 3) is a separate filing and is not produced here. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no W.D.N.Y. rule names a face; Times New Roman, the house standard and the exemplars' face, vendored in fonts/
#let type-size = 12pt              // Local Rule 10(a)(1): all text and footnotes at least 12-point
#let margin = 1in                  // Local Rule 10(a)(4): at least one inch on all four sides
#let para-indent = 0.5in           // first-line indent of paragraphs; the paragraph number in a box of it
#let item-indent = 0.5in           // lettered items: the label half an inch in, in a box of item-label
#let item-label = 0.5in
#let quote-indent = 0.5in          // block quotations, indented on both sides
#let caption-left = 3.4in          // the parties box
#let caption-gutter = 0.3in        // between the parties box and the title column
#let caption-pad = 0.1in           // the parties' text this far off the box's right rule
#let caption-foot = 8pt            // and its last line this far above the bottom rule
#let caption-gap = 6.9pt           // between the parties, "v." and the designations: half a single line
#let against-indent = 1.2in        // "v."
#let designation-indent = 2.2in    // "Plaintiff," / "Defendants."
#let signature-w = 3.2in           // the signature column at the right
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt           // Local Rule 10(a)(2): double-spaced body, 2 x the type size
#let pitch-single = 13.8pt         // single spacing, 1.15 x the size: court title, caption, headings, quotations,
                                   // signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown: *italic* runs (case names, *Id.*, *et al.*); everything else is plain text.
#let inl(s) = {
  let t = s.replace("\\*", "\u{E000}")
  for (i, p) in t.split("*").enumerate() {
    let q = p.replace("\u{E000}", "*")
    if calc.odd(i) { emph(q) } else { q }
  }
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties on the left, title on the right)
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "WESTERN DISTRICT OF NEW YORK")))
}

/// The parties box: each side's names, its designation, and "v." between the sides, half a single line apart; a
/// rule at its right and bottom.
#let party-box(parties) = block(width: 100%, inset: (right: caption-pad, bottom: caption-foot),
  stroke: (right: rule, bottom: rule), {
  for (k, p) in parties.enumerate() {
    if k > 0 { line-block(above: caption-gap, pad(left: against-indent, [v.])) }
    line-block(above: if k > 0 { caption-gap } else { 0pt }, inl(p.names.join(" ")))
    line-block(above: caption-gap, pad(left: designation-indent, inl(p.designation)))
  }
})

/// The caption a single line below the court title (Fed. R. Civ. P. 10(a)): the parties box, and at its right the
/// title, the civil action number line and the jury demand a double line apart. Never split.
#let caption(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  party-box(meta.caption.parties),
  [],
  {
    line-block(text(weight: "bold", upper(meta.title)))
    line-block(above: pitch-double, [Civil Action No. \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_])
    if meta.at("jury_demand", default: false) {
      line-block(above: pitch-double, text(weight: "bold", "JURY TRIAL DEMANDED"))
    }
  },
))

// ---------------------------------------------------------------------------
// Body: blank-line-separated blocks; a block is a heading (#, ##, ###), a block quotation (>), a list
// of "1." items (lettered (a), (b) ...), an unnumbered paragraph (a leading "<!-- unnumbered -->" HTML comment), or a
// numbered paragraph.
// ---------------------------------------------------------------------------

/// A heading, bold and centered, level 1 in capitals; single-spaced, a single line above and below; sticky.
#let heading-block(lvl, t) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", if lvl == 1 { upper(t) } else { inl(t) }))
})

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, Fed. R. Civ. P. 10(b)) the
/// number in a box of the indent and the text after it. `keep`: kept whole on the page of the block after it (the
/// last block stays with the signature).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// Lettered items (a), (b), ...: the label half an inch in, in a box of item-label, the text hanging after it.
#let item-list(items, keep: false) = for (i, t) in items.enumerate() {
  let k = keep and i == items.len() - 1
  block(width: 100%, above: 0pt, below: 0pt, sticky: k, breakable: not k, pad(left: item-indent,
    par(first-line-indent: 0pt, hanging-indent: item-label,
      [#box(width: item-label, numbering("(a)", i + 1))#inl(t)])))
}

/// A block quotation: single-spaced, indented on both sides, a single line above and below.
#let quote-block(t, keep: false) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: keep,
  breakable: not keep, pad(left: quote-indent, right: quote-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    inl(t)
  }))

#let render-body(body) = {
  let n = 0
  let cs = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")
  let marker = "<!-- unnumbered -->"
  for (i, c) in cs.enumerate() {
    let last = i == cs.len() - 1
    if c.starts-with("#") {
      let lvl = 0
      while c.at(lvl) == "#" { lvl += 1 }
      heading-block(lvl, c.slice(lvl).trim())
    } else if c.starts-with(">") {
      quote-block(c.split("\n").map(l => l.trim(">", at: start).trim()).join(" "), keep: last)
    } else if c.split("\n").all(l => l.match(regex("^\\d+\\. ")) != none) {
      item-list(c.split("\n").map(l => l.match(regex("^\\d+\\. (.*)$")).captures.at(0)), keep: last)
    } else if c.starts-with(marker) {
      body-par(none, inl(c.slice(marker.len()).trim().replace("\n", " ")), keep: last)
    } else {
      n += 1
      body-par(n, inl(c.replace("\n", " ")), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Local Rule 10(a); Fed. R. Civ. P. 11(a): signer, address, telephone, email)
// ---------------------------------------------------------------------------

/// A double line below the body: "Dated:" at the left; the firm in bold, a double line below it "By:" and the
/// signer's lines in a column at the right; never split.
#let signature(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (1fr, signature-w),
  line-block[Dated: #inl(meta.date)],
  {
    for f in meta.signature.firm { line-block(text(weight: "bold", inl(f))) }
    line-block(above: pitch-double, [By: #inl(meta.signature.by)])
    for l in meta.signature.lines { line-block(l) }
  },
))

// ---------------------------------------------------------------------------
// Entry point: the complaint
// ---------------------------------------------------------------------------

#let nywd-complaint(meta, body) = {
  // Pages numbered consecutively at the foot, centered (Local Rule 10(a)), the number in a single line box, so it
  // sits where Word's footer sets it.
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (Local Rule 10(a)(2): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  court-title()
  caption(meta)
  // the lead-in a double line below the caption
  block(above: pitch-double, below: 0pt, body-par(none, inl(meta.lead_in)))
  render-body(body)
  signature(meta)
}
