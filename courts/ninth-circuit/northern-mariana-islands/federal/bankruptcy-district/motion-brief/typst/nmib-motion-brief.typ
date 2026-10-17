// Bankruptcy Court, District of the Northern Mariana Islands (Bankruptcy Division): motion with a
// memorandum of law. Rule-driven and content-agnostic. Requirement IDs (NMIB-...) refer to
// ../README.md, which quotes or cites the rule text (LBR 5005-1, 9004-1, 9013-1; LR 5.2, 7.1; FRBP 9013).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown
// body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // NMIB-FORM-002: serif type. Vendored in /fonts.
#let type-size = 13pt                    // NMIB-FORM-002: 12 point or larger. 13 pt is a style choice (EB Garamond sets smaller than Times at the same size); see ../README.md.
#let pitch = 24pt                        // NMIB-FORM-003: double spacing on 24 numbered lines (pleading form, see NMIB-FORM-004).
#let body-leading = 0.54em               // tuned so one body line occupies exactly one pitch at type-size.
#let single-leading = 0.2em              // counsel block, caption, headings, footnotes, tables of contents and authorities.
#let top-margin = 1.5in                  // NMIB-FORM-001: top margin at least 1.5 in (LR 5.2 as summarized; see README).
#let bottom-margin = 1in                 // NMIB-FORM-001: bottom margin at least 1 in.
#let left-margin = 1.3in                 // NMIB-FORM-001: left margin at least 1 in; room for the line numbers.
#let right-margin = 1in                  // NMIB-FORM-001: right margin at least 0.5 in.
#let margins = (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin)
#let page-w = 8.5in
#let page-h = 11in
#let lines-per-page = 24                 // NMIB-FORM-004: numbered lines per page (matches the filed exemplar).
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let footer-size = 11pt
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"

// ---------------------------------------------------------------------------
// Pleading form: numbered lines and rules (NMIB-FORM-004)
// ---------------------------------------------------------------------------

/// Numbers 1 to 24 down the left margin, one per numbered line; the first line sits on the top margin.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.45in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// A double rule at the text's left edge and a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

#let pleading-background() = {
  line-numbers()
  pleading-rules()
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nmib-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// A heading that must fit on one numbered line (its height is one pitch).
#let heading-line(c) = context {
  assert(measure(width: 6.2in, c).height <= pitch, message: "nmib-motion-brief: a centered heading must fit on one numbered line")
  block(width: 100%, height: pitch, above: pitch, below: 0pt, c)
}

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines (single-spaced headings of any length).
#let on-grid(c) = context {
  let h = measure(width: 6.2in, c).height
  block(width: 100%, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles (NMIB-CONT-001)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "A.", 3 "1.", 4 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LR 7.1 / 7.1 TOC practice as used by the exemplar)
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
  ("local", "Local Bankruptcy Rules"),
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
        panic("nmib-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (LBR 5005-1(b); FRCP 10(a) as applied by FRBP 7010 for adversary captions; LR 5.2)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced. Names, firm, address, telephone, email and bar number as given.
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
  v(single-leading)
  emph(inl(need(meta, "counsel_role")))
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let hearing = meta.at("hearing", default: (:))
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.0in, inl(side.designation))
      if i < sides.len() - 1 { v(pitch * 0.5); align(center)[v.]; v(pitch * 0.5) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
    linebreak()
    [Chapter #need(meta, "chapter")]
    v(pitch * 0.5)
    strong(upper(inl(need(meta, "brief_title"))))
    v(pitch * 0.5)
    // LBR 5005-1(b)(2): the hearing date and time and the presiding judge, when the document is the subject of a hearing.
    for (k, lab) in (("date", "Hearing Date:"), ("time", "Hearing Time:"), ("judge", "Judge:")) {
      if k in hearing {
        [#lab ]
        inl(hearing.at(k))
        linebreak()
      }
    }
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = page(numbering: none, footer: none, margin: margins, {
  counsel-block(meta)
  v(pitch)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(pitch)
  caption-table(meta)
})

// ---------------------------------------------------------------------------
// Signature block (convention; the court's rules do not prescribe the form; see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sigs = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      for s in sigs {
        v(pitch)
        box(width: 2.6in, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), [/s/])
        linebreak()
        inl(s.signer)
        linebreak()
        for l in s.at("lines", default: ()) { inl(l); linebreak() }
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let running-footer = context {
  let loc = here()
  set text(size: footer-size)
  align(center, numbering(loc.page-numbering(), ..counter(page).get()))
}

#let nmib-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "chapter", "court", "caption", "counsel", "counsel_role", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, background: pleading-background())
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").first().signer,
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
      heading-line(align(center, text(size: type-size, strong(upper(it.body)))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: pitch, below: 0pt, sticky: true,
        on-grid(hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          text(size: type-size, strong(it.body))
        })))
    }
  }

  cover(meta)
  page(numbering: "i", footer: running-footer, margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer, margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
