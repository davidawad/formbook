// New York Court of Appeals: appellant's principal (opening) brief, normal course appeal.
//
// Rule-driven and content-agnostic. Rule references (22 NYCRR) are in ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// 500.1(j): serifed, proportionally spaced; 500.1(i) names Times New Roman as its example. Vendored in /fonts;
// Liberation Serif is its metric twin, declared so the docx, which names Times New Roman, passes DEF-FONT-002.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 14pt                      // 500.1(j)(1): body in 14-point type (footnotes too: at least 12).
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (docx/ny-opening.lua and docx/reference.xml set the same twips: 20 x pt).
#let pitch-double = 31.4pt                 // 500.1(l): double spaced, about 2.24 x type size.
#let pitch-single = 20pt                   // headings, quotations, footnotes, contents, cover, signature: single spaced.
#let page-margin = 1in                     // 500.1(l): one inch on all sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let toc-col = 36pt                        // the contents' page numbers keep the last 36 pt of the line
#let toa-col = 56pt                        // the authorities' page lists (a longer list widens its own row's column)
#let half-width = 3.25in                   // the right half of the 6.5 in text width: designations, notary
#let arg-col = 3.1in                       // the cover's argument request, upper right (500.13(b))
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim".
#let word-limit = 14000                    // 500.13(c)(1): principal brief of appellant or respondent.
#let caption-separator = [– against –]
// Blanks to fill in by hand, typed as underscores so every engine sets the same characters (7 pt each at 14 pt).
#let blank-by = 22                         // "By:" signature line, about 2.2 in
#let blank-long = 26                       // a name or an address, about 2.6 in
#let blank-mid = 16                        // a county or a method of service
#let blank-day = 8                         // a day, a month
#let blank-year = 4                        // the last digits of a year
#let ss-col = 3in                          // the affidavit's venue: the ")" column

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

#let blank(n) = "_" * n

/// One single-spaced line (or paragraph), `above` pt above it.
#let line-par(body, above: 0pt, align-to: left, indent: 0pt) = block(above: above, below: 0pt, width: 100%,
  pad(left: indent, align(align-to, par(first-line-indent: 0pt, body))))

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
#let hang(indent, body) = par(hanging-indent: indent, first-line-indent: 0pt, body)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  set text(size: type-size, ..edges(pitch-single))   // every heading is body size or larger; no typst default sizes
  if it.level == 1 {
    // Section headings: bold, capitals, centered (500.1(j): capitals and bold are allowed in headings).
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt, align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings (addendum entries): bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else {
    // Numbered sub-headings: the label hangs in a box; the text wraps under itself.
    // Level 2 steps in from the margin by nothing, each further level by half an inch.
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
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

/// One table-of-contents row, built from a heading element (listing-row: the page number has its own column, so a
/// title that fills its last line never pushes it onto a line of its own). Wrapped lines hang under the title.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else if numbered and hd.level == 2 { upper(hd.body) } else { hd.body }
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-col, ind + heading-tab, if hd.level == 1 { 8.4pt } else { 4.9pt })
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
        }, page-text, calc.max(toa-col, measure(page-text).width), 0.35in, 9.8pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (500.13(b))
// ---------------------------------------------------------------------------

#let double-rule(above) = block(above: above, below: 0pt, {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
})
#let short-rule(above) = block(width: 100%, above: above, below: 0pt, line(start: (50% - 1in, 0pt), length: 2in, stroke: 0.7pt))

