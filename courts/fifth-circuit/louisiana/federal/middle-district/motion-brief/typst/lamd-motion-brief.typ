// Memorandum in support of a motion for the U.S. District Court for the Middle District of Louisiana (lamd).
// Rules: M.D. La. Local Civil Rules 7(d) (a contested motion is accompanied by a separate memorandum),
// 7(g) (memoranda limited to 25 pages excluding attachments; a table of contents and table of authorities
// are excluded from the count; the signature block may extend beyond the limit; the form complies with
// LR 10(a)); 10(a)(1) (paper, type size, double spacing, margins, page numbers); 10(a)(2) (judge initials in
// the caption); 11(a)(3) (counsel block under the signature). Fed. R. Civ. P. 12(b)(6) is the motion's basis.
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-name = ("UNITED STATES DISTRICT COURT", "MIDDLE DISTRICT OF LOUISIANA") // the court's name, not a case's
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 10(a)(1): standard typeface (vendored, docs/FONTS.md)
#let type-size = 12pt                   // LR 10(a)(1): no smaller than standard 12-point
#let margin = 1in                       // LR 10(a)(1): every margin no less than one inch; 8 1/2 x 11 inch paper
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs; a level 3 heading's indent
#let quote-indent = 1in                 // block quotation indent, both sides
#let signature-indent = 2.5in           // the signature column starts at mid-page, as in the filed exemplars
#let caption-party-w = 2.7in            // width of the party column (the party names, then "VERSUS" between them)
#let caption-pad = 0.3in                // the civil action number stands off the party column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lamd-motion-brief.lua sets the same twips).
#let pitch-body = 24pt                  // LR 10(a)(1): double spaced (court name, title, headings, body)
#let pitch-single = 13.8pt              // single spaced (LR 10(a)(1) allows it for quotations): caption, quotations,
                                        // signature lines, page number
#let blank = 24pt                       // one blank double-spaced line: court name to caption, caption to title,
                                        // title to text, around the signature block and a "/s/" line, below a quotation
// LR 10(a)(1): page numbers no less than 1/2 inch from the bottom edge. The number sits in a single-spaced line box
// whose foot is 0.6 in above the bottom edge (docx: footer distance 864 twips): 72 - 43.2 - 13.8 = 15 pt below the text.
#let footer-descent = 15pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each, as typed (plain text); an empty item is a blank single line.
#let line-stack(items) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = 0pt
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, i)
      gap = 0pt
    }
  }
}

/// A line (or more) at the body pitch, centred.
#let centred(body, above: 0pt) = block(width: 100%, above: above, below: 0pt,
  align(center, par(first-line-indent: 0pt, body)))

/// The markdown line that marks where the signature block goes (after the conclusion, before the certificate).
#let signature-marker = "<!-- signature -->"

// ---------------------------------------------------------------------------
// Cover: court name, caption, title of the paper
// ---------------------------------------------------------------------------

/// LR 10(a)(2): the civil action number carries the judge and magistrate initials once allotted.
#let file-number(meta) = {
  let n = meta.civil_action_no
  if "judges" in meta { for j in meta.judges { n += "-" + j } }
  n
}

/// The party column at left; at right the civil action number, then the judge and the magistrate judge, each on the
/// line of the next party row (a blank single line between).
#let caption(meta) = {
  let right = ("CIVIL ACTION NO. " + file-number(meta),)
  if "judge" in meta and meta.judge != "" { right += ("", meta.judge) }
  if "magistrate" in meta and meta.magistrate != "" { right += ("", meta.magistrate) }
  block(above: blank, below: 0pt, breakable: false, grid(
    columns: (caption-party-w, text-width - caption-party-w),
    line-stack(meta.caption),
    pad(left: caption-pad, line-stack(right)),
  ))
}

#let cover(meta) = {
  for line in court-name { centred(text(weight: "bold", line)) }
  caption(meta)
  // The title as typed (in capitals by convention; a rule cited in it keeps its letters: "12(b)(6)").
  centred(above: blank, text(weight: "bold", meta.title))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Counsel block under the signature (LR 11(a)(3)): from mid-page, single spaced, a blank double-spaced line above
/// and below it. The space above is the block's own (typst drops a gap at the start of the pad).
#let signature-block(meta) = block(width: 100%, breakable: false, above: blank, below: blank,
  pad(left: signature-indent, line-stack(meta.signature_lines)))

/// Body paragraphs. Each blank-line-separated chunk of markdown is one paragraph (first-line indent, double
/// spaced), except: a heading (`#` centred bold capitals, `##` bold at the margin, `###` bold half an inch in, each
/// kept with the block after it), a chunk that starts with ">" (a single-spaced block quotation indented on both
/// sides, a blank line below it), and a "/s/" chunk (an electronic signature, LR 11(a)(2), in the signature column).
/// `keep-last`: the last chunk is kept whole and with what follows (the signature block). `first-above`: the space
/// above the first chunk.
#let paragraphs(body, keep-last: false, first-above: 0pt) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let sticky = keep-last and i == chunks.len() - 1
    let above = if i == 0 { first-above } else { 0pt }
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      // A title that starts "2. " is a heading, not a list item: the period is escaped for the markdown reader.
      let s = t.slice(level).trim().replace(regex("^(\\d+)\\."), m => m.captures.at(0) + "\\.")
      let h = text(weight: "bold", if level == 1 { upper(inl(s)) } else { inl(s) })
      block(width: 100%, sticky: true, above: above, below: 0pt,
        if level == 1 { align(center, par(first-line-indent: 0pt, h)) }
        else { pad(left: if level >= 3 { para-indent } else { 0pt }, par(first-line-indent: 0pt, h)) })
    } else if t.starts-with(">") {
      set text(..edges(pitch-single))
      block(width: 100%, sticky: sticky, breakable: not sticky, above: above, below: blank, pad(x: quote-indent,
        par(first-line-indent: 0pt, unloose(inl(t.replace(regex("(?m)^>[ \t]?"), ""))))))
    } else if t.starts-with("/s/") {
      set text(..edges(pitch-single))
      block(width: 100%, sticky: sticky, breakable: not sticky, above: blank, below: blank, pad(left: signature-indent,
        par(first-line-indent: 0pt, unloose(inl(t)))))
    } else {
      block(width: 100%, sticky: sticky, breakable: not sticky, above: above, below: 0pt, par(unloose(inl(t))))
    }
  }
}

#let lamd-motion-brief(meta, body) = {
  // Every page numbered, bottom centre (LR 10(a)(1)).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. No markdown lists reach typst's list layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)

  // The signature marker splits the body: everything after it (the certificate) follows the signature block.
  let parts = body.split(signature-marker)
  let before = parts.at(0)
  let after = parts.slice(1).join("", default: "")

  // The first paragraph sits a blank line below the title. The last paragraph before the signature stays on the
  // page with it: a signature never starts a page alone.
  paragraphs(before, keep-last: true, first-above: blank)
  signature-block(meta)
  paragraphs(after)
}
