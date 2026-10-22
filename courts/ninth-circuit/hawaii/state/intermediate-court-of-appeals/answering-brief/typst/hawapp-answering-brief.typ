// Hawaii Intermediate Court of Appeals: answering brief.
//
// Content-agnostic. The numbers below are the ones HRAP 32(a)-(b) (flyleaf, 1-inch margins, 12-point
// Times New Roman, double spacing) and HRAP 28(b) (the brief's sections) set; see ../../rules.md. No
// case-specific text, no coordinates measured off any filed brief, no forced line breaks. The markdown
// body is rendered by cmarker; the metadata is the YAML frontmatter of the same file.
// Base: the CA fifth-district answering-brief template (table of contents and authorities generators,
// heading scheme, footnote and quotation styles), adapted to HRAP.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HRAP 32(b): Times New Roman 12 pt is deemed to comply; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // HRAP 32(b): 12 point, footnotes and quotations included.
#let body-leading = 1.15em                 // HRAP 32(b): double spaced. 1.15em of extra leading gives a 27.6 pt pitch at 12 pt.
#let single-leading = 0em                  // headings, block quotations, footnotes, TOC and TOA: single spaced (13.8 pt pitch).
#let page-margin = 1in                     // HRAP 32(a): not less than 1 inch on all sides.
#let flyleaf-band = 3in                    // HRAP 32(a): the flyleaf keeps a 3-inch-by-3-inch top-right corner clear.
#let para-indent = 0.5in
#let toc-depth = 5
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim".

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("hawapp-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hawapp-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// Returns (content, placed). Why not simply put the tag in front: when a citation begins at the
/// start of a line, typst files a tag that sits before the first word under the PREVIOUS line, which
/// may be on the previous page, so the table of authorities would cite the wrong page.
#let tag-after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = tag-after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = tag-after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) }
      else { let r = tag-after-first-word(ch, tag); out.push(r.first()); placed = r.last() }
    }
    return (out.join(), placed)
  }
  (c, false)
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: I. / A. / 1. / a. (level 2 to 5).
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("hawapp-answering-brief: headings deeper than level 5 are not supported") }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1em, below: 0.8em, strong(it.body))
  } else {
    // Numbered sub-headings: label in a fixed box, text hangs under the text, bold.
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1em, below: 0.8em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])
#let toc-page-width = 2em               // page-number column of the table of contents

/// One table-of-contents row, built from a heading element. The label sits where the heading's
/// own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  // Two columns: the title and its leader wrap inside the first, the page number sits in the second,
  // level with the last line. A long title therefore never pushes its page number onto a line of its own.
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    grid(columns: (1fr, toc-page-width), column-gutter: 0.3em,
      hang(ind + heading-tab, {
        h(ind)
        if numbered { box(width: heading-tab, lab) }
        title
        h(0.6em)
        dot-leader
      }),
      align(right + bottom, it.page()),
    )))
}

/// The table of contents lists the body's headings: the ones after `<body-start>` and before
/// `<body-end>`. The certificate of service is not listed.
#let toc-section() = {
  heading(level: 1, numbering: none)[Table of Contents]
  align(right, block(above: 0.3em, below: 1em, strong(underline(offset: 0.25em)[Page])))
  show outline.entry: toc-entry
  outline(
    title: none,
    target: selector(heading.where(outlined: true)).after(<body-start>).before(<body-end>),
    depth: toc-depth, indent: 0pt,
  )
}

#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("hawapp-answering-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: if first { 1em } else { 0.2em }, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline(offset: 0.25em)[Page(s)]) }
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
        // The page list sits in its own right-hand column, so a long citation never wraps a page reference alone.
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%,
          grid(columns: (1fr, 1.4in), column-gutter: 0.3em,
            hang(0.35in, {
              if "name" in a {
                if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
                [,]
                linebreak()
              }
              inl(a.cite)
              h(0.8em)
              dot-leader
            }),
            align(right + bottom, page-text),
          ))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Flyleaf (HRAP 32(a)): case number, court and cause, character of the document, counsel with
