// Appellate Division, Fourth Judicial Department: brief for the appellant (doc type set below).
//
// Rule-driven and content-agnostic. Rule IDs (CPLR 5529, 22 NYCRR 1250.8, 22 NYCRR Part 1000) refer to
// ../README.md. No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). docx/nyappdiv-opening-brief.lua and
// docx/reference.xml set the same numbers in twips (20 x pt), so the Word render breaks every line and page here.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that differs between the copies of this template)
// ---------------------------------------------------------------------------

#let doc-kind = "opening-brief"
#let court-lines = (
  "SUPREME COURT OF THE STATE OF NEW YORK",
  "APPELLATE DIVISION",
  "FOURTH JUDICIAL DEPARTMENT",
)
#let word-limit = 14000                     // 22 NYCRR 1250.8(f)(2): appellant's computer-generated brief.
#let footnotes-allowed = false              // Part 1000: "A brief shall contain no footnotes" (secondary source; see README).
#let required-sections = (                  // 22 NYCRR 1250.8(b)(3)-(5), in this order (regexes on lowercased titles).
  "^statement of (the )?questions",
  "^statement of (the )?(nature of the )?(case|facts)",  // exemplar heading: "STATEMENT OF FACTS" (see usage/SOURCE.md)
  "^argument$",
  "^conclusion$",
)

// ---------------------------------------------------------------------------
// Parameters (every number traces to a rule or to a style choice noted beside it)
// ---------------------------------------------------------------------------

// 22 NYCRR 1250.8(f)(1): a serifed, proportionally spaced face such as Times Roman; Times New Roman (docs/FONTS.md),
// vendored in /fonts with its metric twin; no system font is used.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 14pt                       // 22 NYCRR 1250.8(f)(1)(i): 14-point body type (proportional face).
#let page-margin = 1in                      // 22 NYCRR 1250.8(h)
#let footer-distance = 0.5in                // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in
#let heading-tab = 0.5in                    // a heading label (A., 1., a.) in a half-inch box, its text hanging after it
#let point-box = 1in                        // a contents row's "POINT I" label: the box its title starts after
#let toc-depth = 4
#let toc-col = 0.5in                        // contents: the page column the rows wrap before
#let toa-col = 1in                          // authorities: the page column ("4, 5, 6" and "passim" fit)
#let toa-hang = 0.5in                       // an authority's later lines hang this far in
#let passim-threshold = 7                   // An authority cited on this many pages or more prints "passim".
#let lead-slack = 4pt                       // a row keeps its last word before the leader only with this much to spare
                                            // (LibreOffice wants about 4 pt after the leader's three spaces)
#let caption-inset = 0.5in                  // the caption and the proceeding: centred lines, this far in on each side
#let arg-col = 2.5in                        // the argued / submitted notation's column at the upper right (1250.8(a))
#let counsel-left = 2.5in                   // the counsel block in the lower right (1250.8(a))
#let sig-left = 3in                         // the signature column

// Pitches (line boxes) and the spaces between blocks.
#let pitch-body = 28pt                      // 22 NYCRR 1250.8(h): double-spaced text, two 14 pt lines
#let pitch-single = 16.1pt                  // single spacing (cover, headings, quotations, tables, signature, page number): Word's 1.15 x 14 pt
#let heading-above = 16pt                   // above a section or point heading
#let heading-below = 12pt                   // below a section or point heading
#let point-gap = 6pt                         // between a point heading's label and its title
#let sub-above = 12pt                       // above a lettered or numbered heading
#let sub-below = 6pt                        // below it
#let quote-gap = 14pt                       // above and below a block quotation
#let toc-above = 8pt                        // above a level 1 row of the contents
#let toa-above = 4pt                        // above each authority
#let blank = pitch-single                   // a blank single line

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

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
  if key not in meta { panic("nyappdiv-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyappdiv-brief: the sample must start with a YAML frontmatter block") }
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
/// Headings count (22 NYCRR 1250.8(f)(2): inclusive of point headings). Markup is removed first; links keep their text.
/// (docx/nyappdiv-opening-brief.lua counts the same way, rule for rule.)
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")
  s = s.replace(regex("\\\\(.)"), keep)
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// Single-spaced lines, one paragraph each; "" is a blank single line. `above`: space above the first line.
#let line-stack(items, above: 0pt, inset-l: 0pt, inset-r: 0pt, align-to: left) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += blank } else {
      block(width: 100%, above: g, below: 0pt, pad(left: inset-l, right: inset-r, align(align-to, i)))
      g = 0pt
    }
  }
}

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Headings: numbering and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading. Argument: POINT I, A., 1., a. Elsewhere: A., 1., a., (1).
#let heading-label(h) = {
  let loc = h.location()
  let n = counter(heading).at(loc).at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { "POINT " + numbering("I", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("nyappdiv-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("nyappdiv-brief: headings deeper than level 5 are not supported") }
  }
}

// Headings are single-spaced (1250.8(h)), bold, and kept with the text after them.
#let style-heading(it) = {
  set text(size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, breakable: false, above: heading-above, below: heading-below,
      align(center, strong(upper(it.body))))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: label on one line, the point itself centered below, both bold.
    block(width: 100%, sticky: true, breakable: false, above: heading-above, below: heading-below, {
      align(center, strong(heading-label(it)))
      block(width: 100%, above: point-gap, below: 0pt, align(center, strong(it.body)))
    })
  } else {
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, breakable: false, above: sub-above, below: sub-below,
      pad(left: ind, par(hanging-indent: heading-tab, {
        box(width: heading-tab, strong(lab))
        if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
      })))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// A table's title (a section heading that is not listed), then the column label at the right.
