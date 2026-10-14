// Memorandum in support of a motion for the U.S. District Court for the District of Idaho (idd).
// Rules: Dist. Idaho Loc. Civ. R. 7.1(a)(2) (memorandum at most 20 pages; no small fonts or minimal spacing to
// comply with the limit), 7.1(a)(3) (the motion's docket number in the caption), 7.1(b)(1) (a separate brief);
// Loc. Civ. R. 5.2 (8 1/2 x 11, double-spaced, 1-inch margins, 12-point type including footers and footnotes,
// numbered pages, counsel block, caption four inches down, CM/ECF file number). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // only vendored font (fonts/); see README.md, known gaps
#let type-size = 12pt                   // LR 5.2(a): at least 12 point, footnotes and footer included
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // LR 5.2(a): top, bottom and side margins at least one inch
#let pitch = 24pt                       // one double-spaced line at 12 pt (measured, README.md)
#let body-leading = 1.35em              // LR 5.2(a): double-spaced; 24 pt baseline pitch at 12 pt
#let single-leading = 0.5em             // counsel, caption, signature block, footnotes: single-spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-top = 4in                  // LR 5.2(b): caption commences four inches below the top of the first page
#let caption-left = 3.25in              // width of the party column of the caption
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("idd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Whole double-spaced line slots: the block is rounded up to a multiple of `pitch`, so whatever follows it starts
/// on the grid and never overlaps (a block sized to its text leaves the next line too close).
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// Single-spaced lines, one per item; the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  // An empty item is a line-high gap (between counsel groups, for example).
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i.trim() == "" { block(height: 1em) } else { inl(i) }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number and paper title, each page (LR 5.2(a): each page numbered consecutively).
#let footer-block(title) = context {
  set text(size: type-size)
  align(left, [#counter(page).display() - #upper(title)])
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title and caption (four inches down), title with the motion's docket number
// ---------------------------------------------------------------------------

#let counsel-block(meta) = line-stack(meta.counsel)

#let court-title(meta) = stack(dir: ttb, spacing: single-leading, ..meta.caption.court.map(l => align(center, text(weight: "bold", l))))

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    // LR 5.2(b)(3): the file number as it appears in CM/ECF.
    line-stack(("Case No. " + meta.case_number,))
    v(body-leading * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "motion_docket" in meta and meta.motion_docket != none {
      // LR 7.1(a)(3): a paper filed in support of a motion carries that motion's docket number in the caption.
      v(body-leading * 0.5)
      text(weight: "bold", "[" + meta.motion_docket + "]")
    }
  }),
)

#let cover(meta) = context {
  counsel-block(meta)
  // The caption starts four inches below the top of the page; counsel that needs more room pushes it down
  // (LR 5.2(b): "except where additional space is required for identification").
  let used = measure(width: text-width, counsel-block(meta)).height
  v(calc.max(caption-top - margin - used, 12pt))
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, above: body-leading, breakable: false, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (2.9in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(single-leading * 2)
      line-stack(meta.signature.firm)
      v(single-leading * 2)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// A level-1 heading: a centered bold caps line on the grid, with a weak space above.
#let heading-block(c) = {
  v(body-leading * 0.5, weak: true)
  on-grid(align(center, text(weight: "bold", upper(c))))
}

/// Certificate of service: its own page (convention; LR 5.2 is silent), signed by the filer.
#let certificate-block(meta) = {
  pagebreak(weak: true)
  heading-block[CERTIFICATE OF SERVICE]
  par(leading: body-leading, first-line-indent: 0pt, h(para-indent) + meta.certificate.text)
  block(width: text-width, above: body-leading, breakable: false, grid(
    columns: (2.9in, 1fr),
    column-gutter: 0.2in,
    [],
    line-stack(("/s/ " + meta.certificate.signer,) + meta.certificate.lines),
  ))
}

/// Markdown to content, with its `[^n]` references turned into typst footnotes (cmarker has no footnotes; the
/// definitions are `[^n]: text` chunks, collected by `body-text`).
#let with-notes(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    let key = m.captures.at(0)
    assert(key in notes, message: "idd-motion-brief: footnote [^" + key + "] has no definition in the sample")
    out += cmarker.render(t.slice(pos, m.start), raw-typst: false, smart-punctuation: true, h1-level: 1)
    out += footnote(cmarker.render(notes.at(key), raw-typst: false, smart-punctuation: true, h1-level: 1))
    pos = m.end
  }
  out + cmarker.render(t.slice(pos), raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// The items of a markdown bullet list; a line without a bullet continues the item before it.
#let bullet-items(t) = {
  let items = ()
  for line in t.split("\n") {
    let l = line.trim()
    if l.starts-with(regex("^[-*+][ \t]")) {
      items.push(l.slice(2).trim())
    } else if l != "" and items.len() > 0 {
      items.at(items.len() - 1) = items.at(items.len() - 1) + " " + l
    }
  }
  items
}

/// Body paragraphs are not numbered (a memorandum, not a pleading). Each blank-line-separated chunk of markdown is
/// one paragraph unless it is a heading, a list or a footnote definition. Chunks are not wrapped in a `show par`
/// rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions, keyed by their number; they are placed where their reference is.
  let notes = (:)
  for c in chunks {
    let m = c.trim().match(regex("^\\[\\^(\\d+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  for c in chunks {
    let t = c.trim()
    if t.match(regex("^\\[\\^(\\d+)\\]:")) != none {
      continue
    } else if t.starts-with("#") {
      // Headings are sticky through their show rules: they move to the next page with the chunk after them.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^[-*+][ \t]")) {
      // A bulleted list may break across pages; each item is spaced by body-leading.
      set par(leading: body-leading)
      list(..bullet-items(t).map(i => with-notes(i, notes)))
      v(body-leading * 0.5)
    } else if t == "\\* \\* \\*" {
      // A section break is centered on its own line.
      on-grid(align(center, [\* \* \*]))
    } else {
      // A paragraph flows like any text (it may break across pages). The indent is inline, because typst does not
      // indent the first paragraph after a block (a list, the caption), and every paragraph here is indented.
      par(leading: body-leading, first-line-indent: 0pt, {
        h(para-indent)
        with-notes(t, notes)
      })
      v(body-leading * 0.5)
    }
  }
}

#let idd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading * 0.5)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading * 0.5, marker: [•])
  // Footnotes: 12 point, single-spaced (LR 5.2(a) allows single spacing in footnotes).
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt), gap: 0.4em)
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 an argument heading, bold, left.
  // Each heading fills whole double-spaced slots, so the paragraph after it starts on the grid.
  show heading.where(level: 1): it => heading-block(it.body)
  show heading.where(level: 2): it => {
    v(body-leading * 0.25, weak: true)
    on-grid(align(center, text(weight: "bold", it.body)))
  }
  show heading.where(level: 3): it => {
    v(body-leading * 0.25, weak: true)
    on-grid(par(leading: body-leading, first-line-indent: 0pt, hanging-indent: 0.5in, text(weight: "bold", it.body)))
  }

  cover(meta)

  body-text(body)

  signature-block(meta)

  if "certificate" in meta and meta.certificate != none {
    certificate-block(meta)
  }
}
