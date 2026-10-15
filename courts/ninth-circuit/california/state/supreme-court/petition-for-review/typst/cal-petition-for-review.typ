// California Supreme Court: petition for review.
//
// Rule-driven and content-agnostic. Requirement IDs (CAL-...) refer to ../README.md, which
// cites the Cal. Rules of Court (rules 8.504, 8.204, 8.74, 8.25). No case-specific text, no
// coordinates measured off any filed petition, no forced line breaks. The markdown body is
// rendered by cmarker; the metadata comes from the YAML frontmatter of the same file
// (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"      // CAL-FONT-001: proportionally spaced serif, Century Schoolbook preferred (rule 8.74(b)(1)). Substitute per docs/FONTS.md. Vendored in /fonts.
#let font-named = "Century Schoolbook"    // the face the rule names; the certificate states it (Schola is a Century Schoolbook clone).
#let type-size = 13pt                      // CAL-FONT-002: 13-point or larger, footnotes included (rules 8.204(b)(4), 8.74(b)(1)).
#let body-leading = 0.94em                 // CAL-SPACE-001: double-spaced text, as the filed exemplar is. Rule 8.204(b)(5) asks for 1.5.
#let single-leading = 0.12em               // headings, quotations, footnotes, tables, certificates: single-spaced (rule 8.204(b)(5)).
#let margin-x = 1.5in                      // CAL-MARGIN-001: left and right (rules 8.204(b)(6), 8.74(b)(3)).
#let margin-y = 1in                        // CAL-MARGIN-001: top and bottom.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim"
#let word-limit = 8400                     // CAL-LENGTH-001: rule 8.504(d)(1), computer-prepared petition, footnotes included.

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
  if key not in meta { panic("cal-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cal-petition: the sample must start with a YAML frontmatter block") }
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

/// 14000 -> "14,000"
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
/// Markup characters are removed first; links keep their text; footnote text is counted.
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
// Headings: numbering scheme and styles (CAL-CONT-001)
// ---------------------------------------------------------------------------

/// I. / A. / 1. / a. / (1), by level. Roman numerals mark the sections (Issues, Introduction, ...).
#let heading-number(..n) = {
  let k = n.pos().last()
  let lvl = n.pos().len()
  if lvl == 1 { numbering("I.", k) }
  else if lvl == 2 { numbering("A.", k) }
  else if lvl == 3 { numbering("1.", k) }
  else if lvl == 4 { numbering("a.", k) }
  else if lvl == 5 { numbering("(1)", k) }
  else { panic("cal-petition: headings deeper than level 5 are not supported") }
}

/// Printed label of a numbered heading.
#let heading-label(h) = numbering(heading-number, ..counter(heading).at(h.location()))

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold capitals, centered. A numbered section keeps its Roman numeral.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em, align(center,
      if it.numbering == none { strong(upper(it.body)) }
      else { strong[#heading-label(it) #upper(it.body)] }))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Sub-headings: the label sits in a fixed box, the text hangs under itself, bold.
    let ind = (it.level - 1) * heading-tab
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(heading-label(it)))
      strong(it.body)
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CAL-TOC-001, CAL-TOA-001)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from an outline entry. Wrapped lines hang under the title.
#let toc-entry(it) = {
  let hd = it.element
  // Narrower steps than the body's: a deep entry must keep room for its page number on its first line.
  let ind = if hd.level >= 2 { (hd.level - 1) * 0.35in } else { 0pt }
  let lab = if hd.numbering != none { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.7em } else { 0.4em }, below: 0pt,
    hang(ind + heading-tab, {
      h(ind)
      if lab != none { box(width: heading-tab, lab) }
      title
      h(0.3em)
      dot-leader
      h(0.3em)
      box(width: 0.9em, align(right, it.page()))
    })))
}

/// Contents: every outlined heading from the Issues to the certificates (the front matter and
/// certificates are not listed).
#let toc-section() = {
  heading(level: 1, numbering: none)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(
    title: none,
    target: selector(heading.where(outlined: true)).after(<body-start>).before(<certs-start>),
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

#let sort-key(a) = {
  let s = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
  s.replace(regex("[^a-z0-9 ]"), "")
}

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cal-petition: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        // Distinct printed page numbers, in document order.
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
// Cover (rules 8.504(b)(7), 8.74(a)(9), 8.74(c)(1); CAL-COVER-001 to -005)
// ---------------------------------------------------------------------------

