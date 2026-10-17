// Memorandum in support of a motion for the U.S. District Court for the Northern District of Illinois (ilnd).
// Rules: N.D. Ill. LR 5.2(e) (8 1/2 x 11 paper; line spacing at least 2.0 lines; 12-point body type;
// footnotes at least 11 points; margins at least 1 inch on all four sides); LR 7.1 (a brief in support of a
// motion is capped at 15 pages without prior approval; a longer brief needs a table of contents and a table of
// cases, which this template does not generate: see ../README.md); Fed. R. Civ. P. 7(b), 11(a), 12(b).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no font is mandated by LR 5.2(e); Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (see README.md)
#let type-size = 12pt                   // LR 5.2(e)(1): 12-point type in the body of the text
#let note-size = 11pt                   // LR 5.2(e)(1): footnotes no less than 11 points
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

#let single-leading = 0.5em             // single spacing (13.8 pt pitch): caption, counsel, signature, footnotes, quotations
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-paren = 0.3in              // the column of ")" marks between the parties and the case number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (one chunk: a paragraph, a list, a quotation or a heading).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading is set single-spaced inside its own block, with one double-spaced line of space above and below.
/// Typst puts leading between lines but not after the last one, so the space below keeps the next line clear.
#let heading-line(c, align-to: left) = block(width: text-width, sticky: true, above: body-leading, below: body-leading, {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  set text(hyphenate: false)
  align(align-to, c)
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered in the bottom margin. The cover page has none (set on the cover page in `ilnd-motion-brief`).
#let footer-block() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, counsel (the cover page carries no page number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE NORTHERN DISTRICT OF ILLINOIS],
    ..if "division" in meta { (upper(meta.division),) } else { () },
  )))
}

/// Each party's names, a blank line and its designation, then "v." between the parties; each row ends in ")".
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      rows.push(("", ""))
      rows.push((h(1.0in) + [v.], ""))
      rows.push(("", ""))
    }
    for n in p.names { rows.push((inl(n), "")) }
    rows.push(("", ""))
    rows.push((h(0.5in) + inl(p.designation), ""))
  }
  let left = rows.map(r => r.at(0))
  let parens = rows.map(r => [)])
  let left-column = grid(
    columns: (caption-left, caption-paren),
    row-gutter: single-leading,
    ..left.zip(parens).flatten(),
  )
  grid(
    columns: (caption-left + caption-paren, 1fr),
    column-gutter: 0.3in,
    left-column,
    align(horizon, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Case No. #meta.case_number]
      if "judge" in meta and meta.judge != none {
        v(single-leading)
        [Honorable #meta.judge]
      }
    }),
  )
}

#let title-block(meta) = {
  v(body-leading * 2)
  align(center, stack(dir: ttb, spacing: single-leading, ..meta.brief_title.map(l => text(weight: "bold", l))))
  v(body-leading * 2)
}

/// Counsel block at the lower right of the cover (single-spaced; one group per counsel).
#let right-column(c) = grid(columns: (text-width - 3.2in, 3.2in), [], c)

#let counsel-block(meta) = right-column(block(width: 3.2in, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  for (k, g) in meta.counsel.enumerate() {
    if k > 0 { v(single-leading * 2) }
    line-stack(g)
  }
}))

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  title-block(meta)
  v(1fr)
  counsel-block(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
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
      line-stack(meta.signature.party)
      v(single-leading * 2)
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.role)
    },
  )
})

/// The body. Each blank-line-separated chunk is a heading, a list, a quotation or a paragraph. Paragraphs are
/// not numbered (a brief's text is not a pleading's allegations). Headings are sticky: never at a page's end.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions are chunks of their own. cmarker resolves a reference only against definitions in the
  // same source, so every chunk that refers to a note is rendered with all the definitions appended.
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let pieces = ()
  for c in chunks.filter(c => not c.trim().starts-with("[^")) {
    let t = c.trim()
    let s = if t.contains("[^") { t + "\n\n" + defs } else { t }
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let text-body = md(s)
      if level == 1 {
        pieces.push((kind: "h", body: heading-line(align(center, text(weight: "bold", upper(text-body))))))
      } else if level == 2 {
        pieces.push((kind: "h", body: heading-line(text(weight: "bold", text-body))))
      } else {
        pieces.push((kind: "h", body: heading-line(pad(left: 0.5in, text(weight: "bold", text-body)))))
      }
    } else if t.starts-with(">") {
      pieces.push((kind: "q", body: block(width: text-width, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading, spacing: 0pt, justify: true)
        md(t.replace(regex("^>\\s?"), ""))
      })))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pieces.push((kind: "l", body: block(width: text-width, {
        set par(leading: body-leading, justify: true)
        md(s)
      })))
    } else {
      pieces.push((kind: "p", body: block(width: text-width, {
        set par(leading: body-leading, justify: true, first-line-indent: 0pt)
        h(para-indent)
        md(s)
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

/// The certificate of service (Fed. R. Civ. P. 5(b)): its own page, double-spaced text, signed by counsel.
#let certificate(meta) = if "certificate" in meta {
  pagebreak()
  heading-line(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  set par(leading: body-leading, justify: true, first-line-indent: para-indent)
  inl(meta.certificate.text)
  parbreak()
  block(breakable: false, width: text-width, {
    v(body-leading)
    right-column(block(width: 3.2in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(("/s/ " + meta.certificate.signer,) + meta.certificate.role)
    }))
  })
}

#let ilnd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right),
    footer: none,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: true)
  set block(spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  // Footnotes: at least 11 points, single-spaced (LR 5.2(e)(1)).
  show footnote.entry: set text(size: note-size)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show quote: set text(size: type-size)

  cover(meta)

  // Body pages are numbered from 1 (the cover is not counted, as in the filed exemplar).
  set page(footer: footer-block())
  counter(page).update(1)

  let (main, tail) = body-chunks(body)
  main
  block(breakable: false, width: text-width, {
    tail
    signature-block(meta)
  })
  certificate(meta)
}
