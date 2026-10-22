// Memorandum in support of a motion (lawd motion-brief): the Rule 12(b) memorandum of this district.
// Rules: W.D. La. LR 7.1 and LR 7.8 (25-page limit exclusive of the tables; a memorandum over 10 pages needs a
// table of contents and a table of authorities); LR 10.1 (8 1/2 x 11 paper, paginated, double spaced except
// footnotes and quotations; caption with the division and the district and magistrate judges); LR 11.1 (counsel's
// name, address, telephone and bar number under the signature); Fed. R. Civ. P. 10(a). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no W.D. La. font rule (LR 7.1, 7.8, 10.1, checked 2026-10-14); Times New Roman, the default per docs/FONTS.md
#let type-size = 12pt                   // convention for filed briefs; the rule set does not state a size
#let page-margin = 1in                  // convention; the rule set does not state margins
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let list-indent = 0.5in                // a list item's label sits half an inch in ...
#let label-box = 0.5in                  // ... in a box of half an inch; the text hangs 1 in from the margin
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-star = 0.3in               // width of the asterisk column between the parties and the case number
#let designation-indent = 1.5in         // a party's designation ("Plaintiffs,") is set 1.5 in into the party column
#let sig-left = 3.25in                  // the signature block's date column; the signature lines at the right
#let toc-step = 18pt                    // the table of contents: each heading level a step further in
#let page-col = 0.5in                   // the tables: the column the page references stand in
#let toa-hang = 0.5in                   // the table of authorities: a long entry's turn lines hang half an inch in
#let blank = "_______________________"  // a blank for a caption entry not yet known (23 underscores, 1.9 in)
#let divisions = ("ALEXANDRIA", "LAFAYETTE", "LAKE CHARLES", "MONROE", "SHREVEPORT") // the five W.D. La. divisions

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lawd-motion-brief.lua sets the same twips).
#let pitch-body = 24pt                  // LR 10.1 double spacing: 24 pt lines at 12 pt (the body, headings, tables)
#let pitch-single = 13.8pt              // the court title, caption, title and signature block (single spaced)
#let block-gap = 24pt                   // one blank double-spaced line: court title to caption, caption to title, title
                                        // to the text, above every heading, below a table's title, above a signature
#let subtitle-above = 6pt               // the title to the subtitle (the filer line)
#let footer-descent = 36.76pt           // the page number in a single line box whose foot is 0.3 in above the page foot
                                        // (Word: w:footer 432 twips, docx/reference.xml)

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

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One line (a paragraph of its own), with an explicit space above it.
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

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

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
/// they follow the text (docx: the same count from the face's advance widths, docx/lawd-motion-brief.lua).
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

/// A signature block (LR 11.1): the date (if the sample gives one) at the left; at the right the lead-in (if any),
/// a blank line and the sample's lines. Kept whole; the space above it is spacing of its own (docx: an empty
/// paragraph of that height).
#let signature(sig, lead: "Respectfully submitted,") = v(block-gap) + block(width: 100%, breakable: false,
  above: 0pt, below: 0pt, grid(
    columns: (sig-left, 1fr),
    if "date" in sig { line-stack(("Dated: " + sig.date,)) },
    line-stack((..if lead != none { (lead, "") } else { () }, ..sig.lines)),
  ))

// ---------------------------------------------------------------------------
// The tables (LR 7.1, 7.8)
// ---------------------------------------------------------------------------

/// A table's title: centered bold on the body pitch, a blank line below it.
#let table-title(s) = block(width: 100%, above: 0pt, below: block-gap,
  align(center, par(first-line-indent: 0pt, text(weight: "bold", s))))

/// One contents row: a step in per heading level below the first; the page number in its own column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), page-col, ind, 0pt)
}

/// The table of authorities: one bold category per group; each entry with a dot leader to its page references
/// (typed in the sample).
#let table-of-authorities(groups) = {
  for g in groups {
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, par(first-line-indent: 0pt, text(weight: "bold", g.category)))
    for item in g.items {
      listing-row(none, unloose(inl(item.cite)), item.pages, page-col, toa-hang, 0pt)
    }
  }
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

