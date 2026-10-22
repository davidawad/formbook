// Motion with memorandum for the United States Bankruptcy Court, Western District of Louisiana (lawb).
// Rules: Fed. R. Bankr. P. 9004(a) (legible), 9004(b) (caption: court, title, case number, adversary number if any,
// character of the document); Fed. R. Bankr. P. 9013 (a motion states its grounds with particularity and the relief
// requested); LBR 7007-1(d) (a brief is optional), LBR 7007-1(g) (relief and statutory basis), LBR 7007-2 (a brief is
// legible; length and tables), LBR 9013-1(b) (notice of hearing), LBR 9013-1(d) (certificate of service),
// LBR 5005-1(b) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the LBRs set no typeface; Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                   // FRBP 9004(a): legible; no rule sets a size, so the 12 pt convention
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let list-indent = 0.5in                // a lettered item's letter starts half an inch in ...
#let letter-box = 0.4in                 // ... in a box of its own; the text wraps under the text (docx: List Letter)
#let page-margin = 1in
#let text-width = 8.5in - 2 * page-margin
#let caption-left = 3.4in               // party column of the caption box; the divider between the columns is the box's rule
#let caption-inset-x = 8.65pt           // the caption box's padding left and right of each column (docx: 173 twips) ...
#let caption-inset-y = 0.1in            // ... and above and below (docx: 144 twips)
#let caption-rule = 0.75pt              // the caption box's rules (docx: w:sz 6)
#let party-step = 0.5in                 // a caption party line's indent per level (the frontmatter's `i`)
#let sig-left = 2.75in                  // the signature block's left edge
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lawb-motion-brief.lua and docx/reference.xml set
// the same twips).
#let pitch-body = 24pt                  // convention: double-spaced body text (exemplar)
#let pitch-single = 14pt                // court name, caption, title, signature block, footnotes
#let court-below = 24pt                 // the court name to the caption box
#let caption-below = 24pt               // the caption box to the title
#let rule-above = 12pt                  // the title to the rule under it ...
#let rule-height = 1.75pt               // ... the rule's own line (docx: a 1 pt line and the 0.75 pt border below it) ...
#let rule-below = 24pt                  // ... and the rule to the text
#let heading-above = 12pt               // a heading: the space above it ...
#let heading-below = 12pt               // ... and below it (a heading sits on the body pitch)
#let signature-above = 12pt             // the last paragraph to the signature block
#let certificate-above = 24pt           // the signature block to the certificate of service
#let note-gap = 6pt                     // between two footnotes (docx: Footnote Text 120 twips after)
#let note-clearance = 8pt               // the text to the footnote rule: with typst's 6 pt from the rule to the first note, the 14 pt LibreOffice keeps (docx)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations, footnote references with their definitions appended).
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

// ---------------------------------------------------------------------------
// Cover: court title, caption box, title of the paper, rule
// ---------------------------------------------------------------------------

/// The caption box: parties on the left (indented by the item's `i` level), case numbers on the right. The box's
/// rules run round both columns and between them (docx: the table's borders).
#let caption(meta) = block(above: court-below, below: caption-below, grid(
  columns: (caption-left, text-width - caption-left),
  stroke: caption-rule,
  inset: (x: caption-inset-x, y: caption-inset-y),
  line-stack(meta.caption.left),
  line-stack(meta.caption.right.map(t => if t == none { "" } else { t })),
))

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for l in court-name { line-block(align(center, text(weight: "bold", l))) }
  caption(meta)
  for l in meta.title { line-block(align(center, text(weight: "bold", upper(l)))) }
  block(width: 100%, height: rule-height, above: rule-above, below: rule-below,
    place(bottom, line(length: 100%, stroke: caption-rule)))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it, so it never ends a page. Level 1: centered, bold; level 2: bold and
/// underlined, at the left; both at the type size on the body pitch (docx: Heading 1 and 2 in docx/reference.xml).
#let heading-block(level, s) = block(width: 100%, sticky: true, above: heading-above, below: heading-below, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, text(weight: "bold", inl(s))) } else { text(weight: "bold", underline(inl(s))) }
})

/// The footnote definitions of a text ("[^n]: text"). They are appended to each chunk that refers to them, because
/// cmarker resolves a reference only against the definitions in the same string.
#let footnote-definitions(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c.starts-with("[^")).join("\n\n")

/// Markdown blocks in document order. Each blank-line-separated chunk is one of:
///   `#` heading (level 1 or 2), kept with the text after it;
///   `1.` or `-` list: lettered a., b., ...;
///   `[^n]:` a footnote definition (set with the paragraph that refers to it);
///   anything else: a body paragraph.
#let blocks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = footnote-definitions(body)
  let with-notes(t) = t + if t.contains("[^") { "\n\n" + defs } else { "" }
  let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
  for t in chunks {
    if t.starts-with("[^") {
    } else if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with(item-re) {
      let items = t.split("\n").map(l => l.trim()).filter(l => l.starts-with(item-re)).map(l => l.replace(item-re, ""))
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
          par(first-line-indent: 0pt, hanging-indent: letter-box,
            [#box(width: letter-box)[#numbering("a.", i + 1)]#unloose(inl(with-notes(item)))])))
      }
    } else {
      body-par(inl(with-notes(t)))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate
// ---------------------------------------------------------------------------

/// Signature block (LBR 5005-1(b)): the lead-in, the firm, the signing attorney's "By:" line, then name, bar
/// number, address, telephone and email as the sample supplies them. Single-spaced, at `sig-left`, kept on one page.
/// The space above it is spacing of its own (docx: an empty paragraph of that height).
#let signature-block(meta) = {
  let sig = meta.signature
  v(signature-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, pad(left: sig-left,
    line-stack((sig.lead, "", sig.firm, "By: " + sig.by) + sig.lines + ("",) + sig.counsel_for)))
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let lawb-motion-brief(meta, body) = {
  // Every page numbered "- n -", bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("- 1 -"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. No markdown lists reach typst's list
  // layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Footnotes: the type size, single-spaced, a short rule above them (docx: Footnote Text).
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  blocks(body)
  signature-block(meta)
  if "certificate" in meta {
    v(certificate-above)
    blocks(meta.certificate)
  }
}
