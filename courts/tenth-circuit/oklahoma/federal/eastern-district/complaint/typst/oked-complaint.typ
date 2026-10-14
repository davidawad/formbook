// Complaint for the U.S. District Court for the Eastern District of Oklahoma (oked).
// Rules: LCvR 5.2(a) (paper, 12-point print style, 1-inch margins, line spacing of at least 1.5),
// LCvR 3.1 (parties numbered consecutively in the caption), Fed. R. Civ. P. 10(a) (caption) and
// 10(b) (numbered paragraphs). See ../README.md for each choice and its source.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // LCvR 5.2(a) names no typeface; EB Garamond is the vendored font (README, gap 2)
#let type-size = 12pt                   // LCvR 5.2(a): print style, footnotes included, not smaller than 12 point
#let page-margin = 1in                  // LCvR 5.2(a): margins at least 1 inch on the top, bottom and sides
#let line-pitch = 24pt                  // double spacing: LCvR 5.2(a) requires at least 1.5; the exemplar is double
#let body-leading = 1.35em              // EB Garamond line box is 0.65em, so 1.35em leading is a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // caption, counsel and signature block (README, gap 1)
#let single-pitch = 13.8pt              // one single-spaced caption row: fixed height so the ")" column lines up
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-width = 0.5in               // the paragraph number sits in the first half inch, text starts at 1 inch
#let caption-left = 3.5in               // width of the party column of the caption
#let caption-paren = 0.3in              // the column of ")" marks, as in the exemplar caption
#let text-width = 8.5in - 2 * page-margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oked-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, bold words).
// A paragraph sign keeps its number: a non-breaking space follows it, so "¶ 6" cannot break across lines.
#let inl(s) = cmarker.render(s.replace("¶ ", "¶\u{a0}"), raw-typst: false, smart-punctuation: true)

/// Single-spaced text: used for the caption, the signature block and block quotations.
#let single(c) = block(width: 100%, above: 0pt, below: 0pt, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  c
})

// ---------------------------------------------------------------------------
// Caption: court name, parties (numbered, LCvR 3.1), ")" column, case number and legends
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  single(align(center, strong(stack(dir: ttb, spacing: single-leading, ..meta.court.map(l => upper(l))))))
}

/// One caption row per line of the sample. Each row is a block of fixed height, so the ")" column
/// has exactly one mark per row whatever the font metrics.
#let caption-rows(meta) = {
  let rows = ()
  let k = 0
  let sides = (("plaintiffs", "plaintiff"), ("defendants", "defendant"))
  let first-side = true
  for (key, _) in sides {
    if not first-side {
      rows.push(none)                          // a blank row between the plaintiffs and the "v."
      rows.push("v.")
      rows.push(none)
    }
    first-side = false
    let parties = meta.caption.at(key)
    for (pi, p) in parties.enumerate() {
      if pi > 0 { rows.push(none) }
      k += 1                                   // LCvR 3.1: each party numbered, plaintiffs then defendants
      for (li, line) in p.names.enumerate() {
        rows.push((number: if li == 0 { k } else { none }, text: line))
      }
      if "designation" in p { rows.push((indent: 1.8in, text: p.designation)) }
    }
  }
  rows
}

