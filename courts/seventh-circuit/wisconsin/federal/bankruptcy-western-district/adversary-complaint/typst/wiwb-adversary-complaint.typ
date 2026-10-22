// Adversary complaint, United States Bankruptcy Court for the Western District of Wisconsin (wiwb).
// Rules (see ../README.md for quotes, URLs and the verification date):
//   Fed. R. Bankr. P. 7001 (adversary proceeding), 7008(a) (jurisdiction statement and consent to
//   entry of final orders), 7010 (Fed. R. Civ. P. 10 applies; caption per Official Form 416),
//   9004(a)-(b) (legibility; caption: court, title, case and adversary numbers, designation),
//   9011 (signature block), Fed. R. Civ. P. 10(b) (numbered paragraphs).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no W.D. Wis. rule names a face for a complaint (README.md); Times New Roman, the house standard (docs/FONTS.md), the exemplar's face
#let type-size = 12pt                   // convention: 12 point body text (no W.D. Wis. rule found; README.md)
#let footer-size = 11pt                 // the page number
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; README.md)
#let page-h = 11in
#let margin = 1in                       // convention: 1 inch margins
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number starts here
#let number-box = 0.5in                 // a paragraph's number in a box after the indent: the text starts 1 in from the margin
#let item-box = 0.4in                   // a prayer item's letter in a box after the indent: its lines hang at 0.9 in
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in
#let caption-pad = 10pt                 // the party column's text stands this far from its right and bottom rules
#let caption-rule = 0.75pt
#let designation-right = 0.4in          // a party's designation is set flush right 0.4 in inside the party column
#let sig-col = 3.4in                    // signature: the date in a 3.4 in column, the firm and signer after it
#let adv-blank = "____________"         // the clerk's adversary number, when the sample has none
#let sig-blank = "__________________________"
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN")   // Fed. R. Bankr. P. 9004(b)(1)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wiwb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // convention: the body's 24 pt baseline pitch (README.md)
#let pitch-single = 13.8pt              // single spacing: court title, caption, headings, signature
#let title-gap = 18pt                   // court title to caption, caption to title, title to the body
#let debtor-gap = 14.4pt                // the bankruptcy case lines to the adversary parties
#let designation-gap = 6pt              // a party's names to its designation
#let versus-gap = 9.6pt                 // above and below "v."
#let adv-above = 2.4pt                  // "Adversary Case No." stands this far below the caption's top
#let h1-above = 14.4pt                  // level-1 heading: space above and below
#let h1-below = 7.2pt
#let h2-above = 12pt
#let h2-below = 6pt
#let sig-above = 32.4pt                 // the last paragraph to the signature block
#let sig-gap = 6pt                      // the firm to "Respectfully submitted,"
#let sig-line-above = 32.4pt            // room for the signature above the /s/ line
#let signer-above = 2.4pt               // the /s/ line to the signer's name

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wiwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (for names with *et al.*, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, below: 0pt, centered: false, right: none, c) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set align(center) if centered
  let body = par(first-line-indent: 0pt, if type(c) == str { unloose(md(c)) } else { c })
  if right == none { body } else { pad(right: right, align(std.right, body)) }
})

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b); Fed. R. Bankr. P. 7010, Official Form 416)
// ---------------------------------------------------------------------------

/// The party column: "In re", the debtor and the case; then each side's names and designation, "v." between.
#let party-column(meta) = {
  for l in ("In re:", meta.debtor, "Case No. " + meta.bankruptcy_case, "Chapter " + meta.chapter) { sline(l) }
  for (i, side) in meta.caption.enumerate() {
    for (j, n) in side.names.enumerate() { sline(above: if j == 0 { debtor-gap } else { 0pt }, n) }
    sline(above: designation-gap, right: designation-right - caption-pad, side.designation)
    if i < meta.caption.len() - 1 { block(above: versus-gap, below: versus-gap, sline("v.")) }
  }
}

