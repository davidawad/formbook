// Motion with memorandum for the United States Bankruptcy Court, Western District of Louisiana (lawb).
// Rules: Fed. R. Bankr. P. 9004(a) (legible), 9004(b) (caption: court, title, case number, adversary number if any,
// character of the document); Fed. R. Bankr. P. 9013 (a motion states its grounds with particularity and the relief
// requested); LBR 7007-1(d) (a brief is optional), LBR 7007-1(g) (relief and statutory basis), LBR 7007-2 (a brief is
// legible; length and tables), LBR 9013-1(b) (notice of hearing), LBR 9013-1(d) (certificate of service),
// LBR 5005-1(b) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the LBRs set no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // FRBP 9004(a): legible; no rule sets a size, so the 12 pt convention
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 0.655em + 1.345em = 2em = 24 pt at 12 pt
#let pitch = 24pt                       // one double-spaced line at 12 pt: 0.655em + 1.345em = 2em = 24 pt (a blank line is one pitch)
#let single-leading = 0.495em           // caption, counsel, signature block, footnotes: single-spaced lines
#let para-indent = 0.5in
#let page-margin = 1in
#let text-width = 8.5in - 2 * page-margin
#let caption-left = 3.4in               // party column of the caption box; the divider between the columns is the table rule
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content, with `#` read as a level-1 heading.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item; an empty item keeps a blank line.
#let line-stack(items) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(i => if i == none { block(height: 0.65em) } else { i }),
)

// ---------------------------------------------------------------------------
// Cover: court title, caption box, title of the paper, rule
// ---------------------------------------------------------------------------

/// The caption box: parties on the left (indented by the item's `i` level), case numbers on the right.
/// The table's stroke draws the box and the divider between the two columns.
#let caption(meta) = {
  let left = meta.caption.left.map(item => {
    if item.t == "" { none } else { pad(left: item.at("i", default: 0) * 0.5in, item.t) }
  })
  let right = meta.caption.right.map(t => if t == "" { none } else { t })
  table(
    columns: (caption-left, 1fr),
    stroke: 0.75pt,
    inset: (x: 0.12in, y: 0.1in),
    {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      line-stack(left)
    },
    {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      line-stack(right)
    },
  )
}

#let cover(meta) = {
  align(center, line-stack(court-name.map(l => text(weight: "bold", l))))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, line-stack(meta.title.map(l => text(weight: "bold", upper(l)))))
  v(pitch * 0.5)
  line(length: 100%, stroke: 0.75pt)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Signature block and certificate
// ---------------------------------------------------------------------------

/// Signature block (LBR 5005-1(b)): the lead-in, the firm, the signing attorney's "By:" line, then name, bar
/// number, address, telephone and email as the sample supplies them. Single-spaced, on the right half of the page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: text-width, breakable: false, pad(left: 2.75in, {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    v(pitch * 0.5)
    [#sig.lead]
    v(pitch * 0.5)
    line-stack((sig.firm, "By: " + sig.by) + sig.lines + (none,) + sig.counsel_for)
  }))
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let lawb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "- 1 -",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing equals the leading: typst adds no leading after a paragraph's last line, so a 0pt
  // spacing puts the next paragraph one line too high and it overprints the previous one.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 centered bold; level 2 bold and underlined at the left. A heading never ends a page.
  show heading.where(level: 1): it => block(sticky: true, above: pitch, below: pitch, width: text-width,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => block(sticky: true, above: pitch, below: pitch, width: text-width,
    text(weight: "bold", underline(it.body)))

  // Footnotes: type size, single-spaced entries, a short rule above them.
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  cover(meta)
  md(body)
  signature-block(meta)
  if "certificate" in meta {
    v(pitch)
    md(meta.certificate)
  }
}