#let caption-row(r) = block(width: 100%, height: single-pitch, if r == none {
  []
} else if type(r) == str {
  pad(left: 1.1in, r)
} else if "indent" in r {
  pad(left: r.indent, r.text)
} else {
  let label = if r.number != none { [(#r.number)] } else { [] }
  grid(columns: (number-width, 1fr), label, inl(r.text))
})

#let caption-block(meta) = {
  let rows = caption-rows(meta)
  let n = rows.len()
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  grid(
    columns: (caption-left, caption-paren, 1fr),
    stack(dir: ttb, spacing: 0pt, ..rows.map(caption-row)),
    stack(dir: ttb, spacing: 0pt, ..rows.map(_ => block(width: 100%, height: single-pitch, [)]))),
    block(width: 100%, {
      // The case number and legends sit about the middle of the party column, as in the exemplar.
      v(single-pitch * calc.max(0, calc.floor(n / 2) - 1))
      block(height: single-pitch, [Case No. #meta.case_number])
      v(single-pitch * 2)
      for l in meta.legends { block(height: single-pitch, strong(l)) }
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(line-pitch)
  caption-block(meta)
  v(line-pitch)
  block(width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(meta.title))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, block quotations, lists
// ---------------------------------------------------------------------------

#let heading-block(level, text) = block(width: 100%, above: line-pitch * 0.5, below: body-leading, sticky: true, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  if level == 1 {
    align(center, strong(upper(text)))
  } else if level == 2 {
    strong(text)
  } else {
    strong(emph(text))
  }
})

/// Markdown body, chunk by chunk (blank-line separated). A chunk is a heading (`#`), a block
/// quotation (`>`), a list (`- `), a paragraph marked `[unnumbered]` (the lead-in, the WHEREFORE and
/// the "For her ... Cause of Action" paragraphs, which the exemplar does not number), or a numbered
/// paragraph. Blocks are appended to one flow; a heading is `sticky`, so it stays with the block after
/// it. Numbering is a loop counter: a show rule that re-wraps paragraph content recurses without end
/// in typst 0.15.
#let body(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+) +([\\s\\S]*)$"))
      if m == none { panic("oked-complaint: a heading needs text: " + t) }
      out += heading-block(m.captures.at(0).len(), m.captures.at(1).trim())
    } else if t.starts-with(">") {
      // A block quotation is single-spaced and indented; it is not numbered.
      let lines = t.split("\n").map(l => {
        let s = l.trim(at: start)
        if s.starts-with(">") { s.slice(1).trim(at: start) } else { s }
      })
      out += block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, breakable: false, {
        pad(left: 1in, right: 0.5in, single(inl(lines.join("\n"))))
      })
    } else if t.starts-with("- ") {
      // A list (the prayer items, if any): lettered (a), (b), ... as in the exemplar's prayers.
      let items = t.split("\n").filter(l => l.starts-with("- ")).map(l => l.slice(2))
      for (i, it) in items.enumerate() {
        out += block(width: 100%, above: 0pt, below: body-leading, {
          set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
          h(para-indent)
          box(width: number-width)[(#("abcdefghijklmnopqrstuvwxyz".at(i))).]
          inl(it)
        })
      }
    } else {
      let unnumbered = t.starts-with("[unnumbered]")
      let text = if unnumbered { t.slice("[unnumbered]".len()).trim(at: start) } else { t }
      let label = if unnumbered { [] } else {
        n += 1
        [#n.]
      }
      out += block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
        h(para-indent)
        if not unnumbered { box(width: number-width)[#label] }
        inl(text)
      })
    }
  }
  out
}
// ---------------------------------------------------------------------------
// Signature block (LCvR 5.2(a): the form is not set by a local rule; the exemplar's layout)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sigs = meta.signature
  block(breakable: false, above: line-pitch, {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    grid(columns: (3.2in, 1fr), [], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      for (i, s) in sigs.enumerate() {
        if i > 0 { v(line-pitch * 0.5); [and]; v(line-pitch * 0.5) }
        for l in s.firm { strong(l); linebreak() }
        v(line-pitch * 0.5)
        [By: /s/ #s.signer]
        linebreak()
        for l in s.lines { inl(l); linebreak() }
      }
      if "attorneys_for" in meta {
        v(line-pitch * 0.5)
        meta.attorneys_for
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let oked-complaint(meta, md) = {
  for k in ("court", "case_number", "caption", "legends", "title", "signature") {
    if k not in meta { panic("oked-complaint: missing required metadata field `" + k + "`") }
  }

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set document(title: meta.title + ", No. " + meta.case_number, author: meta.signature.at(0).signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  cover(meta)
  body(md)
  signature-block(meta)
}
