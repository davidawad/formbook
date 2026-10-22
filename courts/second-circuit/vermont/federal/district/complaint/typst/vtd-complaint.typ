// Complaint for the U.S. District Court for the District of Vermont (vtd).
// Rules: D. Vt. L.R. 10(a) (8 1/2 x 11 paper, legible, at least 1 inch margins, no less than 12 point font,
// consecutively numbered pages, double-spaced except quoted material, footnotes used sparingly);
// Fed. R. Civ. P. 8(a) (claim for relief), 10(a) (caption) and 10(b) (numbered paragraphs), 38(b) (jury demand
// in a pleading). See ../README.md for the rule text, the dates verified, and the known gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 10(a)(2), (4): plainly legible, 12 point or more; the rule names no face: Times New Roman, the house standard and the exemplars' face; vendored in fonts/
#let type-size = 12pt                   // L.R. 10(a)(4): 12 point or more; the rule floor
#let page-margin = 1in                  // L.R. 10(a)(3): at least 1 inch on every side
#let para-indent = 0.5in                // first-line indent; the paragraph number in a box of it
#let list-indent = 0.5in                // prayer items: the label half an inch in
#let list-label = 0.4in                 // prayer items: the label's box, the text hanging after it
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case column
#let caption-gap = 0.15in               // the case column's text this far inside it
#let caption-pad = 12pt                 // the party column's text this far off its right rule
#let caption-foot = 10pt                // and its last line this far above its bottom rule
#let signature-indent = 2.9in           // the signature lines stand this far from the left margin
#let rule = 0.75pt                      // the caption's rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // L.R. 10(a)(6): double-spaced, 2 x the type size
#let pitch-single = 13.8pt              // single spacing (court title, caption, headings, signature): 1.15 x the size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vtd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (no separate cover page). Pages are numbered in the
// footer (L.R. 10(a)(5)), set in #vtd-complaint below.
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, strong[UNITED STATES DISTRICT COURT]))
  line-block(align(center, strong[FOR THE DISTRICT OF VERMONT]))
}

/// Caption, a double line below the court title: the parties on the left (closed by a rule at the right and the
/// bottom), each party's names, a blank line and its designation, "v." between the parties with a blank line on
/// each side; the case number, a double line below it the title and a single line below that the jury demand on the
/// right. One single line each; never split.
#let caption(meta) = {
  let left = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { left += (line-block(""), line-block[v.], line-block("")) }
    for n in p.names { left.push(line-block(n)) }
    left += (line-block(""), line-block(p.designation))
  }
  let label = meta.at("case_label", default: "Civil Action No.")
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, inset: (right: caption-pad, bottom: caption-foot), stroke: (right: rule, bottom: rule),
      left.join()),
    [],
    pad(left: caption-gap, {
      line-block(label + " " + meta.case_number)
      line-block(above: pitch-double, strong(inl(meta.brief_title)))
      if meta.at("jury_demand", default: false) {
        line-block(above: pitch-single, strong[JURY TRIAL DEMANDED])
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, signature
// ---------------------------------------------------------------------------

/// A heading, single-spaced, a single line above and below it, sticky so it never ends a page: level 1 centered bold
/// capitals, level 2 centered bold, level 3 bold italic at the margin.
#let heading-block(level, c, above: pitch-single) = block(width: 100%, above: above, below: pitch-single,
  sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(c)))) }
  else if level == 2 { align(center, strong(inl(c))) }
  else { strong(emph(inl(c))) }
})

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, Fed. R. Civ. P. 10(b)) the
/// number in a box of the paragraph indent and the text after it. `keep`: kept whole on the page of the block after it
/// (the last block stays with the signature).
#let body-par(num, content, keep: false, above: 0pt) = block(width: 100%, above: above, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// The body in order. A `#` heading is unnumbered. A list item (`1.`) is lettered A., B., ... by its number (the
/// prayer). A paragraph starting with `~ ` is unnumbered (the WHEREFORE clause). Any other paragraph is numbered.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (k, t) in chunks.enumerate() {
    let keep = k == chunks.len() - 1
    // the body a double line below the caption
    let above = if k == 0 { pitch-double } else { 0pt }
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    let li = t.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1), above: calc.max(above, pitch-single))
    } else if li != none {
      block(width: 100%, above: above, below: 0pt, sticky: keep, breakable: not keep, pad(left: list-indent,
        par(first-line-indent: 0pt, hanging-indent: list-label,
          [#box(width: list-label, numbering("A.", int(li.captures.at(0))))#inl(li.captures.at(1))])))
    } else if t.starts-with("~ ") {
      body-par(none, inl(t.slice(2)), keep: keep, above: above)
    } else {
      n += 1
      body-par(n, inl(t), keep: keep, above: above)
    }
  }
}

/// Signature block: the date line at the body pitch (indented), a double line below it "By:" (or a signature line)
/// and each counsel's block with a blank line between, 2.9 in from the left margin, single-spaced; the date line is
/// kept with the block, which is never split.
#let signature(meta) = {
  let s = meta.signature
  block(width: 100%, above: pitch-double, below: 0pt, sticky: true, breakable: false,
    par(first-line-indent: (amount: para-indent, all: true), inl(s.date_line)))
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, pad(left: signature-indent, {
    if "by" in s { line-block("By: /s/ " + s.by) } else { line-block([#("_" * 34)]) }
    for b in s.blocks {
      line-block("")
      for l in b { line-block(l) }
    }
    if "counsel_for" in s {
      line-block("")
      line-block(s.counsel_for)
    }
  }))
}

#let vtd-complaint(meta, body) = {
  // Pages numbered consecutively (L.R. 10(a)(5)) at the bottom, centered; the number in a single-spaced line box, so
  // it sits where Word's footer sets it.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (L.R. 10(a)(6): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title()
  caption(meta)
  allegations(body)
  signature(meta)
}
