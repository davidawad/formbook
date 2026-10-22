// Adversary complaint for the United States Bankruptcy Court, Western District of Louisiana (lawb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies to an adversary pleading: caption, numbered
// paragraphs under Rule 10(b)); Fed. R. Bankr. P. 7008(a) (the complaint states whether the pleader consents to
// final orders or judgment by the bankruptcy court; the template does not assert it, see ../README.md);
// LBR 7001-1 (division where the chapter case is pending); LBR 5005-1(b) (signature block: name, bar
// number, address, telephone, email). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the LBRs set no typeface; Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                   // FRBP 9004(a): legible; no rule sets a size, so the 12 pt convention
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let letter-box = 0.4in                 // ... in a box of its own; the text wraps under the text (docx: List Letter)
#let page-margin = 1in
#let text-width = 8.5in - 2 * page-margin
#let caption-left = 3.3in               // party column of the caption; the rule on its right edge is the caption's divider
#let caption-gutter = 0.25in            // between the party column and the case numbers
#let caption-pad = 0.2in                // the divider stands off the party lines by this much ...
#let caption-pad-bottom = 0.1in         // ... and runs this far below the last of them
#let case-pad = 0.1in                   // the case numbers stand off the gutter
#let party-step = 0.5in                 // a caption party line's indent per level (the frontmatter's `i`)
#let sig-left = 3.25in                  // the signature block's left edge
#let table-inset = 6pt                  // the transfers table: cell padding left and right (docx: 120 twips) ...
#let table-pad = 3pt                    // ... and above and below (docx: 60 twips)
#let table-slack = 4                    // the table: characters of room added to a column's longest cell
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lawb-adversary-complaint.lua and
// docx/reference.xml set the same twips).
#let pitch-body = 24pt                  // convention: double-spaced body text (exemplar)
#let pitch-single = 14pt                // court name, title, caption, table, signature block
#let court-below = 24pt                 // the court name to the title
#let title-below = 24pt                 // the title to the caption
#let caption-below = 24pt               // the caption to the text
#let heading-above = 12pt               // a heading: the space above it ...
#let heading-below = 12pt               // ... and below it (a heading sits on the body pitch)
#let table-above = 12pt                 // the table: the space above it ...
#let table-below = 12pt                 // ... and below it
#let signature-above = 24pt             // the last paragraph to the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, quotations, emphasis).
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

/// Single-spaced lines, one paragraph each; an empty item is a blank line (the next line sits a line lower). An item
/// is a string or a dictionary (t: text, i: indent level).
#let line-stack(items) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = 0pt
  for i in items {
    let (t, lvl) = if type(i) == dictionary { (i.t, i.at("i", default: 0)) } else { (i, 0) }
    if t == "" { gap += pitch-single } else {
      line-block(above: gap, pad(left: lvl * party-step, inl(t)))
      gap = 0pt
    }
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the number in its box after the first-line indent, then the text.
#let numbered(n, content) = body-par[#box(width: number-box)[#n.]#unloose(content)]

/// A pipe table (GitHub markdown), unruled and single-spaced, the width of the text. A column's width is in
/// proportion to its longest cell (characters, emphasis marks not counted) plus `table-slack`, rounded to the twip;
/// the last column takes the rest (docx: the same arithmetic in docx/lawb-adversary-complaint.lua).
#let pipe-table(t, width) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let lines = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let rows = lines.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let need = range(ncol).map(j => calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack)
  let total = need.sum()
  let widths = need.slice(0, -1).map(n => calc.round(width.pt() * n / total * 20) / 20 * 1pt)
  widths.push(width - widths.sum(default: 0pt))
  table(columns: widths, inset: (x: table-inset, y: table-pad), stroke: none,
    ..rows.map(r => range(ncol).map(j => inl(r.at(j, default: "")))).flatten())
}

// ---------------------------------------------------------------------------
// Cover: court title, title of the paper, caption
// ---------------------------------------------------------------------------

/// Left: the parties, indented by the item's `i` level; right: the case numbers. A vertical rule divides them.
#let caption(meta) = {
  let right = meta.caption.right.map(t => if t == none { "" } else { t })
  block(above: title-below, below: caption-below, grid(
    columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
    grid.cell(stroke: (right: 0.75pt), inset: (right: caption-pad, bottom: caption-pad-bottom),
      line-stack(meta.caption.left)),
    [],
    pad(left: case-pad, line-stack(right)),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let lines = court-name
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
  line-block(above: court-below, align(center, text(weight: "bold", underline(upper(meta.title)))))
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it, so it never ends a page. Level 1: centered, bold, underlined; level 2:
/// centered, bold; both at the type size on the body pitch (docx: Heading 1 and 2 in docx/reference.xml).
#let heading-block(level, s) = block(width: 100%, sticky: true, above: heading-above, below: heading-below,
  { set par(first-line-indent: 0pt); align(center, text(weight: "bold",
    if level == 1 { underline(inl(s)) } else { inl(s) })) })

/// Signature block (LBR 5005-1(b)): firm, the signing attorney's "By:" line, then name, bar number, address,
/// telephone and email, as the sample supplies them. Single-spaced, at `sig-left`, kept on one page. The space above
/// it is spacing of its own (docx: an empty paragraph of that height), so it stays behind when the block moves on.
#let signature-block(meta) = {
  let sig = meta.signature
  v(signature-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, pad(left: sig-left,
    line-stack(("Respectfully submitted,", "", sig.firm, "By: " + sig.by) + sig.lines + ("",) + sig.counsel_for)))
}

/// The body. Each blank-line-separated chunk of markdown is one of:
///   `#` heading (level 1 or 2), kept with the text after it;
///   `>` paragraph: unnumbered text (the opening paragraph and the prayer lead-in);
///   `1.` or `-` list: lettered (a), (b), ... (the prayer for relief);
///   `|` table: a markdown table, kept on one page;
///   anything else: one numbered paragraph (Fed. R. Civ. P. 10(b)).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with(">") {
      body-par(inl(t.replace(regex("(?m)^>[ \t]?"), "")))
    } else if t.starts-with(item-re) {
      let items = t.split("\n").map(l => l.trim()).filter(l => l.starts-with(item-re)).map(l => l.replace(item-re, ""))
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
          par(first-line-indent: 0pt, hanging-indent: letter-box,
            [#box(width: letter-box)[#numbering("(a)", i + 1)]#unloose(inl(item))])))
      }
    } else if t.starts-with("|") {
      // The space around the table is spacing of its own, kept at a page end (docx: an empty paragraph of that height).
      v(table-above)
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pipe-table(t, text-width)
      })
      v(table-below)
    } else {
      n += 1
      numbered(n, inl(t))
    }
  }
}

#let lawb-adversary-complaint(meta, body) = {
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)
  allegations(body)
  signature-block(meta)
}
