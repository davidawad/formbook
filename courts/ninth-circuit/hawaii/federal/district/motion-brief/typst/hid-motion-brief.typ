// U.S. District Court for the District of Hawaii: motion with memorandum in support (FRCP 12;
// LR 7.1, 7.3, 7.4, 7.8, 10.2). The form is the motion, then the memorandum with a table of
// contents and a table of authorities (LR 7.4(f)), then the signature and any certificate.
//
// Rule-driven and content-agnostic. Requirement references are to ../README.md (the rules, with
// URLs and the date they were verified). No case-specific text, no coordinates measured off any
// filed document, no forced line breaks. The body is rendered by cmarker; the metadata is the
// YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// LR 10.2(a)(2): "All memoranda, including footnotes, shall utilize 14-point Times New Roman plain
// style". Substitute per docs/FONTS.md: Liberation Serif (SIL OFL, metric-compatible with Times New Roman).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 14pt                      // LR 10.2(a)(2): 14 pt, footnotes included
#let body-leading = 1.4em                  // LR 10.2(a)(4) double spacing: baseline pitch 32.3 pt at 14 pt with Liberation Serif (measured; was 1.0em with EB Garamond)
#let single-leading = 0.12em               // headings, quotations, footnotes, caption, TOC and TOA: single-spaced
#let page-margin = 1in                     // LR 10.2(a)(1): one-inch margins
#let para-indent = 0.5in
#let court-title = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII")  // LR 10.2(c)(1)
#let page-limit = 25                       // LR 7.4(a): a memorandum shall not exceed 25 pages ...
#let word-limit = 6250                     // LR 7.4(b): ... unless it contains no more than 6,250 words
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim"

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hid-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Plain text of a piece of content, for sorting only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// (A tag placed before a citation that starts a line can land on the previous page.)
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
      else {
        let r = tag-after-first-word(ch, tag)
        out.push(r.first())
        placed = r.last()
      }
    }
    return (out.join(), placed)
  }
  (c, false)
}

/// Word count of the markdown source (LR 7.4(d)), whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text. Headings, footnotes and quotations
/// count; the table of contents, table of authorities and certificates are not in the source.
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

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (An explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Caption (LR 10.2(b), (c); LR 7.3 for the first page of a motion)
// ---------------------------------------------------------------------------

// Counsel columns, by how many the frontmatter gives (`counsel.columns`). Widths sum to 6.5 inches.
#let counsel-widths = (
  "1": (6.5in,),
  "2": (3.25in, 3.25in),
  "3": (2.3in, 2.2in, 2.0in),
)

