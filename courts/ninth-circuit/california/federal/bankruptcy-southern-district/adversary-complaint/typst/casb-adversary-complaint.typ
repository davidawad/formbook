// U.S. Bankruptcy Court, Southern District of California (casb): adversary complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CASB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. Every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // CASB-FORM-002: vendored in fonts/; see README.md (font is a choice, not a rule text)
#let type-size = 12pt                   // CASB-FORM-002: 12 point; the rule text is not verified, see README.md
#let lines-per-page = 27                // CASB-FORM-003: pleading paper, 28 numbered lines (exemplars)
#let page-w = 8.5in                     // CASB-FORM-001 (FRBP 9004(a), legibility; 8 1/2 x 11 paper)
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let number-width = 1in                 // the line numbers stand right-aligned in the first inch of the page
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let number-box = 0.45in                // the allegation number's box: the text starts 0.95 in from the margin
#let item-indent = 0.5in                // list items: the label half an inch in
#let item-box = 0.7in                   // the label's box: the item's text hangs 1.2 in from the margin
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column's rule and the case column
#let caption-inset = 10pt               // the party text stands off the column's rule
#let right-inset = 0.1in                // the case column's text stands this far in
#let counsel-lines = 7                  // the court title starts after at least this many numbered lines
#let sig-left = 2.6in                   // the date column of the signature block
#let page-size = 10pt                   // the footer's page number
#let footer-size = 9pt                  // the footer's title and case number
#let footer-top = 4pt                   // the footer starts this far below the last numbered line
#let footer-gap = 2pt                   // between the footer's lines

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // CASB-FORM-003: double spacing; the numbered lines are this pitch
#let pitch-single = 12pt                // counsel, caption and signature: single-spaced, exactly half a numbered line, so
                                        // every second line keeps to the grid of the numbers
#let pitch-page = 11.5pt                // the footer's page number line, 1.15 x its size
#let pitch-footer = 10.4pt              // the footer's title and case number lines
#let half-gap = 12pt                    // between the caption's parts and the signature's groups
#let drop = 9.6pt                       // a single-spaced block starts this far into its numbered line, so that its first
                                        // line (and every second after it) stands on the line number's baseline
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("casb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height (a zero-width space holds it).
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == [] or body == "" { sym.zws } else { body }
})

/// A double-spaced paragraph (one or more numbered lines) with a first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A block of single lines starting `drop` into its numbered line, at least `min` numbered lines high, and `pad` more than its lines. It is not
/// rounded up to whole numbered lines: Word cannot round a block of wrapped lines, so the text after it follows it
/// directly in both engines.
#let single-block(min: 0, pad: 0pt, c) = context {
  let h = measure(width: text-width, c).height + drop + pad
  block(width: 100%, height: calc.max(min * pitch, h), inset: (top: drop), above: 0pt, below: 0pt, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, on the baseline of its line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-width, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer: page number, then the paper's title and the case number, each centered on its own line
/// (the title is too long for a row shared with the case number at this size).
#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-top,
  block(width: text-width, {
    set par(first-line-indent: 0pt)
    block(width: 100%, below: 0pt,
      align(center, text(size: page-size, ..edges(pitch-page), context counter(page).display())))
    set text(size: footer-size, ..edges(pitch-footer))
    block(width: 100%, above: footer-gap, below: 0pt, align(center, upper(inl(title))))
    block(width: 100%, above: footer-gap, below: 0pt, align(center, [CASE NO. #case-number]))
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption (FRBP 7010 and Form 416; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// Counsel identification, upper left, from line 1. More counsel lines push the court title down, half a line below the last.
#let counsel-block(meta) = single-block(min: counsel-lines, pad: half-gap, for l in meta.counsel { line-block(inl(l)) })

#let court-title(meta) = {
  let lines = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { block(width: 100%, above: 0pt, below: 0pt, align(center, strong(l))) }
}

/// A list of parties: each side's names, then its designation; "vs." between the sides.
#let party-lines(sides) = {
  let rows = ()
  for (k, p) in sides.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  rows
}

/// The caption, a numbered line below the court title: the debtor ("In re"), then
/// the adversary parties, in a column ruled on the right and bottom; the case numbers, the title of the paper and the
/// judge beside it.
#let caption(meta) = block(width: 100%, above: pitch, below: 0pt, single-block(grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: half-gap), {
    for l in ("In re",) + party-lines(meta.in_re) { line-block(inl(l)) }
    for (j, l) in party-lines(meta.caption).enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
  }),
  pad(left: right-inset, {
    line-block[Case No. #meta.case_number]
    line-block[Chapter #meta.chapter]
    if "adv_number" in meta { line-block(above: half-gap)[Adv. Proc. No. #meta.adv_number] }
    line-block(above: half-gap, strong(inl(meta.brief_title)))
    if "judge" in meta { line-block(above: half-gap, inl(meta.judge)) }
  }),
)))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings, one numbered line each (more for a long one): level 1 a centered section in capitals; level 2 a
/// centered bold sub-heading; level 3 bold, at the margin. Sticky: a heading never ends a page.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    align(center, strong(it.body))
  } else { strong(it.body) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b), applied by FRBP 7010). Headings and lists
/// are rendered unnumbered, list items lettered (a), (b), ... Numbering is applied per chunk, not with a `show par`
/// rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#md(t)])
    }
  }
}

// The signature block, a numbered line below the text, is kept whole: it never splits across a page break. The
// space above it is an inset, kept at the top of a page as Word keeps the space above a table's first line.
#let signature-block(meta) = block(breakable: false, width: 100%, above: 0pt, below: 0pt, inset: (top: pitch + drop), grid(
  columns: (sig-left, 1fr),
  column-gutter: caption-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    for (j, l) in meta.signature.firm.enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
    line-block(above: half-gap, [By: /s/ #meta.signature.signer])
    for l in (meta.signature.signer,) + meta.signature.lines { line-block(inl(l)) }
  },
))

#let casb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch; list items as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 157(b)"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  set enum(numbering: "(a)")

  cover(meta)
  // The unnumbered lead-in ("Plaintiffs ... allege as follows:") follows the caption on the same page.
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  allegations(body)
  // Unnumbered closing paragraph (the prayer), kept whole with the signature block, which never stands on a page
  // alone.
  if "closing" in meta { block(sticky: true, breakable: false, above: 0pt, below: 0pt, body-par(inl(meta.closing))) }
  signature-block(meta)
}
