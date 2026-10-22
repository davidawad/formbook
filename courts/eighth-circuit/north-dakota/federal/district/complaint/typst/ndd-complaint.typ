// Complaint for the U.S. District Court for the District of North Dakota (ndd).
// Rules: D.N.D. Civil Rule 5.1(B) (12-point type or larger, double-spaced, one-inch margins, page numbers at
// the bottom); Civil Rule 3.1(A) (the division is designated in the caption of a complaint); Fed. R. Civ. P. 10(a)
// (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Civil Rule 5.1(B)(2) sets a size, not a typeface; Times New Roman, as both exemplars
#let type-size = 12pt                   // Civil Rule 5.1(B)(2): 12-point font or larger
#let page-w = 8.5in                     // Civil Rule 5.1(B)(1): standard size paper
#let page-h = 11in
#let margin = 1in                       // Civil Rule 5.1(B)(2): minimum one-inch margin
#let para-indent = 0.5in                // first-line indent of every body paragraph; the number's box after it
#let num-box = 0.5in                    // numbered paragraphs: the number in a box of this width, the text after it
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.3in              // the ")" column
#let caption-inset = 0.2in              // the right column stands off the ")" column
#let sig-indent = 3.25in                // the firm and signer lines stand in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // Civil Rule 5.1(B)(2): double-spaced (Word's double, 27.6 pt in both exemplars)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ndd-complaint: the sample must start with a YAML frontmatter block") }
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
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = for s in (meta.court, meta.district, meta.division) {
  line-block(align(center, text(weight: "bold", upper(s))))
}

/// Party column (names, designation, "v." between parties), a column of ")" marks, and the case
/// number, title and jury legend. Each row is one single-spaced line, so the two columns align.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(width: 100%, above: pitch-single, below: pitch-single, grid(
    columns: (caption-left, caption-paren, 1fr),
    column-gutter: 0pt,
    { for r in rows { line-block(inl(r)) } },
    { for r in rows { line-block(")") } },
    pad(left: caption-inset, {
      let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
      line-block[Case No. #case-no]
      line-block(above: pitch-single, text(weight: "bold", upper(meta.title)))
      if "jury_demand" in meta and meta.jury_demand {
        line-block(text(weight: "bold", "JURY DEMAND"))
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, signature
// ---------------------------------------------------------------------------

/// The signature block, never split across a page: an optional "Dated" line at the margin, then the optional
/// closing, the firm lines and the signer lines in the right half, a double line between the groups.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let dated = "date" in meta and meta.date != ""
  if dated { line-block[Dated: #meta.date] }
  // the space below the "Dated" line sits on a block around the pad: a space at the start of a container is dropped
  block(width: 100%, above: if dated { pitch-double } else { 0pt }, below: 0pt, pad(left: sig-indent, {
    let gap = 0pt
    if "closing" in meta {
      line-block(inl(meta.closing))
      gap = pitch-double
    }
    for (k, l) in meta.signature.firm.enumerate() { line-block(above: if k == 0 { gap } else { 0pt }, inl(l)) }
    for (k, l) in meta.signature.lines.enumerate() {
      line-block(above: if k == 0 { pitch-double } else { 0pt }, inl(l))
    }
  }))
})

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b)): after
/// the first-line indent the number in a box of num-box, then the text.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: num-box, [#num.])#content])
})

/// Blank-line-separated markdown chunks become: a heading (unnumbered), a list (lettered (a), (b), ...),
/// a WHEREFORE paragraph (unnumbered, the prayer), or else a numbered allegation (Fed. R. Civ. P. 10(b)).
/// Numbering is per chunk, not a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: para-indent, md(t))
    } else if t.starts-with("WHEREFORE") {
      body-par(none, inl(t))
    } else {
      n += 1
      body-par(n, inl(t))
    }
  }
}

#let ndd-complaint(meta, body) = {
  assert("division" in meta, message: "ndd-complaint: the caption must designate the division (Civil Rule 3.1(A))")

  // Civil Rule 5.1(B)(1): page numbers at the bottom, centered, in a single-spaced line box (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (Civil Rule 5.1(B)(2): double-spaced); list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: num-box)

  // Headings at the body size and pitch: level 1 centered bold caps; level 2 a centered bold sub-heading; level 3
  // bold italic at the margin; no space of their own. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }
  set enum(numbering: "(a)")

  court-title(meta)
  caption(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
}
