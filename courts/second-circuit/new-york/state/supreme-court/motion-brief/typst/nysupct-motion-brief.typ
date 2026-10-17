// Supreme Court of the State of New York: memorandum of law on a motion (motion-brief).
//
// Rule-driven and content-agnostic. Requirement IDs (NYSM-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks.
// The body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample
// (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Termes"   // Termes matches the audited exemplar (docs/FONTS.md)
#let type-size = 12pt              // NYSM-FORM-002: 22 NYCRR 202.5(a) print no smaller than 12-point
#let footnote-size = 11pt          // NYSM-FORM-003: 22 NYCRR 202.5(a) footnotes no smaller than 10-point; 11-point for legibility
#let page-margin = 1in             // NYSM-FORM-004: 22 NYCRR 202.5(a) margins no smaller than one inch
#let para-indent = 0.5in           // convention: text paragraphs begin with a first-line indent
#let body-leading = 1.645em        // NYSM-FORM-001: double space (202.5(a)); baseline pitch about twice the single pitch, see README
#let single-leading = 0.52em       // quotations, caption, signature block, TOC/TOA, footnotes: single-spaced
#let toc-depth = 4
#let passim-threshold = 7          // convention (as in the ca9 template): an authority on 7 or more pages prints "passim"
#let word-limit-in-chief = 7000    // NYSM-WORD-001: 22 NYCRR 202.8-b(a)(i)
#let word-limit-reply = 4200       // NYSM-WORD-001: 22 NYCRR 202.8-b(a)(ii)

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
  if key not in meta { panic("nysupct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A run of single-spaced address or signature lines, one item per line (no manual breaks).
#let address(lines, italic: false) = stack(
  dir: ttb,
  spacing: single-leading,
  ..lines.map(l => if italic { text(style: "italic")[#inl(l)] } else { inl(l) }),
)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysupct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// Why not simply put the tag in front: when a citation begins at the start of a line, typst
/// files a tag that sits before the first word under the PREVIOUS line, which may be on the
/// previous page, so the table of authorities would cite the wrong page.
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
/// Markup characters are removed first; links keep their text. Footnote text counts.
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
// Caption (NYSM-CAP-001..003: court, county, parties, index number, judge, title)
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let parties = need(meta, "parties")
  block(width: 100%, breakable: false)[
    #block(width: 100%)[#align(center)[#text(weight: "bold")[SUPREME COURT OF THE STATE OF NEW YORK]]]
    #block(width: 100%)[#align(left)[#text(weight: "bold")[COUNTY OF #upper(need(meta, "county"))]]]
    #v(0.8em)
    #grid(
      columns: (3.6in, 1fr),
      column-gutter: 0.2in,
      block(
        width: 100%,
        stroke: (top: 0.7pt, bottom: 0.7pt, right: 0.7pt),
        inset: (top: 0.7em, bottom: 0.7em, right: 0.6em),
      )[
        #for (i, group) in parties.enumerate() {
          if i > 0 {
            v(0.6em)
            align(center)[#text(style: "italic")[-against-]]
            v(0.6em)
          }
          for name in group.names {
            pad(left: 0.2in, right: 0.2in)[#set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
              #inl(name)]
            v(0.1em)
          }
          align(right)[#pad(right: 0.2in)[#set par(leading: single-leading, spacing: single-leading)
            #inl(group.designation)]]
        }
      ],
      block(width: 100%, inset: (top: 0.7em))[
        #set par(leading: single-leading, spacing: single-leading)
        #stack(
          dir: ttb,
          spacing: single-leading,
          need(meta, "index_no"),
          ..(if "judge" in meta { (meta.judge,) } else { () }),
          ..(if "motion_seq" in meta { (meta.motion_seq,) } else { () }),
        )
      ],
    )
    #v(1.2em)
  ]
}

// ---------------------------------------------------------------------------
// Cover: caption, title, and the counsel block at the foot of the page (CPLR 2101; 202.5(a)(1))
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  let c = need(meta, "counsel")
  block(width: 3.6in, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #address(c.names)
    #v(0.5em)
    #address(c.lines)
    #if "on_brief" in c [
      #v(1.2em)
      On the Memorandum of Law:
      #address(c.on_brief)
    ]
  ]
}

#let cover(meta) = {
  caption-block(meta)
  v(1.6in)
  align(center)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #text(weight: "bold")[#need(meta, "title")]
  ]
  v(1fr)
  counsel-block(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (front matter, lowercase roman)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.])

