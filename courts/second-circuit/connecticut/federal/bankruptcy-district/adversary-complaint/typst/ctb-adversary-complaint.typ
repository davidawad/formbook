// Adversary complaint for the United States Bankruptcy Court, D. Connecticut (ctb).
// Rules: FRBP 7010 (caption and form of an adversary pleading: Fed. R. Civ. P. 10 applies, and the caption
// must substantially conform to Official Form 416A); FRBP 9004(a)-(b) (legibility; the caption elements);
// FRBP 7008(a) (jurisdiction allegation and the statement on final orders); FRCP 10(b) (numbered paragraphs);
// D. Conn. Local Bankr. R. 5005-1 (adopts D. Conn. L. Civ. R. 10: double spacing, 8 1/2 x 11, margins of at
// least 1 inch, page numbers after page 1, docket number with judge initials, signature block, date in caption).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // no typeface rule in the bankruptcy local rules; Times New Roman (vendored), the house face per docs/FONTS.md (README.md, gap 2)
#let type-size = 12pt                  // D. Conn. L. Civ. R. 7(a)(5), applied by Local Bankr. R. 7007-1: text at least 12 point
#let docket-size = 10pt                // the docket line beside the page number (L. Civ. R. 10 sets no size)
#let page-w = 8.5in                    // L. Civ. R. 10: 8 1/2 x 11 inches
#let page-h = 11in
#let margin = 1in                      // L. Civ. R. 10: margins of at least 1 inch
#let footer-distance = 0.5in           // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in               // first-line indent of every body paragraph; a paragraph number starts here
#let number-box = 0.5in                // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-box = 0.5in                  // a list item's label box after the indent; the text hangs after it
#let caption-left = 3.4in              // width of the left (party) column of the caption, closed by a right and a bottom rule
#let caption-gutter = 0.2in            // between the party column and the case column
#let caption-rule = 0.75pt             // the party column's rules
#let caption-pad-right = 10pt          // the party column's text to its right rule ...
#let caption-pad-below = 8pt           // ... and to its bottom rule
#let case-pad = 0.1in                  // the case column's text stands off the gutter
#let debtor-indent = 0.5in             // the debtors' names under "In re:"
#let versus-indent = 2.0in             // "v." between the sides
#let designation-indent = 2.5in        // "Debtors.", "Plaintiff,", "Defendant."
#let sig-left = 3.0in                  // the signature block: the date and place at left, the signer's column after it
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ctb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                 // L. Civ. R. 10: double-spaced (2 x 12 pt): body, headings, list items
#let pitch-single = 13.8pt             // single spacing: court, caption, title, signature block, footer
#let caption-above = 24pt              // the court's name to the caption (one blank double line)
#let caption-gap = 12pt                // between the debtor box and the adversary box
#let title-above = 24pt                // the caption to the title
#let title-below = 12pt                // the title to the text
#let sig-above = 24pt                  // the last paragraph to the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, unloose(c)))
})

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), Official Form 416A: court, title, case number, document character)
// ---------------------------------------------------------------------------

/// One caption box: the party column (right and bottom rules) and the case column, both from their first line.
#let caption-box(above, left, right) = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) } else { none },
  pad(right: caption-pad-right, bottom: caption-pad-below, left.join()),
  [],
  pad(left: case-pad, right.join()),
))

#let caption(meta) = {
  for l in (meta.court, meta.district, meta.division) {
    sline(centered: true, text(weight: "bold", upper(l)))
  }
  let right1 = (sline[Chapter #meta.chapter], sline[#meta.main_case])
  if meta.at("jointly_administered", default: false) { right1.push(sline[(Jointly Administered)]) }
  caption-box(caption-above,
    (sline[In re:], sline(left: debtor-indent, md(meta.debtors)), sline(left: designation-indent)[Debtors.]),
    right1)
  let left2 = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { left2.push(sline(left: versus-indent)[v.]) }
    left2 += p.names.map(n => sline(md(n)))
    left2.push(sline(left: designation-indent, md(p.designation)))
  }
  caption-box(caption-gap, left2,
    (sline[Adv. Pro. No. #meta.adv_number (#meta.judge)], sline[Dated: #meta.date]))
  block(width: 100%, above: title-above, below: title-below,
    sline(centered: true, text(weight: "bold", md(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists (Fed. R. Civ. P. 10(b) via FRBP 7010)
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// Headings on the body pitch with no space of their own, kept with the block after them (docx: Heading 1 to 3 in
/// docx/reference.xml): `#` centred bold capitals (a section); `##` bold, left (a lettered sub-section, a claim's
/// subtitle); `###` centred bold.
#let section-heading(level, t) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set align(center) if level != 2
  par(first-line-indent: 0pt, text(weight: "bold", if level == 1 { upper(unloose(md(t))) } else { unloose(md(t)) }))
})

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(c)))

/// A list item: its label in a box after the indent, the text hanging after it (docx: style "List Label").
#let list-item(label, c) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: para-indent + list-box,
    [#h(para-indent)#box(width: list-box, label)#unloose(c)]))

/// Renders the body. Paragraphs before the first heading are the unnumbered lead-in, and so are the
/// paragraphs under the prayer for relief ("WHEREFORE"); every other paragraph is numbered 1, 2, ...
/// (the template numbers, the sample does not).
#let body-text(body) = {
  let numbered = false
  let n = 0
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  for t in body-chunks(body) {
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      let level = calc.min(m.captures.at(0).len(), 3)
      // A section heading starts a numbered run, except the prayer for relief, which is not numbered.
      numbered = not t.contains("PRAYER")
      section-heading(level, m.captures.at(1))
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      let ordered = t.match(regex("^\\d+\\.")) != none
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() {
        list-item(if ordered [#(i + 1).] else [•], md(item))
      }
    } else if numbered {
      n += 1
      body-par[#box(width: number-box)[#n.]#unloose(md(t))]
    } else {
      body-par(md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (D. Conn. L. Civ. R. 10: name, office address, telephone, email under the signature;
// federal bar number beneath the signature)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let s = meta.signature
  let rows = (sline(upper(s.party)), sline[By: /s/ #s.esigner])
  for signer in s.signers {
    rows.push(sline(md(signer.at(0))))
    rows.push(sline(md(signer.at(1))))
  }
  rows += s.firm.map(l => sline(md(l)))
  rows.push(sline(md(s.role)))
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, grid(
    columns: (sig-left, sig-gutter, 1fr),
    sline[Dated: #meta.date] + sline(md(s.dated_place)),
    [],
    rows.join(),
  ))
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ctb-adversary-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // L. Civ. R. 10 (via Local Bankr. R. 5005-1): page numbers in the bottom margin after page 1, and the docket
    // number with the judge's initials on every pleading (page 1 carries it in the caption): the number centred,
    // the docket line at the right, in a single-pitch line box that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context {
      if counter(page).get().first() > 1 {
        set text(..edges(pitch-single))
        grid(columns: (1fr, auto, 1fr), [], counter(page).display(),
          align(right, text(size: docket-size, "Adv. Pro. No. " + meta.adv_number + " (" + meta.judge + ")")))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  caption(meta)
  body-text(body)
  signature(meta)
}
