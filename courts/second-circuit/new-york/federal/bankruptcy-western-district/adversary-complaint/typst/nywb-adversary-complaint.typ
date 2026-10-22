// Adversary complaint for the United States Bankruptcy Court, Western District of New York (nywb).
// Rules: Fed. R. Bankr. P. 7001 (proceedings brought as adversary proceedings), 7008(a) (statement of jurisdiction,
// the pleader's consent to final orders), 7010 (caption: Civil Rule 10 applies, the caption substantially conforms
// to Form 416), 9004(b) (caption contents); Civil Rule 10(b) (numbered paragraphs, applies through Rule 7010);
// W.D.N.Y. LBR 9004-1 (letter-size paper), 9004-2 (caption with the judge's initial; date, signature, name, address
// and telephone). See ../README.md for the source, date and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no W.D.N.Y. font rule (LBR 9004-1: "plainly and legibly written"); Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt                   // convention: 12 point, as the filed exemplar (headings too)
#let footer-size = 10pt                 // the page number
#let margin = 1in                       // convention: one-inch margins on every side (no W.D.N.Y. margin rule)
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of every body paragraph; a paragraph number starts here
#let number-box = 0.5in                 // a paragraph number's (or prayer letter's) box: the text starts 1 in from the margin (docx: a tab)
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column's rule and the right column
#let caption-pad = 10pt                 // the party column's text stands this far from its right and bottom rules
#let caption-right-pad = 0.1in          // the right column's text stands this far in
#let caption-rule = 0.75pt
#let sig-col = 3.2in                    // signature: "Dated:" in a 3.0 in column, a 0.2 in gutter, the firm and signer after it
#let quote-inset = 0.5in                // block quotations are indented on both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nywb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 27.6pt                // double spacing at the exemplar's measured 27.6 pt pitch: body, headings, prayer
#let pitch-single = 13.8pt              // single spacing: court title, caption, block quotations, signature
#let cover-gap = 13.8pt                 // court title to caption (a blank single line)
#let lead-above = 27.6pt                // caption to the lead-in (a blank double line)
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
  if m == none { panic("nywb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

// ---------------------------------------------------------------------------
// Cover: court title, caption (debtor, then adversary parties), title of the pleading
// ---------------------------------------------------------------------------

#let court-title(meta) = for line in meta.court_name { sline(centered: true, text(weight: "bold", upper(line))) }

/// The caption: the party column ruled at its right and foot (the debtor, then the adversary parties, "vs." between
/// them); beside it the case number, chapter and judge (LBR 9004-2), the adversary number and the title in bold.
#let caption(meta) = {
  let rows = ()
  if "debtor" in meta and meta.debtor != none {
    rows += ("In re:", "") + meta.debtor.names + (meta.debtor.designation, "")
  }
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "vs.", "") }
    rows += p.names + (p.designation,)
  }
  let right = ("Case No. " + meta.case_number,)
  if "chapter" in meta { right.push(meta.chapter) }
  if "judge" in meta { right.push("Hon. " + meta.judge) }
  let adv = if "adv_number" in meta and meta.adv_number != none and meta.adv_number != "" { meta.adv_number } else { "__________" }
  right += ("", "Adv. Pro. No. " + adv, "")
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: caption-left, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-pad, bottom: caption-pad), slines(rows)),
    [],
    pad(left: caption-right-pad, {
      slines(right)
      sline(text(weight: "bold", unloose(md(meta.brief_title))))
    }),
  ))
}

/// Counsel (optional): single lines at the right column's edge.
#let counsel-block(meta) = block(width: 100%, above: pitch-single, below: 0pt,
  slines(meta.counsel, left: caption-left + caption-gutter))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Civil Rule 10(b), through Rule 7010), unnumbered headings and lists
// ---------------------------------------------------------------------------

/// A body paragraph on the body pitch, its first line indented half an inch.
#let body-par(above: 0pt, sticky: false, c) = block(width: 100%, above: above, below: 0pt, sticky: sticky, par(unloose(c)))

/// A labelled paragraph: the label in a box after the indent; `hang` hangs the following lines at the text.
#let labelled(label, c, hang: false) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: if hang { para-indent + number-box } else { 0pt },
    [#h(para-indent)#box(width: number-box, label)#unloose(c)]))

/// A block quotation: single-spaced, indented on both sides, not numbered (as in the filed complaint).
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for (i, q) in ps.enumerate() {
    block(width: 100%, above: if i == 0 { quote-above } else { pitch-single }, below: quote-below,
      pad(x: quote-inset, sline(q.trim())))
  }
}

/// Each blank-line-separated chunk of markdown is a heading, a list, a quotation or a numbered paragraph. The
/// numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15 (the same finding as cand-complaint).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      md(t)
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      // Prayer items (a markdown list) are lettered A., B., ...; a list may break across pages.
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() { labelled(numbering("A.", i + 1), md(item), hang: true) }
    } else if t.starts-with(">") {
      quotation(t)
    } else if t.starts-with("WHEREFORE") {
      // The prayer lead-in is not a numbered allegation (the filed complaint leaves it unnumbered).
      body-par(sticky: true, md(t))
    } else {
      n += 1
      labelled[#n.][#md(t)]
    }
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

#let nywb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",                 // LBR 9004-1: letter size paper
    margin: margin,
    // Page numbers centered at the foot of each page from page 1 (the exemplar numbers its first page too), in a
    // single-pitch line box that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("§§ 544"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings on the body pitch with no space of their own, kept with the text after them: level 1 centered bold
  // capitals; level 2 centered bold; level 3 bold italic at the margin (docx: the same paragraphs).
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if it.level == 2 { align(center, text(weight: "bold", it.body)) }
    else { text(weight: "bold", style: "italic", it.body) }
  })

  court-title(meta)
  caption(meta)
  if "counsel" in meta and meta.counsel != none { counsel-block(meta) }

  if "lead_in" in meta and meta.lead_in != none { body-par(above: lead-above, md(meta.lead_in)) }

  allegations(body)

  signature-block(meta)
}
