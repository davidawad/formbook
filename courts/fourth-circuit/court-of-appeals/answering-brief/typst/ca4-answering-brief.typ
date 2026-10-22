// U.S. Court of Appeals for the Fourth Circuit: appellee's (answering) brief.
//
// Rule-driven and content-agnostic. Requirement IDs (CA4-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // CA4-FORM-004: serif, proportional. Times New Roman (court's preferred typefaces; exemplar): substitute per docs/FONTS.md.
#let type-size = 14pt                      // CA4-FORM-004: 14-point or larger, everywhere.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 25.9pt                 // FRAP 32(a)(4): double-spaced (the baseline pitch this template has always set)
#let pitch-single = 16pt                   // headings, quotations, footnotes, TOC/TOA, cover, certificates: single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let page-margin = 1in                     // CA4-FORM-002
#let para-indent = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let type-volume-limit = 13000             // CA4-LIMIT-001: FRAP 32(a)(7)(B)(i), appellee's principal brief.

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

/// Content in the right half of the text width, left-aligned (the designation on the cover, the signature). A pad of
/// 50 % would be relative to the padded content and move with its width.
#let right-half(body) = align(left, grid(columns: (1fr, 1fr), [], body))

#let need(meta, key) = {
  if key not in meta { panic("ca4-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A form check box: a ruled box around a literal X, or around the X's room when not checked (the cross-engine
/// model: Word and LaTeX draw the same box around the same letter).
#let checkbox(checked) = box(stroke: 0.7pt, inset: (x: 1pt, y: 1pt), baseline: 1pt, if checked [X] else [#hide[X]])

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca4-brief: the sample must start with a YAML frontmatter block") }
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

/// Only the Argument's sub-headings are numbered (I., A., 1., a.). Everywhere else a
/// sub-heading is an unnumbered bold line (the exemplar's Statement of the Case). CA4-CONT-012.
#let numbered(h) = h.level >= 2 and in-argument(h.location())

/// Printed label of a numbered heading: I. / A. / 1. / a.
#let heading-label(h) = {
  let c = counter(heading).at(h.location())
  let n = c.at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("ca4-brief: headings deeper than level 5 are not supported") }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a numbered sub-heading's label. Labels in the Argument start at the margin plus
/// one half inch for level 3 and step in half an inch per level.
#let label-indent(h) = (h.level - 2) * heading-tab

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size, ..edges(pitch-single))   // typst's built-in heading sizes are not used; every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, text(size: 16pt, strong(upper(it.body)))))
  } else if not numbered(it) {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else if it.level == 2 {
    // Point headings of the Argument: bold small capitals, centered, with the roman numeral.
    block(width: 100%, sticky: true, above: 16.8pt, below: 14pt,
      align(center, strong(heading-label(it) + [ ] + it.body)))
  } else {
    // Argument sub-headings: label in a fixed box, text hangs under the text.
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      strong(it.body)
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
  let num = numbered(hd)
  let ind = if num { label-indent(hd) } else if hd.level >= 2 { (hd.level - 1) * heading-tab } else { 0pt }
  // The Argument's centered point heading has no body indent in the table; its label starts at the margin.
  if num and hd.level == 2 { ind = 0pt }
  let lab = if num { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  // The page number has its own column (listing-row), so a title that fills its last line can never push the number
  // onto a line of its own; the leader runs from the end of the title to the number.
  listing-row(hd.location(), {
    h(ind)
    if num { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, if hd.level == 1 { 8.4pt } else { 4.9pt })
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, strong(underline(offset: 0.2em)[Page])))
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
        panic("ca4-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        if first { h(1fr); strong(underline(offset: 0.2em)[Page(s)]) }
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
// Disclosure statement, cover (FRAP 26.1, FRAP 32(a)(2))
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[No. #need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR THE FOURTH CIRCUIT]
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    right-half(inl(side.designation))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))
  if "judge" in meta {
    parbreak()
    inl(meta.judge)
  }
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number). Lines are roman, as in the
  // court's filed briefs; a line the markdown italicises stays italic.
  right-half({
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { inl(l); linebreak() }
      })
    }
  })
  v(gap)
  grid(columns: (1fr, 1fr), align: (left, right),
    [#need(meta, "date")], inl(need(meta, "party_line")))
  v(gap * 0.6)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca4-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

/// The FRAP 26.1 disclosure statement, as the court's form asks it (CA4-DISC-001).
/// One yes-or-no answer per question, in the order the form asks them.
#let disclosure-questions = (
  [Is party/amicus a publicly held corporation or other publicly held entity?],
  [Does party/amicus have any parent corporations?],
  [Is 10% or more of the stock of a party/amicus owned by a publicly held corporation or other publicly held entity?],
  [Is there any other publicly held corporation or other publicly held entity that has a direct financial interest in the outcome of the litigation?],
  [Is party a trade association? (amici curiae do not complete this question)],
  [Does this case arise out of a bankruptcy proceeding?],
  [Is this a criminal case in which there was an organizational victim?],
)

#let disclosure-page(meta) = page(numbering: none, footer: none, {
  let d = need(meta, "disclosure")
  let answers = d.answers
  if answers.len() != disclosure-questions.len() {
    panic("ca4-brief: disclosure.answers needs one yes or no for each of the " + str(disclosure-questions.len()) + " questions")
  }
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 12.6pt, justify: false)
  align(center, [
    #strong[UNITED STATES COURT OF APPEALS FOR THE FOURTH CIRCUIT]
    #v(8.4pt)
    #strong[DISCLOSURE STATEMENT]
    #v(8.4pt)
    No. #need(meta, "case_number")
  ])
  v(14pt)
  [Pursuant to FRAP 26.1 and Local Rule 26.1, #inl(d.party), who is #d.role, makes the following disclosure:]
  for (i, q) in disclosure-questions.enumerate() {
    let a = answers.at(i)
    if a not in ("yes", "no") { panic("ca4-brief: disclosure answer " + str(i + 1) + " must be `yes` or `no`") }
    block(above: 12.6pt, breakable: false, {
      [#(i + 1)\. #q]
      linebreak()
      h(1.6em)
      [YES #h(0.4em) #checkbox(a == "yes") #h(2.4em) NO #h(0.4em) #checkbox(a == "no")]
    })
  }
  block(above: 22.4pt, breakable: false, right-half([
    /s/ #d.signer \
    #d.date
  ]))
})

// ---------------------------------------------------------------------------
// Signature, certificates (FRAP 32(g), FRAP 25(d))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    right-half({
      [Respectfully submitted,]
      v(16.8pt)
      for l in sig.at("lead", default: ()) { l; linebreak() }
      v(8.4pt)
      [/s/ #sig.signer]
      for l in sig.at("lines", default: ()) { linebreak(); l }
    })
  })
}