#let counsel-column(lines) = {
  set text(size: 12pt)
  set par(leading: 0em, spacing: 0pt, first-line-indent: 0pt)
  for l in lines {
    if l == "" { v(0.6em) } else { [#inl(l)] }
    linebreak()
  }
}

#let caption(meta) = {
  let columns = meta.at("counsel", default: (:)).at("columns", default: ())
  grid(
    columns: counsel-widths.at(str(columns.len())),
    ..columns.map(counsel-column),
  )
  v(0.3in)
  if "counsel_for" in meta {
    set par(first-line-indent: 0pt)
    text(style: "italic")[#inl(meta.counsel_for)]
  }
  v(0.35in)
  align(center, strong(court-title.at(0)) + linebreak() + strong(court-title.at(1)))
  v(0.25in)
  block(breakable: false, grid(
    columns: (3.1in, 1fr), column-gutter: 0.2in,
    block(width: 100%, inset: (right: 0.12in, bottom: 0.12in), stroke: (right: 0.7pt, bottom: 0.7pt), {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
      for p in need(meta, "parties") {
        for n in p.names { [#inl(n)]; linebreak() }
        v(0.4em)
        align(right, emph(inl(p.designation)))
        v(0.8em)
        if p != meta.parties.last() { [v.]; linebreak(); v(0.4em) }
      }
    }),
    {
      set par(leading: single-leading, first-line-indent: 0pt)
      v(0.5em)
      [No. #need(meta, "case_number")]
      v(1.2em)
      strong(upper(need(meta, "title")))
      v(1.2em)
      [Judge: #need(meta, "judge")]
      if "hearing" in meta { linebreak(); [Hearing: #meta.hearing] }
      if "trial_date" in meta { linebreak(); [Trial Date: #meta.trial_date] }
    },
  ))
  v(0.3in)
}

// ---------------------------------------------------------------------------
// Motion (the paragraphs before the memorandum; unnumbered)
// ---------------------------------------------------------------------------

#let motion-paragraphs(meta) = {
  for p in meta.at("motion", default: ()) {
    par(first-line-indent: (amount: para-indent, all: true), inl(p))
  }
}

/// Dated line at left; signature blocks at right, kept together.
#let signature-block(meta) = {
  let sig = meta.at("signature", default: (:))
  block(breakable: false, {
    v(1.2em)
    set par(leading: single-leading, first-line-indent: 0pt)
    if "date" in meta { [#inl(meta.date)] }
    pad(left: 3in, {
      for b in sig.at("blocks", default: ()) {
        for l in b.lines {
          if l == "" { v(single-leading * 1.5) } else { [#inl(l)] }
          linebreak()
        }
        v(0.8em)
      }
    })
  })
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles (level 1 roman, level 2 letter, level 3 arabic)
// ---------------------------------------------------------------------------

#let heading-numbering(..n) = {
  let lvl = n.pos().len()
  let k = n.pos().last()
  if lvl == 1 { numbering("I.", k) }
  else if lvl == 2 { numbering("A.", k) }
  else { numbering("1.", k) }
}

#let style-heading(it) = {
  let num = if it.numbering != none {
    [#numbering(it.numbering, ..counter(heading).at(it.location())) #h(0.5em)]
  } else { [] }
  block(breakable: false, sticky: true, above: if it.level == 1 { 1.2em } else { 0.8em }, below: 0.8em, {
    set text(size: type-size)   // headings are the memorandum's type size, not typst's larger heading default
    set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: 0.5in, justify: false)
    strong(num + it.body)
  })
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (LR 7.4(f))
// ---------------------------------------------------------------------------

#let toc-section() = {
  align(center, strong[TABLE OF CONTENTS])
  v(1.2em)
  set par(leading: single-leading, first-line-indent: 0pt)
  show outline.entry: it => block(above: 0.7em, below: 0pt, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  })
  outline(title: none, depth: 3)
}

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
  .replace(regex("[^a-z0-9 ]"), "")

#let toa-section(authorities) = {
  align(center, strong[TABLE OF AUTHORITIES])
  v(1.2em)
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("hid-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 0.3em } else { 1.2em }, below: 0.4em, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct page labels of the memorandum, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
          h(0.6em)
          dot-leader
          h(0.3em)
          page-text
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Certificates (LR 7.4(e) compliance; certificate of service)
// ---------------------------------------------------------------------------

/// Certificate of compliance with the word limit (LR 7.4(e)). Required only when the memorandum runs
/// past 25 pages, that is, when the 6,250-word alternative of LR 7.4(b) is the one being used.
#let certificate-of-compliance(meta, words) = {
  align(center, strong[CERTIFICATE OF COMPLIANCE])
  v(0.8em)
  par(first-line-indent: (amount: para-indent, all: true), [
    The undersigned certifies that the foregoing memorandum complies with the word limit of
    LR 7.4(b) and contains #str(words) words, counted from the headings, text, quotations and
    footnotes of the memorandum. The caption, table of contents, table of authorities and
    certificates are not counted (LR 7.4(d)).
  ])
  signature-block(meta)
}

#let certificate-of-service(meta) = {
  let svc = meta.service
  align(center, strong[CERTIFICATE OF SERVICE])
  v(0.8em)
  par(first-line-indent: (amount: para-indent, all: true), [
    I hereby certify that on #inl(svc.date), the foregoing document was filed electronically through the
    CM/ECF system, which will send notice of the filing to all counsel of record.
  ])
  block(breakable: false, {
    v(1.2em)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(left: 3in, {
      for l in svc.signature {
        if l == "" { v(single-leading * 1.5) } else { [#inl(l)] }
        linebreak()
      }
    })
  })
}

/// The memorandum body, then the signature block. The last paragraph is kept on the same page as the
/// signature (a signature never stands alone on a page). Footnote definitions stay in the first part,
/// with their references.
#let body-with-signature(meta, body-md) = {
  let parts = body-md.trim(at: end).split(regex("\n[ \t]*\n"))
  let tail = none
  for (i, p) in parts.enumerate() {
    if not p.starts-with("[^") { tail = i }
  }
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if tail == none or parts.at(tail).starts-with("#") {
    render(body-md)
    signature-block(meta)
  } else {
    let head = parts.enumerate().filter(e => e.first() != tail).map(e => e.last()).join("\n\n")
    render(head)
    block(breakable: false, {
      render(parts.at(tail))
      signature-block(meta)
    })
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let hid-motion-brief(meta, body-md) = {
  set document(title: need(meta, "title") + " (No. " + need(meta, "case_number") + ")")
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-numbering)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)   // typst's default is 0.85em; LR 10.2(a)(2) asks for 14 pt, footnotes included
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  show heading: style-heading
  // Typography that holds for any text: never break inside "60(b)(5)" or between "§" and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- the motion: unnumbered pages (LR 7.1, 7.3, 7.8, 10.2) ----
  caption(meta)
  motion-paragraphs(meta)
  signature-block(meta)

  // ---- front matter: table of contents, table of authorities (lowercase roman) ----
  pagebreak()
  set page(numbering: "i", number-align: center + bottom)
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(meta.at("authorities", default: (:)))

  // ---- memorandum: arabic from 1 (LR 7.4(a): 25 pages) ----
  pagebreak()
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  align(center, strong[MEMORANDUM IN SUPPORT OF MOTION])
  v(1.2em)
  [#metadata("start") <body-start>]
  body-with-signature(meta, body-md)
  [#metadata("end") <body-end>]

  // ---- certificates ----
  context {
    let s = query(<body-start>).first().location()
    let e = query(<body-end>).first().location()
    let pages = counter(page).at(e).first() - counter(page).at(s).first() + 1
    let words = count-words(body-md)
    if pages > page-limit {
      if words > word-limit {
        panic("hid-motion-brief: the memorandum is " + str(pages) + " pages and " + str(words) + " words; LR 7.4 allows 25 pages or 6,250 words")
      }
      pagebreak(weak: true)
      certificate-of-compliance(meta, words)
    }
  }
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
