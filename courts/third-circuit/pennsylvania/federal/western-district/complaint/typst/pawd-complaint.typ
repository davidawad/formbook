// pawd-complaint.typ: complaint for the United States District Court for the Western District of Pennsylvania.
// Rules (fetched 2026-10-14, see ../README.md): LCvR 5.1.A-B (paper, type, spacing, margins),
// LCvR 5.2.B (signature block: name, address, telephone, email, bar number with the PA prefix),
// Fed. R. Civ. P. 8(a), 10(a), 10(b), 38(b) (jury demand).
// Content-agnostic: no case text here. The sample supplies the frontmatter and the markdown body.
#import "@preview/cmarker:0.1.10"

// ---- LCvR 5.1 format ----
#let type-size = 12pt // LCvR 5.1.B: not smaller than 12 pt.
#let double = 24pt // LCvR 5.1.B: double-spaced, a baseline pitch of two type sizes (0.655 em line + 1.345 em leading).
#let para-indent = 0.5in
#let single-leading = 0.6em // headings, the caption and the signature block may be single-spaced.

#let md(s) = cmarker.render(s, smart-punctuation: true, raw-typst: false)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The caption: parties in a left column with a ")" column, the case number and the
/// jury demand in a right column that spans the rows. Names are plain text (no markdown).
#let caption(meta) = {
  let rows = ()
  for (i, p) in meta.caption.enumerate() {
    if i > 0 { rows.push("v.") }
    for n in p.names { rows.push(n) }
    rows.push(p.designation)
  }
  let right = block(width: 100%)[
    #set par(leading: single-leading)
    Civil Action No. #meta.case_number
    #if meta.at("jury_demand", default: false) [
      #v(double)
      *JURY TRIAL DEMANDED*
    ]
    #if meta.at("electronically_filed", default: false) [
      #v(double)
      Electronically Filed.
    ]
  ]
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells.push(block(width: 100%)[#set par(leading: single-leading); #r])
    cells.push(block(width: 100%)[#set par(leading: single-leading); #align(center)[)]])
    if k == 0 {
      cells.push(grid.cell(rowspan: rows.len(), align: horizon, right))
    }
  }
  grid(
    columns: (1fr, 0.4in, 2.9in),
    row-gutter: single-leading,
    ..cells,
  )
}

/// Each chunk of the markdown body is a block of text between blank lines.
#let chunks(body) = body.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// List items of a chunk: a line that starts "- " opens an item; other lines continue it.
#let list-items(chunk) = {
  let items = ()
  for line in chunk.split("\n") {
    if line.starts-with("- ") {
      items.push(line.slice(2))
    } else if items.len() > 0 {
      let last = items.pop()
      items.push(last + " " + line.trim())
    }
  }
  items
}

/// Whether a paragraph is numbered: every body paragraph is, except the prayer lead-in
/// ("WHEREFORE ...") and the jury demand line, which are not allegations (Fed. R. Civ. P. 10(b)).
#let numbered(chunk) = not (chunk.starts-with("WHEREFORE") or chunk.starts-with("JURY TRIAL DEMANDED"))

/// The body. Each chunk is one block: a heading (# section, ## count, ### sub), a numbered
/// paragraph, an unnumbered paragraph, or a run of lettered list items (the prayer, or the
/// sub-paragraphs of the paragraph above). Every block is its own layout unit, so the
/// paragraphs stack and no heading can overlap the text next to it.
#let body-content(body) = {
  let n = 0
  let letters = "abcdefghijklmnopqrstuvwxyz"
  for c in chunks(body) {
    if c.starts-with("### ") {
      block(width: 100%, sticky: true, above: double, below: 0pt)[
        #set par(leading: single-leading)
        #strong(c.slice(4))
      ]
    } else if c.starts-with("## ") {
      // A count heading may run to several lines in the filing (its statute line): one line per source line.
      block(width: 100%, sticky: true, above: double, below: 0pt)[
        #set par(leading: single-leading)
        #align(center, c.slice(3).split("\n").map(l => strong(l.trim())).join(linebreak()))
      ]
    } else if c.starts-with("# ") {
      block(width: 100%, sticky: true, above: double, below: 0pt)[
        #set par(leading: single-leading)
        #align(center, strong(upper(c.slice(2))))
      ]
    } else if c.starts-with("- ") {
      for (i, item) in list-items(c).enumerate() {
        block(width: 100%)[
          #grid(
            columns: (1in, 1fr),
            pad(left: 0.5in)[#letters.at(i).],
            md(item),
          )
        ]
      }
    } else if c.starts-with("JURY TRIAL DEMANDED") {
      block(width: 100%, sticky: true, above: double)[
        #align(center, strong(c))
      ]
    } else if numbered(c) {
      n += 1
      block(width: 100%)[#h(para-indent)#(str(n) + ".")#h(para-indent)#md(c)]
    } else {
      block(width: 100%)[#h(para-indent)#md(c)]
    }
  }
}

/// The signature block after the body. Single-spaced, set at the right half of the page.
#let signature(sig, date) = {
  block(breakable: false, width: 100%, above: double)[
    #set par(leading: single-leading)
    #if date != none [Dated: #date \ ]
    #v(double)
    #pad(left: 3.0in)[
      #sig.lead
      #v(double)
      #if sig.at("firm", default: none) != none [#for f in sig.firm [#f \ ]]
      #v(double)
      #sig.signer \
      #for l in sig.lines [#md(l) \ ]
    ]
  ]
}

/// The complaint. Page 1 carries the court title and the caption, and the body follows on.
#let pawd-complaint(meta, body) = {
  set document(title: meta.case_number + " " + meta.title)
  set page(
    paper: "us-letter",
    margin: 1in,
    numbering: "1",
    number-align: center,
    footer-descent: 0.4in,
  )
  set text(font: "Liberation Serif", size: type-size, lang: "en", ligatures: true)
  set par(leading: 1.345em, justify: false, spacing: 0pt) // 0.655 em line (Liberation Serif) + 1.345 em leading = a 24 pt pitch at 12 pt
  set block(spacing: 1.345em) // the gap between blocks is the leading again, so the pitch stays 24 pt

  block(width: 100%, align(center)[*IN THE UNITED STATES DISTRICT COURT*])
  block(width: 100%, above: 0pt, align(center)[*FOR THE WESTERN DISTRICT OF PENNSYLVANIA*])
  block(width: 100%, above: double, caption(meta))
  block(width: 100%, above: double, align(center, strong(meta.title)))
  if meta.at("lead_in", default: none) != none {
    block(width: 100%, above: double)[#h(para-indent)#md(meta.lead_in)]
  }
  body-content(body)
  signature(meta.signature, meta.at("date", default: none))
}
