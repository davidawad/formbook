// Complaint for the U.S. District Court for the Northern District of Illinois (ilnd).
// Rules: N.D. Ill. LR 5.2(e) (8 1/2 x 11 paper; line spacing at least 2.0 lines; 12-point body type;
// footnotes at least 11 points; margins at least 1 inch on all four sides); Fed. R. Civ. P. 8(a), 10(a),
// 10(b), 11(a), 38(b). See ../README.md. Content-agnostic: every case-specific word comes from the
// sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // no font is mandated by LR 5.2(e); Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (see README.md)
#let type-size = 12pt                   // LR 5.2(e)(1): 12-point type in the body of the text
#let page-w = 8.5in                     // LR 5.2(e): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin-top = 1in                   // LR 5.2(e)(2): each margin at least 1 inch
#let margin-bottom = 1in
#let margin-left = 1in
#let margin-right = 1in
#let text-width = page-w - margin-left - margin-right
// LR 5.2(e): "line spacing will be at least 2.0 lines". In Liberation Serif at 12 pt the natural line
// box is 0.655 em (7.86 pt), so 1.645 em of leading gives a 27.6 pt baseline pitch, the pitch of double-spaced
// 12-point Times New Roman in the filed exemplar (2 x 13.8 pt).
#let body-leading = 1.645em

#let pitch = 27.6pt                    // one double-spaced line: the height a heading or a list item takes up
#let single-leading = 0.5em             // single spacing (13.8 pt pitch) for the caption, signature and counsel blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let para-number-gap = 0.25in           // space between a paragraph number and its text
#let caption-left = 3.3in               // width of the party column of the caption
// Headings after which paragraphs are not numbered: a prayer and a jury demand are not claims, so Fed. R.
// Civ. P. 10(b) (numbered paragraphs for claims) does not reach them.
#let unnumbered-after = ("PRAYER FOR RELIEF", "DEMAND FOR JURY TRIAL")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (one chunk: a paragraph, a list or a heading).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading is set single-spaced inside its own block (a wrapped heading takes one line per row), with one
/// double-spaced line of space above and below. Typst puts leading between lines but not after the last one, so
/// the space below is what keeps the next line of text clear of the heading.
#let heading-line(c) = block(width: text-width, sticky: true, above: body-leading, below: body-leading, {
  set par(leading: single-leading, spacing: 0pt)
  set text(hyphenate: false)
  c
})

#let pitch-gap = 1.2em                  // a blank space between groups on the first page

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered in the bottom margin (LR 5.2 sets no page-number rule; the number is conventional).
#let footer-block() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper (Fed. R. Civ. P. 10(a); LR 5.2(e))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE NORTHERN DISTRICT OF ILLINOIS],
    ..if "division" in meta { (upper(meta.division),) } else { () },
  )))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  // Left: the parties, closed by a rule on the right and the bottom.
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 {
        v(single-leading)
        h(0.9in)
        [v.]
        v(single-leading)
      }
      for n in p.names { line-stack((n,)) }
      v(single-leading)
      h(0.5in)
      inl(p.designation)
    }
  }),
  // Right: the case number, the judge when assigned, the title and any jury legend.
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Case No.: #meta.case_number]
    if "judge" in meta and meta.judge != none {
      v(single-leading)
      [Judge #meta.judge]
    }
    v(pitch-gap)
    stack(dir: ttb, spacing: single-leading, ..meta.brief_title.map(l => text(weight: "bold", l)))
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch-gap)
      text(weight: "bold", "JURY TRIAL DEMANDED")
    }
  }),
)

#let first-page(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(single-leading * 2)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
      v(single-leading * 2)
      line-stack(meta.signature.firm)
      v(single-leading * 2)
      line-stack(meta.signature.party)
    },
  )
})

/// The body. Each blank-line-separated chunk is a heading, a list (lettered (a), (b) by the template) or a
/// paragraph (numbered 1, 2, ... by the template, unless it follows a heading in `unnumbered-after`).
/// A heading is sticky: it is kept with the block after it, so it never ends a page.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let numbered = true
  let pieces = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let title = upper(t.replace(regex("^#+\\s*"), ""))
      if t.starts-with("# ") { numbered = title not in unnumbered-after }
      pieces.push((kind: "h", body: md(t)))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists may break across pages; each item fills whole lines.
      pieces.push((kind: "l", body: block(width: text-width, {
        set par(leading: body-leading)
        md(t)
      })))
    } else if numbered {
      n += 1
      pieces.push((kind: "p", body: block(width: text-width, {
        set par(leading: body-leading, justify: true)
        h(para-indent)
        [#n.]
        h(para-number-gap)
        md(t)
      })))
    } else {
      pieces.push((kind: "p", body: block(width: text-width, {
        set par(leading: body-leading, justify: true)
        h(para-indent)
        md(t)
      })))
    }
  }
  // The last paragraph, with the heading in front of it if any, is kept with the signature block: a signature
  // alone at the top of a page is not filed that way.
  let k = pieces.len()
  let tail-start = if k >= 2 and pieces.at(k - 2).kind == "h" { k - 2 } else { calc.max(k - 1, 0) }
  (
    pieces.slice(0, tail-start).map(p => p.body).join(),
    pieces.slice(tail-start).map(p => p.body).join(),
  )
}

#let ilnd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right),
    footer: footer-block(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: true)
  set block(spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section; level 2 a centered sub-heading; level 3 bold, flush left.
  show heading.where(level: 1): it => heading-line(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(text(weight: "bold", it.body))

  first-page(meta)

  if "lead_in" in meta {
    set par(leading: body-leading, justify: true)
    h(para-indent)
    md(meta.lead_in)
    parbreak()
  }

  let (main, tail) = body-chunks(body)
  main
  block(breakable: false, width: text-width, {
    tail
    signature-block(meta)
  })
}
