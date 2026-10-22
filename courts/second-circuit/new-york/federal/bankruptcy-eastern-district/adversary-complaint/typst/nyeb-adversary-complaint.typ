// Adversary complaint for the United States Bankruptcy Court, Eastern District of New York (nyeb).
// Rules (sources and dates in ../README.md):
//   Fed. R. Bankr. P. 7001 (a complaint starts an adversary proceeding), 7010 (Fed. R. Civ. P. 10 applies,
//   and the caption must substantially conform to Official Form 416A), 9004(b) (caption: court's name,
//   case title, case number and adversary-proceeding number, designation of the paper);
//   E.D.N.Y. LBR 9004-1(a) (plainly typed, no erasures, 8 1/2 x 11 paper, signed under Rule 9011, not bound
//   on the side); E.D.N.Y. LBR 9004-2(a) (caption states the court, the title and chapter, the case number and
//   judge code, and for an adversary proceeding the full title and the adversary number).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")       // no font is named by FRBP 9004 or E.D.N.Y. LBR 9004-1; Times New Roman (vendored) per docs/FONTS.md, the face of both filed exemplars
#let type-size = 12pt                  // no size is named either; 12 pt is the working convention (README.md)
#let page-w = 8.5in                    // E.D.N.Y. LBR 9004-1(a)(ii): 8 1/2 x 11 inch paper
#let margin = 1in                      // layout choice: 1 inch margins on all sides
#let footer-distance = 0.5in           // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in               // the number of a numbered paragraph; the first line of an unnumbered one
#let text-indent = 1in                 // the text of a numbered paragraph; wrapped lines return to this indent
#let caption-left = 3.8in              // the caption's party column
#let caption-gutter = 0.2in            // between it and the numbers column
#let designation-indent = 1.2in        // "Debtor.", "Plaintiff", "Defendants." set in under the names
#let caption-rule = 0.75pt             // the caption's rules above, between and below its two blocks
#let caption-inset = 8pt               // the space inside each block, above and below its lines
#let signature-indent = 3.25in         // the signer's column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nyeb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                 // double spacing: the body, headings, prayer items
#let pitch-single = 13.8pt             // single spacing: court title, caption, quotations, signature block
#let title-gap = 6pt                   // between the two lines of the court title
#let caption-above = 24pt              // the court title to the caption
#let caption-below = 24pt              // the caption to the lead-in
#let against-gap = 12pt                // above and below "-against-" between the parties
#let heading-above = 12pt              // above a heading (none at the top of a page)
#let quote-space = 12pt                // above and below a quotation
#let signature-above = 24pt            // the last paragraph to the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics, emphasis) for one piece of text. A line of underscores alone (the signature's rule)
/// is typed as written, not read as a thematic break.
#let inl(s) = if type(s) != str { s } else if s.match(regex("^_+$")) != none { s } else {
  unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))
}

/// The body's blank-line-separated chunks, in order.
#let chunks(body) = body.replace("\r\n", "\n").split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, inl(c)))
})

/// An empty single-pitch line.
#let sblank() = block(width: 100%, height: pitch-single, above: 0pt, below: 0pt)

/// Numbered paragraphs: the counter runs across the whole pleading (Fed. R. Civ. P. 10(b)).
#let para-no = counter("nyeb-para")

// ---------------------------------------------------------------------------
// Caption: court name; debtor and case number; adversary parties, number and title
// ---------------------------------------------------------------------------

#let court-title() = {
  sline(centered: true, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"))
  sline(above: title-gap, centered: true, text(weight: "bold", "EASTERN DISTRICT OF NEW YORK"))
}

/// One side of the caption: its names, then its designation set in from the left.
#let party-lines(p) = (..p.names.map(n => sline(n)), sline(left: designation-indent, p.designation)).join()

