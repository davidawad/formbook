// U.S. District Court, District of New Jersey: brief in support of a motion (memorandum of law).
//
// Rule-driven and content-agnostic. Requirement IDs (NJD-...) refer to ../README.md, which quotes the
// rule text (D.N.J. L.Civ.R. 7.1(d)(1), 7.2, 10.1, 11.1, 78.1). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // NJD-FORM-002: a standard proportional serif; the only vendored family in fonts/
#let type-size = 14pt                    // NJD-FORM-002: 14-point proportional type (L.Civ.R. 7.2(d)); no 25% page-limit reduction applies
#let pitch = 28.3pt                      // NJD-FORM-003: double spacing, measured in the Karre exemplar (28.3 pt at 14 pt)
#let body-leading = 0.72em               // gap between lines of body text; tuned so the line pitch is `pitch` (see README.md)
#let single-leading = 0.2em              // counsel block, caption, headings in the contents pages, block quotations, signature
#let margins = (top: 1in, bottom: 1in, x: 1in)   // NJD-FORM-001: L.Civ.R. 7.2(c), margins not less than one inch
#let para-indent = 0.5in                 // first-line indent of body paragraphs
#let heading-tab = 0.5in                 // hanging indent of numbered headings
#let footer-size = 12pt                  // page number only; not text under L.Civ.R. 7.2(d)
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("njd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("njd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles
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
// Tables of contents and authorities (L.Civ.R. 7.2(b): both are required)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
  link(hd.location(), block(width: 100%, above: 0.45em, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if lab != "" { box(width: heading-tab, lab) }
      if hd.level == 1 { upper(hd.body) } else { hd.body }
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
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
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("njd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        strong(title)
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            inl(a.name)
            [, ]
          }
          inl(a.cite)
          h(0.8em)
          dot-leader
          h(0.3em)
          page-text
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (L.Civ.R. 10.1(b): docket number, judge, and counsel on the first page; 78.1: motion day)
// ---------------------------------------------------------------------------

#let caption-table(meta) = {
  let sides = need(meta, "caption").parties
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(single-leading * 3); align(center)[v.]; v(single-leading * 3) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    let cn = need(meta, "case_number")
    [Civil Action No. #cn]
    v(pitch * 0.5)
    let judge = need(meta, "judge")
    if judge != "" { inl("Hon. " + judge + ", U.S.D.J."); v(pitch * 0.5) }
    [Motion Day: #need(meta, "motion_day")]
  }
  table(
    columns: (1fr, 1.3fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = page(numbering: none, footer: none, margin: margins, {
  // Counsel block, upper left, single spaced (L.Civ.R. 10.1(b)).
  line-stack(need(meta, "counsel"))
  v(pitch)
  align(center, stack(dir: ttb, spacing: 0pt, ..need(meta, "court").map(l => strong(upper(l)))))
  v(pitch)
  caption-table(meta)
  v(pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
})

// ---------------------------------------------------------------------------
// Signature block (the "s/" line, L.Civ.R. 11.1 and the D.N.J. ECF Policies ¶ 12(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
    grid(columns: (1fr, 3.2in), column-gutter: 0.2in,
      [Dated: #need(meta, "date")],
      stack(dir: ttb, spacing: single-leading,
        [Respectfully submitted,],
        v(pitch * 0.5),
        inl("/s/ " + sig.signer),
        line-stack((sig.signer,) + sig.firm + sig.lines),
      ),
    )
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let running-footer(meta) = context {
  let loc = here()
  set text(size: footer-size)
  align(center, numbering(loc.page-numbering(), ..counter(page).get()))
}

#let njd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "judge", "court", "caption", "counsel", "title", "motion_day", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  // L.Civ.R. 7.2(d): footnotes in the same size of type as the text.
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Block quotations are single spaced and indented on both sides.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, top: pitch * 0.25, bottom: pitch * 0.25, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })

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
      block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  cover(meta)
  // Contents pages: roman numerals (L.Civ.R. 7.2(b)); the body restarts at page 1.
  page(numbering: "i", footer: running-footer(meta), margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer(meta), margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
