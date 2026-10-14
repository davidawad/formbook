// Memorandum in support of a motion (lawd motion-brief): the Rule 12(b) memorandum of this district.
// Rules: W.D. La. LR 7.1 and LR 7.8 (25-page limit exclusive of the tables; a memorandum over 10 pages needs a
// table of contents and a table of authorities); LR 10.1 (8 1/2 x 11 paper, paginated, double spaced except
// footnotes and quotations; caption with the division and the district and magistrate judges); LR 11.1 (counsel's
// name, address, telephone and bar number under the signature); Fed. R. Civ. P. 10(a). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no W.D. La. font rule (LR 7.1, 7.8, 10.1, checked 2026-10-14); no-face default per docs/FONTS.md
#let type-size = 12pt                   // convention for filed briefs; the rule set does not state a size
#let page-margin = 1in                  // convention; the rule set does not state margins
#let text-width = 8.5in - 2 * page-margin
#let pitch = 24pt                       // one double-spaced line: EB Garamond's 0.65em line box plus the leading below
#let body-leading = 1.35em              // LR 10.1 double spacing: 1.35em of leading gives the 24 pt pitch (measured, README.md)
#let single-leading = 0.5em             // single spacing for the caption, the tables and the signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-star = 0.3in               // width of the asterisk column between the parties and the case number
#let blank = box(width: 1.9in, line(length: 1.9in, stroke: 0.5pt))  // a blank for a caption entry not yet known
#let divisions = ("ALEXANDRIA", "LAFAYETTE", "LAKE CHARLES", "MONROE", "SHREVEPORT") // the five W.D. La. divisions

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let s = src.replace("\r\n", "\n")
  let m = s.match(regex("^---\n([\\s\\S]*?)\n---[ \t]*\n"))
  if m == none { panic("lawd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), s.slice(m.end))
}

/// Inline markdown (case names in italics, section signs, smart quotes, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of double-spaced text rounded up to whole 24 pt lines. Typst leaves the leading out of a
/// paragraph's measured height, so an unrounded block would sit on the line above it.
#let on-grid(c, sticky: false, width: text-width) = context {
  let h = measure(width: width, c).height
  block(width: width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

/// Chunk kinds of the body: headings (# ## ###), directives (:::), lists (1. or -), paragraphs.
#let kind(c) = {
  if c.starts-with("### ") { "h3" } else if c.starts-with("## ") { "h2" } else if c.starts-with("# ") { "h1" } else if c.starts-with(":::") { "directive" } else if c.match(regex("^(\\d+\\.|-) ")) != none { "list" } else { "para" }
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

/// The caption: parties on the left, one asterisk per line between them and the case number on the right.
/// The asterisks are counted from the measured height of the party column, so they follow the text.
#let caption(cap, meta) = {
  let left = block(width: caption-left, above: 0pt, below: 0pt)[
    #par(leading: single-leading)[
      #for (i, p) in cap.parties.enumerate() {
        if i > 0 { [#inl(cap.at("separator", default: "v.")) \ \ ] }
        for name in p.names { [#inl(name) \ ] }
        [#h(1.5in) #inl(p.designation) \ ]
      }
    ]
  ]
  let right = block(width: 100%, above: 0pt, below: 0pt)[
    #par(leading: single-leading)[
      CIVIL ACTION NO. #meta.at("case_number", default: blank) \
      #if "judge" in meta [JUDGE #meta.judge \ ] else [JUDGE #blank \ ]
      #if "magistrate" in meta [MAGISTRATE JUDGE #meta.magistrate \ ] else [MAGISTRATE JUDGE #blank \ ]
      #if "legend" in meta [\ #meta.legend]
    ]
  ]
  grid(
    columns: (caption-left, caption-star, 1fr),
    align: (top, top, top),
    left,
    context {
      let line-pitch = measure(par(leading: single-leading)[A\ A]).height - measure(par(leading: single-leading)[A]).height
      let n = calc.ceil(measure(left).height / line-pitch)
      stack(dir: ttb, ..range(n).map(_ => block(height: line-pitch, width: 100%, align(center)[\*])))
    },
    right,
  )
}

/// A signature block: the date (if the sample gives one) at the left; "Respectfully submitted," and the sample's
/// lines at the right. LR 11.1: the lines carry the signer's name, address, telephone and bar number.
#let signature(sig) = {
  block(width: 100%, above: 0pt, below: 0pt, sticky: true)[
    #grid(
      columns: (3.25in, 1fr),
      align: (top, top),
      [#par(leading: single-leading)[#if "date" in sig [Dated: #sig.date]]],
      [#par(leading: single-leading)[
        Respectfully submitted,\
        \
        #for l in sig.lines [#inl(l) \ ]
      ]],
    )
  ]
}

/// The table of authorities: one group per category; each entry with dot leaders to its page references.
#let table-of-authorities(groups) = {
  for g in groups {
    on-grid(align(left, text(weight: "bold", g.category)))
    for item in g.items {
      on-grid(par(hanging-indent: 0.5in, leading: body-leading)[#inl(item.cite) #box(width: 1fr, repeat[.]) #item.pages])
    }
  }
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

/// Render the memorandum. `meta` is the sample's frontmatter; `body` is its markdown body.
/// Front matter (caption and the opening paragraphs) is numbered in roman; the tables follow; the body starts at 1.
#let lawd-motion-brief(meta, body) = {
  assert(upper(meta.division) in divisions, message: "lawd-motion-brief: division must be one of the five W.D. La. divisions")

  set page(paper: "us-letter", margin: page-margin, numbering: "i", number-align: center)
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, spacing: 0pt, first-line-indent: 0pt)

  // Headings: level 1 a centered bold section; level 2 a bold sub-heading at the margin; level 3 bold italic.
  set heading(numbering: none)
  show heading: set text(size: type-size)
  show heading.where(level: 1): it => align(center, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => text(weight: "bold", it.body)
  show heading.where(level: 3): it => text(weight: "bold", style: "italic", it.body)

  // Court title (LR 10.1; FRCP 10(a)). The division comes from the sample.
  align(center)[
    #par(leading: single-leading)[
      UNITED STATES DISTRICT COURT\
      WESTERN DISTRICT OF LOUISIANA\
      #upper(meta.division) DIVISION
    ]
  ]
  v(pitch)
  caption(meta.caption, meta)
  v(pitch)
  align(center)[#par(leading: single-leading)[#text(weight: "bold", upper(meta.title))]]
  if "subtitle" in meta {
    v(single-leading)
    align(center)[#par(leading: single-leading)[#text(weight: "bold", upper(meta.subtitle))]]
  }
  v(pitch)

  // Split the chunks: those before the first level-1 heading are the front matter; the rest are the body.
  let chunks = body.split("\n\n").map(c => c.trim()).filter(c => c.len() > 0)
  let first-h1 = chunks.position(c => kind(c) == "h1")
  let front = if first-h1 == none { chunks } else { chunks.slice(0, first-h1) }
  let rest = if first-h1 == none { () } else { chunks.slice(first-h1) }

  let render-chunks(list) = {
    let parts = ()
    let letters = "(1)"
    let unnumbered = false
    for c in list {
      let k = kind(c)
      if k == "directive" { continue }
      if k == "h1" or k == "h2" or k == "h3" {
        let lvl = if k == "h1" { 1 } else if k == "h2" { 2 } else { 3 }
        parts.push(v(pitch))
        parts.push(on-grid(heading(level: lvl, outlined: true)[#inl(c.slice(lvl + 1).trim())], sticky: true))
      } else if k == "list" {
        let items = list-items(c).map(i => on-grid(inl(i), width: text-width - 1in))
        parts.push(enum(numbering: letters, spacing: 0pt, indent: 0.5in, body-indent: 0.5in, ..items))
      } else {
        parts.push(on-grid([#h(para-indent)#inl(c)]))
      }
    }
    parts.join()
  }

  render-chunks(front)

  // The tables (LR 7.8): the table of contents is generated from the body headings; the table of authorities is
  // the sample's list, with page references given in the sample.
  if "authorities" in meta {
    pagebreak()
    align(center, on-grid(text(weight: "bold")[TABLE OF CONTENTS]))
    v(pitch)
    outline(title: none, depth: 3, indent: 1.5em)
    pagebreak()
    align(center, on-grid(text(weight: "bold")[TABLE OF AUTHORITIES]))
    v(pitch)
    table-of-authorities(meta.authorities)
  }

  // The body: arabic page numbers from 1.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  render-chunks(rest)

  // Signature (LR 11.1), then the certificate of service.
  v(pitch)
  signature(meta.signature)
  if "certificate" in meta {
    v(pitch)
    align(center, on-grid(text(weight: "bold")[CERTIFICATE OF SERVICE], sticky: true))
    on-grid([#h(para-indent) #inl(meta.certificate.text)], sticky: true)
    v(pitch)
    signature(meta.certificate.signature)
  }
}
