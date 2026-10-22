// Adversary complaint for the United States Bankruptcy Court, Northern District of Florida (flnb).
// Rules (primary sources, verified 2026-10-14 against the Local Rules effective Feb. 26, 2024 and the
// District Local Rules, PDF version effective Nov. 24, 2015): Bankr. N.D. Fla. LBR 1001-1(B)-(C) (the
// District Local Rules apply in all bankruptcy cases, adversary proceedings included); LBR 7001-1 (complaint
// begins with an adversary proceeding cover sheet, caption conforms to the Official Form); LBR 9004-1(A)-(B)
// (caption and title, designation of the party, prayer for injunctive relief in the title); District LR
// 5.1(B)-(D) (case style, heading, 14-point double-spaced, 1-inch margins, numbered pages, signature block).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // District LR 5.1 names no face; Times New Roman, the house standard and the filed exemplar's face
#let type-size = 14pt              // District LR 5.1(C): at least 14-point font
#let margin = 1in                  // District LR 5.1(C): at least one inch on all four sides
#let para-indent = 0.5in           // first-line indent of every body paragraph (the filing)
#let caption-left = 3.95in         // the case-style column of the caption (its longest line, the rule, fits)
#let caption-gutter = 0.1in        // between the case style and the case numbers
#let sig-left = 2.9in              // the signature block's left edge (right half of the page, as filed)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // District LR 5.1(C) double spacing: 32.2 pt, the filed exemplar's pitch

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (case names in *italics*, headings, paragraphs).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line (a paragraph of its own); an empty one keeps its line box.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == "" { block(height: pitch-single) } else { body }
})

/// The caption (LBR 9004-1(A); Official Form 416D layout): the case style on the left and its numbers on the
/// right, one grid row per line so the numbers stand at the style's lines.
#let case-grid(left, right, above, below) = {
  let n = calc.max(left.len(), right.len())
  let at(list, i) = if i < list.len() { list.at(i) } else { "" }
  block(width: 100%, above: above, below: below, grid(
    columns: (caption-left, caption-gutter, 1fr),
    ..range(n).map(i => (line-block(at(left, i)), [], line-block(at(right, i)))).flatten(),
  ))
}

/// Court name, case styles and the title of the paper (LBR 9004-1(A)).
#let caption(meta) = {
  for l in meta.court { line-block(align(center, upper(l))) }
  case-grid(meta.debtor_style, meta.debtor_numbers, pitch-double, 0pt)
  case-grid(meta.adversary_style, meta.adversary_numbers, pitch-single, 0pt)
  for (i, l) in meta.title_lines.enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, text(weight: "bold", l)))
  }
}

/// Signature block (District LR 5.1(D)): counsel block plus the attorney's signature and bar details; one
/// unbreakable block, so it never splits over a page.
#let signature(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt,
  pad(left: sig-left, for l in meta.signature { line-block(l) }))

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  set document(title: meta.title)
  // District LR 5.1(C): pages numbered; centered in a single line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // Headings: centered single-spaced lines, the section headings (##) bold a single line below the text before
  // them, the claim subtitles (####) regular right under them; kept with the text after them.
  show heading: it => block(sticky: true, width: 100%, above: if it.level <= 2 { pitch-single } else { 0pt },
    below: 0pt, {
      set text(size: type-size, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      align(center, text(weight: if it.level <= 2 { "bold" } else { "regular" }, it.body))
    })

  caption(meta)
  // The last paragraph of the body stays with the signature block (one unbreakable block), so the signature never
  // stands alone on a page.
  let chunks = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let last = chunks.last()
  let keep = not last.starts-with("#")
  let head = if keep { chunks.slice(0, -1).join("\n\n") } else { body }
  block(width: 100%, above: pitch-single, below: 0pt, md(head))
  if keep {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, { md(last); signature(meta) })
  } else { signature(meta) }
}
