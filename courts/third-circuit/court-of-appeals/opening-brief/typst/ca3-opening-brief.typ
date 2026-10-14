// U.S. Court of Appeals for the Third Circuit: opening brief of an appellant.
//
// Rule-driven and content-agnostic. The rules are cited in ../README.md (rule IDs in its table).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // FRAP 32(a)(5): proportionally spaced serif. Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, text and footnotes (L.A.R. 32.2(a)).
#let body-leading = 0.94em                 // FRAP 32(a)(4): double-spaced text. Same metric as the ca9 template.
#let single-leading = 0.12em               // headings, block quotations, footnotes, TOC/TOA: single-spaced.
#let page-margin = 1in                     // L.A.R. 32.1(b): at least 1 in on each side (top and bottom at least 3/4 in).
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim".
#let word-limit = 13000                    // FRAP 32(a)(7)(B)(i): principal brief, type-volume limit in words.
#let circuit-name = "THE\u{00A0}THIRD\u{00A0}CIRCUIT"  // FRAP 32(a)(2)(B), cover. Joined words, not a line break.
#let required-fields = (
  "case_number", "caption", "proceeding", "brief_title", "counsel", "phone",
  "signature", "related_cases",
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
  if key not in meta { panic("ca3-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca3-opening-brief: the sample must start with a YAML frontmatter block") }
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
/// Markup characters are removed first; links keep their text.
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
// Headings: numbering and styles (the same scheme inside and outside the Argument)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: I. / A. / 1. / a. at levels 2 to 5.
/// The exemplar uses this scheme throughout (Statement of the Case and Argument alike).
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("ca3-opening-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Sub-headings: the label sits in a fixed box and the text hangs under itself.
    // Each level steps in half an inch; the label of level 2 starts at the margin.
    let ind = (it.level - 2) * heading-tab
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
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(ind + heading-tab, {
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      title
      h(0.8em)
      dot-leader
      box(align(right, it.page()))
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

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ca3-opening-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (FRAP 32(a)(2); one page)
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
  double-rule
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS FOR #circuit-name]
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
  if "district_court_case" in meta {
    parbreak()
    [(#inl(meta.district_court_case))]
  }
  if "judge" in meta {
    parbreak()
    [(#inl(meta.judge))]
  }
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  if "appendix" in meta {
    parbreak()
    inl(meta.appendix)
  }
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number).
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        for l in g.at("lines", default: ()) { h(0.5em); inl(l); linebreak() }
        if gi == groups.len() - 1 {
          h(0.5em)
          need(meta, "phone")
          if "counsel_for" in meta {
            linebreak()
            h(0.5em)
            emph(inl(meta.counsel_for))
          }
        }
      })
    }
  }))
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca3-opening-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Statement of related cases (L.A.R. 28.1(a)(2)), signature, certificates (FRAP 32(g); L.A.R. 28.3(d))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      [/s/ #sig.signer]
      for l in sig.at("lines", default: ()) { linebreak(); inl(l) }
    }))
    if "date" in meta { v(0.8em); meta.date }
  })
}

/// Signature under a certificate: the same `/s/` line and counsel lines as the brief's signature.
#let certificate-signature(meta) = block(above: 1.4em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sig = need(meta, "signature")
  align(left, pad(left: 50%, {
    [/s/ #sig.signer]
    for l in sig.at("lines", default: ()) { linebreak(); inl(l) }
  }))
  if "date" in meta { v(0.8em); meta.date }
})

/// Statement of Related Cases, after the statement of the issues (L.A.R. 28.1(a)(2)).
/// The statement itself is the filer's, from the frontmatter; the template only places it.
#let related-cases(meta) = {
  heading(level: 1, numbering: none)[Statement of Related Cases]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  inl(need(meta, "related_cases"))
}

/// Certificate of compliance with the type-volume limit (FRAP 32(g)(1); FRAP 32(a)(7)(B)).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).]
  parbreak()
  [This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because it has been prepared in a proportionally spaced typeface using #meta.at("prepared_with", default: "Typst") in font size 14, font style #font-family.]
  certificate-signature(meta)
}

/// Certification of bar membership (L.A.R. 28.3(d)).
#let certificate-of-bar(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certification of Bar Membership]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [I certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court, or has filed an application for admission under 3d Cir. L.A.R. 46.1.]
  certificate-signature(meta)
}

/// Certification of the electronic brief (L.A.R. 31.1(b)(2): PDF; the identity and virus checks
/// are the filer's convention, shown in the exemplar, not a requirement of the L.A.R. text).
#let certificate-of-e-brief(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certification of Text of E-Brief and Virus Check]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [I certify that the text of the E-Brief and the text of the hard copies of this brief are identical.]
  parbreak()
  if "virus_software" in meta {
    [I certify that a virus check was performed on the PDF file of this brief. The virus software used was #meta.virus_software.]
  }
  certificate-signature(meta)
}

/// Certificate of service (FRAP 25(d)): electronic service through the appellate CM/ECF system.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [I, #need(meta, "signature").signer, counsel for the filer and a member of the bar of this Court, certify that, on #need(meta, "date"), the brief and all accompanying appendices were filed electronically through the appellate CM/ECF system with the Clerk of Court. I further certify that all parties required to be served have been served.]
  certificate-signature(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca3-opening-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in required-fields { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- the body must have the sections the rules require ----
  let split = md.match(regex("(?mi)^#[ \t]+statement of the case[ \t]*$"))
  if split == none {
    panic("ca3-opening-brief: the body needs a `# Statement of the Case` heading; the related-cases statement is placed before it (L.A.R. 28.1(a)(2))")
  }
  for (pattern, what) in (
    ("(?mi)^#+[ \t]+[^\n]*standard of review", "a heading containing `Standard of Review` (L.A.R. 28.1(b))"),
    ("(?mi)^#[ \t]+argument[ \t]*$", "an `# Argument` heading"),
    ("(?mi)^#[ \t]+conclusion[ \t]*$", "a `# Conclusion` heading"),
  ) {
    if md.find(regex(pattern)) == none { panic("ca3-opening-brief: the body needs " + what) }
  }
  let before = md.slice(0, split.start)
  let after = md.slice(split.start)

  // ---- word count (FRAP 32(a)(7)(B)(i)): everything the rules do not exempt from the body ----
  let words = count-words(md) + count-words(need(meta, "related_cases"))
  if words > word-limit {
    panic("ca3-opening-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(i) allows " + str(word-limit))
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
    set text(size: type-size)   // typst's default is smaller; L.A.R. 32.2(a) requires the text size
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
    // The signature block never stands alone on a page: the brief's last paragraph is kept
    // together with it (unless that last block is a heading or a footnote definition).
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let text-md = after.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    render(before)
    related-cases(meta)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates of counsel (each on its own page, as the exemplar sets them) ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  pagebreak(weak: true)
  certificate-of-bar(meta)
  pagebreak(weak: true)
  certificate-of-e-brief(meta)
  if meta.at("service", default: (:)).at("certificate", default: true) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
