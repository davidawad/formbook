// United States Foreign Intelligence Surveillance Court of Review: amicus curiae brief.
//
// Rule-driven and content-agnostic. Requirement IDs (FISC Ct. Rev. R. P. ..., FRAP ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters (rule-driven; the only part that differs between doc types)
// ---------------------------------------------------------------------------

#let doc-kind = "amicus-brief"
#let word-limit-appointed = 13000          // FRAP 32(a)(7)(B)(i), applied to a court-appointed amicus by FISCR R. 15(d)(2).
#let word-limit-other = 6500               // FRAP 29(a)(5): one-half of the 13,000-word principal-brief limit (amicus not appointed by the court).
#let required-sections = (                 // FISCR R. 14(a)(6)-(8) as made applicable by R. 15(d)(1), in this order (regexes on lowercased titles).
  "^(statement of (the )?case|introduction)", // 14(a)(6). The filed exemplar has no heading of that name; see README, Known gaps.
  "^summary of (the )?argument",           // 14(a)(7)
  "^argument$",                            // 14(a)(8)
)
#let needs-standard-of-review = false      // FISCR R. 15(d)(1)(C): the standard of review need not appear.
#let addendum = "optional"                 // no addendum is required for an amicus brief (R. 14(a) list, as applied by R. 15(d)(1)).

// ---------------------------------------------------------------------------
// Parameters (the only other numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-name = "United States Foreign Intelligence Surveillance Court of Review"   // FRAP 32(a)(2)(B), as applied by R. 15(d)(2)
#let font-family = ("Times New Roman", "Liberation Serif")           // FRAP 32(a)(5)(A): proportionally spaced, serif. Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, everywhere, footnotes included.
#let body-leading = 0.94em                 // with the metric-aligned line box, a baseline pitch of about
                                           // 2.2 x type size: double spacing (FISCR R. 9(c)(2)).
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA: single-spaced (R. 9(c)(2)).
#let page-margin = 1in                     // FISCR R. 9(c)(3): at least one inch on all four sides.
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
  if key not in meta { panic("fiscr-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fiscr-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Cut the level-1 section whose heading matches `pat` (case-insensitive) out of `md`.
/// Returns (section markdown or none, the rest). The section runs to the next level-1 heading.
#let take-section(md, pat) = {
  let m = md.match(regex("(?mi)^#[ \t]+(" + pat + ")[^\n]*$"))
  if m == none { return (none, md) }
  let rest = md.slice(m.end)
  let n = rest.match(regex("(?m)^#[ \t]"))
  let end = if n == none { md.len() } else { m.end + n.start }
  (md.slice(m.start, end), md.slice(0, m.start) + md.slice(end))
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
    else { panic("fiscr-amicus-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("fiscr-amicus-brief: headings deeper than level 5 are not supported") }
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
    // Unnumbered sub-headings: bold, left.
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
      h(0.4em)
      dot-leader
      box(width: 1.6em, align(right, it.page()))
    })))
}

#let toc-section(has-addendum) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
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
        panic("fiscr-amicus-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (FRAP 32(a)(2)(A)-(F) as applied by FISCR R. 15(d)(2))
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
  strong[Docket No. #need(meta, "case_number")]         // the docket number, centered at the top
  v(gap)
  double-rule
  v(gap)
  [In the]                                              // the name of the court
  parbreak()
  strong(upper(court-name))
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")                     // the title of the case
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    if "designation" in side and side.designation != "" { align(left, pad(left: 50%, inl(side.designation))) }
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))                         // the nature of the proceeding and the court below
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [D.C. No. #meta.district_court_case]#if "district_court_case" in meta and "judge" in meta [; ]#if "judge" in meta [#inl(meta.judge)]]
  }
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))         // the title of the brief
  v(gap)
  short-rule
  v(gap)
  // Name, office address and telephone number of counsel.
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
  if "date" in meta {
    v(gap)
    meta.date
  }
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("fiscr-amicus-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Disclosure statement (FRAP 26.1 / FISCR R. 12. Not required of an amicus; rendered only when given.)
// ---------------------------------------------------------------------------

#let disclosure-page(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Disclosure Statement]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  inl(meta.disclosure)
}

// ---------------------------------------------------------------------------
// Signature, certificates (FRAP 32(g)(1), Form 6; FISCR R. 14(a)(10) via R. 15(d)(1); R. 10(c))
// ---------------------------------------------------------------------------

/// A drawn check box (no font glyph needed, so no fallback can occur).
#let checkbox(checked) = box(
  width: 0.72em, height: 0.72em, baseline: 0.05em, stroke: 0.7pt, inset: 0pt,
  if checked {
    place(top + left, line(start: (0pt, 0pt), end: (100%, 100%), stroke: 0.9pt))
    place(top + left, line(start: (0pt, 100%), end: (100%, 0pt), stroke: 0.9pt))
  },
)

/// Space for a handwritten signature above the signer's name (the brief is signed by counsel;
/// the template does not insert an electronic "/s/" signature).
#let signature-space = {
  v(2.4em)
  line(length: 2.6in, stroke: 0.6pt)
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      signature-space
      sig.signer
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
    if "date" in meta { v(0.8em); meta.date }
  })
}