#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[No. #meta.at("supreme_court_case", default: "S__________")]
  v(gap)
  // Fixed court heading for this document type (not case text).
  [In the Supreme Court of the State of California]
  v(gap)
  short-rule
  v(gap)
  // Title and designation of the parties: identical to the Court of Appeal opinion (rule 8.504(b)(7)).
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    block(width: 100%, align(right, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  // Court below: the Court of Appeal and trial court numbers and judge (rule 8.74(c)(1)).
  inl(need(meta, "court_of_appeal"))
  parbreak()
  inl(need(meta, "trial_court"))
  if "judge" in meta {
    parbreak()
    inl(meta.judge)
  }
  v(gap)
  short-rule
  v(gap)
  strong[PETITION FOR REVIEW]
  v(gap)
  short-rule
  v(gap)
  // Attorneys filing the petition: name, State Bar number, address, telephone (rule 8.74(a)(9)).
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { inl(n); linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { h(0.5em); emph(inl(l)); linebreak() }
      })
    }
  }))
  v(gap)
  align(left, need(meta, "date"))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  // Bookmark for the first page of the petition (rule 8.74(a)(3)); placed, so it takes no room and prints nothing.
  place(top + left, hide(heading(level: 1, numbering: none)[Petition for Review]))
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("cal-petition: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature, certificates, proof of service (CAL-CERT-001 to -003)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Dated: #need(meta, "date")]
    v(1.2em)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      [/s/ #sig.signer]
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
  })
}

/// Certificate of compliance: font and word count (rule 8.504(d)(1), rule 8.204(c)(1)).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I certify that the attached PETITION FOR REVIEW uses a 13-point #font-named font and contains #group-digits(words) words.]
  signature-block(meta)
}

/// Proof of service (rule 8.25(a)): each party and court served, the manner of service.
#let proof-of-service(meta) = {
  heading(level: 1, numbering: none)[Proof of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I certify that the foregoing PETITION FOR REVIEW was electronically served on the following interested parties on #need(meta, "date"), in the manner described.]
  for s in need(meta, "service") {
    block(above: 0.9em, breakable: false, pad(left: 0.5in, {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
      inl(s.party)
      for n in s.at("names", default: ()) { linebreak(); inl(n) }
      for l in s.at("lines", default: ()) { linebreak(); inl(l) }
      linebreak()
      [#s.method]
    }))
  }
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// The petition
// ---------------------------------------------------------------------------

#let cal-petition(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("caption", "court_of_appeal", "trial_court", "counsel", "phone", "signature", "date", "service") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- rule 8.504(b)(1): the body opens with a concise statement of the issues presented ----
  let opening = md.trim(at: start)
  let first-heading = opening.match(regex("^#[ \t]+(.*)"))
  if first-heading == none or not lower(first-heading.captures.at(0)).contains("issue") {
    panic("cal-petition: the body must open with the statement of issues presented (rule 8.504(b)(1))")
  }
  if md.match(regex("(?mi)^#[ \t]+conclusion[ \t]*$")) == none {
    panic("cal-petition: the body needs a Conclusion heading")
  }

  // ---- rule 8.504(d)(1): length, footnotes included; the tables and certificates are not counted ----
  let words = count-words(md)
  if words > word-limit {
    panic("cal-petition: the petition has " + str(words) + " words; rule 8.504(d)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: "Petition for Review, " + meta.at("supreme_court_case", default: "S__________"),
    author: need(meta, "signature").signer,
  )
  set page(
    paper: "us-letter", margin: (x: margin-x, y: margin-y),
    numbering: "1", number-align: center, footer-descent: 30%,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-number)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)   // typst's default is 0.85em; rule 8.204(b)(4) allows nothing under 13 pt
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
  // Never break inside a token of adjacent parentheses ("60(b)(5)"), and never between a section
  // sign / pilcrow and its number. Unbreakable boxes keep the extracted text the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (page 1; its number is not printed) ----
  cover(meta)

  // ---- contents and authorities (pages 2 on; the same arabic sequence as the body) ----
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // ---- body ----
  [#metadata("body-start") <body-start>]
  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature-block(meta)

  // ---- certificates and proof of service (rules 8.504(d)(1), 8.25(a)) ----
  pagebreak(weak: true)
  [#metadata("certs-start") <certs-start>]
  certificate-of-compliance(meta, words)
  pagebreak(weak: true)
  proof-of-service(meta)
}
