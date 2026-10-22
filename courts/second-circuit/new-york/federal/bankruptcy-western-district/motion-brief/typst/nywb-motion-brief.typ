// Motion with memorandum of law for the United States Bankruptcy Court, Western District of New York (nywb).
// Rules: Fed. R. Bankr. P. 9004(b) (caption), 9013(a)-(b) (written motion, grounds stated with particularity),
// 7012(b) (Civil Rule 12(b)-(i) applies in an adversary proceeding); W.D.N.Y. LBR 9004-1 (letter-size paper),
// 9004-2 (caption with the judge's initial; date, signature, name, address and telephone), 9013-1 (notice and
// memoranda filed at least five days before the return date). See ../README.md for the source, date and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no W.D.N.Y. font rule (LBR 9004-1 says only "plainly and legibly written"); Times New Roman, the house standard and the exemplar's face (docs/FONTS.md)
#let type-size = 12pt                   // convention: 12 point, as the filed exemplar (Times New Roman 12 pt), headings too
#let footer-size = 10pt                 // the page number
#let margin = 1in                       // convention: one-inch margins on every side (no W.D.N.Y. margin rule)
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-hang = 0.5in               // level-2 and level-3 headings: the lines after the first hang this far
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column's rule and the right column
#let caption-pad = 10pt                 // the party column's text stands this far from its right and bottom rules
#let caption-right-pad = 0.1in          // the right column's text stands this far in
#let caption-rule = 0.75pt
#let toc-step = 0.4in                   // contents: each heading level steps in this far
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let sig-col = 3.2in                    // signature: "Dated:" in a 3.0 in column, a 0.2 in gutter, the firm and signer after it
#let quote-inset = 0.5in                // block quotations are indented on both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nywb-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 27.6pt                // double spacing at the exemplar's 27.6 pt pitch: body text and headings
#let pitch-single = 13.8pt              // single spacing: cover, contents, block quotations, signature
#let cover-gap = 13.8pt                 // court title to caption; the contents' title to its rows (a blank single line)
#let counsel-above = 27.6pt             // the caption to the counsel block
#let toc-row-gap = 6pt                  // between the rows of the contents
#let quote-above = 13.8pt               // body to a block quotation
#let quote-below = 6.9pt                // a block quotation to the body
#let sig-above = 27.6pt                 // the last paragraph to the signature block
#let sig-gap = 13.8pt                   // the firm to "By: /s/" (a blank single line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
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
#let sline(above: 0pt, left: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, if type(c) == str { unloose(md(c)) } else { c }))
  })
}

/// Single-pitch lines, one paragraph each.
#let slines(items, left: 0pt) = for i in items { sline(left: left, i) }

/// The page number, centered in a single-pitch line box.
#let page-foot(fmt) = context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display(fmt)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, counsel block (W.D.N.Y. LBR 9004-2; Rule 9004(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = for line in meta.court_name { sline(centered: true, text(weight: "bold", upper(line))) }

/// The caption: the party column ruled at its right and foot ("v." between the parties); beside it the case number,
/// the chapter, the adversary number (when given) and the title of the paper in bold.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }
    rows += p.names + (p.designation,)
  }
  let right = ("Case No. " + meta.case_number,)
  if "chapter" in meta { right.push(meta.chapter) }
  if "adv_number" in meta and meta.adv_number != none and meta.adv_number != "" {
    right += ("", "Adv. Proc. No. " + meta.adv_number)
  }
  right.push("")
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    // the party column's rules run the height of the caption row (Word's cell borders); the caption pad below every
    // column (LibreOffice keeps it below the row whichever column is taller)
    stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if x == 0 { (right: caption-pad, bottom: caption-pad) } else { (bottom: caption-pad) },
    slines(rows),
    [],
    pad(left: caption-right-pad, {
      slines(right)
      sline(text(weight: "bold", unloose(md(meta.brief_title))))
    }),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  if "counsel" in meta and meta.counsel != none {
    block(width: 100%, above: counsel-above, below: 0pt, slines(meta.counsel, left: caption-left + caption-gutter))
  }
}

// ---------------------------------------------------------------------------
// Front matter: table of contents (generated from the headings: page numbers are not typed in)
// ---------------------------------------------------------------------------

/// One contents row: each level steps in; the page number in its own column, a dot leader before it.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind, toc-row-gap)
}

#let toc() = {
  sline(centered: true, text(weight: "bold", "TABLE OF CONTENTS"))
  block(width: 100%, above: cover-gap, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    show outline.entry: toc-entry
    outline(title: none, depth: 3, indent: 0pt)
  })
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A block quotation: single-spaced, indented on both sides.
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for (i, q) in ps.enumerate() {
    block(width: 100%, above: if i == 0 { quote-above } else { pitch-single }, below: quote-below,
      pad(x: quote-inset, sline(q.trim())))
  }
}

/// Each blank-line-separated chunk of markdown is a heading, a quotation or a paragraph. The last paragraph stays
/// whole with the signature block after it (sticky and unbreakable; docx: keep with next, lines together), so the
/// signature never stands alone on a page.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, c) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if c.starts-with("#") { md(c) }
    else if c.starts-with(">") { quotation(c) }
    else { block(width: 100%, above: 0pt, below: 0pt, sticky: last, breakable: not last, par(unloose(md(c)))) }
  }
}

/// The signature block, single-spaced and kept on one page: "Dated:" at the left of the first line, the firm,
/// "By: /s/" and the signer's lines in a column from `sig-col` (docx: a tab and a hanging indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = sig.firm.map(l => (l, 0pt))
  lines.push(("By: /s/ " + sig.signer, if sig.firm.len() > 0 { sig-gap } else { 0pt }))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [Dated: #meta.date])#unloose(md(l))]))
    }
  })
}

#let nywb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",                 // LBR 9004-1: letter size paper
    margin: margin,
    // the page number centered in a single-pitch line box that ends footer-distance above the page edge
    footer-descent: margin - footer-distance - pitch-single,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Every body paragraph is indented, including the first after a heading (the exemplar does the same).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("§§ 544"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings on the body pitch with no space of their own, kept with the text after them: level 1 centered bold
  // capitals; level 2 bold, level 3 bold italic, at the margin with the lines after the first hanging half an inch.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if it.level == 2 { par(hanging-indent: heading-hang, text(weight: "bold", it.body)) }
    else { par(hanging-indent: heading-hang, text(weight: "bold", style: "italic", it.body)) }
  })

  // Cover: no page number.
  page(footer: none, cover(meta))

  // Front matter: table of contents, lower-case roman page numbers from i.
  page(footer: page-foot("i"), {
    counter(page).update(1)
    toc()
  })

  // Body: arabic page numbers from 1, centered at the foot of each page.
  page(footer: page-foot("1"), {
    counter(page).update(1)
    body-chunks(body)
    signature-block(meta)
  })
}
