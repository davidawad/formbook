// Complaint for the U.S. District Court for the Southern District of Florida (flsd).
// Rules: S.D. Fla. L.R. 5.1(a) (paper, margins, spacing, type size, pagination, caption, signature block);
// L.R. 3.3 (civil cover sheet is a separate filing, not generated here); Fed. R. Civ. P. 8(a), 10(a), 10(b)
// (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no font rule in L.R. 5.1; Times New Roman, the house default (docs/FONTS.md), as in the exemplar
#let type-size = 12pt                   // L.R. 5.1(a)(4): fonts no smaller than 12 point
#let page-w = 8.5in                     // L.R. 5.1(a)(3): standard 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // L.R. 5.1(a)(4): 1 inch on top, bottom and each side
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it
#let style-width = 3.25in               // L.R. 5.1(a)(5)(C): the style fills no more than the left side of the page
#let sig-indent = style-width + 0.25in  // the signature column starts right of the style column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (caption, signature; L.R. 5.1(a)(4))
#let pitch-double = 2 * pitch-single    // L.R. 5.1(a)(4): at least 1 1/2 spaces; double, as in the exemplar
#let caption-gap = pitch-double         // between the parts of the caption, and before the body

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italics, links).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption: court (L.R. 5.1(a)(5)(A)), docket line (B), style on the left (C), title (D)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "SOUTHERN DISTRICT OF FLORIDA")))
  if "division" in meta { line-block(align(center, text(weight: "bold", upper(meta.division)))) }
  // Docket line centered across the page (L.R. 5.1(a)(5)(B)): category, number, assigned judges.
  line-block(above: caption-gap, align(center, "CIVIL CASE NO. " + meta.case_number))
  // The style (L.R. 5.1(a)(5)(C)): each party's names, then its designation; "v." between the parties; "/" closes it.
  block(width: style-width, above: caption-gap, below: 0pt, {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
    line-block("/")
  })
  line-block(above: caption-gap, below: caption-gap, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); headings; unnumbered prayer paragraphs
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the number in a box of the
/// paragraph indent after the first-line indent, then the text).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// Each blank-line-separated chunk of markdown is one unit: a heading, a list, a numbered paragraph, or an
/// unnumbered paragraph. Unnumbered: a paragraph that starts with WHEREFORE (the prayer for relief) and the
/// paragraph under the DEMAND FOR JURY TRIAL heading. Numbering is applied per chunk, not with a `show par`
/// rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let body-chunks(body) = {
  let unnumbered = false
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      unnumbered = t.replace("#", "").trim() == "DEMAND FOR JURY TRIAL"
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else if unnumbered or t.starts-with("WHEREFORE") {
      body-par(none, inl(t))
    } else {
      n += 1
      body-par(n, inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 5.1(a)(6)): it never breaks across a page
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  line-block[Dated: #meta.date]
  line-block(above: pitch-double, left: sig-indent)[Respectfully submitted,]
  // L.R. 5.1(a)(6): name, street address, telephone, e-mail and bar number of each counsel.
  line-block(above: pitch-double, left: sig-indent, inl("By: /s/ " + meta.signature.signer))
  for l in meta.signature.lines { line-block(left: sig-indent, inl(l)) }
})

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let flsd-complaint(meta, body) = {
  // Paginated consecutively at the bottom center of each page (L.R. 5.1(a)(4)); the number in a single-spaced
  // line box, so it sits where Word's footer does.
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Headings at the body size and pitch, bold, no space of their own (the double pitch sets them off): level 1
  // centered capitals, level 2 centered, level 3 at the margin. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  caption(meta)
  // The lead-in (the paragraph before the first heading) is unnumbered.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  body-chunks(body)
  signature-block(meta)
}