/// The cover: the argument request in the upper right corner (500.13(b)), the docket,
/// the court, the caption, the title, counsel and the completion date.
#let cover-body(meta, gap) = {
  let c(body, above: 0pt) = line-par(body, above: above, align-to: center)
  // Docket on the left, the argument request in the upper right corner (500.13(b)), on one row.
  let arg = need(meta, "argument")
  let docket-lines = (need(meta, "docket"),)
  if "county_clerk_index" in meta { docket-lines.push(meta.county_clerk_index) }
  grid(columns: (1fr, arg-col), column-gutter: 0.3in,
    { for l in docket-lines { line-par(l) } },
    {
      if "presenter" in arg {
        line-par[To be Argued by:]
        line-par(strong(upper(inl(arg.presenter))))
        line-par[(Time Requested: #arg.time_requested)]
      } else {
        line-par[Submitted without oral argument]
      }
    })
  c(strong[Court of Appeals of the State of New York], above: gap)
  double-rule(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for (k, name) in side.names.enumerate() {
      c(inl(name), above: if k > 0 { 4.9pt } else if i == 0 { gap } else { gap * 0.3 })
    }
    line-par(inl(side.designation), above: 4.9pt, indent: half-width)
    if i < sides.len() - 1 { c(caption-separator, above: gap * 0.3) }
  }
  double-rule(gap)
  c(strong(upper(inl(need(meta, "brief_title")))), above: gap)
  short-rule(gap)
  // Counsel: name, office address, telephone and facsimile (500.13(b)). Side by side, as on the filed cover.
  let groups = need(meta, "counsel")
  block(above: gap, below: 0pt, grid(columns: groups.map(g => 1fr), column-gutter: 0.4in,
    ..groups.map(g => {
      line-par(strong(upper(inl(g.firm))))
      for l in g.lines { line-par(emph(inl(l))) }
    })))
  c(emph(inl(need(meta, "attorneys_for"))), above: gap * 0.5)
  c([Date Completed: #need(meta, "date_completed")], above: gap)
  double-rule(gap)
}

/// The cover's height at a gap, estimated from the text as written (the docx filter computes the same estimate, so
/// both engines take the same gap): every line `pitch-single`, a double rule 7 pt, the short one 3 pt, a text of n characters as many lines as
/// its width needs at 0.72 em for a capital and 0.5 em for any other character, over 92 % of its column.
#let cover-estimate(meta, gap) = {
  let w = 468pt
  let lines(s, col) = {
    let t = str(s)
    let width = t.clusters().map(c => if c == " " { 0.25 } else if upper(c) == c and lower(c) != c { 0.66 } else { 0.47 }).sum(default: 0) * 14pt
    calc.max(1, calc.ceil(width / (col * 0.97)))
  }
  let col-lines(ls, col) = ls.map(l => lines(l, col)).sum(default: 0)
  let arg = need(meta, "argument")
  let half = (w - arg-col - 0.3in)
  let docket = (need(meta, "docket"),) + if "county_clerk_index" in meta { (meta.county_clerk_index,) } else { () }
  let args = if "presenter" in arg { ("To be Argued by:", arg.presenter, "(Time Requested: " + arg.time_requested + ")") } else { ("Submitted without oral argument",) }
  let h = calc.max(col-lines(docket, half), col-lines(args, arg-col)) * pitch-single
  h += gap + lines("Court of Appeals of the State of New York", w) * pitch-single
  h += gap + 7pt
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for (k, n) in side.names.enumerate() {
      h += (if k > 0 { 4.9pt } else if i == 0 { gap } else { gap * 0.3 }) + lines(n, w) * pitch-single
    }
    h += 4.9pt + lines(side.designation, w - half-width) * pitch-single
    if i < sides.len() - 1 { h += gap * 0.3 + pitch-single }
  }
  h += gap + 7pt
  h += gap + lines(upper(need(meta, "brief_title")), w) * pitch-single
  h += gap + 3pt
  let groups = need(meta, "counsel")
  let cw = (w - (groups.len() - 1) * 0.4in) / groups.len()
  h += gap + calc.max(..groups.map(g => (lines(upper(g.firm), cw) + col-lines(g.lines, cw)))) * pitch-single
  h += gap * 0.5 + lines(need(meta, "attorneys_for"), w) * pitch-single
  h += gap + lines("Date Completed: " + need(meta, "date_completed"), w) * pitch-single
  h + gap + 7pt
}

/// The cover is one page. The spacing between its parts is the only thing that gives: the largest spacing at which
/// the estimated cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(g => cover-estimate(meta, g * 14pt) <= size.height)
  if g == none or measure(block(width: size.width, cover-body(meta, g * 14pt))).height > size.height {
    panic("ny-opening-brief: the cover does not fit on one page; shorten the caption or counsel")
  }
  cover-body(meta, g * 14pt)
}))

// ---------------------------------------------------------------------------
// Front pages before the contents (500.1(f), 500.13(a)), signature, certificates
// ---------------------------------------------------------------------------

/// The double-spaced text of a statement or certificate (500.1(l)), first lines indented.
#let double-spaced(body) = {
  set text(..edges(pitch-double))
  set par(first-line-indent: (amount: para-indent, all: true))
  body
}

/// Disclosure statement under 500.1(f). Printed only when the filer is an entity and the
/// sample gives the text (`disclosure:`, markdown).
#let disclosure-page(meta) = {
  heading(level: 1, numbering: none)[Disclosure Statement Pursuant to Section 500.1(f) of the Rules of the Court of Appeals]
  double-spaced(cmarker.render(meta.disclosure, raw-typst: false, smart-punctuation: true, h1-level: 1))
}

/// Statement of the status of related litigation, required before the contents (500.13(a)).
#let related-litigation(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Statement of Related Litigation]
  double-spaced(inl(need(meta, "related_litigation")))
}

#let signature-block(meta, address: true) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, below: 0pt, {
    line-par[Dated: #sig.place]
    line-par(sig.date)
    // The firms sign side by side (the signature line is above the first firm's signer, who is
    // named in that firm's list), so the block stays within one page.
    block(above: 16.8pt, below: 0pt, grid(columns: sig.blocks.map(b => 1fr), column-gutter: 0.4in,
      ..sig.blocks.enumerate().map(((bi, b)) => {
        line-par(strong(upper(inl(b.firm))))
        if bi == 0 { line-par[By: #blank(blank-by)] }
        for n in b.names { line-par(inl(n)) }
        if address { for l in b.lines { line-par(emph(inl(l))) } }
      })))
    line-par(emph(inl(sig.attorneys_for)), above: 8.4pt)
  })
}

