// Adversary complaint for the United States Bankruptcy Court, E.D. Pennsylvania (paeb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption must substantially conform to Form 416),
// 9004(a) (clearly legible), 9004(b) (caption: court, title, case number and adversary number, designation);
// L.B.R. 9004-1(b) (8 1/2 x 11 inch paper). The 7008(a) consent statement is author content (see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // no E.D. Pa. rule names a font; Times New Roman substitute per docs/FONTS.md (README.md)
#let type-size = 12pt                   // convention; the Krueger and TIG exemplars are 12 point
#let body-leading = 1.345em             // double spacing: 24 pt baseline pitch at 12 pt (README.md)
#let single-leading = 0.5em             // single spacing for the caption, the signature block and the service list
#let margin = 1in                       // convention (no E.D. Pa. margin rule)
#let para-indent = 0.5in                // first-line indent of paragraphs
#let number-gap = 0.3in                 // gap between a paragraph number and its text
#let designation-indent = 1.2in         // "Plaintiffs," and "Defendant." sit under the names
#let caption-cols = (3.4in, 0.35in, 2.75in)  // party column, colon column, case column (6.5 in text width)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("paeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (inline names, quotations, headings, lists).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

// ---------------------------------------------------------------------------
// Cover: court, caption, title (Fed. R. Bankr. P. 9004(b), 7010)
// ---------------------------------------------------------------------------

#let court-title(meta) = align(center, stack(
  dir: ttb,
  spacing: single-leading,
  text(weight: "bold", upper(meta.court)),
  text(weight: "bold", upper(meta.district)),
))

/// Caption rows: (party column, case column). The case column carries the chapter, the case number
/// and the adversary number; the party column carries the debtor, the parties and "v.".
#let caption-rows(meta) = {
  let rows = ()
  rows.push(("IN RE:", "Chapter " + meta.chapter))
  rows.push((meta.debtor.name, "Case No. " + meta.case_number))
  if meta.debtor.designation != "" {
    rows.push(([#h(designation-indent)#meta.debtor.designation], ""))
  }
  rows.push(("", ""))
  for (k, p) in meta.parties.enumerate() {
    if k > 0 {
      rows.push(("", ""))
      rows.push(("v.", ""))
      rows.push(("", ""))
    }
    for (j, name) in p.names.enumerate() {
      let case-cell = if k == 0 and j == 0 { "Adv. Proc. No. " + meta.adversary_number } else { "" }
      rows.push((name, case-cell))
    }
    if p.designation != "" {
      rows.push(([#h(designation-indent)#p.designation], ""))
    }
  }
  rows
}

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let cells = ()
  for (l, r) in caption-rows(meta) {
    cells.push(l)
    cells.push([:])
    cells.push(r)
  }
  // Cells hold plain text, not paragraphs, so the single leading is supplied by the row gutter.
  grid(columns: caption-cols, row-gutter: single-leading, ..cells)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists
// ---------------------------------------------------------------------------

/// Each markdown chunk becomes one piece of content. Paragraphs are numbered in order (Fed. R. Civ. P.
/// 10(b), applied by Rule 7010). A chunk that starts with ">" is unnumbered (a WHEREFORE clause).
/// Headings and lists are not numbered. Every piece is followed by a double-spaced line.
#let body-pieces(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let pieces = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pieces.push((keep: true, content: md(t)))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pieces.push((keep: false, content: {
        set enum(numbering: meta.at("list_numbering", default: "(a)"), indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        block(width: 100%, below: body-leading, md(t))
      }))
    } else if t.starts-with(">") {
      pieces.push((keep: true, content: block(width: 100%, below: body-leading, [#h(para-indent)#md(t.slice(1).trim())])))
    } else {
      n += 1
      pieces.push((keep: false, content: block(width: 100%, below: body-leading, [#h(para-indent)#(str(n) + ".")#h(number-gap)#md(t)])))
    }
  }
  pieces
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  block(breakable: false, width: 100%, {
    grid(
      columns: (3in, 1fr),
      [Dated: #s.date],
      {
        set par(leading: single-leading, spacing: 0pt)
        [Respectfully submitted,]
        v(single-leading)
        [#s.firm]
        v(single-leading)
        [By: /s/ #s.signer]
        for line in s.lines {
          linebreak()
          line
        }
      },
    )
  })
}

#let certificate(meta) = {
  let c = meta.certificate
  block(breakable: false, above: body-leading, width: 100%, {
    v(body-leading)
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading)
    [#h(para-indent)I, #c.signer, hereby certify that I served a true and correct copy of the foregoing document upon the following parties in the manner indicated:]
    v(body-leading)
    set par(leading: single-leading, spacing: 0pt)
    [#c.method:]
    v(single-leading)
    for (k, block-lines) in c.served.enumerate() {
      if k > 0 { v(body-leading) }
      for (i, line) in block-lines.enumerate() {
        if i > 0 { linebreak() }
        line
      }
    }
    v(body-leading)
    grid(
      columns: (3in, 1fr),
      [Date: #c.date],
      [By: /s/ #c.signer],
    )
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let adversary-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)

  // Headings: level 1 centered bold capitals; levels 2 and 3 bold, kept with the paragraph after them.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, weight: "bold", it.body))

  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", meta.title))
  v(body-leading)
  if "lead_in" in meta {
    block(width: 100%, below: body-leading, [#h(para-indent)#md(meta.lead_in)])
  }

  // Headings and WHEREFORE lead-ins (keep: true) are carried into the block of the piece after them, so
  // they never end a page. The last piece stays on the page with the signature block: a signature never
  // stands alone.
  let pieces = body-pieces(body, meta)
  let last = pieces.len() - 1
  let carry = []
  for (i, piece) in pieces.enumerate() {
    if i == last {
      block(breakable: false, width: 100%, {
        carry
        piece.content
        signature-block(meta)
      })
    } else if piece.keep {
      carry += piece.content
    } else {
      // Emitted as content, not wrapped in a block: a container drops the trailing spacing of its last child.
      carry += piece.content
      carry
      carry = []
    }
  }
  if pieces.len() == 0 { signature-block(meta) }
  if "certificate" in meta {
    certificate(meta)
  }
}
