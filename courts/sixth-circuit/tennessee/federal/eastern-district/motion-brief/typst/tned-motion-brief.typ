// Memorandum of law supporting a motion (Rule 12(b)(6) motion to dismiss) for the U.S. District Court
// for the Eastern District of Tennessee (tned).
//
// Rule-driven and content-agnostic. Governing rules: E.D. Tenn. LR 5.1 (paper, type size, spacing,
// margins, page numbers) and LR 7.1 (briefing; 25-page limit, LR 7.1(b)); Fed. R. Civ. P. 7(b)(1), 12(b)(6).
// Rule text, verification dates and known gaps: ../README.md.
// Every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1 names no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR 5.1: no smaller than 12, footnotes included
#let body-leading = 1.345em             // LR 5.1: double-spaced. Line box 0.655em + leading 1.345em = 24 pt pitch at 12 pt (measured)
#let single-leading = 0.65em            // LR 5.1: quotations, headings, footnotes may be single-spaced; caption and signature block too
#let page-margin = 1in                  // LR 5.1: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.2in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tned-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced stack: one item per block, spaced by the single-spacing pitch (0.655em line box + 0.65em).
#let single-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(inl))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = (
    text(weight: "bold", "UNITED STATES DISTRICT COURT"),
    text(weight: "bold", "EASTERN DISTRICT OF TENNESSEE"),
  )
  if "division" in meta and meta.division != none {
    lines.push(text(weight: "bold", upper(meta.division)))
  }
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading, ..lines))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  // Party column, closed on the right and bottom by rules (the caption convention; see README.md).
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.14in, bottom: 0.14in), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    single-stack(rows)
  }),
  block(inset: (left: 0.14in), {
    single-stack(("No. " + meta.case_number,))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  // The title of the paper sits under the caption, centered and bold.
  block(width: 100%, sticky: true, align(center, text(weight: "bold", upper(inl(meta.title)))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%, {
  let sig = meta.signature
  set par(leading: single-leading, first-line-indent: 0pt)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [],
    {
      single-stack(("Respectfully submitted,",))
      v(single-leading)
      single-stack(sig.firm + ("By: /s/ " + sig.by,))
      v(single-leading)
      for a in sig.attorneys {
        let head = if "bpr" in a and a.bpr != none { (a.name + ", " + a.bpr,) } else { (a.name,) }
        single-stack(head + a.lines)
        v(single-leading)
      }
      single-stack((sig.role,))
    },
  )
})

#let certificate-block(meta) = {
  let c = meta.certificate_of_service
  block(breakable: false, width: 100%, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading)
    block(width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      inl(c.text)
    })
    v(body-leading)
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [],
      {
        for r in c.recipients {
          single-stack(r)
          v(single-leading)
        }
        single-stack(("By: /s/ " + c.by, c.by))
      },
    )
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let tned-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    // LR 5.1: page numbers consecutively at the bottom; no other text may appear in the bottom margin.
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing is one body leading: a paragraph's last line box is shorter than its pitch, so the gap
  // between paragraphs must be added here, or lines of neighbouring paragraphs collide.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set footnote.entry(indent: 0pt)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)
  show footnote.entry: set text(size: type-size)

  // Headings: level 1 centered bold caps (I. INTRODUCTION); level 2 bold, left (A. ...); level 3 bold italic.
  // Single-spaced and sticky: a heading never ends a page.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    par(hanging-indent: 0.5in, first-line-indent: 0pt, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    par(first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body)))

  // Block quotations: indented both sides, single-spaced.
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in),
    above: body-leading, below: body-leading, {
      set par(leading: single-leading, first-line-indent: 0pt)
      it.body
    })

  cover(meta)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
  if "certificate_of_service" in meta and meta.certificate_of_service != none {
    v(body-leading * 2)
    certificate-block(meta)
  }
}
