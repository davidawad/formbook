// U.S. Court of Appeals for the Eighth Circuit: brief (doc type set in the parameter block).
//
// Rule-driven and content-agnostic. Requirement IDs (FRAP ..., 8th Cir. R. ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that differs between the three copies)
// ---------------------------------------------------------------------------

#let doc-kind = "opening-brief"
#let word-limit = 13000                    // FRAP 32(a)(7)(B)(i): principal brief. Reply: half (32(a)(7)(B)(ii)).
#let required-sections = (                 // FRAP 28(a)(4)-(9), in this order (regexes on lowercased titles).
  "^(jurisdictional statement|statement of (the )?jurisdiction)",
  "^(statement of the )?issues",
  "^statement of (the )?case",
  "^summary of (the )?argument",
  "^argument$",
  "^conclusion$",
)
#let needs-standard-of-review = true       // FRAP 28(a)(8)(B)
#let addendum = "separate"                 // 8th Cir. R. 28A(g): every appellant's brief has an addendum, filed as its
                                           // own PDF (Clerk's "Pointers on Preparing Briefs", item 6). "separate": none here.

// ---------------------------------------------------------------------------
// Parameters (the only other numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-name = "United States Court of Appeals for the Eighth Circuit"   // FRAP 32(a)(2)(B)
#let font-family = ("Times New Roman", "Liberation Serif")   // FRAP 32(a)(5)(A): proportionally spaced, serif; the rule
                                           // names no face, so Times metrics (docs/FONTS.md). Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, everywhere, footnotes included.
#let heading-size = 16pt                   // section headings, a little larger than the body (whole points: Word has no others)
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 28pt                   // FRAP 32(a)(4): double-spaced, 2 x the 14 pt type
#let pitch-single = 17pt                   // headings, quotations, footnotes, TOC/TOA, cover, signature, certificates: single-spaced
#let pitch-heading = 20pt                  // section headings (16 pt), single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
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
  if key not in meta { panic("ca8-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca8-brief: the sample must start with a YAML frontmatter block") }
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
    else { panic("ca8-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca8-brief: headings deeper than level 5 are not supported") }
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
  set text(size: type-size, ..edges(pitch-single))   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, text(size: heading-size, ..edges(pitch-heading), strong(upper(it.body)))))
  } else if it.numbering == none {
    // Unnumbered sub-headings (addendum entries): bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral. (Not small capitals: Word and LaTeX synthesize those
    // differently, so the line breaks could not agree across engines; docs/EVAL-LOOP.md, "Cross-engine gate".)
    block(width: 100%, sticky: true, above: 16.8pt, below: 14pt,
      align(center, strong(heading-label(it) + [ ] + it.body)))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

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
  // The page number has its own column (listing-row), so a title that fills its last line can never push the number
  // onto a line of its own; the leader runs from the end of the title to the number.
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, if hd.level == 1 { 8.4pt } else { 4.9pt })
}

#let toc-section(has-addendum) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, strong(underline[Page])))
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
        panic("ca8-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 14pt } else { 19.6pt }, below: 2.8pt, sticky: true, {
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
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), 0.35in, 9.8pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2)(A)-(F))
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

/// Set in the right half of the text block, left-aligned: it starts at mid-page whatever its width (a `pad(left: 50%)`
/// is half the padded content's own width, so its left edge moved with the longest line).
#let right-half(body) = block(width: 100%, inset: (left: 50%), align(left, body))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[No. #need(meta, "case_number")]              // (A) the number of the case, centered at the top
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
    right-half(inl(side.designation))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))                         // (D) the nature of the proceeding and the court below
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [Case No. #meta.district_court_case]#if "district_court_case" in meta and "judge" in meta [; ]#if "judge" in meta [#inl(meta.judge)]]
  }
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))         // (E) the title of the brief
  v(gap)
  short-rule
  v(gap)
  // (F) name, office address and telephone number of counsel.
  // One column of counsel per group, side by side (as the filed Eighth Circuit covers set them).
  {
    set par(hanging-indent: 0pt, spacing: 7pt)
    let groups = need(meta, "counsel")
    grid(
      columns: (1fr,) * groups.len(), column-gutter: 0.25in, align: left,
      ..groups.enumerate().map(((gi, g)) => block(breakable: false, {
        for n in g.names { n; linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { emph(inl(l)); linebreak() }
      })),
    )
  }
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca8-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Corporate disclosure statement (FRAP 26.1; 8th Cir. R. 26.1A: in front of the TOC)
// ---------------------------------------------------------------------------

#let disclosure-page(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Corporate Disclosure Statement]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  inl(meta.disclosure)
}

// ---------------------------------------------------------------------------
// Signature, certificates (FRAP 32(g); Form 6)
// ---------------------------------------------------------------------------

/// A check box: a ruled box around an "X" (Word's bordered run, so every engine sets the same text in it; no symbol
/// font, so no fallback face).
#let checkbox(checked) = box(
  stroke: 0.6pt, inset: (x: 1pt), outset: (y: 0.6pt),
  if checked [X] else { hide("\u{a0}\u{a0}\u{a0}") },
)

/// A checked option of Form 6: 22.4 pt in, the box in a 22.4 pt column, the text hanging after it; 11.2 pt above and
/// below.
#let option-row(body) = block(above: 11.2pt, below: 11.2pt, breakable: false,
  par(hanging-indent: 44.8pt, first-line-indent: 0pt, { h(22.4pt); box(width: 22.4pt, checkbox(true)); body }))

