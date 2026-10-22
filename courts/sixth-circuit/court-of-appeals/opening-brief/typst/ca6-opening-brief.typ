// U.S. Court of Appeals for the Sixth Circuit: appellant's principal brief.
//
// Rule-driven and content-agnostic. The governing rules are FRAP 26.1, 28, 30, 32 and
// 6 Cir. R. 26.1, 28, 30(g), 32; ../README.md records the rule text, the URL and the date verified.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // FRAP 32(a)(5)(A): proportionally spaced, serif; Times New Roman, Liberation Serif its metric twin (docs/FONTS.md)
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, everywhere.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 31.4pt                 // FRAP 32(a)(4): double-spaced, about 2.24 x type size
#let pitch-single = 20pt                   // headings, quotations, footnotes, TOC/TOA, cover, certificates: single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let heading-size = 16pt                   // section headings, a little larger than the body (whole half points, as Word sets them)
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let page-margin = 1in                     // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let half-measure = 3.25in                 // half the text width (letter, 1 in margins): the right half of the cover and signature
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let word-limit = 13000                    // FRAP 32(a)(7)(B)(i); 6 Cir. R. 28(e)(2)(A)(i)

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
    // Unnumbered sub-headings: bold, left.
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

/// Table of contents. Lists every outlined heading (the front matter's Table of Authorities and
/// Statement in Support of Oral Argument, the brief's sections, and the certificates and designation).
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
// Cover (FRAP 32(a)(2); 6 Cir. R. 28(d))
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[No. #need(meta, "case_number")]
  v(gap)
  double-rule
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR THE SIXTH CIRCUIT]
  v(gap)
  short-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: half-measure, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  short-rule
  v(gap)
  inl(need(meta, "proceeding"))
  v(gap)
  short-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number). One group sits in the right
  // half; several groups are set in two columns across the measure, as covers conventionally are.
  {
    set par(hanging-indent: 0pt, spacing: 7pt)
    let groups = need(meta, "counsel")
    let group-block(gi, g) = block(breakable: false, {
      for n in g.names { n; linebreak() }
      let lines = g.at("lines", default: ())
      if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
      for l in lines { indented-line(l) }
    })
    if groups.len() == 1 {
      align(left, pad(left: half-measure, group-block(0, groups.first())))
    } else {
      align(left, grid(columns: (1fr, 1fr), column-gutter: 14pt, row-gutter: 11.2pt,
        ..groups.enumerate().map(((gi, g)) => group-block(gi, g))))
    }
  }
  // Optional line naming the party counsel represent (frontmatter `counsel_for:`), centred under
  // the counsel block as is conventional; FRAP 32(a)(2)(F) does not require it.
  if "counsel_for" in meta { v(gap * 0.5); inl(meta.counsel_for) }
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
// Signature, disclosure, certificates, designation
// ---------------------------------------------------------------------------

#let signature-line(meta) = [/s/ #need(meta, "signature").signer]

/// The signature block after the Conclusion (6 Cir. R. 28; FRAP 32(d)).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if "date" in meta { [Dated: #meta.date]; v(11.2pt) }
    align(left, pad(left: half-measure, {
      [Respectfully submitted,]
      v(16.8pt)
      signature-line(meta)
      linebreak()
      sig.signer
      for l in sig.at("lines", default: ()) { indented-line(l) }
    }))
  })
}

/// Signature line for a certificate: "/s/ Name", the name, and the date (6 Cir. R. 25; FRAP 25(d)).
#let form-sig-line(meta) = block(above: 22.4pt, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading)
  grid(columns: (1fr, 1fr), column-gutter: 14pt,
    [#signature-line(meta)\ #text(size: type-size)[Signature]],
    [#meta.at("date", default: "")\ Date])
})

/// Circuit Rule 26.1 disclosure statement: the first page after the cover (FRAP 26.1, FRAP 28(a)(1),
/// 6 Cir. R. 26.1). Roman page i. Its text comes from the frontmatter `disclosure:`; it is excluded
/// from the length limit (FRAP 32(f)).
#let disclosure-page(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Circuit Rule 26.1 Disclosure Statement]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  cmarker.render(need(meta, "disclosure"), raw-typst: false, smart-punctuation: true)
}

