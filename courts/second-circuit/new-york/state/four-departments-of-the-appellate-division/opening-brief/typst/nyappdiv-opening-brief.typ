// Appellate Division, Fourth Judicial Department: brief for the appellant (doc type set below).
//
// Rule-driven and content-agnostic. Rule IDs (CPLR 5529, 22 NYCRR 1250.8, 22 NYCRR Part 1000) refer to
// ../README.md. No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that differs between the copies of this template)
// ---------------------------------------------------------------------------

#let doc-kind = "opening-brief"
#let court-lines = (
  "SUPREME COURT OF THE STATE OF NEW YORK",
  "APPELLATE DIVISION",
  "FOURTH JUDICIAL DEPARTMENT",
)
#let word-limit = 14000                     // 22 NYCRR 1250.8(f)(2): appellant's computer-generated brief.
#let footnotes-allowed = false              // Part 1000: "A brief shall contain no footnotes" (secondary source; see README).
#let required-sections = (                  // 22 NYCRR 1250.8(b)(3)-(5), in this order (regexes on lowercased titles).
  "^statement of (the )?questions",
  "^statement of (the )?(nature of the )?(case|facts)",  // exemplar heading: "STATEMENT OF FACTS" (see usage/SOURCE.md)
  "^argument$",
  "^conclusion$",
)

// ---------------------------------------------------------------------------
// Parameters (every number traces to a rule or to a style choice noted beside it)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")            // Times New Roman substitute per docs/FONTS.md, vendored in /fonts; no system font is used.
#let type-size = 14pt                       // Style choice above the 11-point floor in secondary sources (README).
#let body-leading = 1.345em                 // Gap between lines; set so the baseline pitch is about double spacing (README, measured).
#let single-leading = 0.65em                // Headings, block quotations, table entries: single-spaced (Typst's default leading, so two-line headings do not crowd).
#let page-margin = 1in                      // Style choice; the rules leave margins open (README).
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                   // An authority cited on this many pages or more prints "passim".

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
  if key not in meta { panic("nyappdiv-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyappdiv-brief: the sample must start with a YAML frontmatter block") }
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

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Headings count (22 NYCRR 1250.8(f)(2): inclusive of point headings). Markup is removed first; links keep their text.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")
  s = s.replace(regex("\\\\(.)"), keep)
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading. Argument: POINT I, A., 1., a. Elsewhere: A., 1., a., (1).
#let heading-label(h) = {
  let loc = h.location()
  let n = counter(heading).at(loc).at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { "POINT " + numbering("I", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("nyappdiv-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("nyappdiv-brief: headings deeper than level 5 are not supported") }
  }
}

/// A single-spaced paragraph whose continuation lines hang under the text.
/// (An explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.4em, below: 1.1em, align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: label on one line, the point itself centered below, both bold.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em, {
      align(center, strong(heading-label(it)))
      v(0.2em)
      align(center, strong(it.body))
    })
  } else {
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, pad(left: ind, hang(heading-tab, {
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    })))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(ind + heading-tab + 0.5em, {
      h(ind)
      if numbered and hd.level == 2 and in-argument(hd.location()) { box(lab); h(0.6em) }
      else if numbered { box(width: heading-tab, lab) }
      title
      h(0.6em)
      dot-leader
      box(width: 2.2em, align(right, it.page()))
    })))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("constitution", "Constitutional Provisions"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))

#let toa-entry(key, a) = context {
  // Pages on which the key is cited in the body (links `[...](toa:KEY)`).
  let hits = query(<toa-cite>).filter(e => e.value.key == key)
  // Printed page labels (the body restarts at 1 after the roman front matter), not physical PDF pages.
  let pages = ()
  for e in hits {
    let loc = e.location()
    let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
    if label not in pages { pages.push(label) }
  }
  // 1250.8(b)(2): every listed authority shows the pages where it is cited; an entry no link reaches is an error.
  if pages.len() == 0 { panic("nyappdiv-brief: authority `" + key + "` is listed but never cited with a `toa:` link") }
  let p = if pages.len() >= passim-threshold { "passim" } else { pages.map(str).join(", ") }
  let label = if a.at("kind", default: "") == "case" and "name" in a {
    inl("*" + a.name + "*, " + a.cite)
  } else if "name" in a {
    inl(a.name + ", " + a.cite)
  } else {
    inl(a.cite)
  }
  block(width: 100%, above: 0.45em, below: 0pt, hang(0.3in, {
    label
    h(0.6em)
    dot-leader
    box(width: 2.6em, align(right, p))
  }))
}

#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page(s)])))
  for (kind, title) in toa-groups {
    let keys = authorities.keys().filter(k => authorities.at(k).at("kind", default: "other") == kind)
    if keys.len() == 0 { continue }
    let sorted = keys.sorted(key: k => sort-key(authorities.at(k)))
    block(above: 1.1em, below: 0.4em, sticky: true, strong(title))
    for k in sorted { toa-entry(k, authorities.at(k)) }
  }
}

// ---------------------------------------------------------------------------
// Cover (22 NYCRR 1250.8: the printing statement and the court's form govern the rest; layout is convention)
// ---------------------------------------------------------------------------

#let caption-block(caption) = {
  for (i, side) in caption.enumerate() {
    if i > 0 { align(center, "-against-"); v(0.6em) }
    for n in side.names { align(center, inl(n)) }
    align(center, inl(side.designation))
    v(0.4em)
  }
}

