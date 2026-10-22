// U.S. Court of Appeals for the Fifth Circuit: principal (opening) brief.
//
// Rule-driven and content-agnostic. Requirement IDs (CA5-...) refer to ../README.md, which
// cites the court's brief checklist and FRAP 32. No case-specific text, no coordinates measured
// off any filed brief, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // CA5-FORM-005: proportional serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // CA5-FORM-005: 14 point or larger for text.
#let footnote-size = 12pt                  // CA5-FORM-005: 12 point or larger for footnotes.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 30.8pt                 // CA5-FORM-004: double spaced, 2.2 x the type size
#let pitch-single = 17pt                   // quotations, headings, TOC/TOA, cover, signature: single spaced
#let pitch-note = 14pt                     // footnotes (12 pt), single spaced
#let gap-single = 7pt                      // between single-spaced paragraphs (half a line)
#let page-margin = 1in                     // CA5-FORM-003: 1 inch on all sides.
#let para-indent = 0.5in
#let title-size = 16pt                     // section titles: bold capitals, a little larger than the text
                                           // (typst's built-in heading sizes are not used).
#let heading-gap = 28pt                    // space above a heading: more than the double-spaced
                                           // line gap, so the heading does not run into the text above.
#let label-width = 0.5in                   // the box a heading label ("I.", "A.") sits in.
#let label-gutter = 0.1in                  // between the label box and the heading text
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim"
#let word-limit = 13000                    // CA5-LEN-001: principal brief, FRAP 32(a)(7)(B)(i).
#let front-titles = (
  "Certificate of Interested Persons",     // CA5-CONT-001 (5th Cir. R. 28.2.1): before the TOC
  "Statement Regarding Oral Argument",    // CA5-CONT-002 (5th Cir. R. 28.2.3): before the TOC
)

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

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca5-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
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

/// Split the markdown body into sections at each level-1 heading. Each section is
/// (title, md) with md starting with its own "# " line.
#let split-sections(body) = {
  let parts = ("\n" + body).split("\n# ").slice(1)
  parts.map(p => (title: p.split("\n").first().trim(), md: "# " + p))
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme (CA5-CONT-010)
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
    else { panic("ca5-opening-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca5-opening-brief: headings deeper than level 5 are not supported") }
  }
}

// ---------------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------------

/// Cover (CA5-CONT-003, 5th Cir. checklist 3(a)): case number, court, case title, nature of the
/// proceeding and court below, brief title, counsel. The cover is one page; the spacing is the
/// only thing that adapts: when the lines with their gaps would not fit, the gaps shrink alike as far
/// as the page needs (a long caption), and the counsel stand at the foot of the page.
/// One single-spaced line or paragraph of the cover, centered, `above` clear of the one before.
#let cover-line(above, body) = block(width: 100%, above: above, below: 0pt, align(center, body))

/// The cover's lines; every gap scaled by `s` (0 to 1), the counsel after a fill when `fill`.
#let cover-body(meta, s, fill) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  cover-line(0pt)[No. #meta.case_number]
  cover-line(18pt * s)[In the United States Court of Appeals for the Fifth Circuit]
  for (i, side) in meta.caption.enumerate() {
    for (j, n) in side.names.enumerate() { cover-line(if j == 0 { if i == 0 { 18pt * s } else { 8.4pt * s } } else { 0pt }, inl(n)) }
    cover-line(2.8pt * s, inl(side.designation))
    if i < meta.caption.len() - 1 { cover-line(8.4pt * s)[v.] }
  }
  cover-line(15.6pt * s, inl(meta.proceeding))
  cover-line(18pt * s, strong(inl(meta.brief_title)))
  if fill { v(1fr) }
  for (gi, g) in meta.counsel.enumerate() {
    for (j, n) in g.names.enumerate() { cover-line(if j == 0 and gi > 0 { 7pt * s } else { 0pt }, inl(n)) }
    for l in g.lines { cover-line(0pt, inl(l)) }
  }
  if meta.at("date", default: none) != none { cover-line(14pt * s, meta.date) }
}

#let cover(meta) = layout(size => {
  let full = measure(block(width: size.width, cover-body(meta, 1, false))).height
  let bare = measure(block(width: size.width, cover-body(meta, 0, false))).height
  // the gaps shrink, all alike, as far as the page needs (LaTeX: shrinkable glue)
  let s = if full <= size.height or full == bare { 1 } else { calc.max(0, (size.height - bare) / (full - bare)) }
  cover-body(meta, s, true)
})

/// One single-spaced line of the signature, 3 in from the margin.
#let sig-line(above, body) = block(width: 100%, above: above, below: 0pt, sticky: true,
  pad(left: 3in, { set par(first-line-indent: 0pt); body }))

