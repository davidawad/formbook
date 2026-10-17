// Complaint for the U.S. District Court for the Eastern District of Tennessee (tned).
//
// Rule-driven and content-agnostic. Governing rules: E.D. Tenn. LR 5.1 (paper, type size, spacing,
// margins, page numbers) and LR 3.1 (civil cover sheet, a separate filing); Fed. R. Civ. P. 8(a),
// 10(a), 10(b). Rule text, verification dates and known gaps: ../README.md.
// Every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // LR 5.1 names no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR 5.1: no smaller than 12, footnotes included
#let body-leading = 1.345em             // LR 5.1: double-spaced. Line box 0.655em + leading 1.345em = 24 pt pitch at 12 pt (measured)
#let single-leading = 0.65em            // LR 5.1: quotations, headings, footnotes may be single-spaced; caption and signature block too
#let page-margin = 1in                  // LR 5.1: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.2in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tned-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced stack: one item per block, spaced by the single-spacing pitch (0.655em line box + 0.65em).
#let single-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
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
    single-stack(("Case No. " + meta.case_number,))
    v(body-leading)
    text(weight: "bold", inl(meta.title))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%, {
  let sig = meta.signature
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #sig.date],
    {
      single-stack(("Respectfully submitted,",))
      v(single-leading)
      // LR 5.1: the filing attorney's name, address, telephone number and BPR number. The BPR line is
      // taken from `bpr` when the filer has one (a pro hac vice filer's Tennessee counsel supplies it).
      let bpr = if "bpr" in sig and sig.bpr != none { (sig.bpr,) } else { () }
      single-stack(sig.firm + ("By: /s/ " + sig.signer, sig.signer) + bpr + sig.lines + (sig.role,))
    },
  )
})

/// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph; a paragraph beginning WHEREFORE is an unnumbered
/// prayer lead-in. Headings are sticky (a heading never ends a page). Lists are lettered (a), (b), ...
/// Numbering is applied per chunk, not with a `show par` rule (a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; the trailing v() closes the last item.
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with("WHEREFORE") {
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
    } else {
      para-counter.step()
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        [#h(para-indent)#context para-counter.display(). #h(0.25in)#inl(t)]
      })
    }
  }
}

#let tned-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: page-margin,
    // LR 5.1: page numbers consecutively at the bottom; no other text may appear in the bottom margin.
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 centered caps; level 2 centered bold; level 3 bold, left. Single-spaced, kept with what follows.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading,
    text(weight: "bold", it.body))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)

  signature-block(meta)
}
