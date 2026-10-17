// U.S. Bankruptcy Court, District of Hawaii: motion with a memorandum of points and authorities,
// filed in an adversary proceeding (FRBP 9013; LBR 9004-1, 9013-1, 9013-2).
//
// Rule-driven and content-agnostic. Requirement IDs (HIB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // vendored in /fonts; the local rules name no typeface
#let type-size = 14pt                    // HIB-FORM-002: LBR 9004-1(b)(1), all memoranda including footnotes: 14-point type
#let body-leading = 1em                  // HIB-FORM-003: double spacing. Line pitch is 2.3 em (natural line 1.31 em + this gap),
                                         // the same pitch as double-spaced Times New Roman, so a page holds the same lines.
#let single-leading = 0em                // counsel block, caption, headings' tables, footnotes, TOC and TOA entries
#let blank-line = 1.31em                 // one single-spaced blank line
#let margin = 1in                        // HIB-FORM-004: LBR 9004-1(b)(3): margins 1 inch from the edge
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let page-number-size = 12pt
#let passim-threshold = 7                // an authority cited on this many pages or more is listed as "passim"

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hib-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

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
// Tables of contents and authorities (LBR 9013-2(b))
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = label-indent(hd.level)
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
  link(hd.location(), block(width: 100%, above: 0.45em, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if lab != "" { box(width: heading-tab, lab) }
      hd.body
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
}

/// Table of contents from the body headings (levels 2 to 4). Level 1 is an unnumbered title and is
/// not listed.
#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong[Page]))
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level >= 2 and hd.level <= 4 { toc-entry(hd) }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
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
        panic("hib-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover: counsel, court title, caption, title of the paper, hearing (HIB-FORM-001, -005, -006)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (identification of counsel is exempt from double spacing).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
  if "counsel_role" in meta { emph(inl(meta.counsel_role)) }
}

/// One party: its names, then its designation.
#let caption-side(side) = {
  for n in side.names { inl(n); parbreak() }
  pad(left: 1.8in, inl(side.designation))
}

/// Caption (FRBP 9004(b)(1)-(4)). Row 1: the bankruptcy case lines (if any), the first party, and on
/// the right the adversary number, the title of the paper and the noticed hearing. Row 2: the
/// remaining parties ("v."), with the rule closing the party column. The rows are separate unbreakable
/// blocks, so a row moves whole to the next page and no cell is torn. (The filed exemplar's caption
/// also runs onto a second page; see README.md.)
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let bankruptcy = meta.at("bankruptcy", default: ())
  let row1-left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for l in bankruptcy { inl(l); linebreak() }
    if bankruptcy.len() > 0 { v(blank-line) }
    caption-side(sides.at(0))
  }
  let row1-right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "adversary_number")]
    v(blank-line)
    strong(upper(inl(need(meta, "brief_title"))))
  }
  let row2-left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for side in sides.slice(1) {
      align(center)[v.]
      v(blank-line)
      caption-side(side)
    }
  }
  // Noticed hearing date, time and judge, opposite the remaining parties (LBR 9013-1(c)(1)).
  let row2-right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if "hearing" in meta {
      for (k, lab) in (("date", "Date:"), ("time", "Time:"), ("place", "Place:"), ("judge", "Judge:")) {
        if k in meta.hearing {
          [#lab #inl(meta.hearing.at(k))]
          linebreak()
        }
      }
    }
  }
  let cols = (1fr, 1fr)
  stack(
    dir: ttb, spacing: 0pt,
    block(breakable: false, table(
      columns: cols, inset: 0pt,
      stroke: (x, y) => if x == 0 { (right: 0.7pt) } else { none },
      pad(right: 1.2em, bottom: 1em, row1-left),
      pad(left: 1.2em, top: 0.3em, row1-right),
    )),
    if sides.len() > 1 {
      block(breakable: false, table(
        columns: cols, inset: 0pt,
        stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
        pad(right: 1.2em, bottom: 1em, row2-left),
        pad(left: 1.2em, top: 0.3em, row2-right),
      ))
    },
  )
}

#let cover(meta) = page(numbering: none, footer: none, margin: margin, {
  counsel-block(meta)
  v(blank-line)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(blank-line)
  caption-table(meta)
})

// ---------------------------------------------------------------------------
// Signature block (HIB-FORM-007: convention; no local rule text on signatures)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  block(breakable: false, above: blank-line, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [DATED: #need(meta, "date")], {
      for (i, b) in blocks.enumerate() {
        if i > 0 { v(blank-line) }
        for l in b { inl(l); linebreak() }
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let running-footer = context {
  set text(size: page-number-size)
  align(center, numbering(here().page-numbering(), ..counter(page).get()))
}

#let hib-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "counsel", "adversary_number", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")   // LBR 9004-1(a)(2): 8 1/2 x 11 inch
  set document(title: need(meta, "brief_title"))
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
      block(width: 100%, above: blank-line, below: blank-line, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: blank-line, below: blank-line, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  cover(meta)
  page(numbering: "i", footer: running-footer, margin: margin, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer, margin: margin, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
