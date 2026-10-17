// U.S. Court of Appeals for the Armed Forces: brief on behalf of the appellant (Rule 24).
//
// Rule-driven and content-agnostic. Rule numbers in comments refer to the CAAF Rules of
// Practice and Procedure (effective Oct. 1, 2024, as amended through Sept. 26, 2025), see ../README.md.
// No case-specific text, no coordinates measured off a filed exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")           // Rule 37(a): proportional type. Vendored in /fonts.
#let type-size = 14pt                       // Rule 37(a): 14-point, printed matter including footnotes.
#let body-leading = 0.94em                  // Double spacing, calibrated as in courts/ninth-circuit/court-of-appeals.
#let single-leading = 0.12em                // Headings, block quotations, footnotes, index, authorities.
#let page-margin = 1in                      // Rule 37(a): at least one inch on all four sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                   // An authority cited on this many pages or more prints "passim".
#let word-limit = 13000                     // Rule 24(b)(1): a brief of the appellant may not exceed 13,000 words.

// Required sections, in the order Rule 24(a) lists them (a pattern per section).
#let required-sections = (
  "(?i)issue",                              // Issue(s) Presented (or the granted issue)
  "(?i)statement of statutory jurisdiction",
  "(?i)statement of the case",
  "(?i)statement of facts",                 // Rule 24(a) puts facts before the summary
  "(?i)summary of argument",
  "(?i)^argument$",
  "(?i)^conclusion$",
)

// Groups of the table of cases, statutes and other authorities, in print order.
#let toa-groups = (
  ("constitution", "Constitutional Provisions"),
  ("scotus", "Supreme Court of the United States"),
  ("caaf", "Court of Appeals for the Armed Forces and Court of Military Appeals"),
  ("service", "Service Courts of Criminal Appeals"),
  ("other-court", "State and Other Federal Court Cases"),
  ("statute", "Statutes"),
  ("rule", "Rules and Other Authorities"),
  ("other", "Other Authorities"),
)
#let case-kinds = ("scotus", "caaf", "service", "other-court")

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
  if key not in meta { panic("armfor-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("armfor-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Words of the markdown body, counted the way a word processor counts them: markers,
/// footnote labels and citation targets are not words; headings, footnotes and quotations are.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")     // footnote definition labels
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
  s.split(regex("\\s+")).filter(w => w.find(regex("[\\p{L}\\p{N}]")) != none).len()
}

/// Fails loudly when a required section is missing or out of order (Rule 21(b)).
#let check-structure(md) = {
  let titles = md.matches(regex("(?m)^# (.+?)\\s*$")).map(m => m.captures.at(0))
  let i = 0
  for p in required-sections {
    let found = false
    while i < titles.len() and not found {
      if titles.at(i).match(regex(p)) != none { found = true }
      i += 1
    }
    if not found {
      panic("armfor-opening-brief: required section matching `" + p + "` is missing or out of order (Rule 24(a))")
    }
  }
}

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading. Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("armfor-opening-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("armfor-opening-brief: headings deeper than level 5 are not supported") }
  }
}

/// Puts an invisible `tag` after the first word of a link's text, so that a citation which begins
/// at the start of a line is filed on the page where it begins (see ca9-brief.typ).
#let toa-tag(c, tag) = {
  if type(c) != str and c.func() == [ ].func() and c.children.len() > 0 {
    let k = c.children
    [#k.first()#tag#k.slice(1).join()]
  } else {
    [#c#tag]
  }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label; each further level steps in half an inch.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 3 } else { 2 }
  (h.level - first + 1) * heading-tab
}

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)
  if it.level == 1 {
    // Section headings: bold, centered, sentence case as written (Rule 24(a) form).
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em, align(center, strong(it.body)))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings of the Argument: bold, centered, with the roman numeral.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(heading-label(it) + [ ] + it.body)))
  } else {
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      strong(it.body)
    }))
  }
}

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One index row, built from a heading element. Wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  if numbered and in-argument(hd.location()) and hd.level == 2 { ind = 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let hang-by = ind + heading-tab
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(hang-by, {
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      hd.body
      h(0.4em)
      dot-leader
      box(width: 1.6em, align(right, it.page()))
    })))
}

#let index-section() = {
  heading(level: 1, numbering: none, outlined: false)[Index of Brief]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Table of cases, statutes, and other authorities (Rule 37(c)(1))
// ---------------------------------------------------------------------------

#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.cite)))

