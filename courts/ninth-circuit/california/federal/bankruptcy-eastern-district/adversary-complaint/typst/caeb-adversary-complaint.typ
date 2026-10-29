// Adversary complaint for the U.S. Bankruptcy Court, Eastern District of California (caeb).
// Rules: FRBP 7010 (FRCP 10 applies; the caption must substantially conform to Official Form 416A), FRCP 10(a)-(b),
// FRBP 9004(a)-(b) (caption), LBR 9004-1 (counsel block, signatures), LBR 9004-2 (paper, numbered and double-spaced
// lines, 12-14 point type, margins, clerk's stamp space, page numbers, page total), LBR 7038-1(b) (jury demand
// immediately after the title). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LBR 9004-2(a)(4) names Times New Roman; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 13pt                   // LBR 9004-2(a)(4): not less than 12 and not more than 14 point
#let lines-per-page = 27                // the pleading form used by the exemplar and by CAND; the LBR sets no count
#let page-w = 8.5in                     // LBR 9004-2(a)(1): white letter-size paper
#let page-h = 11in
#let top-margin = 72pt                  // LBR 9004-2(b)(2): every margin not less than one-half inch
#let left-margin = 1.5in                // room for the line numbers and the pleading rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent; an allegation's number stands here
#let number-box = 0.5in                 // the allegation number's box: the text starts an inch in
#let item-indent = 0.5in                // list items: the label half an inch in, the text a box after it
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the caption's columns, and the signature block's
#let caption-inset = 10pt               // the party text stands off the box's rule
#let debtor-pad = 10pt                  // between the debtors and the party box
#let caption-pad = 8pt                  // the party box's bottom rule stands this far below its last line
#let right-inset = 0.1in                // the right column's text stands this far in
#let counsel-width = 4.0in              // keeps the counsel block clear of the clerk's stamp space (LBR 9004-2(b)(3))
#let counsel-lines = 7                  // the court title starts on line 8 unless counsel needs more room
#let total-top = 0.5in                  // LBR 9004-2(c)(4): the page total in the upper left corner of page 1
#let sig-left = 2.6in                   // the signature block's date column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LBR 9004-2(a)(2), (b)(1): numbered lines, double spaced
#let pitch-single = 12pt                // counsel, caption, quotations and signature are single spaced (LBR 9004-2(b)(1)): two lines to a numbered line
#let single-size = 12pt                 // their type (LBR 9004-2(a)(4): 12 to 14 point), solid on the 12 pt pitch; 13 pt type
                                        // would set them closer than solid (DEF-FORM-004)
#let half-gap = 12pt                    // a blank half line in the caption and the signature block
#let drop = 9.6pt                       // a block of single lines starts this far below a numbered line's top, so its first line
                                        // (and every second) stands on a line number's baseline (0.8 x 24 pt = 9.6 + 0.8 x 12 pt)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the page number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("caeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// A metadata value as a list (a YAML list or one string).
#let as-list(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line block (a paragraph of its own), with explicit space above it, in `size` type.
#let line-block(above: 0pt, size: single-size, body) = block(width: 100%, above: above, below: 0pt, {
  set text(size: size, ..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A double-spaced paragraph with a first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// The numbered lines a block of single lines fills: `drop`, `n` lines and `gaps` half lines, rounded up.
#let grid-rows(n, gaps) = calc.ceil((drop + n * pitch-single + gaps * half-gap) / pitch)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, ending half an inch left of the text, on the
/// baselines of the double-spaced text.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Bottom center page number (LBR 9004-2(c)(3)), a single line 8 pt below the last numbered line; page 1 is the page
/// bearing the caption.
#let page-number() = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, line-block(size: type-size, align(center, context counter(page).display()))),
)

/// Upper left corner of the first page: the total number of pages (LBR 9004-2(c)(4)).
#let page-total() = context if counter(page).get().first() == 1 {
  place(top + left, dx: left-margin, dy: total-top,
    block(width: counsel-width, line-block(size: type-size)[Page total: #counter(page).final().first()]))
}

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The counsel block, upper left (LBR 9004-1(b)), clear of the clerk's stamp space: single lines from line 1's
/// baseline, filling at least lines 1-7; more counsel lines push the court title down by whole numbered lines, half
/// a line kept below the last.
#let counsel-block(meta) = {
  let lines = as-list(meta.counsel)
  let rows = calc.max(counsel-lines, grid-rows(lines.len(), 1))
  block(width: counsel-width, height: rows * pitch, above: 0pt, below: 0pt, inset: (top: drop),
    for l in lines { line-block(inl(l)) })
}

#let court-title(meta) = for l in as-list(meta.court) {
  block(width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(inl(l)))))
}

