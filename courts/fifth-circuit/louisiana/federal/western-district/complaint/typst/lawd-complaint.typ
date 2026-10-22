// Complaint for the U.S. District Court, Western District of Louisiana (lawd).
// Rules: Fed. R. Civ. P. 10(a) (caption: court, title, file number, Rule 7(a) designation), 10(b)
// (numbered paragraphs); W.D. La. LR 10.1 (8 1/2 x 11 paper, paginated, double spaced except footnotes
// and quotations; caption with the division and the district and magistrate judges). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no W.D. La. font rule (LR 10.1, checked 2026-10-14); Times New Roman, the default per docs/FONTS.md
#let type-size = 12pt                   // convention for filed complaints; the rule set does not state a size
#let page-margin = 1in                  // convention; the rule set does not state margins
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                // the number of an allegation sits at the first-line indent
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a lettered item's label sits half an inch in ...
#let label-box = 0.5in                  // ... in a box of half an inch; the text hangs 1 in from the margin
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-star = 0.3in               // width of the asterisk column between the parties and the case number
#let designation-indent = 1.5in         // a party's designation ("Plaintiff,") is set 1.5 in into the party column
#let blank = "_______________________"  // a blank for a caption entry not yet known (23 underscores, 1.9 in)
#let divisions = ("ALEXANDRIA", "LAFAYETTE", "LAKE CHARLES", "MONROE", "SHREVEPORT") // the five W.D. La. divisions

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lawd-complaint.lua sets the same twips).
#let pitch-body = 24pt                  // LR 10.1 double spacing: 24 pt lines at 12 pt
#let pitch-single = 13.8pt              // the court title, caption, title and signature block (single spaced)
#let block-gap = 24pt                   // one blank double-spaced line: court title to caption, caption to title, title
                                        // to the text, above every heading and above the signature block
#let footer-descent = 36.76pt           // the page number in a single line box whose foot is 0.3 in above the page foot
                                        // (Word: w:footer 432 twips, docx/reference.xml)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let s = src.replace("\r\n", "\n")
  let m = s.match(regex("^---\n([\\s\\S]*?)\n---[ \t]*\n"))
  if m == none { panic("lawd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), s.slice(m.end))
}

/// Inline markdown (names with *et al.*, smart quotes, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, body)

/// Single-spaced lines, one paragraph each; an empty item is a blank line (the next line sits a line lower).
#let line-stack(items) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = 0pt
  for i in items {
    if i == "" { gap += pitch-single } else {
      line-block(above: gap, if type(i) == str { inl(i) } else { i })
      gap = 0pt
    }
  }
}

/// A body paragraph at the body pitch: its first line indented half an inch (none: no indent).
#let body-par(content, indent: para-indent) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: indent, all: true), unloose(content)))

/// Chunk kinds of the body: headings (# ## ###), directives (<!-- -->), lists (1. or -), paragraphs.
#let kind(c) = {
  if c.starts-with("### ") { "h3" } else if c.starts-with("## ") { "h2" } else if c.starts-with("# ") { "h1" } else if c.starts-with("<!-- ") { "directive" } else if c.match(regex("^(\\d+\\.|-) ")) != none { "list" } else { "para" }
}

/// The items of a markdown list chunk; a line without a marker continues the item before it.
#let list-items(c) = {
  let items = ()
  for line in c.split("\n") {
    let m = line.match(regex("^(?:\\d+\\.|-)\\s+(.*)$"))
    if m != none {
      items.push(m.captures.at(0))
    } else if items.len() > 0 {
      items = items.slice(0, -1) + ((items.last() + " " + line.trim()),)
    }
  }
  items
}

// ---------------------------------------------------------------------------
// Caption (FRCP 10(a); LR 10.1)
// ---------------------------------------------------------------------------

