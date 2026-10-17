// Complaint for the U.S. District Court for the Western District of North Carolina (ncwd).
// Rules: LCvR 7.1(d) (12 pt minimum, double-spaced, one-inch margins, numbered pages; a judge's standing
// order overrides these); Fed. R. Civ. P. 8(a), 10(a) (caption), 10(b) (numbered paragraphs), 11(a)
// (signer's address, e-mail and telephone). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LCvR 7.1(d): font size is the rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README)
#let type-size = 12pt                   // LCvR 7.1(d): a minimum of 12 point
#let margin = 1in                       // LCvR 7.1(d): one-inch margins
#let text-width = 8.5in - 2 * margin
#let pitch = 24pt                       // one double-spaced line: the block spacing unit (LCvR 7.1(d))
#let body-leading = 1.645em             // double spacing: twice the single line (13.8 pt), a 27.6 pt pitch at 12 pt, as the filed exemplar sets it (measured, README)
#let single-leading = 0.5em             // single spacing for caption, counsel, signature: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.0in               // party column of the caption
#let caption-mark = 0.3in               // ")" column between the parties and the title

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *et al.*, quotations, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item; each item is its own block so the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page numbers, centered in the bottom margin (LCvR 7.1(d): each page is numbered).
#let page-number() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = block(width: 100%, below: body-leading, {
  // Fed. R. Civ. P. 10(a): the court's name; the division line when the filing uses one.
  set par(leading: single-leading, spacing: 0pt)
  align(center)[
    #text(weight: "bold")[IN THE UNITED STATES DISTRICT COURT] \
    #text(weight: "bold")[FOR THE WESTERN DISTRICT OF NORTH CAROLINA]
    #if "division" in meta and meta.division != none [\ #text(weight: "bold", upper(meta.division))]
  ]
})

#let caption(meta) = block(width: 100%, breakable: false, grid(
  columns: (caption-left, caption-mark, 1fr),
  column-gutter: 0.1in,
  {
    // Each party: its lines, then its designation; "v." between the parties. Every row is one line.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.lines + (p.designation,)
    }
    line-stack(rows)
  },
  // A ")" for each row of the party column, as in the filed caption.
  {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.lines + (p.designation,)
    }
    line-stack(rows.map(_ => ")"))
  },
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    if "case_number" in meta and meta.case_number != "" {
      [Civil Action No. #meta.case_number]
    } else {
      [Civil Action No.: #h(1.5in)]
    }
    v(pitch)
    for line in meta.title [#text(weight: "bold", inl(line)) \ ]
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch)
      text(weight: "bold")[JURY TRIAL DEMANDED]
    }
  }),
))

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (Fed. R. Civ. P. 11(a)): date, then each firm's block with the signer's address,
/// e-mail and telephone. Set at the right half of the page.
#let signature-block(sig) = block(width: 100%, breakable: false, above: pitch, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  [Dated: #sig.date]
  v(pitch)
  pad(left: 2.75in, stack(dir: ttb, spacing: pitch,
    [Respectfully submitted,],
    ..sig.blocks.map(b => block(width: 100%, breakable: false, line-stack(
      // A signing firm has a "By: /s/" line for the signer, then its lines (the signer's own name is one of them);
      // co-counsel has the firm and its lines only.
      if "by" in b and b.by != none {
        (b.firm, "By: /s/ " + b.by) + b.lines
      } else {
        (b.firm,) + b.lines
      },
    ))),
  ))
})

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph. Numbering is applied per chunk, not with a show rule:
/// a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let numbered(t, n) = [#h(para-indent)#n.#h(0.3in)#inl(t)]

#let ncwd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  // Prayer items are lettered A., B., ... (as in the filed prayer); the list may break across pages.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section in caps; level 2 a centered bold heading (a claim's title);
  // level 3 a centered line (a claim's "(On Behalf of ...)" line). Each stays with the text after it.
  // Headings are set single-spaced (a two-line heading does not take the double pitch).
  show heading.where(level: 1): it => block(width: 100%, above: pitch, below: body-leading, sticky: true, {
    set par(leading: single-leading)
    align(center, text(weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: 100%, above: pitch, below: body-leading, sticky: true, {
    set par(leading: single-leading)
    align(center, text(weight: "bold", it.body))
  })
  show heading.where(level: 3): it => block(width: 100%, above: pitch, below: body-leading, sticky: true, {
    set par(leading: single-leading)
    align(center, it.body)
  })

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: each chunk is a heading, a list, or a numbered paragraph.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are spaced by body-leading; the trailing v() closes the list.
      {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with(">") {
      [#h(para-indent)#inl(t.slice(1).trim())]
    } else {
      n += 1
      numbered(t, n)
    }
    parbreak()
  }

  signature-block(meta.signature)
}
