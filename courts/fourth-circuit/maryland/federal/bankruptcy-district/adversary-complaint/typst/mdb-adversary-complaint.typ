// Adversary complaint for the United States Bankruptcy Court for the District of Maryland (mdb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7010 (form of pleadings), 9004(a)-(b) (legibility,
// caption); Fed. R. Civ. P. 10(a)-(b) (caption, numbered paragraphs); Local Bankruptcy Rule 9004-1 (1-inch
// margins, 12-point text); Local Rule 9013-1(a) (caption with chapter, descriptive title, plaintiff and
// defendant). See ../README.md. Content-agnostic: every case word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.R. 9004-1 names no face; Times New Roman, the house standard (docs/FONTS.md), as in the exemplar
#let type-size = 12pt                    // Local Rule 9004-1: 12 point or larger for text (footer too: no footnotes)
#let page-margin = 1in                   // Local Rule 9004-1: at least one inch on each side
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                 // first-line indent; the paragraph number's box after it
#let item-indent = 0.5in                 // prayer items: the letter at the indent, in a box of this width
#let quote-inset = 0.5in                 // block quotations are indented on both sides
#let caption-left = 4.0in                // the party column, with its ")" column
#let caption-close = 0.4in               // the ")" column
#let caption-inset = 0.25in              // the right column's text starts this far right of the ")" column
#let sig-indent = 3in                    // the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // double spacing, as in the exemplar (L.R. 9004-1 sets no spacing)
#let pitch-single = 14pt                 // the court lines, caption, quotations and signature
#let gap-half = 12pt                     // half a double line: around the title rules, quotations, prayer items

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// A horizontal rule: a block of `h` whose foot is the rule (Word: a table row of that exact height with a bottom
/// border), so the rule takes no line of its own.
#let rule-block(h) = block(width: 100%, height: h, above: 0pt, below: 0pt, stroke: (bottom: 0.75pt))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b); Fed. R. Civ. P. 10(a); Local Rule 9013-1(a))
// ---------------------------------------------------------------------------

/// The caption's party lines: (text, indented?, ruled?) per row.
#let caption-rows(cap) = {
  let rows = ()
  if "in_re" in cap and cap.in_re != none {
    rows.push(("In re:", false, false))
    for n in cap.in_re.names { rows.push((n, false, false)) }
    rows.push((cap.in_re.designation, true, false))
    rows.push(("", false, true))
  }
  for (k, p) in cap.parties.enumerate() {
    if k > 0 { rows.push(("v.", true, false)) }
    for n in p.names { rows.push((n, false, false)) }
    rows.push((p.designation, true, false))
  }
  rows
}

/// The right column: case number, chapter and adversary number, a blank line between them, centered on the
/// party lines (from row floor((rows - lines) / 2)).
#let caption-right(meta) = {
  let r = ("Case No. " + meta.case_number, "")
  if "chapter" in meta and meta.chapter != none { r.push("Chapter " + str(meta.chapter)) }
  r.push("")
  // An empty adversary number leaves a blank for the clerk.
  let adv = if "adv_number" in meta and meta.adv_number != "" { meta.adv_number } else { "_" * 11 }
  r.push("Adv. Pro. No. " + adv)
  r
}

/// One row per caption line: the party text (indented 0.5 in for a designation or "v."), the ")" column, and the
/// right column's line for that row.
#let caption(meta) = {
  let rows = caption-rows(meta.caption)
  let right = caption-right(meta)
  let first = calc.max(0, calc.floor((rows.len() - right.len()) / 2))
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left - caption-close, caption-close, 1fr),
    ..rows.enumerate().map(((i, (t, ind, ruled))) => {
      let k = i - first
      (
        if ruled { block(width: 100%, height: pitch-single, stroke: (bottom: 0.5pt)) }
        else { pad(left: if ind { 0.5in } else { 0pt }, md(t)) },
        [)],
        pad(left: caption-inset, if k >= 0 and k < right.len() { right.at(k) } else { [] }),
      )
    }).flatten(),
  ))
}

#let cover(meta) = {
  // Court name lines, then the division, all centered and bold.
  for t in meta.court { line-block(align(center, text(weight: "bold", t))) }
  if "division" in meta and meta.division != none { line-block(align(center, text(weight: "bold", meta.division))) }
  caption(meta)
  // The title in capitals between two rules, half a double line from each.
  rule-block(gap-half)
  block(width: 100%, above: gap-half, below: 0pt, {
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", upper(meta.title)))
  })
  rule-block(gap-half)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the number in a box of the
/// paragraph indent after the first-line indent, then the text).
#let body-par(num, content, above: 0pt) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// The prayer's items (a markdown list), lettered A., B., ...: the letter at the item indent in a box of its
/// width, the text hanging after it, half a double line between the items.
#let prayer-items(t) = {
  let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).filter(s => s.trim() != "")
  for (i, it) in items.enumerate() {
    block(width: 100%, above: gap-half, below: 0pt, pad(left: item-indent,
      par(hanging-indent: item-indent, first-line-indent: 0pt,
        [#box(width: item-indent, numbering("A.", i + 1))#md(it.trim().replace(regex("\\s*\\n\\s*"), " "))])))
  }
}

/// A block quotation: single-spaced, indented on both sides, half a double line above, below and between its
/// paragraphs; not numbered.
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for q in ps { line-block(above: gap-half, below: gap-half, pad(x: quote-inset, md(q.trim()))) }
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), made applicable by Fed. R. Bankr. P. 7010). Each blank-line-
/// separated chunk of markdown that is neither a heading, a quotation, a list nor the WHEREFORE lead-in is one
/// numbered paragraph.
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      quotation(t)
    } else if t.starts-with("WHEREFORE") {
      body-par(none, md(t))
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      prayer-items(t)
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

/// The signature block: the date, then "Respectfully submitted,", the firm and the signer's lines at the
/// signature column; it never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  line-block[Dated: #meta.date]
  line-block(above: gap-half, left: sig-indent)[Respectfully submitted,]
  for (i, f) in meta.signature.firm.enumerate() { line-block(above: if i == 0 { gap-half } else { 0pt }, left: sig-indent, md(f)) }
  line-block(above: gap-half, left: sig-indent, md(meta.signature.signer))
  for l in meta.signature.lines { line-block(left: sig-indent, md(l)) }
})

#let mdb-adversary-complaint(meta, body) = {
  // The page number centered at the foot of every page, in a single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the body pitch, bold, kept with the text after them: level 1 centered underlined capitals,
  // level 2 centered, level 3 bold italic at the margin.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", underline(upper(it.body)))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
  })

  cover(meta)
  if "lead_in" in meta and meta.lead_in != none { body-par(none, md(meta.lead_in), above: gap-half) }
  allegations(body)
  signature-block(meta)
}
