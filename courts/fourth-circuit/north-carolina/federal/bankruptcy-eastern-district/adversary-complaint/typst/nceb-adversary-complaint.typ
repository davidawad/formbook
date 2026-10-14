// Adversary complaint in the U.S. Bankruptcy Court, E.D.N.C. (nceb).
// Rules: FRBP 7010 (caption per Official Form 416A, which FRCP 10 applies to) and FRCP 10(a) (caption, title, file number);
// FRCP 10(b) (allegations in numbered paragraphs, each limited as far as practicable to one set of circumstances);
// FRBP 7008(a) (statement of core or non-core status and of consent to final orders); FRBP 9004(a) (legible),
// 9004(b) (caption: court, division, case and adversary numbers, designation); LBR 9004-2 (caption states the court,
// division and chapter); LBR 9011-4 and Admin Guide Rule 5005-4(8) (signature block, "s/" signature). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no E.D.N.C. typeface rule (FRBP 9004(a): "clearly legible"); vendored in fonts/
#let type-size = 12pt                   // no E.D.N.C. type-size rule; the exemplar is a 12 pt serif
#let body-leading = 1.35em              // double spacing as in the exemplar: 0.65em line box + 1.35em leading = 24 pt pitch
#let single-leading = 0.5em             // single spacing: caption, counsel, signature, quotations, table
#let margin = 1in                       // no E.D.N.C. margin rule; 1 inch as in the exemplar
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nceb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (smart punctuation: the author's characters are kept).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Body chunks: blank-line-separated blocks of the markdown body.
#let chunks(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

/// The allegations are numbered by the template (FRCP 10(b)); the counter only counts those.
#let allegation = counter("allegation")

// ---------------------------------------------------------------------------
// Caption: court (centered caps), then the parties on the left and the case numbers on the right.
// FRBP 9004(b) and LBR 9004-2 require the court, the division, the case and adversary numbers, the chapter,
// and a designation of the paper; the title below states that designation.
// ---------------------------------------------------------------------------

#let party-block(p) = {
  for n in p.names { [#n \ ] }
  align(right, [#p.designation])
  v(single-leading * 2)
}

#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for line in meta.court { align(center, text(weight: "bold", upper(line))) }
  align(center, text(weight: "bold", upper(meta.division)))
  v(single-leading * 3)
  grid(
    columns: (3.2in, 1fr),
    column-gutter: 0.2in,
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      for p in meta.caption.in_re { party-block(p) }
      for p in meta.caption.parties { party-block(p) }
    }),
    block(inset: (left: 0.1in), {
      v(single-leading * 4)
      [Case No. #meta.case_number \ ]
      [Chapter #meta.chapter \ ]
      if "adversary_number" in meta [ \ Adversary Proceeding No. #meta.adversary_number ]
    }),
  )
  v(single-leading * 3)
  align(center, text(weight: "bold", upper(meta.title)))
  v(single-leading * 2)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(breakable: false, {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  v(single-leading * 2)
  if "lead" in sig [ #sig.lead ]
  v(single-leading * 2)
  pad(left: 3in, {
    if "firm" in sig [ #upper(sig.firm) \ ]
    v(single-leading * 2)
    for s in sig.signers {
      [#s.sign \ ]
      for l in s.lines { [#l \ ] }
      v(single-leading * 2)
    }
    if "role" in sig { [#text(style: "italic", sig.role)] }
  })
})

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, lettered introduction items, prayer list, quotations, tables
// ---------------------------------------------------------------------------

#let body-style(body) = {
  // Level 1: centered, bold, capitals (INTRODUCTION AND NATURE OF ACTION, FIRST CLAIM FOR RELIEF, PRAYER FOR RELIEF).
  show heading.where(level: 1): it => block(width: 100%, above: 24pt, below: 12pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  // Level 2: centered, bold (the name of a claim).
  show heading.where(level: 2): it => block(width: 100%, above: 6pt, below: 6pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  // Level 3: centered (the statutory citation under a claim).
  show heading.where(level: 3): it => block(width: 100%, above: 6pt, below: 12pt, sticky: true,
    align(center, text(size: type-size, it.body)))
  // Block quotations: indented 1 inch on both sides, single-spaced.
  show quote.where(block: true): it => pad(left: 1in, right: 1in, top: 6pt, bottom: 12pt, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    it.body
  })
  // Tables: single-spaced, unruled, flush with the text.
  show table: it => block(width: 100%, above: 6pt, below: 12pt, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    set table(stroke: none, inset: (x: 6pt, y: 3pt))
    it
  })
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)
  let items = chunks(body)
  let first-heading = items.position(c => c.starts-with("#"))
  if first-heading == none { first-heading = items.len() }
  for (i, c) in items.enumerate() {
    // each chunk is a block of its own, so one allegation never runs into the next
    block(width: 100%, if c.starts-with("#") or c.starts-with("|") or c.starts-with(">") or c.starts-with("- ") or c.match(regex("^\\d+\\. ")) != none {
      // headings, tables, quotations and the prayer list are not numbered
      md(c)
    } else if c.starts-with("~") {
      // a paragraph the template must not number: the author writes a leading "~" (removed here)
      md(c.slice(1).trim())
    } else if c.starts-with("(") {
      // a parenthetical that completes the paragraph before it (e.g. a table is followed by "(collectively, ...)")
      md(c)
    } else if c.starts-with("[") {
      // bracketed editorial notes about the transcription are unnumbered and set in italics
      text(style: "italic", md(c))
    } else if c.match(regex("^[A-Z]\\. ")) != none {
      // lettered items of the introduction: unnumbered, indented
      pad(left: 0.5in, md(c))
    } else if i < first-heading {
      // the lead-in paragraph before the first heading is unnumbered
      md(c)
    } else {
      allegation.step()
      context {
        let n = allegation.get().first()
        md(str(n) + "\\. \u{2003}" + c)
      }
    })
  }
}

#let nceb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  caption(meta)
  body-style(body)
  signature-block(meta.signature)
}
