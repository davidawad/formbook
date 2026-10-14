// Complaint for the U.S. District Court for the District of Oregon (ord).
// Rules: LR 10-1 (double spacing, 12-point minimum for all typewritten material including footers, one-inch margins,
// no page numbers down the left margin, footer with a description and consecutive page numbers); LR 10-2 (counsel
// information upper left, court title centered, party names, case number at the center of the page, title);
// Fed. R. Civ. P. 8 and 10(a)-(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/ (the only serif face vendored; no rule names a face)
#let type-size = 13pt                   // LR 10-1(c) floor is 12 pt; 13 pt because EB Garamond's x-height is smaller than Times 12 pt (README)
#let footer-size = 12pt                 // LR 10-1(c): the footer is typewritten material, so it is 12 pt too
#let pitch = 24pt                       // LR 10-1(b): double spacing; 27 lines fill the 9-inch text height exactly
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (LR 10-1(f)(1))
#let page-h = 11in
#let margin = 1in                       // LR 10-1(d): one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 15.55pt             // 24 pt baseline pitch at 13 pt: EB Garamond's line box is 0.65 em (README, measured)
#let single-leading = 0.35em            // single spacing for counsel, caption and signature (about 1.0 em per line)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-split = text-width / 2     // LR 10-2(f): the case number starts at the center of the page
#let caption-gap = 0.3in                // space between the party column and the center line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ord-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so whatever follows it
/// stays on the grid of double-spaced lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// One single-spaced line per item; blank items keep their line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i.trim() == "" { v(type-size * 0.65) } else { inl(i) }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LR 10-1(e)(1): a footer on every page with a brief description of the document and the page number.
#let footer-block(title) = context {
  set text(size: footer-size)
  align(left, [#upper(title) - #counter(page).display()])
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left, LR 10-2(a)), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = context {
  // LR 10-2(b): the court title is centered at least one inch below the counsel information.
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.ceil((h + 1in) / pitch) * pitch, above: 0pt, below: 0pt,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", upper(meta.court.at(0)))))
  for line in meta.court.slice(1) {
    on-grid(align(center, text(weight: "bold", upper(line))))
  }
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-split, 1fr),
  column-gutter: 0pt,
  block(width: caption-split - caption-gap, {
    // Each party: its names, then its designation; "vs." between the parties (LR 10-2(d)).
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("vs.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(width: 100%, {
    set par(leading: single-leading, spacing: 0pt)
    // LR 10-2(f): the case number, on the first line of the caption (the clerk assigns it for a complaint).
    let number = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "________________" }
    line-stack(("Case No. " + number,))
    // LR 10-2(g): the document title is at least two lines below the case number, single-spaced, capitalized.
    v(pitch)
    text(weight: "bold", inl(upper(meta.brief_title)))
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch * 0.5)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.9in, 1fr),
  column-gutter: 0.2in,
  [DATED: #meta.date],
  {
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
  },
))

/// Lettered sub-items: each "- " line of a markdown list is one item, lettered (a), (b), ... (LR 10-1 has no list rule;
/// the letters keep the prayer and the sub-allegations citable).
#let lettered(t) = {
  let items = t.split(regex("\\r?\\n")).filter(l => l.trim().starts-with(regex("^[-*+][ \\t]"))).map(l => l.trim().replace(regex("^[-*+][ \\t]+"), ""))
  for (i, it) in items.enumerate() {
    let letter = "(" + str.from-unicode(96 + i + 1) + ")"
    on-grid(grid(columns: (0.9in, 1fr), [#h(0.5in)#letter], inl(it)))
  }
}

/// Numbered allegations. Each blank-line-separated chunk of markdown is one of: a heading (kept with the chunk
/// after it), a lettered list, a table (unnumbered), or a paragraph (numbered, Fed. R. Civ. P. 10(b)).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for (k, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      pending += on-grid(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^[-*+][ \\t]")) {
        // A list may break across pages; a heading in front of it is kept with its first item.
        { set par(leading: body-leading); lettered(t) }
      } else if t.starts-with("|") {
        // A table is reproduced as written, unnumbered.
        on-grid({ set par(leading: single-leading); cmarker.render(t, raw-typst: false, smart-punctuation: true) })
      } else {
        // A paragraph breaks across pages like any text; a heading in front of it is kept with its first line.
        para-counter.step()
        on-grid({
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      }
      // The last chunk stays on one page with the signature block, so a signature is never left alone.
      let content = if k == chunks.len() - 1 { block(breakable: false, width: text-width, { piece; tail }) } else { piece }
      if has-pending {
        block(breakable: false, width: text-width, { pending; content })
      } else {
        content
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let ord-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title),
    footer-descent: 0.5in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold centered sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => align(center, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => align(center, text(weight: "bold", it.body))
  show heading.where(level: 3): it => text(weight: "bold", style: "italic", it.body)

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter, {
    v(pitch)
    signature-block(meta)
  })
}
