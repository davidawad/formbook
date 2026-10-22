// Supreme Court of the United States: petition for a writ of certiorari (doc type `cert-petition`).
//
// Rule-driven and content-agnostic. Requirement IDs (Rule 14, Rule 33.1, Rule 34 ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed petition, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that would differ for another SCOTUS doc type)
// ---------------------------------------------------------------------------

#let doc-kind = "cert-petition"
#let word-limit = 9000                      // Rule 33.1(g)(i): petition for a writ of certiorari, booklet format
#let typeface = "TeX Gyre Schola"           // Rule 33.1(b): Century family (URW Century Schoolbook clone), vendored in fonts/tex-gyre-schola/.
#let type-size = 12pt                       // Rule 33.1(b): Century 12-point type
#let footnote-size = 10pt                   // Rule 33.1(b): footnotes 10-point
#let cover-size = 11pt                      // Rule 34.1(g): not smaller than 11-point (identification of counsel may be smaller)
#let counsel-size = 10pt                    // Rule 34.1(g): counsel identification
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). Rule 33.1(b): 2-point leading on every size.
#let pitch-body = 14pt                      // 12-point type (quotations too)
#let pitch-note = 12pt                      // 10-point footnotes and counsel
#let pitch-cover = 13pt                     // the 11-point cover
#let title-size = 13pt                      // the cover's title
#let pitch-title = 15pt
#let para-space = 10.8pt                    // between paragraphs (0.9 em)
#let toc-page-col = 24pt                    // the contents' page numbers keep this column to themselves
#let toa-page-col = 40pt                    // the authorities' page lists; a longer list widens its row's column
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

/// Counsel block: `columns` is a list of columns, each a list of lines; "" is a blank line. 10-point lines.
#let counsel-block(columns) = grid(
  columns: (1fr,) * columns.len(),
  column-gutter: 0.15in,
  align: top + left,
  ..columns.map(col => {
    set text(size: counsel-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, justify: false)
    // a blank line is a line box of its own
    for l in col { block(above: 0pt, below: 0pt, width: 100%, height: if l == "" { pitch-note } else { auto }, inl(l)) }
  }),
)

/// A centred line (or wrapped paragraph) of the cover, `above` the space before it.
#let cover-line(above, body) = block(width: 100%, above: above, below: 0pt, align(center, body))

#let cover(meta) = {
  let caption = need(meta, "caption")
  set par(first-line-indent: 0pt, justify: false)
  set text(size: cover-size, ..edges(pitch-cover))
  cover-line(0pt)[No. #need(meta, "docket")]
  cover-line(17.6pt)[IN THE]
  cover-line(5.5pt, strong[Supreme Court of the United States])
  for (i, l) in caption.petitioner.enumerate() { cover-line(if i == 0 { 15.4pt } else { 0pt }, inl(l)) }
  cover-line(3.3pt, need(meta, "petitioner-designation"))
  for (i, l) in caption.respondents.enumerate() { cover-line(if i == 0 { 9.9pt } else { 0pt }, inl(l)) }
  cover-line(3.3pt, need(meta, "respondent-designation"))
  cover-line(13.2pt, inl(need(meta, "proceeding")))
  cover-line(13.2pt, text(size: title-size, ..edges(pitch-title), strong(need(meta, "title"))))
  v(1fr)
  counsel-block(need(meta, "counsel").columns)
}

// ---------------------------------------------------------------------------
// Signature block (Rule 34.3: names of counsel at the close of the body) and certificate (Rule 33.1(h))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let counsel = need(meta, "counsel")
  block(breakable: false, width: 100%, above: 13.2pt, below: 0pt, {
    set par(first-line-indent: 0pt, justify: false)
    block(above: 0pt, below: 0pt)[Respectfully submitted,]
    block(above: 10.8pt, below: 0pt, counsel-block(counsel.columns))
    block(above: 10.8pt, below: 0pt, counsel.at("attorneys-for", default: ""))
    block(above: 0pt, below: 0pt, counsel.at("date", default: ""))
  })
}

