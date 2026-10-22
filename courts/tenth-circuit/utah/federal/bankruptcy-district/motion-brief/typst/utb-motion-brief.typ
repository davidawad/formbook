// Motion with supporting memorandum for the United States Bankruptcy Court for the District of Utah (utb).
// LBR 9013-1: the motion and any supporting memorandum are one document; DUCivR 10-1 (format; applies in
// bankruptcy through LBR 1001-1(a)); DUCivR 7-1 (word limit and certificate of compliance). See ../README.md and
// ../../rules.md for the citations and the status of each rule. Content-agnostic: every case-specific word comes
// from the sample.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // UTB-FORM-004: no rule names a face; Times New Roman (vendored), the house standard (docs/FONTS.md)
#let type-size = 12pt                     // UTB-FORM-006 via UTB-FORM-003/004 (DUCivR 10-1(3), LBR 5005-3(a)(4)): at least 12 point
#let top-margin = 1.5in                   // UTB-FORM-003 (DUCivR 10-1(1)): top margin of at least 1 1/2 inches
#let side-margin = 1in                    // UTB-FORM-003 (DUCivR 10-1(1), LBR 5005-3(a)(3)): at least 1 inch
#let bottom-margin = 1in                  // holds the page number (LBR 5005-3(a)(7))
#let footer-distance = 0.5in              // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                  // first-line indent of body paragraphs; a list's label box
#let caption-left = 3.3in                 // width of the party column of the caption (Form 416D)
#let caption-gutter = 0.25in              // between the caption's two columns
#let caption-right-pad = 10pt             // the party column's text stands this far from its right rule
#let caption-bottom-pad = 8pt             // and this far above its bottom rule
#let caption-number-indent = 0.15in       // the case numbers stand this far right of the gutter
#let caption-rule = 0.75pt                // the party column's right and bottom rules
#let sig-column = 3.4in                   // the signature block's right column starts here (left column 3.2 in + 0.2 in)
#let footnote-size = 12pt                 // UTB-FORM-004 (DUCivR 10-1(3)): the 12 point minimum includes footnotes

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/utb-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 24pt                    // UTB-FORM-003 (DUCivR 10-1(4)): double-spaced, 24 pt at 12 pt
#let pitch-single = 13.8pt                // single-spaced lines: counsel, court title, caption, title, headings, signature
#let part-gap = 24pt                      // between the parts of the first page (counsel, court, caption, title, body)
#let h-above = 18pt                       // headings: single-spaced, bold (level 1 centered), kept with the text after them
#let h-below = 6pt
#let sig-above = 24pt                     // the paragraph before a signature block to the block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Block markdown.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline markdown (names with *et al.*, and so on), without the paragraph breaks cmarker puts around it.
#let inl(s) = {
  let body = md(s)
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch paragraph with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, bold: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set text(weight: "bold") if bold
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, c))
})

/// A body paragraph on the body pitch, its first line indented.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, [#h(para-indent)#c]))

// ---------------------------------------------------------------------------
// Cover: counsel block, court title, caption (Form 416D), title
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF UTAH")
  if "division" in meta and meta.division != none and meta.division != "" {
    lines.push(upper(meta.division) + " DIVISION")
  }
  block(width: 100%, above: part-gap, below: part-gap, for l in lines { sline(centered: true, bold: true, l) })
}

/// Form 416D: the debtor, then the adversary parties (and any third-party claim) in the left column, ruled on its
/// right and at its foot; on the right the case numbers and the judge. A blank single line between the elements.
#let caption(meta) = {
  let left = (sline[In re:],)
  for (k, d) in meta.caption.debtors.enumerate() { left.push(sline(above: if k == 0 { pitch-single } else { 0pt }, inl(d))) }
  left.push(sline(above: pitch-single, inl(meta.caption.debtor_designation)))
  let groups = meta.caption.parties
  if "third_party" in meta.caption and meta.caption.third_party != none { groups = groups + meta.caption.third_party }
  for (k, p) in groups.enumerate() {
    if k > 0 { left.push(sline(above: pitch-single, [v.])) }
    for (j, n) in p.names.enumerate() { left.push(sline(above: if j == 0 { pitch-single } else { 0pt }, inl(n))) }
    left.push(sline(above: pitch-single, inl(p.designation)))
  }
  let bk = if meta.case.bankruptcy_number == "" { "________" } else { meta.case.bankruptcy_number }
  let adv = if meta.case.adversary_number == "" { "________" } else { meta.case.adversary_number }
  let right = (
    sline[Bankruptcy No. #bk],
    sline[Chapter #meta.case.chapter],
    sline(above: pitch-single)[Adversary Proceeding No. #adv],
    sline(above: pitch-single)[Hon. #meta.case.judge],
  )
  block(width: 100%, above: 0pt, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-right-pad, bottom: caption-bottom-pad), left.join()),
    [],
    pad(left: caption-number-indent, right.join()),
  ))
}

#let cover(meta) = {
  for c in meta.counsel { sline(inl(c)) }
  court-title(meta)
  caption(meta)
  block(width: 100%, above: part-gap, below: part-gap, sline(centered: true, bold: true, inl(upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Signature
// ---------------------------------------------------------------------------

/// "DATED ..." at the margin, the firm beside it at the signature column; the signer and the lines under the firm.
#let signature-lines(meta) = {
  let s = meta.signature
  block(width: 100%, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    par(first-line-indent: 0pt, hanging-indent: sig-column, [#box(width: sig-column)[DATED #(s.date).]#inl(s.firm)])
  })
  sline(above: pitch-single, left: sig-column)[/s/ #inl(s.signer)]
  for l in s.lines { sline(left: sig-column, inl(l)) }
}

// ---------------------------------------------------------------------------
// Body: the motion and its memorandum, one document (LBR 9013-1)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is a heading (kept with the chunk after it), a markdown list, a body
/// paragraph, or one of two markers: <!-- SIGNATURE --> places the signature block after the paragraph before it
/// (kept on one page with it), <!-- PAGEBREAK --> starts a new page (the certificates). Paragraphs are not
/// numbered: a memorandum is not an allegation.
#let body-blocks(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, t) in chunks.enumerate() {
    let before-signature = i + 1 < chunks.len() and chunks.at(i + 1) == "<!-- SIGNATURE -->"
    let piece = if t == "<!-- SIGNATURE -->" {
      // Placed with the paragraph before it (before-signature, below): every marker follows a paragraph.
      none
    } else if t == "<!-- PAGEBREAK -->" {
      pagebreak(weak: true)
    } else if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else {
      body-par(inl(t))
    }
    if before-signature {
      // The paragraph before a signature stays on the signature's page, whole: a signature alone is not a filing.
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; signature-lines(meta) })
    } else {
      piece
    }
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let utb-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    // The page number centered at the foot of every page (LBR 5005-3(a)(7)), in a single-pitch line box that ends
    // footer-distance above the page edge.
    footer-descent: bottom-margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number; a list's label in a box of the paragraph indent.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number too ("¶¶ 38, 54"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  show footnote.entry: set text(size: footnote-size, ..edges(pitch-single))

  // Headings single-spaced at the type size, bold (level 1 centered, the others at the margin), kept with the text
  // after them.
  show heading: it => block(width: 100%, sticky: true, above: h-above, below: h-below, {
    set text(size: type-size, weight: "bold", ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, it.body) } else { it.body }
  })

  cover(meta)
  body-blocks(meta, body)
}