#let signature-only(meta) = block(above: 22.4pt, breakable: false, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading)
  right-half([/s/ #need(meta, "signature").signer])
})

/// Certificate of Compliance, FRAP 32(g)(1) (CA4-CERT-001, -002). The word count is the one the
/// template computed from the body (headings, text and footnotes; not the cover, tables or signature).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [1\.#h(0.5em)This brief complies with the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because this brief contains #group-digits(words) words, excluding the parts of the brief exempted by Rule 32(f).]
  parbreak()
  [2\.#h(0.5em)This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type style requirements of Rule 32(a)(6) because this brief has been prepared in a proportionally spaced typeface, #font-family.first(), in fourteen-point type.]
  signature-only(meta)
}

/// Certificate of Service, FRAP 25(d) (CA4-CERT-003). Only when `service.certificate: true`.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [I hereby certify that on this #svc.date, the foregoing #inl(need(meta, "brief_title")) was served on #svc.served_on.]
  signature-only(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca4-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "date", "party_line", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- length (FRAP 32(a)(7)(B)(i)) ----
  let words = count-words(md)
  if words > type-volume-limit {
    panic("ca4-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(i) allows " + str(type-volume-limit))
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
  // A loose list (items apart by a blank line) has items that end in a paragraph break, which xengine's list item, one
  // paragraph, cannot hold: the breaks are dropped (xengine gives list items no space of their own either way).
  let ends-in-break(c) = c.body.func() == [].func() and c.body.children.any(x => x.func() == parbreak)
  show enum: it => if not it.children.any(ends-in-break) { it } else {
    enum(numbering: it.numbering, start: it.start, ..it.children.map(c => {
      let body = if ends-in-break(c) { c.body.children.filter(x => x.func() != parbreak).join() } else { c.body }
      if c.at("number", default: none) == none { enum.item(body) } else { enum.item(c.number, body) }
    }))
  }
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

  // ---- cover, then the disclosure statement when the case has one ----
  { set text(..edges(pitch-single)); cover(meta) }
  if "disclosure" in meta { disclosure-page(meta) }

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
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
  set text(..edges(pitch-single))
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  // The certificate of service follows the certificate of compliance on the same page when it fits
  // (the exemplar does the same); it is not a separate page.
  if meta.at("service", default: (:)).at("certificate", default: false) {
    v(22.4pt)
    certificate-of-service(meta)
  }
}
