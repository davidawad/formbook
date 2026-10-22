// Adversary complaint for the United States Bankruptcy Court for the District of Alaska (akb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to Official Form 416D),
// 7008(a) (jurisdiction allegation; statement whether the pleader consents to entry of final orders),
// 9004(a)-(b) (legible; caption); D. Alaska LBR 9004-1 (letter size, margins, double spacing, 12-point
// type, page numbers, counsel block) and LBR 7003-1, 7012-1. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")    // LBR 9004-1(a)(7): 12 point or 10 pitch; only vendored fonts
#let type-size = 12pt               // LBR 9004-1(a)(7)
#let margin = 1in                   // LBR 9004-1(a)(2): not less than 1 inch on all four sides
#let para-indent = 0.5in            // first-line indent; an allegation's number stands here
#let number-box = 0.35in            // the allegation number's box: the text starts 0.85 in from the margin
#let item-indent = 0.5in            // relief items: the letter half an inch in
#let item-box = 0.4in               // the letter's box: the item's text hangs 0.9 in from the margin
#let caption-left = 3.3in           // party column of the caption (Official Form 416D layout)
#let caption-gutter = 0.25in        // between the party column and the case numbers
#let caption-inset = 10pt           // the party text stands off the column's right end
#let caption-pad = 6pt              // a party group's rule stands this far below its designation
#let right-inset = 0.1in            // the case numbers stand this far into their column
#let versus-indent = 1.2in          // "v." between the party groups
#let cell-pad = 5pt                 // the data table's cell padding, every side

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt            // LBR 9004-1(a)(4): double spacing
#let pitch-single = 13.8pt          // counsel, caption, signature, quotations: single spacing, 1.15 x the type size
#let half-gap = 12pt                // around headings, the table and its title
#let small-gap = 6pt                // between "v." and the parties, and inside the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("akb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A double-spaced paragraph with a first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Cover: attorney block (top left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The attorney block sits at the top of the page, at least one inch down (LBR 9004-1(c)(2)(A)).
#let counsel-block(meta) = for l in meta.counsel { line-block(inl(l)) }

/// Court title (FRBP 9004(b)(1)): two single-spaced lines, centered, a double line above and below.
#let court-title() = {
  line-block(above: pitch-double, align(center, strong("IN THE UNITED STATES BANKRUPTCY COURT")))
  line-block(align(center, strong("FOR THE DISTRICT OF ALASKA")))
}

/// Caption (FRBP 9004(b)(2)-(3), Official Form 416D): each party group is a left cell, ruled below,
/// with the case numbers beside it in the right cell; "v." sits between the groups.
#let caption(meta) = {
  let cells = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      cells += (block(width: 100%, inset: (top: small-gap, bottom: small-gap),
        line-block(pad(left: versus-indent, [v.]))), [])
    }
    let lead = if "lead" in p { (p.lead,) } else { () }
    cells += (
      block(width: 100%, inset: (bottom: caption-pad, right: caption-inset), stroke: (bottom: 0.75pt), {
        for l in lead + p.names { line-block(inl(l)) }
        line-block(align(right, inl(p.designation)))
      }),
      pad(left: right-inset, for r in p.at("right", default: ()) { line-block(inl(r)) }),
    )
  }
  block(width: 100%, above: pitch-double, below: 0pt,
    grid(columns: (caption-left, 1fr), column-gutter: caption-gutter, row-gutter: 0pt, ..cells))
}

/// Title of the paper: bold, centered; the subtitle (e.g. the Code sections) below it.
#let title-block(meta) = {
  line-block(above: pitch-double, align(center, strong(upper(meta.brief_title))))
  if "brief_subtitle" in meta and meta.brief_subtitle != none {
    line-block(above: small-gap, align(center, inl(meta.brief_subtitle)))
  }
}

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
  title-block(meta)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, the data table, relief items
// ---------------------------------------------------------------------------

