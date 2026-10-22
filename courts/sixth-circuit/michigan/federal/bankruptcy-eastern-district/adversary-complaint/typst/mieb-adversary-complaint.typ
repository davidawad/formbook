// U.S. Bankruptcy Court, E.D. Michigan: adversary complaint (Fed. R. Bankr. P. 7001, 7008, 7010;
// Local Bankruptcy Rules 9004-1 and 9029-1(h)).
//
// Rule-driven and content-agnostic. Requirement IDs (MIEB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file
// (schema: ../README.md). Paragraphs are numbered by the template (Fed. R. Civ. P. 10(b)); a paragraph
// that begins with WHEREFORE is a prayer and is not numbered.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // MIEB-FORM-002: proportional serif; Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 14pt                    // MIEB-FORM-002: LBR 9029-1(h) "14 point (proportional)" for all text and footnotes.
#let margins = 1in                       // MIEB-FORM-001: LBR 9029-1(h) "at least 1 inch on the top, sides and bottom".
#let text-width = 8.5in - 2 * margins
#let para-indent = 0.5in                 // first-line indent of the lead-in, numbered paragraphs and prayers.
#let caption-col = text-width / 2        // caption: the party column and the case column
#let case-pad = 0.25in                   // caption: the case column stands off the party column
#let sig-col = 3.2in                     // signature: the signer's column at the right
#let rule-stroke = 0.5pt                 // the caption's rules (docx: w:sz 4)
#let rule-pad = 4pt                      // caption: the text stands off its rules (docx: 80 twips)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/mieb-adversary-complaint.lua sets the same
// twips, 20 x pt).
#let pitch-body = 28pt                   // MIEB-FORM-003: LBR 9029-1(h) "double-spaced": twice the 14 pt type
#let pitch-single = 17pt                 // MIEB-FORM-004: court name, caption, title, signature block single-spaced
#let court-below = 16.8pt                // the court name to the first rule
#let captions-gap = 8.4pt                // the debtor caption to the adversary caption
#let vs-gap = 8.4pt                      // adversary caption: above and below "vs."
#let caption-below = 16.8pt              // the last rule to the title
#let title-below = 11.2pt                // the title to the lead-in
#let heading-above = 14pt                // a "#" heading: the space above it
#let signature-above = 16.8pt            // the last paragraph to the signature block

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, links, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("mieb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mieb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A metadata value that may be one string or a list of strings, as a list.
#let lines-of(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line (a paragraph of its own; a string as plain text), with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, body)

// ---------------------------------------------------------------------------
// Cover: court, caption, title (MIEB-CAP-001 to MIEB-CAP-003)
// ---------------------------------------------------------------------------

/// One caption: the party column and the case column, ruled above (when `top`) and below across both
/// (docx: the cells' borders).
#let caption-table(top, left, right) = grid(
  columns: (caption-col, caption-col),
  stroke: (top: if top { rule-stroke } else { none }, bottom: rule-stroke),
  inset: (top: if top { rule-pad } else { 0pt }, bottom: rule-pad),
  left,
  pad(left: case-pad, right),
)

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for l in lines-of(need(meta, "court")) { line-block(align(center, l)) }

  // Debtor caption: the debtor on the left (the role at the right), the case number, chapter and judge on the
  // right (MIEB-CAP-001, LBR 9004-1(a)(1) and (2)).
  let ir = need(meta, "in_re")
  let cs = need(meta, "case")
  let debtor = {
    for (i, n) in lines-of(ir.names).enumerate() { line-block(if i == 0 { "In re: " + n } else { n }) }
    line-block(align(right, ir.role))
  }
  let case = {
    line-block("Case No. " + cs.number)
    line-block("Chapter " + cs.chapter)
    line-block(cs.judge)
  }
  block(above: court-below, below: 0pt, caption-table(true, debtor, case))

  // Adversary caption: the parties ("vs." between them), the chapter and the adversary number (MIEB-CAP-002,
  // Fed. R. Bankr. P. 7010: the caption conforms to Official Form 416). An adversary number not yet assigned is a
  // blank line of underscores (docx: the same characters).
  let parties = need(meta, "caption")
  let left = {
    for (i, p) in parties.enumerate() {
      if i > 0 { line-block(above: vs-gap, align(center, "vs.")) }
      for (j, n) in lines-of(p.names).enumerate() { line-block(above: if i > 0 and j == 0 { vs-gap } else { 0pt }, n) }
      line-block(align(right, p.designation))
    }
  }
  let an = need(meta, "adversary_number")
  let right = {
    line-block("Chapter " + cs.chapter)
    line-block("Adversary Proceeding No. " + if an == "" { "______________" } else { an })
  }
  block(above: captions-gap, below: 0pt, caption-table(false, left, right))

  block(width: 100%, above: caption-below, below: title-below, align(center, strong(need(meta, "title"))))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayers (MIEB-BODY-001 to MIEB-BODY-003)
// ---------------------------------------------------------------------------

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// The body, chunk by chunk. `# ` is a centered bold heading, `## ` a centered bold subheading (both on the body
/// pitch, kept with the block after them), a chunk beginning WHEREFORE is an unnumbered prayer, any other chunk is a
/// numbered paragraph.
#let body(meta, md) = {
  // Footnotes are not supported by this chunked body (each chunk is rendered alone); fail loudly.
  if md.contains("[^") { panic("mieb-adversary-complaint: footnotes are not supported in a complaint body") }
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  // The lead-in (the opening paragraph before the first heading) is unnumbered.
  body-par(inl(need(meta, "lead_in")))
  for (i, c) in chunks.enumerate() {
    // The last paragraph is kept with the signature block (docx: keepNext), so the block never stands alone.
    let last = i == chunks.len() - 1
    if c.starts-with("#") {
      let level = c.match(regex("^(#+)")).captures.at(0).len()
      block(width: 100%, sticky: true, above: if level == 1 { heading-above } else { 0pt }, below: 0pt, {
        set par(first-line-indent: 0pt)
        align(center, strong(unloose(inl(c.replace(regex("^#+[ \t]*"), "")))))
      })
    } else if c.starts-with("WHEREFORE") {
      body-par(inl(c), sticky: last)
    } else {
      n += 1
      body-par([#n. #unloose(inl(c))], sticky: last)
    }
  }
}

/// The signature block after the prayer (MIEB-SIG-001): the date at left, the signer at right, kept whole.
#let signature(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, breakable: false, above: signature-above, below: 0pt, grid(
    columns: (text-width - sig-col, sig-col),
    line-block("Dated: " + need(meta, "date")),
    {
      line-block(sig.signer)
      for l in lines-of(sig.lines) { line-block(l) }
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let complaint-doc(meta, doc) = {
  set document(title: need(meta, "title"))
  // Every page numbered "N of M", bottom centre (MIEB-FORM-001), in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margins,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1 of 1", both: true))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  doc
}

#let complaint-body(meta, md) = {
  cover(meta)
  body(meta, md)
  signature(meta)
}
