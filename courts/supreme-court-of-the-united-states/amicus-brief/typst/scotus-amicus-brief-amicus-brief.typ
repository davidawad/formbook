// Supreme Court of the United States: amicus curiae brief on the merits (booklet format).
//
// Rule-driven and content-agnostic. Rule references are to the Rules of the Supreme Court of the
// United States: Rule 33.1 (booklet format, word limits, cover), Rule 34 (cover contents), Rule 37
// (amicus briefs). The word limits and cover colors come from the booklet-format chart effective
// March 16, 2026. No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule)
// ---------------------------------------------------------------------------

// Rule 33.1(a): 6 1/8 by 9 1/4 inch booklet.
#let page-w = 6.125in
#let page-h = 9.25in
// Rule 33.1(c): the text field, footnotes included, may not exceed 4 1/8 by 7 1/8 inches;
// margins are at least 3/4 inch on every side.
#let text-w = 4.125in
#let text-h = 7.125in
#let margin-x = (page-w - text-w) / 2
#let margin-top = 1in
#let margin-bottom = page-h - text-h - margin-top
#let margin-min = 0.75in
#assert(
  margin-x >= margin-min and margin-top >= margin-min and margin-bottom >= margin-min,
  message: "scotus-amicus-brief: Rule 33.1(c) margins must be at least 3/4 inch",
)
// Rule 33.1(b): Century family, 12-point, with 2-point or more leading between lines.
// Face: TeX Gyre Schola, the vendored Century-family substitute named in docs/FONTS.md.
#let font-family = "TeX Gyre Schola"
#let type-size = 12pt
// Line box fixed at 1em (top-edge + bottom-edge), so the baseline pitch is 1em + leading (12 + 2 = 14pt)
// and does not depend on the face's own ascent and descent. Same as the cert-petition template.
#let line-box = (top-edge: 0.75em, bottom-edge: -0.25em)
#let leading = 2pt
// Rule 33.1(b): footnotes 10-point, with 2-point or more leading.
#let footnote-size = 10pt
// Rule 34.1(g): the cover may not be set smaller than 11-point (counsel identification excepted).
#let cover-size = 12pt
#let para-indent = 0.4in
#let label-tab = 0.4in
// Rule 33.1(g), booklet-format chart effective March 16, 2026:
//   government amicus in Rule 37.6 class, on the merits: 9,000 words; any other amicus: 8,000 words.
#let word-limits = (government: 9000, other: 8000)
// Authority cited on this many pages or more is listed as "passim".
#let passim-threshold = 6

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("scotus-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scotus-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
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

/// Word count of markdown source, whitespace-delimited like a word processor (Rule 33.1(d)).
/// Markup is removed first; links keep their text; footnote definitions are not counted.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")       // footnote labels; the note text stays (Rule 33.1(d): footnotes count)
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")               // footnote references
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")
  s = s.replace(regex("\\\\(.)"), keep)
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// Plain text of a string, for sorting and comparisons only.
#let plain-key(s) = s.replace("*", "").replace("“", "").replace("”", "")

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles (Argument points I., A., 1., a.)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", level 3 "A.", level 4 "1.", level 5 "a.".
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("scotus-amicus-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose wrapped lines hang at `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, leading: leading, justify: false)
  if it.level == 1 {
    // Section headings: bold capitals, centered (Introduction, Summary, Argument, Conclusion).
    block(width: 100%, sticky: true, above: 1.4em, below: 1em,
      align(center, strong(upper(it.body))))
  } else {
    // Point and sub-point headings: label in a fixed box, text hangs under the text.
    let ind = (it.level - 2) * label-tab
    block(width: 100%, sticky: true, above: 1em, below: 0.9em, pad(left: ind,
      hang(label-tab, [#box(width: label-tab, strong(heading-label(it)))#strong(it.body)])))
  }
}

// ---------------------------------------------------------------------------
// Cover (Rule 34.1)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set align(center)
  set text(size: cover-size)
  set par(leading: leading, justify: false, first-line-indent: 0pt)
  // The cover lines are blocks; their default spacing would push the counsel block onto page 2.
  set block(spacing: 0.3em)
  // (a) the docket number at the top of the cover
  align(left)[No. #need(meta, "case_number")]
  v(0.4in)
  // (b) the name of this Court
  block(text(size: 1.1em)[In the])
  block(strong(upper[Supreme Court of the United States]))
  v(0.25in)
  // (c) the caption
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 {
      v(0.6em)
      block[v.]
      v(0.6em)
    }
    for n in side.names { block(inl(n)) }
    block(inl(side.designation))
  }
  v(0.25in)
  // (d) the nature of the proceeding and the court below
  block(inl(need(meta, "proceeding")))
  v(0.25in)
  // (e) the title of the document; it also identifies the party supported (Rule 37.2, 37.3)
  block(strong(upper(inl(need(meta, "brief_title")))))
  v(1fr)
  // (f) counsel: the counsel of record is identified with the notation directly under the name
  for (i, g) in need(meta, "counsel").enumerate() {
    for n in g.names { block(inl(n)) }
    if "role" in g { block(emph(g.role)) }
    for l in g.lines { block(inl(l)) }
    if i == 0 { block(inl(need(meta, "phone"))) }
    v(0.9em)
  }
  block(emph(need(meta, "counsel_role")))
  v(0.9em)
  block(inl(need(meta, "date")))
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row for a heading (levels 1 to 3). Page numbers are the body's own numbers.
#let toc-row(h) = {
  let pg = counter(page).at(h.location()).first()
  let ind = if h.level == 1 { 0pt } else { (h.level - 2) * label-tab }
  let lab = if h.level == 1 { [] } else { heading-label(h) }
  let title = if h.level == 1 { upper(h.body) } else { h.body }
  pad(left: ind, hang(if h.level == 1 { 0pt } else { label-tab }, [
    #box(width: if h.level == 1 { 0pt } else { label-tab }, lab)#title #dot-leader #pg
  ]))
  v(0.5em, weak: true)
}

/// The authorities of one kind with their pages, from the labels placed by the body's show rule.
#let toa-section(title, kind, auth) = {
  let items = auth.pairs().filter(p => p.last().kind == kind)
  if items.len() == 0 { return }
  block(strong(title), above: 1.1em, below: 0.7em)
  let cited = query(<toa-cite>)
  for (key, a) in items.sorted(key: p => plain-key(p.last().name)) {
    let pages = cited.filter(e => e.value == key)
      .map(e => counter(page).at(e.location()).first())
      .dedup()
      .sorted()
    // A table of authorities lists cited authorities only: an uncited registry entry is an error.
    if pages.len() == 0 { panic("scotus-amicus-brief: authority `" + key + "` is listed but not cited in the body") }
    let where = if pages.len() >= passim-threshold { "passim" } else { pages.map(str).join(", ") }
    let entry = if a.cite == "" { inl(a.name) } else { [#inl(a.name), #inl(a.cite)] }
    pad(left: 0pt, hang(label-tab, [#entry #dot-leader #where]))
    v(0.6em, weak: true)
  }
}

// ---------------------------------------------------------------------------
// Signature block (after the Conclusion; Rule 34.3) and certificate (Rule 33.1(h))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, {
    v(1.2em)
    block(par(first-line-indent: 0pt, [Respectfully submitted,]))
    v(1.6em)
    block(strong(upper(inl(sig.signer))))
    for l in sig.lines { block(inl(l)) }
    v(0.6em)
    block(inl(need(meta, "date")))
  })
}

#let certificate(meta, words, limit) = {
  set par(leading: leading, justify: false, first-line-indent: 0pt)
  align(center, strong[CERTIFICATE OF COMPLIANCE])
  v(1.2em)
  let kind = if need(meta, "amicus_class") == "government" {
    "an amicus curiae identified in Rule 37.6"
  } else {
    "any other amicus curiae"
  }
  [Pursuant to Rule 33.1(h), I certify that the attached brief complies with the word limitation of Rule 33.1(g). It contains #group-digits(words) words, excluding the items listed in Rule 33.1(d). The limit for #kind is #group-digits(limit) words.]
  v(1.2em)
  block(breakable: false, {
    block(strong(upper(inl(need(meta, "signature").signer))))
    for l in need(meta, "signature").lines { block(inl(l)) }
    v(0.6em)
    block(inl(need(meta, "date")))
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let scotus-amicus-brief(meta, body) = {
  let auth = meta.at("authorities", default: (:))
  let words = count-words(body)
  let limit = if need(meta, "amicus_class") == "government" { word-limits.government } else { word-limits.other }
  if words > limit {
    panic("scotus-amicus-brief: the body has " + str(words) + " words; Rule 33.1(g) allows " + str(limit))
  }
  // Cited authorities are labelled in the body text, so the table of authorities can list pages.
  // A regex that never matches stands in when the sample cites nothing.
  let pattern = if auth.len() > 0 { auth.values().map(a => a.match).join("|") } else { "\\b\\B" }
  let key-for(txt) = {
    for (k, a) in auth {
      if txt.find(regex(a.match)) != none { return k }
    }
    none
  }

  set page(
    width: page-w, height: page-h,
    margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x),
    numbering: none, footer: none,
  )
  set text(font: font-family, size: type-size, lang: "en", ..line-box)
  set par(leading: leading, justify: false, first-line-indent: para-indent, spacing: 1em)
  show footnote.entry: it => {
    set par(first-line-indent: 0pt, leading: leading)
    set text(size: footnote-size)
    it
  }
  show quote.where(block: true): it => pad(left: para-indent, right: para-indent, it)
  // Headings are numbered by our own labels (heading-label). A numbering that prints nothing is set
  // only so that typst advances the heading counter on every level (it does not count unnumbered headings).
  set heading(numbering: (..n) => "")
  show heading: style-heading

  // Cover: no page number.
  cover(meta)
  pagebreak()

  // Front matter: lower-case roman, from the table of contents to the table of authorities.
  set page(numbering: "i", footer: context align(center, counter(page).display()))
  counter(page).update(1)
  align(center, strong[TABLE OF CONTENTS])
  v(1em)
  context {
    for h in query(heading) {
      if h.level <= 3 { toc-row(h) }
    }
  }
  pagebreak()
  align(center, strong[TABLE OF AUTHORITIES])
  v(1em)
  context {
    toa-section("Cases", "case", auth)
    toa-section("Statutes", "statute", auth)
    toa-section("Regulations", "regulation", auth)
    toa-section("Other Authorities", "other", auth)
  }
  pagebreak()

  // Body: arabic, restarting at 1 with the Introduction.
  set page(numbering: "1", footer: context align(center, counter(page).display()))
  counter(page).update(1)
  {
    show regex(pattern): it => {
      let k = key-for(it.text)
      if k == none { it } else { [#it#metadata(k)<toa-cite>] }
    }
    cmarker.render(body, raw-typst: false, smart-punctuation: true)
  }
  signature-block(meta)

  if meta.at("certificate", default: false) {
    // Rule 33.1(h): the certificate accompanies the brief but is separate from it.
    pagebreak()
    set page(numbering: none, footer: none)
    certificate(meta, words, limit)
  }
}