#let form-sig-line(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading)
  let sig = need(meta, "signature")
  align(left, pad(left: 50%, {
    signature-space
    sig.signer
    linebreak()
    [#inl(sig.at("for", default: ""))]
    if "date" in meta { linebreak(); [Dated: #meta.date] }
  }))
})

/// Certificate of Compliance, Form 6 wording (FRAP 32(g)(1)-(2) as applied by FISCR R. 15(d)(2) and 14(a)(10)).
#let certificate-of-compliance(meta, words, limit-cite) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [Pursuant to FISC Ct. Rev. R. P. 15(d)(1)-(2), the undersigned certifies that this brief complies with the content requirements of FISC Ct. Rev. R. P. 14(a)(2)-(8) and (10), with the exceptions in FISC Ct. Rev. R. P. 15(d)(1)(A)-(C), and with the type-volume limit of #limit-cite. Excluding the parts of the brief exempted by Fed. R. App. P. 32(f):]
  block(above: 0.8em, below: 0.8em, breakable: false, pad(left: 1.6em, {
    checkbox(true)
    h(0.6em)
    [this brief contains #group-digits(words) words.]
  }))
  [The undersigned relied upon the word count of the word-processing system used to prepare this brief, as Fed. R. App. P. 32(g)(1) permits.]
  block(above: 0.8em, below: 0.8em, breakable: false, pad(left: 1.6em, {
    checkbox(true)
    h(0.6em)
    [this brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6): it has been prepared in a proportionally spaced typeface using #need(meta, "word_processor") in #int(type-size.pt())-point #need(meta, "typeface") roman type.]
  }))
  form-sig-line(meta)
}

/// Certificate of Service. Only when `service.certificate: true`. FISCR R. 10(c) requires the time
/// and manner of service; the time is printed when the sample gives one.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  let s = meta.service
  let time = if "time" in s { [ at #s.time] } else { [] }
  [I hereby certify that on #meta.at("date", default: "__________")#time, I #s.method.]
  let rec = s.at("recipients", default: ())
  for u in rec { block(above: 0.7em, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
  form-sig-line(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let fiscr-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "word_processor", "typeface", "court_appointed") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let word-limit = if meta.court_appointed { word-limit-appointed } else { word-limit-other }
  let limit-cite = if meta.court_appointed [Fed. R. App. P. 32(a)(7)(B) (FISC Ct. Rev. R. P. 15(d)(2))] else [Fed. R. App. P. 29(a)(5)]

  // ---- split off the front sections (rendered before the table of contents, or before the body) ----
  let (oa, md1) = take-section(md, "statement regarding oral argument")  // excluded from length: FRAP 32(f)
  let (qp, md2) = take-section(md1, "question presented")
  let (idn, md3) = take-section(md2, "identity and interest")
  let (body-md, add-md) = (md3, none)

  // ---- split off the addendum ----
  let add = body-md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  if add != none {
    add-md = body-md.slice(add.end)
    body-md = body-md.slice(0, add.start)
  }
  if body-md.match(regex("(?m)^#+[ \t]+[^\n]*toa:")) != none {
    panic("fiscr-amicus-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }

  // ---- sections: FISCR R. 14(a)(6)-(8) as applied by R. 15(d)(1), in order ----
  let titles = body-md.matches(regex("(?m)^#[ \t]+(.*?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
  let pos = 0
  for pat in required-sections {
    let rest = titles.slice(pos)
    let k = rest.position(t => t.match(regex(pat)) != none)
    if k == none { panic("fiscr-amicus-brief: " + doc-kind + " needs a section matching `" + pat + "` (in this order; FISCR R. 14(a), 15(d))") }
    pos = pos + k + 1
  }

  // ---- length: FRAP 32(a)(7) / 29(a)(5), with 32(f) exclusions ----
  // Counted: question presented, identity and interest, the body (headings, footnotes, quotations count).
  // Not counted: the statement regarding oral argument (above), the table of contents and authorities,
  // the addendum, the certificates and the signature block (FRAP 32(f)).
  let qp-md = if qp != none { qp } else { "" }
  let idn-md = if idn != none { idn } else { "" }
  let words = count-words(qp-md + "\n\n" + idn-md + "\n\n" + body-md)
  if words > word-limit {
    panic("fiscr-amicus-brief: the brief has " + str(words) + " words; the limit is " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, number-align: center, footer-descent: 30%)   // FISCR R. 9(c)(1), (3), (4)
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

  // ---- cover (page 1, not numbered) ----
  cover(meta)

  // ---- front matter (lowercase roman; the cover is page 1, so the first front page is ii) ----
  set page(numbering: "i")
  if "disclosure" in meta {
    disclosure-page(meta)
    pagebreak()
  }
  let front(s) = {
    set heading(numbering: none)
    cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  if oa != none {
    front(oa)
    pagebreak()
  }
  if qp != none {
    front(qp)
    pagebreak()
  }
  toc-section(add != none)
  pagebreak()
  toa-section(authorities)
  if idn != none {
    pagebreak()
    front(idn)
  }

  // ---- body (arabic from 1) ----
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
    // Footnote definitions stay in the first render call, with the body they belong to: a footnote
    // reference cannot resolve across two render calls, so the tail may not contain one.
    let text-md = body-md.trim(at: end)
    let defs = text-md.matches(regex("(?m)^\\[\\^[^\\]]+\\]:[^\n]*")).map(m => m.text).join("\n\n")
    let main = text-md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:[^\n]*\n?"), "").trim(at: end)
    let breaks = main.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = main.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.contains("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(main.slice(0, cut) + "\n\n" + defs)
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(main + "\n\n" + defs)
      signature-block(meta)
    }
  }

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words, limit-cite)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }

  // ---- addendum (none is required of an amicus brief) ----
  if add-md != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