/// Headings at the double pitch: level 1 centered and bold, in capitals; level 2 bold; level 3 bold italic; half a
/// line above each. Sticky: a heading never ends a page.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    strong(it.body)
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: half-gap, below: 0pt, b)
}

/// A markdown table (`| a | b |` rows, a `|---|` separator after the header row) as equal columns of single lines,
/// thin rules, the header row bold. Every cell is padded `cell-pad`; a row never splits across a page.
#let data-table(t) = {
  let rows = t.split(regex("\\r?\\n")).map(l => l.trim()).filter(l => l != "")
  let sep = rows.position(l => l.match(regex("^\\|?[\\s:|-]+\\|?$")) != none)
  let cells(l) = l.trim("|").split("|").map(c => c.trim())
  let head = if sep != none and sep > 0 { rows.slice(0, sep) } else { () }
  let data = if sep != none { rows.slice(sep + 1) } else { rows }
  let n = cells(rows.first()).len()
  block(breakable: false, width: 100%, above: half-gap, below: half-gap, table(
    columns: (1fr,) * n,
    inset: cell-pad,
    stroke: 0.5pt,
    ..head.map(l => cells(l).map(c => line-block(strong(inl(c))))).flatten(),
    ..data.map(l => cells(l).map(c => line-block(inl(c)))).flatten(),
  ))
}

/// Numbered allegations (Fed. R. Civ. P. 10(b), applied by FRBP 7010). Each blank-line-separated chunk of
/// markdown that is a paragraph is one numbered paragraph. Headings, tables, table titles and lists are
/// not numbered. Numbering is applied per chunk, not with a `show par` rule (typst 0.15 recurses on that).
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with("|") {
      data-table(t)
    } else if t.starts-with(regex("^Table \\d")) {
      // A table title, centered and bold, unnumbered.
      block(sticky: true, above: half-gap, below: 0pt, line-block(align(center, strong(inl(t)))))
    } else if t.starts-with(">") {
      // A block quotation (LBR 9004-1(a)(4): quotations over fifty words single-spaced and indented).
      block(width: 100%, above: half-gap, below: half-gap, inset: (left: para-indent, right: para-indent), {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        md(t.split(regex("\\r?\\n")).map(l => l.trim-start(">").trim()).join("\n"))
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Relief items are lettered (A., B., ...), as in the filed complaint, at the double pitch.
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#md(t)])
    }
  }
}

/// The statement of consent (FRBP 7008(a); LBR 7012-1). Required in every complaint; unnumbered.
#let consent-block(meta) = {
  assert("consent" in meta, message: "akb-adversary-complaint: FRBP 7008(a) and LBR 7012-1 require a consent statement (frontmatter: consent)")
  block(sticky: true, width: 100%, above: pitch-double, below: 0pt, strong("STATEMENT REGARDING CONSENT"))
  // kept with the signature block, so the signature never stands on a page alone
  block(sticky: true, breakable: false, above: 0pt, below: 0pt, body-par(inl(meta.consent)))
}

/// Signature block (LBR 9004-1(a)(9): names typed beneath signatures). Date at left when given. The block never
/// breaks across a page.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  if "date" in meta and meta.date != none { line-block[Dated: #meta.date] } else { line-block[] },
  {
    for l in meta.signature.firm { line-block(inl(l)) }
    for (j, l) in meta.signature.lines.enumerate() { line-block(above: if j == 0 { small-gap } else { 0pt }, inl(l)) }
    line-block(above: half-gap, [/s/ #meta.signature.signer])
    line-block(meta.signature.signer)
  },
))

#let akb-adversary-complaint(meta, body) = {
  // LBR 9004-1(a)(1), (5): letter size; the page number centered at the foot of each page, at the type size, in a
  // single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; relief items as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 549"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  set enum(numbering: "A.")

  cover(meta)
  if "lead_in" in meta { body-par(above: pitch-double, inl(meta.lead_in)) }
  allegations(body)
  consent-block(meta)
  signature-block(meta)
}
