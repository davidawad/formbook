// U.S. District Court, Southern District of California: motion (notice of motion and memorandum
// of points and authorities). Pleading paper as the complaint template (casd-complaint.typ):
// numbered lines 1 to 28, double rule at the text's left edge, footer below line 28.
//
// Rule-driven and content-agnostic. The rule text is S.D. Cal. Civil L.R. 5.1 (14-point proportional type,
// 28 numbered lines, letter size; secondary excerpt, see ../README.md) and Civil L.R. 7.1 (not verified).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown body
// is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/pleading-paper.typ": background as shared-pleading-background
#import "../../../../../../../lib/typst/tables.typ": leader-row, grid-outline-row as shared-grid-outline-row
#import "../../../../../../../lib/typst/typography.typ": footnote-style as shared-footnote-style
#import "../../../../../../../lib/typst/toa.typ": linked-authorities as shared-linked-authorities, cited-authorities as shared-cited-authorities, authority-page-labels as shared-authority-page-labels

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // CivLR 5.1: proportional font "such as Times New Roman"; EB Garamond is the vendored one (README.md, gap 2)
#let type-size = 14pt                    // CivLR 5.1: type no smaller than 14-point for proportional text
#let line-pitch = 24pt                   // CivLR 5.1: double spacing; the numbered lines are this pitch
#let lines-per-page = 27                 // CivLR 5.1: not more than 28 lines per page
#let page-w = 8.5in                      // CivLR 5.1: letter size
#let page-h = 11in
#let body-leading = 14.9pt               // leading that gives a 24 pt pitch at 14 pt EB Garamond (measured: natural line box 9.1 pt; README.md)
#let single-leading = 3.5pt              // counsel block, captions, tables of contents and authorities: about 12.6 pt pitch at 14 pt
#let top-margin = 72pt                   // numbered line 1 sits on the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * line-pitch   // 72 pt: holds the footer block placed below line 28
#let left-margin = 1.5in                 // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let margins = (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin)
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let footer-size = 10pt                  // footer: paper title and case number; not body text (README.md, gap 3)
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"

// Paragraph spacing equals the leading, so a paragraph of n lines is n × line-pitch tall and the next
// paragraph starts on the grid of numbered lines.
#let pleading-par = (leading: body-leading, spacing: body-leading)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("casd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("casd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// A block that fills whole numbered lines, so whatever follows it stays on the grid (as in casd-complaint.typ).
/// A paragraph ends body-leading short of its last grid row (its spacing is only between paragraphs), so the
/// block after it starts with body-leading of space.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / line-pitch) * line-pitch, above: body-leading, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Pleading paper (CivLR 5.1): numbered lines in the left margin, rules, footer below line 28
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line; the page background of every page.
#let pleading-background() = {
  shared-pleading-background(page-w, page-h, left-margin, right-margin, top-margin, line-pitch, lines-per-page, type-size,
    top-edge: "cap-height", bottom-edge: "baseline")
}

/// Footer below line 28: the page number (when `numbered`, in the page's own numbering style), the paper's
/// title and the case number.
#let footer-block(meta, numbered: true) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * line-pitch + 6pt,
  block(width: text-width, context {
    set text(size: footer-size)
    align(center)[
      #if numbered and here().page-numbering() != none {
        counter(page).display(here().page-numbering())
        v(4pt)
      }
      #upper(need(meta, "footer_title"))\
      No. #need(meta, "case_number")
    ]
  }),
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (CASD-RULE)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (Civil L.R. 7-4(a)(2))
// ---------------------------------------------------------------------------

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
  shared-grid-outline-row(hd.location(), if hd.level == 1 { upper(hd.body) } else { hd.body },
    if lab == "" { none } else { lab }, ind, heading-tab, pg, single-leading, 0.25em,
    above: 0.45em, page-gap: 0.4em, page-width: 2em)
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong[Page]))
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level <= 4 { toc-entry(hd) }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body (CASD-RULE).
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = shared-linked-authorities(authorities, error-prefix: "casd-motion-brief")
    let first = true
    for (kind, title) in toa-groups {
      let members = shared-cited-authorities(authorities, hits, kind, sort-key)
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        strong(title)
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let page-text = shared-authority-page-labels(hits, key, passim-threshold)
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, leader-row({
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            if a.cite != "" { [, ] }
          }
          inl(a.cite)
        }, page-text,
          hang: 0.35in, leading: single-leading, dot-gap: 0.25em, lead-gap: 0.8em, gutter: 0.3em, min-leader: 1em))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (Civil L.R. 3-4(a), 7-2(b)(1), 7-4(a)(1))
// ---------------------------------------------------------------------------

/// Counsel block, upper left (3-4(a)(1)). Single-spaced; the court title follows it. The rule puts
/// the title on line 8 "except where additional space is required for counsel identification" (3-4(a)(3)).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
  emph(inl(need(meta, "counsel_role")))
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let hearing = need(meta, "hearing")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(single-leading); align(center)[v.]; v(single-leading) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
    v(line-pitch * 0.5)
    strong(upper(inl(need(meta, "brief_title"))))
    v(line-pitch * 0.5)
    // Noticed hearing date and time, opposite the caption (7-2(b)(1), 7-4(a)(1)).
    for (k, lab) in (("date", "Date:"), ("time", "Time:"), ("place", "Place:"), ("judge", "")) {
      if k in hearing {
        if lab != "" { [#lab ] }
        inl(hearing.at(k))
        linebreak()
      }
    }
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 0.5em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = page(numbering: none, margin: margins, background: pleading-background(), foreground: footer-block(meta, numbered: false), {
  counsel-block(meta)
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(line-pitch * 0.5)
  caption-table(meta)
})

// ---------------------------------------------------------------------------
// Signature block (convention: no local rule cited for the form; see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(line-pitch)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let casd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "counsel", "counsel_role", "brief_title", "footer_title", "hearing", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")   // Civil L.R. 3-4(c)(1): 8 1/2 x 11 inch
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "cap-height", bottom-edge: "baseline",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  shared-footnote-style(type-size, single-leading, spacing: 0.4em,
    gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      on-grid(align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      on-grid(hang(ind + heading-tab, {
        h(ind)
        box(width: heading-tab, lab)
        strong(it.body)
      }))
    }
  }

  cover(meta)
  page(numbering: "i", footer: none, margin: margins, background: pleading-background(), foreground: footer-block(meta), {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: none, margin: margins, background: pleading-background(), foreground: footer-block(meta), {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