/// Signer lines (CA5-CONT-006): "/s/ Name", the name, and the firm/title/contact lines.
#let signer-block(sig, above: 14pt) = block(breakable: false, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  sig-line(0pt)[/s/ #sig.signer]
  sig-line(7pt, sig.signer)
  for l in sig.lines { sig-line(0pt, inl(l)) }
})

/// The closing signature after the Conclusion: date and "Respectfully submitted," (CA5-CONT-006).
#let closing-signature(meta) = block(breakable: false, above: 28.8pt, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if meta.at("date", default: none) != none {
    block(above: 0pt, below: 0pt, sticky: true, par[Dated: #meta.date])
  }
  sig-line(5.6pt)[Respectfully submitted,]
  signer-block(meta.signature, above: 8.4pt)
})

/// Title of a front table (contents, authorities): set like a level-1 section heading.
#let table-title(t) = block(width: 100%, above: 0pt, below: 16.8pt,
  align(center, text(size: title-size, ..edges(pitch-single), strong(upper(t)))))

/// Table of contents: every level-1 to level-4 heading of the body, with its printed label and
/// the body page it starts on (CA5-CONT-004). Built from the headings, never typed in. Each row
/// (listing-row) keeps a page column of its own, so a wrapped entry never pushes its page number
/// onto a line of its own; the leader runs from the end of the entry to the number.
#let toc-page() = context {
  let hs = query(heading).filter(h => plain(h.body).trim() not in front-titles)
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  table-title[Table of Contents]
  for hd in hs {
    let pg = str(counter(page).at(hd.location()).first())
    let ind = (hd.level - 1) * 0.4in
    if hd.level >= 2 {
      listing-row(hd.location(), [#h(ind)#box(width: label-width, heading-label(hd))#hd.body], pg,
        toc-page-col, ind + label-width, 11.2pt)
    } else {
      listing-row(hd.location(), hd.body, pg, toc-page-col, 0pt, 11.2pt)
    }
  }
}

