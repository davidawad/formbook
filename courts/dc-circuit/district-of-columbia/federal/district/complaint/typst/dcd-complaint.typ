// Complaint for the U.S. District Court for the District of Columbia (dcd).
// Rules: LCvR 5.1(c) (party and attorney identification), 5.1(d) (8 1/2 by 11, typed, double-spaced,
// 12-point, case number with judge initials); Fed. R. Civ. P. 8(a), 10(a), 10(b) (numbered paragraphs).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no typeface is required by LCvR 5.1(d); the vendored serif in fonts/
#let type-size = 12pt                   // LCvR 5.1(d): all pleadings in 12-pt type, footnotes too
#let page-w = 8.5in                     // LCvR 5.1(d): standard 8 1/2 by 11 inch format
#let page-h = 11in
#let margin = 1in                       // convention (no margin figure in LCvR 5.1); 1-inch margins all round
#let para-indent = 0.5in                // the paragraph number's box, and the first-line indent of unnumbered paragraphs
#let item-indent = 0.5in                // prayer items: the letter stands half an inch in, the text a box after it
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case-number column
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let right-inset = 0.1in                // the case-number column stands off the gutter
#let sig-left = 2.8in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // LCvR 5.1(d): double-spaced (Word's double, as in the filed exemplars)
#let caption-pad = pitch-single / 2     // caption: the rules stand half a line off the text

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dcd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (the body follows on the same page)
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE DISTRICT OF COLUMBIA")))
}

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names (name, residence or official address, as LCvR 5.1(c)(1) requires), then its
    // designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    // LCvR 5.1(d): the case number is followed by the judge's initials once a judge is assigned.
    let number = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
    line-block("Civil Action No. " + number)
    line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
    }
  }),
))

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: "Dated" at the left; "Respectfully submitted,", the signature line, the signer, firm and
/// role at the right; it never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    line-block(above: pitch-double, "________________________________")
    line-block(inl(meta.signature.signer))
    for l in meta.signature.firm { line-block(inl(l)) }
    line-block(inl(meta.signature.role))
  },
))

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b)): the
/// number in a box of the paragraph indent at the margin, the text after it.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: 0pt, [#box(width: para-indent, [#num.])#content])
})

/// The body: each blank-line-separated chunk of markdown that is neither a heading, a list nor a `>` line is one
/// numbered paragraph. A `>` line is an unnumbered paragraph; a list is lettered (A., B., ...). Numbering is applied
/// per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end.
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if t.starts-with(">") {
      // Unnumbered paragraph (for example a prayer's "WHEREFORE" lead-in).
      body-par(none, md(t.slice(1).trim()))
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

#let dcd-complaint(meta, body) = {
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
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
  // the body pitch (LCvR 5.1(d): double-spaced); prayer items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)

  // Headings at the body size and pitch, bold and centered (level 1 in capitals), level 3 bold at the margin; no
  // space of their own (the double pitch sets them off). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }
  // Prayer items: lettered A., B., ... (the markdown numbers are not printed).
  set enum(numbering: "A.")

  court-title()
  caption(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
}