// telephone, e-mail and Hawaii bar number, and the judges who participated. The flyleaf is
// the first page, has a 3-inch top margin, and is not printed with a page number.
// ---------------------------------------------------------------------------

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  // HRAP 32(a): the top right 3-inch-by-3-inch corner of the flyleaf is left clear; the case number and
  // the court sit in the top left band, and the cause, judges, title and counsel run full width below it.
  grid(columns: (3.5in, 1fr), rows: (flyleaf-band,),
    align(top + left, {
      [No. #need(meta, "case_number")]
      v(gap)
      for l in need(meta, "court_lines") { strong(l); linebreak() }
    }),
    [],
  )
  // The cause: each side's names, then its designation, with "v." between the sides.
  align(left, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.3em)
    let sides = need(meta, "caption")
    for (i, side) in sides.enumerate() {
      for name in side.names { inl(name); parbreak() }
      pad(left: 45%, inl(side.designation))
      if i < sides.len() - 1 { v(gap * 0.4); pad(left: 45%, [v.]); v(gap * 0.4) }
    }
  })
  v(gap)
  set align(center)
  if "proceeding" in meta {
    inl(meta.proceeding)
    v(gap)
  }
  for j in need(meta, "judges") { inl(j); linebreak() }
  v(gap * 1.6)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap * 1.6)
  // Counsel: each counsel group in its own column, then the party line.
  align(left, {
    set par(hanging-indent: 0pt, spacing: 0.2em)
    let groups = need(meta, "counsel")
    grid(columns: groups.map(_ => 1fr), column-gutter: 0.3in, ..groups.map(g => block(breakable: false, {
      for n in g.names { n; linebreak() }
      for l in g.at("lines", default: ()) { l; linebreak() }
    })))
    v(0.5em)
    emph(inl(need(meta, "counsel_for")))
  })
}

/// The flyleaf is one page. The spacing between its parts is the only
/// thing that gives: the largest spacing at which the whole flyleaf fits is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, margin: page-margin, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.2, 1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("hawapp-answering-brief: the flyleaf does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature (HRAP 32(c)), certificate of service (HRAP 28(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in),
      [DATED: #need(meta, "date")],
      [#sig.firm \ #v(1.8em) #line(length: 100%) \ #sig.signer \ #emph(inl(sig.role))])
  })
}

/// Certificate of service: HRAP 28(a) requires proof of service of two copies on each party when service
/// is by any means other than a notice of electronic filing. Written only when `service` is in the frontmatter.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.8em, justify: false)
  [I certify that on #need(meta, "date"), two copies of the foregoing document, #inl(need(meta, "brief_title")), were served on the following parties by #svc.method:]
  for s in svc.served {
    block(above: 0.6em, breakable: false, pad(left: 0.5in, [#s.name \ #s.address]))
  }
  block(above: 1.4em, breakable: false, pad(left: 50%, [#need(meta, "signature").signer \ #emph(inl(need(meta, "signature").role))]))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let hawapp-answering-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court_lines", "caption", "judges", "brief_title", "counsel", "counsel_for",
            "signature", "date") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, number-align: center, footer-descent: 30%)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)   // HRAP 32(b): footnotes in the same font and size as the text
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Typography that holds for any text: never break inside a token of adjacent parentheses
  // ("60(b)(5)"), and never between a section sign and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶]+ \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- flyleaf (page 1) ----
  cover(meta)

  // ---- tables (pages 2 onward; arabic, counting the flyleaf as page 1) ----
  set page(numbering: "1")
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // ---- body ----
  [#metadata(none)<body-start>]
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is kept with it
    // (unless that last block is a heading or a footnote definition).
    let text-md = md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }
  [#metadata(none)<body-end>]

  // ---- certificate of service ----
  if "service" in meta {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
