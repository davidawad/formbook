// U.S. Bankruptcy Appellate Panel of the Tenth Circuit (bap10): reply brief of the appellant (FRBP 8014(c); 15 pages or 6,500 words).
//
// Rule-driven and content-agnostic. Requirement IDs (FRBP ..., 10th Cir. BAP L.R. ...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that differs between the three copies)
// ---------------------------------------------------------------------------

#let doc-kind = "reply-brief"             // FRBP 8014(c): appellant's reply; must comply with (a)(2)-(3) (cover, TOC, TOA)
#let word-limit = 6500                     // FRBP 8015(a)(7)(B)(ii): half the principal-brief type-volume limit
#let required-sections = ()                // no section is mandated beyond the cover, TOC and TOA (8014(c))
#let needs-standard-of-review = false

// ---------------------------------------------------------------------------
// Parameters that do not differ by doc type (each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-name = "United States Bankruptcy Appellate Panel of the Tenth Circuit"   // FRBP 8015(a)(2)(B)
#let font-family = "Liberation Serif"     // FRBP 8015(a)(5)(A): proportionally spaced, serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // FRBP 8015(a)(5)(A) requires 14-point; 10th Cir. BAP L.R. 8015-1(b) accepts 12-point. 14 satisfies both.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). The pitches are the template's own: Liberation
// Serif's line box (0.909em) plus its leading, 2.245em double and 1.425em single, at 14 pt.
#let pitch-double = 31.4pt                 // FRBP 8015(a)(4): double-spaced, about 2.24 x type size
#let pitch-single = 20pt                   // headings, quotations, footnotes, TOC/TOA, cover, certificates: single-spaced (FRBP 8015(a)(4))
#let heading-size = 16pt                   // section headings, a little larger than the body (whole half points: Word has no others)
#let pitch-heading = 23pt                  // their single-spaced line (1.425 x 16 pt)
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let page-margin = 1in                     // FRBP 8015(a)(4): at least one inch on all four sides.
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
  if key not in meta { panic("bap10-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("bap10-brief: the sample must start with a YAML frontmatter block") }
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

/// Drop a "statement regarding oral argument" section: FRBP 8015(g) excludes it from the length limit.
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
    else { panic("bap10-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("bap10-brief: headings deeper than level 5 are not supported") }
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
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral (no small capitals: Liberation Serif has none, and Word
    // would synthesize them).
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

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, strong(underline[Page])))
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

// (one expression: in markup a `#let` ends at the line end, so a `.replace` on the next line would be stray text)
#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite)))).replace(regex("[^a-z0-9 ]"), "").replace(regex(" +"), " ").trim()

/// Table of authorities (FRBP 8014(a)(3)), built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("bap10-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (FRBP 8015(a)(2)(A)-(F); 10th Cir. BAP L.R. 8015-1(a): the court's caption satisfies (A)-(D))
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

/// One party block of the case title: names (one centered line each), then its designation.
#let caption-side(side) = {
  for name in side.names { inl(name); parbreak() }
  align(left, pad(left: 50%, inl(side.designation)))
}

#let cover-body(meta, gap) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[BAP No. #need(meta, "case_number")]           // (A) the number of the case, centered at the top
  v(gap)
  double-rule
  v(gap)
  strong(upper(court-name))                            // (B) the name of the court
  v(gap)
  short-rule
  v(gap)
  // (C) the title of the case (FRBP 8003(d)(2)): the debtor, if any, then the parties.
  if "in_re" in meta {
    caption-side(meta.in_re)
    v(gap * 0.3)
  }
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    caption-side(side)
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  if "bankruptcy" in meta {
    v(gap * 0.5)
    align(right, inl(meta.bankruptcy))
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
  // (F) name, office address, telephone number and email address of counsel.
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 7pt)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"), need(meta, "email")) }
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
  if g == none { panic("bap10-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Disclosure statement (FRBP 8014(a)(1), 8012; placed before the TOC)
// ---------------------------------------------------------------------------

#let disclosure-page(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Disclosure Statement]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  inl(meta.disclosure)
}

// ---------------------------------------------------------------------------
// Signature, certificates (FRBP 8015(h); Form 417C wording is not reproduced, see README)
// ---------------------------------------------------------------------------

/// A check box: a ruled box around an "X" when checked, around three spaces' width when not (Word's bordered run,
/// so every engine sets the same text in it).
#let checkbox(checked) = box(
  stroke: 0.6pt, inset: (x: 1pt), outset: (y: 0.6pt),
  if checked [X] else { hide("\u{a0}\u{a0}\u{a0}") },
)

#let signature-line(meta) = [/s/ #need(meta, "signature").signer]

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(16.8pt)
      signature-line(meta)
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
    if "date" in meta { v(11.2pt); meta.date }
  })
}

