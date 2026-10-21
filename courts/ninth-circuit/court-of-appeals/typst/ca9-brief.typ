// U.S. Court of Appeals for the Ninth Circuit: principal (opening) brief.
//
// Rule-driven and content-agnostic. Requirement IDs (CA9-...) refer to ../rules.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "../../../../lib/typst/ca9-cover.typ": cover-body as shared-cover-body, ca9-cover as shared-ca9-cover
#import "../../../../lib/typst/tables.typ": dot-leader as shared-dot-leader, outline-row as shared-outline-row
#import "../../../../lib/typst/typography.typ": hanging-paragraph as shared-hanging-paragraph
#import "../../../../lib/typst/headings.typ": section-heading as shared-section-heading
#import "../../../../lib/typst/typography.typ": footnote-body as shared-footnote-body
#import "../../../../lib/typst/certificates.typ": ca9-compliance as shared-ca9-compliance, ca9-service as shared-ca9-service
#import "../../../../lib/typst/toa.typ": linked-authorities as shared-linked-authorities, cited-authorities as shared-cited-authorities, authority-page-labels as shared-authority-page-labels

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // CA9-FORM-004: serif, proportional. Vendored in /fonts.
#let type-size = 14pt                      // CA9-FORM-004: 14-point or larger, everywhere.
#let heading-size = 16pt                   // section headings: a little larger than the body (a whole half point, as Word sizes go)
// Cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"): the typst, LaTeX and Word renders break every
// line and page alike. Every line is a box of a fixed height (its pitch) with the baseline at 0.8 of it, the boxes
// stack with no leading, and the space between blocks is the larger of the space below the one and above the other
// (dropped at the top of a page). That is Word's exact line spacing; LaTeX sets the same boxes with \pdfeachlineheight.
#let pitch-double = 29.4pt                 // CA9-FORM-003: body text, 2.1 x type size (double spacing)
#let pitch-single = 17pt                   // headings, quotations, footnotes, TOC/TOA, certificates: single-spaced
#let pitch-heading = 20pt                  // section headings (16 pt)
#let edges(pitch) = (top-edge: 0.8 * pitch, bottom-edge: -0.2 * pitch)
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let page-margin = 1in                     // CA9-FORM-002
#let para-indent = 0.5in
#let toc-depth = 4
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"

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
  if key not in meta { panic("ca9-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A check box: a ruled box around an "X" when checked, around three spaces' width when not (Word's bordered run,
/// so every engine sets the same text in it).
#let checkbox(checked) = box(
  stroke: 0.6pt, inset: (x: 1pt), outset: (y: 1.5pt),
  if checked [X] else { h(0.75em) },
)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca9-brief: the sample must start with a YAML frontmatter block") }
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

/// 11622 -> "11,622"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")      // footnote definition labels
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")             // footnote references
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")   // list markers are not words
  s = s.replace(regex("\\\\(.)"), keep)                    // backslash escapes
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)   (CA9-CONT-012)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("ca9-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca9-brief: headings deeper than level 5 are not supported") }
  }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = shared-hanging-paragraph(indent, single-leading, body)

/// Left edge of a heading's label. Labels sit half an inch in from the margin; each further
/// level steps in half an inch more. In the Argument the level-2 point heading is centered, so
/// its sub-headings start at the first step.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 3 } else { 2 }
  (h.level - first + 1) * heading-tab
}

