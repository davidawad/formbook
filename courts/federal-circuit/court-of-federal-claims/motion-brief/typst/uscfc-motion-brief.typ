// U.S. Court of Federal Claims: motion for judgment on the administrative record, with its
// memorandum of law (the motion-brief doc type).
//
// Rule-driven and content-agnostic. Requirement IDs (RCFC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same sample file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in /fonts (Liberation Serif: Times New Roman metrics)
#let type-size = 12pt                      // RCFC-FORM-002: text and footnotes no smaller than 12 point
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt                 // a single line: 1.15 x the type size (the Word convention)
#let pitch-double = 2 * pitch-single       // RCFC-FORM-004: the text is double spaced
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6 (a longer list widens its own row's column)
#let caption-cols = (3.4in, 0.35in)        // caption: the parties, then the column of ")" marks
#let role-indent = 1.6in                   // caption: a party's role steps in under its name
#let cover-gap = 2 * pitch-single          // cover: the space between its parts
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

/// A paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(hanging-indent: indent, first-line-indent: 0pt, body)

/// One single-spaced line block (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// A signature line: /s/ and the signer on a rule the width of the column (the rule takes no room of its own).
#let signed(name) = box(width: 100%, stroke: (bottom: 0.5pt + black), outset: (bottom: 1pt))[/s/ #name]

// Space around headings: a section heading has a double line above it and a single line below; a sub-heading a
// single line on each side.
#let section-above = pitch-double
#let section-below = pitch-single
#let sub-above = pitch-single
#let sub-below = pitch-single

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  set text(size: type-size, ..edges(pitch-single))
  if it.level == 1 {
    // Section headings: bold, capitals, centered; numbered I., II., ... unless unnumbered.
    let label = if it.numbering == none { [] } else { heading-label(it) + [ ] }
    block(width: 100%, sticky: true, above: section-above, below: section-below,
      align(center, strong(upper(label + it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: sub-above, below: sub-below, strong(it.body))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic and bold at level 4+).
    let ind = (it.level - 1) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: sub-above, below: sub-below, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// One table-of-contents row, built from a heading element: the label where the heading's own label sits, wrapped
/// lines hanging under the title; the page number in its own column (listing-row), a leader running to it.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none
  let ind = if hd.level >= 2 { (hd.level - 1) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, if hd.level == 1 { 9pt } else { 4pt })
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0pt, below: 0pt, strong(underline[Page])))
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
      block(width: 100%, above: if first { 0pt } else { pitch-double }, below: 4pt, sticky: true, {
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
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), 0.35in, 10pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Caption and cover (RCFC 5.5(h) bid-protest caption; RCFC 5.5(g) judge; RCFC 10(a) caption)
// ---------------------------------------------------------------------------

/// The caption: one row per line. Each party is a dictionary: `name` (a line) and/or `role` (a line stepped in
/// under it), and an empty row follows each party; every row has a ")" in the middle column. The case number and the
/// judge stand in the right column on the two rows at the middle of the caption.
#let caption-rows(meta) = {
  let rows = ()
  for p in need(meta, "parties") {
    if "name" in p { rows.push(inl(p.name)) }
    if "role" in p { rows.push(pad(left: role-indent, inl(p.role))) }
    if "name" not in p and "role" not in p { rows.push([]) }
    rows.push([])
  }
  rows
}

#let caption-block(meta) = {
  let rows = caption-rows(meta)
  let mid = calc.max(0, calc.quo(rows.len(), 2) - 1)
  let right(i) = if i == mid { [Case No. #need(meta, "case_number")] } else if i == mid + 1 { inl(need(meta, "judge")) } else { [] }
  grid(
    columns: (..caption-cols, 1fr), align: (left, center, left),
    ..rows.enumerate().map(((i, r)) => (r, [)], right(i))).flatten(),
  )
}

/// The cover: the court, the caption, the title and counsel, single spaced, a double line between the parts.
#let cover(meta) = page(numbering: none, footer: none, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  line-block(align(center, strong[IN THE UNITED STATES COURT OF FEDERAL CLAIMS]))
  if meta.at("bid_protest", default: false) { line-block(align(center, strong[BID PROTEST])) }
  block(width: 100%, above: cover-gap, below: 0pt, caption-block(meta))
  line-block(above: cover-gap, align(center, strong(upper(inl(need(meta, "brief_title"))))))
  // Counsel block (RCFC 5.5(f): the attorney of record's email and telephone number).
  let groups = need(meta, "counsel")
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (1fr,) * groups.len(),
    ..groups.map(g => {
      for n in g.names { line-block(inl(n)) }
      for l in g.at("lines", default: ()) { line-block(emph(inl(l))) }
    }),
  ))
})

// ---------------------------------------------------------------------------
// Signature and certificate of service (RCFC 5.5(e), 5.5(f), 5.3)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch-double, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    line-block[Dated: #need(meta, "date")]
    block(width: 100%, above: pitch-single, below: 0pt, grid(columns: (1fr, 1fr), [], {
      line-block[Respectfully submitted,]
      // The signature line: /s/ and the signer on a rule the width of the column.
      line-block(above: pitch-double, signed(sig.signer))
      // RCFC 5.5(f): the email and telephone number of the attorney of record directly below the signature line.
      line-block[#sig.signer]
      line-block[Phone: #need(meta, "phone")]
      line-block[Email: #need(meta, "email")]
      for l in sig.at("lines", default: ()) { line-block(emph(inl(l))) }
    }))
  })
}

/// Certificate of Service (RCFC 5.3(a): the day and manner of service, the persons served, the method).
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  // RCFC 5.5(c)(4): the certificate statement is text, so it is double spaced like the body.
  par(first-line-indent: para-indent)[I hereby certify that on this #svc.day, I caused a true and correct copy of the foregoing #inl(svc.documents) to be served by #inl(svc.manner) on:]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for r in svc.recipients {
    block(width: 100%, above: pitch-single, below: 0pt, breakable: false, pad(left: 0.5in, {
      for l in r.lines { line-block(inl(l)) }
    }))
  }
  // The signature in the same right-hand column as the brief's signature block.
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(columns: (1fr, 1fr), [],
    line-block(signed(need(meta, "signature").signer))))
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
  // RCFC-FORM-005: the page number centered in the bottom margin, in a single-spaced line box, so it sits at the
  // same place on every page (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, ragged right, no kerning, ligatures or
  // hyphenation, line boxes of the body pitch (RCFC-FORM-004: double spaced), footnote marks at 58 %, no break inside
  // "2304a(d)(3)" or after a section sign.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set heading(numbering: none)
  set footnote.entry(
    gap: 6pt, clearance: 12pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // RCFC-FORM-004: quoted material single spaced, indented both sides; a single line around it.
  show quote.where(block: true): it => block(above: pitch-single, below: pitch-single, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: pitch-single)
    it.body
  }))
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- front matter (lowercase roman), single spaced ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    toc-section()
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
  pagebreak()
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
