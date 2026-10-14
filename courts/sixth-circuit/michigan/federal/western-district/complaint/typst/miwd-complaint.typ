// Complaint for the U.S. District Court for the Western District of Michigan (miwd).
// Rules: LCivR 10.1 (double spaced, 8 1/2 x 11, one side, type 12 point or larger, margins at least 1 inch);
// LCivR 10.3 (date, address and telephone of the signing attorney); Fed. R. Civ. P. 10(a) (caption),
// 10(b) (numbered paragraphs), 11(a) (signature with address, e-mail and telephone). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only font typst can see (tools/render.sh)
#let type-size = 12pt                   // LCivR 10.1: type no smaller than 12 point
#let pitch = 24pt                       // LCivR 10.1: double spaced; a 24 pt baseline pitch at 12 pt
#let page-w = 8.5in                     // LCivR 10.1: 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LCivR 10.1: all margins at least one inch
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so this gives a 24 pt pitch (README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption and signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-gap = 0.3in                 // gap between a paragraph number and its text
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines; each item is one line of text (markdown inline).
#let single(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, counsel block (LCivR 10.1; Fed. R. Civ. P. 10(a), 11(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "UNITED STATES DISTRICT COURT"),
    text(weight: "bold", "WESTERN DISTRICT OF MICHIGAN"),
    if "division" in meta and meta.division != none { text(weight: "bold", upper(meta.division)) },
  ))
}

#let caption(meta) = {
  let cn = if meta.case_number == "" { "__________________" } else { meta.case_number }
  let hon = if meta.judge == "" { "__________________" } else { meta.judge }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      // Each party: its names, then its designation; "v." between the parties.
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      single(rows)
    }),
    block(inset: (left: 0.1in), {
      single(("Case No. " + cn, "Hon. " + hon))
      v(pitch)
      text(weight: "bold", inl(meta.title))
    }),
  )
}

#let counsel-block(meta) = block(breakable: false, width: text-width, {
  for (k, g) in meta.counsel.enumerate() {
    if k > 0 { v(single-leading) }
    single(g.names + g.lines)
  }
})

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch * 2)
  counsel-block(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(pitch * 0.5)
      single(meta.signature.firm)
      v(pitch * 0.5)
      single(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph. Numbering stops at the heading named by the frontmatter
/// field `numbering_stops_at` (the request for relief and the jury demand are not numbered).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, stop-at, para-counter, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbering-on = true
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  // The last chunk is kept with the signature block, so a signature never stands alone on a page.
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let title = t.replace(regex("^#+\\s*"), "").trim()
      if stop-at != none and title == stop-at { numbering-on = false }
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // Lists (request for relief items) are lettered A., B., ... by the enum setting; a list may break across pages.
        {
          set par(leading: body-leading)
          // Items are separated by the paragraph spacing alone; block spacing would add a second gap.
          // Weak spacing before and after a list collapses with the neighbouring spacing: one double-spaced line.
          set block(spacing: 0pt)
          v(body-leading, weak: true)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading, weak: true)
        }
      } else {
        // A paragraph breaks across pages like any text; numbered unless the section is unnumbered.
        {
          set par(leading: body-leading)
          if numbering-on {
            para-counter.step()
            context [#h(para-indent)#(para-counter.display()).#h(number-gap)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
          } else {
            [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
          }
        }
      }
      let keep-tail = last and tail != none
      if has-pending or keep-tail {
        block(breakable: false, width: text-width, {
          pending
          piece
          if keep-tail { tail }
        })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let miwd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    // Page numbers centered at the foot of every page after the cover (LCivR 10.1 sets no footer; convention).
    footer: context {
      if counter(page).get().first() > 1 { align(center, text(size: type-size, counter(page).display())) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: 0pt)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 a centered line.
  show heading.where(level: 1): it => block(width: text-width, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, sticky: true, above: 0pt, below: body-leading,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, sticky: true, above: 0pt, below: body-leading,
    align(center, text(it.body)))

  cover(meta)

  // Page 2 opens with the title of the pleading, centered, then the lead-in paragraph.
  align(center, text(weight: "bold", inl(meta.title)))
  v(body-leading)
  if "lead_in" in meta {
    block(width: text-width, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, meta.at("numbering_stops_at", default: none), para-counter, {
    v(body-leading)
    signature-block(meta)
  })
}