/// The caption: parties on the left, one asterisk per line of the party column between them and the case number
/// on the right. The asterisks are counted from the measured height of the party column (whole single lines), so
/// they follow the text (docx: the same count from the face's advance widths, docx/lawd-complaint.lua).
#let caption(cap, meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let lines = ()
  for (i, p) in cap.parties.enumerate() {
    // the separator, then a blank line
    if i > 0 { lines += (cap.at("separator", default: "v."), "") }
    lines += p.names
    lines.push(pad(left: designation-indent, inl(p.designation)))
  }
  let left = line-stack(lines)
  let entry(label, key) = label + " " + if key in meta { meta.at(key) } else { blank }
  let right = line-stack((
    entry("CIVIL ACTION NO.", "case_number"),
    entry("JUDGE", "judge"),
    entry("MAGISTRATE JUDGE", "magistrate"),
    ..if "legend" in meta { ("", meta.legend) } else { () },
  ))
  grid(
    columns: (caption-left, caption-star, 1fr),
    left,
    context {
      let n = int(calc.round(measure(block(width: caption-left, left)).height / pitch-single))
      for _ in range(n) { line-block(align(center)[\*]) }
    },
    right,
  )
}

/// The signature block: the date at the left, "Respectfully submitted," and the sample's lines at the right. It is
/// kept whole; the space above it is spacing of its own (docx: an empty paragraph of that height).
#let signature(sig) = v(block-gap) + block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
  columns: (3.25in, 1fr),
  line-stack(("Dated: " + sig.date,)),
  line-stack(("Respectfully submitted,", "", ..sig.lines)),
))

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

/// A heading: one blank line above it, on the body pitch, kept with the block after it. Level 1 a centered bold
/// section in capitals; level 2 centered bold; level 3 bold italic at the margin.
#let heading-block(level, s) = {
  let body = if level == 1 { text(weight: "bold", upper(inl(s))) } else if level == 2 {
    text(weight: "bold", inl(s)) } else { text(weight: "bold", style: "italic", inl(s)) }
  block(width: 100%, sticky: true, above: block-gap, below: 0pt,
    if level < 3 { align(center, par(first-line-indent: 0pt, body)) } else { par(first-line-indent: 0pt, body) })
}

/// Render the complaint. `meta` is the sample's frontmatter; `body` is its markdown body.
#let lawd-complaint(meta, body) = {
  assert(upper(meta.division) in divisions, message: "lawd-complaint: division must be one of the five W.D. La. divisions")

  // Every page numbered, bottom centre (LR 10.1: paginated); the number in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Court title (LR 10.1; FRCP 10(a)). The division comes from the sample.
  {
    set text(..edges(pitch-single))
    for l in ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF LOUISIANA", upper(meta.division) + " DIVISION") {
      line-block(align(center, l))
    }
  }
  block(width: 100%, above: block-gap, below: 0pt, caption(meta.caption, meta))
  block(width: 100%, above: block-gap, below: block-gap, {
    set text(..edges(pitch-single))
    align(center, text(weight: "bold", upper(meta.title)))
  })

  // Chunks: a paragraph is numbered (FRCP 10(b)) unless a directive says otherwise.
  let chunks = body.split("\n\n").map(c => c.trim()).filter(c => c.len() > 0)
  let n = 0
  let letters = "a."
  let unnumbered = false
  let parts = ()
  for c in chunks {
    let k = kind(c)
    if k == "directive" {
      if c == "<!-- upper -->" { letters = "A." }
      if c == "<!-- unnumbered -->" { unnumbered = true }
      continue
    }
    if k == "h1" or k == "h2" or k == "h3" {
      let lvl = if k == "h1" { 1 } else if k == "h2" { 2 } else { 3 }
      parts.push(heading-block(lvl, c.slice(lvl + 1).trim()))
    } else if k == "list" {
      // A lettered list: the label half an inch in, in a half-inch box; the text hangs under the text.
      for (i, item) in list-items(c).enumerate() {
        parts.push(block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
          par(first-line-indent: 0pt, hanging-indent: label-box,
            [#box(width: label-box, numbering(letters, i + 1))#unloose(inl(item))]))))
      }
      letters = "a."
    } else if unnumbered {
      parts.push(body-par(inl(c)))
      unnumbered = false
    } else {
      n += 1
      parts.push(body-par[#box(width: number-box)[#n.]#unloose(inl(c))])
    }
  }

  // The last block stays whole with the signature block, so the signature never stands alone on a page.
  parts.slice(0, -1).join()
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, parts.last() + signature(meta.signature))
}
