// Complaint for the U.S. District Court for the Northern District of Mississippi (msnd).
// Rules: Fed. R. Civ. P. 8(a), 10(a)-(c) (caption, numbered paragraphs), 38 (jury demand),
// 5(d)(1)(B) (no certificate of service for e-filed papers); L.U.Civ.R. 11(a) (name, address, telephone,
// fax, e-mail and bar number on signed papers). L.U.Civ.R. 5(a)(1) (civil cover sheet) and 7(c) (corporate
// disclosure) are separate filings and are not produced here. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // proportional serif (vendored in fonts/); no local rule sets a complaint typeface
#let type-size = 12pt                   // the memorandum rule (L.U.Civ.R. 7(b)(5)(B)) is the court's only typeface rule; used here too
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (L.U.Civ.R. 7(b)(5)(A), applied for consistency)
#let page-h = 11in
#let margin = 1in                       // at least 1 inch on all four sides (L.U.Civ.R. 7(b)(5)(A))
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em gives 24 pt at 12 pt
#let pitch = 24pt                       // one double-spaced line (the baseline pitch of body text)
#let single-leading = 0.5em             // single spacing for the caption, the title, and the signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, designations, signature lines).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
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

/// Markdown inline text, with each "[^key]" mark replaced by a typst footnote of the definition.
/// A piece that starts with a space keeps it (the markdown renderer trims it), so the word after a mark is spaced.
#let text-piece(s) = {
  let lead = if s.starts-with(regex("\\s")) { " " } else { "" }
  lead + inl(s)
}
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

/// Content set on whole numbered lines: the block is measured, then rounded up to a multiple of `pitch`, so
/// whatever follows it stays on the grid of double-spaced lines. (Measuring is what keeps every line in place.)
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: kept with the text after it, so it never ends a page.
#let heading-block(c) = block(width: text-width, above: body-leading, below: body-leading, sticky: true, c)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the bottom margin (no rule requires a footer title).
#let page-number() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court (FRCP 10(a)), caption, title of the pleading
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
    if "jury_demand" in meta and meta.jury_demand {
      v(single-leading * 2)
      line-stack(("JURY TRIAL DEMANDED",))
    }
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

/// Numbering for the prayer list: "1." at the top level, "a." for a list nested in an item.
#let prayer-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 1 { numbering("1.", n.at(0)) } else { numbering("a.", n.at(n.len() - 1)) }
}

#let signature-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  block(width: text-width, breakable: false, above: body-leading, below: 0pt, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(body-leading)
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.counsel)
    },
  ))
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph, except a paragraph that starts with "WHEREFORE", which is
/// the unnumbered lead-in of the prayer. Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter, defs) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with(regex("^\\[\\^[^\\]]+\\]:")) {
      // A footnote definition: rendered where its mark is, by with-footnotes().
      continue
    } else if t.starts-with("#") {
      heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are spaced by body-leading; the trailing v() closes the last one.
      set enum(numbering: prayer-numbering, indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else if t.starts-with("WHEREFORE") {
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        with-footnotes(t, defs)
      })
    } else {
      // The number is part of the first line. The paragraph is set on whole numbered lines (on-grid), because
      // a paragraph in a loop, or in an auto-height block, loses the height of its later lines.
      para-counter.step()
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        context para-counter.display()
        [.#h(0.3in)]
        with-footnotes(t, defs)
      })
    }
  }
}

#let msnd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    footer: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  show footnote.entry: set text(size: 11pt)

  // Headings: level 1 is a centered caps section; level 2 a centered bold sub-heading.
  show heading.where(level: 1): it => heading-block(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(size: type-size, weight: "bold", it.body)))

  cover(meta)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
  }

  allegations(body, para-counter, footnote-defs(body))

  if "jury_demand_text" in meta {
    heading-block(align(center, text(weight: "bold", "JURY DEMAND")))
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.jury_demand_text)
  }

  signature-block(meta)
}
