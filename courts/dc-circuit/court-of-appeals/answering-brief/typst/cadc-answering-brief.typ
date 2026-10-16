// U.S. Court of Appeals for the District of Columbia Circuit: answering (appellee's) brief.
//
// Rule-driven and content-agnostic. Requirement numbers (CADC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"      // FRAP 32(a)(5): serif, proportional. Handbook IX.A.6 names Century and Times; Century per the filed exemplar. Substitute per docs/FONTS.md.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): at least 14-point, footnotes included.
#let body-leading = 0.94em                 // FRAP 32(a)(4): double-spaced; metric-aligned line box, see README.
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA, certificates: single-spaced.
#let page-margin = 1in                     // FRAP 32(a)(5)(B): margins at least 1 inch on all four sides.
#let para-indent = 0.5in
#let toc-depth = 4
#let toc-page-col = 2.6em                 // TOC: width of the page-number column
#let toa-page-col-max = 1.5in             // TOA: a page list wider than this wraps inside its column (no "passim": Cir. R. 28(a)(2))
#let word-limit = 13000                    // FRAP 32(a)(7)(B)(i): principal brief (appellee's brief included)

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
  if key not in meta { panic("cadc-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cadc-answering-brief: the sample must start with a YAML frontmatter block") }
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

/// 13000 -> "13,000"
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
    else { panic("cadc-answering-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("cadc-answering-brief: headings deeper than level 5 are not supported") }
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
  set text(size: type-size)   // typst's built-in heading sizes are not used; every heading is body size or larger
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
  // The page number has its own column, so a title that fills its last line can never push the
  // number onto a line of its own; the leader fills what is left of the title's last line.
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    grid(columns: (1fr, toc-page-col), align: (left, right + bottom),
      hang(hang-by, {
        h(ind)
        if numbered { box(width: heading-tab, lab) }
        title
        h(0.8em)
        dot-leader
      }),
      it.page())))
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
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cadc-answering-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        // Circuit Rule 28(a)(2): every page is listed; "passim" may not be used.
        let page-text = pages.join(", ")
        // The page list has its own column (its natural width, wrapping only past toa-page-col-max).
        let col = calc.min(measure(page-text).width, toa-page-col-max)
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%,
          grid(columns: (1fr, col), column-gutter: 0.3em, align: (left, right + bottom),
            hang(0.35in, {
              if "name" in a {
                if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
                [,]
                linebreak()
              }
              inl(a.cite)
              h(0.8em)
              dot-leader
            }),
            par(leading: single-leading, first-line-indent: 0pt, justify: false, page-text)))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2))
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
  if "oral_argument" in meta {
    align(left, strong(inl(meta.oral_argument)))
    v(gap * 0.6)
  }
  strong[No. #need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong[UNITED STATES COURT OF APPEALS\ FOR THE DISTRICT OF COLUMBIA CIRCUIT]
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
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [#inl(meta.district_court_case)]#if "district_court_case" in meta and "judge" in meta [; ]#if "judge" in meta [#inl(meta.judge)]]
  }
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number).
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { inl(n); linebreak() }
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
  if g == none { panic("cadc-answering-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Certificate of parties, statutes, signature, certificates of counsel
// ---------------------------------------------------------------------------

#let signature-line(meta) = [/s/ #need(meta, "signature").signer]

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      signature-line(meta)
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
  })
}

#let form-sig-line(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading)
  let sig = need(meta, "signature")
  pad(left: 50%, {
    signature-line(meta)
    linebreak()
    upper(sig.signer)
    if sig.at("lines", default: ()).len() > 0 { linebreak(); h(0.5em); emph(inl(sig.lines.first())) }
  })
})

/// Certificate of parties, rulings and related cases (D.C. Circuit Rule 28(a)(1)) and the
/// statutes-and-regulations statement (D.C. Circuit Rule 28(a)(5)). Text comes from the frontmatter.
#let certificate-of-parties(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Parties, Rulings, and Related Cases]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  inl(need(meta, "certificate_of_parties"))
  if "statutes_and_regulations" in meta {
    heading(level: 1, numbering: none, outlined: false)[Statutes and Regulations]
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
    inl(meta.statutes_and_regulations)
  }
}

/// Certificate of Compliance (FRAP 32(g)). The count is computed from the markdown body.
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I HEREBY CERTIFY pursuant to Fed. R. App. P. 32(g) that this brief contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and D.C. Circuit Rule 32(e)(1), and therefore complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B). This brief has been prepared in #str(int(type-size / 1pt))-point #font-family, a proportionally spaced typeface.]
  form-sig-line(meta)
}

/// Certificate of Service (FRAP 25(d)). Only when `service.certificate: true`.
#let certificate-of-service(meta) = {
  let svc = meta.service
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I HEREBY CERTIFY that I have caused a copy of the foregoing #inl(svc.document) to be served by electronic means, through the Court’s CM/ECF system, upon #inl(svc.served_upon), on this #svc.date.]
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

#let cadc-answering-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "certificate_of_parties") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }
  let words = count-words(body-md)
  if words > word-limit {
    panic("cadc-answering-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(i) allows " + str(word-limit))
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
    set text(size: type-size)   // typst's default is 0.85em; FRAP 32(a)(5) allows nothing under 14 pt
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

  // ---- cover (page i, not printed) ----
  cover(meta)

  // ---- front matter: certificate of parties is page ii (roman), then contents and authorities ----
  set page(numbering: "i")
  counter(page).update(2)
  certificate-of-parties(meta)
  pagebreak()
  toc-section(add != none)
  pagebreak()
  toa-section(authorities)

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

  // ---- certificates of counsel ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }

  // ---- addendum (D.C. Circuit Rule 28(a)(5)) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    toc-addendum()
    pagebreak()
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
