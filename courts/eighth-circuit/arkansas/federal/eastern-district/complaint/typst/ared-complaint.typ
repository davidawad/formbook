// Complaint for the U.S. District Court for the Eastern District of Arkansas (ared).
// Rules: Fed. R. Civ. P. 8(a), 10(a)-(b), 11(a), 38(b); E.D. Ark. Local Rule 5.5(a) (type not less than
// elite, double space, letter size, one side) and 5.5(c)(1) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
// No rule names a font (LR 5.5(a) sets only a minimum); vendored in fonts/, the face of the exemplars.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                   // LR 5.5(a): type not less than elite (12 cpi); 12 pt is the working equivalent
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let margin = 1in                       // no margin rule in LR 5.5; 1 inch on every side, as in the exemplar
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let label-box = 0.5in                  // a paragraph number or list letter, and the space after it (Word: a tab)
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case number
#let caption-inset = (right: 10pt, bottom: 8pt) // the party column's text stands off its rules
#let case-pad = 0.1in                   // the case number and title stand off the gutter
#let sig-left = 2.6in                   // the signature block: "Dated:" column, then the signature at right
#let sig-gap = 12pt                     // signature block: between "Respectfully submitted,", the firm and the signer

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/complaint.lua sets the same twips).
#let pitch = 24pt                       // LR 5.5(a): double space (body, headings, court title)
#let pitch-single = 13.8pt              // single spacing: caption and signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ared-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One line block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// Several single-spaced lines, one paragraph each; an empty item leaves one blank line before the next.
#let lines(items, above: 0pt) = {
  let gap = above
  for s in items {
    if s == "" { gap = pitch-single } else {
      line-block(above: gap, inl(s))
      gap = 0pt
    }
  }
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
// Cover: court title, caption, title of the paper (no separate cover page)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let rows = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF ARKANSAS")
  if "division" in meta and meta.division != none { rows.push(upper(meta.division)) }
  for r in rows { line-block(align(center, text(weight: "bold", r))) }
}

#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(above: pitch, below: pitch, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: caption-inset, {
      // Each party: its names, then its designation; "v." between the parties, a line above and below it.
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { line-block(above: pitch-single, below: pitch-single)[v.] }
        lines(p.names + (p.designation,))
      }
    }),
    [],
    pad(left: case-pad, {
      line-block[Case No. #meta.case_number]
      line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
      if "jury_demand" in meta and meta.jury_demand {
        line-block(above: pitch-single, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// "Dated:" at left; at right "Respectfully submitted,", the firm, "By: /s/" and the signer, then the lines. One
/// unbreakable block, a blank double-spaced line above it.
#let signature-block(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(above: pitch, below: 0pt, breakable: false, grid(
    columns: (sig-left, 1fr),
    if "date" in meta and meta.date != none { line-block[Dated: #meta.date] },
    {
      line-block[Respectfully submitted,]
      lines(meta.signature.firm, above: sig-gap)
      lines(("By: /s/ " + meta.signature.signer,) + meta.signature.lines, above: sig-gap)
    },
  ))
}

/// One list item: the label at the paragraph indent, the text hanging after the label box. `sticky`: kept on the
/// page with the block after it.
#let list-item(label, body, sticky: false) = block(sticky: sticky, above: 0pt, below: 0pt, pad(left: para-indent,
  par(first-line-indent: 0pt, hanging-indent: label-box, [#box(width: label-box, label)#unloose(body)])))

/// Lists: lettered (a), (b), ... (bullets for an unordered list).
#let list-items(it, sticky-last) = {
  let n = if it.func() == enum and it.start != auto { it.start } else { 1 }
  for (i, item) in it.children.enumerate() {
    if item.has("number") and item.number != none { n = item.number }
    let label = if it.func() == enum { numbering("(a)", n) } else { [•] }
    list-item(label, item.body, sticky: sticky-last and i == it.children.len() - 1)
    n += 1
  }
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph. A chunk that starts with "~ " is an
/// unnumbered paragraph (for example a prayer's lead-in); the marker is removed. Headings and lists
/// are rendered unnumbered. Every block is double-spaced with no space between blocks; the last one stays on
/// the page of the signature block (sticky), so the signature never stands alone.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      show enum: it => list-items(it, last)
      show list: it => list-items(it, last)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("~ ") {
      block(sticky: last, above: 0pt, below: 0pt, par(inl(t.slice(2))))
    } else {
      para-counter.step()
      let num = box(width: label-box, context [#para-counter.display().])
      block(sticky: last, above: 0pt, below: 0pt, par[#num#inl(t)])
    }
  }
}

#let ared-complaint(meta, body) = {
  let para-counter = counter("allegation")

  // Page number centered in the bottom margin, in a single-spaced line box on the baseline of Word's footer (0.3 in
  // footer distance; footer-descent 51 % of the margin).
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
    footer-descent: 51%,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. The lettered lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch, list-indent: none)

  // Headings, one double-spaced line each, no space of their own; sticky: a heading never ends a page.
  // Level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the left.
  show heading: it => {
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    set par(first-line-indent: 0pt)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, text(size: type-size, b))
  }


  court-title(meta)
  caption(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(above: 0pt, below: 0pt, par(inl(meta.lead_in)))
  }

  allegations(body, para-counter)

  signature-block(meta)
}
