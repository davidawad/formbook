// Complaint for the U.S. District Court for the Southern District of Iowa (iasd).
// Rules: Local Rules of the Northern and Southern Districts of Iowa, effective Dec. 7, 2020: LR 10(a) 8 1/2 x 11 paper;
// LR 10(b)(1)-(3) double spaced, one side, top margin of at least 1 inch; LR 10(b) documents of more than one page
// numbered at the bottom; LR 10(d) caption with district, division, case number, party names (Fed. R. Civ. P. 10(a)),
// a designation of the content and the filing party; LR 11 signature block (name, firm, address, telephone, email).
// Fed. R. Civ. P. 10(b) (numbered paragraphs), 38(b) (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no typeface rule in the S.D. Iowa Local Rules; tier 2 (the exemplar is Times New Roman)
#let type-size = 12pt                   // no size rule in the Local Rules; tier 2: 12 point, as in the exemplar
#let page-w = 8.5in                     // LR 10(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin-top = 1in                   // LR 10(b)(3): top margin of at least 1 inch
#let margin-bottom = 1in                // tier 2: not stated by the Local Rules
#let margin-left = 1in                  // tier 2
#let margin-right = 1in                 // tier 2
#let para-indent = 0.5in                // first-line indent of paragraphs; the number or letter in a box of it (tier 2)
#let caption-left = 3.25in              // width of the party column of the caption (tier 2)
#let caption-gutter = 0.2in
#let caption-inset = 10pt               // the party text stands off the caption's rules
#let right-inset = 0.1in                // the case-number column stands off the gutter
#let quote-indent = 0.5in               // block quotations, both sides
#let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t")
// Headings after which paragraphs are not numbered (the relief and the jury demand are not allegations).
#let unnumbered-after = ("REQUESTED RELIEF", "JURY DEMAND")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LR 10(b)(1): double spaced; 24 pt baseline pitch at 12 pt
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (caption, quotations, signature block)
#let heading-space = pitch / 2          // above and below a heading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field: a missing one fails the build, it is never silently left out.
#let need(meta, k) = {
  if k not in meta { panic("iasd-complaint: frontmatter field `" + k + "` is required") }
  meta.at(k)
}

/// Inline markdown (for names with *et al.*, section signs, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty item is a blank
/// line.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  // a rule of underscores is text, not a markdown thematic break
  if body == "" { "\u{00A0}" } else if type(body) == str and body.match(regex("^[_ ]+$")) != none { body } else if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 10(d))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  for l in ("IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF IOWA", upper(need(meta, "division"))) {
    line-block(align(center, text(weight: "bold", l)))
  }
}

#let caption(meta) = block(above: pitch, below: pitch, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-inset), {
    // Each party: its names, then its designation; the versus line between the parties.
    let cap = need(meta, "caption")
    for (k, p) in cap.parties.enumerate() {
      if k > 0 { line-block(cap.at("versus", default: "v.")) }
      for n in p.names { line-block(n) }
      line-block(p.designation)
    }
  }),
  pad(left: right-inset, {
    line-block("Case No. " + need(meta, "case_number"))
    line-block(above: pitch-single, text(weight: "bold", upper(need(meta, "title"))))
  }),
))

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered lists, block quotations
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body, in order.
#let chunks-of(body) = body.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// A heading: centered bold capitals (level 1), centered bold (level 2), bold at the margin (level 3), in a body
/// line with half a line above and below. Sticky, so a heading never ends a page.
#let heading-block(level, t) = {
  let c = strong(if level == 1 { upper(inl(t)) } else { inl(t) })
  block(width: 100%, above: heading-space, below: heading-space, sticky: true,
    align(if level <= 2 { center } else { left }, par(first-line-indent: 0pt, c)))
}

/// A body paragraph at the double pitch: the first-line indent, then (when labelled) the number or letter in a box
/// of the paragraph indent, the text after it.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if label == none { content } else { [#box(width: para-indent, label)#content] }))

#let body-blocks(body) = {
  let n = 0                             // paragraph number (LR 10(b): numbered paragraphs)
  let numbered = true
  for chunk in chunks-of(body) {
    if chunk.starts-with("###") {
      heading-block(3, chunk.slice(3).trim())
    } else if chunk.starts-with("##") {
      heading-block(2, chunk.slice(2).trim())
    } else if chunk.starts-with("#") {
      let t = chunk.slice(1).trim()
      if upper(t) in unnumbered-after { numbered = false }
      heading-block(1, t)
    } else if chunk.starts-with(">") {
      // A block quotation: single spaced, indented on both sides.
      let t = chunk.split("\n").map(l => l.replace(regex("^>\\s?"), "")).join("\n")
      pad(left: quote-indent, right: quote-indent, line-block(below: heading-space, inl(t)))
    } else if chunk.starts-with("1. ") {
      // A list: lettered (a), (b), ... by the template; each item is one markdown line.
      for (i, l) in chunk.split("\n").filter(l => l.trim() != "").enumerate() {
        body-par("(" + letters.at(i) + ")", inl(l.replace(regex("^\\s*\\d+\\.\\s+"), "")))
      }
    } else if numbered {
      n += 1
      body-par(str(n) + ".", inl(chunk))
    } else {
      body-par(none, inl(chunk))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 11): name, firm, address, telephone, email, under the signature
// ---------------------------------------------------------------------------

/// The signature lines in the signature column (after the caption's party column), then the filing note at the
/// margin; all of it kept on one page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch, below: 0pt, breakable: false, {
    if "date" in sig { line-block(sig.date) }
    pad(left: caption-left + caption-gutter, top: if "date" in sig { heading-space } else { 0pt },
      for l in sig.lines { line-block(l) })
    if "filing_note" in meta { line-block(above: pitch, meta.filing_note) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let iasd-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("division", "caption", "case_number", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // Page numbers centered at the bottom (LR 10(b)), in a single-spaced line box, so the number sits at the same
  // place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right),
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set document(title: need(meta, "title") + ", No. " + need(meta, "case_number"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 10(b)(1): double spaced).
  show: xengine.with(pitch: pitch, list-indent: para-indent)

  court-title(meta)
  caption(meta)
  if "lead_in" in meta and meta.lead_in != none { body-par(none, inl(meta.lead_in)) }
  body-blocks(md)
  signature-block(meta)
}
