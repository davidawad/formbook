// California Court of Appeal: respondent's (answering) brief.
//
// Rule-driven and content-agnostic. Requirement IDs (CALCTAPP-...) refer to ../rules.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"          // CALCTAPP-FORM-002: a conventional roman face. Vendored in /fonts.
#let type-size = 13pt                      // CALCTAPP-FORM-003: 13-point or larger, footnotes included.
#let body-leading = 0.49em                 // CALCTAPP-FORM-004: about 23.4 pt pitch at 13 pt (the exemplar measures 23.5 pt), double-style, well over 1.5 spacing.
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA: single-spaced.
#let margin-side = 1.5in                   // CALCTAPP-FORM-005: at least 1.5 in left and right.
#let margin-tb = 1in                       // CALCTAPP-FORM-005: at least 1 in top and bottom.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let word-limit = 14000                    // CALCTAPP-LEN-001: rule 8.204(c)(1), computer-produced brief.
#let court-name = "IN THE COURT OF APPEAL OF THE STATE OF CALIFORNIA"   // CALCTAPP-COVER-002

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
  if key not in meta { panic("calctapp-brief: missing required metadata field `" + key + "`") }
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
  if m == none { panic("calctapp-brief: the sample must start with a YAML frontmatter block") }
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
    else { panic("calctapp-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("calctapp-brief: headings deeper than level 5 are not supported") }
  }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. Level 2 sits on the margin; each further level steps in
/// half an inch (Argument point I. on the margin, its A. at the first step, as in the exemplar).
#let label-indent(h) = (h.level - 2) * heading-tab

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // typst's built-in heading sizes are not used; every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.4em, below: 1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Point and sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
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
#let toc-page-width = 2.2em             // page-number column of the table of contents

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  let hang-by = ind + heading-tab
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    // Two columns: the title and its leader wrap inside the first, the page number sits in the second,
    // level with the last line, so a long title never pushes its page number onto a line of its own.
    grid(columns: (1fr, toc-page-width), column-gutter: 0.3em,
      hang(hang-by, {
        h(ind)
        if numbered { box(width: heading-tab, lab) }
        title
        h(0.8em)
        dot-leader
      }),
      align(right + bottom, it.page()),
    )))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  // The rule sits below the descender of "g", so no part of the heading hangs under it into the first entry.
  align(right, block(above: 0.3em, below: 0.75em, strong(underline(offset: 0.3em)[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
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
        panic("calctapp-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        if first { h(1fr); strong(underline(offset: 0.3em)[Page(s)]) }
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
// Cover (rule 8.204(b)(10); CALCTAPP-COVER-001 to -007)
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: 0em, spacing: 0.35em, justify: false)
  set text(top-edge: "ascender", bottom-edge: "baseline")
  set align(center)
  strong[No. #need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong(court-name)
  v(gap * 0.5)
  strong(upper(need(meta, "district")))
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); linebreak() }
    inl(side.designation)
    parbreak()
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  // Trial court, judge and trial court number (rule 8.204(b)(10)).
  inl(need(meta, "proceeding"))
  parbreak()
  [#inl(need(meta, "trial_judge")) #sym.dash.en Case No. #need(meta, "trial_case_number")]
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel and the party each one represents (rule 8.204(b)(10)). The lead firm is centered
  // across the page, as in the exemplar; the others share two columns.
  // A parenthetical on a counsel line (a bar number) is kept whole: it moves to the next line
  // in a narrow column rather than splitting.
  {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    show regex("\\([^()]+\\)"): it => box(it)
    let groups = need(meta, "counsel")
    let group-block(g) = block(breakable: false, {
      for n in g.names { n; linebreak() }
      for l in g.at("lines", default: ()) { emph(inl(l)); linebreak() }
    })
    align(center, group-block(groups.first()))
    let rest = groups.slice(1)
    if rest.len() > 0 {
      v(gap)
      let cols = calc.min(rest.len(), 2)
      grid(columns: (1fr,) * cols, column-gutter: 1.5em, row-gutter: 1.2em, ..rest.map(g => align(left, group-block(g))))
    }
  }
  v(gap)
  emph(inl(need(meta, "counsel_for")))
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("calctapp-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Certificate of interested entities (rule 8.208; first page after the cover)
// ---------------------------------------------------------------------------

#let interested-page(meta) = {
  let ie = meta.at("interested_entities", default: "none")
  let supplemental = meta.at("certificate_type", default: "initial") == "supplemental"
  heading(level: 1, numbering: none)[Certificate of Interested Entities or Persons]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em, justify: false)
  set align(left)
  [Case Name: #inl(need(meta, "short_caption")) \ Court of Appeal No. #need(meta, "case_number")]
  parbreak()
  [(Check One) #h(1em) #checkbox(not supplemental) Initial Certificate #h(1.5em) #checkbox(supplemental) Supplemental Certificate]
  parbreak()
  block(breakable: false, hang(1.6em, {
    checkbox(ie == "none")
    h(0.6em)
    [There are no interested entities or persons to list in this Certificate per California Rules of Court, rule 8.208(d).]
  }))
  if ie != "none" {
    block(breakable: false, hang(1.6em, {
      checkbox(true)
      h(0.6em)
      [Interested entities or persons are listed below:]
    }))
    for e in ie {
      block(above: 0.7em, breakable: false, hang(1.6em, {
        h(1.6em)
        [#inl(e.name) (#e.party) #inl(e.interest)]
      }))
    }
  }
  parbreak()
  [The undersigned certifies that the above listed persons or entities (corporations, partnerships, firms or any other association, but not including government entities or their agencies), have either (i) an ownership interest of 10 percent or more in the party if an entity; or (ii) a financial or other interest in the outcome of the proceeding that the justices should consider in determining whether to disqualify themselves, as defined in rule 8.208(e)(2).]
  parbreak()
  let sig = need(meta, "signature")
  block(breakable: false, above: 1em, {
    set par(leading: single-leading, spacing: 0.35em)
    [Date: #meta.at("date", default: "__________")]
    v(1.2em)
    [s/ #sig.signer]
    linebreak()
    upper(sig.signer)
    for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Signature, certificates (rule 8.204(c)(1), (c)(3))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if "date" in meta { [Date: #meta.date] ; v(0.8em) }
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      if "firm" in sig { linebreak(); upper(sig.firm) }
      v(1.2em)
      [By: #box(width: 2.6in, line(length: 100%, stroke: 0.5pt))]
      linebreak()
      sig.signer
      for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
    }))
  })
}

#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [The foregoing #inl(need(meta, "brief_title")) complies with the type-volume limitation of California Rules of Court, rule 8.204(c)(1) because it contains #group-digits(words) words, excluding the parts of the brief exempted by rule 8.204(c)(3), and was prepared in 13-point #font-family, a proportionally spaced typeface, using a word-processing program. The electronic brief was subject to a virus scan and no virus was detected prior to its submission.]
  block(breakable: false, width: 100%, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    let sig = need(meta, "signature")
    [Dated: #meta.at("date", default: "__________")]
    v(1.2em)
    pad(left: 50%, {
      sig.signer
      for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
    })
  })
}

/// Proof of service (rule 8.212). Only when `service` is given.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [At the time of service, I was over 18 years of age and not a party to this action. I am employed in the County of #svc.county, State of California. My business address is #svc.address.]
  parbreak()
  [On the date set forth below, I served one true copy of the following document(s) described as #inl(need(meta, "brief_title")) on the interested parties in this action as follows:]
  parbreak()
  for m in svc.methods { inl(m); parbreak() }
  for u in svc.served {
    block(above: 0.7em, breakable: false, pad(left: 0.5in, {
      set par(spacing: 0.35em)
      inl(u.name)
      parbreak()
      inl(u.address)
    }))
  }
  [I declare under penalty of perjury under the laws of the State of California that the foregoing is true and correct.]
  parbreak()
  [Executed on #meta.at("date", default: "__________") at #svc.place, California.]
  block(breakable: false, width: 100%, above: 1.2em, pad(left: 50%, [#svc.declarant]))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let calctapp-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "district", "caption", "proceeding", "trial_judge", "trial_case_number",
            "brief_title", "short_caption", "counsel", "counsel_for", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- word count (rule 8.204(c)(1): 14,000 words including footnotes) ----
  let words = count-words(md)
  if words > word-limit {
    panic("calctapp-brief: the brief has " + str(words) + " words; rule 8.204(c)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: (x: margin-side, y: margin-tb), number-align: center, footer-descent: 30%)
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
    set text(size: type-size)   // typst's default is 0.85em; rule 8.204(b)(4) counts footnotes too
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
  show regex("[§¶]+ \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (page 1, number suppressed) ----
  cover(meta)

  // ---- certificate of interested entities (page 2) ----
  pagebreak(weak: true)
  interested-page(meta)

  // ---- table of contents and authorities (arabic, continuing from the cover) ----
  set page(numbering: "1")
  pagebreak(weak: true)
  toc-section()
  pagebreak(weak: true)
  toa-section(authorities)

  // ---- body ----
  pagebreak(weak: true)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
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

  // ---- certificates of counsel ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if "service" in meta {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
