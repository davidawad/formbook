// U.S. Court of Appeals for Veterans Claims: Secretary's principal brief (Vet. App. R. 28(b), 32).
//
// Rule-driven and content-agnostic. Requirement IDs (CAVC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// CAVC-FORM-004: proportionally spaced, 13 pt or larger. Liberation Sans, vendored in /fonts: the metrics of Arial,
// the face of the Secretary's briefs (CAVC-FORM-011). The docx names the same vendored family.
#let font-family = "Liberation Sans"
#let type-size = 14pt                      // CAVC-FORM-004: 13-point or larger. 14 pt, everywhere (footnotes too).
#let heading-size = 16pt                   // section headings: a little larger than the body (a whole half point)
// Cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"): the typst and Word renders break every line
// and page alike. Every line is a box of a fixed height (its pitch) with the baseline at 0.8 of it, the boxes stack
// with no leading, and the space between blocks is the larger of the space below the one and above the other
// (dropped at the top of a page). That is Word's exact line spacing.
#let pitch-double = 29.4pt                 // CAVC-FORM-003: body text double spaced, 2.1 x type size
#let pitch-single = 17pt                   // headings, quotations, footnotes, TOC/TOA, caption page: single-spaced
#let pitch-heading = 20pt                  // section headings (16 pt)
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let page-margin = 1in                     // CAVC-FORM-001: at least one inch from all edges.
#let para-indent = 0.5in
#let half-text = 3.25in                    // the right half of the 6.5 in text block: designations, counsel, signatures
#let toc-depth = 4
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim" (convention).
#let page-limit = 30                       // CAVC-LEN-001: Rule 32(e), principal brief, not counting front matter.

// Required level-1 sections, in order. Rule 28(b)(1): the Secretary's brief conforms to Rule 28(a),
// but a statement of the issues or of the case need not be made, so neither is required here
// (write one as `# Issue Presented` or `# Statement of the Case` if the Secretary gives one).
// The TOC and TOA are generated (Rule 28(a)(1), (2)). Rule 28(a)(5): the argument begins with a
// summary. Rule 28(b)(2)-(3): the argument states any agreement with Board error and the relief sought.
#let required-sections = (
  "summary of the argument",  // Rule 28(a)(5), first part of the argument division
  "argument",                 // Rule 28(a)(5); Rule 28(b)(2)-(3)
  "conclusion",               // Rule 28(a)(6)
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

#let need(meta, key) = {
  if key not in meta { panic("cavc-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cavc-answering-brief: the sample must start with a YAML frontmatter block") }
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
    else { panic("cavc-answering-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("cavc-answering-brief: headings deeper than level 5 are not supported") }
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

// Spacing above and below each kind of block, in points (the larger of below/above applies between two blocks).
#let space = (
  section: (above: 21pt, below: 15.4pt),
  point: (above: 16.8pt, below: 14pt),
  sub: (above: 15.4pt, below: 12.6pt),
  plain: (above: 16.8pt, below: 12.6pt),
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, justify: false)
  set text(size: type-size, ..edges(pitch-single))   // typst's built-in heading sizes are not used
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, ..space.section,
      align(center, text(size: heading-size, ..edges(pitch-heading), strong(upper(it.body)))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, ..space.plain, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral. Not small capitals: Word and LaTeX would synthesize
    // different ones (the engines must set the same glyphs).
    block(width: 100%, sticky: true, ..space.point,
      align(center, strong(heading-label(it) + [ ] + it.body)))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, ..space.sub, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (Rule 28(a)(1), (2); Form 18)
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
  let lw = if lab == none { 0pt } else { heading-tab }
  listing-row(hd.location(), {
    h(ind)
    if lab != none { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + lw, if hd.level == 1 { 8.4pt } else { 4.9pt })
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
  ("rba", "Citations to the Record Before the Agency:"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body. Record citations
/// (kind `rba`) are listed after the law, in the order given by their `sort` key (Rule 28(a)(2)).
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cavc-answering-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Caption page (Rule 32(c); Form 2): court, case number, title of the case, brief heading,
// counsel. The caption page is not numbered and is not counted toward the page limit.
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}

#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[Vet. App. No. #need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR VETERANS CLAIMS]
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: half-text, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  let proceeding = need(meta, "proceeding")
  if proceeding != "" {
    strong(inl(proceeding))
    v(gap)
    short-rule
    v(gap)
  }
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel (Rule 32(f): signature, printed name, address and telephone number).
  align(left, pad(left: half-text, {
    set par(hanging-indent: 0pt)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, above: 5pt, below: 0pt, {
        for n in g.names { par(inl(n)) }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { par({ h(0.5em); emph(inl(l)) }) }
      })
    }
  }))
  v(gap)
  double-rule
}

/// The caption page is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole page fits is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("cavc-answering-brief: the caption page does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature block and certificate of service (Rules 25(a), 32(f))
// ---------------------------------------------------------------------------

#let signature-line(meta) = [s/ #need(meta, "signature").signer]

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: half-text, {
      [Respectfully submitted,]
      v(16.8pt)
      signature-line(meta)
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
      linebreak()
      h(0.5em)
      emph(inl(need(meta, "phone")))
    }))
    if "date" in meta { v(11.2pt); meta.date }
  })
}

