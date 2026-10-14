// Memorandum in support of a motion to dismiss for the United States District Court for the District of
// Alaska (akd). Rules: D. Alaska Local Civil Rule 7.5(a) (double-spaced; margins of at least 1 inch,
// footers included; a page number and a footer with the case name and number on every page of a
// multi-page document; at least 13-point proportionally spaced font), 7.5(b) (first-page layout), 7.5(c)
// (signature block), 7.1(a) (a motion states the relief and the points and authorities), 7.4(a)(1) (a
// Rule 12(b) memorandum is limited to 35 pages or 10,000 words, the caption, signature and tables
// excluded: 7.4(a)(4); the template does not count pages or words), 8.1 (pleadings; not applicable to a
// memorandum but its statute-under-the-title line is kept for the motion's citation). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // L.R. 7.5(a)(1)(D): proportionally spaced; vendored in fonts/
#let type-size = 13pt                   // L.R. 7.5(a)(1)(D): at least 13-point
#let body-leading = 1.35em              // L.R. 7.5(a)(1)(A): double-spaced. Measured at 13 pt: single line 17.0 pt, double 34.5 pt (README.md)
#let single-leading = 0em              // single spacing: the line pitch is the font line height (17.0 pt at 13 pt)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margins = 1in                      // L.R. 7.5(a)(1)(B): at least 1 inch on all sides, footer included
#let footer-size = 13pt                 // L.R. 7.5(a)(1)(D): the footer is part of the document; same size as the text
#let caption-left = 3.4in               // width of the party column of the caption
#let title-gap = 1.5em                  // space above and below a heading or the document title
#let passim-threshold = 7               // an authority cited on this many pages or more prints "passim"
#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("akd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field; a missing one fails the build with its name.
#let need(meta, k) = {
  if k not in meta { panic("akd-motion-brief: the sample frontmatter needs `" + k + "`") }
  meta.at(k)
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Heading labels. Level 1 (the section headings INTRODUCTION, BACKGROUND, ...) is unnumbered; level 2
/// is I., II.; level 3 is A., B.; level 4 is 1., 2.; level 5 is a., b.
#let heading-num(..nums) = {
  let v = nums.pos()
  let n = v.last()
  if v.len() == 1 { none } else if v.len() == 2 { numbering("I.", n) } else if v.len() == 3 { numbering("A.", n) } else if v.len() == 4 { numbering("1.", n) } else { numbering("a.", n) }
}

/// Indent of a heading label, by level.
#let label-indent(level) = if level <= 2 { 0in } else { (level - 2) * 0.5in }
#let heading-tab = 0.5in

/// A paragraph whose wrapped lines hang at `indent` (headings, table entries).
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page: page number, the short title of the paper, then the case name and number
/// (L.R. 7.5(a)(1)(C)).
#let running-footer(meta) = context {
  let loc = here()
  set text(size: footer-size)
  align(center)[
    #numbering(loc.page-numbering(), ..counter(page).get())
    #v(0.2em)
    #need(meta, "footer_title")\
    #need(meta, "case_name"), Case No. #need(meta, "case_number")
  ]
}

/// Court title, centered, one line per entry (L.R. 7.5(b)(2)).
#let court-title(lines) = block(width: 100%, above: 0pt, below: 0pt)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #align(center)[#for l in lines [#strong[#upper(l)]\ ]]
]

/// Counsel block, upper left, single-spaced (L.R. 7.5(b)(1)(A)-(C)).
#let counsel-block(lines) = block(width: 100%, above: 0pt, below: 0pt)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #for l in lines [#inl(l)\ ]
]

/// Caption: parties on the left, closed by a rule on the right and bottom; the case number and the
/// judge's name on the right (L.R. 7.5(b)(3)(B)).
#let caption(meta) = {
  let sides = need(meta, "caption")
  let left = []
  for s in sides {
    for n in s.names { left += inl(n) + linebreak() }
    left += v(0.4em)
    left += align(right, [#s.designation])
    left += v(0.8em)
  }
  block(width: 100%, above: 1.2em, below: 0pt)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.6em,
      block(width: 100%, stroke: (right: 0.7pt, bottom: 0.7pt), inset: (right: 0.6em, bottom: 0.6em), left),
      block(width: 100%, inset: (left: 0.4em, top: 0.2em))[
        #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
        No. #need(meta, "case_number")
        #if "judge" in meta [\ #inl(meta.judge)]
      ],
    )
  ]
}

