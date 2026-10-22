// Complaint for the U.S. District Court for the Eastern District of Virginia (vaed).
// Rules (E.D. Va. Local Civil Rules, amended Dec. 1, 2024): L.R. 7(B) (attorney's office address and
// telephone on every pleading); L.R. 7(F)(3) (12 point Roman, footnotes included, one-inch margins,
// double-spaced; the page cap is for briefs). Fed. R. Civ. P. 10(a) (caption), 10(b) (numbered paragraphs).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample, never from here.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.R. 7(F)(3): a Roman face; Times New Roman (vendored, docs/FONTS.md)
#let type-size = 12pt                   // L.R. 7(F)(3): 12 point Roman, footnotes and footer included
#let margin-in = 1in                    // L.R. 7(F)(3): one-inch margins
#let text-width = 8.5in - 2 * margin-in
#let para-indent = 0.5in                // first-line indent; the number of a numbered paragraph sits here ...
#let number-box = 0.5in                 // ... in a box of its own, the text after it 1 in from the margin
#let caption-w = 3.3in                  // width of the party box in the caption
#let caption-gutter = 0.25in            // the party box to the case number
#let caption-inset = 0.15in             // the party box's padding (docx: cell margins 216 twips)
#let caption-rule = 0.75pt              // the party box's rule (docx: w:sz 6)
#let designation-indent = 1.4in         // "Plaintiff," / "Defendants." under the party names
#let sig-left = 3.25in                  // the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vaed-complaint.lua sets the same twips).
#let pitch-body = 24pt                  // L.R. 7(F)(3): double spaced (title, headings, body)
#let pitch-single = 13.8pt              // single spaced: court name, caption, signature block, page number
#let small-gap = 6pt                    // around "v." in the caption; between the parts of the signature block
#let court-below = 24pt                 // the court name to the caption
#let caption-below = 24pt               // the caption to the title
#let title-below = 12pt                 // the title to the text
#let sig-above = 24pt                   // the last paragraph to the signature block
// The page number is centred in a single-spaced line box whose foot is 0.5 in above the bottom edge (docx: footer
// distance 720 twips): 72 - 36 - 13.8 = 22.2 pt below the text.
#let footer-descent = 22.2pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("vaed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold) in a paragraph or heading.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Blank-line-separated chunks of the body, trimmed, without empty ones.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")

/// Heading level and text of a `#`-prefixed chunk, or none.
#let heading-of(c) = {
  let m = c.match(regex("^(#{1,3})\\s+(.*)$"))
  if m == none { none } else { (level: m.captures.at(0).len(), text: m.captures.at(1)) }
}

/// Split "I. Title" or "A. Title" into the label ("I.") and the rest, so the label hangs in the margin.
#let label-of(t) = {
  let m = t.match(regex("^([IVX]+|[A-Z]|\\d+)\\.\\s+(.*)$"))
  if m == none { (none, t) } else { (m.captures.at(0) + ".", m.captures.at(1)) }
}

/// One single-spaced line (a paragraph of its own), plain text, with an explicit space above it.
#let line(t, above: 0pt, left: 0pt) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, par(first-line-indent: 0pt, t)))

// ---------------------------------------------------------------------------
// Cover: court name, caption, title
// ---------------------------------------------------------------------------

/// Caption (Fed. R. Civ. P. 10(a)): the party box on the left, the case number on the right, on the line of the first party line.
#let caption(meta) = block(width: 100%, above: court-below, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  grid(
    columns: (caption-w, caption-gutter, text-width - caption-w - caption-gutter),
    align: left + top,
    block(width: caption-w, stroke: caption-rule, inset: caption-inset, {
      let parties = meta.caption.parties
      let above = 0pt
      for (i, p) in parties.enumerate() {
        for l in p.lines { line(l, above: above); above = 0pt }
        if p.at("designation", default: none) != none { line(p.designation, left: designation-indent) }
        if i < parties.len() - 1 { line("v.", above: small-gap); above = small-gap }
      }
    }),
    [],
    pad(top: caption-inset, line(meta.caption.case_number)),
  )
})

#let cover(meta) = {
  // Court title, lines as the sample gives them: bold, single-spaced, centered.
  {
    set text(..edges(pitch-single))
    for l in meta.court { block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, strong(l)))) }
  }
  caption(meta)
  // Title of the paper: centered, bold, on the body pitch.
  block(width: 100%, above: caption-below, below: title-below,
    align(center, par(first-line-indent: 0pt, strong(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body: headings, numbered paragraphs (Fed. R. Civ. P. 10(b)), unnumbered (">") paragraphs and lettered prayer
/// items, all on the body pitch.
#let body-blocks(body) = {
  let n = 0
  for c in chunks(body) {
    let hd = heading-of(c)
    if hd != none {
      if hd.level == 1 {
        block(width: 100%, sticky: true, above: 0pt, below: 0pt,
          align(center, par(first-line-indent: 0pt, strong(upper(unloose(inl(hd.text)))))))
      } else {
        // the label hangs half an inch, the title after it
        let (label, rest) = label-of(hd.text)
        block(width: 100%, sticky: true, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: 0.5in,
          strong(if label == none { unloose(inl(rest)) } else { box(width: 0.5in, label) + unloose(inl(rest)) })))
      }
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      // A markdown list: each item is a lettered prayer item (A., B., ...), the letter half an inch in, the text
      // hanging 1 in from the margin.
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
      let items = c.split("\n").map(s => s.trim()).filter(s => s != "")
      for (k, it) in items.enumerate() {
        let t = it.match(regex("^\\d+\\.\\s+(.*)$")).captures.at(0)
        block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
          par(first-line-indent: 0pt, hanging-indent: number-box, box(width: number-box, letters.at(k) + ".") + unloose(inl(t)))))
      }
    } else if c.starts-with(">") {
      // An unnumbered body paragraph (e.g. the WHEREFORE paragraph before a prayer list): indented, no number.
      block(width: 100%, above: 0pt, below: 0pt, par(unloose(inl(c.replace(regex("(?m)^>[ \t]?"), "")))))
    } else {
      // A numbered allegation: the number at the indent in its box, then the text; wrapped lines return to the margin.
      n += 1
      block(width: 100%, above: 0pt, below: 0pt, par(box(width: number-box, str(n) + ".") + unloose(inl(c))))
    }
  }
}

/// Signature block: kept together, single-spaced (L.R. 7(B): office address and telephone in the lines). The date at
/// the margin, the rest in the signature column.
#let signature(sig) = block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
  set text(..edges(pitch-single))
  let above = 0pt
  if sig.at("date", default: none) != none { line("Dated: " + sig.date); above = small-gap }
  for k in ("closing", "party", "by") {
    if sig.at(k, default: none) != none { line(sig.at(k), above: above, left: sig-left); above = small-gap }
  }
  for l in sig.lines { line(l, above: above, left: sig-left); above = 0pt }
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let vaed-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-in,
    footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)

  // The unnumbered lead-in paragraph (the "alleges as follows" paragraph), if the sample has one.
  if meta.at("lead_in", default: none) != none {
    block(width: 100%, above: 0pt, below: 0pt, par(unloose(inl(meta.lead_in))))
  }
  body-blocks(body)

  if meta.at("signature", default: none) != none { signature(meta.signature) }
}