#let signature-line(meta) = [/s/ #need(meta, "signature").signer]

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    right-half({
      [Respectfully submitted,]
      v(16.8pt)
      signature-line(meta)
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(7pt); emph(inl(l)) }
    })
    if "date" in meta { v(11.2pt); meta.date }
  })
}

#let form-sig-line(meta) = block(above: 22.4pt, breakable: false, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: 0pt)
  let sig = need(meta, "signature")
  right-half({
    signature-line(meta)
    linebreak()
    [Attorney for #inl(sig.at("for", default: ""))]
    if "date" in meta { linebreak(); [Dated: #meta.date] }
  })
})

/// Certificate of Compliance, Form 6 wording (FRAP 32(g)(1)-(2); no local disk rule applies).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [1\. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f):]
  option-row[this document contains #group-digits(words) words.]
  [2\. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because:]
  option-row[this document has been prepared in a proportionally spaced typeface using #need(meta, "word_processor") in #int(type-size.pt())-point #need(meta, "typeface") roman type.]
  // 8th Cir. R. 28A(h): counsel certifies that the brief (and the addendum) was scanned for viruses.
  [3\. The brief has been scanned for viruses and it is virus free.]
  form-sig-line(meta)
}

/// Certificate of Service. Only when `service.certificate: true`. Filed through CM/ECF the Notice of
/// Docket Activity is the service on registered filers.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [I hereby certify that on #meta.at("date", default: "__________"), I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the Eighth Circuit by using the appellate CM/ECF system, which will send notification of such filing to all counsel of record.]
  let unreg = meta.service.at("unregistered", default: ())
  if unreg.len() > 0 {
    parbreak()
    [I further certify that on the same date I served the foregoing by mail on the following persons who are not registered for electronic filing:]
    for u in unreg { block(above: 9.8pt, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
  }
  form-sig-line(meta)
}

#let toc-addendum() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(level: 2)).after(<add-start>), depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca8-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "word_processor", "typeface") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }

  // ---- summary of the case (8th Cir. R. 28A(i)(1)): the first item, one page, on the first front page ----
  // Pulled out of the body: it is not a numbered section, and it sits before the disclosure statement.
  let sum = body-md.match(regex("(?mi)^#[ \t]+summary of (the )?case[^\n]*$"))
  let summary-md = ""
  if sum != none {
    let after = body-md.slice(sum.end)
    let nxt = after.match(regex("(?m)^#[ \t]"))
    summary-md = if nxt == none { after } else { after.slice(0, nxt.start) }
    body-md = body-md.slice(0, sum.start) + if nxt == none { "" } else { after.slice(nxt.start) }
  }
  if body-md.match(regex("(?m)^#+[ \t]+[^\n]*toa:")) != none {
    panic("ca8-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }
  if addendum == "required" and add == none {
    panic("ca8-brief: 8th Cir. R. 28A(g) requires an addendum; add a `# Addendum` section or set addendum = \"separate\"")
  }

  // ---- sections: FRAP 28, in order ----
  let titles = body-md.matches(regex("(?m)^#[ \t]+(.*?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
  let pos = 0
  for pat in required-sections {
    let rest = titles.slice(pos)
    let k = rest.position(t => t.match(regex(pat)) != none)
    if k == none { panic("ca8-brief: " + doc-kind + " needs a section matching `" + pat + "` (in this order; FRAP 28)") }
    pos = pos + k + 1
  }
  // FRAP 28(a)(8)(B): a statement of the standard of review for each issue (under its own heading or
  // inside the discussion of the issue; a heading naming the standard is accepted for either).
  let standard-found = lower(body-md).contains("standard of review") or body-md.match(regex("(?mi)^#+[ \t]+[^\n]*standard")) != none
  if needs-standard-of-review and not standard-found {
    panic("ca8-brief: FRAP 28(a)(8)(B) requires a statement of the applicable standard of review")
  }

  // ---- length: FRAP 32(a)(7), with 32(f) exclusions ----
  let words = count-words(strip-oral-argument(summary-md + "\n\n" + body-md))
  if words > word-limit {
    panic("ca8-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // FRAP 32(a)(4). The page number: centered in a single-spaced line box whatever the text around it (Word's footer,
  // LaTeX's plain page style), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign or
  // pilcrow kept with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set heading(numbering: none)
  // Footnotes: 8.5 pt from the text to the separator and 7 pt from it to each note, 15.5 pt in all.
  set footnote.entry(
    gap: 7pt, clearance: 8.5pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // typst's default is 0.85em; FRAP 32(a)(5)(A) allows nothing under 14 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // a note is never split across pages (LaTeX and Word keep it whole: xengine.sty, the reference.docx)
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 12.6pt)
    it.body
  }))
  // A URL breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows: each part is
  // a box, so the PDF text keeps the author's characters. Without this typst breaks an overlong URL at any character,
  // which TeX and Word do not; the LaTeX and Word filters set the same break points (docs/EVAL-LOOP.md).
  show regex("https?://\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  { set text(..edges(pitch-single)); cover(meta) }

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  if summary-md != "" {
    heading(level: 1, numbering: none, outlined: false)[Summary of the Case]
    cmarker.render(summary-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
    pagebreak()
  }
  if "disclosure" in meta {
    disclosure-page(meta)
    pagebreak()
  }
  {
    set text(..edges(pitch-single))
    toc-section(add != none)
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
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
  }

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }

  // ---- addendum (when included in this file: at the rear, with its own table of contents) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    { set text(..edges(pitch-single)); toc-addendum() }
    pagebreak()
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
