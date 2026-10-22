// Brief on the merits, Supreme Court of the United States (Rules 24, 33.1, 34).
// The template is content-agnostic: every number below is a named parameter that traces to a rule.
// The sample (markdown with a YAML frontmatter) supplies all text.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Rule parameters
// ---------------------------------------------------------------------------

#let court-name = "Supreme Court of the United States"
// Rule 33.1(b): Century family (New Century Schoolbook, Century Schoolbook, Century Expanded).
// docs/FONTS.md maps the Century family to the vendored TeX Gyre Schola (metric-compatible with
// the Adobe base-35 New Century Schoolbook AFMs).
#let font-family = "TeX Gyre Schola"
#let body-size = 12pt                 // Rule 33.1(b): 12-point text
#let note-size = 10pt                 // Rule 33.1(b): 10-point footnotes
#let counsel-size = 10pt              // Rule 34.1(g): identification of counsel is exempt from the 11-point floor
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight). The same layout in the
// latex (latex/template.tex) and docx (docx/brief.lua) engines.
#let pitch-body = 14pt                // Rule 33.1(b): 12-point type with 2-point leading
#let pitch-note = 12pt                // Rule 33.1(b): 10-point notes with 2-point leading (counsel on the cover too)
#let para-space = 9pt                 // between paragraphs (0.75 em)
#let toc-page-col = 24pt              // the contents' page numbers keep this column to themselves
#let toa-page-col = 40pt              // the authorities' page lists; a longer list widens its row's column
#let booklet-width = 6.125in          // Rule 33.1(a): 6 1/8 by 9 1/4 inch booklet
#let booklet-height = 9.25in
#let text-width = 4.125in             // Rule 33.1(c): text field, footnotes included, at most 4 1/8 by 7 1/8 inches
#let text-height = 7.125in
#let min-margin = 0.75in              // Rule 33.1(c): margins of at least three-fourths of an inch on all sides
#let margin-x = (booklet-width - text-width) / 2
#let margin-top = 1in
#let margin-bottom = booklet-height - text-height - margin-top
#let word-limit = 13000               // Rule 33.1(g)(v): brief on the merits for a petitioner or appellant
#let heading-indent = 0.4in           // hanging indent of argument point headings
#let para-indent = 0.3in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("merits-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("merits-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible tag right after the first word of `c`, keeping emphasis around it.
/// (A tag placed before a citation that starts a line can land on the previous line's page.)
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

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Markup is removed first; links keep their text. Footnote text is counted (Rule 33.1(d)).
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

// ---------------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------------

/// A line (or wrapped paragraph) of the cover, `above` the space before it.
#let cover-line(above, body) = block(width: 100%, above: above, below: 0pt, align(center, body))
#let cover-rule(above) = block(width: 100%, above: above, below: 0pt, line(length: 100%, stroke: 0.6pt))

/// Cover, Rule 34.1: docket number, court, caption, nature of the proceeding, title, counsel.
/// Counsel of record sits first and carries its own notation (Rule 34.1(f)); counsel in two columns at the foot.
#let cover(meta) = {
  let counsel-group(g) = block(width: 100%, {
    set text(size: counsel-size, ..edges(pitch-note))
    set par(justify: false, first-line-indent: 0pt)
    for n in g.names { block(above: 0pt, below: 0pt, inl(n)) }
    for l in g.at("lines", default: ()) { block(above: 0pt, below: 0pt, emph(inl(l))) }
  })
  let counsel = need(meta, "counsel")
  block(height: text-height, width: 100%, {
    set par(justify: false, first-line-indent: 0pt)
    cover-line(0pt, need(meta, "docket"))
    cover-line(64.8pt)[IN THE]
    cover-line(2.4pt, court-name)
    cover-rule(7.2pt)
    for (i, l) in need(meta, "caption").enumerate() { cover-line(if i == 0 { 7.2pt } else { 0pt }, inl(l)) }
    cover-rule(7.2pt)
    cover-line(7.2pt, inl(need(meta, "proceeding")))
    cover-line(7.2pt, strong(inl(need(meta, "brief_title"))))
    v(1fr)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 0.25in,
      row-gutter: 10.8pt,
      ..counsel.map(counsel-group),
    )
  })
}