/// Rule 25(a): a document is submitted with proof of service. The wording below is drafted for
/// this template (the rules prescribe no form); the date and method come from the `service` block.
#let certificate-of-service(meta) = {
  let s = need(meta, "service")
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  [I certify that on #s.date, I filed the foregoing #plain(inl(need(meta, "brief_title"))) with the Clerk of the Court and served it on counsel for the other party by #s.method.]
  block(width: 100%, breakable: false, above: 22.4pt, pad(left: half-text, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading)
    signature-line(meta)
    linebreak()
    upper(need(meta, "signature").signer)
  }))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

/// Fails the build when a level-1 section required by Rule 28(a) is missing or out of order.
#let check-sections(md) = {
  let h1s = md.matches(regex("(?m)^#[ \t]+(.+?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
  let i = 0
  for want in required-sections {
    let found = false
    while i < h1s.len() and not found {
      found = h1s.at(i).starts-with(want)
      i += 1
    }
    if not found {
      panic("cavc-answering-brief: Vet. App. R. 28 needs a level-1 section `# " + want + "` in this order")
    }
  }
}

#let cavc-answering-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "service") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  check-sections(md)

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", Vet. App. No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // The page number: centered in a single-spaced line box whatever the text around it (Word's footer), so it sits
  // at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    // Rule 32(b) gives the footnotes the body typeface and size: the marker, a space, then the note (Word's)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
    [#super(num) #note.body]
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt)
    it.body
  }))
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- caption page (not numbered) ----
  { set text(..edges(pitch-single)); cover(meta) }

  // ---- front matter (lowercase roman, Rule 32(d)) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    toc-section()
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1, Rule 32(d)); the page limit counts from here to the signature ----
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata("body") <body-start>]
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading). Footnote definitions are split off and handed
    // to every render call, so their references resolve wherever the paragraph is placed.
    let defs = md.matches(regex("(?m)^\\[\\^[^\\]]+\\]:[^\n]*$")).map(m => m.text).join("\n\n")
    let text-md = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:[^\n]*(\n|$)"), "").trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#")
    let render(s) = cmarker.render(s + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }
  [#metadata("end") <body-end>]
  context {
    let s = query(<body-start>).first().location().page()
    let e = query(<body-end>).first().location().page()
    if e - s + 1 > page-limit {
      panic("cavc-answering-brief: the brief runs " + str(e - s + 1) + " pages; Vet. App. R. 32(e) allows " + str(page-limit))
    }
  }

  // ---- certificate of service (Rule 32(d): roman numerals, not counted toward the limit) ----
  pagebreak(weak: true)
  set page(numbering: "i")
  counter(page).update(1)
  certificate-of-service(meta)
}
