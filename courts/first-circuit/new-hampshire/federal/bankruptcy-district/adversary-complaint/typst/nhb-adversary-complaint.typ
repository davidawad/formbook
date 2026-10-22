// Adversary complaint for the U.S. Bankruptcy Court, District of New Hampshire (nhb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceedings), 7008 (general pleading: jurisdiction and consent
// to final orders), 7010 (caption must substantially conform to Official Form 416D; Fed. R. Civ. P. 10
// otherwise applies, so paragraphs are numbered), 9004(b) (caption contents); D.N.H. LBR 9004-1 (chapter,
// judge initials, BNH number after signature), LBR 7003-1 (cover sheet, a separate attachment), LBR 9004-2.
// See ../README.md for the rule text, dates, and the known gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; no NH rule sets a typeface (README.md, gap 1)
#let type-size = 12pt                   // no NH or federal minimum found for the body; 12 pt is the working standard
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let sub-indent = 1in                   // lettered sub-items "(A) ..." of a numbered paragraph
#let page-margin = 1in                  // letter paper, one-inch margins (no NH rule found; common practice)
#let sig-indent = 3.25in                // the signature block: the right half of the page
#let adv-blank = 2.25in                 // the clerk's blank for the adversary number ends this far into its column
#let rule = 0.5pt                       // the caption's rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // the body, double-spaced (27.6 pt, Word's double spacing at 12 pt)
#let cap-gap = 12pt                     // between the groups of a caption column and of the signature block
#let head-above = 6pt                   // above a section heading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold) in names, citations and text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph of its own, with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// A caption: two equal columns, the left one ruled at its right and foot (the bordered caption of README.md,
/// layout), the right one standing off the rule.
#let caption-grid(above, left, right) = block(above: above, below: 0pt, grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: 10pt, bottom: 8pt, top: 2pt), left),
  block(width: 100%, inset: (left: 18pt, top: 2pt), right),
))

/// The bankruptcy caption: the debtor, the chapter and the case number with the judge's initials (LBR 9004-1(a), (b)).
#let bankruptcy-caption(meta) = {
  let b = meta.bankruptcy
  caption-grid(18pt, {
    line-block[In re:]
    line-block(above: cap-gap, strong(inl(b.debtor)))
    line-block(above: cap-gap, align(right, inl(b.designation)))
  }, {
    line-block(inl(b.chapter))
    line-block(above: cap-gap)[Case No. #inl(b.case_number)]
  })
}

/// The adversary caption: parties, the "v." between them, and the adversary number (Official Form 416D); a blank
/// for the clerk when the number is not yet assigned.
#let adversary-caption(meta) = {
  let a = meta.adversary
  let num = str(a.at("number", default: ""))
  caption-grid(10pt, {
    for (i, p) in a.parties.enumerate() {
      if i > 0 { line-block(above: cap-gap)[v.] }
      for (k, n) in p.names.enumerate() { line-block(above: if i > 0 and k == 0 { cap-gap } else { 0pt }, strong(inl(n))) }
      line-block(above: cap-gap, align(right, inl(p.designation)))
    }
  }, {
    if num == "" {
      line-block(block(width: adv-blank)[Adv. Pro. No. #box(width: 1fr, height: 0.9em, stroke: (bottom: rule))])
    } else {
      line-block[Adv. Pro. No. #inl(num)]
    }
  })
}

/// Signature block (single spaced, right half of the page), the date at the left; one block that never breaks.
#let signature(meta) = {
  let s = meta.signature
  block(breakable: false, width: 100%, above: cap-gap, below: 0pt, {
    line-block[#meta.at("date_label", default: "Date:") #inl(meta.date)]
    for (i, l) in s.intro.enumerate() { line-block(above: if i == 0 { cap-gap } else { 0pt }, indent: sig-indent, inl(l)) }
    line-block(above: 2 * cap-gap, indent: sig-indent, inl(s.signer))
    for (i, l) in s.lines.enumerate() { line-block(above: if i == 0 { cap-gap } else { 0pt }, indent: sig-indent, inl(l)) }
  })
}

/// A body paragraph at the double pitch; the last one stays whole and on the page of the signature block.
#let body-par(last, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: last, breakable: not last, par(content))

/// Body: `#` headings are centered bold (sections), `##` headings are centered bold (sub-sections), every other
/// chunk is a paragraph. Paragraphs are numbered unless their section is listed in `unnumbered` (Fed. R. Civ. P.
/// 10(b)); "WHEREFORE" paragraphs and "(A)" sub-items are not numbered (the exemplar's numbering runs 1 to 40).
#let body(src, unnumbered) = {
  let chunks = src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")
  let last = chunks.len() - 1
  let n = 0
  let numbered = true
  for (i, c) in chunks.enumerate() {
    if c.starts-with("## ") {
      block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(inl(c.slice(3)))))
    } else if c.starts-with("# ") {
      let h = c.slice(2).trim()
      numbered = not unnumbered.contains(h)
      block(sticky: true, width: 100%, above: head-above, below: 0pt, align(center, strong(inl(h))))
    } else if c.match(regex("^\\([A-Z]\\) ")) != none {
      block(width: 100%, above: 0pt, below: 0pt, sticky: i == last, breakable: i != last, {
        set par(first-line-indent: 0pt)
        pad(left: sub-indent, par(inl(c)))
      })
    } else if numbered and not c.starts-with("WHEREFORE") {
      n += 1
      body-par(i == last, [#n. #inl(c)])
    } else {
      body-par(i == last, inl(c))
    }
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------
#let nhb-adversary-complaint(meta, src) = {
  // The page number centered at the foot, in a single-spaced line box (where Word's footer sets it).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number ("§§ 544"), as the Word filter binds it (xengine binds a single one).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // court title, centered bold, one line per entry
  for l in meta.court { line-block(align(center, strong(inl(l)))) }
  bankruptcy-caption(meta)
  if "adversary" in meta { adversary-caption(meta) }
  block(width: 100%, above: 18pt, below: 12pt, line-block(align(center, strong(inl(meta.title)))))
  body(src, meta.at("unnumbered", default: ()))
  signature(meta)
}