#let cover(meta) = {
  set page(numbering: none)
  // The cover is not brief text, so it is single-spaced (1250.8(h) double-spaces the text); it must fit one page.
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  set block(spacing: single-leading)
  // 22 NYCRR 1250.8(a): the upper right-hand section states whether the cause is argued or submitted,
  // and if argued, the time required and the attorney who will argue. The docket sits on the left of that row.
  let arg = need(meta, "argument")
  grid(columns: (1fr, auto), column-gutter: 0.3in,
    strong(need(meta, "docket")),
    block({
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      if "presenter" in arg {
        [To be argued by:]
        linebreak()
        strong(inl(arg.presenter))
        linebreak()
        [Time requested: #arg.time_requested]
      } else {
        [Submitted]
      }
    }))
  v(0.6em)
  for l in court-lines { align(center, strong(l)) }
  v(1.2em)
  align(center, block(width: 85%, caption-block(need(meta, "caption"))))
  v(1em)
  if "index_number" in meta { align(right, meta.index_number) }
  v(1em)
  align(center, block(width: 90%, inl(need(meta, "proceeding"))))
  v(2.5em)
  align(center, strong(upper(need(meta, "brief_title"))))
  v(1fr)
  let counsel-groups = need(meta, "counsel")
  align(right, block(width: 62%, {
    for (gi, g) in counsel-groups.enumerate() {
      if gi > 0 { v(0.8em) }
      for n in g.names { align(left, strong(n)) }
      for l in g.at("lines", default: ()) { align(left, inl(l)) }
    }
    // 1250.8(a): the lower right-hand section gives the filing attorney's telephone number and email address.
    align(left, need(meta, "phone"))
    align(left, need(meta, "email"))
  }))
  v(1.2em)
  align(left, need(meta, "date"))
  // Keeps the last line's descenders inside the 1 in bottom margin (NY-FORM-001).
  v(0.3em)
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nyappdiv-brief(meta, md) = {
  let words = count-words(md)
  if words > word-limit {
    panic("nyappdiv-brief: " + str(words) + " words; 22 NYCRR 1250.8(f)(2) limits this brief to " + str(word-limit))
  }
  let titles = md.matches(regex("(?m)^#[ \t]+([^\n]+)$")).map(m => lower(m.captures.at(0)).trim())
  let found = ()
  for pat in required-sections {
    let r = regex(pat)
    let hit = titles.position(t => t.match(r) != none)
    if hit == none { panic("nyappdiv-brief: no section matching " + pat + " (22 NYCRR 1250.8(b))") }
    found.push(hit)
  }
  for i in range(1, found.len()) {
    if found.at(i) < found.at(i - 1) { panic("nyappdiv-brief: sections are out of the order in 22 NYCRR 1250.8(b)") }
  }
  let authorities = need(meta, "authorities")
  let counsel-groups = need(meta, "counsel")

  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, justify: false, first-line-indent: para-indent)
  set heading(numbering: "1.")
  show heading: style-heading
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(above: 0.8em, below: 1.1em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  }))
  show footnote: it => {
    if footnotes-allowed { it } else { panic("nyappdiv-brief: footnotes are not allowed (22 NYCRR Part 1000; see README)") }
  }
  // Every `[text](toa:KEY)` is recorded with the page where it starts (a tag before the text, so no stray space);
  // an unknown key stops the build.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in authorities { panic("nyappdiv-brief: toa key `" + key + "` is not in authorities:") }
      [#metadata((key: key))<toa-cite>#it.body]
    } else { it }
  }

  cover(meta)
  pagebreak()

  // Front matter is numbered in lowercase roman from i (TOC, TOA); the body restarts at 1.
  // The exemplar settles this (see usage/SOURCE.md, "What the exemplar shows").
  counter(page).update(1)
  set page(numbering: "i", number-align: center + bottom)
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()
  counter(page).update(1)
  set page(numbering: "1", number-align: center + bottom)

  // Body: the sample's own sections (cmarker renders the markdown). The conclusion is set in
  // one unbreakable block with the signature, so the signature never stands alone on a page.
  let conclusion-at = md.matches(regex("(?im)^#[ \t]+conclusion[ \t]*$")).first().start
  cmarker.render(md.slice(0, conclusion-at), raw-typst: false, smart-punctuation: true)

  // Signature block (22 NYCRR 1250.8(b)(5)-(6) follows the argument; the signature is conventional).
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, {
    cmarker.render(md.slice(conclusion-at), raw-typst: false, smart-punctuation: true)
    v(1.2em)
    align(right, block(width: 55%, {
      [Respectfully submitted,]
      v(1.2em)
      align(left, strong("s/ " + upper(sig.signer)))
      for l in sig.at("lines", default: ()) { align(left, inl(l)) }
      if "date" in meta { v(0.6em); align(left, meta.date) }
    }))
  })

  // Printing specifications statement: last thing in the brief (22 NYCRR 1250.8(b)(6), (j)).
  pagebreak()
  heading(level: 1, numbering: none, outlined: false)[Printing Specifications Statement]
  set par(first-line-indent: para-indent)
  [This brief was prepared on a computer. The typeface is #font-family.first(), #int(type-size.pt()) point. The body text is double-spaced. Headings, block quotations, and the tables are single-spaced. The brief contains #group-digits(words) words, exclusive of the cover, the tables, the signature block, and any certificate of service, as counted by the word-processing system used to prepare it (22 NYCRR 1250.8(f)(2), (j)).]
  v(0.6em)
  [Signed under 22 NYCRR 130-1.1-a(a), which is also the signer's representation that this statement is accurate.]
  v(1em)
  set par(first-line-indent: 0pt)
  align(left, strong("s/ " + upper(sig.signer)))
  for l in sig.at("lines", default: ()) { align(left, inl(l)) }
}
