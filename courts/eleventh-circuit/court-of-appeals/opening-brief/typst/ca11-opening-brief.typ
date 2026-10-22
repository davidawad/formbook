// U.S. Court of Appeals for the Eleventh Circuit: appellant's opening brief.
//
// Rule-driven and content-agnostic. Rule IDs (CA11-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // CA11-FORM-003: serif, proportional; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // CA11-FORM-003: 14-point or larger, everywhere (FRAP 32(a)(5)(A)).
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 31.4pt                 // CA11-FORM-004: double spacing, about 2.24 x type size (11th Cir. R. 32-3).
#let pitch-single = 20pt                   // CA11-FORM-005: quotations, headings, footnotes, cover, signature,
                                           // certificate of service: single-spaced (11th Cir. R. 32-3).
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36.4pt                 // TOC: the page numbers keep the last 2.6 em of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as *4, 6, 8 (a longer list widens its own row's column)
#let page-margin = 1in                     // CA11-FORM-002: at least one inch on all four sides (FRAP 32(a)(4)).
#let para-indent = 0.5in
#let toc-depth = 4
#let word-limit = 13000                    // CA11-LEN-001: FRAP 32(a)(7)(B)(i) principal brief.

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
  if key not in meta { panic("ca11-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca11-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// (Why not in front: when a citation starts a line, a tag placed before the first word can be
/// filed under the previous line, which may be on the previous page.)
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

/// 13000 -> "13,000"
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
// Headings
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("ca11-opening-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca11-opening-brief: headings deeper than level 5 are not supported") }
  }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. Labels sit half an inch in from the margin; each further
/// level steps in half an inch more. In the Argument the level-2 point heading is centered, so
/// its sub-headings start at the first step.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 3 } else { 2 }
  (h.level - first + 1) * heading-tab
}

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size, ..edges(pitch-single))
  if it.level == 1 {
    // Section headings: bold, capitals, centered (CA11-CONT-003).
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold capitals, centered, with the roman numeral.
    block(width: 100%, sticky: true, above: 16.8pt, below: 14pt,
      align(center, strong(upper(heading-label(it) + [ ] + it.body))))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and citations
// ---------------------------------------------------------------------------

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
  // The page number has its own column (listing-row), so a title that fills its last line can never push the number
  // onto a line of its own; the leader runs from the end of the title to the number. The rows are double-spaced
  // (11th Cir. R. 32-3): every line, wrapped ones too, is a box of the body pitch.
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, if hd.level == 1 { 8.4pt } else { 0pt })
}

/// Table of Contents (CA11-CONT-001, 11th Cir. R. 28-1(c)): every outlined heading, with its page.
#let toc-section() = {
  heading(level: 1, numbering: none)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, text(..edges(pitch-single), strong(underline[Page]))))
  show outline.entry: toc-entry
  set text(..edges(pitch-double))
  outline(title: none, target: heading.where(outlined: true), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of Citations (CA11-CONT-002, 11th Cir. R. 28-1(d)), built from the `toa:` links in the body.
/// A link written `toa*:KEY` marks a citation the party primarily relies on; its page carries an
/// asterisk. The table lists every page (never "passim").
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Citations]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value.at("key") not in authorities {
        panic("ca11-opening-brief: link `toa:" + h.value.at("key") + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value.at("key") == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 14pt } else { 19.6pt }, below: 2.8pt, sticky: true, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order; an asterisk marks a page where the
        // authority is one the party primarily relies on.
        let pages = ()
        let primary = ()
        for h in hits.filter(h => h.value.at("key") == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label); primary.push(false) }
          if h.value.at("primary") {
            let i = pages.position(p => p == label)
            primary.at(i) = true
          }
        }
        let page-text = pages.zip(primary).map(((p, s)) => if s { [\*#p] } else { p }).join(", ")
        // One double-spaced row (11th Cir. R. 32-3; listing-row): the citation wraps before the page column, which
        // is as wide as a longer page list.
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
// Cover (11th Cir. R. 28-1(a); FRAP 32(a)(2))
// ---------------------------------------------------------------------------

#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[Case No. #need(meta, "case_number")]
  v(gap)
  strong[In the United States Court of Appeals\ for the Eleventh Circuit]
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: 50%, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))
  if "district_court_case" in meta {
    parbreak()
    inl(meta.district_court_case)
  }
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F), 11th Cir. R. 28-1(a): name, office address, telephone number).
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 7pt)
    let groups = need(meta, "counsel")
    for g in groups {
      block(breakable: false, above: 7pt, below: 7pt, {
        for n in g.names { n; linebreak() }
        for l in g.at("lines", default: ()) { h(0.5em); emph(inl(l)); linebreak() }
        h(0.5em); need(meta, "phone")
      })
    }
  }))
  v(gap * 0.6)
  align(center, emph(inl(need(meta, "role"))))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca11-opening-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Certificate of Interested Persons (11th Cir. R. 26.1-1), statement on oral argument
