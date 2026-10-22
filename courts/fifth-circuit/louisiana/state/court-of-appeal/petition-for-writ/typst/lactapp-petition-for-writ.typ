// Court of Appeal of Louisiana (lactapp): one filing of a Louisiana Court of Appeal (appeal brief,
// motion or writ application). The same file is copied into each doc folder; only the name differs.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Uniform Rules of Louisiana Courts of Appeal, Rules 2-12.2 to 2-12.5 and 2-14; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // COA 2-12.2(D)(2): "Roman or Times New Roman" (docs/FONTS.md, Times alias).
#let type-size = 14pt                      // COA 2-12.2(D)(2): 14-point or larger computer font, all briefs including footnotes.
#let body-leading = 1.2em                  // COA 2-12.2(B): text double-spaced (normal spacing), baseline pitch about twice the single leading below.
#let single-leading = 0.45em               // COA 2-12.2(B): matter customarily single-spaced (headings, block quotations, footnotes, blocks).
#let page-margin = (top: 1.05in, bottom: 1.05in, left: 1in, right: 1.1in)   // COA 2-12.2(B), (D)(2): 1 in each side, at least 1 in top and bottom. Top and bottom are deeper by 0.05 in and right by 0.1 in: footnote marks rise into the top margin, footnote text and justified glyph boxes reach the bottom and right edges by a few pt.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature and counsel blocks start right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lactapp: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("lactapp: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Heading numbers for argument points: level 2 "I.", level 3 "A.", level 4 "1.", level 5 "a.".
/// The level-1 section headings are unnumbered.
#let heading-number(..nums) = {
  let v = nums.pos()
  let k = v.len()
  if k == 2 { numbering("I.", v.at(1)) }
  else if k == 3 { numbering("A.", v.at(2)) }
  else if k == 4 { numbering("1.", v.at(3)) }
  else if k == 5 { numbering("a.", v.at(4)) }
  else { "" }
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(inl(side.designation))
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(inl(n)) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Cover counsel in two columns across the text width, as in the filed covers (Tier 2: both exemplars set
/// counsel side by side; one column right of centre pushed a three-group counsel list onto a second cover page,
/// DEF-COVER-001). Groups keep their order and fill the left column first; the split is the one that leaves the
/// taller column shortest, measured at the column width, so it holds for any counsel list.
#let counsel-columns(groups) = layout(size => {
  let gutter = 0.4in
  let colw = (size.width - gutter) / 2
  let blocks = groups.map(g => block(width: colw, counsel-group(g)))
  let gap = 0.6em   // between groups: the group's own trailing v() is dropped at the end of its block
  if blocks.len() < 2 { return stack(..blocks) }
  let hs = blocks.map(b => measure(b).height)
  let best = 1
  let best-h = none
  for k in range(1, blocks.len()) {
    let tall = calc.max(hs.slice(0, k).sum() + gap.to-absolute() * (k - 1), hs.slice(k).sum() + gap.to-absolute() * (blocks.len() - k - 1))
    if best-h == none or tall < best-h { best = k; best-h = tall }
  }
  grid(columns: (colw, colw), column-gutter: gutter, stack(spacing: gap, ..blocks.slice(0, best)), stack(spacing: gap, ..blocks.slice(best)))
})

/// Signature block: the signer's name under the signature line.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)] \
    #inl(sig.signer)
    #for l in sig.at("lines", default: ()) [ \ #inl(l) ]
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. "150 So. 3d"). A show rule on that string drops a marker after
/// each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<lactapp-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<lactapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true, numbering: none)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The cite wraps in its own column; the page references sit in a fixed-width column beside it, bottom-aligned
      // to the cite's last line, so a page reference never wraps off its entry (DEF-TOC-001).
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(
          columns: (1fr, auto),
          column-gutter: 0pt,
          [#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])],
          align(bottom, pad(left: 4pt, if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })),
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let lactapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // COA 2-12.2(B): pages numbered consecutively; the cover carries no number.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set heading(numbering: heading-number)

  // Level 1: a section, centred, bold, capitals. Level 2-5: argument points, numbered automatically.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]

  // Block quotations: indented, single-spaced (COA 2-12.2(B)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: at the text size (COA 2-12.2(D)(2)) and single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (COA 2-12.3(a)-(j)) ----
  page(numbering: none)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, justify: false)   // single-spaced cover: the body's paragraph spacing (body-leading) between its blocks helped push it past one page (DEF-COVER-001)
    #align(center)[
      #if meta.at("case_number", default: "") != "" [#text(weight: "bold")[No. #meta.case_number] \ ]
      #v(0.2in)
      #text(weight: "bold")[#inl(need(meta, "court_title"))]
    ]
    #v(0.3in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if meta.at("proceeding", default: "") != "" { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
      #if meta.at("on_behalf_of", default: "") != "" [ \ #v(0.2in) #inl(meta.on_behalf_of) ]
      #if meta.at("case_type", default: "") != "" [ \ #v(0.2in) #inl(meta.case_type) ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      counsel-columns(need(meta, "counsel"))   // two columns across the page, not one right of centre (see counsel-columns)
    }
  ]

  // ---- Table of contents (COA 2-12.4(A)(1)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (COA 2-12.4(A)(2)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: pages begin with the first section ----
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render("\n" + body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block and date (COA 2-12.3(i)) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if meta.at("date", default: "") != "" { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (COA 2-14.1, 2-14.2; 2-7.2 for motions) ----
  let svc = meta.at("service", default: none)
  if svc != none {
    pagebreak(weak: true)
    heading(level: 1, numbering: none)[Certificate of Service]
    par[I certify that on #inl(svc.date) a copy of the foregoing was served on all counsel of record and on each unrepresented party by #inl(svc.method), in accordance with La. Code Civ. Proc. art. 1313, as follows:]
    v(0.4em)
    pad(left: 0.5in, {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.6em)
      for r in svc.recipients [ #inl(r) \ ]
    })
    v(0.4em)
    signature-block(need(meta, "signature"))
  }
}
