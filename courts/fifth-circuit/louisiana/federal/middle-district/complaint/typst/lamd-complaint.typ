// Complaint for the U.S. District Court for the Middle District of Louisiana (lamd).
// Rules: Fed. R. Civ. P. 10(a) (caption, title, file number), 10(b) (numbered paragraphs);
// M.D. La. Local Civil Rules 10(a)(1) (paper, type size, double spacing, margins, page numbers),
// 10(a)(2) (judge initials in the caption), 11(a)(3) (counsel block under the signature). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
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
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let label-box = 0.5in                  // a list item's label box, half an inch in; the text hangs after it
#let caption-party-w = 2.7in            // width of the party column (the party names, then "VERSUS" between them)
#let caption-pad = 0.3in                // the civil action number stands off the party column
#let sig-indent = 3in                   // LR 11(a)(3): the counsel block in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lamd-complaint.lua sets the same twips).
#let pitch-body = 24pt                  // LR 10(a)(1): double spaced (court name, title, headings, body)
#let pitch-single = 13.8pt              // single spaced: caption, signature block, page number
#let blank = 24pt                       // one blank double-spaced line: court name to caption, caption to title,
                                        // title to text, last paragraph to the signature block
// LR 10(a)(1): page numbers no less than 1/2 inch from the bottom edge. The number sits in a single-spaced line box
// whose foot is 0.6 in above the bottom edge (docx: footer distance 864 twips): 72 - 43.2 - 13.8 = 15 pt below the text.
#let footer-descent = 15pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
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
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
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

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(content)))

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
  if "subtitle" in meta and meta.subtitle != none { centred(meta.subtitle) }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it. Level 1 a centred section in capitals; level 2 centred bold (COUNT ...);
/// level 3 bold at the left margin. All on the body pitch, with no space of their own.
#let heading-block(level, s) = {
  // A title that starts "2. " is a heading, not a list item: the period is escaped for the markdown reader.
  let s = s.replace(regex("^(\\d+)\\."), m => m.captures.at(0) + "\\.")
  let body = text(weight: "bold", if level == 1 { upper(inl(s)) } else { inl(s) })
  block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    if level <= 2 { align(center, par(first-line-indent: 0pt, body)) } else { par(first-line-indent: 0pt, body) })
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph, except a chunk that starts with ">": that is an unnumbered paragraph
/// (the jurisdiction statement, the prayer's lead-in). A list ("- " or "1. ") is set item by item, the label in its
/// box half an inch in, the text hanging after it.
#let allegations(chunks, n) = {
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      out += heading-block(level, t.slice(level).trim())
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) or items.len() == 0 { items.push(l) }
        else { items.last() += " " + l }
      }
      for item in items {
        let m = item.match(regex("^(\\d+\\.|[-*+])[ \\t]+"))
        let label = if m.captures.at(0).ends-with(".") { m.captures.at(0) } else { [•] }
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
          par(first-line-indent: 0pt, hanging-indent: label-box,
            [#box(width: label-box, label)#unloose(inl(item.slice(m.end)))])))
      }
    } else if t.starts-with(">") {
      out += body-par(inl(t.replace(regex("(?m)^>[ \t]?"), "")))
    } else {
      n += 1
      out += body-par[#box(width: number-box)[#n.]#unloose(inl(t))]
    }
  }
  (out, n)
}

/// The signature block (LR 11(a)(3)): the date at the margin when given, then the counsel lines, single spaced, in
/// the right part of the page.
#let signature-block(meta) = {
  // The space above is the block's own: a gap at the start of the pad would be dropped (typst drops leading spacing).
  if "date" in meta.signature and meta.signature.date != "" {
    line-stack(("Dated: " + meta.signature.date,), above: blank)
  }
  block(width: 100%, above: blank, below: 0pt, pad(left: sig-indent, line-stack(meta.signature.lines)))
}

#let lamd-complaint(meta, body) = {
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
  // body pitch. Lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)

  if "lead_in" in meta { block(above: blank, below: 0pt, body-par(inl(meta.lead_in))) }

  // The last paragraph (or, when the body ends in a list, its last item) stays on the page with the signature block:
  // a signature never starts a page alone, and the rest of a list may stay behind on the page before.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let tail = chunks.last().trim()
  if tail.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
    let at = tail.matches(regex("(?m)^(\\d+\\.|[-*+])[ \\t]")).last().start
    if at > 0 { chunks = chunks.slice(0, -1) + (tail.slice(0, at), tail.slice(at)) }
  }
  let (main, n) = allegations(chunks.slice(0, -1), 0)
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(chunks.slice(-1), n).at(0)
    signature-block(meta)
  })
}
