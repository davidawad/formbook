// Adversary complaint for the U.S. Bankruptcy Court, Western District of Texas (txwb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7010 (Fed. R. Civ. P. 10 applies; caption per Form 416A/B/D),
// Fed. R. Civ. P. 10(b) (numbered paragraphs). Local rules: no format rule for this doc type was located (see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // convention (FRBP 9004(a): legible; no point size in the rule)
#let margin = 1in                       // convention; the exemplar's margins are about one inch
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (Fed. R. Civ. P. 10(b))
#let num-box = 0.4in                    // the paragraph number's box after it: the text starts 0.9 in from the margin
#let item-indent = 0.5in                // prayer items: the letter half an inch in
#let item-box = 0.6in                   // the letter's box: the item text hangs 1.1 in from the margin
#let caption-left = 3.4in               // width of the parties column of the caption
#let caption-gutter = 0.3in             // between the parties column and the case block
#let caption-inset = 10pt               // the parties column's text stands off its right rule
#let caption-pad = 8pt                  // the bottom rule stands off the last party line
#let right-inset = 0.1in                // the case block stands off the gutter
#let debtor-indent = 0.5in              // "Debtor." under the debtor's name
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let sig-gap = 10pt                     // between the groups of the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size; caption and signature lines
#let pitch-double = 24pt                // the body: double spacing at the template's 24 pt pitch
#let party-gap = pitch-single           // a single line between the debtor block and the adversary parties

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One line block (a paragraph of its own) at a pitch, with explicit space above it.
#let line-block(above: 0pt, below: 0pt, pitch: pitch-single, indent: 0pt, body) = block(width: 100%, above: above,
  below: below, pad(left: indent, {
    set text(..edges(pitch))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption: court title, parties (left), case numbers (right), title of the paper
// ---------------------------------------------------------------------------

/// The court's name, centered and bold, on lines of the body pitch.
#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF TEXAS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division) + " DIVISION") }
  for l in lines { line-block(pitch: pitch-double, align(center, text(weight: "bold", l))) }
}

#let caption(meta) = block(width: 100%, above: pitch-single, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // The debtor block (In re), then the adversary parties: each side's names, then its designation.
    line-block("IN RE:")
    line-block(inl(meta.debtor.name))
    line-block(indent: debtor-indent, "Debtor.")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for (j, n) in p.names.enumerate() { line-block(above: if k == 0 and j == 0 { party-gap } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block(inl("Case No. " + meta.debtor.case_number))
    line-block(inl(meta.debtor.chapter))
    let adv = if "adversary_number" in meta and meta.adversary_number != "" { meta.adversary_number } else { "____________________" }
    line-block(above: pitch-single, inl("Adv. Pro. No. " + adv))
  }),
))

/// The title of the paper: bold capitals, centered, on a line of the body pitch.
#let title(meta) = line-block(pitch: pitch-double, below: pitch-single,
  align(center, text(weight: "bold", upper(meta.brief_title))))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, lettered prayer items, headings
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (Fed. R. Civ. P. 10(b): the
/// number in a box after the first-line indent, the text after it). `keep`: kept whole on the page of the block
/// after it (the last paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: num-box, [#num.])#content])
})

/// Each blank-line-separated chunk is a heading (`#` numbered I., II., ...; `##` A., B., ...; `###`), a list
/// (lettered (a), (b), ...) or a numbered paragraph. Numbering is applied per chunk, not with a `show par` rule: a
/// show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let h1n = 0
  let h2n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("# ") {
      // Level 1: a centered section, numbered with roman numerals by the template.
      h1n += 1
      h2n = 0
      md("# " + numbering("I.", h1n) + " " + t.slice(2))
    } else if t.starts-with("## ") {
      // Level 2: a bold sub-heading with a capital letter (A., B., ...).
      h2n += 1
      md("## " + numbering("A.", h2n) + " " + t.slice(3))
    } else if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists (prayer items): lettered (a), (b), ...; the letter half an inch in; a list may break across pages.
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par(n, md(t), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

/// "Dated:" at the left; "Respectfully submitted," the firm, each signed group ("/s/ Name", the name and the lines
/// under it) and the role at the right, the groups a gap apart, -AND- between them. It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let sig = meta.signature
  grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block(inl("Dated: " + meta.date)),
    {
      line-block[Respectfully submitted,]
      for (k, l) in sig.at("firm", default: ()).enumerate() { line-block(above: if k == 0 { sig-gap } else { 0pt }, inl(l)) }
      for (k, g) in sig.groups.enumerate() {
        if k > 0 { line-block(above: sig-gap, "-AND-") }
        // A group with a `signer` is signed: "/s/ Name", then the name and the lines under it.
        let lines = if "signer" in g { ("/s/ " + g.signer, g.signer) + g.lines } else { g.lines }
        for (i, l) in lines.enumerate() { line-block(above: if i == 0 { sig-gap } else { 0pt }, inl(l)) }
      }
      for (k, l) in sig.at("role", default: ()).enumerate() { line-block(above: if k == 0 { sig-gap } else { 0pt }, inl(l)) }
    },
  )
})

#let txwb-adversary-complaint(meta, body) = {
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch; lists as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 157(a)"): xengine binds one sign, which leaves a break between the
  // two (the docx filter binds the same).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Prayer items (markdown lists) are lettered (a), (b), ... as in the filed form.
  set enum(numbering: "(a)")

  // Headings at the body size and pitch: level 1 a centered bold section (roman); level 2 a bold lettered
  // sub-heading at the margin; level 3 bold italic. No space of their own (the double pitch sets them off);
  // sticky, so a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", it.body)) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  court-title(meta)
  caption(meta)
  title(meta)
  // The opening paragraph of the pleading is unnumbered in the filed form.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
}
