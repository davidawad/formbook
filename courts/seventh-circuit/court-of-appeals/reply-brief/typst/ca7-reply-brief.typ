// U.S. Court of Appeals for the Seventh Circuit: reply brief.
//
// Rule-driven and content-agnostic. Requirement IDs (CA7-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").
//
// Structure follows the ca9 template (courts/ninth-circuit/court-of-appeals/typst/ca9-brief.typ).
// Numbers differ where the seventh Circuit's rules differ: type size, note size, word limit,
// the cover, the certificate of compliance (Form 6) and the point-heading layout.

#import "@preview/cmarker:0.1.10"
#import "../../../../../lib/typst/tables.typ": leader-row
#import "/lib/typst/word-compat.typ": word-compat

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // Serif, proportionally spaced (FRAP 32(a)(5)(A)); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                      // CA7-FORM-005: 12 points or larger in the body (Cir. R. 32(b)).
#let note-size = 11pt                      // CA7-FORM-005: 11 points or larger in footnotes (Cir. R. 32(b)).
#let body-leading = 1.396em                // CA7-FORM-004: double-spaced (FRAP 32(a)(4)): 27.7 pt baseline pitch on the 12 pt body (README, visual review): 0.909em Liberation Serif ascender-to-descender box + 1.396em.
#let single-leading = 0.516em              // headings, quotations, footnotes, TOC/TOA, cover: single-spaced (1.425em pitch).
#let page-margin = 1in                     // CA7-FORM-003: at least one inch on all four sides (FRAP 32(a)(4)).
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 3                         // point headings (level 2) and their sub-headings (levels 3); no deeper.
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim".
#let word-limit = 7000                     // CA7-LEN-001: reply brief, no more than 7,000 words (Cir. R. 32(c)).

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
  if key not in meta { panic("ca7-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca7-reply-brief: the sample must start with a YAML frontmatter block") }
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
/// Markup characters are removed first; links keep their text. Footnote text counts (FRAP 32(f)).
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

/// Printed label of a numbered heading: point headings I., I. / A. / 1. / a. below them.
/// Level 2 is the point heading (I., II.), level 3 A., level 4 1., level 5 a.
/// The brief's own structure is the same in the whole document; there is no separate Argument section.
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("ca7-reply-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label: point headings at half an inch, each deeper level half an inch more.
#let label-indent(h) = (h.level - 1) * heading-tab

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)
  if it.level == 1 {
    // Section headings (certificates, tables): bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Point headings and sub-headings: the label hangs in a fixed box, the text hangs under the text.
    // Point headings are bold; the deepest levels are bold italic, as in the filed exemplar.
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element. Point headings start at the margin,
/// sub-headings step in half an inch per level; wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  let hang-by = ind + heading-tab
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    leader-row({
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      title
    }, it.page(),
      hang: hang-by, leading: single-leading, dot-gap: 0.16em, lead-gap: 0.8em, gutter: 0.3em, min-leader: 1.5em)))
}

/// Table of contents: point headings and sub-headings of the body (up to the certificates).
#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)).before(<body-end>), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite)))).replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities (FRAP 28(c)), built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ca7-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, leader-row({
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text,
          hang: 0.35in, leading: single-leading, dot-gap: 0.16em, lead-gap: 0.8em, gutter: 0.3em, min-leader: 1.5em))
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

/// One counsel group: names, then the lines under them (office address, telephone).
/// Names and lines are set as given: markdown emphasis in them is honoured, nothing is forced italic.
#let counsel-cell(g) = block(breakable: false, {
  for n in g.names { inl(n); linebreak() }
  for l in g.at("lines", default: ()) { inl(l); linebreak() }
})

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  // (A) the number of the case, centered at the top
  [#need(meta, "case_number")]
  v(gap)
  // (B) the name of the court
  [In the United States Court of Appeals]
  parbreak()
  strong[FOR THE SEVENTH CIRCUIT]
  v(gap)
  // (C) the title of the case
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: 50%, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  // (D) the nature of the proceeding and the court below
  inl(need(meta, "proceeding"))
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [No. #meta.district_court_case]#if "district_court_case" in meta and "judge" in meta [ ]#if "judge" in meta [(#inl(meta.judge))]]
  }
  v(gap)
  short-rule
  v(gap)
  // (E) the title of the brief, identifying the party it is filed for
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // (F) counsel: name, office address, telephone. Two columns; a group goes in the right column when
  // it says `column: right`. `counsel_note` (optional) closes the right column.
  let groups = need(meta, "counsel")
  let first-col = groups.filter(g => g.at("column", default: "left") != "right")
  let second-col = groups.filter(g => g.at("column", default: "left") == "right")
  grid(columns: (1fr, 1fr), column-gutter: 0.3in, align: top,
    align(left, [
      #set par(hanging-indent: 0pt, spacing: 0.5em)
      #for g in first-col { counsel-cell(g); v(0.7em) }
    ]),
    align(left, [
      #set par(hanging-indent: 0pt, spacing: 0.5em)
      #for g in second-col { counsel-cell(g); v(0.7em) }
      #if "counsel_note" in meta { emph(inl(meta.counsel_note)) }
    ]))
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca7-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature, certificates (FRAP 32(g), Form 6; FRAP 25(d))
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
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); inl(l) }
    }))
    if "date" in meta { v(0.8em); [Dated: #meta.date] }
  })
}

