// Complaint for the U.S. District Court for the District of Utah (utd).
//
// Rules: DUCivR 10-1(1) (letter paper, 1 1/2 in top margin, 1 in others), 10-1(3) (12 point minimum, footnotes
// included; no face named), 10-1(4) (double spacing except block quotes and footnotes), 10-1(5) (pages numbered
// consecutively), 10-1(6) (counsel block above the caption; caption table with parties, title, case number, judge),
// 10-1(7) ("JURY DEMANDED" below the title), 10-1(8) (signature); Fed. R. Civ. P. 8(a), 10(a)-(b), 38(b). See
// ../README.md and ../../rules.md. Content-agnostic: every case-specific word comes from the sample's frontmatter
// and body, never from this file. No coordinates measured off the exemplar, no forced line breaks.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // DUCivR 10-1(3) names no face; Times New Roman (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // DUCivR 10-1(3): minimum 12 point, footnotes included
#let margins = (top: 1.5in, bottom: 1in, x: 1in) // DUCivR 10-1(1): top at least 1 1/2 in, the others at least 1 in
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent; a paragraph number or prayer label starts here
#let number-box = 0.5in                 // a paragraph number (list label) in a box after the indent: its text starts 1 in in
#let caption-left = 4in                 // the party column of the caption, closed by a rule on its right and below
#let caption-pad = 0.15in               // the party column's text to its rule, and the rule to the right column
#let designation-indent = 1.25in        // "Plaintiffs," / "Defendants." under the party names
#let sig-left = 3.25in                  // the signature lines start 3.25 in from the margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/utd-complaint.lua and docx/reference.xml set the
// same twips: 20 x pt).
#let pitch-body = 24pt                  // DUCivR 10-1(4): double spacing, two 12 pt lines (body, headings, prayer)
#let pitch-single = 13.8pt              // counsel block, court title, caption, signature: single spacing (Word's 1.15 x 12 pt)
#let gap = 24pt                         // a blank double line: counsel block to court title, court title to caption, caption to body, before the signature
#let heading-above = 12pt                // above a heading that follows text (a run of headings stays together)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("utd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Markdown to inline typst content.
#let md(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each; "" is a blank single line. `above`: space above the first line.
#let line-stack(items, above: 0pt, left: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, pad(left: left, if type(i) == str { md(i) } else { i }))
      g = 0pt
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel block (DUCivR 10-1(6)(A)), court title, caption (DUCivR 10-1(6)(B), 10-1(7))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let left = ()
  for (k, side) in need(meta, "caption").enumerate() {
    if k > 0 { left += ("", [v.], "") }
    left += side.names
    left += ("", pad(left: designation-indent, md(side.designation)))
  }
  let right = (strong(upper(md(need(meta, "brief_title")))),)
  // DUCivR 10-1(7): "JURY DEMANDED" in capitals immediately below the title
  if meta.at("jury_demand", default: false) { right.push(strong[JURY DEMANDED]) }
  right += ("", [Case No. #need(meta, "case_number")])
  if "judge" in meta { right += ("", [Judge #meta.judge]) }
  if "magistrate" in meta { right.push([Magistrate Judge #meta.magistrate]) }
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: pitch-single, line-stack(left)),
    pad(left: caption-pad, line-stack(right)),
  ))
}

#let cover(meta) = {
  line-stack(need(meta, "counsel") + if "counsel_role" in meta { (emph(md(meta.counsel_role)),) } else { () })
  let court = need(meta, "court") + if "division" in meta { (meta.division,) } else { () }
  line-stack(court.map(l => align(center, strong(upper(l)))), above: gap)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, prayer list, jury demand
// ---------------------------------------------------------------------------

/// A heading on the body pitch, bold, kept with the text after it: level 1 centered capitals, level 2 centered,
/// level 3 at the margin.
#let heading-block(level, s, above: 0pt) = block(width: 100%, above: above, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  let t = strong(if level == 1 { upper(md(s)) } else { md(s) })
  if level <= 2 { align(center, t) } else { t }
})

/// A body paragraph, its first line indented; `label` (a number) in a box after the indent.
#let body-par(label: none, sticky: false, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: 0pt, [#h(para-indent)#if label != none { box(width: number-box, label) }#c]))

/// One chunk of the markdown body (chunks are separated by blank lines); `sticky`: kept with the block after it.
#let chunk(t, num, sticky: false, above: 0pt) = {
  let m = t.match(regex("^(#{1,3}) (.*)$"))
  if m != none {
    heading-block(m.captures.at(0).len(), m.captures.at(1), above: above)
  } else if t.starts-with("- ") or t.match(regex("^\\d+\\. ")) != none {
    // A list: each item's number as written (a bullet as "•") at the indent, its lines hanging at 1 in.
    let marks = t.matches(regex("(?m)^(\\d+\\.|-)[ \\t]+")).map(m => if m.captures.at(0) == "-" { "•" } else { m.captures.at(0) })
    let items = t.split(regex("(?m)^(\\d+\\.|-)[ \\t]+")).map(s => s.trim()).filter(s => s != "")
    for (k, item) in items.enumerate() {
      block(width: 100%, above: 0pt, below: 0pt, sticky: sticky and k == items.len() - 1,
        par(first-line-indent: 0pt, hanging-indent: para-indent + number-box,
          [#h(para-indent)#box(width: number-box, marks.at(k))#md(item)]))
    }
  } else if num != none {
    body-par(label: [#num.], sticky: sticky, md(t))
  } else {
    body-par(sticky: sticky, md(t))
  }
}

// ---------------------------------------------------------------------------
// Signature block (DUCivR 10-1(8)): the date, then the signer's lines from 3.25 in, kept on one page
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: gap, below: 0pt, breakable: false, {
    line-stack(("DATED this " + need(meta, "date") + ".",))
    line-stack(("Respectfully submitted,", "") + sig.at("firm", default: ()) + ("", "By: /s/ " + sig.signer, sig.signer)
      + sig.at("lines", default: ()), above: pitch-single, left: sig-left)
  })
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let utd-complaint(meta, body) = {
  for k in ("case_number", "court", "caption", "counsel", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  set page(
    paper: "us-letter",                  // DUCivR 10-1(1): 8 1/2 x 11 inch
    margin: margins,
    // DUCivR 10-1(5): pages numbered consecutively, centered at the foot, in a single-pitch line box that ends
    // footer-distance above the page edge.
    footer-descent: margins.bottom - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)

  // The lead-in, a blank double line under the caption; unnumbered.
  if "lead_in" in meta {
    block(width: 100%, above: gap, below: 0pt, body-par(md(meta.lead_in)))
  } else {
    v(gap)
  }

  // Numbering (Fed. R. Civ. P. 10(b)): every paragraph, except one under a heading that names the prayer or the
  // jury demand, and one that introduces a list (the next chunk is a list).
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let is-list(c) = c.starts-with("- ") or c.match(regex("^\\d+\\. ")) != none
  let unnumbered = false
  let n = 0
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      let l = lower(t)
      unnumbered = l.contains("prayer") or l.contains("jury demand")
    }
    let next-list = i + 1 < chunks.len() and is-list(chunks.at(i + 1))
    let para = not t.starts-with("#") and not is-list(t) and not unnumbered and not next-list
    if para { n += 1 }
    // the last chunk is kept with the signature (a signature never stands alone on a page)
    chunk(t, if para { n } else { none }, sticky: i == chunks.len() - 1,
      above: if t.starts-with("#") and i > 0 and not chunks.at(i - 1).starts-with("#") { heading-above } else { 0pt })
  }

  signature-block(meta)
}