/// A heading-like title that is not in the table of contents (Rule 24.1 front pages are; these are not).
#let front-title(body) = heading(level: 1, numbering: none, outlined: false, body)

/// Questions Presented page (Rule 24.1(a)): the questions and nothing else.
#let questions-page(meta) = {
  let qs = need(meta, "questions")
  heading(level: 1, if qs.len() == 1 { "Question Presented" } else { "Questions Presented" })
  for q in qs { par(first-line-indent: 0pt)[#inl(q)] }
}

/// Parties and corporate disclosure (Rule 24.1(b)).
#let parties-page(meta) = {
  heading(level: 1, "Parties to the Proceedings")
  par(first-line-indent: 0pt)[#inl(need(meta, "parties"))]
  if "disclosure" in meta {
    heading(level: 1, "Corporate Disclosure Statement")
    par(first-line-indent: 0pt)[#inl(meta.disclosure)]
  }
}

/// Table of contents (Rule 24.1(c)): generated from the headings, levels 1 to 3; each row 4.8 pt below the one
/// before, the text wrapping before the page column (listing-row), its wrapped lines at the row's indent.
#let toc-section() = {
  front-title[Table of Contents]
  block(width: 100%, above: 0pt, below: 0pt, align(right, text(size: note-size, ..edges(pitch-note))[Page]))
  context for hd in query(heading.where(outlined: true)) {
    if hd.level <= 3 {
      let ind = (hd.level - 1) * para-indent
      let loc = hd.location()
      let pg = numbering(loc.page-numbering(), ..counter(page).at(loc))
      listing-row(loc, [#h(ind)#hd.body], pg, toc-page-col, ind, 4.8pt)
    }
  }
}

#let toa-groups = (
  (kind: "case", title: "Cases"),
  (kind: "constitution", title: "Constitutional Provisions"),
  (kind: "statute", title: "Statutes"),
  (kind: "regulation", title: "Regulations"),
  (kind: "rule", title: "Rules"),
  (kind: "other", title: "Other Authorities"),
)

/// Table of authorities (Rule 34.2): every page on which an authority is cited, no "passim".
/// Pages come from the `toa:` links in the body; the key must be in the frontmatter `authorities`.
#let toa-section(authorities) = {
  front-title[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    let pages = (:)
    for h in hits {
      let p = counter(page).at(h.location()).first()
      let cur = pages.at(h.value, default: ())
      if p not in cur { cur.push(p); pages.insert(h.value, cur) }
    }
    for key in authorities.keys() {
      if key not in pages { panic("merits-brief: authority `" + key + "` is listed in the frontmatter but never cited") }
    }
    for (kind, title) in toa-groups {
      let keys = authorities.keys().filter(k => authorities.at(k).kind == kind)
      if keys.len() == 0 { continue }
      keys = keys.sorted(key: k => lower(authorities.at(k).at("sort", default: authorities.at(k).name)))
      block(width: 100%, above: 12pt, below: 4.8pt, sticky: true, strong(title))
      for k in keys {
        let a = authorities.at(k)
        let name = inl(a.name)
        let shown = if a.kind == "case" { emph(name) } else { name }
        let cite = a.at("cite", default: none)
        let line = if cite == none { shown } else { [#shown, #inl(cite)] }
        let ps = pages.at(k).sorted().map(str).join(", ")
        // one row: the citation hangs 0.25 in and wraps before the page column, a dot leader to the pages
        listing-row(none, line, ps, calc.max(toa-page-col, measure(ps).width), 0.25in, 6pt)
      }
    }
  }
}

/// Signature block, Rule 34.3: counsel's name at the close of the body; never split.
#let signer-lines(meta) = {
  let sig = need(meta, "signature")
  block(above: 0pt, below: 0pt, sig.signer)
  for l in sig.lines { block(above: 0pt, below: 0pt, inl(l)) }
  if "date" in meta { block(above: 9.6pt, below: 0pt, inl(meta.date)) }
}

#let signature-block(meta) = block(breakable: false, width: 100%, above: 14.4pt, below: 0pt, {
  set par(first-line-indent: 0pt, justify: false)
  block(above: 0pt, below: 24pt)[Respectfully submitted,]
  signer-lines(meta)
})