#let certificate-of-compliance(meta, words) = {
  set par(first-line-indent: 0pt, justify: false)
  block(width: 100%, above: 0pt, below: 12pt, align(center, strong[CERTIFICATE OF COMPLIANCE]))
  block(above: 12pt, below: 0pt)[I certify that this petition complies with the word limitation of Supreme Court Rule 33.1(g)(i), 9,000 words, and contains #strong[#group-digits(words)] words, counted as Rule 33.1(d) directs: the question presented, the list of parties and corporate disclosure statement, the table of contents, the table of cited authorities, the counsel listing and any appendix are excluded.]
  let counsel = need(meta, "counsel")
  block(breakable: false, width: 100%, above: 16.8pt, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt, align(right, need(meta, "certificate-signer")))
    block(width: 100%, above: 0pt, below: 0pt, align(right, strong[Counsel of Record]))
    block(width: 100%, above: 0pt, below: 0pt, align(right, counsel.at("date", default: "")))
  })
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (Rule 34.2)
// ---------------------------------------------------------------------------

/// Table of contents: the outlined headings to `toc-depth`; each row 6 pt below the one before, the text wrapping
/// before the page column (listing-row), its wrapped lines at the row's indent.
#let toc-section() = {
  heading(level: 1, outlined: false)[Table of Contents]
  context for hd in query(heading.where(outlined: true)) {
    if hd.level <= toc-depth {
      let ind = (hd.level - 1) * 0.3in
      let loc = hd.location()
      let pg = numbering(loc.page-numbering(), ..counter(page).at(loc))
      listing-row(loc, [#h(ind)#hd.body], pg, toc-page-col, ind, 6pt)
    }
  }
}

/// Table of authorities: built from the `toa:` links found in the body; every page listed.
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
      block(width: 100%, above: if first { 12pt } else { 16.8pt }, below: 6pt, sticky: true, strong(title))
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let ps = pages.join(", ")
        // one row: the citation hangs 0.3 in and wraps before the page column, a dot leader to the pages
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }, ps, calc.max(toa-page-col, measure(ps).width), 0.3in, 7.2pt)
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

  // Layout: booklet page, one text font (Rule 33.1(b)). The page number: centered in a line box of the body pitch.
  set page(width: page-width, height: page-height, margin: (x: margin-x, y: margin-y), numbering: none,
    footer-descent: 30%,
    footer: context if page.numbering != none {
      align(center, text(..edges(pitch-body), counter(page).display(page.numbering)))
    })
  set text(font: typeface, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: para-indent)
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, a section sign kept with its number, no break inside "60(b)(5)".
  // Ragged right: a justified 4 1/8 in measure without hyphenation (which no two engines share) opens wide gaps.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  set par(spacing: para-space)
  set heading(numbering: none)
  // Rule 33.1(b): 12-point type, headings too.
  show heading: set text(size: type-size, ..edges(pitch-body))
  show heading.where(level: 1): it => block(above: 14.4pt, below: 10.8pt, width: 100%, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 2): it => block(above: 12pt, below: 8.4pt, width: 100%, sticky: true, par(
    first-line-indent: 0pt, hanging-indent: 0.4in, strong(it.body),
  ))
  show heading.where(level: 3): it => block(above: 10.8pt, below: 7.2pt, width: 100%, sticky: true, par(
    first-line-indent: 0pt, hanging-indent: 0.4in, strong(emph(it.body)),
  ))
  set footnote.entry(gap: 6pt, clearance: 12pt, indent: 0pt, separator: line(length: 0.9in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 6pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // A note is not split across pages (Word keeps its lines together).
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }
  show quote.where(block: true): it => block(above: para-space, below: para-space, pad(
    left: quote-indent, right: quote-indent,
    { set par(first-line-indent: 0pt); it.body },
  ))
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
  toc-section()
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
