// U.S. Court of Appeals for the Federal Circuit: answering brief (brief for the appellee).
//
// Rule-driven and content-agnostic. Rule references (CAFC-...) are in ../README.md.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks
// in the template. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").
// Structure copied from courts/ninth-circuit/court-of-appeals/typst/ca9-brief.typ.

#import "@preview/cmarker:0.1.10"
#import "../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // FRAP 32(a)(5)(A): proportionally spaced serif. Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, everywhere.
#let body-leading = 0.99em                 // with the metric-aligned line box, a baseline pitch of about
                                           // 2.2 x type size (double spacing). Checked against the exemplar in README.md.
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA, certificates: single-spaced.
#let page-margin = 1in                     // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let word-limit = 14000                    // Fed. Cir. R. 32(b) principal-brief type-volume limit (see README: not yet verified at the primary source)

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
  if key not in meta { panic("cafc-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cafc-brief: the sample must start with a YAML frontmatter block") }
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

/// Printed label of a numbered heading: I. / A. / 1. / a. / (1), one per level.
/// Level 1 is a section (Statement of the Issue, ..., Argument, Conclusion), as in the exemplar.
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if h.level == 1 { numbering("I.", n) }
  else if h.level == 2 { numbering("A.", n) }
  else if h.level == 3 { numbering("1.", n) }
  else if h.level == 4 { numbering("a.", n) }
  else if h.level == 5 { numbering("(1)", n) }
  else { panic("cafc-brief: headings deeper than level 5 are not supported") }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. Level 1 sits at the margin; each further level steps in half an inch.
#let label-indent(h) = (h.level - 1) * heading-tab

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // typst's built-in heading sizes are not used; every heading is body size or larger
  if it.numbering == none and it.level == 1 {
    // Front-matter and certificate headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Numbered headings: the label sits in a fixed box and the text hangs under the text.
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level == 1 { strong(upper(it.body)) }
      else if it.level >= 4 { strong(emph(it.body)) }
      else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none
  let ind = if numbered { label-indent(hd) } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    leader-row({
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      hd.body
    }, it.page(), hang: ind + heading-tab, leading: single-leading, lead-gap: 0.8em, page-width: 2.6em, gutter: 0pt)))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
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
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cafc-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, leader-row({
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, hang: 0.35in, leading: single-leading, lead-gap: 0.8em, dot-gap: 0.16em))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); Fed. Cir. R. 32 cover contents)
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[#need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong[UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT]
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
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number).
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        // One line per name and per address line; a line too long for the column wraps under its own indent.
        for n in g.names { block(spacing: single-leading, n) }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { block(spacing: single-leading, inset: (left: 0.5em), inl(l)) }
      })
    }
  }))
  if "date" in meta {
    v(gap)
    align(left, pad(left: 50%, meta.date))
  }
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("cafc-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

/// Exemplary patent claims (Fed. Cir. R. 32(a)(3)): when the language of a patent or patent
/// application is at issue, each principal brief carries one or more illustrative claims inside
/// the front cover, or immediately after it when the text needs more room. Electronic filings
/// have no inside cover, so the claims take their own unnumbered page(s) right after the cover.
/// The text may be single-spaced. Only when the frontmatter has `patent_claims`.
#let patent-claims-page(meta) = if "patent_claims" in meta {
  page(numbering: none, footer: none, {
    heading(level: 1, numbering: none, outlined: false, meta.at("patent_claims_heading", default: "Exemplary Patent Claims"))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
    for p in meta.patent_claims { inl(p); parbreak() }
  })
}

// ---------------------------------------------------------------------------
// Signature, related statement, certificates
// ---------------------------------------------------------------------------

/// Signature block after the Conclusion. Dated line, then "Respectfully submitted," and the /s/ line.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if "date" in meta { [Dated: #meta.date]; parbreak() }
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      [/s/ #sig.signer]
      for l in sig.at("lines", default: ()) { linebreak(); inl(l) }
    }))
  })
}

/// Signature under a certificate: the /s/ line, the signer's name in capitals, and the certificate lines.
#let certificate-signature(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sig = need(meta, "signature")
  align(left, pad(left: 50%, {
    [/s/ #sig.signer]
    linebreak()
    upper(sig.signer)
    for l in sig.at("certificate_lines", default: ()) { linebreak(); inl(l) }
  }))
})

/// Statement of Related Cases. The text is supplied by the sample (Fed. Cir. R. 47.5 is not
/// generated from a form here: the court's own form language is the sample's business, not the template's).
#let related-statement(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Statement of Related Cases]
  for p in need(meta, "related_statement") { inl(p); parbreak() }
}

/// Certificate of Compliance: word count under Fed. Cir. R. 32(b) and the typeface and type style under FRAP 32(a)(5)-(6).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I certify that this brief complies with the type-volume limitation of Fed. Cir. R. 32(b). The total number of words in the brief is #group-digits(words), as calculated by #meta.at("word_counter", default: "the word-processing system used to prepare it").]
  parbreak()
  [The brief’s typeface and type style comply with FRAP 32(a)(5) and (6).]
  certificate-signature(meta)
}

/// Certificate of Service. Only when `service.certificate: true`.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I certify that on #meta.at("date", default: "the date of filing") I electronically filed the foregoing brief with the Clerk of Court using the CM/ECF system, which will send notice of the filing to all counsel of record.]
  certificate-signature(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let cafc-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "related_statement") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- word count (Fed. Cir. R. 32(b)) ----
  let words = count-words(md)
  if words > word-limit {
    panic("cafc-brief: the brief has " + str(words) + " words; Fed. Cir. R. 32(b) allows " + str(word-limit))
  }

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
    set text(size: type-size)   // typst's default is 0.85em; FRAP 32(a)(5) allows nothing under 14 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
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
  cover(meta)
  patent-claims-page(meta)

  // ---- front matter (lowercase roman): contents, authorities, related cases ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()
  related-statement(meta)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
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

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