#let toc-section() = {
  align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
  v(0.4em)
  align(right)[Page]
  v(0.4em)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  outline(title: none, depth: toc-depth, indent: 0.4in)
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
  align(center)[#text(weight: "bold")[TABLE OF AUTHORITIES]]
  v(0.4em)
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nysupct-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    align(right)[Page(s)]
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        strong(title)
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
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, {
          set par(hanging-indent: 0.35in, first-line-indent: 0pt)
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
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block, service list, and word-count certification
// (NYSM-SIG-001..002: CPLR 2101(a) printed name beneath the signature; NYSM-WORD-002: 202.8-b(c))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    #grid(
      columns: (1fr, 3.2in),
      stack(
        dir: ttb,
        spacing: single-leading,
        [Dated:],
        [#need(meta, "place")],
        [#need(meta, "date")],
      ),
      [
        Respectfully submitted,
        #v(1.2em)
        #address(sig.firm)
        #v(1.2em)
        By: #line(length: 2.6in, stroke: 0.6pt)
        #v(0.2em)
        #stack(dir: ttb, spacing: single-leading, inl(sig.signer), address(sig.lines, italic: false))
      ],
    )
  ]
}

#let service-block(meta) = {
  if "to" not in meta { return }
  v(1.6em)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    TO:
    #for group in meta.to [
      #v(0.6em)
      #address(group.names)
      #address(group.lines, italic: true)
    ]
  ]
}

#let certificate-block(meta, words, filing) = {
  let clause = if filing == "reply" { "202.8-b(a)(ii)" } else { "202.8-b(a)(i)" }
  align(center)[#text(weight: "bold")[CERTIFICATION OF COMPLIANCE WITH WORD COUNT LIMIT]]
  v(1.2em)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))
  [
    I hereby certify pursuant to 22 NYCRR 202.8-b(c) that the total number of words in the foregoing
    memorandum of law, exclusive of the caption, table of contents, table of authorities, and signature
    block, is #group-digits(words), according to the word count of the document as prepared, and thus
    that the document complies with the word count limit set forth in 22 NYCRR #clause.
  ]
  v(2.4em)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #stack(
      dir: ttb,
      spacing: single-leading,
      [Dated: #need(meta, "place"), #need(meta, "date")],
    )
    #v(2.4em)
    #align(right)[#block(width: 3.2in)[
      #line(length: 100%, stroke: 0.6pt)
      #v(0.2em)
      #inl(need(meta, "signature").signer)
    ]]
  ]
}

// ---------------------------------------------------------------------------
// The memorandum of law
// ---------------------------------------------------------------------------

#let nysupct-motion-brief(meta, body) = {
  let title = need(meta, "title")
  let _ = need(meta, "parties")
  let filing = meta.at("filing", default: "in-chief")
  if filing not in ("in-chief", "reply") {
    panic("nysupct-motion-brief: `filing` must be `in-chief` or `reply`, not `" + filing + "`")
  }
  let limit = if filing == "reply" { word-limit-reply } else { word-limit-in-chief }
  let words = count-words(body)
  assert(
    words <= limit,
    message: "nysupct-motion-brief: " + str(words) + " words exceeds the 22 NYCRR 202.8-b(a) limit of " + str(limit),
  )

  set document(title: title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: none,
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true),
    justify: false,
  )

  // Headings (the author types the numbering, as the exemplar does):
  // level 1 centered bold capitals; level 2 bold; level 3 bold; level 4 bold italic; level 5 italic.
  show heading.where(level: 1): it => block(
    width: 100%, above: 1.4em, below: 1.2em, sticky: true,
    align(center, text(weight: "bold", it.body)),
  )
  show heading.where(level: 2): it => block(
    width: 100%, above: 1.2em, below: 1em, sticky: true,
    par(first-line-indent: 0pt, text(weight: "bold", it.body)),
  )
  show heading.where(level: 3): it => block(
    width: 100%, above: 1em, below: 0.8em, sticky: true,
    par(first-line-indent: 0pt, text(weight: "bold", it.body)),
  )
  show heading.where(level: 4): it => block(
    width: 100%, above: 1em, below: 0.8em, sticky: true,
    par(first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body)),
  )
  show heading.where(level: 5): it => block(
    width: 100%, above: 0.9em, below: 0.7em, sticky: true,
    par(first-line-indent: 0pt, text(style: "italic", it.body)),
  )
  show heading.where(level: 6): it => panic("nysupct-motion-brief: headings deeper than level 5 are not supported")

  // Footnotes at the 10-point minimum (202.5(a)); the marks sit in the body text.
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)

  // Block quotations: indented, single-spaced (convention; the exemplar quotes are set this way).
  show quote: it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: 1em, below: 1em)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  // Table of contents entries: dot leaders and page numbers.
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.body() + h(0.4em) + dot-leader + h(0.4em) + it.page()),
  )

  // Typography that holds for any text: never break "§ 3211" or "¶ 13" across lines.
  show regex("[§¶] \\S+"): it => box(it)

  // Citations: a link whose target is `toa:KEY` is recorded for the table of authorities.
  // The link prints as its text; plain web links print their text only.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (page 1, unnumbered) ----
  cover(meta)

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  if meta.at("toc", default: true) {
    toc-section()
    pagebreak()
  }
  toa-section(need(meta, "authorities"))
  pagebreak()

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  service-block(meta)

  pagebreak()
  certificate-block(meta, words, filing)
}
