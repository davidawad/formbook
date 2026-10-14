// Supreme Court of the United States: petition for a writ of certiorari (doc type `cert-petition`).
//
// Rule-driven and content-agnostic. Requirement IDs (Rule 14, Rule 33.1, Rule 34 ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed petition, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that would differ for another SCOTUS doc type)
// ---------------------------------------------------------------------------

#let doc-kind = "cert-petition"
#let word-limit = 9000                      // Rule 33.1(g)(i): petition for a writ of certiorari, booklet format
#let typeface = "New Century Schoolbook"    // Rule 33.1(b): Century family. NOT VENDORED in fonts/: see README "Blockers".
#let type-size = 12pt                       // Rule 33.1(b): Century 12-point type
#let footnote-size = 10pt                   // Rule 33.1(b): footnotes 10-point
#let cover-size = 11pt                      // Rule 34.1(g): not smaller than 11-point (identification of counsel may be smaller)
#let counsel-size = 10pt                    // Rule 34.1(g): counsel identification
#let leading-pitch = 2pt                    // Rule 33.1(b): 2-point or more leading between lines
// Line box fixed at 1em (top-edge + bottom-edge), so the baseline pitch is 1em + leading and does not
// depend on the font's own ascent and descent: 12-point type on 14-point lines, as the exemplar sets it.
#let line-box = (top-edge: 0.75em, bottom-edge: -0.25em)
#let page-width = 6.125in                   // Rule 33.1(a): 6 1/8 x 9 1/4 inch booklet format
#let page-height = 9.25in
#let margin-x = 1in                         // Rule 33.1(c): margins at least 3/4 inch; text field no larger than 4 1/8 x 7 1/8 inch
#let margin-y = 1.0625in                    // (9.25in - 7.125in) / 2
#let para-indent = 0.5in
#let quote-indent = 0.5in                   // Rule 33.1(b): quotations over 50 words are indented
#let toc-depth = 2

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes and Other Authorities"),
)

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
  if key not in meta { panic("cert-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cert-petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// (Same method as the first-circuit template: a tag placed before a word at the start of a line
/// can be filed under the previous line, which may sit on the previous page.)
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

/// 9000 -> "9,000"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  let k = 0
  for ch in s.clusters().rev() {
    if k > 0 and calc.rem(k, 3) == 0 { out = "," + out }
    out = ch + out
    k += 1
  }
  out
}

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text; footnote labels are not words.
#let count-words(md) = {
  let s = md
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")      // footnote definition labels
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")             // footnote references
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")   // list markers are not words
  s = s.replace(regex("\\\\(.)"), keep)                    // backslash escapes
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w.match(regex("[A-Za-z0-9]")) != none).len()
}

/// Split the body at level-1 headings. Each piece keeps its heading line.
#let split-sections(body) = {
  let chunks = ("\n" + body).split(regex("\n# "))
  if chunks.first().trim() != "" {
    panic("cert-petition: text before the first level-1 heading is not allowed")
  }
  chunks.slice(1).map(c => "# " + c)
}

/// Which front page a section goes on, by its heading (Rule 14.1(a), (b)); everything else is the body.
#let section-kind(md) = {
  let t = lower(md.split("\n").first().slice(2).trim())
  if t.starts-with("questions presented") { "qp" }
  else if t.starts-with("parties to the proceeding") { "parties" }
  else { "body" }
}

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite)))).replace(regex("[^a-z0-9 ]"), "")

// ---------------------------------------------------------------------------
// Cover (Rule 34.1(a)-(f), in the order the rule gives)
// ---------------------------------------------------------------------------

/// Counsel block: `columns` is a list of columns, each a list of lines; "" is a blank line.
#let counsel-block(columns) = grid(
  columns: (1fr,) * columns.len(),
  column-gutter: 0.15in,
  align: top + left,
  ..columns.map(col => text(size: counsel-size, par(
    first-line-indent: 0pt, leading: leading-pitch, justify: false,
    col.map(l => if l == "" { [ ] } else { inl(l) }).join(linebreak()),
  ))),
)

#let cover(meta) = {
  let caption = need(meta, "caption")
  set par(first-line-indent: 0pt, leading: 2pt, justify: false)
  set text(size: cover-size)
  align(center)[
    No. #need(meta, "docket")
    #v(1.6em)
    IN THE
    #v(0.5em)
    #strong[Supreme Court of the United States]
    #v(1.4em)
    #for l in caption.petitioner { inl(l) + linebreak() }
    #v(0.3em)
    #need(meta, "petitioner-designation")
    #v(0.9em)
    #for l in caption.respondents { inl(l) + linebreak() }
    #v(0.3em)
    #need(meta, "respondent-designation")
    #v(1.2em)
    #inl(need(meta, "proceeding"))
    #v(1.2em)
    #strong(text(size: 13pt, need(meta, "title")))
  ]
  v(1fr)
  counsel-block(need(meta, "counsel").columns)
}