// ---------------------------------------------------------------------------

#let cip-page(meta) = {
  heading(level: 1, numbering: none)[Certificate of Interested Persons and Corporate Disclosure Statement]
  // Double-spaced (11th Cir. R. 32-3): every line a box of the body pitch, no space of its own between paragraphs.
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  par(inl(need(meta, "cip_intro")))
  // Each entry: its number in a half-inch box at the margin, the text hanging after it.
  for (i, e) in need(meta, "cip").enumerate() {
    par(hanging-indent: 0.5in, { box(width: 0.5in, [#(i + 1).]); inl(e) })
  }
  // A blank line's worth of space before the closing statement (the 1.336 em of the old paragraph spacing).
  block(above: 18.7pt, below: 0pt, par(inl(need(meta, "cip_closing"))))
}

// ---------------------------------------------------------------------------
// Signature, certificates (FRAP 32(g), FRAP 25(d))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    par[Respectfully submitted this #need(meta, "date").]
    block(above: 16.8pt, below: 0pt, align(left, pad(left: 50%, {
      [/s/ #sig.signer]
      linebreak()
      sig.signer
      for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
    })))
  })
}

/// Certificate of Compliance (FRAP 32(g)(1)): the word count is computed from the markdown.
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [Pursuant to Rule 32(g) of the Federal Rules of Appellate Procedure, I certify that the foregoing #strong(upper(inl(need(meta, "brief_title")))) complies with (1) the word limit of Rule 32(a)(7)(B) of the Federal Rules of Appellate Procedure because it contains #group-digits(words) words, which is no more than #group-digits(word-limit), and (2) the typeface and type-style requirements of Rule 32(a)(5) and (6) of the Federal Rules of Appellate Procedure because it has been prepared in a proportionally spaced typeface (#font-family.first()) in #(type-size / 1pt)-point.]
  signature-block(meta)
}

/// Certificate of Service (FRAP 25(d); CM/ECF notice). Only when `service: true`.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [This is to certify that I, #need(meta, "signature").signer, have this day electronically filed the foregoing #strong(upper(inl(need(meta, "brief_title")))) with the Clerk of Court using the CM/ECF system, which will automatically send electronic notification of such filing to counsel of record who are CM/ECF participants:]
  // The service list and the signature stay together on one page: 14 pt (1 em) above the list, 9.8 pt between
  // its entries.
  block(breakable: false, above: 14pt, {
    for (i, s) in need(meta, "service_list").enumerate() {
      block(above: if i == 0 { 0pt } else { 9.8pt }, below: 0pt, pad(left: 0.5in, s.lines.join(", ")))
    }
    signature-block(meta)
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca11-opening-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "role", "date", "signature", "cip_intro", "cip", "cip_closing", "oral_argument") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  let words = count-words(md)
  if words > word-limit {
    panic("ca11-opening-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(i) allows " + str(word-limit))
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
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch (double spacing), footnote marks at 58 %, lists with the number in a half-inch box, a
  // section sign kept with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    // typst's default is 0.85em; FRAP 32(a)(5)(A) allows nothing under 14 pt. Single-spaced.
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 12.6pt)
    it.body
  }))
  show heading: style-heading
  show link: it => {
    let d = it.dest
    if type(d) == str and d.starts-with("toa") {
      let m = d.match(regex("^toa(\\*?):(.+)$"))
      if m == none { return it.body }
      let key = m.captures.at(1)
      let primary = m.captures.at(0) == "*"
      tag-after-first-word(it.body, [#metadata((key: key, primary: primary))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- certificate of interested persons: C-1, C-2 ... (11th Cir. R. 26.1-1) ----
  set page(numbering: (..n) => "C-" + str(n.pos().first()))
  counter(page).update(1)
  cip-page(meta)
  pagebreak()

  // ---- front matter (lowercase roman): oral argument, table of contents, table of citations ----
  set page(numbering: "i")
  counter(page).update(1)
  heading(level: 1, numbering: none)[Statement Regarding Oral Argument]
  par(inl(need(meta, "oral_argument")))
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  // The signature block never stands alone on a page: the brief's last paragraph is kept
  // together with it (unless that last block is a heading or a footnote definition).
  {
    set heading(numbering: "1")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let text-md = md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates (arabic, continuing the body) ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