/// The body blocks of a run of chunks, in order (an array, so the last can be kept with the signature).
#let render-chunks(list) = {
  let parts = ()
  for c in list {
    let k = kind(c)
    if k == "directive" { continue }
    if k == "h1" or k == "h2" or k == "h3" {
      let lvl = if k == "h1" { 1 } else if k == "h2" { 2 } else { 3 }
      parts.push(heading(level: lvl, outlined: true, inl(c.slice(lvl + 1).trim())))
    } else if k == "list" {
      // A numbered list: "(1)" half an inch in, in a half-inch box; the text hangs under the text.
      for (i, item) in list-items(c).enumerate() {
        parts.push(block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
          par(first-line-indent: 0pt, hanging-indent: label-box,
            [#box(width: label-box, numbering("(1)", i + 1))#unloose(inl(item))]))))
      }
    } else {
      parts.push(body-par(inl(c)))
    }
  }
  parts
}

/// Render the memorandum. `meta` is the sample's frontmatter; `body` is its markdown body.
/// Front matter (caption and the opening paragraphs) is numbered in roman; the tables follow; the body starts at 1.
#let lawd-motion-brief(meta, body) = {
  assert(upper(meta.division) in divisions, message: "lawd-motion-brief: division must be one of the five W.D. La. divisions")

  // Every page numbered, bottom centre (LR 10.1: paginated); the number in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, numbering: "i", footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Headings on the body pitch, a blank line above them, kept with the block after them: level 1 a centered bold
  // section in capitals; level 2 bold at the margin; level 3 bold italic.
  show heading: it => {
    set text(size: type-size)
    let b = if it.level == 1 { text(weight: "bold", upper(it.body)) } else if it.level == 2 {
      text(weight: "bold", it.body) } else { text(weight: "bold", style: "italic", it.body) }
    block(width: 100%, sticky: true, above: block-gap, below: 0pt,
      if it.level == 1 { align(center, par(first-line-indent: 0pt, b)) } else { par(first-line-indent: 0pt, b) })
  }

  // Court title (LR 10.1; FRCP 10(a)). The division comes from the sample.
  {
    set text(..edges(pitch-single))
    for l in ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF LOUISIANA", upper(meta.division) + " DIVISION") {
      line-block(align(center, l))
    }
  }
  block(width: 100%, above: block-gap, below: 0pt, caption(meta.caption, meta))
  {
    set text(..edges(pitch-single))
    line-block(above: block-gap, align(center, text(weight: "bold", upper(meta.title))))
    if "subtitle" in meta {
      line-block(above: subtitle-above, align(center, text(weight: "bold", upper(meta.subtitle))))
    }
  }
  v(block-gap)

  // Split the chunks: those before the first level-1 heading are the front matter; the rest are the body.
  let chunks = body.split("\n\n").map(c => c.trim()).filter(c => c.len() > 0)
  let first-h1 = chunks.position(c => kind(c) == "h1")
  let front = if first-h1 == none { chunks } else { chunks.slice(0, first-h1) }
  let rest = if first-h1 == none { () } else { chunks.slice(first-h1) }

  render-chunks(front).join()

  // The tables (LR 7.1, 7.8): the table of contents is generated from the body headings; the table of authorities
  // is the sample's list, with the page references given in the sample.
  if "authorities" in meta {
    pagebreak()
    table-title[TABLE OF CONTENTS]
    {
      show outline.entry: toc-entry
      outline(title: none, depth: 3, indent: 0pt)
    }
    pagebreak()
    table-title[TABLE OF AUTHORITIES]
    table-of-authorities(meta.authorities)
  }

  // The body: arabic page numbers from 1.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  let parts = render-chunks(rest)
  // The last block stays whole with the signature block (LR 11.1), so the signature never stands alone on a page.
  parts.slice(0, -1).join()
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, parts.last() + signature(meta.signature))

  // The certificate of service: heading, text and signature kept together.
  if "certificate" in meta {
    block(width: 100%, breakable: false, above: block-gap, below: 0pt, {
      align(center, par(first-line-indent: 0pt, text(weight: "bold")[CERTIFICATE OF SERVICE]))
      body-par(inl(meta.certificate.text))
      signature(meta.certificate.signature, lead: none)
    })
  }
}