#let form-sig-line(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading)
  grid(columns: (1fr, 1fr), column-gutter: 1em,
    [/s/ #need(meta, "signature").signer\ #text(size: type-size)[Signature]],
    [#meta.at("date", default: "")\ Date])
})

/// Certificate of Compliance: Form 6 of the Appendix of Forms (FRAP 32(g)(2)), with the type-volume
/// limit that Circuit Rule 32(c) sets for a reply brief (CA7-CERT-001, CA7-CERT-002).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I certify that this brief complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B), as modified by Cir. R. 32(c). Excluding the parts of the brief exempted by Fed. R. App. P. 32(f), this brief contains #group-digits(words) words.]
  parbreak()
  [I further certify that this brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6), as modified by Cir. R. 32(b). This brief has been prepared in a proportionally spaced typeface using Typst #sys.version.major.#sys.version.minor.#sys.version.patch in #str(int(type-size.pt()))-point #font-family.first() for the body text and #str(int(note-size.pt()))-point #font-family.first() for the footnotes.]
  form-sig-line(meta)
}

/// Certificate of Service (FRAP 25(d)). Only when `service.certificate: true`.
#let certificate-of-service(meta) = {
  let svc = meta.service
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I hereby certify that on #need(meta, "date"), I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the Seventh Circuit by using the CM/ECF system, which will send notice of such filing to all registered CM/ECF users.]
  if "paper_copies" in svc {
    parbreak()
    [Pursuant to Circuit Rule 31(b), upon notice of this Court's acceptance of the electronic brief for filing, I certify that I will cause #svc.paper_copies copies of the above-named brief to be delivered to the Clerk of the Court.]
  }
  let unreg = svc.at("unregistered", default: ())
  if unreg.len() > 0 {
    parbreak()
    strong[Service on case participants who are not registered for electronic filing:]
    parbreak()
    [I certify that I served the foregoing on this date by hand delivery, mail, third-party commercial carrier, or, having obtained prior consent, by email, to the following unregistered participants:]
    for u in unreg { block(above: 0.7em, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
  }
  form-sig-line(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca7-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- the body is everything in the markdown; the words count against the limit ----
  let words = count-words(md)
  if words > word-limit {
    panic("ca7-reply-brief: the reply brief has " + str(words) + " words; Circuit Rule 32(c) allows " + str(word-limit))
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
  // Word paragraph composition (lib/typst/word-compat.typ); the INPUT's `word:` map sets justify/shrink.
  show: word-compat.with(meta.at("word", default: (:)))
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: note-size)
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

  // ---- cover (page 1, not printed) ----
  cover(meta)

  // ---- front matter (roman; the cover counts as page i, so the table of contents is ii) ----
  set page(numbering: "i")
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading).
    // Footnote definitions can sit anywhere in the markdown, so they are set apart first and
    // given to every render call: a reference in one call still finds its definition, and a
    // definition with no reference in a call prints nothing.
    let text-md = md.trim(at: end)
    let defs = text-md.matches(regex("(?m)^\\[\\^[^\\]]+\\]:[^\n]*")).map(m => m.text).join("\n\n")
    let body-md = text-md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:[^\n]*\n?"), "").trim(at: end)
    let breaks = body-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = body-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#")
    let render(s) = cmarker.render(s + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(body-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(body-md)
      signature-block(meta)
    }
  }
  [#metadata(none)<body-end>]

  // ---- certificates (FRAP 32(g); FRAP 25(d)) ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