/// Table of authorities: from the `authorities:` registry, grouped (cases; then statutes and other
/// authorities), each with the body pages it is cited on. Cited on 7 or more pages: "passim".
#let toa-page(auth) = context {
  let cites = query(<toa-cite>)
  let pages-for(key) = {
    let ps = ()
    for c in cites {
      if c.value.key == key {
        let p = counter(page).at(c.location()).first()
        if p not in ps { ps.push(p) }
      }
    }
    ps.sorted()
  }
  let entry(key) = {
    let a = auth.at(key)
    let ps = pages-for(key)
    if ps.len() == 0 { return none }
    let pstr = if ps.len() >= passim-threshold { "passim" } else { ps.map(str).join(", ") }
    let name = if a.at("name", default: "") != "" [#emph(a.name), ] else []
    listing-row(none, [#name#a.cite], pstr, toa-page-col, 0.35in, 11.2pt)
  }
  let keys-of(kinds) = auth.keys().filter(k => auth.at(k).kind in kinds)
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  table-title[Table of Authorities]
  let group-title(t) = block(above: 16.8pt, below: 11.2pt, sticky: true, par(strong(t)))
  let case-keys = keys-of(("case",)).sorted(key: k => lower(auth.at(k).name))
  let other-keys = keys-of(("constitution", "statute", "regulation", "rule", "other"))
  if case-keys.len() > 0 {
    group-title[Cases]
    for k in case-keys { entry(k) }
  }
  if other-keys.len() > 0 {
    group-title[Statutes & Other Authorities]
    for k in other-keys.sorted(key: k => lower(auth.at(k).cite)) { entry(k) }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca5-opening-brief(meta, body) = {
  let auth = meta.at("authorities", default: (:))
  let sections = split-sections(body)
  let front = sections.filter(s => s.title in front-titles)
  let certs = sections.filter(s => s.title.starts-with("Certificate of") and s.title not in front-titles)
  let main = sections.filter(s => s.title not in front-titles and s.title not in certs.map(c => c.title))

  // CA5-CONT-007: the word count is computed from the body markdown (the main sections, their
  // footnotes, not the cover, tables, oral argument statement, signature or certificates; FRAP 32(f)).
  let main-md = main.map(s => s.md).join("\n")
  let n-words = count-words(main-md)
  if n-words > word-limit {
    panic("ca5-opening-brief: the brief has " + str(n-words) + " words; the limit is " + str(word-limit) + " (FRAP 32(a)(7)(B)(i))")
  }
  let words = group-digits(n-words)
  let cert-md = certs.map(s => s.md.replace("{{words}}", words))

  // The page number: centered in a single-spaced line box whatever the text around it (Word's footer, LaTeX's
  // plain page style), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, numbering: none, footer-descent: 30%,
    footer: context if page.numbering != none {
      align(center, text(..edges(pitch-single), counter(page).display(page.numbering)))
    })
  // Typst steps the heading counter only when numbering is set; the labels are drawn by the show rules below.
  set heading(numbering: "1")
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: para-indent)
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign kept
  // with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // Widows and orphans are allowed: typst's widow control moves a line to the next page but leaves that line's
  // footnote behind (a note on the page before its reference). The latex and docx engines allow them too.
  set text(costs: (widow: 0%, orphan: 0%))
  // A loose list (blank lines between the items) gives each item a paragraph break that xengine's list paragraph
  // cannot hold: the item is set as that one paragraph without it (the number in a half-inch box, the text hanging,
  // no space between items: the layout xengine and the other engines' "List Item" paragraphs set).
  let tight(b) = if b.has("children") { b.children.filter(c => c.func() != parbreak).join() } else { b }
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(above: 0pt, below: 0pt, par(hanging-indent: para-indent, first-line-indent: 0pt,
        { box(width: para-indent, numbering(it.numbering, n)); tight(item.body) }))
      n += 1
    }
  }
  show list: it => for item in it.children {
    block(above: 0pt, below: 0pt, par(hanging-indent: para-indent, first-line-indent: 0pt,
      { box(width: para-indent, [•]); tight(item.body) }))
  }

  // ---- rules for the parts of the markdown ----
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in auth {
        panic("ca5-opening-brief: citation key `" + key + "` is not in authorities:")
      }
      [#metadata((key: key))<toa-cite>#it.body]
    } else {
      it
    }
  }

  // Footnotes: 12 pt in 14 pt line boxes, 14 pt clear of the text under a 30 % rule, 7 pt between notes; the mark
  // and a quarter em before the text.
  set footnote.entry(gap: gap-single, clearance: 14pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: 0.5in, right: 0.5in, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: gap-single)
    it.body
  }))

  // Every heading is set at the body size or larger: typst's built-in heading sizes are not used.
  show heading: set text(size: type-size, ..edges(pitch-single))

  show heading.where(level: 1): it => block(width: 100%, above: heading-gap, below: 12.6pt, sticky: true,
    align(center, par(first-line-indent: 0pt, text(size: title-size, strong(upper(it.body))))))

  // Levels 2 to 5: the label sits in a fixed box and the text hangs beside it; each level steps
  // in by one label width. Bold at levels 2 and 3.
  let sub-heading(it, below, bold) = context block(width: 100%, above: heading-gap, below: below, sticky: true,
    pad(left: (it.level - 2) * label-width, par(first-line-indent: 0pt, hanging-indent: label-width + label-gutter, {
      let s = if bold { strong } else { x => x }
      box(width: label-width + label-gutter, s(heading-label(it)))
      s(it.body)
    })))
  show heading.where(level: 2): it => sub-heading(it, 12.6pt, true)
  show heading.where(level: 3): it => sub-heading(it, 11.2pt, true)
  show heading.where(level: 4): it => sub-heading(it, 11.2pt, false)
  show heading.where(level: 5): it => sub-heading(it, 11.2pt, false)

  // ---- cover (unnumbered) ----
  cover(meta)

  // ---- front matter (roman numerals) ----
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  for s in front {
    if s.title == "Certificate of Interested Persons" {
      // single spaced, half a line between paragraphs (the exemplar's form)
      set text(..edges(pitch-single))
      set par(spacing: gap-single)
      cmarker.render(s.md, raw-typst: false, smart-punctuation: true)
      signer-block(meta.signature)
    } else {
      cmarker.render(s.md, raw-typst: false, smart-punctuation: true)
    }
    pagebreak(weak: true)
  }
  toc-page()
  pagebreak(weak: true)
  toa-page(auth)
  pagebreak(weak: true)

  // ---- body (arabic numerals from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  // The closing signature never stands alone on a page: the brief's last paragraph is kept
  // together with it. Footnote definitions at the end of the body are not that paragraph; they
  // stay in the first render, with the references that use them. A last block that is a heading
  // is not kept.
  let blocks = main-md.trim(at: end).split(regex("\n[ \t]*\n"))
  let is-def(b) = b.starts-with("[^") or b.starts-with(" ") or b.starts-with("\t")
  let i = blocks.len() - 1
  while i > 0 and is-def(blocks.at(i)) { i -= 1 }
  let tail = blocks.at(i)
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
  if i > 0 and not tail.starts-with("#") and not is-def(tail) {
    render((blocks.slice(0, i) + blocks.slice(i + 1)).join("\n\n"))
    block(breakable: false, { render(tail); closing-signature(meta) })
  } else {
    render(main-md)
    closing-signature(meta)
  }

  // ---- certificates: each on its own page, numbered in the body sequence ----
  for (i, c) in cert-md.enumerate() {
    pagebreak(weak: true)
    // Certificate paragraphs and recipient lists are set flush left.
    { set par(first-line-indent: 0pt); cmarker.render(c, raw-typst: false, smart-punctuation: true) }
    signer-block(meta.signature)
  }
}
