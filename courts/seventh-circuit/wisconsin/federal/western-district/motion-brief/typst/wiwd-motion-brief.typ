// Brief in support of a motion to dismiss for the U.S. District Court for the Western District of Wisconsin (wiwd).
// Rules: Fed. R. Civ. P. 7(b)(1) (a request for a court order is made by motion, stated with particularity),
// 12(b)(1) and 12(b)(6) (the grounds for dismissal), 5(b)(2)(E) and 5(d)(1)(B) (service by the court's
// electronic system needs no separate certificate of service); W.D. Wis. LR 5.1 (electronic filing) and the
// court's Briefing Guidelines (12(b)(6) motions: matters outside the pleadings need leave). The W.D. Wis. form
// rules (font, spacing, margins) are not in the court's posted local rules; see ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no W.D. Wis. rule names a face (rules.md WIWD-LEN-001); Times New Roman, the house standard (docs/FONTS.md); the exemplar's Century Schoolbook is that filer's style (tier 3)
#let type-size = 12pt                   // convention, matching the filed exemplar's body size; no W.D. Wis. rule verified
#let footer-size = 11pt                 // the page number
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; the exemplar is letter size)
#let page-h = 11in
#let margin = 1in                       // convention; the exemplar's text block is about 1 inch in from each edge
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-box = 0.4in                   // a list item's letter (or bullet) at the indent, its lines hanging at 0.9 in
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column's rule and the right column
#let caption-pad-right = 10pt           // the party column's text stands this far from its right rule
#let caption-pad-bottom = 8pt           // and this far above its bottom rule
#let caption-right-pad = 0.1in          // the right column's text stands this far in
#let caption-rule = 0.75pt
#let sig-left = 2.75in                  // the signature block in the right half of the page, the usual place in a brief
#let sig-width = 3.5in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wiwd-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                  // double spacing at 12 pt (convention, the exemplar's): body, headings, lists
#let pitch-single = 13.8pt              // single spacing: court title, caption, title, signature block
#let cover-gap = 13.8pt                 // court title to caption, caption to title (a blank single line)
#let title-below = 24pt                 // the title to the first paragraph (a blank double line)
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 24pt                     // the preamble to "/s/" (a blank double line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wiwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (for names with *et al.*, headings).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it; "" is a blank line.
#let sline(above: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    par(first-line-indent: 0pt, if type(c) == str { unloose(md(c)) } else { c })
  })
}

/// Single-pitch lines, one paragraph each.
#let slines(items) = for i in items { sline(i) }

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  sline(centered: true, text(weight: "bold", [IN THE UNITED STATES DISTRICT COURT]))
  sline(centered: true, text(weight: "bold", [FOR THE WESTERN DISTRICT OF WISCONSIN]))
}

/// The caption: the party column ruled at its right and foot (each party's names, then its designation; "v."
/// between the parties), the case number beside it (docx: a table row).
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if x == 0 { (right: caption-pad-right, bottom: caption-pad-bottom) } else { (bottom: caption-pad-bottom) },
    slines(rows),
    [],
    pad(left: caption-right-pad, sline("Case No. " + meta.case_number)),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  sline(above: cover-gap, centered: true, text(weight: "bold", unloose(md(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block, single-spaced in the right half of the page and kept on one page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, pad(left: sig-left, block(width: sig-width, {
    slines(sig.preamble)
    sline(above: sig-gap, "/s/ " + sig.signer)
    sline(sig.signer)
    slines(sig.lines)
  })))
}

/// Brief body. Each blank-line-separated chunk of markdown is one paragraph (indented, unnumbered: a brief is
/// not a numbered pleading), a list ("1." items lettered a., b., ...; "-" items bulleted), or a heading, which is
/// kept with the chunk after it.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  for t in chunks {
    if t.starts-with("#") {
      md(t)
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      let lettered = t.match(regex("^\\d")) != none
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: para-indent + item-box,
          [#h(para-indent)#box(width: item-box, if lettered { numbering("a.", i + 1) } else { [•] })#unloose(md(item))]))
      }
    } else {
      block(width: 100%, above: 0pt, below: 0pt,
        par(first-line-indent: (amount: para-indent, all: true), unloose(md(t))))
    }
  }
}

#let wiwd-motion-brief(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number centered at the foot of every page, in a single-pitch line box that ends footer-distance
    // above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("§§ 1983"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the type size on the body pitch with no space of their own, kept with the text after them: level 1
  // a centered section (CONCLUSION); level 2 a bold argument heading at the left margin; level 3 a bold italic
  // sub-heading.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, upper(it.body)) }
    else if it.level == 2 { it.body }
    else { text(style: "italic", it.body) }
  })

  cover(meta)
  v(title-below)

  brief-body(body)

  signature-block(meta)
}