/// The caption (FRBP 9004(b), Official Form 416A): the debtors above the party box; the parties in the box, ruled
/// right and below, "v." between them (FRCP 10(a)); case number, chapter, adversary number, title and jury demand
/// (LBR 7038-1(b)) at right. The party box fills its column down to the caption's foot, as a Word table cell does.
#let caption(meta) = {
  let parties = {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for n in as-list(p.names) { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }
  let right = {
    for l in as-list(meta.caption.at("case-lines")) { line-block(inl(l)) }
    for (j, l) in as-list(meta.caption.at("chapter-lines")).enumerate() {
      line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l))
    }
    line-block(above: half-gap)[Adv. Proc. No.: #meta.caption.adversary]
    if "dcn" in meta.caption and meta.caption.dcn != none { line-block(above: half-gap)[DCN: #meta.caption.dcn] }
    line-block(above: half-gap, strong(upper(inl(meta.brief_title))))
    if "jury_demand" in meta and meta.jury_demand { line-block(above: half-gap, strong[DEMAND FOR JURY TRIAL]) }
  }
  block(width: 100%, above: pitch + drop, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    grid.cell(inset: (right: caption-inset, bottom: debtor-pad),
      for l in as-list(meta.caption.debtors) { line-block(inl(l)) }),
    grid.cell(rowspan: 2, []),
    grid.cell(rowspan: 2, inset: (left: right-inset), right),
    grid.cell(inset: (right: caption-inset, bottom: caption-pad), stroke: (right: 0.75pt, bottom: 0.75pt), parties),
  ))
}

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings, each in numbered lines: level 1 a centered section in capitals; level 2 a bold centered sub-heading;
/// level 3 bold italic. Sticky: a heading never ends a page.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    align(center, strong(it.body))
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
}

/// One signature block (LBR 9004-1(c)): the date at left; "Respectfully submitted,", the firm and the signer at
/// right, single lines from a line number's baseline, filling whole numbered lines.
#let signature-block(date, sig) = {
  let firm = as-list(sig.firm)
  let lines = as-list(sig.at("lines", default: ()))
  let rows = grid-rows(1 + firm.len() + 2 + lines.len(), 2)
  block(width: 100%, height: rows * pitch, above: 0pt, below: 0pt, inset: (top: drop), grid(
    columns: (sig-left, caption-gutter, 1fr),
    line-block[Dated: #date],
    [],
    {
      line-block[Respectfully submitted,]
      for (j, l) in firm.enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
      line-block(above: half-gap)[By: /s/ #sig.signer]
      line-block(sig.signer)
      for l in lines { line-block(inl(l)) }
    },
  ))
}

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (FRCP 10(b)). Headings and lists are rendered unnumbered; a chunk the sample marks with a
/// leading "^" (a lead-in such as "WHEREFORE") is an unnumbered paragraph. Numbering is applied per chunk, not with a
/// `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, tail) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      md(t)
      if last { tail }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      if last {
        // the last item goes with the signature blocks, so they never stand on a page alone
        let starts = t.matches(regex("\\n(\\d+\\.|[-*+])[ \\t]"))
        let cut = if starts.len() > 0 { starts.last().start } else { 0 }
        if cut > 0 { pad(left: item-indent, md(t.slice(0, cut))) }
        block(breakable: false, width: 100%, above: 0pt, below: 0pt, { pad(left: item-indent, md(t.slice(cut).trim())); tail })
      } else {
        pad(left: item-indent, md(t))
      }
    } else {
      let piece = if t.starts-with("^") {
        body-par(md(t.replace(regex("^\\^[ \\t]?"), "")))
      } else if t.starts-with(">") {
        // A quotation is single spaced (LBR 9004-2(b)(1)) and indented on both sides.
        block(width: 100%, above: drop, below: 0pt, inset: (left: para-indent, right: para-indent), {
          set text(size: single-size, ..edges(pitch-single))
          par(first-line-indent: 0pt, md(t.split(regex("\\r?\\n")).map(l => l.trim(">", at: start).trim()).join("\n")))
        })
      } else {
        n += 1
        body-par([#box(width: number-box, [#n.])#md(t)])
      }
      // the last paragraph goes with the signature blocks, so they never stand on a page alone
      if last { block(breakable: false, width: 100%, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
    }
  }
}

#let caeb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: {
      page-number()
      page-total()
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch; list items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: item-indent)
  // A doubled sign stays with its number ("§§ 9-406"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  // Markdown lists become (a), (b), ...
  set enum(numbering: "(a)")

  cover(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  // The signature blocks stay together, a numbered line above each, and with the last paragraph or item.
  allegations(body, if "signature" in meta {
    block(breakable: false, width: 100%, above: 0pt, below: 0pt, for sig in as-list(meta.signature) {
      block(width: 100%, height: pitch, above: 0pt, below: 0pt)
      signature-block(meta.date, sig)
    })
  })
}