/// Document title, centered and bold, with the statute under it (L.R. 8.1(a)) and an optional
/// oral-argument legend (L.R. 7.1(f)).
#let doc-title(meta) = block(width: 100%, above: title-gap, below: title-gap)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #align(center)[#strong(upper(need(meta, "title")))]
  #if "statute" in meta [#align(center)[(#meta.statute)]]
  #if meta.at("oral_argument", default: false) [#align(center)[#strong[Oral Argument Requested]]]
]

/// The cover: attorney block, court title, caption and title (L.R. 7.5(b)).
#let cover(meta) = {
  counsel-block(need(meta, "counsel"))
  v(0.8in)
  court-title(need(meta, "court"))
  v(0.3in)
  caption(meta)
  doc-title(meta)
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
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
      if lab != none { box(width: heading-tab, lab) }
      if hd.level == 1 { upper(hd.body) } else { hd.body }
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
}

#let toc-section() = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
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

#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.at("cite", default: ""))))

/// Table of authorities, built from the `toa:` links found in the body (L.R. 7.4 is silent on it; the
/// convention is kept from the exemplar).
#let toa-section(authorities) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("akd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 0.8em } else { 1em }, below: 0.2em, sticky: true)[
        #strong(title)
      ]
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
        block(breakable: false, above: 0.35em, below: 0pt, width: 100%, hang(0.35in, {
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
// Body
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks. Footnote definitions are collected
/// first and attached to each chunk that cites them, because cmarker needs the definition in the
/// same source.
#let split-body(body) = {
  let chunks = body.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let rest = ()
  for c in chunks {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { defs.insert(m.captures.at(0), c) } else { rest.push(c) }
  }
  (rest, defs)
}

/// The markdown source for one chunk, with the footnote definitions it cites appended.
#let chunk-source(c, defs) = {
  let extra = ()
  for m in c.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    if k in defs and defs.at(k) not in extra { extra.push(defs.at(k)) }
  }
  c + "\n\n" + extra.join("\n\n")
}

/// Render the body. A chunk is a heading (starts with #), a block quotation (starts with >), a list
/// (starts with a number and a dot, or a bullet) or a paragraph; paragraphs are indented, not numbered
/// (memoranda are not numbered pleadings; Fed. R. Civ. P. 10(b) applies to complaints).
#let render-body(body) = {
  let (chunks, defs) = split-body(body)
  for c in chunks {
    if c.starts-with("#") or c.starts-with(">") or c.match(regex("^(\\d+\\.|[-*+]) ")) != none {
      cmarker.render(chunk-source(c, defs), raw-typst: false, smart-punctuation: true)
    } else {
      block(width: 100%, above: 0pt, below: 0pt)[
        #h(para-indent)
        #cmarker.render(chunk-source(c, defs), raw-typst: false, smart-punctuation: true)
      ]
    }
  }
}

/// Signature block (L.R. 7.5(c)(1)-(2)): the date line, the preamble lines, the signature line and the
/// signer's name and the lines under it, single-spaced, set in the right half of the page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: title-gap, below: 0pt, breakable: false)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #if "date" in meta [#h(para-indent) #inl(meta.date)\ ]
    #v(0.8em)
    #pad(left: 2.5in)[
      #for l in sig.at("preamble", default: ()) [#inl(l)\ ]
      #v(1em)
      /s/ #sig.signer\
      #for l in sig.at("lines", default: ()) [#inl(l)\ ]
    ]
  ]
}

/// Certificate of service, when the sample has one (the exemplar does not; see README.md).
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  pagebreak(weak: true)
  align(center)[#strong[CERTIFICATE OF SERVICE]]
  v(title-gap)
  block(width: 100%, above: 0pt, below: 0pt)[#h(para-indent) #inl(c.text)]
  v(2.4em)
  pad(left: 2.5in)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #line(length: 3in, stroke: 0.5pt)
    #c.signer
  ]
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let akd-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "case_name", "footer_title", "caption", "counsel", "title", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins)
  set document(
    title: need(meta, "title") + ", Case No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: 0pt, justify: false)
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)
  show quote: it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 0.9em)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #it.body
  ]
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
    let lab = heading-num(..nums)
    if it.level == 1 {
      block(width: 100%, above: title-gap, below: title-gap, sticky: true)[
        #align(center)[#strong(upper(it.body))]
      ]
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: title-gap, below: title-gap, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          if lab != none { box(width: heading-tab, lab) }
          strong(it.body)
        }))
    }
  }

  // Cover (page i), tables (ii and on), then the body from page 1.
  page(numbering: "i", footer: running-footer(meta), {
    cover(meta)
  })
  page(numbering: "i", footer: running-footer(meta), {
    toc-section()
  })
  page(numbering: "i", footer: running-footer(meta), {
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer(meta), {
    counter(page).update(1)
    render-body(body)
    signature-block(meta)
    certificate(meta)
  })
}
