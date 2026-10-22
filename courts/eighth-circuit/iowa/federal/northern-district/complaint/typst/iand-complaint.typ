// Complaint for the U.S. District Court for the Northern District of Iowa (iand).
// Rules: N.D. Iowa LR 10(a) (8.5 x 11 inch paper), 10(b) (double spaced, one side, top margin of at least
// 1 inch, pages numbered at the bottom), 10(d) (caption with district, division, case number, litigants
// and a designation of the content); Fed. R. Civ. P. 8(a), 10(a), 10(b) (numbered paragraphs, one set of
// circumstances each); Fed. R. Civ. P. 38 (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Termes"        // no typeface is named in LR 10; Termes matches the audited exemplar (docs/FONTS.md)
#let type-size = 12pt                   // no size is named in LR 10; 12 point is the usual federal filing size
#let page-w = 8.5in                     // LR 10(a): 8 1/2 by 11 inch
#let page-h = 11in
#let margin = 1in                       // LR 10(b)(3): top margin of at least 1 inch (all sides set to 1 inch)
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number in a box of this width after the indent (Word: the next tab stop)
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-gap = 0.1in               // the party names stand off the ")" marks
#let caption-marks = 0.3in              // the column of ")" marks
#let caption-inset = 0.15in             // the case number and designation stand off the marks
#let list-indent = 0.5in                // prayer items: the letter at the indent
#let list-label = 0.4in                 // ... and the text hanging after a label box of this width
#let sig-indent = 3.0in                 // the signature block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/complaint.lua sets the same twips).
#let pitch-body = 24pt                  // LR 10(b)(1): double spaced; body text and headings
#let pitch-single = 13.8pt              // single spacing: court title, caption, signature
#let court-below = 24pt                 // the court title to the caption, and the caption to the text
#let list-space = 8.1pt                 // above and below the prayer's list
#let sig-space = 16.2pt                 // the signature block: above it, around the date, and below it
#let sig-gap = 8.1pt                    // between the groups of the signature block
#let footer-distance = 0.3in            // the page number line ends this far above the page edge

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iand-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One line block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// Single-spaced lines, one paragraph each, with no space between them. Used instead of forced line breaks.
#let lines(items, above: 0pt) = for (i, s) in items.enumerate() {
  line-block(above: if i == 0 { above } else { 0pt }, inl(s))
}

/// A list item's body without the paragraph breaks a loose list puts around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Court title: centered bold lines (LR 10(d): district and division).
#let court-title(meta) = {
  let ls = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE NORTHERN DISTRICT OF IOWA",
  )
  if "division" in meta { ls.push(upper(meta.division)) }
  for l in ls { line-block(align(center, text(weight: "bold", l))) }
}

/// Caption: the parties on the left, closed by a column of ")" marks (one per line); the case number
/// and the designation of the paper on the right (LR 10(d); Fed. R. Civ. P. 10(a)). Every line of the three
/// columns is a single-pitch line, the right column's on the left column's line grid (a blank line before the
/// judge and before the designation).
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(above: court-below, below: court-below, grid(
    columns: (caption-left, caption-marks, text-width - caption-left - caption-marks),
    pad(right: caption-gap, lines(rows)),
    lines(rows.map(_ => ")")),
    pad(left: caption-inset, {
      line-block[No. #meta.case_number]
      if "judge" in meta { line-block(above: pitch-single)[Judge: #meta.judge] }
      if "magistrate_judge" in meta { line-block(above: pitch-single)[Magistrate Judge: #meta.magistrate_judge] }
      line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
      if "jury_demand" in meta and meta.jury_demand { line-block(text(weight: "bold")[JURY DEMAND]) }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The signature block (after the body; a SIGNATURE marker in the markdown places it). Kept on one page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(breakable: false, width: text-width, above: sig-space, below: sig-space, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if "date" in meta { line-block(below: sig-space)[Dated: #meta.date] }
    block(above: 0pt, below: 0pt, pad(left: sig-indent, {
      line-block[Respectfully submitted,]
      if "party" in sig { lines(sig.party, above: sig-gap) }
      lines(sig.firm, above: sig-gap)
      lines(("By: /s/ " + sig.signer, sig.signer) + sig.at("lines", default: ()), above: sig-gap)
    }))
  })
}

/// Body chunks (blank-line separated markdown): a heading, a list, the SIGNATURE marker, or a paragraph.
/// Paragraphs are numbered when the sample says so (complaints; Fed. R. Civ. P. 10(b)); a paragraph that
/// starts with "<!--UNNUMBERED-->" (or "UNNUMBERED:") is not (the prayer's WHEREFORE and the jury demand).
/// Numbering is applied per chunk, not with a show rule: a show rule that re-wraps paragraph content recurses.
#let body(meta, src) = {
  let para-counter = counter("paragraph")
  let numbered = meta.at("numbered", default: false)
  let chunks = src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    let unnumbered = false
    for mark in ("<!--UNNUMBERED-->", "UNNUMBERED:") {
      if t.starts-with(mark) { unnumbered = true; t = t.slice(mark.len()).trim() }
    }
    if t == "<!--SIGNATURE-->" or t == "SIGNATURE" {
      signature-block(meta)
    } else if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items are lettered (A., B., ...): the letter at the indent, the text hanging after it. A list may
      // break across pages.
      block(above: list-space, below: list-space, inl(t))
    } else if numbered and not unnumbered {
      para-counter.step()
      par[#box(width: number-box)[#context para-counter.display().]#inl(t)]
    } else {
      par(inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let iand-complaint(meta, src) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // the page number in a single-pitch line box that ends 0.3 in above the page edge (Word: the footer distance)
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Every body paragraph opens with the half-inch indent, the numbered ones and the lead-in too.
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. The prayer's lettered list is written below (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // An abbreviation of single letters and slashes ("d/b/a", "c/o") is not broken at a slash (docx/complaint.lua: no
  // break opportunity there either).
  show regex("\\b\\p{L}(?:/\\p{L})+\\b"): it => box(it)

  set enum(numbering: "A.")
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: list-indent + list-label,
        [#h(list-indent)#box(width: list-label, numbering(it.numbering, n))#unloose(item.body)]))
      n += 1
    }
  }
  show list: it => for item in it.children {
    block(above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: list-indent + list-label,
      [#h(list-indent)#box(width: list-label)[•]#unloose(item.body)]))
  }

  // Headings, on the body pitch with no space of their own: level 1 centered bold caps; level 2 centered bold;
  // level 3 bold, flush left. Each is kept with what follows (sticky).
  show heading: it => {
    let b = if it.level == 1 { upper(it.body) } else { it.body }
    let b = text(size: type-size, weight: "bold", b)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
      set align(center) if it.level <= 2
      par(first-line-indent: 0pt, b)
    })
  }

  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    court-title(meta)
    caption(meta)
  }

  if "lead_in" in meta { par(inl(meta.lead_in)) }

  body(meta, src)
}