/// Certificate of word count, Rule 33.1(h). The count is the template's mechanical count of the
/// sample body; a filer substitutes the count from the word processor used to prepare the brief.
#let word-certificate(meta, words) = {
  front-title[Certificate of Compliance]
  par(first-line-indent: 0pt)[I certify that this brief complies with the word limit of Supreme Court Rule 33.1(g), #group-digits(word-limit) words for a brief on the merits for a petitioner or appellant, and that it contains #group-digits(words) words, excluding the parts that Rule 33.1(d) excludes.]
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let merits-brief(meta, md) = {
  // Booklet geometry must satisfy Rule 33.1(c) before anything else is set.
  assert(margin-x >= min-margin and margin-top >= min-margin and margin-bottom >= min-margin,
    message: "merits-brief: margins below Rule 33.1(c)'s three-fourths of an inch")
  assert(text-width <= 4.125in and text-height <= 7.125in,
    message: "merits-brief: text field exceeds Rule 33.1(c)'s 4 1/8 by 7 1/8 inches")

  let authorities = meta.at("authorities", default: (:))
  let words = count-words(md)
  if words > word-limit {
    panic("merits-brief: body is " + str(words) + " words, over the Rule 33.1(g) limit of " + str(word-limit))
  }

  set document(title: need(meta, "docket") + " " + need(meta, "brief_title"))
  // The page number: centered in a line box of the body pitch, the same on every page.
  set page(
    width: booklet-width,
    height: booklet-height,
    margin: (x: margin-x, top: margin-top, bottom: margin-bottom),
    numbering: none,
    footer-descent: 30%,
    footer: context if page.numbering != none {
      align(center, text(..edges(pitch-body), counter(page).display(page.numbering)))
    },
  )
  set text(font: font-family, size: body-size, lang: "en", fallback: false)
  set par(first-line-indent: para-indent)
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the bullet in a 0.3 in box, a section sign kept with
  // its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // Ragged right, as the court's other templates here: a justified 4 1/8 in measure without hyphenation (which no two
  // engines share) opens wide gaps between words.
  set par(spacing: para-space)

  // Rule 33.1(b): 12-point type, headings too (typst would enlarge them).
  show heading: set text(size: body-size, ..edges(pitch-body))
  show heading.where(level: 1): it => block(above: 13.2pt, below: 10.8pt, width: 100%, sticky: true,
    {
      set par(justify: false)
      align(center, strong(it.body))
    })
  show heading.where(level: 2): it => block(above: 10.8pt, below: 8.4pt, sticky: true,
    par(first-line-indent: 0pt, justify: false, hanging-indent: heading-indent, strong(it.body)))
  show heading.where(level: 3): it => block(above: 9.6pt, below: 7.2pt, sticky: true,
    par(first-line-indent: 0pt, justify: false, hanging-indent: heading-indent, strong(it.body)))

  show quote.where(block: true): it => block(above: para-space, below: para-space, pad(left: 0.4in, right: 0.4in, {
    set par(first-line-indent: 0pt)
    it.body
  }))
  set footnote.entry(gap: 6pt, clearance: 12pt, indent: 0pt, separator: line(length: 0.9in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 6pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // A note is not split across pages (Word keeps its lines together; LaTeX: \interfootnotelinepenalty 10000).
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  // Citations: [text](toa:key) is recorded for the table of authorities; the key must be listed.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in authorities {
        panic("merits-brief: link `toa:" + key + "` has no entry under `authorities:` in the frontmatter")
      }
      tag-after-first-word(it.body, [#metadata(key)<toa-hit>]).first()
    } else {
      it
    }
  }

  // ---- Front matter: cover (unnumbered), then roman-numbered pages ----
  cover(meta)

  pagebreak()
  counter(page).update(1)
  set page(numbering: "i")
  questions-page(meta)

  pagebreak()
  parties-page(meta)

  pagebreak()
  toc-section()

  pagebreak()
  toa-section(authorities)

  // ---- Body: arabic numbering from 1 ----
  pagebreak()
  counter(page).update(1)
  set page(numbering: "1")
  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // ---- Signature and certificate ----
  signature-block(meta)

  pagebreak()
  set page(numbering: none)
  word-certificate(meta, words)
}
