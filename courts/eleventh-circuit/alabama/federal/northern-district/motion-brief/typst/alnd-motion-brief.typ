// Memorandum in support of a motion for the U.S. District Court for the Northern District of Alabama (alnd):
// the brief that accompanies a Rule 12(b) motion, with a table of contents and a table of authorities.
// Rules: Fed. R. Civ. P. 7(b) (motions state the grounds with particularity), 10(a) (caption), 11(a) (signature);
// Local Rule 5.5 (electronic filing). The local rules of the court (rev. Dec. 4, 2019) set no typeface, margin,
// spacing or length rule for briefs; a judge's standing order may (see ../README.md). Layout follows the filed
// exemplar where the rules leave it open.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated layout choice in ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // no ALND typeface rule; vendored in /fonts, the only serif face there
#let type-size = 13pt                   // EB Garamond sets smaller than Times at the same size; 13 pt matches the exemplar's Times 12 pt (README.md)
#let line-pitch = 24pt                  // double spacing, the convention of the exemplar (no ALND rule states it)
#let body-leading = 1.2em               // gap between body lines: EB Garamond sets a 0.65 em line box, so this gives a 24 pt pitch at 13 pt (measured, README.md)
#let single-leading = 0.5em             // captions, headings, signature blocks, tables: about 15 pt pitch at 13 pt (measured, README.md)
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let footer-size = type-size
#let passim-threshold = 7               // authority cited on this many pages or more: "passim"

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alnd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the brief's sections; level 1 is unnumbered)
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
// Tables of contents and authorities
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
        panic("alnd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = align(center, strong({
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for l in need(meta, "court") {
    inl(l)
    linebreak()
  }
}))

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    // Each party: its names, then its designation set in from the names; "v." between the parties.
    let rows = ()
    for (i, side) in sides.enumerate() {
      if i > 0 { rows.push(align(center, [v.])) }
      for n in side.names { rows.push(inl(n)) }
      rows.push(pad(left: 1.8in, inl(side.designation)))
    }
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    stack(dir: ttb, spacing: single-leading, ..rows)
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "case_label") #need(meta, "case_number")]
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
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, block(width: 85%, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    strong(upper(inl(need(meta, "brief_title"))))
  }))
})

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let sig-lines(lines) = {
  for l in lines {
    if l == "" { v(single-leading * 3) } else { inl(l); linebreak() }
  }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "date_line")]
    v(line-pitch)
    grid(
      columns: (1fr,) * sig.firms.len(),
      column-gutter: 0.3in,
      ..sig.firms.map(lines => sig-lines(lines)),
    )
    v(line-pitch)
    sig-lines(sig.at("lines", default: ()))
  })
}

#let certificate(meta) = {
  let c = need(meta, "certificate")
  heading(level: 1, numbering: none)[#c.title]
  block(breakable: false, {
    set par(first-line-indent: para-indent, leading: body-leading, justify: false)
    inl(c.text)
    v(line-pitch)
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    h(1fr)
    block(width: 3.2in, {
      [#c.date_line]
      v(line-pitch)
      [/s/ #c.signer]
      linebreak()
      inl(c.signer)
    })
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let running-footer = context {
  align(center, text(size: footer-size, counter(page).display()))
}

#let alnd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "case_label", "case_number", "brief_title", "signature", "date_line") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")   // 8 1/2 x 11 inch
  set document(title: need(meta, "brief_title"))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
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
    if "certificate" in meta {
      pagebreak()
      certificate(meta)
    }
  })
}