#let table-head(title, col) = {
  heading(level: 1, numbering: none, outlined: false, title)
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(..edges(pitch-single))
    align(right, strong(underline(col)))
  })
}

/// The contents: level 1 headings at the margin in capitals; a point's "POINT I" label at the margin in a 1 in box;
/// any other label in a half-inch box at its level's indent; later lines hang under the title.
#let toc-section() = {
  table-head[Table of Contents][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      if hd.level > toc-depth { continue }
      let loc = hd.location()
      let row = if hd.level == 1 {
        (upper(hd.body), heading-tab, toc-above)
      } else if hd.level == 2 and in-argument(loc) {
        ([#box(width: point-box, heading-label(hd))#hd.body], point-box, 0pt)
      } else {
        let ind = (hd.level - 2) * heading-tab
        ([#h(ind)#box(width: heading-tab, heading-label(hd))#hd.body], ind + heading-tab, 0pt)
      }
      listing-row(loc, [#row.at(0)#h(lead-slack)], page-label(loc), toc-col, row.at(1), row.at(2))
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("constitution", "Constitutional Provisions"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))

/// The authorities the body cites (its `toa:` links), by group, sorted; the printed pages each is cited on.
#let toa-section(authorities) = {
  table-head[Table of Authorities][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-cite>)
    for (kind, title) in toa-groups {
      let keys = authorities.keys().filter(k => authorities.at(k).at("kind", default: "other") == kind)
      if keys.len() == 0 { continue }
      let sorted = keys.sorted(key: k => sort-key(authorities.at(k)))
      block(width: 100%, above: blank, below: 0pt, sticky: true, strong(title))
      for key in sorted {
        let a = authorities.at(key)
        // Printed page labels (the body restarts at 1 after the roman front matter), not physical PDF pages.
        let pages = ()
        for e in hits.filter(e => e.value.key == key) {
          let label = page-label(e.location())
          if label not in pages { pages.push(label) }
        }
        // 1250.8(b)(2): every listed authority shows the pages where it is cited; an entry no link reaches is an error.
        if pages.len() == 0 { panic("nyappdiv-brief: authority `" + key + "` is listed but never cited with a `toa:` link") }
        let p = if pages.len() >= passim-threshold { "passim" } else { pages.join(", ") }
        let label = if a.at("kind", default: "") == "case" and "name" in a {
          inl("*" + a.name + "*, " + a.cite)
        } else if "name" in a {
          inl(a.name + ", " + a.cite)
        } else {
          inl(a.cite)
        }
        listing-row(none, [#label#h(lead-slack)], p, toa-col, toa-hang, toa-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (22 NYCRR 1250.8: the printing statement and the court's form govern the rest; layout is convention)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  // The cover is not brief text, so it is single-spaced (1250.8(h) double-spaces the text); it must fit one page.
  // 22 NYCRR 1250.8(a): the upper right-hand section states whether the cause is argued or submitted,
  // and if argued, the time required and the attorney who will argue. The docket sits on the left of that row.
  let arg = need(meta, "argument")
  let arg-lines = if "presenter" in arg {
    ([To be argued by:], strong(inl(arg.presenter)), [Time requested: #arg.time_requested])
  } else { ([Submitted],) }
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(columns: (1fr, arg-col),
    line-stack((strong(need(meta, "docket")),)),
    line-stack(arg-lines)))
  line-stack(court-lines.map(l => strong(l)), above: 2 * blank, align-to: center)
  // The caption: each side's names and designation, "-against-" between them, centred.
  let cap = ()
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 { cap += ("", [-against-], "") }
    cap += side.names.map(inl)
    cap.push(inl(side.designation))
  }
  line-stack(cap, above: 2 * blank, inset-l: caption-inset, inset-r: caption-inset, align-to: center)
  if "index_number" in meta { line-stack((meta.index_number,), above: blank, align-to: right) }
  line-stack((inl(need(meta, "proceeding")),), above: 2 * blank, inset-l: caption-inset, inset-r: caption-inset,
    align-to: center)
  line-stack((strong(upper(need(meta, "brief_title"))),), above: 2 * blank, align-to: center)
  // 1250.8(a): the lower right-hand section gives the filing attorney's name, address, telephone number and email.
  let c = ()
  for (gi, g) in need(meta, "counsel").enumerate() {
    if gi > 0 { c.push("") }
    c += g.names.map(n => strong(n))
    c += g.at("lines", default: ()).map(inl)
  }
  c += (need(meta, "phone"), need(meta, "email"))
  line-stack(c, above: 3 * blank, inset-l: counsel-left)
  line-stack((need(meta, "date"),), above: 2 * blank)
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nyappdiv-brief(meta, md) = {
  let words = count-words(md)
  if words > word-limit {
    panic("nyappdiv-brief: " + str(words) + " words; 22 NYCRR 1250.8(f)(2) limits this brief to " + str(word-limit))
  }
  let titles = md.matches(regex("(?m)^#[ \t]+([^\n]+)$")).map(m => lower(m.captures.at(0)).trim())
  let found = ()
  for pat in required-sections {
    let r = regex(pat)
    let hit = titles.position(t => t.match(r) != none)
    if hit == none { panic("nyappdiv-brief: no section matching " + pat + " (22 NYCRR 1250.8(b))") }
    found.push(hit)
  }
  for i in range(1, found.len()) {
    if found.at(i) < found.at(i - 1) { panic("nyappdiv-brief: sections are out of the order in 22 NYCRR 1250.8(b)") }
  }
  let authorities = need(meta, "authorities")
  let _ = need(meta, "counsel")

  set page(paper: "us-letter", margin: page-margin, numbering: none,
    // 1250.8(h): pages numbered consecutively; centred at the foot in a single-pitch line box that ends
    // footer-distance above the page edge; the cover carries none.
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context {
      let n = here().page-numbering()
      if n != none { align(center, text(..edges(pitch-single), counter(page).display(n))) }
    })
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body)
  set heading(numbering: "1.")
  show heading: style-heading
  // Block quotations: single-spaced and indented half an inch on both sides (1250.8(h)).
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: para-indent, right: para-indent, it.body)
  })
  show footnote: it => {
    if footnotes-allowed { it } else { panic("nyappdiv-brief: footnotes are not allowed (22 NYCRR Part 1000; see README)") }
  }
  // Every `[text](toa:KEY)` is recorded with the page where it starts (a tag before the text, so no stray space);
  // an unknown key stops the build.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in authorities { panic("nyappdiv-brief: toa key `" + key + "` is not in authorities:") }
      [#metadata((key: key))<toa-cite>#it.body]
    } else { it }
  }

  cover(meta)
  pagebreak()

  // Front matter is numbered in lowercase roman from i (TOC, TOA); the body restarts at 1.
  // The exemplar settles this (see usage/SOURCE.md, "What the exemplar shows").
  counter(page).update(1)
  set page(numbering: "i")
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()
  counter(page).update(1)
  set page(numbering: "1")

  // Body: the sample's own sections (cmarker renders the markdown). The conclusion is set in
  // one unbreakable block with the signature, so the signature never stands alone on a page.
  let conclusion-at = md.matches(regex("(?im)^#[ \t]+conclusion[ \t]*$")).first().start
  cmarker.render(md.slice(0, conclusion-at), raw-typst: false, smart-punctuation: true)

  // Signature block (22 NYCRR 1250.8(b)(5)-(6) follows the argument; the signature is conventional).
  let sig = need(meta, "signature")
  let sig-lines = ([Respectfully submitted,], "", strong("s/ " + upper(sig.signer)))
  sig-lines += sig.at("lines", default: ()).map(inl)
  if "date" in meta { sig-lines += ("", meta.date) }
  // (the block opens with the conclusion heading: the heading's space above is the block's)
  block(width: 100%, breakable: false, above: heading-above, below: 0pt, {
    cmarker.render(md.slice(conclusion-at), raw-typst: false, smart-punctuation: true)
    line-stack(sig-lines, above: pitch-body, inset-l: sig-left)
  })

  // Printing specifications statement: last thing in the brief (22 NYCRR 1250.8(b)(6), (j)).
  pagebreak()
  heading(level: 1, numbering: none, outlined: false)[Printing Specifications Statement]
  par[This brief was prepared on a computer. The typeface is #font-family.first(), #int(type-size.pt()) point. The body text is double-spaced. Headings, block quotations, and the tables are single-spaced. The brief contains #group-digits(words) words, exclusive of the cover, the tables, the signature block, and any certificate of service, as counted by the word-processing system used to prepare it (22 NYCRR 1250.8(f)(2), (j)).]
  par[Signed under 22 NYCRR 130-1.1-a(a), which is also the signer's representation that this statement is accurate.]
  line-stack((strong("s/ " + upper(sig.signer)),) + sig.at("lines", default: ()).map(inl), above: pitch-single)
}
