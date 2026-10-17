// Adversary complaint for the United States Bankruptcy Court, Western District of Louisiana (lawb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies to an adversary pleading: caption, numbered
// paragraphs under Rule 10(b)); Fed. R. Bankr. P. 7008(a) (the complaint states whether the pleader consents to
// final orders or judgment by the bankruptcy court; the template does not assert it, see ../README.md);
// LBR 7001-1 (division where the chapter case is pending); LBR 5005-1(b) (signature block: name, bar
// number, address, telephone, email). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the LBRs set no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // FRBP 9004(a): legible; no rule sets a size, so the 12 pt convention
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 0.655em + 1.345em = 2em = 24 pt at 12 pt
#let pitch = 24pt                       // one double-spaced line at 12 pt: 0.655em + 1.345em = 2em = 24 pt (a blank line is one pitch)
#let single-leading = 0.495em           // caption, signature block: single-spaced lines
#let para-indent = 0.5in
#let page-margin = 1in
#let text-width = 8.5in - 2 * page-margin
#let caption-left = 3.3in               // party column of the caption; the rule on its right edge is the caption's divider
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (inline or block), with `#` read as a level-1 heading.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item; an empty item keeps a blank line.
#let line-stack(items) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(i => if i == none { block(height: 0.65em) } else { i }),
)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = court-name
  if "division" in meta { lines.push(upper(meta.division)) }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(l => text(weight: "bold", l))))
}

/// Left: the parties, indented by the item's `i` level; right: the case numbers. A vertical rule divides them.
#let caption(meta) = {
  let left = meta.caption.left.map(item => {
    if item.t == "" { none } else { pad(left: item.at("i", default: 0) * 0.5in, item.t) }
  })
  let right = meta.caption.right.map(t => if t == "" { none } else { t })
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt), inset: (right: 0.2in, bottom: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      line-stack(left)
    }),
    block(inset: (left: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      line-stack(right)
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  align(center, underline(text(weight: "bold", upper(meta.title))))
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (LBR 5005-1(b)): firm, the signing attorney's "By:" line, then name, bar number, address,
/// telephone and email, as the sample supplies them. Single-spaced, set to the right half of the page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: text-width, breakable: false, pad(left: 3.25in, {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    v(body-leading)
    [Respectfully submitted,]
    v(body-leading)
    line-stack((sig.firm, "By: " + sig.by) + sig.lines + (none,) + sig.counsel_for)
  }))
}

/// Numbered allegations. Each blank-line-separated chunk of markdown is one of:
///   `#` heading: centered (level 1, underlined) or centered bold (level 2), kept with the text after it;
///   `>` paragraph: unnumbered text (the opening paragraph and the prayer lead-in);
///   `1.` list: lettered (a), (b), ... (the prayer for relief);
///   `|` table: a markdown table;
///   anything else: one numbered paragraph (Fed. R. Civ. P. 10(b)).
/// Numbering is applied per chunk, not with a show rule that re-wraps paragraph content.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      [#h(para-indent)#md(t.slice(1).trim())]
      parbreak()
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Not on-grid: a fixed-height block cannot break between pages, and a list must.
      // Each item is one double-spaced block; the trailing v() closes the last item.
      set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading)
      md(t)
      v(body-leading)
    } else if t.starts-with("|") {
      set table(stroke: none, inset: (x: 6pt, y: 3pt))
      md(t)
      v(body-leading)
    } else {
      para-counter.step()
      context [#h(para-indent)#(para-counter.display()).#h(0.4in)#md(t)]
      parbreak()
    }
  }
}

#let lawb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing equals the leading: typst adds no leading after a paragraph's last line, so a 0pt
  // spacing puts the next paragraph one line too high and it overprints the previous one.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: a blank double-spaced line above and below; a heading never ends a page.
  show heading.where(level: 1): it => block(sticky: true, above: pitch, below: pitch, width: text-width,
    align(center, text(weight: "bold", underline(it.body))))
  show heading.where(level: 2): it => block(sticky: true, above: pitch, below: pitch, width: text-width,
    align(center, text(weight: "bold", it.body)))

  cover(meta)
  allegations(body, para-counter)
  signature-block(meta)
}