#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Cases, Statutes, and Other Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("armfor-opening-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
          let name = a.at("name", default: none)
          if name != none {
            if kind in case-kinds { emph(inl(name)) } else { inl(name) }
            [, ]
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
// Cover (Rule 24(a) form)
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    if i > 0 { align(center, [v.]) }
    align(center, stack(dir: ttb, spacing: 0.3em, ..side.at("names", default: ()).map(n => align(center, inl(n)))))
    if "lines" in side {
      align(center, stack(dir: ttb, spacing: 0pt, ..side.lines.map(n => align(center, inl(n)))))
    }
    align(center, emph(side.role))
  }
}

#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  grid(
    columns: (1fr, 1fr), column-gutter: 1.5em, row-gutter: 1.2em,
    ..groups.map(g => stack(dir: ttb, spacing: 0pt,
      ..g.names.map(n => inl(n)),
      ..g.at("lines", default: ()).map(l => emph(inl(l))),
    )),
  )
}

#let cover(meta) = page(numbering: none, footer: none)[
  #set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em, justify: false)
  #align(center, strong[IN THE UNITED STATES COURT OF APPEALS])
  #align(center, strong[FOR THE ARMED FORCES])
  #v(0.8em)
  #caption-block(meta)
  #v(0.8em)
  #align(center, strong[BRIEF ON BEHALF OF #upper(need(meta, "filer_role"))])
  #v(0.8em)
  #align(center, need(meta, "crim_app_dkt"))
  #align(center, need(meta, "uscaaf_dkt"))
  #v(0.8em)
  #align(left)[TO THE JUDGES OF THE UNITED STATES COURT OF APPEALS FOR THE ARMED FORCES:]
  #v(1fr)
  #counsel-block(meta)
]

// ---------------------------------------------------------------------------
// Back matter: signature, certificates (Rules 21(b)(6), 38, 39(c)(2))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, below: 0pt, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 50%, {
      [/s/ #sig.signer]
      v(0.5em)
      stack(dir: ttb, spacing: 0pt, ..sig.at("lines", default: ()).map(l => inl(l)))
    })
    if "date" in meta { v(0.8em); pad(left: 50%, [Dated: #meta.date]) }
  })
}

/// Form of Rule 24(d): the words stated are the count computed from the body (headings, footnotes
/// and quotations included; index, authorities, cover, certificates and signature excluded).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance with Rule 24(b)]
  block(breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
    [This brief complies with the type-volume limitation of Rule 24(b) because: This brief contains #words words. This brief complies with the typeface and type style requirements of Rule 37.]
    v(1.4em)
    pad(left: 50%, {
      [/s/ #need(meta, "signature").signer]
      v(0.4em)
      stack(dir: ttb, spacing: 0pt, ..need(meta, "signature").at("lines", default: ()).map(l => inl(l)))
    })
  })
}

#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Filing and Service]
  block(breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
    let svc = need(meta, "service")
    [I certify that a copy of the foregoing was electronically filed with the Court and electronically served on #svc.served-on on #need(meta, "date").]
    v(1.4em)
    pad(left: 50%, {
      [/s/ #need(meta, "signature").signer]
      v(0.4em)
      stack(dir: ttb, spacing: 0pt, ..need(meta, "signature").at("lines", default: ()).map(l => inl(l)))
    })
  })
}

// ---------------------------------------------------------------------------
// The supplement
// ---------------------------------------------------------------------------

#let armfor-opening-brief(meta, md) = {
  // ---- metadata and structure checks (loud failure beats silent omission) ----
  for k in ("crim_app_dkt", "uscaaf_dkt", "filer_role", "caption", "counsel", "signature", "date", "service") { let _ = need(meta, k) }
  check-structure(md)
  // Rule 24(a): each brief must set out the standard of review for each issue, under its own
  // heading or within the discussion of each issue.
  if md.match(regex("(?mi)^#+[ \t]+.*standard of review")) == none {
    panic("armfor-opening-brief: no heading names the standard of review (Rule 24(a), Argument)")
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- length (Rule 24(b)) ----
  let words = count-words(md)
  if words > word-limit {
    panic("armfor-opening-brief: the brief has " + str(words) + " words; Rule 24(b)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: "Brief on Behalf of " + need(meta, "filer_role") + ", " + need(meta, "uscaaf_dkt"),
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
  set heading(numbering: "1")
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("502(c)(3)") or between a section sign and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      toa-tag(it.body, [#metadata(it.dest.slice(4))<toa-hit>])
    } else { it.body }
  }

  // ---- cover (unnumbered) ----
  cover(meta)

  // ---- front matter (lowercase roman): index, then table of authorities ----
  set page(numbering: "i")
  counter(page).update(1)
  index-section()
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    // The signature block never stands alone: the last paragraph is kept with it.
    let text-md = md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if need(meta, "service").at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
