// Memorandum brief in support of a motion (the "motion-brief" doc type) for the U.S. District Court for the
// Northern District of Mississippi (msnd). Rules: L.U.Civ.R. 7(b)(2) (the memorandum is a separate docket item),
// 7(b)(5)(A) (8 1/2 by 11 paper, double-spaced text, margins of at least 1 inch, page numbers only in the margins),
// 7(b)(5)(B) (proportional serif face; text 12-point or larger; footnotes 11-point or larger), 7(b)(5)(C) (plain roman
// type; case names italicized or underlined); L.U.Civ.R. 11(a) (signed papers carry counsel's name, address,
// telephone, fax, e-mail and bar number); Fed. R. Civ. P. 10(a) (caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // L.U.Civ.R. 7(b)(5)(B): a proportionally spaced face with serifs (vendored in fonts/)
#let type-size = 12pt                   // L.U.Civ.R. 7(b)(5)(B): text 12-point or larger
#let footnote-size = 11pt               // L.U.Civ.R. 7(b)(5)(B): footnotes 11-point or larger
#let page-w = 8.5in                     // L.U.Civ.R. 7(b)(5)(A): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // L.U.Civ.R. 7(b)(5)(A): at least 1 inch on all four sides
#let text-width = page-w - 2 * margin
#let pitch = 24pt                       // one double-spaced line (the baseline pitch of body text)
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em gives 24 pt at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, the signature block and footnotes
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, designations, signature lines, footnote text).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Content set on whole double-spaced lines: the block is measured, then rounded up to a multiple of `pitch`,
/// so whatever follows it stays on the grid. Measuring keeps every line in place (a plain block around
/// multi-line paragraphs loses the height of its later lines).
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil((h - 6pt) / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// Footnote definitions in the body ("[^key]: text" in its own chunk), keyed by the key.
#let footnote-defs(body) = {
  let defs = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// A markdown piece in running text. A piece that starts with a space keeps it (the markdown renderer
/// trims it), so the word after a footnote mark is spaced.
#let text-piece(s) = {
  let lead = if s.starts-with(regex("\\s")) { " " } else { "" }
  lead + inl(s)
}

/// Markdown inline text, with each "[^key]" mark replaced by a typst footnote of the definition.
#let with-footnotes(t, defs) = {
  let refs = t.matches(regex("\\[\\^([^\\]]+)\\]"))
  if refs.len() == 0 { return inl(t) }
  let out = []
  let pos = 0
  for r in refs {
    out += text-piece(t.slice(pos, r.start))
    out += footnote(inl(defs.at(r.captures.at(0))))
    pos = r.end
  }
  out + text-piece(t.slice(pos))
}

/// A heading: kept with the text after it, so it never ends a page.
#let heading-block(c) = block(width: text-width, above: body-leading, below: 0pt, sticky: true, on-grid(c))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the bottom margin (L.U.Civ.R. 7(b)(5)(A) allows numbers in the margins only).
#let page-number() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court (FRCP 10(a)), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center)[
    #text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT") \
    #text(weight: "bold", "FOR THE NORTHERN DISTRICT OF MISSISSIPPI") \
    #if "division" in meta and meta.division != none {
      text(weight: "bold", upper(meta.division) + " DIVISION")
    }
  ]
  v(body-leading)
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.2in), {
    line-stack(("CIVIL ACTION NO.:", meta.case_number))
  }),
)

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  v(body-leading)
  align(center, block(width: text-width, text(weight: "bold", inl(meta.title))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Body text: each blank-line-separated chunk that is neither a heading, a list nor a footnote definition is
/// one paragraph, with a first-line indent. Briefs are not numbered.
/// Numbering-free paragraphs are set with on-grid (see its comment): a paragraph in a loop, set on its own,
/// is not measured correctly otherwise.
#let body-text(body, defs) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with(regex("^\\[\\^[^\\]]+\\]:")) {
      // A footnote definition: rendered where its mark is, by with-footnotes().
      continue
    } else if t.starts-with("#") {
      heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(">") {
      // A block quotation: indented on both sides (L.U.Civ.R. 7(b)(5)(A) lets it be single-spaced; it is kept double).
      pad(left: 0.5in, right: 0.5in, on-grid({
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; the trailing v() closes the last item.
      set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else {
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        with-footnotes(t, defs)
      })
    }
  }
}

#let signature-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  block(width: text-width, breakable: false, above: body-leading, below: 0pt, {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      meta.date_line
    })
    pad(left: 3in, line-stack(("Respectfully submitted,",)))
    v(body-leading)
    pad(left: 3in, line-stack((meta.signature.party, meta.signature.signer) + meta.signature.counsel))
    v(body-leading)
    line-stack(meta.signature.of_counsel)
  })
}

#let msnd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    footer: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  show footnote.entry: set text(size: footnote-size)

  // Headings: level 1 is a centered caps section; level 2 an argument heading, bold; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  body-text(body, footnote-defs(body))

  signature-block(meta)
}
