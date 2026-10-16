// U.S. Court of Appeals for the Federal Circuit: opening brief (principal brief of the appellant).
//
// Rule-driven and content-agnostic. Requirement IDs (Fed. Cir. R. ..., FRAP ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters
// ---------------------------------------------------------------------------

#let doc-kind = "opening-brief"
#let word-limit = 14000                    // Fed. Cir. R. 32(b)(1): principal brief, 14,000 words (FRAP 32(a)(7)(B)(i) as enlarged).
#let required-sections = (                 // Fed. Cir. R. 28(a)(5)-(10), in this order (regexes on lowercased titles).
  "^(statement of (the )?)?jurisdiction",
  "^statement of (the )?issues?$",
  "^statement of (the )?case",
  "^summary of (the )?argument",
  "^argument$",
  "^conclusion",
)
#let needs-standard-of-review = true       // Fed. Cir. R. 28(a)(9): standard of review under its own heading
#let addendum = "required"                 // Fed. Cir. R. 28(c)(1)(A): the decision appealed from, bound with the brief

// ---------------------------------------------------------------------------
// Parameters (the only other numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-name = "United States Court of Appeals for the Federal Circuit"   // FRAP 32(a)(2)(B); Fed. Cir. R. 32(a)(1)
#let font-family = "EB Garamond"          // FRAP 32(a)(5)(A): proportionally spaced, serif. Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A) and Fed. Cir. R. 32 Practice Notes (Footnotes): 14-point, footnotes included.
#let body-leading = 0.94em                 // with the metric-aligned line box, a baseline pitch of about
                                           // 2.2 x type size: double spacing (FRAP 32(a)(4)).
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA: single-spaced (FRAP 32(a)(4)).
#let page-margin = 1in                     // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"

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
  if key not in meta { panic("cafc-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cafc-brief: the sample must start with a YAML frontmatter block") }
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

/// Drop a "statement regarding oral argument" section: FRAP 32(f) excludes it from the word count.
#let strip-oral-argument(md) = {
  let m = md.match(regex("(?mi)^#[ \t]+[^\n]*oral argument[^\n]*$"))
  if m == none { return md }
  let rest = md.slice(m.end)
  let n = rest.match(regex("(?m)^#[ \t]"))
  let after = if n == none { "" } else { rest.slice(n.start) }
  md.slice(0, m.start) + after
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() in ("argument", "reply argument")
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("cafc-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("cafc-brief: headings deeper than level 5 are not supported") }
  }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. Labels sit half an inch in from the margin; each further
/// level steps in half an inch more. In the Argument the level-2 point heading is centered, so
/// its sub-headings start at the first step.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 3 } else { 2 }
  (h.level - first + 1) * heading-tab
}

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, text(size: 1.15em, strong(upper(it.body)))))
  } else if it.numbering == none {
    // Unnumbered sub-headings (addendum entries): bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold small capitals, centered, with the roman numeral.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(smallcaps(heading-label(it) + [ ] + it.body))))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
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

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  // The Argument's centered point heading has no body indent in the table; its label starts at the margin.
  if numbered and in-argument(hd.location()) and hd.level == 2 { ind = 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  let hang-by = ind + heading-tab
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(hang-by, {
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      title
      h(0.8em)
      dot-leader
      box(width: 2.6em, align(right, it.page()))
    })))
}

/// Table of contents of the brief's own headings. The front matter headings (certificate of
/// interest, contents, authorities, related cases) are listed too, as Fed. Cir. practice does.
#let toc-section(has-addendum) = {
  heading(level: 1, numbering: none)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  let target = if has-addendum {
    selector(heading.where(outlined: true)).before(<add-start>, inclusive: true)
  } else {
    selector(heading.where(outlined: true))
  }
  show outline.entry: toc-entry
  outline(title: none, target: target, depth: toc-depth, indent: 0pt)
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
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cafc-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (FRAP 32(a)(2); Fed. Cir. R. 32(a)(1): the clerk's official caption)
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
  strong[#need(meta, "case_number")]                   // (A) the number of the case, centered at the top
  v(gap)
  double-rule
  v(gap)
  strong(upper(court-name))                            // (B) the name of the court
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")                     // (C) the title of the case
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: 50%, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))                         // (D) the nature of the proceeding and the court below
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))         // (E) the title of the brief
  v(gap)
  short-rule
  v(gap)
  // (F) name, office address and telephone number of counsel.
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { h(0.5em); emph(inl(l)); linebreak() }
      })
    }
  }))
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("cafc-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

/// Exemplary patent claims (Fed. Cir. R. 32(a)(3)): when the language of a patent or patent
/// application is at issue, each principal brief carries one or more illustrative claims inside
/// the front cover, or immediately after it when the text needs more room. Electronic filings
/// have no inside cover, so the claims take their own unnumbered page(s) right after the cover.
/// The text may be single-spaced. Only when the frontmatter has `patent_claims`.
#let patent-claims-page(meta) = if "patent_claims" in meta {
  page(numbering: none, footer: none, {
    heading(level: 1, numbering: none, outlined: false, meta.at("patent_claims_heading", default: "Exemplary Patent Claims"))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
    for p in meta.patent_claims { inl(p); parbreak() }
  })
}

