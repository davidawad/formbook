// Memorandum of law in support of a motion to dismiss, United States District Court for the Western
// District of New York (nywd). Rules: Fed. R. Civ. P. 7(b)(1) and 12(b)(6); W.D.N.Y. Local Civil Rule 7(a)
// (notice of motion and memorandum of law; a memorandum is limited to 25 pages, and tables of contents and
// authorities are not counted, Rule 7(a)(2)(C)); Local Civil Rule 10(a) (12-point type, double spacing,
// one-inch margins, consecutive page numbers). The table of authorities is not generated (known gap, README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no W.D.N.Y. rule names a face; Times New Roman, the house standard and the exemplars' face, vendored in fonts/
#let type-size = 12pt              // Local Rule 10(a)(1): all text and footnotes at least 12-point
#let margin = 1in                  // Local Rule 10(a)(4): at least one inch on all four sides
#let para-indent = 0.5in           // first-line indent of body paragraphs
#let heading-tab = 0.5in           // a heading's label (I., A.) in a box of this width, the title hanging after it;
                                   // level 3 (and its contents row) half an inch further in
#let item-indent = 0.5in           // lettered items: the label half an inch in, in a box of item-label
#let item-label = 0.5in
#let quote-indent = 0.5in          // block quotations, indented on both sides
#let caption-left = 3.4in          // the parties box
#let caption-gutter = 0.3in        // between the parties box and the case number
#let caption-pad = 0.1in           // the parties' text this far off the box's right rule
#let caption-foot = 8pt            // and its last line this far above the bottom rule
#let caption-gap = 6.9pt           // between the parties, "v." and the designations: half a single line
#let against-indent = 1.2in        // "v."
#let designation-indent = 2.2in    // "Plaintiff," / "Defendants."
#let counsel-indent = 3.5in        // the counsel block on the cover, at the right
#let signature-w = 3.2in           // the signature column at the right
#let page-col = 36pt               // contents: the column of the page numbers; a title wraps before it
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt           // Local Rule 10(a)(2): double-spaced, 2 x the type size (the contents too)
#let pitch-single = 13.8pt         // single spacing, 1.15 x the size: court title, caption, cover title, counsel,
                                   // headings, quotations, signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywd-motion-brief: the sample must start with a YAML frontmatter block") }
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
// Cover: court title, caption (parties left; case number right), title, counsel block
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

/// The caption a single line below the court title: the parties box, and at its right the case number. Never split.
#let caption(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  party-box(meta.caption.parties),
  [],
  line-block("Case No. " + meta.case_number),
))

/// The paper's title, bold capitals, centered, a double line below the caption.
#let cover-title(meta) = block(width: 100%, above: pitch-double, below: 0pt,
  line-block(align(center, text(weight: "bold", upper(meta.title)))))

/// The counsel block at the right, a double line below the title: each group's first name in bold, its other names
/// and its lines, the groups a single line apart.
#let counsel-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt,
  pad(left: counsel-indent, for (k, g) in meta.counsel.enumerate() {
    line-block(above: if k > 0 { pitch-single } else { 0pt }, text(weight: "bold", inl(g.names.first())))
    for n in g.names.slice(1) { line-block(n) }
    for l in g.lines { line-block(l) }
  }))

// ---------------------------------------------------------------------------
// Headings: level 1 is a section (centered, bold capitals, unnumbered); level 2 is numbered I., II. and level 3
// A., B. (numbers reset at each higher level). Each heading is a real heading (its label in the supplement), so
// the table of contents is read from them.
// ---------------------------------------------------------------------------

#let roman = ("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV")
#let letter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

/// The left edge of a heading's label: levels 1 and 2 at the margin, level 3 half an inch in.
#let label-indent(level) = if level >= 3 { heading-tab } else { 0pt }

/// A heading, single-spaced, a single line above and below, sticky: level 1 centered bold capitals; deeper levels
/// bold, the label in a box of heading-tab, the title hanging after it.
#let show-heading(it) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
  set text(size: type-size, weight: "regular", ..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if it.level == 1 { align(center, strong(upper(it.body))) } else {
    pad(left: label-indent(it.level), par(hanging-indent: heading-tab,
      strong[#box(width: heading-tab, it.supplement)#it.body]))
  }
})

// ---------------------------------------------------------------------------
// Table of contents (a page of its own, numbered i): a row per heading, the page at the right
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

#let toc-section() = {
  line-block(align(center, text(weight: "bold", "TABLE OF CONTENTS")))
  block(above: pitch-double, below: 0pt, context {
    for hd in query(heading.where(outlined: true)) {
      let ind = label-indent(hd.level)
      if hd.level == 1 {
        listing-row(hd.location(), hd.body, page-label(hd.location()), page-col, 0pt, 0pt)
      } else {
        listing-row(hd.location(), [#h(ind)#box(width: heading-tab, hd.supplement)#hd.body],
          page-label(hd.location()), page-col, ind + heading-tab, 0pt)
      }
    }
  })
}

// ---------------------------------------------------------------------------
// Body: blank-line-separated blocks; a block is a heading (#, ##, ###), a block quotation (>), a list of
// "1." items (lettered (a), (b) ...), or a paragraph (a "::" prefix is dropped). Memorandum paragraphs are not
// numbered.
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch with the first-line indent; `keep`: kept whole on the page of the block
/// after it (the last block stays with the signature).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

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
  let h2 = 0
  let h3 = 0
  let cs = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")
  for (i, c) in cs.enumerate() {
    let last = i == cs.len() - 1
    if c.starts-with("#") {
      let lvl = 0
      while c.at(lvl) == "#" { lvl += 1 }
      let t = c.slice(lvl).trim()
      let lab = if lvl == 1 {
        h2 = 0
        h3 = 0
        none
      } else if lvl == 2 {
        h2 += 1
        h3 = 0
        roman.at(h2 - 1) + "."
      } else {
        h3 += 1
        letter.at(h3 - 1) + "."
      }
      heading(level: calc.min(lvl, 3), outlined: true, supplement: lab, inl(t))
    } else if c.starts-with(">") {
      quote-block(c.split("\n").map(l => l.trim(">", at: start).trim()).join(" "), keep: last)
    } else if c.split("\n").all(l => l.match(regex("^\\d+\\. ")) != none) {
      item-list(c.split("\n").map(l => l.match(regex("^\\d+\\. (.*)$")).captures.at(0)), keep: last)
    } else {
      let t = if c.starts-with("::") { c.slice(2).trim() } else { c }
      body-par(inl(t.replace("\n", " ")), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a): signer, address, telephone, email)
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
// Entry point: cover (unnumbered), table of contents (roman), body (arabic, from 1)
// ---------------------------------------------------------------------------

#let running-footer = context align(center, text(..edges(pitch-single),
  numbering(here().page-numbering(), ..counter(page).get())))

#let nywd-motion-brief(meta, body) = {
  // Pages numbered consecutively at the foot, centered (Local Rule 10(a)), the number in a single line box, so it
  // sits where Word's footer sets it.
  set page(paper: "us-letter", margin: margin, footer-descent: 30%)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (Local Rule 10(a)(2): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: show-heading

  // ---- cover (no page number) ----
  page(numbering: none, footer: none, {
    court-title()
    caption(meta)
    cover-title(meta)
    counsel-block(meta)
  })

  // ---- table of contents, numbered i ----
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc-section()
  pagebreak()

  // ---- body, numbered from 1 ----
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)
  render-body(body)
  signature(meta)
}