/// Certificate of Compliance (FRBP 8014(a)(10), 8015(h)): word count from the body, excluding the
/// items listed in FRBP 8015(g) and L.R. 8015-1(d).
#let certificate-of-compliance(meta, words, limit) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [1. This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g) and 10th Cir. BAP L.R. 8015-1(d), it contains no more than #group-digits(limit) words. The brief contains #group-digits(words) words, as counted by the drafting software.]
  block(above: 11.2pt, below: 11.2pt, breakable: false, pad(left: 22.4pt, {
    box(width: 21pt, checkbox(true))
    [this brief contains #group-digits(words) words.]
  }))
  [2. This brief complies with the typeface requirements of Fed. R. Bankr. P. 8015(a)(5) and 10th Cir. BAP L.R. 8015-1(b) because it has been prepared in a proportionally spaced typeface using #need(meta, "word_processor") in #int(type-size.pt())-point #need(meta, "typeface") roman type.]
  block(width: 100%, above: 22.4pt, breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading)
    let sig = need(meta, "signature")
    align(left, pad(left: 50%, {
      signature-line(meta)
      linebreak()
      [Attorney for #inl(sig.at("for", default: ""))]
      if "date" in meta { linebreak(); [Dated: #meta.date] }
    }))
  })
}

/// Statement of Related Cases (10th Cir. BAP L.R. 8014-1): the LAST page of the brief.
#let related-cases-page(meta) = {
  let rc = need(meta, "related_cases")
  heading(level: 1, numbering: none, outlined: false)[Statement of Related Cases]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  if rc.at("status", default: "none") == "none" {
    [The filer knows of no related case pending before the United States Supreme Court, any United States Court of Appeals, any United States District Court, or the Bankruptcy Appellate Panel.]
  } else {
    [The following related case(s) are pending before the court(s) listed. A related case involves substantially the same litigants and substantially the same fact pattern or legal issues as this appeal.]
    for c in rc.at("cases", default: ()) {
      block(above: 9.8pt, breakable: false, pad(left: 0.5in, inl(c)))
    }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let bap10-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "email", "signature", "word_processor", "typeface", "related_cases") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off anything after a `# Statement of Related Cases` heading: it is generated, not authored ----
  let rel = md.match(regex("(?mi)^#[ \t]+statement of related cases[ \t]*$"))
  let body-md = if rel == none { md } else { md.slice(0, rel.start) }
  if body-md.match(regex("(?m)^#+[ \t]+[^\n]*toa:")) != none {
    panic("bap10-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }

  // ---- sections: FRBP 8014(a)(4)-(9) (opening) or 8014(b) (appellee), in order ----
  let titles = body-md.matches(regex("(?m)^#[ \t]+(.*?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
  let pos = 0
  for pat in required-sections {
    let rest = titles.slice(pos)
    let k = rest.position(t => t.match(regex(pat)) != none)
    if k == none { panic("bap10-brief: " + doc-kind + " needs a section matching `" + pat + "` (in this order; FRBP 8014)") }
    pos = pos + k + 1
  }
  // FRBP 8014(a)(5): a statement of the applicable standard of review for each issue.
  let standard-found = lower(body-md).contains("standard of review") or body-md.match(regex("(?mi)^#+[ \t]+[^\n]*standard")) != none
  if needs-standard-of-review and not standard-found {
    panic("bap10-brief: FRBP 8014(a)(5) requires a statement of the applicable standard of review")
  }

  // ---- length: FRBP 8015(a)(7)(B), with 8015(g) exclusions ----
  let words = count-words(strip-oral-argument(body-md))
  if words > word-limit {
    panic("bap10-brief: the brief has " + str(words) + " words; FRBP 8015(a)(7)(B) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", BAP No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // FRBP 8015(a)(4). The page number: centered in a single-spaced line box whatever the text around it (Word's
  // footer), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign kept
  // with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A loose list (items apart by blank lines) gives each item a paragraph break of its own; xengine sets an item as
  // one paragraph after its number, so the break is dropped (the items still follow one another at the body pitch).
  show enum: it => { show parbreak: none; it }
  show list: it => { show parbreak: none; it }
  // A doubled sign stays with the number after it ("§§ 157"), as a single one does (xengine); the Word filter binds
  // them with a no-break space.
  show regex("[§¶]{2} \\S+"): it => box(it)
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // L.R. 8015-1(b): footnotes the same size as the body text
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 12.6pt)
    it.body
  }))
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
  {
    set text(..edges(pitch-single))
    if "disclosure" in meta {
      disclosure-page(meta)
      pagebreak()
    }
    toc-section()
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

  // ---- certificate of compliance, then the statement of related cases as the last page (L.R. 8014-1) ----
  set text(..edges(pitch-single))
  pagebreak(weak: true)
  certificate-of-compliance(meta, words, word-limit)
  pagebreak(weak: true)
  related-cases-page(meta)
}