// ---------------------------------------------------------------------------
// Signature block (Rule 34.3: names of counsel at the close of the body) and certificate (Rule 33.1(h))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let counsel = need(meta, "counsel")
  block(breakable: false, width: 100%, {
    set par(first-line-indent: 0pt, leading: 2pt, justify: false)
    v(1.1em)
    [Respectfully submitted,]
    v(0.9em)
    counsel-block(counsel.columns)
    v(0.9em)
    [#counsel.at("attorneys-for", default: "") \ #counsel.at("date", default: "")]
  })
}

#let certificate-of-compliance(meta, words) = {
  set par(first-line-indent: 0pt, leading: 2pt, justify: true, spacing: 1em)
  align(center, strong[CERTIFICATE OF COMPLIANCE])
  v(1em)
  [
    I certify that this petition complies with the word limitation of Supreme Court Rule 33.1(g)(i),
    9,000 words, and contains #strong[#group-digits(words)] words, counted as Rule 33.1(d) directs:
    the question presented, the list of parties and corporate disclosure statement, the table of
    contents, the table of cited authorities, the counsel listing and any appendix are excluded.
  ]
  v(1.4em)
  let counsel = need(meta, "counsel")
  block(breakable: false, width: 100%, {
    set par(first-line-indent: 0pt, leading: 2pt, justify: false)
    align(right, [
      #need(meta, "certificate-signer") \
      #strong[Counsel of Record] \
      #counsel.at("date", default: "")
    ])
  })
}

// ---------------------------------------------------------------------------
// Table of authorities (Rule 34.2): built from the `toa:` links found in the body; every page listed
// ---------------------------------------------------------------------------

#let toa-section(authorities) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cert-petition: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.5em, sticky: true, strong(title))
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, grid(
          columns: (1fr, auto), column-gutter: 0.12in,
          par(first-line-indent: 0pt, hanging-indent: 0.3in, {
            if "name" in a {
              if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
              [, ]
            }
            inl(a.cite)
          }),
          par(first-line-indent: 0pt, pages.join(", ")),
        ))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let scotus-cert-petition(meta, body) = {
  let authorities = meta.at("authorities", default: (:))
  let sections = split-sections(body)
  let by-kind(k) = sections.filter(s => section-kind(s) == k).join("\n")
  let qp-md = by-kind("qp")
  let parties-md = by-kind("parties")
  let body-md = by-kind("body")
  if body-md.trim() == "" { panic("cert-petition: the sample has no body section") }

  let words = count-words(body-md)
  if words > word-limit {
    panic("cert-petition: body is " + str(words) + " words; Rule 33.1(g)(i) allows " + str(word-limit))
  }

  // Layout: booklet page, one text font (Rule 33.1(b)).
  set page(width: page-width, height: page-height, margin: (x: margin-x, y: margin-y), numbering: none)
  set text(font: typeface, size: type-size, lang: "en", ..line-box)
  set par(leading: leading-pitch, spacing: 0.9em, justify: true, first-line-indent: para-indent)
  set heading(numbering: none)
  show heading.where(level: 1): it => block(above: 1.2em, below: 0.9em, width: 100%, align(center, strong(it.body)))
  show heading.where(level: 2): it => block(above: 1em, below: 0.7em, width: 100%, par(
    first-line-indent: 0pt, hanging-indent: 0.4in, justify: false, strong(it.body),
  ))
  show heading.where(level: 3): it => block(above: 0.9em, below: 0.6em, width: 100%, par(
    first-line-indent: 0pt, hanging-indent: 0.4in, justify: false, strong(emph(it.body)),
  ))
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: leading-pitch, first-line-indent: 0pt, justify: false)
    it
  }
  show quote.where(block: true): it => block(above: 0.9em, below: 0.9em, pad(
    left: quote-indent, right: quote-indent,
    { set par(first-line-indent: 0pt, leading: 1.5pt, justify: false); it.body },
  ))
  set outline.entry(fill: repeat[.])
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (no number) ----
  cover(meta)

  // ---- front pages (lowercase roman) ----
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  // Rule 14.1(a): the questions presented sit on the first page after the cover, with nothing else.
  if qp-md != "" {
    cmarker.render(qp-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
    pagebreak()
  }
  if parties-md != "" {
    cmarker.render(parties-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
    pagebreak()
  }
  // Rule 34.2 / Rule 14(c): table of contents and table of cited authorities.
  heading(level: 1, outlined: false)[Table of Contents]
  outline(title: none, depth: toc-depth, indent: 0.3in)
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(body-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature-block(meta)

  // ---- certificate of compliance: separate from the document (Rule 33.1(h)) ----
  pagebreak()
  set page(numbering: none)
  certificate-of-compliance(meta, words)
}
