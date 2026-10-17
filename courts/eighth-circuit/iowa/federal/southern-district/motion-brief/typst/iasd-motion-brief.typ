// Brief in support of a motion for the U.S. District Court for the Southern District of Iowa (iasd).
// Rules: Local Rules of the Northern and Southern Districts of Iowa, effective Dec. 7, 2020: LR 10(a) 8 1/2 x 11 paper;
// LR 10(b)(1)-(3) double spaced, one side, top margin of at least 1 inch; LR 10(b)(4) a brief of more than 10 pages
// has a subject-matter table of contents; LR 10(b) documents of more than one page numbered at the bottom;
// LR 10(d) caption with district, division, case number, party names (Fed. R. Civ. P. 10(a)), designation of the content
// and the filing party; LR 7(b)(3), 7(d) (the brief is filed with the motion and states its grounds and authorities);
// LR 7(c) oral argument requested in the caption; LR 7(h) 20-page limit (tables and signature block not counted);
// LR 11 signature block. Fed. R. Civ. P. 12(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no typeface rule in the S.D. Iowa Local Rules; tier 2. EB Garamond is the only serif in fonts/ (the exemplar is Times New Roman)
#let type-size = 12pt                   // no size rule in the Local Rules; tier 2: 12 point, as in the exemplar
#let footnote-size = 12pt               // tier 2: footnotes at text size, as in the exemplar
#let pitch = 24pt                       // LR 10(b)(1): double spaced; 24 pt baseline pitch at 12 pt
#let page-w = 8.5in                     // LR 10(a)
#let page-h = 11in
#let margin-top = 1in                   // LR 10(b)(3): top margin of at least 1 inch
#let margin-bottom = 1in                // tier 2
#let margin-left = 1in                  // tier 2
#let margin-right = 1in                 // tier 2
#let margins = (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right)
#let text-width = page-w - margin-left - margin-right
#let body-leading = 1.35em              // double spacing: 24 pt baseline pitch at 12 pt (measured in the complaint template, README.md)
#let single-leading = 0.5em             // about 13.8 pt pitch: caption, block quotations, footnotes, tables, signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs (tier 2)
#let heading-tab = 0.5in                // hanging indent of numbered headings (tier 2)
#let caption-left = 3.25in              // width of the party column of the caption (tier 2)
#let passim-threshold = 5               // an authority on this many pages or more is listed as "passim" (tier 2)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field: a missing one fails the build, it is never silently left out.
#let need(meta, k) = {
  if k not in meta { panic("iasd-motion-brief: frontmatter field `" + k + "` is required") }
  meta.at(k)
}

/// Inline markdown. A section or paragraph sign is kept on the line of its number (no-break space).
#let inl(s) = cmarker.render(
  s.replace("§ ", "§\u{a0}").replace("¶ ", "¶\u{a0}"),
  raw-typst: false, smart-punctuation: true,
)

/// Single-spaced lines: one block per item, stacked at the single-spacing pitch.
#let lines-block(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos()
  let depth = lv.len()
  let k = lv.at(depth - 1)
  if depth == 2 { numbering("I.", k) } else if depth == 3 { numbering("A.", k) } else if depth == 4 { numbering("1.", k) } else if depth == 5 { numbering("a.", k) } else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

/// A paragraph with a hanging indent: wrapped lines start at `indent`, the first line at the margin.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, oral argument (LR 10(d), 7(c))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE SOUTHERN DISTRICT OF IOWA",
    upper(need(meta, "division")),
  )
  align(center, lines-block(lines.map(l => "**" + l + "**")))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation; the versus line between the parties.
    let rows = ()
    for (k, p) in need(meta, "caption").parties.enumerate() {
      if k > 0 { rows += (need(meta, "caption").at("versus", default: "v."),) }
      rows += p.names + (p.designation,)
    }
    lines-block(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(first-line-indent: 0pt, leading: single-leading)
    lines-block(("Case No. " + need(meta, "case_number"),))
    v(pitch * 0.5)
    text(weight: "bold", upper(need(meta, "brief_title")))
    if "oral_argument" in meta and meta.oral_argument {
      v(pitch * 0.5)
      text(weight: "bold", "ORAL ARGUMENT REQUESTED")
    }
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Table of contents (LR 10(b)(4)) and table of authorities
// ---------------------------------------------------------------------------

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
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body. Each link is recorded with the
/// page it starts on; an authority on passim-threshold pages or more reads "passim".
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("iasd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        // The page numbers sit in their own column, so a long citation can never push them onto a new line.
        grid(columns: (1fr, 0.9in), column-gutter: 0.2em,
          block(breakable: false, above: 0.6em, below: 0pt, hang(0.35in, {
            set par(leading: single-leading, first-line-indent: 0pt)
            if "name" in a {
              if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
              [, ]
            }
            inl(a.cite)
            h(0.4em)
            dot-leader
          })),
          block(breakable: false, above: 0.6em, below: 0pt, align(right, page-text)))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 11): date, the signature, the name, firm, address, telephone, email
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch, sticky: true, {
    lines-block((sig.date,))
    v(pitch * 0.5)
    pad(left: caption-left + 0.2in, lines-block(sig.lines))
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let iasd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("division", "caption", "case_number", "brief_title", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")           // LR 10(a)
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"))
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
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Block quotations: single spaced and indented on both sides, not double spaced.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(width: 100%, above: 0pt, below: pitch * 0.5, {
    set par(leading: single-leading, first-line-indent: 0pt)
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

  // Front matter: cover (i), table of contents, table of authorities; the body starts again at 1.
  page(numbering: "i", margin: margins, cover(meta))
  page(numbering: "i", margin: margins, {
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", margin: margins, {
    counter(page).update(1)
    cmarker.render(md.replace("§ ", "§\u{a0}").replace("¶ ", "¶\u{a0}"), raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