#let caption(meta) = block(width: 100%, above: title-gap, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
  inset: (x, y) => if x == 0 { (right: caption-pad, bottom: caption-pad) } else { 0pt },
  party-column(meta),
  [],
  {
    let n = if "adversary_case" in meta and meta.adversary_case != "" { meta.adversary_case } else { adv-blank }
    // the space above the first line of a cell is not collapsed away (Word keeps it): a pad
    pad(top: adv-above, sline([#text(weight: "bold")[Adversary Case No.] #n]))
  },
))

#let cover(meta) = {
  for l in court-name { sline(centered: true, text(weight: "bold", l)) }
  caption(meta)
  sline(above: title-gap, below: title-gap, centered: true, text(weight: "bold", upper(meta.title)))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayer
// ---------------------------------------------------------------------------

/// A body paragraph on the body pitch.
#let body-par(above: 0pt, sticky: false, first: para-indent, hang: 0pt, c) = block(width: 100%, above: above,
  below: 0pt, sticky: sticky, par(first-line-indent: (amount: first, all: true), hanging-indent: hang, unloose(c)))

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), via Fed. R. Bankr. P. 7010). Each blank-line-separated
/// chunk of markdown that is neither a heading nor a list is one numbered paragraph; a paragraph that
/// begins with WHEREFORE is the prayer lead-in and stays unnumbered, kept with the items after it. Markdown lists
/// become (a), (b), ... Numbering is applied per chunk, not with a `show par` rule (a show rule that re-wraps
/// paragraph content recurses without end in typst 0.15).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      md(t)
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      // Prayer items, lettered; a list may break across pages.
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() {
        body-par(first: 0pt, hang: para-indent + item-box,
          [#h(para-indent)#box(width: item-box, numbering("(a)", i + 1))#unloose(md(item))])
      }
    } else if t.starts-with("WHEREFORE") {
      body-par(sticky: true, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#unloose(md(t))])
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011): date, firm, /s/ signature, signer, bar number, address, phone
// ---------------------------------------------------------------------------

/// Single-spaced and kept on one page: the date at the left of the first line, the firm (bold) beside it, then
/// "Respectfully submitted,", the /s/ line, the signer and the counsel lines in a column from `sig-col` (docx: a tab
/// and a hanging indent there).
#let signature(meta) = {
  let sig = meta.signature
  let lines = ()
  if "firm" in sig { lines.push((text(weight: "bold", sig.firm), 0pt)) }
  lines.push(("Respectfully submitted,", if "firm" in sig { sig-gap } else { 0pt }))
  lines.push(("/s/ " + sig-blank, sig-line-above))
  lines.push((sig.signer, signer-above))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 and "date" in meta { unloose(md(meta.date)) })#if type(l) == str { unloose(md(l)) } else { l }]))
    }
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let wiwb-adversary-complaint(meta, body) = {
  // Fed. R. Bankr. P. 7008(a): the complaint must state whether the pleader consents to entry of final orders
  // (in force since the December 1, 2016 amendment), and must give the jurisdiction statement.
  assert(body.match(regex("(?i)consent")) != none, message: "wiwb-adversary-complaint: Fed. R. Bankr. P. 7008(a) requires a statement whether the pleader consents to entry of final orders")
  assert(body.match(regex("(?im)^# *jurisdiction")) != none, message: "wiwb-adversary-complaint: Fed. R. Bankr. P. 7008(a) requires a jurisdiction statement (a '# JURISDICTION' heading)")

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number centered at the foot of every page (the ECF header is added by the court's system, not
    // here), in a single-pitch line box that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings on the single pitch, kept with the text after them: level 1 centered, bold, capitals; level 2 bold,
  // at the margin.
  show heading: it => {
    let (above, below) = if it.level == 1 { (h1-above, h1-below) } else { (h2-above, h2-below) }
    block(width: 100%, above: above, below: below, sticky: true, {
      set text(size: type-size, weight: "bold", ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, upper(it.body)) } else { it.body }
    })
  }

  cover(meta)

  allegations(body)

  signature(meta)
}
