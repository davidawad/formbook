// U.S. Court of Appeals for the Sixth Circuit: appellee's brief (answering brief).
//
// Rule-driven and content-agnostic. Requirement IDs (CA6-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"     // CA6-FORM-004: proportional serif; Schola matches the audited exemplar (docs/FONTS.md)
#let type-size = 14pt                      // CA6-FORM-004: FRAP 32(a)(5)(A), 14-point or larger, everywhere.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 31.4pt                 // double spacing (FRAP 32(a)(4)), about 2.24 x type size
#let pitch-single = 20pt                   // headings, quotations, footnotes, TOC/TOA, cover, certificates: single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let heading-size = 15pt                   // section headings, a little larger than the body (whole half points, as Word sets them; at 16 pt
                                           // a heading that opens a page reaches above the top margin in Schola's glyph box)
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let half-measure = 3.25in                 // half the text width (letter, 1 in margins): the right half of the cover and signature
#let counsel-indent = 2.6in               // the cover's counsel block: 40 % of the text width in
#let page-margin = 1in                     // CA6-FORM-002: FRAP 32(a)(4), at least one inch on all four sides.
#let para-indent = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"

// CA6-LEN-001: type-volume limits in words (FRAP 32(a)(7)(B); FRAP 28.1(e)(2)).
#let word-limits = (
  standard: 13000,         // FRAP 32(a)(7)(B)(i): principal brief (the appellee's brief in a single appeal)
  cross-appeal: 15300,     // FRAP 28.1(e)(2)(B)(i): appellee's principal and response brief in a cross-appeal
  reply: 6500,             // FRAP 32(a)(7)(B)(ii): reply brief, half the principal limit
  cross-appeal-reply: 6500, // FRAP 28.1(e)(2)(C): appellee's reply brief in a cross-appeal
)
// The rule each limit comes from, as cited in the certificate of compliance (CA6-CERT-001).
#let word-limit-rule = (
  standard: "32(a)(7)(B)(i)",
  cross-appeal: "28.1(e)(2)(B)(i)",
  reply: "32(a)(7)(B)(ii)",
  cross-appeal-reply: "28.1(e)(2)(C)",
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
/// An italic address or role line, indented under a name; a line too long for its column wraps
/// with the same indent. The block gap equals the single-spaced line gap around it.
#let indented-line(s) = block(above: single-leading, below: single-leading, pad(left: 0.5em, emph(inl(s))))

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
  if key not in meta { panic("ca6-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca6-brief: the sample must start with a YAML frontmatter block") }
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

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)   (CA6-CONT-012)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("ca6-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca6-brief: headings deeper than level 5 are not supported") }
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
  set text(size: type-size, ..edges(pitch-single))   // typst's built-in heading sizes are not used; every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, text(size: heading-size, strong(upper(it.body)))))
  } else if it.numbering == none {
    // Unnumbered sub-headings (addendum entries): bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral (no small capitals: Word and LaTeX synthesize them).
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
  // onto a line of its own; the leader runs from three spaces after the title to the number.
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, 0pt)   // single-spaced rows, no space between them
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
        panic("ca6-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (FRAP 32(a)(2); CA6-COVER-001 to -007)
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[Case No. #need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong[UNITED STATES COURT OF APPEALS\ FOR THE SIXTH CIRCUIT]
  v(gap)
  short-rule
  v(gap)
  // The case title. A side marked `continues: true` follows the one before it without "v." (CA6-COVER-003).
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    if i > 0 and not side.at("continues", default: false) { v(gap * 0.3); [v.]; v(gap * 0.3) }
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: half-measure, inl(side.designation)))
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  if meta.at("oral_argument", default: false) {
    v(gap)
    strong[ORAL ARGUMENT REQUESTED]
  }
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number).
  align(left, pad(left: counsel-indent, {
    set par(hanging-indent: 0pt, spacing: 0pt)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { indented-line(l) }
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
  if g == none { panic("ca6-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Corporate disclosure (6th Cir. R. 26.1; CA6-DISC-001). Filed with the brief, immediately before
// the table of contents. This reproduces the two answers of the clerk's form; the form itself
// (Form 6CA-1) is what is filed.
// ---------------------------------------------------------------------------

#let disclosure-page(meta) = {
  let d = meta.disclosure
  set page(numbering: none, footer: none)
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  align(center, strong[DISCLOSURE OF CORPORATE AFFILIATIONS AND FINANCIAL INTEREST])
  v(14pt)
  [Pursuant to 6th Cir. R. 26.1, #inl(need(d, "party")) makes the following disclosure:]
  block(above: 14pt, hang(1.6em, [#box(width: 1.6em, "1.")Is said party a subsidiary or affiliate of a publicly owned corporation? If yes, list below the identity of the parent corporation or affiliate and the relationship between it and the named party:]))
  block(hang(1.6em, [#h(1.6em)#inl(need(d, "subsidiary"))]))
  block(above: 14pt, hang(1.6em, [#box(width: 1.6em, "2.")Is there a publicly owned corporation, not a party to the appeal, that has a financial interest in the outcome? If yes, list the identity of such corporation and the nature of the financial interest:]))
  block(hang(1.6em, [#h(1.6em)#inl(need(d, "financial_interest"))]))
}

// ---------------------------------------------------------------------------
// Signature and certificates (FRAP 32(g), 25(d), 28(a)(9)(A); CA6-CERT-001 to -003)
// ---------------------------------------------------------------------------

#let signature-line(meta) = [s/ #need(meta, "signature").signer]

/// The filing attorney's block: "s/ Name", the name in capitals, then the office lines.
#let signature-lines(meta) = {
  let sig = need(meta, "signature")
  [#signature-line(meta)]
  linebreak()
  upper(sig.signer)
  for l in sig.at("lines", default: ()) { indented-line(l) }
}

#let signature-block(meta) = {
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: half-measure, {
      [Respectfully submitted,]
      v(16.8pt)
      signature-lines(meta)
    }))
    if "date" in meta { v(11.2pt); meta.date }
  })
}

#let signature-block-compact(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  v(16.8pt)
  signature-lines(meta)
  if "date" in meta { v(11.2pt); meta.date }
}

#let cert-block(body) = block(above: 14pt, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  body
})

/// Certificate of Compliance (FRAP 32(g)(1): the attorney certifies the type-volume limit and states the word count).
#let certificate-of-compliance(meta, words) = {
  let basis = meta.at("word_limit_basis", default: "standard")
  let limit = word-limits.at(basis)
  if words > limit {
    panic("ca6-brief: the brief has " + str(words) + " words; the " + basis + " limit is " + str(limit))
  }
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [I certify that this brief complies with the type-volume limitation of Fed. R. App. P. #word-limit-rule.at(basis). Exclusive of the items exempted by Fed. R. App. P. 32(f), the brief contains #group-digits(words) words.]
  parbreak()
  [The brief has been prepared in a proportionally spaced typeface, #font-family in #box[#str(int(type-size / 1pt))-point] type, which complies with Fed. R. App. P. 32(a)(5) and (6).]
  cert-block(signature-block-compact(meta))
}

/// Certificate of Service (FRAP 25(d)). Served through CM/ECF; non-ECF participants are listed by mail.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  // One unbreakable block: the certificate and its signature never split across pages.
  block(breakable: false, {
    heading(level: 1, numbering: none)[Certificate of Service]
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
    [I certify that on #need(svc, "date"), I electronically filed the foregoing with the Clerk of the Court using the CM/ECF system, which will send notification of such filing to all attorneys of record.]
    let unreg = svc.at("unregistered", default: ())
    if unreg.len() > 0 {
      [I further certify that I have mailed by United States Postal Service the document to the following non-ECF participants:]
      for u in unreg { block(above: 9.8pt, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
    }
    signature-block-compact(meta)
  })
}

#let toc-addendum() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(level: 2)).after(<add-start>), depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca6-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))
  let basis = meta.at("word_limit_basis", default: "standard")
  if basis not in word-limits { panic("ca6-brief: unknown word_limit_basis `" + basis + "`") }

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }

  // ---- oral argument: the statement must be in the brief (6 Cir. R. 34(a); CA6-ORAL-001) ----
  if meta.at("oral_argument", default: false) and body-md.match(regex("(?mi)^#[ \t]+.*oral argument")) == none {
    panic("ca6-brief: oral_argument is set but the brief has no statement in support of oral argument")
  }

  // ---- the statements before the Argument are numbered in roman with the front matter ----
  let prelim = meta.at("preliminary_sections", default: 0)
  let top-starts = body-md.matches(regex("(?m)^#[ \t]+[^#]")).map(m => m.start)
  if prelim > top-starts.len() {
    panic("ca6-brief: preliminary_sections is " + str(prelim) + " but the body has " + str(top-starts.len()) + " sections")
  }
  let cut = if prelim == 0 { 0 } else if prelim < top-starts.len() { top-starts.at(prelim) } else { body-md.len() }
  let prelim-md = body-md.slice(0, cut)
  let main-md = body-md.slice(cut)

  // FRAP 32(f) excludes the statement regarding oral argument from the count: drop any
  // top-level section whose heading names oral argument before counting.
  let bounds = top-starts + (body-md.len(),)
  let counted-md = body-md.slice(0, bounds.first())
  for i in range(top-starts.len()) {
    let sec = body-md.slice(bounds.at(i), bounds.at(i + 1))
    let first-line = sec.split("\n").first()
    if first-line.match(regex("(?i)oral argument")) == none { counted-md += sec }
  }
  let words = count-words(counted-md)
  let limit = word-limits.at(basis)
  if words > limit {
    panic("ca6-brief: the brief has " + str(words) + " words; the " + basis + " limit is " + str(limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // The page number: centered in a single-spaced line box whatever the text around it (Word's footer, LaTeX's
  // plain page style), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign kept
  // with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // "§§ 1651" stays whole: the shared rule binds the last sign to the number, and a line could otherwise end
  // between the two signs (LaTeX and Word never break there).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // A loose list (items apart by blank lines) ends each item with a paragraph break, which the shared list rule cannot
  // set inside its one paragraph per item: the items are made tight first (the layout is the same, no space between
  // items).
  let tighten(b) = if b.func() == [].func() { b.children.filter(c => c.func() != parbreak).join() } else { b }
  show enum: it => if not it.children.any(i => tighten(i.body) != i.body) { it } else {
    enum(tight: true, start: it.start, numbering: it.numbering,
      ..it.children.map(i => if i.has("number") and i.number != none { enum.item(i.number, tighten(i.body)) } else { enum.item(tighten(i.body)) }))
  }
  show list: it => if not it.children.any(i => tighten(i.body) != i.body) { it } else { list(tight: true, ..it.children.map(i => list.item(tighten(i.body)))) }
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // typst's default is 0.85em; FRAP 32(a)(5) allows nothing under 14 pt
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
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // ---- cover ----
  { set text(..edges(pitch-single)); cover(meta) }

  // ---- corporate disclosure, before the table of contents (6 Cir. R. 26.1) ----
  if "disclosure" in meta { disclosure-page(meta) }

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    toc-section(add != none)
    pagebreak()
    toa-section(authorities)
  }

  // ---- statements before the Argument (roman) ----
  if prelim > 0 {
    set page(numbering: "i")
    render(prelim-md)
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
    let text-md = main-md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut2 = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut2)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    if keep {
      render(text-md.slice(0, cut2))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates of counsel (FRAP 32(g); FRAP 25(d)) ----
  set text(..edges(pitch-single))
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  certificate-of-service(meta)

  // ---- addendum (6 Cir. R. 28(b)(1)(A)(i)) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    toc-addendum()
    pagebreak()
    render(add-md)
  }
}