/// Statement in Support of Oral Argument: at most one page (6 Cir. R. 34(a)). Its text comes from
/// the frontmatter `oral_argument:`; the brief may put it before the jurisdictional statement (6 Cir. R. 28(b)(1)(B)).
#let oral-argument-page(meta) = {
  heading(level: 1, numbering: none)[Statement in Support of Oral Argument]
  cmarker.render(need(meta, "oral_argument"), raw-typst: false, smart-punctuation: true)
}

/// Certificate of Compliance, Form 6 wording (FRAP 32(g)(1); 6 Cir. R. 28(e)(2), 32(a), 32(g)).
/// It follows the signature block immediately (6 Cir. R. 32(a)).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [This brief complies with: (1) the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Rule 32(f); and (2) the typeface requirements of Rule 32(a)(5) and the type style requirements of Rule 32(a)(6) because it has been prepared in a proportionally spaced typeface (#box[#(type-size / 1pt)-point] #font-family.first()). The word count is computed from the markdown source of this brief.]
  form-sig-line(meta)
}

/// Certificate of Service (FRAP 25(d); 6 Cir. R. 25). Shown unless `service.certificate: false`.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [I certify that on #need(meta, "date"), this brief was served via CM/ECF on all registered counsel and transmitted to the Clerk of the Court.]
  form-sig-line(meta)
}

/// Designation of District Court Record (6 Cir. R. 28(b)(1)(A)(i), 30(g)(1)): an addendum at the end of
/// the principal brief, excluded from the length limit (6 Cir. R. 32(b)(1)). Rows come from `designation:`.
#let designation-section(meta) = {
  heading(level: 1, numbering: none)[Designation of District Court Record]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  // The party named in the lead-in is frontmatter (`designation_intro:`), never template text.
  inl(meta.at("designation_intro", default: "The appellant designates the following filings from the District Court's electronic records under Sixth Circuit Rules 28(b)(1)(A)(i) and 30(g)(1):"))
  block(width: 100%, breakable: true, above: 14pt, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 5.6pt, justify: false)
    // a row is never split across pages (Word: cantSplit)
    set grid.cell(breakable: false)
    grid(columns: (1.5in, 2.3in, 1fr), column-gutter: 0.15in, row-gutter: 8.4pt,
      strong[Date Filed], strong[R.No.; Page ID \#], strong[Description of Document],
      ..need(meta, "designation").map(d => (inl(d.date), inl(d.rno), inl(d.description))).flatten())
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca6-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "disclosure", "oral_argument") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }
  let words = count-words(body-md)
  if words > word-limit {
    panic("ca6-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(i) allows " + str(word-limit))
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
  // boxes of the body pitch, footnote marks at 58 %, a section sign kept with its number, no break inside
  // "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // "§§ 1651" stays whole: the shared rule binds the last sign to the number, and a line could otherwise end
  // between the two signs (LaTeX and Word never break there).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: none)
  set footnote.entry(
    gap: 7pt, clearance: 12.6pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // typst's default is 0.85em; FRAP 32(a)(5)(A) allows nothing under 14 pt
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

  // ---- front matter (lowercase roman, from the disclosure page) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    disclosure-page(meta)
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
  }
  pagebreak()
  oral-argument-page(meta)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
    // Footnote definitions may sit at the end of the file; they are not the last paragraph. They
    // are passed to both renders, since a reference and its definition must be in the same render.
    let paras = body-md.trim(at: end).split(regex("\n[ \t]*\n"))
    let notes = paras.filter(p => p.starts-with("[^")).join("\n\n")
    let main = paras.filter(p => not p.starts-with("[^"))
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let tail = if main.len() > 0 { main.last() } else { "" }
    let head = main.slice(0, calc.max(main.len() - 1, 0)).join("\n\n")
    let keep = tail.len() > 0 and not tail.starts-with("#")
    pagebreak(weak: true)
    if keep {
      render(head + "\n\n" + notes)
      block(breakable: false, { render(tail + "\n\n" + notes); signature-block(meta) })
    } else {
      render(main.join("\n\n") + "\n\n" + notes)
      signature-block(meta)
    }
  }

  // ---- certificates and designation (after the signature, 6 Cir. R. 32(a)) ----
  set text(..edges(pitch-single))
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (certificate: true)).at("certificate", default: true) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
  pagebreak(weak: true)
  designation-section(meta)

  // ---- addendum after the designation (6 Cir. R. 28(b)(2): unpublished opinions; optional) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
