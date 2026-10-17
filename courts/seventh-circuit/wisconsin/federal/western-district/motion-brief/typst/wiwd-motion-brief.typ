// Brief in support of a motion to dismiss for the U.S. District Court for the Western District of Wisconsin (wiwd).
// Rules: Fed. R. Civ. P. 7(b)(1) (a request for a court order is made by motion, stated with particularity),
// 12(b)(1) and 12(b)(6) (the grounds for dismissal), 5(b)(2)(E) and 5(d)(1)(B) (service by the court's
// electronic system needs no separate certificate of service); W.D. Wis. LR 5.1 (electronic filing) and the
// court's Briefing Guidelines (12(b)(6) motions: matters outside the pleadings need leave). The W.D. Wis. form
// rules (font, spacing, margins) are not in the court's posted local rules; see ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Schola"        // Schola matches the audited exemplar (docs/FONTS.md); see README.md, open question 1
#let type-size = 12pt                   // convention, matching the filed exemplar's body size; no W.D. Wis. rule verified
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; the exemplar is letter size)
#let page-h = 11in
#let margin = 1in                       // convention; the exemplar's text block is about 1 inch in from each edge
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em leading gives about 24 pt at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, the title, the block quotes and the signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.2in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wiwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item: each item is a block, and the stack keeps the single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let footer-block() = context align(center, text(size: 11pt, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = align(center, line-stack((
  "**IN THE UNITED STATES DISTRICT COURT**",
  "**FOR THE WESTERN DISTRICT OF WISCONSIN**",
)))

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
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
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + meta.case_number,))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(single-leading * 2)
  caption(meta)
  v(single-leading * 2)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  // The signature block sits in the right half of the page, the usual place for it in a brief.
  pad(left: 2.75in, block(width: 3.5in, {
    line-stack(meta.signature.preamble)
    v(body-leading)
    line-stack(("/s/ " + meta.signature.signer,) + (meta.signature.signer,) + meta.signature.lines)
  }))
})

/// Brief body. Each blank-line-separated chunk of markdown is one paragraph (indented, unnumbered: a brief is
/// not a numbered pleading), a list, or a heading. A heading is kept in one unbreakable block with the chunk
/// after it, so it never ends a page.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // Lettered items (a., b., ...) from the sample's numbered markdown list; a list may break across pages.
        {
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading)
        }
      } else {
        // A paragraph breaks across pages like any text.
        {
          set par(leading: body-leading)
          h(para-indent)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let wiwd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Block spacing equals the double-spacing leading (see main.typ and README.md): with zero spacing the
  // blocks overlap, because Liberation Serif's line box is 0.655em.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section (CONCLUSION); level 2 a bold argument heading at the left margin;
  // level 3 a bold italic sub-heading.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  brief-body(body)

  signature-block(meta)
}
