// Brief on the merits, Supreme Court of the United States (Rules 24, 33.1, 34).
// The template is content-agnostic: every number below is a named parameter that traces to a rule.
// The sample (markdown with a YAML frontmatter) supplies all text.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Rule parameters
// ---------------------------------------------------------------------------

#let court-name = "Supreme Court of the United States"
// STAND-IN FONT: Rule 33.1(b) requires a Century-family face (New Century Schoolbook, Century
// Schoolbook, Century Expanded). No Century face is vendored under fonts/, so EB Garamond is used
// for layout only. The README records this as an open tier-1 gap.
#let font-family = "EB Garamond"
#let body-size = 12pt                 // Rule 33.1(b): 12-point text
#let note-size = 10pt                 // Rule 33.1(b): 10-point footnotes
#let counsel-size = 10pt              // Rule 34.1(g): identification of counsel is exempt from the 11-point floor
#let min-leading = 2pt                // Rule 33.1(b): at least 2-point leading
#let leading-value = 2.5pt            // typst's leading is the space added between lines; 2.5pt >= 2pt
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

/// Cover, Rule 34.1: docket number, court, caption, nature of the proceeding, title, counsel.
/// Counsel of record sits first and carries its own notation (Rule 34.1(f)).
#let cover(meta) = {
  let counsel-group(g) = block(width: 100%, {
    set text(size: counsel-size)
    set par(justify: false, leading: min-leading, first-line-indent: 0pt)
    for n in g.names { [#inl(n) \ ] }
    for l in g.at("lines", default: ()) { [#text(style: "italic")[#inl(l)] \ ] }
  })
  let counsel = need(meta, "counsel")
  block(height: text-height, width: 100%, {
    set par(justify: false, first-line-indent: 0pt, leading: min-leading)
    align(center)[
      #text(size: body-size)[#need(meta, "docket")]
      #v(0.9in)
      #text(size: body-size)[IN THE]
      #v(0.2em)
      #text(size: 14pt)[#court-name]
      #v(0.6em)
      #line(length: 100%, stroke: 0.6pt)
      #v(0.6em)
      #for l in need(meta, "caption") [#text(size: body-size)[#inl(l)] \ ]
      #v(0.6em)
      #line(length: 100%, stroke: 0.6pt)
      #v(0.6em)
      #text(size: body-size)[#inl(need(meta, "proceeding"))]
      #v(0.6em)
      #text(size: body-size, weight: "bold")[#inl(need(meta, "brief_title"))]
    ]
    v(1fr)
    align(left, {
      grid(
        columns: (1fr, 1fr),
        column-gutter: 0.25in,
        row-gutter: 0.9em,
        ..counsel.map(counsel-group),
      )
    })
  })
}

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

/// Table of contents (Rule 24.1(c)): generated from the body headings.
#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right)[#text(size: note-size)[Page]]
  outline(title: none, depth: 3, indent: 0pt)
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
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
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
      block(above: 1em, below: 0.4em, sticky: true, text(weight: "bold")[#title])
      for k in keys {
        let a = authorities.at(k)
        let name = inl(a.name)
        let shown = if a.kind == "case" { emph(name) } else { name }
        let cite = a.at("cite", default: none)
        let line = if cite == none { shown } else { [#shown, #inl(cite)] }
        let ps = pages.at(k).sorted().map(str).join(", ")
        block(width: 100%, below: 0.5em, grid(
          columns: (1fr, auto),
          column-gutter: 0.5em,
          par(first-line-indent: 0pt, hanging-indent: 0.25in, leading: min-leading, line),
          align(right, text(size: body-size)[#ps]),
        ))
      }
    }
  }
}

/// Signature block, Rule 34.3: counsel's name at the close of the body.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, {
    v(1.2em)
    par(first-line-indent: 0pt)[Respectfully submitted,]
    v(2em)
    par(first-line-indent: 0pt, leading: min-leading)[
      #sig.signer \
      #for l in sig.lines [#inl(l) \ ]
    ]
    if "date" in meta { v(0.8em); par(first-line-indent: 0pt)[#inl(meta.date)] }
  })
}

/// Certificate of word count, Rule 33.1(h). The count is the template's mechanical count of the
/// sample body; a filer substitutes the count from the word processor used to prepare the brief.
#let word-certificate(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  par(first-line-indent: 0pt)[
    I certify that this brief complies with the word limit of Supreme Court Rule 33.1(g),
    #group-digits(word-limit) words for a brief on the merits for a petitioner or appellant,
    and that it contains #group-digits(words) words, excluding the parts that Rule 33.1(d) excludes.
  ]
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
  set page(
    width: booklet-width,
    height: booklet-height,
    margin: (x: margin-x, top: margin-top, bottom: margin-bottom),
    numbering: none,
  )
  set text(font: font-family, size: body-size, lang: "en", fallback: false)
  set par(justify: true, leading: leading-value, spacing: 0.75em, first-line-indent: para-indent)

  show heading.where(level: 1): it => block(above: 1.1em, below: 0.9em, width: 100%, sticky: true,
    {
      set par(justify: false)
      align(center, text(weight: "bold", hyphenate: false, it.body))
    })
  show heading.where(level: 2): it => block(above: 0.9em, below: 0.7em, sticky: true,
    par(first-line-indent: 0pt, justify: false, hanging-indent: heading-indent, text(weight: "bold", hyphenate: false, it.body)))
  show heading.where(level: 3): it => block(above: 0.8em, below: 0.6em, sticky: true,
    par(first-line-indent: 0pt, justify: false, hanging-indent: heading-indent, text(weight: "bold", hyphenate: false, it.body)))

  show quote.where(block: true): it => pad(left: 0.4in, right: 0.4in, {
    set par(first-line-indent: 0pt, leading: min-leading, justify: true)
    it.body
  })
  show footnote.entry: it => {
    set text(size: note-size)
    set par(leading: min-leading + 0.5pt, first-line-indent: 0pt, justify: true)
    it
  }

  show outline.entry: it => context {
    let loc = it.element.location()
    let pg = numbering(loc.page-numbering(), ..counter(page).at(loc))
    link(loc, pad(left: (it.level - 1) * 0.3in, block(width: 100%, {
      it.element.body
      h(0.2em)
      box(width: 1fr, repeat[.])
      h(0.2em)
      pg
    })))
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
