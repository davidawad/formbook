// Brief in support of a motion (Rule 12(b)) for the U.S. District Court for the Northern District of Texas (txnd).
// Rules: N.D. Tex. LR 7.2 (12-point or larger type, double spacing with exceptions for quotations and headings,
// margins of at least one inch, 25-page limit excluding the tables, and for a brief longer than 10 pages a table of
// contents and an alphabetical table of authorities with page references); LR 10.1 (required form: typed,
// 8 1/2 by 11, numbered pages, title, signature block with bar number, telephone and email); Fed. R. Civ. P. 10(a)
// (caption). See ../README.md for the rule text, the date verified and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 7.2 sets only the size; Times New Roman (vendored), the exemplars' face
#let type-size = 12pt                   // LR 7.2: 12-point or larger
#let margin-all = 1in                   // LR 7.2: margins of at least one inch
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let list-indent = 0.5in                // bullets: the bullet half an inch in, the text a box of this width after it
#let quote-indent = 0.5in               // quotations: indented from both margins
#let heading-hang = 0.5in               // level-2 and level-3 headings: the lines after the first hang this far
#let caption-left = 3.0in               // width of the party column of the caption
#let caption-sign = 0.3in               // the column of section marks (§) between the parties and the case data
#let sig-left = 3.0in                   // the signature block starts here
#let toc-step = 18pt                    // contents: each level steps in 1.5 em
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 72pt                // authorities: the page lists keep the last inch of the line to themselves
#let toa-passim-after = 5               // an authority on more pages than this is listed as "passim" (LR 7.2 tables)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing (LR 7.2): the body's baseline-to-baseline distance at 12 pt
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size; cover, headings, quotations, tables, signature
#let cover-gap = 18pt                   // between the court title and the caption; below a table's title
#let title-above = 42pt                 // between the caption and the title of the brief
#let row-gap = 6pt                      // between the rows of the tables and the groups of the signature block
#let group-gap = 12pt                   // above a group of the index of authorities (Cases, Statutes, Rules)
#let h1-above = 16pt                    // a level-1 heading stands off the text above it
#let h2-above = 8pt                     // a level-2 or level-3 heading sits on the double-spaced grid of the text
#let heading-below = 2pt                // the text below a heading keeps to the double-spaced grid
#let quote-above = 12pt                 // a quotation is set off from the text by about a single line
#let quote-below = 6pt

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
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Escape a string for use inside a regex pattern (the authority keys are literal text).
#let esc(s) = s.clusters().map(c => if c in "\\.()[]{}*+?^$|" { "\\" + c } else { c }).join()

/// A page number in a single-spaced line box, so it sits at the same place on every page (Word's footer).
#let page-foot(fmt) = context align(center, text(..edges(pitch-single), counter(page).display(fmt)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (no page number)
// ---------------------------------------------------------------------------