// ---------------------------------------------------------------------------
// Front matter: certificate of interest (Fed. Cir. R. 47.4; Form 9), statement of related cases
// (Fed. Cir. R. 28(a)(4), 47.5(a)). Both are listed in the table of contents.
// ---------------------------------------------------------------------------

/// A drawn check box (no font glyph needed, so no fallback can occur).
#let checkbox(checked) = box(
  width: 0.72em, height: 0.72em, baseline: 0.05em, stroke: 0.7pt, inset: 0pt,
  if checked {
    place(top + left, line(start: (0pt, 0pt), end: (100%, 100%), stroke: 0.9pt))
    place(top + left, line(start: (0pt, 100%), end: (100%, 0pt), stroke: 0.9pt))
  },
)

#let numbered-items(items) = for (i, t) in items.enumerate() {
  block(above: 0.9em, below: 0pt, breakable: true, hang(0.3in, [#box(width: 0.3in)[#(i + 1).]#t]))
}

/// Signature line for a certificate filed by counsel (Form 9 / Form 19 / Form 30 style).
#let signature-line-block(meta, prefix) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sig = need(meta, "signature")
  align(left, pad(left: 50%, {
    [#prefix #sig.signer]
    linebreak()
    upper(sig.signer)
    if "date" in meta { linebreak(); meta.date }
  }))
})
#let certificate-of-interest(meta) = {
  let ci = need(meta, "interest")
  heading(level: 1, numbering: none)[Certificate of Interest]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [Counsel for #inl(ci.for) certifies the following:]
  numbered-items((
    [The full name of every party or amicus represented by me is: #inl(ci.represented).],
    [The name of the real party in interest represented by me is: #inl(ci.real_party).],
    [All parent corporations and any publicly held companies that own 10 percent of the stock of a party or amicus curiae represented by me are: #inl(ci.parents).],
    [The names of all law firms and the partners and associates that (a) appeared for the entities in the originating court or agency or (b) are expected to appear in this court for the entities not including those who have already entered an appearance in this court: #inl(ci.other_counsel).],
    [#if need(meta, "related_cases").status == "none" [I am unaware of any cases pending in this or any other court or agency that meet the criteria under Fed. Cir. R. 47.5(a). I am unaware of any cases pending that will directly affect or be directly affected by this court's decision in the pending appeal.] else [Related or prior cases meeting the criteria under Fed. Cir. R. 47.5(a) are listed in the Statement of Related Cases.]],
  ))
  signature-line-block(meta, "/s/")
}

#let related-cases-page(meta) = {
  let rc = need(meta, "related_cases")
  heading(level: 1, numbering: none)[Statement of Related Cases]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [Pursuant to Federal Circuit Rules 28(a)(4) and 47.5, counsel for #inl(need(meta, "interest").for) certifies:]
  if rc.status == "none" {
    numbered-items((
      [I am unaware of any other appeal in or from the same civil action or proceeding in the originating tribunal that was previously before this or any other appellate court.],
      [I am unaware of any case pending in this or any other tribunal that will directly affect or be directly affected by this court's decision in the pending case.],
    ))
  } else {
    // Fed. Cir. R. 47.5(a)(1): title and number, date of decision, panel, reporter citation; 47.5(a)(2): pending cases.
    numbered-items(rc.cases.map(c => inl(c)))
  }
  signature-line-block(meta, "/s/")
}


// ---------------------------------------------------------------------------
// Signature block (after the Conclusion), certificates
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      [/s/ #sig.signer]
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
    if "date" in meta { v(0.8em); meta.date }
  })
}

/// Certificate of Compliance with Type-Volume Limitations: Federal Circuit Form 19 wording
/// (Fed. Cir. R. 32(b)(3); FRAP 32(g)). Required only for a brief over the page limit; the
/// template always produces it, from the word count of the markdown (FRAP 32(f) exclusions applied).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance with Type-Volume Limitations]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [Case Number: #meta.case_number]
  linebreak()
  [Short Case Caption: #inl(need(meta, "short_caption"))]
  parbreak()
  [The foregoing filing complies with the relevant type-volume limitation of the Federal Rules of Appellate Procedure and Federal Circuit Rules because it meets one of the following:]
  block(above: 0.8em, below: 0.8em, breakable: false, pad(left: 1.6em, {
    checkbox(true)
    h(0.6em)
    [the filing has been prepared using a proportionally-spaced typeface and includes #group-digits(words) words.]
  }))
  block(above: 0.8em, below: 0.8em, breakable: false, pad(left: 1.6em, {
    checkbox(false)
    h(0.6em)
    [the filing has been prepared using a monospaced typeface and includes \_\_\_\_ lines of text.]
  }))
  block(above: 0.8em, below: 0.8em, breakable: false, pad(left: 1.6em, {
    checkbox(false)
    h(0.6em)
    [the filing contains \_\_\_\_ pages / \_\_\_\_ words / \_\_\_\_ lines of text, which does not exceed the maximum authorized by this court's order (ECF No. \_\_\_\_).]
  }))
  block(above: 1.6em, breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading)
    [Date: #need(meta, "date")]
    linebreak()
    [Signature: /s/ #need(meta, "signature").signer]
    linebreak()
    [Name: #upper(need(meta, "signature").signer)]
  })
}

/// Proof of service (FRAP 25(d); Fed. Cir. R. 25(e); Form 30). Only when the brief is served outside
/// CM/ECF (`service.certificate: true`); electronic service through CM/ECF needs no certificate.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I hereby certify under penalty of perjury that on #need(meta, "date"), a copy of the foregoing "#inl(need(meta, "brief_title"))" was filed electronically and served via the Court's ECF system.]
  let unreg = meta.service.at("unregistered", default: ())
  if unreg.len() > 0 {
    parbreak()
    [I further certify that on the same date I served the foregoing by U.S. Mail on the following persons, who are not registered for electronic filing:]
    for u in unreg { block(above: 0.7em, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
  }
  signature-line-block(meta, "/s/")
}

#let toc-addendum() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(level: 2)).after(<add-start>), depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let cafc-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "short_caption", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "date", "interest", "related_cases") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }
  if body-md.match(regex("(?m)^#+[ \t]+[^\n]*toa:")) != none {
    panic("cafc-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }
  if addendum == "required" and add == none {
    panic("cafc-brief: Fed. Cir. R. 28(c)(1)(A) requires an addendum with the decision appealed from; add a `# Addendum` section")
  }

  // ---- sections: Fed. Cir. R. 28(a), in order ----
  let titles = body-md.matches(regex("(?m)^#[ \t]+(.*?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
  let pos = 0
  for pat in required-sections {
    let rest = titles.slice(pos)
    let k = rest.position(t => t.match(regex(pat)) != none)
    if k == none { panic("cafc-brief: " + doc-kind + " needs a section matching `" + pat + "` (in this order; Fed. Cir. R. 28(a))") }
    pos = pos + k + 1
  }
  // Fed. Cir. R. 28(a)(9): the standard of review under its own heading, in the argument or just before it.
  let standard-found = body-md.match(regex("(?mi)^#+[ \t]+[^\n]*standard of review")) != none
  if needs-standard-of-review and not standard-found {
    panic("cafc-brief: Fed. Cir. R. 28(a)(9) requires the standard of review under its own heading")
  }

  // ---- length: Fed. Cir. R. 32(b)(1), with FRAP 32(f) and Fed. Cir. R. 32(b)(2) exclusions ----
  let words = count-words(strip-oral-argument(body-md))
  if words > word-limit {
    panic("cafc-brief: the brief has " + str(words) + " words; Fed. Cir. R. 32(b)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, number-align: center, footer-descent: 30%)   // FRAP 32(a)(4); Fed. Cir. R. 32(e)
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
    set text(size: type-size)   // typst's default is 0.85em; the Practice Notes apply the type size to footnotes
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
  patent-claims-page(meta)

  // ---- front matter (lowercase roman): certificate of interest, contents, authorities, related cases ----
  set page(numbering: "i")
  counter(page).update(1)
  certificate-of-interest(meta)
  pagebreak()
  toc-section(add != none)
  pagebreak()
  toa-section(authorities)
  pagebreak()
  related-cases-page(meta)

  // ---- body (arabic from 1) ----
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
    let text-md = body-md.trim(at: end)
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
    [#metadata(none)<body-end>]
  }

  // ---- addendum (Fed. Cir. R. 28(a)(11), 28(c): bound with the brief, before the certificates; own contents and Add- pagination) ----
  if add != none {
    pagebreak()
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    toc-addendum()
    pagebreak()
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }

  // ---- certificates (Fed. Cir. R. 28(a)(12)): arabic pagination continues from the body ----
  pagebreak()
  set page(numbering: "1")
  context {
    let last = counter(page).at(query(<body-end>).first().location()).first()
    counter(page).update(last + 1)
  }
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
