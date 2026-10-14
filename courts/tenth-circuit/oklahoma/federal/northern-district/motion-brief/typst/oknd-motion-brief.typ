// U.S. District Court, Northern District of Oklahoma: motion with brief in support (one filed document).
//
// Rule-driven and content-agnostic. Requirement IDs (OKND-...) refer to ../README.md, which quotes the rule
// text: LGnR2-4 (format of papers; Local Rules, 2026-07-31), LCvR7-1(b) (motion and brief as one document),
// LCvR7-1(d) (25-page limit; indexed TOC and TOA above 15 pages), Fed. R. Civ. P. 12(b). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // OKND-FORM-002: vendored proportional font (the only one in /fonts).
#let type-size = 13pt                    // OKND-FORM-002: not smaller than 12 pt, footnotes and quotations included. 13 pt is a style choice; see ../README.md.
#let line-pitch = 24pt                   // OKND-FORM-001: double spacing. With the margins below, 27 lines fit per page.
#let body-leading = 0.54em               // gap between lines of body text; tuned so the line pitch is line-pitch (measured, ../README.md).
#let single-leading = 0.2em              // captions, block quotations, footnotes, tables of contents and authorities, signature block.
#let margins = (top: 1in, bottom: 1in, x: 1in)   // OKND-FORM-003: at least one inch on the top, bottom and sides.
#let footer-size = 12pt                  // page number, at the 12 pt floor.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let passim-threshold = 7                // an authority cited on this many pages or more: "passim".
#let toc-threshold = 15                  // LCvR7-1(d): a brief exceeding fifteen pages needs an indexed TOC and TOA.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("oknd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oknd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles. Level 1 is unnumbered (SUMMARY OF ARGUMENT, ARGUMENT AND AUTHORITY);
// levels 2-5 are numbered by the template: I., A., 1., a.
// ---------------------------------------------------------------------------

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
// Tables of contents and authorities (LCvR7-1(d); built only when `toc_toa: true` in the frontmatter)
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
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
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
        panic("oknd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
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
// Cover: court name, caption, title of the paper (FRCP 10(a) form, as the court files it)
// ---------------------------------------------------------------------------

/// The court's own name, on two centered lines.
#let court-title() = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong[IN THE UNITED STATES DISTRICT COURT FOR THE])
  v(single-leading)
  align(center, strong[NORTHERN DISTRICT OF OKLAHOMA])
}

/// Parties on the left (each side: its names, then its designation; "v." between sides), the file
/// number on the right, closed by a rule on the right and bottom.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      stack(dir: ttb, spacing: 0pt, ..side.names.map(n => inl(n)))
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
    }
  }
  let right = align(horizon, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
  })
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, bottom: 0.3em, right),
  )
}

#let cover(meta) = {
  court-title()
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(inl(need(meta, "title"))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [#if "date" in meta [Dated: #meta.date]], {
      [Respectfully submitted,]
      v(line-pitch)
      stack(dir: ttb, spacing: 0pt,
        [/s/ #inl(sig.signer)],
        ..sig.at("lines", default: ()).map(l => inl(l)),
      )
    })
  })
}

/// Certificate of service (Fed. R. Civ. P. 5(d)(1)(B): required only when a paper is not served through the
/// court's electronic-filing system). Starts on its own page.
#let certificate-block(meta) = {
  let c = meta.certificate
  pagebreak()
  align(center, strong(upper[Certificate of Service]))
  v(line-pitch * 0.5)
  par(first-line-indent: para-indent, inl(c.text))
  v(line-pitch * 0.5)
  block(breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 0.5in, stack(dir: ttb, spacing: 0pt, ..c.at("service", default: ()).map(l => inl(l))))
  })
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [], stack(dir: ttb, spacing: 0pt, [/s/ #inl(c.signer)], inl(c.signer)))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let oknd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "title", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let toc-toa = meta.at("toc_toa", default: false)

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",   // one continuous Arabic sequence from the caption page (as in both exemplars)
    footer: context {
      set text(size: footer-size)
      align(center, counter(page).display("1"))
    },
  )
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
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Block quotations are single-spaced and indented on both sides, as in the court's filings.
  show quote.where(block: true): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5,
    pad(left: 0.5in, right: 0.5in, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      it.body
    }))

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
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  cover(meta)
  if toc-toa {
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
    pagebreak()
  }
  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature-block(meta)
  if "certificate" in meta { certificate-block(meta) }
}