// Spacing above and below each kind of block, in points (the larger of below/above applies between two blocks).
#let space = (
  section: (above: 21pt, below: 15.4pt),
  point: (above: 16.8pt, below: 14pt),
  sub: (above: 15.4pt, below: 12.6pt),
  plain: (above: 16.8pt, below: 12.6pt),
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, justify: false)
  set text(size: type-size, ..edges(pitch-single))   // typst's built-in heading sizes are not used
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, ..space.section,
      align(center, text(size: heading-size, ..edges(pitch-heading), strong(upper(it.body)))))
  } else if it.numbering == none {
    // Unnumbered sub-headings (addendum entries): bold, left.
    block(width: 100%, sticky: true, ..space.plain, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral. Not small capitals: Times New Roman has none, and Word
    // and LaTeX would synthesize different ones (the engines must set the same glyphs).
    block(width: 100%, sticky: true, ..space.point,
      align(center, strong(heading-label(it) + [ ] + it.body)))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, ..space.sub, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// One row of the table of contents or of authorities: the text wraps before a column of width `col` kept for the
/// page number, and a dot leader runs from the end of the text to the number on the last line (Word's layout: a
/// right indent and a right tab beyond it), at least three spaces after it. Rows are not split across pages.
#let listing-row(target, body, page, col, hang-by, above) = {
  let row = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
    columns: (1fr, col), column-gutter: 0pt,
    par(hanging-indent: hang-by, first-line-indent: 0pt, leading: 0pt, justify: false, {
      body
      h(0.75em)   // the leader is never shorter than three spaces, and it does not leave the last word
      box(width: 1fr, repeat[.])
    }),
    align(right + bottom, page),
  ))
  if target == none { row } else { link(target, row) }
}

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  // The Argument's centered point heading has no body indent in the table; its label starts at the margin.
  if numbered and in-argument(hd.location()) and hd.level == 2 { ind = 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  let lw = if lab == none { 0pt } else { heading-tab }
  listing-row(hd.location(), {
    h(ind)
    if lab != none { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + lw, if hd.level == 1 { 8.4pt } else { 4.9pt })
}

#let toc-section(has-addendum) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, strong(underline[Page])))
  let target = if has-addendum {
    selector(heading.where(outlined: true)).before(<add-start>, inclusive: true)
  } else {
    selector(heading.where(outlined: true))
  }
  show outline.entry: toc-entry
  outline(title: none, target: target, depth: toc-depth, indent: 0pt)
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
    let hits = shared-linked-authorities(authorities, error-prefix: "ca9-brief")
    let first = true
    for (kind, title) in toa-groups {
      let members = shared-cited-authorities(authorities, hits, kind, sort-key)
      if members.len() == 0 { continue }
      block(above: if first { 14pt } else { 19.6pt }, below: 2.8pt, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let page-text = shared-authority-page-labels(hits, key, passim-threshold)
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), 0.35in, 9.8pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); CA9-COVER-001 to -007)
// ---------------------------------------------------------------------------

#let cover-body(meta, gap) = shared-cover-body(meta, gap, single-leading, need, inl)
#let cover(meta) = shared-ca9-cover(meta, single-leading, need, inl, error-prefix: "ca9-brief")
// ---------------------------------------------------------------------------
// Signature, related cases, certificates (Forms 17, 8, 15)
// ---------------------------------------------------------------------------

#let signature-line(meta) = [s/ #need(meta, "signature").signer]

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 3.25in, {   // the right half of the 6.5 in text block
      [Respectfully submitted,]
      v(1.2em)
      signature-line(meta)
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
    if "date" in meta { v(0.8em); meta.date }
  })
}

#let form-sig-line(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading)
  grid(columns: (1fr, 1fr), column-gutter: 1em,
    [#signature-line(meta)\ #text(size: type-size)[Signature]],
    [#meta.at("date", default: "")\ Date])
})

#let option-row(checked, body, indent: 0pt) = block(above: 0.8em, breakable: false, hang(indent + 1.6em, {
  h(indent)
  box(width: 1.6em, checkbox(checked))
  body
}))

