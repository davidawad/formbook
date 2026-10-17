// U.S. Court of Appeals for the Federal Circuit: reply brief.
//
// Rule-driven and content-agnostic. Rule references (FRAP / FCR) are sourced in ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // FRAP 32(a)(5)(A): proportionally spaced serif. Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, everywhere.
#let body-leading = 0.94em                 // double spacing: baseline pitch about 2.2 x type size (see README).
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA, signature: single-spaced.
#let page-margin = 1in                     // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let word-limit = 7000                     // FCR 32(b)(1): reply brief. FRAP 32(a)(7)(B)(ii) (half of 13,000) is overridden.

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
  if key not in meta { panic("cafc-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A drawn check box (no font glyph needed, so no fallback can occur).
#let checkbox(checked) = box(
  width: 0.72em, height: 0.72em, baseline: 0.05em, stroke: 0.7pt, inset: 0pt,
  if checked {
    place(top + left, line(start: (0pt, 0pt), end: (100%, 100%), stroke: 0.9pt))
    place(top + left, line(start: (0pt, 100%), end: (100%, 0pt), stroke: 0.9pt))
  },
)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cafc-reply-brief: the sample must start with a YAML frontmatter block") }
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

/// 6998 -> "6,998"
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
/// Markup characters are removed first; links keep their text. Headings, footnotes and
/// quotations are counted (FRAP 32(f)); the cover, tables, signature and certificates are not
/// part of the markdown and so are not counted.
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

/// Printed label of a numbered heading. Sections are roman (I. ARGUMENT, II. CONCLUSION, as the
/// filed reply briefs print them); under a section: A., then i., then 1., then a.
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 1 { numbering("I.", n) }
  else if h.level == 2 { numbering("A.", n) }
  else if h.level == 3 { numbering("i.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("cafc-reply-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 and it.numbering == none {
    // Unnumbered sections (tables, certificates): bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else if it.level == 1 {
    // Numbered sections: bold capitals, centered, with the roman numeral.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(heading-label(it) + [ ] + upper(it.body))))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text. Each level steps in half an inch.
    let ind = (it.level - 1) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element. The label sits where the heading's
/// own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none
  let ind = if numbered { (hd.level - 1) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(ind + heading-tab, {
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      title
      h(0.8em)
      dot-leader
      box(width: 2.6em, align(right, it.page()))
    })))
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

/// Table of authorities, built from the `toa:` links found in the body. Every page is listed:
/// "passim" is not used (proposed Fed. Cir. R. 32(j) would forbid it from December 1, 2026).
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cafc-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
          pages.join(", ")
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FCR 32(a)(1): the official caption; FRAP 32(a)(2))
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
  strong[No. #need(meta, "case_number")]
  v(gap)
  strong(block(width: 4in, [UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT]))
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
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number), two groups to a row.
  grid(columns: (1fr, 1fr), column-gutter: 0.1in, row-gutter: 0.6em,
    ..need(meta, "counsel").map(g => align(left, block(breakable: false, {
      // One paragraph per line, single-spaced; a line too long for its column wraps under a hanging indent.
      set par(spacing: single-leading)
      for l in g.names + g.at("lines", default: ()) { par(hanging-indent: 1em, l) }
    }))))
  v(gap * 0.6)
  align(center, inl(need(meta, "counsel_for")))
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("cafc-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature block and certificates (Form 19; FCR 32(b)(3); FRAP 25)
// ---------------------------------------------------------------------------

/// Signature block after the Conclusion. The first signer is printed "/s/ Name"; the others are
/// listed under it. The date sits on the left, as in the filed exemplar.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let dated = if "date" in meta { [Dated: #meta.date] } else { [] }
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.9in), dated, {
      [Respectfully submitted,]
      v(1.2em)
      [/s/ #sig.signer]
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); l }
      for o in sig.at("also", default: ()) {
        v(1.2em)
        o.name
        for l in o.at("lines", default: ()) { linebreak(); h(0.5em); l }
      }
      v(0.8em)
      inl(need(meta, "counsel_for"))
    })
  })
}

#let option-row(checked, body, indent: 0pt) = block(above: 0.8em, breakable: false, hang(indent + 1.6em, {
  h(indent)
  box(width: 1.6em, checkbox(checked))
  body
}))

/// Form 19 (Certificate of Compliance with Type-Volume Limitations), wording of the filed form.
/// The word count is computed from the markdown; the box is the only option this template produces.
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance with Type-Volume Limitations]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [Case Number: #need(meta, "case_number")]
  parbreak()
  [Short Case Caption: #inl(need(meta, "short_caption"))]
  parbreak()
  [Instructions: When computing a word, line, or page count, you may exclude any items listed as exempted under Fed. R. App. P. 5(c), Fed. R. App. P. 21(d), Fed. R. App. P. 27(d)(2), Fed. R. App. P. 32(f), or Fed. Cir. R. 32(b)(2).]
  parbreak()
  [The foregoing filing complies with the relevant type-volume limitation of the Federal Rules of Appellate Procedure and Federal Circuit Rules because it meets one of the following:]
  option-row(true, [the filing has been prepared using a proportionally-spaced typeface and includes #group-digits(words) words.])
  option-row(false, [the filing has been prepared using a monospaced typeface and includes \_\_\_\_\_\_\_\_\_\_ lines of text.])
  option-row(false, [the filing contains \_\_\_\_\_\_\_\_\_\_ pages / \_\_\_\_\_\_\_\_\_\_ words / \_\_\_\_\_\_\_\_\_\_ lines of text, which does not exceed the maximum authorized by this court’s order (ECF No. \_\_\_\_\_\_\_\_\_\_).])
  block(above: 1.6em, breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading)
    grid(columns: (1fr, 1fr), column-gutter: 1em,
      [Date: #need(meta, "date")],
      {
        [Signature: /s/ #need(meta, "signature").signer]
        parbreak()
        [Name: #need(meta, "signature").signer]
      })
  })
}

/// Certificate of Service: filing through CM/ECF, in the wording of the filed exemplar.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I hereby certify that on #need(meta, "date"), I electronically filed the foregoing #inl(need(meta, "brief_title")), with the Court’s CM/ECF filing system, which constitutes service, pursuant to Fed. R. App. P. 25(c) and Fed. Cir. R. 25(a).]
  block(above: 1.6em, breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.9in), [Date: #need(meta, "date")], {
      [/s/ #need(meta, "signature").signer]
      for l in need(meta, "signature").at("lines", default: ()) { linebreak(); h(0.5em); l }
    })
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let cafc-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "short_caption", "counsel", "counsel_for", "signature", "date") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- length (FCR 32(b)(1)) ----
  let words = count-words(md)
  if words > word-limit {
    panic("cafc-reply-brief: the brief has " + str(words) + " words; Fed. Cir. R. 32(b)(1) allows " + str(word-limit) + " for a reply brief")
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
    set text(size: type-size)   // typst's default is 0.85em; FRAP 32(a)(5)(A) allows nothing under 14 pt
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

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block is kept whole (it is about 27 single-spaced lines with three signers).
    // When the Conclusion fills the page it starts its own page, as the filed exemplar does.
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    render(md.trim(at: end))
    signature-block(meta)
  }

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  pagebreak(weak: true)
  certificate-of-service(meta)
}
