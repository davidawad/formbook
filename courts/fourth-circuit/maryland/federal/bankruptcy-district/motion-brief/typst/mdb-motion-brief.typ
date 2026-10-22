// Memorandum of fact and law in support of a motion, for the United States Bankruptcy Court for the District
// of Maryland (mdb). Rules: Local Bankruptcy Rule 9013-2 (a brief memorandum of fact and law with each motion),
// 9013-1(a) (caption with the court, case name and number, chapter if any, a descriptive title, and in an
// adversary the plaintiff and defendant); Fed. R. Bankr. P. 9004(a)-(b) (legibility, caption); Local Rule
// 9004-1 (1-inch margins, 12-point text). See ../README.md. Content-agnostic: every case word comes from the
// sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.R. 9004-1 names no face; Times New Roman, the house standard (docs/FONTS.md), as in the exemplar
#let type-size = 12pt                    // Local Rule 9004-1: 12 point or larger for text (footer too: no footnotes)
#let page-margin = 1in                   // Local Rule 9004-1: at least one inch on each side
#let para-indent = 0.5in                 // first-line indent of the body paragraphs
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
#let gap-half = 12pt                     // half a double line: around the title rules, quotations, signature parts

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdb-motion-brief: the sample must start with a YAML frontmatter block") }
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
// Caption (Fed. R. Bankr. P. 9004(b); Local Rule 9013-1(a))
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

/// The right column: case number, then the chapter and the adversary number when given, a blank line before
/// each, centered on the party lines (from row floor((rows - lines) / 2)).
#let caption-right(meta) = {
  let r = ("Case No. " + meta.case_number,)
  if "chapter" in meta and meta.chapter != none { r += ("", "Chapter " + str(meta.chapter)) }
  if "adv_number" in meta and meta.adv_number != "" { r += ("", "Adv. Pro. No. " + meta.adv_number) }
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

/// A body paragraph at the double pitch, first line indented (a memorandum is not a numbered pleading).
#let body-par(content, above: 0pt) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A block quotation (the certificate's service list): single-spaced, indented on both sides, half a double line
/// above, below and between its paragraphs; the sample's own line breaks kept.
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for q in ps { line-block(above: gap-half, below: gap-half, pad(x: quote-inset, md(q.trim()))) }
}

/// The memorandum's body: each blank-line-separated chunk of markdown is a heading, a quotation or an indented
/// paragraph. "# Certificate of Service" starts a new page, as the filed exemplar does.
#let brief-body(body) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("# Certificate of Service") { pagebreak(weak: true) }
    if t.starts-with("#") { md(t) } else if t.starts-with(">") { quotation(t) } else { body-par(md(t)) }
  }
}

/// The signature block: the date, then "Respectfully submitted:", the firm and the signer's lines at the
/// signature column.
#let signature-block(meta) = {
  line-block(above: pitch-double, md(meta.date))
  line-block(above: gap-half, left: sig-indent)[Respectfully submitted:]
  for (i, f) in meta.signature.firm.enumerate() { line-block(above: if i == 0 { gap-half } else { 0pt }, left: sig-indent, md(f)) }
  line-block(above: gap-half, left: sig-indent, md(meta.signature.signer))
  for l in meta.signature.lines { line-block(left: sig-indent, md(l)) }
}

#let mdb-motion-brief(meta, body) = {
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

  // Headings at the body pitch, bold, kept with the text after them: level 1 centered underlined capitals
  // (INTRODUCTION, ARGUMENT, ...), levels 2 and 3 at the margin.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", underline(upper(it.body)))) } else {
      text(weight: "bold", it.body)
    }
  })

  cover(meta)
  if "lead_in" in meta and meta.lead_in != none { body-par(md(meta.lead_in), above: gap-half) }

  // The signature comes before the certificate of service, which starts a new page (as in the exemplar). The
  // last paragraph before it stays on one page with the signature, so a signature never stands alone.
  let parts = body.split("# Certificate of Service")
  let chunks = parts.at(0).split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  brief-body(chunks.slice(0, -1).join("\n\n"))
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    brief-body(chunks.at(-1))
    signature-block(meta)
  })
  if parts.len() > 1 { brief-body("# Certificate of Service" + parts.at(1)) }
}
