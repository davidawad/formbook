// Complaint for the U.S. District Court for the District of Nebraska (ned).
// Rules: Fed. R. Civ. P. 10(a) (caption: court name, title, file number, Rule 7(a) designation) and 10(b)
// (numbered paragraphs); NECivR 10.1(a)(3) (the caption shows the paper's description and any jury demand);
// NECivR 11.1(a)(1)(A) (electronic signature format). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // NECivR names no face (checked 2026-10-14): the house standard, as both exemplars are set
#let type-size = 12pt
#let page-w = 8.5in                     // NECivR 10.1(b)(1): 8 1/2 by 11 inch paper (paper filings)
#let page-h = 11in
#let margin = 1in
#let para-indent = 0.5in                // first-line indent of numbered and unnumbered paragraphs
#let number-box = 0.4in                 // the paragraph number's box after the indent; the text follows it
#let item-indent = 0.5in                // prayer items: the letter half an inch in, the text a box after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let right-inset = 0.1in                // the case-number column stands off the gutter
#let designation-indent = 1.5in         // each party's designation ("Plaintiff,") stands in from the names
#let sig-left = 2.7in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let footer-size = 10pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double-spaced body (no NECivR spacing rule; both exemplars are Word's double)
#let pitch-footer = 11.5pt              // a footer line: 1.15 x the footer size
#let footer-gap = 3pt                   // between the page number and the title / case-number line
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line off the text

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ned-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic, names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  })

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page after the first: the page number centered, then the paper's title in capitals at the left
/// and "Case No." with the number at the right.
#let footer-block(title, case-number) = context {
  if counter(page).get().first() > 1 {
    set text(size: footer-size, ..edges(pitch-footer))
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, align(center, counter(page).display()))
    block(width: 100%, above: footer-gap, below: 0pt, grid(columns: (1fr, auto), upper(title), [Case No. #case-number]))
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel (top left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(above: 1.5 * pitch-double, align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE DISTRICT OF NEBRASKA")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = block(above: pitch-double, below: pitch-single, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation)))
    }
  }),
  pad(left: right-inset, {
    line-block[Case No. #meta.case_number]
    line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
    // NECivR 10.1(a)(3): a jury demand must be noted in the pleading caption.
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, text(weight: "bold", "Jury Trial Demanded"))
    }
    if "trial_location" in meta and meta.trial_location != none {
      line-block[Trial Location: #inl(meta.trial_location)]
    }
  }),
))

#let cover(meta) = {
  // Counsel block: upper left, single-spaced, as the filed exemplar has it. Not a rule of this court.
  for l in meta.counsel { line-block(inl(l)) }
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block in NECivR 11.1(a)(1)(A) order: "s/ name", bar number, attorney for, firm and contact lines;
/// "Dated" at the left. It never breaks across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block[Dated: #inl(meta.date)],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-single, [s/ #inl(sig.signer)])
      line-block[Bar Number: #inl(sig.bar_number)]
      line-block[Attorney for #inl(sig.attorney_for)]
      for l in sig.firm { line-block(inl(l)) }
    },
  ))
}

/// A heading as its own sticky block (a heading never ends a page). Level 1: centered bold capitals; level 2:
/// centered bold; both a line of the double pitch. Level 3: a claim sub-line, centered, in a single line box.
#let heading-block(t) = {
  let lvl = t.match(regex("^#+")).text.len()
  let txt = t.replace(regex("^#+[ \\t]*"), "")
  if lvl <= 2 {
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
      set par(first-line-indent: 0pt)
      align(center, text(weight: "bold", inl(if lvl == 1 { upper(txt) } else { txt })))
    })
  } else {
    line-block(sticky: true, align(center, inl(txt)))
  }
}

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b)): the
/// first-line indent, the number in a box, the text after it. `last`: the paragraph before the signature, kept whole
/// and on the page of the signature (a signature never starts a page alone).
#let body-par(num, content, last: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: last,
  breakable: not last, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: number-box, [#num.])#content])
})

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; a chunk starting with "^ " is unnumbered (the WHEREFORE lead-in and
/// the jury demand are not numbered in the exemplar). Lists are lettered A., B., ... (the prayer). Numbering is
/// applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end.
#let allegations(body) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if t.starts-with("^") {
      body-par(none, md(t.slice(1).trim()), last: last)
    } else {
      n += 1
      body-par(n, md(t), last: last)
    }
  }
}

#let ned-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); prayer items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  // Prayer items: lettered A., B., ... (the markdown numbers are not printed).
  set enum(numbering: "A.")

  cover(meta)
  allegations(body)
  signature-block(meta)
}