#let caption(meta) = {
  let debtor = meta.caption.debtor
  let left1 = [#sline("In re:")#party-lines(debtor)]
  let right1 = [#sline("Case No. " + meta.case_number)#sline("Chapter " + meta.chapter)]
  let left2 = {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { sline(above: against-gap, centered: true, "-against-"); v(against-gap) }
      party-lines(p)
    }
  }
  let right2 = [#sline("Adv. Pro. No. " + meta.adversary_number)#sblank()#sline(text(weight: "bold", meta.title))]
  // Two blocks, each between rules, the numbers column centred on the parties beside it (docx: a two-row table,
  // cell rules and vertical centring).
  block(width: 100%, above: caption-above, below: caption-below, grid(
    columns: (caption-left, caption-gutter, 1fr),
    inset: (x: 0pt, y: caption-inset),
    stroke: (x, y) => (top: if y == 0 { caption-rule }, bottom: caption-rule),
    align: (x, y) => if x == 2 { left + horizon } else { left + top },
    left1, [], right1,
    left2, [], right2,
  ))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A paragraph on the body pitch. `keep`: unbreakable and kept with what follows (headings, the prayer's lead-in,
/// the last paragraph before the signature; docx: keep with next, keep lines together).
#let body-par(c, above: 0pt, keep: false) = block(width: 100%, above: above, below: 0pt, sticky: keep,
  breakable: not keep, c)

/// A label (a paragraph number, a prayer letter) at the paragraph indent, the text at the text indent, wrapped
/// lines back at the text indent (docx: a hanging indent and a tab).
#let labelled(label, c, keep: false) = body-par(keep: keep, par(first-line-indent: 0pt, hanging-indent: text-indent,
  [#h(para-indent)#box(width: text-indent - para-indent, label)#c]))

/// A heading on the body pitch, kept with what follows: level 1 and 2 centred bold, level 3 bold italic.
#let heading-block(level, t) = body-par(above: heading-above, keep: true, {
  set align(center) if level <= 2
  par(first-line-indent: 0pt, if level <= 2 { text(weight: "bold", inl(t)) }
    else { text(weight: "bold", style: "italic", inl(t)) })
})

/// The body: headings, the prayer (a list, lettered), quotations, the WHEREFORE lead-in and numbered paragraphs.
/// `keep-last`: the last paragraph stays with the signature block after it.
#let render-body(cs, keep-last: false) = {
  let n = cs.len()
  for (i, c) in cs.enumerate() {
    let last = keep-last and i == n - 1
    let h = c.match(regex("^(#{1,3})[ \t]+([\\s\\S]*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1).replace("\n", " "))
    } else if c.match(regex("^\\d+\\. ")) != none {
      // A list is the prayer: one lettered item per item of the list.
      let items = c.split(regex("\n\\d+\\. ")).map(s => s.trim()).filter(s => s != "")
      for (k, it) in items.enumerate() {
        labelled(numbering("(a)", k + 1), inl(it.replace(regex("^\\d+\\. "), "").replace("\n", " ")),
          keep: last and k == items.len() - 1)
      }
    } else if c.starts-with(">") {
      // A quotation: single-spaced, indented on both sides.
      block(width: 100%, above: quote-space, below: quote-space, pad(x: para-indent, {
        set text(..edges(pitch-single))
        par(first-line-indent: 0pt, inl(c.split("\n").map(s => s.replace(regex("^> ?"), "")).join(" ")))
      }))
    } else if c.starts-with("WHEREFORE") {
      // The prayer's lead-in is an unnumbered paragraph (Fed. R. Civ. P. 10(b) numbers the allegations only).
      body-par(keep: true, par(inl(c.replace("\n", " "))))
    } else {
      // A numbered paragraph.
      para-no.step()
      labelled(context [#para-no.display().], inl(c.replace("\n", " ")), keep: last)
    }
  }
}

/// The signature block, single-spaced and on one page: the date at the left of its first line, the signer's lines
/// in a column from `signature-indent` (docx: a tab and a hanging indent there).
#let signature(sig) = block(width: 100%, above: signature-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  for (i, l) in sig.lines.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: signature-indent,
      [#box(width: signature-indent, if i == 0 { "Dated: " + sig.date })#inl(l)]))
  }
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nyeb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    // the page number centred in a single-pitch line box that ends footer-distance above the page edge
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  court-title()
  caption(meta)
  // The lead-in ("Plaintiff ..., for its Complaint against ..., allege as follows:") is unnumbered.
  if "lead_in" in meta { body-par(par(inl(meta.lead_in))) }
  // The last paragraph or prayer item stays with the signature block: a signature never stands alone on a page.
  render-body(chunks(body), keep-last: "signature" in meta)
  if "signature" in meta { signature(meta.signature) }
}
