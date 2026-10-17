// Brief in support of a motion (Rule 12(b)) for the U.S. District Court for the Northern District of Texas (txnd).
// Rules: N.D. Tex. LR 7.2 (12-point or larger type, double spacing with exceptions for quotations and headings,
// margins of at least one inch, 25-page limit excluding the tables, and for a brief longer than 10 pages a table of
// contents and an alphabetical table of authorities with page references); LR 10.1 (required form: typed,
// 8 1/2 by 11, numbered pages, title, signature block with bar number, telephone and email); Fed. R. Civ. P. 10(a)
// (caption). See ../README.md for the rule text, the date verified and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // LR 7.2 sets only the size; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR 7.2: 12-point or larger
#let pitch = 24pt                       // double spacing: baseline-to-baseline distance of body text at 12 pt
#let page-w = 8.5in                     // LR 10.1: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin-all = 1in                   // LR 7.2: margins of at least one inch
#let text-width = page-w - 2 * margin-all
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em leading gives a 24 pt pitch at 12 pt (README.md)
#let single-leading = 0.495em            // single spacing: caption, headings, block quotations, tables, signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.0in               // width of the party column of the caption
#let caption-sign = 0.3in               // the column of section marks (§) between the parties and the case data
#let toa-passim-after = 5               // a authority on more pages than this is listed as "passim" (LR 7.2 tables)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item: a stack of blocks, each line one single-spaced pitch below the last.
#let line-stack(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))

/// Escape a string for use inside a regex pattern (the authority keys are literal text).
#let esc(s) = s.clusters().map(c => if c in "\\.()[]{}*+?^$|" { "\\" + c } else { c }).join()

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (no page number)
// ---------------------------------------------------------------------------

/// The caption: each party name and designation is one row, with a section mark beside it; the case number and
/// the jury legend sit in the right-hand column, on the middle rows. Each name is one line in the sample; a name
/// that wraps would shift the marks in its row (see README.md).
#let caption(meta) = {
  let lines = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { lines.push("v.") }
    lines += p.names + (p.designation,)
  }
  let mid = calc.floor(lines.len() / 2)
  let cells = ()
  for (i, l) in lines.enumerate() {
    cells.push(align(left, inl(l)))
    cells.push(align(center, "§"))
    if i == mid - 1 {
      cells.push(align(left, "CIVIL ACTION NO. " + meta.case_number))
    } else {
      cells.push([])
    }
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  table(
    columns: (caption-left, caption-sign, 1fr),
    stroke: none,
    inset: 0pt,
    row-gutter: single-leading,
    ..cells,
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let court-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS")
  if "court_division" in meta and meta.court_division != none {
    court-lines.push(upper(meta.court_division))
  }
  align(center, stack(dir: ttb, spacing: single-leading, ..court-lines.map(l => text(weight: "bold", l))))
  v(pitch)
  caption(meta)
  v(pitch * 2)
  align(center, text(weight: "bold", inl(meta.brief_title)))
}

// ---------------------------------------------------------------------------
// Tables: contents (from the headings) and index of authorities (from the frontmatter)
// ---------------------------------------------------------------------------

/// The index of authorities. Each authority's pages are the pages of the body where its key occurs; the body is
/// tagged by the show rule in `txnd-motion-brief` (metadata with label <toa-hit>), and queried here.
#let index-of-authorities(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", "INDEX OF AUTHORITIES"))
  v(pitch)
  context {
    let hits = query(<toa-hit>)
    for cat in meta.authorities {
      text(weight: "bold", cat.category)
      v(single-leading)
      for e in cat.entries {
        let pages = hits.filter(h => h.value == e.key).map(h => counter(page).at(h.location()).first()).dedup()
        let where = if pages.len() == 0 { "" } else if pages.len() > toa-passim-after { "passim" } else { pages.map(str).join(", ") }
        grid(
          columns: (1fr, 0.9in),
          column-gutter: 0.1in,
          inl(e.cite),
          align(right, where),
        )
        v(single-leading)
      }
      v(single-leading)
    }
  }
}

// ---------------------------------------------------------------------------
// Body: paragraphs (unnumbered: briefs do not number paragraphs), headings, lists, quotations, signature
// ---------------------------------------------------------------------------

/// Body text: blank-line-separated chunks; a `#` heading, a list, a quotation or a paragraph.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists: a bullet per item, spaced by body-leading; the trailing v() closes the last one.
      block(width: text-width, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else if t.starts-with(">") {
      // Quotations are single-spaced and indented (show rule below); the block is kept whole.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      block(width: text-width, below: body-leading, {
        context [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
  }
}

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  pad(left: 3.0in, {
    [Respectfully submitted,]
    v(pitch * 0.5)
    for s in meta.signature {
      line-stack(("/s/ " + s.signer, s.signer, s.bar) + s.firm + s.address + s.lines)
      v(pitch * 0.5)
    }
  })
})

#let txnd-motion-brief(meta, body) = {
  // Keys of the authorities: each occurrence in the body is tagged so the index can count its pages.
  let keys = meta.authorities.map(c => c.entries.map(e => e.key)).flatten()
  let key-pattern = regex(keys.map(esc).join("|"))

  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set page(paper: "us-letter", margin: margin-all)

  // Headings: level 1 is a centered bold section; level 2 a bold heading with a hanging letter; level 3 a bold
  // heading with a hanging numeral. Each heading stays with the paragraph after it.
  show heading.where(level: 1): it => block(width: text-width, above: pitch, below: body-leading, sticky: true,
    par(leading: single-leading, align(center, text(weight: "bold", it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    par(leading: single-leading, hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    par(leading: single-leading, hanging-indent: 0.5in, text(weight: "bold", it.body)))

  // Quotations: single-spaced, indented 0.5 inch on both sides.
  show quote.where(block: true): it => block(width: text-width, below: body-leading, inset: (left: 0.5in, right: 0.5in),
    par(leading: single-leading, it.body))

  // Lists: bullets, indented.
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Cover (no page number).
  page(numbering: none, margin: margin-all)[
    #cover(meta)
  ]

  // Front matter: table of contents and index of authorities, roman numerals.
  page(numbering: "i", margin: margin-all)[
    #set par(leading: single-leading, spacing: 0pt, justify: false)
    #align(center, text(weight: "bold", "TABLE OF CONTENTS"))
    #v(pitch)
    #set block(spacing: single-leading)
    #outline(title: none, depth: 3, indent: 1.5em)
    #pagebreak()
    #index-of-authorities(meta)
  ]

  // Body: arabic numerals from 1. The show rule tags each authority occurrence; it applies only in this block.
  page(numbering: "1", margin: margin-all)[
    #counter(page).update(1)
    #show key-pattern: it => [#it#metadata(it.text)<toa-hit>]
    #body-chunks(body)
    #v(pitch)
    #signature-block(meta)
  ]
}