/// Statement of Related Cases, Form 17 wording (Circuit Rule 28-2.6; CA9-CERT-003).
#let related-cases(meta) = {
  let rc = meta.at("related_cases", default: (status: "none"))
  let status = rc.at("status", default: "none")
  heading(level: 1, numbering: none)[Statement of Related Cases]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [9th Cir. Case Number(s) #need(meta, "case_number")]
  parbreak()
  [The undersigned attorney or self-represented party states the following:]
  option-row(status == "none", [I am unaware of any related cases currently pending in this court.])
  option-row(status == "other-briefs", [I am unaware of any related cases currently pending in this court other than the case(s) identified in the initial brief(s) filed by the other party or parties.])
  option-row(status == "pending", [I am aware of one or more related cases currently pending in this court. The case number and name of each related case and its relationship to this case are:])
  if status == "pending" {
    for c in rc.cases {
      block(above: 0.7em, breakable: false, hang(3.2em, {
        h(1.6em)
        [No. #c.number, #emph(inl(c.name)) (#inl(c.relationship)).]
      }))
    }
  }
  form-sig-line(meta)
}

#let limit-options = (
  ("standard", [complies with the word limit of Cir. R. 32-1.]),
  ("cross-appeal", [is a cross-appeal brief and complies with the word limit of Cir. R. 28.1-1.]),
  ("amicus", [is an amicus brief and complies with the word limit of FRAP 29(a)(5), Cir. R. 29-2(c)(2), or Cir. R. 29-2(c)(3).]),
  ("death-penalty", [is for a death penalty case and complies with the word limit of Cir. R. 32-4.]),
)

/// Certificate of Compliance, Form 8 wording (Circuit Rule 32-1(e); CA9-CERT-001, -002).
#let certificate-of-compliance(meta, words) = {
  shared-ca9-compliance(meta, words, heading, single-leading, need, group-digits, limit-options, option-row, form-sig-line)
}

/// Certificate of Service, Form 15 wording. Only when `service.certificate: true` (CA9-CERT-004).
#let certificate-of-service(meta) = {
  shared-ca9-service(meta, heading, single-leading, need, inl, form-sig-line)
}

#let toc-addendum() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(level: 2)).after(<add-start>), depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca9-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }
  let words = count-words(body-md)
  let limit = 14000
  if words > limit {
    panic("ca9-brief: the brief has " + str(words) + " words; Circuit Rule 32-1(a) allows " + str(limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // The page number: centered in a single-spaced line box whatever the text around it (Word's footer, LaTeX's
  // plain page style), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // No kerning and no ligatures: Word sets neither by default, and the LaTeX engine turns both off (the three
    // engines must give every word the same width, docs/EVAL-LOOP.md, "Cross-engine gate").
    kerning: false, ligatures: false,
    ..edges(pitch-double),
  )
  // Greedy line breaking (first fit), as Word and LibreOffice break lines; LaTeX is set up to break the same way.
  set par(
    leading: 0pt, spacing: 0pt, linebreaks: "simple",
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // A superscript (a footnote mark) does not make its line taller: its box is the line's own.
  show super: set text(top-edge: "baseline", bottom-edge: "baseline")
  // Footnote marks at 58 % of the type size: LibreOffice's superscript, which the LaTeX engine sets too.
  set super(size: 0.58em)
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(..edges(pitch-single))
    shared-footnote-body(note.body, num, type-size, single-leading, 7pt)
  }
  // Lists: the number (or bullet) in a half-inch box at the margin, the text hanging after it, double-spaced like
  // the body and with no space of their own (Word and LaTeX set the same paragraphs).
  let list-item(lab, body) = block(above: 0pt, below: 0pt,
    par(hanging-indent: para-indent, first-line-indent: 0pt, { box(width: para-indent, lab); body }))
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      list-item(numbering(it.numbering, n), item.body)
      n += 1
    }
  }
  show list: it => for item in it.children { list-item([•], item.body) }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt)
    it.body
  }))
  // Typography that holds for any text: never break inside a token of adjacent parentheses
  // ("60(b)(5)"), and never between a section sign / pilcrow and its number. Done with
  // unbreakable boxes so the extracted text stays exactly the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  { set text(..edges(pitch-single)); cover(meta) }

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    toc-section(add != none)
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
    let text-md = body-md.trim(at: end)
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

  // ---- certificates of counsel ----
  set text(..edges(pitch-single))
  pagebreak(weak: true)
  related-cases(meta)
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }

  // ---- addendum (Circuit Rule 28-2.7) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    { set text(..edges(pitch-single)); toc-addendum() }
    pagebreak()
    set text(..edges(pitch-double))
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
