// U.S. Court of Appeals for the Sixth Circuit: reply brief (FRAP 28(c); 6 Cir. R. 32).
//
// Rule-driven and content-agnostic. Requirement IDs (CA6-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // CA6-FORM-005: proportionally spaced serif; Times New Roman substitute per docs/FONTS.md
#let type-size-pt = 14                     // CA6-FORM-005: 14-point or larger; footnotes at the same size (6 Cir. checklist).
#let type-size = type-size-pt * 1pt
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 31.4pt                 // CA6-FORM-004: double spacing, about 2.24 x type size
#let pitch-single = 20pt                   // headings, quotations, footnotes, TOC/TOA, cover, certificates: single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let counsel-indent = 2.6in                // the cover's counsel and the signatures: 40 % of the text width in
#let page-margin = 1in                     // CA6-FORM-004: at least one inch on all four sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 2                         // sections and point headings (FRAP 28(c): table of contents)
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let word-limit = 6500                     // CA6-LEN-001: a reply brief is half the principal-brief limit (FRAP 32(a)(7)(B)(ii))
#let court-name = "IN THE UNITED STATES COURT OF APPEALS FOR THE SIXTH CIRCUIT"  // CA6-COVER-002

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
  if key not in meta { panic("ca6-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca6-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// Why not simply put the tag in front: when a citation begins at the start of a line, typst
/// files a tag that sits before the first word under the PREVIOUS line, which may be on the
/// previous page, so the table of authorities would cite the wrong page.
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
/// Markup characters are removed first; links keep their text. Headings, footnotes and
/// quotations count (FRAP 32(f)); the cover, tables and signature block are not in the source.
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
// Headings: numbering scheme and styles (CA6-CONT-012)
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
    else { panic("ca6-reply-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca6-reply-brief: headings deeper than level 5 are not supported") }
  }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. In the Argument the point heading (level 2) hangs from the
/// margin, so its sub-headings step in half an inch per level from there. Elsewhere the first
/// sub-heading level already starts half an inch in.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 2 } else { 1 }
  (h.level - first) * heading-tab
}

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size, ..edges(pitch-single))
  if it.level == 1 {
    // Section headings: bold, capitals, centered (exemplar: INTRODUCTION, ARGUMENT, CONCLUSION).
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else {
    // Point and sub-headings: the label hangs at its own indent, the text starts half an inch
    // further in and the wrapped lines align with the text. Bold; italic below level 3.
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (FRAP 28(c))
// ---------------------------------------------------------------------------


/// One table-of-contents row, built from a heading element. Wrapped lines hang under the title.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  // The page number has its own column (listing-row); the leader runs from three spaces after the title to it.
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, 0pt)   // single-spaced rows, no space between them
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

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ca6-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
            [, ]
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), 0.35in, 9.8pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); CA6-COVER-001 to -006)
// ---------------------------------------------------------------------------

#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

/// One line of a counsel or signature block: markdown inline, never indented (a block of lines is a stack).
#let line-of(s) = {
  set par(first-line-indent: 0pt, spacing: 0pt, leading: single-leading)
  inl(s)
}

#let cover-body(meta, gap) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  set align(center)
  v(gap * 0.6)
  [No. #need(meta, "case_number")]   // CA6-COVER-001: the case number, centered at the top
  v(gap)
  // CA6-COVER-002: the name of the court, in a measure that wraps after "APPEALS" (a width, not a break)
  block(width: 4.4in, strong(court-name))
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")   // CA6-COVER-003: the title of the case
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    inl(side.designation)
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))       // CA6-COVER-004: nature of the proceeding and the court below
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))   // CA6-COVER-005: the brief's title, identifying the party
  v(gap)
  short-rule
  v(gap)
  // CA6-COVER-006: name, office address and telephone number of counsel (FRAP 32(a)(2)(F)).
  align(left, pad(left: counsel-indent, {
    set par(hanging-indent: 0pt, spacing: 0pt)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        stack(dir: ttb, spacing: 0pt,
          ..g.names.map(n => line-of(n)),
          ..g.at("lines", default: ()).map(l => line-of(l)),
        )
      })
      if gi < groups.len() - 1 { v(gap * 0.5) }
    }
  }))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca6-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature and certificates (6 Cir. R. 25(d)(1), 32(a); FRAP 25(d), 32(g))
// ---------------------------------------------------------------------------

/// Signature blocks after the Conclusion: one per signing attorney (6 Cir. R. 25(d)(1): s/Name).
#let signature-block(meta) = block(breakable: false, above: 19.6pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [Respectfully submitted,]
  for sig in need(meta, "signatures") {
    block(width: 100%, above: 19.6pt, breakable: false, pad(left: counsel-indent, stack(
      dir: ttb, spacing: 0pt,
      [s/ #sig.signer],
      ..sig.at("lines", default: ()).map(l => line-of(l)),
    )))
  }
})

/// The compliance certificate's signature: the first signing attorney (CA6-SIG-001).
#let cert-signature(meta) = {
  let sig = need(meta, "signatures").first()
  block(width: 100%, above: 22.4pt, breakable: false, pad(left: counsel-indent, stack(
    dir: ttb, spacing: 0pt,
    [s/ #sig.signer],
    sig.signer,
  )))
}

/// Certificate of Compliance (FRAP 32(g)(1)). 6 Cir. R. 32(a): it immediately follows the
/// signature at the end of the brief, so it is not started on a new page (CA6-CERT-001).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  block(breakable: false, {
    [This reply brief complies with the type-volume limitation of Fed.~R.~App.~P.~32(a)(7)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed.~R.~App.~P.~32(f).]
    parbreak()
    [This reply brief complies with the typeface requirements of Fed.~R.~App.~P.~32(a)(5) and the type-style requirements of Fed.~R.~App.~P.~32(a)(6) because it has been prepared in a proportionally spaced typeface, #box[#(type-size-pt)-point] #font-family.first().]
    cert-signature(meta)
  })
}

/// Certificate of Service (FRAP 25(d)). Only when `service.certificate: true`: a brief served
/// through CM/ECF to registered users needs none (CA6-CERT-002).
#let certificate-of-service(meta) = {
  let svc = meta.service
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  block(breakable: false, {
    [I certify that I electronically filed and served this #inl(need(meta, "brief_title")) using the Court's CM/ECF system upon #inl(svc.upon) on #need(meta, "date").]
    cert-signature(meta)
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca6-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "signatures") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  let words = count-words(md)
  if words > word-limit {
    panic("ca6-reply-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(ii) allows " + str(word-limit) + " for a reply brief")
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signatures").first().signer,
  )
  // The page number: centered in a single-spaced line box (Word's footer, LaTeX's plain page style).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, a section sign kept with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // "§§ 1651" stays whole (the shared rule binds the last sign to the number)
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // the court's checklist: footnotes at the same size as the text
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // a note is never split across pages (LaTeX and Word keep it whole)
    block(breakable: false)[#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 12.6pt)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("60(b)(5)"), and never between a
  // section sign and its number. Unbreakable boxes; the extracted text is unchanged.
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
    toc-section()
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is kept
    // together with it (unless that last block is a heading or a footnote definition).
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

  // ---- certificates of counsel: the compliance certificate follows the signature (6 Cir. R. 32(a)) ----
  set text(..edges(pitch-single))
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
