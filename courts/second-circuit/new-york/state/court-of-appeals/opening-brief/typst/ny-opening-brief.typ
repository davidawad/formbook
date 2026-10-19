// New York Court of Appeals: appellant's principal (opening) brief, normal course appeal.
//
// Rule-driven and content-agnostic. Rule references (22 NYCRR) are in ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // 500.1(j): serifed, proportionally spaced; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 14pt                      // 500.1(j)(1): body in 14-point type.
#let body-leading = 1.336em                // 500.1(l): double spaced: with the 0.909em ascender-to-descender box, a 2.245em pitch (31.4 pt at 14 pt, about 2.2 x type size).
#let single-leading = 0.516em              // headings, quotations, footnotes, contents: single spaced (500.1(l)).
#let page-margin = 1in                     // 500.1(l): one inch on all sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim".
#let word-limit = 14000                    // 500.13(c)(1): principal brief of appellant or respondent.
#let caption-separator = [– against –]

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
  if key not in meta { panic("ny-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A stack of separate lines (each its own block; no forced line break inside text).
#let lines-stack(items) = stack(dir: ttb, spacing: 0.3em, ..items)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ny-opening-brief: the sample must start with a YAML frontmatter block") }
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

/// The markdown with the section headed `title` (case-insensitive, level 1) removed.
/// Used for the word count: 500.13(c)(3) excludes the questions presented.
#let without-section(md, title) = {
  let heads = md.matches(regex("(?m)^#[ \t]+[^\n]*$"))
  for (i, h) in heads.enumerate() {
    let name = lower(h.text.replace(regex("^#[ \t]+"), "")).trim()
    if name == title {
      let next = heads.at(i + 1, default: none)
      let stop = if next == none { md.len() } else { next.start }
      return md.slice(0, h.start) + md.slice(stop)
    }
  }
  md
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

/// Printed label of a numbered heading: I. / A. / 1. / a. (level 2 to 5).
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("ny-opening-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger; no typst default sizes
  if it.level == 1 {
    // Section headings: bold, capitals, centered (500.1(j): capitals and bold are allowed in headings).
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings (addendum entries): bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Numbered sub-headings: the label hangs in a box; the text wraps under itself.
    // Level 2 steps in from the margin by nothing, each further level by half an inch.
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level == 2 { strong(upper(it.body)) }
      else if it.level >= 4 { strong(emph(it.body)) }
      else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element. Wrapped lines hang under the title.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else if numbered and hd.level == 2 { upper(hd.body) } else { hd.body }
  // Three columns: label, title with its leader, page number. The page number has its own column,
  // so a title that wraps never pushes it onto a line of its own; wrapped titles hang under the text,
  // and the page number sits on the last line, where the leader ends.
  let label-width = if numbered { ind + heading-tab } else { ind }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt, {
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (label-width, 1fr, 2em), column-gutter: 0pt, align: (left + top, left + top, right + bottom),
      [#h(ind)#if numbered { lab }],
      [#title#h(0.4em)#dot-leader],
      align(right, it.page()))
  }))
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
        panic("ny-opening-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (500.13(b))
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

/// The cover: the argument request in the upper right corner (500.13(b)), the docket,
/// the court, the caption, the title, counsel and the completion date.
#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  // Docket on the left, the argument request in the upper right corner (500.13(b)), on one row.
  let arg = need(meta, "argument")
  let docket-lines = (need(meta, "docket"),)
  if "county_clerk_index" in meta { docket-lines.push(meta.county_clerk_index) }
  grid(columns: (1fr, 3.1in), column-gutter: 0.3in, align: (left, right),
    lines-stack(docket-lines),
    block(align(left, {
      if "presenter" in arg {
        [To be Argued by:]
        parbreak()
        strong(upper(inl(arg.presenter)))
        parbreak()
        [(Time Requested: #arg.time_requested)]
      } else {
        [Submitted without oral argument]
      }
    })))
  v(gap)
  set align(center)
  strong[Court of Appeals of the State of New York]
  v(gap)
  double-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: 50%, inl(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); caption-separator; v(gap * 0.3) }
  }
  v(gap)
  double-rule
  v(gap)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // Counsel: name, office address, telephone and facsimile (500.13(b)). Side by side, as on the filed cover.
  let groups = need(meta, "counsel")
  grid(columns: groups.map(g => 1fr), column-gutter: 0.4in, align: left, ..groups.map(g => block(breakable: false, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    strong(upper(inl(g.firm)))
    parbreak()
    for l in g.lines { emph(inl(l)); parbreak() }
  })))
  v(gap * 0.5)
  emph(inl(need(meta, "attorneys_for")))
  v(gap)
  [Date Completed: #need(meta, "date_completed")]
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ny-opening-brief: the cover does not fit on one page; shorten the caption or counsel") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Front pages before the contents (500.1(f), 500.13(a)), signature, certificates
// ---------------------------------------------------------------------------

/// A blank to fill in by hand (a drawn line on the baseline; underline() draws nothing for spacing).
#let blank(w) = box(width: w, line(length: 100%, stroke: 0.5pt))

/// Disclosure statement under 500.1(f). Printed only when the filer is an entity and the
/// sample gives the text (`disclosure:`, markdown).
#let disclosure-page(meta) = {
  heading(level: 1, numbering: none)[Disclosure Statement Pursuant to Section 500.1(f) of the Rules of the Court of Appeals]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  cmarker.render(meta.disclosure, raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// Statement of the status of related litigation, required before the contents (500.13(a)).
#let related-litigation(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Statement of Related Litigation]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  inl(need(meta, "related_litigation"))
}

#let signature-block(meta, address: true) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Dated: #sig.place]
    parbreak()
    sig.date
    v(1.2em)
    // The firms sign side by side (the signature line is above the first firm's signer, who is
    // named in that firm's list), so the block stays within one page.
    let cells = ()
    for (bi, b) in sig.blocks.enumerate() {
      cells.push(block(breakable: false, {
        set par(spacing: 0.4em)   // one line per paragraph here: tighter than the body's double spacing
        strong(upper(inl(b.firm)))
        parbreak()
        if bi == 0 { [By: #blank(2.2in)]; parbreak() }
        for n in b.names { inl(n); parbreak() }
        if address { for l in b.lines { emph(inl(l)); parbreak() } }
      }))
    }
    grid(columns: sig.blocks.map(b => 1fr), column-gutter: 0.4in, align: left, ..cells)
    v(0.6em)
    emph(inl(sig.attorneys_for))
  })
}

/// Certificate of Compliance: 500.1(j) (typeface, point size, spacing) and 500.13(c)(1) (word count).
#let certificate-of-compliance(meta, words) = {
  // One unbreakable block: the certificate and its signature never separate.
  block(breakable: false, {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [I hereby certify pursuant to 22 NYCRR 500.1(j) that the foregoing brief was prepared on a computer using #meta.at("word_processor", default: "a word-processing system").]
  parbreak()
  [A proportionally spaced typeface was used, as follows:]
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  block(above: 0.8em, below: 0.8em, pad(left: para-indent, lines-stack((
    [Name of typeface: #font-family.first()],
    [Point size: 14],
    [Line spacing: Double],
  ))))
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [*Word Count.* The total number of words in this brief, inclusive of point headings and footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, certificate of compliance, corporate disclosure statement, questions presented, statement of related litigation, or any authorized addendum containing statutes, rules, regulations, etc., is #group-digits(words).]
  signature-block(meta, address: false)
  })
}

/// Affidavit of service (500.1(e)): the original is affixed to the inside of the back cover.
/// Blanks only: nothing case-specific is printed here.
#let affidavit-of-service() = {
  heading(level: 1, numbering: none, outlined: false)[Affidavit of Service]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  block(above: 0em, below: 1.2em, grid(columns: (auto, 1fr), column-gutter: 0.6em, row-gutter: 0.4em,
    [STATE OF NEW YORK], [)],
    [], [) ss.:],
    [COUNTY OF #blank(1.8in)], [)],
  ))
  [#blank(2.6in), being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years of age, and resides at #blank(2.4in).]
  parbreak()
  [On the #blank(0.7in) day of #blank(1.2in), 20#blank(0.4in), deponent served the within brief upon each attorney for each party to this appeal, at the address designated by that attorney for that purpose, by #blank(2.4in), and by #blank(1.4in).]
  block(above: 1.8em, below: 0pt, pad(left: 50%, lines-stack((
    blank(2.4in),
    [Sworn to before me this],
    [#blank(0.7in) day of #blank(1.2in), 20#blank(0.4in)],
    blank(2.4in),
    [Notary Public],
  ))))
}

#let toc-addendum() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(level: 2)).after(<add-start>), depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ny-opening-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("docket", "argument", "caption", "brief_title", "counsel", "attorneys_for",
            "date_completed", "signature", "related_litigation") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- split off the addendum ----
  let add = md.match(regex("(?mi)^#[ \t]+addendum[ \t]*$"))
  let body-md = if add == none { md } else { md.slice(0, add.start) }
  let add-md = if add == none { none } else { md.slice(add.end) }
  let words = count-words(without-section(body-md, "questions presented"))
  if words > word-limit {
    panic("ny-opening-brief: the brief has " + str(words) + " words; 22 NYCRR 500.13(c)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", " + need(meta, "docket"),
    author: need(meta, "signature").by,
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
    // 500.1(j)(1): footnotes at least 12 points. The body size is used, as the exemplar does.
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Typography that holds for any text: never break inside a token of adjacent parentheses
  // ("63(12)(a)"), and never between a section sign / pilcrow and its number. Done with
  // unbreakable boxes so the extracted text stays exactly the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  if "disclosure" in meta { disclosure-page(meta) }
  related-litigation(meta)
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
    // The last paragraph (with the heading above it, if any) is kept with the signature block.
    // Footnote definitions are not paragraphs of the text and never take part.
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let parts = body-md.trim(at: end).split(regex("\n[ \t]*\n"))
    let k = parts.len() - 1
    while k > 0 and parts.at(k).starts-with("[^") { k -= 1 }
    let first = if k > 0 and parts.at(k - 1).starts-with("#") { k - 1 } else { k }
    let notes = parts.slice(k + 1)
    let head = parts.slice(0, first) + notes
    let tail = parts.slice(first, k + 1)
    if tail.len() == 0 or tail.first().starts-with("[^") {
      render(parts.join("\n\n"))
      signature-block(meta)
    } else {
      render(head.join("\n\n"))
      block(breakable: false, { render(tail.join("\n\n")); signature-block(meta) })
    }
  }

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  pagebreak(weak: true)
  affidavit-of-service()

  // ---- addendum (500.1(h): cited material not otherwise readily available) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    toc-addendum()
    pagebreak()
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