/// The caption: each party name and designation is one row, with a section mark beside it; the case number sits
/// in the right-hand column on the middle row. A name that wraps makes its row taller.
#let caption(meta) = {
  let lines = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { lines.push("v.") }
    lines += p.names + (p.designation,)
  }
  let mid = calc.floor(lines.len() / 2)
  let cells = ()
  for (i, l) in lines.enumerate() {
    cells.push(line-block(inl(l)))
    cells.push(line-block(align(center, "§")))
    cells.push(line-block(if i == mid - 1 [CIVIL ACTION NO. #meta.case_number]))
  }
  block(width: 100%, above: cover-gap, below: 0pt, grid(columns: (caption-left, caption-sign, 1fr), ..cells))
}

#let cover(meta) = {
  let court-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS")
  if "court_division" in meta and meta.court_division != none {
    court-lines.push(upper(meta.court_division))
  }
  for l in court-lines { line-block(align(center, text(weight: "bold", l))) }
  caption(meta)
  line-block(above: title-above, align(center, text(weight: "bold", inl(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Tables: contents (from the headings) and index of authorities (from the frontmatter)
// ---------------------------------------------------------------------------

/// A table's title: centered, bold, single spaced.
#let table-title(t) = line-block(below: cover-gap, align(center, text(weight: "bold", t)))

/// One contents row: each level steps in; the page number in its own column, a dot leader before it.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind, row-gap)
}

#let contents() = {
  table-title("TABLE OF CONTENTS")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  show outline.entry: toc-entry
  outline(title: none, depth: 3, indent: 0pt)
}

/// The index of authorities. Each authority's pages are the body pages where its key occurs; the body is tagged by
/// the show rule in `txnd-motion-brief` (metadata with label <toa-hit>), and queried here.
#let index-of-authorities(meta) = {
  table-title("INDEX OF AUTHORITIES")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  context {
    let hits = query(<toa-hit>)
    for (k, cat) in meta.authorities.enumerate() {
      line-block(above: if k == 0 { 0pt } else { group-gap }, text(weight: "bold", cat.category))
      for e in cat.entries {
        let pages = hits.filter(h => h.value == e.key).map(h => counter(page).at(h.location()).first()).dedup()
        let where = if pages.len() == 0 { "" } else if pages.len() > toa-passim-after { "passim" } else {
          pages.map(str).join(", ")
        }
        listing-row(none, inl(e.cite), where, toa-page-col, 0pt, row-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Body: paragraphs (unnumbered: briefs do not number paragraphs), headings, lists, quotations, signature
// ---------------------------------------------------------------------------

/// The signature block, at the right: "Respectfully submitted," and, for each signer, the signature (/s/ and the
/// name), the bar number, the firm, the address and the role, single spaced, the groups a little apart. It never
/// breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt,
  pad(left: sig-left, {
    line-block[Respectfully submitted,]
    for s in meta.signature {
      let items = ("/s/ " + s.signer, s.signer, s.bar) + s.firm + s.address + s.lines
      for (i, l) in items.enumerate() { line-block(above: if i == 0 { row-gap } else { 0pt }, inl(l)) }
    }
  }))

/// A body paragraph at the double pitch with a first-line indent. `keep`: kept on the page of the block after it
/// (the paragraph before the signature block stays with it).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Body text: blank-line-separated chunks; a `#` heading, a list, a quotation or a paragraph. The signature block
/// goes before a certificate of service (as in the exemplar), or at the end.
#let body-chunks(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "").map(c => c.trim())
  let cert = chunks.position(t => lower(t).match(regex("^#\\s+certificate of service\\s*$")) != none)
  let sig-at = if cert == none { chunks.len() } else { cert }
  for (i, t) in chunks.enumerate() {
    if i == sig-at { signature-block(meta) }
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: list-indent, md(t))
    } else if t.starts-with(">") {
      // Quotations: single spaced, indented from both margins (LR 7.2 allows single spacing).
      block(width: 100%, above: quote-above, below: quote-below, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        md(t.replace(regex("(?m)^>[ \\t]?"), ""))
      }))
    } else {
      body-par(md(t), keep: i == sig-at - 1)
    }
  }
  if sig-at == chunks.len() { signature-block(meta) }
}

#let txnd-motion-brief(meta, body) = {
  // Keys of the authorities: each occurrence in the body is tagged so the index can count its pages.
  let keys = meta.authorities.map(c => c.entries.map(e => e.key)).flatten()
  let key-pattern = regex(keys.map(esc).join("|"))

  set page(paper: "us-letter", margin: margin-all, footer-descent: 30%)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced); lists as a label box (list-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: list-indent)
  // A doubled section or paragraph sign stays with its number too ("¶¶ 42"; xengine binds a single sign; the docx
  // filter binds both).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings, single spaced and bold, kept with the text after them: level 1 centered; levels 2 and 3 at the
  // margin, the lines after the first hanging half an inch.
  show heading: it => {
    let above = if it.level == 1 { h1-above } else { h2-above }
    block(width: 100%, sticky: true, breakable: false, above: above, below: heading-below, {
      set text(..edges(pitch-single), size: type-size, weight: "bold")
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, it.body) } else { par(hanging-indent: heading-hang, it.body) }
    })
  }

  // Cover (no page number).
  page(footer: none, cover(meta))

  // Front matter: table of contents and index of authorities, roman numerals (the cover is page i).
  page(footer: page-foot("i"), {
    contents()
    pagebreak()
    index-of-authorities(meta)
  })

  // Body: arabic numerals from 1. The show rule tags each authority occurrence; it applies only in this block.
  page(footer: page-foot("1"), {
    counter(page).update(1)
    show key-pattern: it => [#it#metadata(it.text)<toa-hit>]
    body-chunks(meta, body)
  })
}
