// U.S. Court of Federal Claims: motion for judgment on the administrative record, with its
// memorandum of law (the motion-brief doc type).
//
// Rule-driven and content-agnostic. Requirement IDs (RCFC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same sample file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // vendored in /fonts; the only serif face available here
#let type-size = 12pt                      // RCFC-FORM-002: text and footnotes no smaller than 12 point
#let body-leading = 0.9em                  // RCFC-FORM-004: double spacing (see README, "Decisions")
#let single-leading = 0.12em               // quotations, footnotes, headings, TOC/TOA: single-spaced
#let page-margin = 1in                     // RCFC-FORM-003: margins not less than 1 inch
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 3
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let page-limit = 40                       // RCFC-LEN-001: body pages (not TOC, TOA, appendix); 50 for a cross-movant

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
  if key not in meta { panic("uscfc-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("uscfc-motion-brief: the sample must start with a YAML frontmatter block") }
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
// Headings: numbering scheme and styles (the court's own convention, as used in the exemplar)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: I. / A. / 1. / a. / (1).
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 1 { numbering("I.", n) }
  else if h.level == 2 { numbering("A.", n) }
  else if h.level == 3 { numbering("1.", n) }
  else if h.level == 4 { numbering("a.", n) }
  else if h.level == 5 { numbering("(1)", n) }
  else { panic("uscfc-motion-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)
  if it.level == 1 {
    // Section headings: bold, capitals, centered; numbered I., II., ... unless unnumbered.
    let label = if it.numbering == none { [] } else { heading-label(it) + [ ] }
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(upper(label + it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic and bold at level 4+).
    let ind = (it.level - 1) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none
  let ind = if hd.level >= 2 { (hd.level - 1) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(ind + heading-tab, {
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      title
      h(0.8em)
      dot-leader
      box(width: 2.6em, align(right, it.page()))
    })))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body (RCFC 5.4(a)(2)(B)).
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("uscfc-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
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
// Caption and cover (RCFC 5.5(h) bid-protest caption; RCFC 5.5(g) judge; RCFC 10(a) caption)
// ---------------------------------------------------------------------------

/// The caption: parties on the left with a column of ")" marks, the case number and judge on the right.
/// Each party is a dictionary: `name` (a line) and/or `role` (an indented line under it), and a
/// `gap` line is added after each party. Both columns are built from the same rows, so they line up.
#let caption-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  let rows = ()
  for p in need(meta, "parties") {
    if "name" in p { rows.push(inl(p.name)) }
    if "role" in p { rows.push(h(1.6in) + inl(p.role)) }
    if "name" not in p and "role" not in p { rows.push([ ]) }
    rows.push([ ])
  }
  grid(
    columns: (3.4in, 0.35in, 1fr), align: (left, center, left),
    stack(dir: ttb, spacing: 0pt, ..rows),
    stack(dir: ttb, spacing: 0pt, ..rows.map(r => [)])),
    align(horizon, stack(dir: ttb, spacing: 0.5em,
      [Case No. #need(meta, "case_number")],
      inl(need(meta, "judge")))),
  )
}

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  strong[IN THE UNITED STATES COURT OF FEDERAL CLAIMS]
  if meta.at("bid_protest", default: false) {
    linebreak()
    strong[BID PROTEST]
  }
  v(gap)
  align(left, caption-block(meta))
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap * 1.5)
  // Counsel block (RCFC 5.5(f): the attorney of record's email and telephone number).
  let groups = need(meta, "counsel")
  align(left, grid(
    columns: (1fr,) * groups.len(), column-gutter: 1em,
    ..groups.map(g => block(breakable: false, {
      set par(hanging-indent: 0pt, spacing: 0.45em)
      for n in g.names { inl(n); linebreak() }
      for l in g.at("lines", default: ()) { emph(inl(l)); linebreak() }
    })),
  ))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.2, 1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("uscfc-motion-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature and certificate of service (RCFC 5.5(e), 5.5(f), 5.3)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Dated: #need(meta, "date")]
    v(0.8em)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      // The signature line: /s/ and the signer on a rule the width of the column.
      box(width: 100%, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[/s/ #sig.signer]
      linebreak()
      // RCFC 5.5(f): the email and telephone number of the attorney of record directly below the signature line.
      [#sig.signer]
      linebreak()
      [Phone: #need(meta, "phone")]
      linebreak()
      [Email: #need(meta, "email")]
      for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
    }))
  })
}

/// Certificate of Service (RCFC 5.3(a): the day and manner of service, the persons served, the method).
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  // RCFC 5.5(c)(4): the certificate statement is text, so it is double spaced like the body.
  par(first-line-indent: para-indent)[I hereby certify that on this #svc.day, I caused a true and correct copy of the foregoing #inl(svc.documents) to be served by #inl(svc.manner) on:]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  for r in svc.recipients {
    block(above: 0.8em, breakable: false, pad(left: 0.5in, {
      for l in r.lines { inl(l); linebreak() }
    }))
  }
  // The signature in the same right-hand column as the brief's signature block.
  block(above: 1.6em, breakable: false, grid(columns: (1fr, 1fr), [],
    box(width: 100%, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[/s/ #need(meta, "signature").signer]))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let uscfc-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "judge", "parties", "brief_title", "counsel", "phone", "email", "signature", "date", "service") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let limit = if meta.at("cross_motion", default: false) { 50 } else { page-limit }

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
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("2304a(d)(3)"), or between a section sign
  // and its number. Unbreakable boxes keep the extracted text the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone: the last paragraph is kept with it.
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

  // ---- certificate of service (RCFC 5.3(b): attached to the end of the filing) ----
  pagebreak(weak: true)
  certificate-of-service(meta)

  // ---- page limit (RCFC 5.4(b)(1)): counts the body and the certificate, not the TOC or TOA ----
  context {
    let pages = counter(page).final().first()
    if pages > limit {
      panic("uscfc-motion-brief: the body runs " + str(pages) + " pages; RCFC 5.4(b)(1) allows " + str(limit) + " without leave of court")
    }
  }
}
