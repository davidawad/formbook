// United States Court of International Trade (cit): complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CIT-...) refer to ../README.md, which quotes the
// rule text: USCIT Rules 81(b), (d), (f) (paper, type size, double spacing, page numbers), 10(a), 10(b)
// (caption, numbered paragraphs), 7(a) (designation), 11(a) (signer's contact details). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The body is markdown, rendered
// by cmarker; the metadata is the YAML frontmatter of the same file (schema: ../README.md).
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the two
// explicit spacings. The docx engine (../docx/) sets the same pitches, spaces, indents and columns.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman; Liberation Serif is its metric twin
#let type-size = 12pt                    // CIT-TYPE-001: Rule 81(f), 12 point or larger, footnotes included
#let pitch = 24pt                        // CIT-SPACE-001: Rule 81(f), double spaced: 24 pt line pitch at 12 pt
#let pitch-single = 14pt                 // caption, title, counsel and signature lines, page number: single spaced
#let page-w = 8.5in                      // CIT-PAPER-001: Rule 81(f), 8 1/2 by 11 inches
#let page-h = 11in
#let margin-x = 1in                      // CIT-PAPER-002: typed matter 6 1/2 in wide (limit 6 1/2 in) ...
#let margin-y = 1in                      // ... and 9 in tall (limit 9 1/2 in); the page number sits in the bottom margin
#let margins = (top: margin-y, bottom: margin-y, x: margin-x)
#let para-indent = 0.5in                 // first-line indent of every body paragraph; the allegation number starts here
#let number-box = 0.6in                  // the allegation number in a box: its text starts 1.1 in from the margin
#let item-indent = 0.5in                 // lettered list items: the letter at 0.5 in ...
#let item-box = 0.4in                    // ... the text at 0.9 in, wrapped lines hanging there
#let heading-above = 12pt                // space above a section heading (none below: the body pitch carries it)
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-paren = 0.3in               // width of the column of ")" marks (the caption's mark column)
#let caption-desig = 1.2in               // indent of a party's designation ("Plaintiff,") in the party column
#let caption-right = 0.2in               // indent of the court number in the right column
#let sig-left = 2.8in                    // signature block: the date column; the counsel column takes the rest
#let sig-gap = 12pt                      // space between "Respectfully submitted," and the /s/ line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cit-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required metadata field; a missing one fails the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("cit-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line (a paragraph of its own).
#let line1(body) = par(first-line-indent: 0pt, body)

// ---------------------------------------------------------------------------
// Cover: court title, caption (Rule 10(a)), title of the pleading
// ---------------------------------------------------------------------------

/// The caption: each party's names and designation, a ")" mark on every row, and the court number on the right.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for n in side.names { rows.push(line1(inl(n))) }
    rows.push(pad(left: caption-desig, line1(inl(side.designation))))
    if i < sides.len() - 1 { rows.push(align(center, line1[v.])) }
  }
  let right = pad(left: caption-right, {
    line1[Court No. #need(meta, "court_no")]
    if "before" in meta { line1[Before: #meta.before] }
  })
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells.push(r)
    cells.push(line1[)])
    if k == 0 { cells.push(grid.cell(rowspan: rows.len(), align(top, right))) }
  }
  grid(columns: (caption-left, caption-paren, 1fr), row-gutter: 0pt, ..cells)
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  for l in need(meta, "court") { align(center, line1(strong(upper(l)))) }
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, line1(strong(upper(inl(need(meta, "brief_title"))))))
  pagebreak()
}

// ---------------------------------------------------------------------------
// Signature block (Rule 11(a): the signer's address, e-mail and telephone are in the lines)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set text(..edges(pitch-single))
    grid(columns: (sig-left, 1fr), column-gutter: 0pt,
      line1[Dated: #need(meta, "date")],
      {
        line1[Respectfully submitted,]
        block(above: sig-gap, below: 0pt, line1[/s/ #sig.signer])
        for l in sig.lines { line1(inl(l)) }
      })
  })
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Rule 10(b)); headings unnumbered; lists lettered
// ---------------------------------------------------------------------------

#let md(t) = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a list
/// is one numbered paragraph. Numbering is applied per chunk, not with a `show par` rule: a show rule that
/// re-wraps paragraph content recurses without end in typst 0.15. Headings are sticky: they stay with the
/// first lines of what follows.
#let allegations(body, para-counter, unnumbered) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Paragraphs under a heading named in the frontmatter `unnumbered` list are not numbered (e.g. the prayer).
  let in-unnumbered = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
      in-unnumbered = unnumbered.contains(t.replace(regex("^#+\\s*"), "").trim())
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if in-unnumbered {
      par[#h(para-indent)#md(t)]
    } else {
      para-counter.step()
      context par[#h(para-indent)#box(width: number-box)[#(para-counter.display()).]#md(t)]
    }
  }
}

#let cit-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "court_no"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, line boxes of the body pitch,
  // lettered lists with the letter in a box (the list itself indented by item-indent).
  show: xengine.with(pitch: pitch, list-indent: item-box)
  // A doubled section sign stays with its number too ("§§ 2643(a)(1)"), as the docx filter binds it (lib/pandoc/xengine.lua).
  show regex("[§¶]{2} \\S+"): it => box(it)
  set enum(numbering: "(a)")

  // Section headings (all levels): centered, bold capitals, one body-pitch line, kept with what follows.
  show heading: it => block(width: 100%, above: heading-above, below: 0pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))

  cover(meta)

  if "lead_in" in meta { par[#h(para-indent)#inl(meta.lead_in)] }

  allegations(body, para-counter, meta.at("unnumbered", default: ()))

  signature-block(meta)
}