/// Certificate of Compliance: 500.1(j) (typeface, point size, spacing) and 500.13(c)(1) (word count).
#let certificate-of-compliance(meta, words) = {
  // One unbreakable block: the certificate and its signature never separate.
  block(breakable: false, {
    heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
    double-spaced({
      [I hereby certify pursuant to 22 NYCRR 500.1(j) that the foregoing brief was prepared on a computer using #meta.at("word_processor", default: "a word-processing system").]
      parbreak()
      [A proportionally spaced typeface was used, as follows:]
    })
    block(above: 11.2pt, below: 11.2pt, {
      line-par([Name of typeface: #font-family.first()], indent: para-indent)
      line-par([Point size: #int(type-size / 1pt)], indent: para-indent)
      line-par([Line spacing: Double], indent: para-indent)
    })
    double-spaced[*Word Count.* The total number of words in this brief, inclusive of point headings and footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, certificate of compliance, corporate disclosure statement, questions presented, statement of related litigation, or any authorized addendum containing statutes, rules, regulations, etc., is #group-digits(words).]
    signature-block(meta, address: false)
  })
}

/// Affidavit of service (500.1(e)): the original is affixed to the inside of the back cover.
/// Blanks only: nothing case-specific is printed here.
#let affidavit-of-service() = {
  heading(level: 1, numbering: none, outlined: false)[Affidavit of Service]
  let venue(l, r) = block(above: 0pt, below: 0pt, grid(columns: (ss-col, 1fr), line-par(l), line-par(r)))
  venue([STATE OF NEW YORK], [)])
  venue([], [) ss.:])
  venue([COUNTY OF #blank(blank-mid)], [)])
  block(above: 16.8pt, below: 0pt, double-spaced({
    [#blank(blank-long), being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years of age, and resides at #blank(blank-long).]
    parbreak()
    [On the #blank(blank-day) day of #blank(blank-day), 20#blank(blank-year), deponent served the within brief upon each attorney for each party to this appeal, at the address designated by that attorney for that purpose, by #blank(blank-mid), and by #blank(blank-mid).]
  }))
  block(above: 25.2pt, below: 0pt, {
    line-par(blank(blank-long), indent: half-width)
    line-par([Sworn to before me this], indent: half-width)
    line-par([#blank(blank-day) day of #blank(blank-day), 20#blank(blank-year)], indent: half-width)
    line-par(blank(blank-long), above: 16.8pt, indent: half-width)
    line-par([Notary Public], indent: half-width)
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
  // The page number (500.1(l): centred in the bottom margin): in a single-pitch line box whatever the text around it
  // (Word's footer), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  // No punctuation hanging into the margin (typst overhang), which Word does not do.
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false, overhang: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, ragged right, no kerning or ligatures, no
  // hyphenation, line boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a
  // section sign kept with its number, no break inside "63(12)(a)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number too ("§§ 213, 214": xengine binds a single one; the docx filter binds both).
  show regex("[§¶]+ \\S+"): it => box(it)
  set heading(numbering: none)
  // 7.5 pt from the text to the rule: with the 7 pt gap, the 14.5 pt LibreOffice keeps above a note (the oked folders;
  // the sample, p8: a line 16 pt above its note fits in both engines; 12.6 pt, as before, moved it on in typst only)
  set footnote.entry(gap: 7pt, clearance: 7.5pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    // 500.1(j)(1): footnotes at least 12 points. The body size is used, as the exemplar does.
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
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

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  if "disclosure" in meta { disclosure-page(meta) }
  related-litigation(meta)
  {
    set text(..edges(pitch-single))
    pagebreak()
    toc-section(add != none)
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph (with the heading above it, if
    // any) is kept together with it (unless that last block is a heading or a footnote definition). Footnote
    // definitions are not paragraphs of the text and never take part.
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let parts = body-md.trim(at: end).split(regex("\n[ \t]*\n"))
    let k = parts.len() - 1
    while k > 0 and parts.at(k).starts-with("[^") { k -= 1 }
    let first = if k > 0 and parts.at(k - 1).starts-with("#") { k - 1 } else { k }
    let notes = parts.slice(k + 1)
    let head = parts.slice(0, first) + notes
    let tail = parts.slice(first, k + 1)
    if tail.len() == 0 or tail.last().starts-with("#") {
      render(parts.join("\n\n"))
      { set text(..edges(pitch-single)); signature-block(meta) }
    } else {
      render(head.join("\n\n"))
      block(breakable: false, { render(tail.join("\n\n")); { set text(..edges(pitch-single)); signature-block(meta) } })
    }
  }

  // ---- certificates ----
  {
    set text(..edges(pitch-single))
    pagebreak(weak: true)
    certificate-of-compliance(meta, words)
    pagebreak(weak: true)
    affidavit-of-service()
  }

  // ---- addendum (500.1(h): cited material not otherwise readily available) ----
  if add != none {
    set page(numbering: (..n) => "Add-" + str(n.pos().first()))
    counter(page).update(1)
    [#heading(level: 1, numbering: none)[Addendum] <add-start>]
    { set text(..edges(pitch-single)); toc-addendum() }
    pagebreak()
    cmarker.render(add-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
}
