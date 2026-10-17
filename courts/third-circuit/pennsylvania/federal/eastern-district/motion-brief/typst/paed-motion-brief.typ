// Motion with memorandum of law for the U.S. District Court for the Eastern District of Pennsylvania (paed).
// Rules: Fed. R. Civ. P. 7(b) (a motion states the grounds and relief with particularity) and 12(b); E.D. Pa.
// Local Civil Rule 7.1(a) (a proposed form of order accompanies every motion), 7.1(c) (a brief with a concise
// statement of the legal contentions and authorities), 7.1(d) (a written statement of the date and manner of
// service); Local Civil Rule 5.1.2(7)(b) (a certificate of service on every ECF document). The local rules set no
// typeface, margin, spacing, or table rule; the choices below follow the filed exemplar. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; the exemplar is Times New Roman (see README.md)
#let type-size = 12pt                   // convention; the local rules set no type size
#let body-leading = 1.345em             // double spacing: 24 pt baseline pitch at 12 pt (measured, README.md)
#let pitch = 24pt                       // one double-spaced line; blocks are whole numbers of these
#let single-leading = 0.5em             // counsel, caption, signature and block quotations are single-spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margin = 1in                       // convention; the local rules set no margin
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.3in               // party column
#let caption-colon = 0.35in             // column of ":" marks between the parties and the action number
#let caption-right = text-width - caption-left - caption-colon

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("paed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so the text after it stays on the
/// same rhythm and blocks cannot overlap (measured; a block without a fixed height lays out unreliably here).
#let on-grid(c, sticky: false, breakable: true) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, breakable: breakable, c)
}

/// Split the body into its named sections: "<!-- name -->" starts a section that runs to the next marker.
#let sections(body) = {
  let out = (:)
  for piece in ("\n" + body).split("\n<!-- ") {
    let i = piece.position(" -->")
    if i != none {
      out.insert(piece.slice(0, i), piece.slice(i + 4))
    }
  }
  out
}

/// Blank-line-separated chunks of a section's markdown.
#let chunks(md) = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

// ---------------------------------------------------------------------------
// Headings: I. (level 1), A. (level 2), 1. (level 3), a. (level 4)
// ---------------------------------------------------------------------------

#let heading-num(..nums) = {
  let v = nums.pos()
  let k = v.last()
  if v.len() == 1 { numbering("I.", k) }
  else if v.len() == 2 { numbering("A.", k) }
  else if v.len() == 3 { numbering("1.", k) }
  else { numbering("a.", k) }
}

#let hd-label(it) = if it.numbering == none { "" } else {
  numbering(it.numbering, ..counter(heading).at(it.location()))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.court_lines {
    align(center, text(weight: "bold", line))
    linebreak()
  }
}

/// The caption: party names on the left, a column of ":" marks, and the action number on the right. The ":" column
/// has one mark per single-spaced line of the party column.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let count = rows.len()
  let number = if meta.case_number == "" { box(line(length: 1.4in, stroke: 0.5pt)) } else { meta.case_number }
  grid(
    columns: (caption-left, caption-colon, caption-right),
    line-stack(rows),
    line-stack(range(count).map(_ => ":")),
    align(horizon, block(inset: (left: 0.15in), stack(dir: ttb, spacing: single-leading, [CIVIL ACTION], [No. #number]))),
  )
}

#let cover(meta, title) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", inl(title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body blocks
// ---------------------------------------------------------------------------

/// Signature block: the date on the left, "Respectfully submitted," and each counsel block on the right.
#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Date: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      [Respectfully submitted,]
      v(body-leading * 0.5)
      for (k, b) in meta.signature.blocks.enumerate() {
        if k > 0 { v(body-leading * 0.5) }
        line-stack(b.firm)
        v(body-leading * 0.5)
        line-stack(("By: /s/ " + b.signer,) + b.lines)
      }
    },
  )
})

/// The proposed order's signature: the court's block (the words are the court's form, not the case's).
#let order-signature() = block(breakable: false, width: text-width, {
  v(body-leading * 2)
  align(right, block(width: 2.8in, {
    set par(leading: single-leading, spacing: 0pt)
    [BY THE COURT:]
    v(body-leading * 1.5)
    line(length: 2.6in, stroke: 0.5pt)
    [J.]
  }))
})

/// One markdown section, rendered as a run of blocks. A paragraph is first-line indented and double-spaced; a
/// heading is kept with the block after it; a list is lettered or numbered as the section sets it; a block
/// quotation is single-spaced and indented from both margins.
#let render-section(md) = {
  for c in chunks(md) {
    let t = c.trim()
    if t.starts-with("#") {
      on-grid(sticky: true, {
        show heading.where(level: 1): it => align(center, text(weight: "bold", upper[#hd-label(it) #it.body]))
        show heading.where(level: 2): it => grid(columns: (0.5in, 1fr), hd-label(it), text(weight: "bold", it.body))
        show heading.where(level: 3): it => grid(columns: (0.5in, 1fr), hd-label(it), text(weight: "bold", style: "italic", it.body))
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are spaced by body-leading.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading * 0.5)
    } else if t.starts-with(">") {
      on-grid(breakable: false, {
        set par(leading: single-leading)
        pad(left: 0.5in, right: 0.5in, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      })
      v(body-leading * 0.5)
    } else {
      on-grid(breakable: false, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// The filing: order, motion with certificate, memorandum
// ---------------------------------------------------------------------------

#let certificate(meta) = {
  on-grid(sticky: true, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  on-grid(breakable: false, {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.service.text)
  })
  block(breakable: false, width: text-width, {
    v(body-leading)
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [Date: #meta.service.date],
      line-stack(("/s/ " + meta.service.signer,) + meta.service.lines),
    )
  })
}

#let paed-motion-brief(meta, body) = {
  let parts = sections(body)
  for name in ("order", "motion", "memorandum") {
    if name not in parts { panic("paed-motion-brief: the sample needs a <!-- " + name + " --> section") }
  }

  set page(paper: "us-letter", margin: margin)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // 1. Proposed order (Local Civil Rule 7.1(a)); no page number.
  page(numbering: none)[
    #cover(meta, meta.order_title)
    #render-section(parts.at("order"))
    #order-signature()
  ]

  // 2. Motion and its certificate of service (Local Civil Rules 5.1.2(7)(b), 7.1(d)); arabic page numbers.
  page(numbering: "1")[
    #counter(page).update(1)
    #cover(meta, meta.motion_title)
    #render-section(parts.at("motion"))
    #signature-block(meta)
    #v(body-leading * 2)
    #certificate(meta)
  ]

  // 3. Memorandum of law (Local Civil Rule 7.1(c)): caption and title; then the table of contents (roman
  //    numbers); then the body (arabic numbers from 1).
  page(numbering: none)[
    #cover(meta, meta.memo_title)
  ]

  page(numbering: "i")[
    #counter(page).update(1)
    #align(center, text(weight: "bold", "TABLE OF CONTENTS"))
    #v(body-leading)
    #outline(title: none, depth: 3, indent: 0.5in)
  ]

  page(numbering: "1")[
    #counter(page).update(1)
    #set heading(numbering: heading-num)
    #render-section(parts.at("memorandum"))
    #signature-block(meta)
  ]
}
