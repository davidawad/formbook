// Supreme Court of the State of New York: memorandum of law on a motion (motion-brief).
//
// Rules: 22 NYCRR 202.5(a) (print no smaller than 12-point, footnotes no smaller than 10-point, double spacing except
// quotations and the names and addresses of attorneys, letter paper, margins no smaller than one inch, the index
// number and the assigned judge to the right of the caption), 202.8-b (7,000 / 4,200 words; the count excludes the
// caption, tables and signature block; a word-count certification), CPLR 2101 (the signer's name printed beneath
// the signature). Requirement IDs refer to ../README.md and ../../rules.md. Content-agnostic: every case-specific
// word comes from the sample's frontmatter and body, never from this file. No coordinates measured off any filed
// paper, no forced line breaks.
//
// Layout: the cover (caption, title, counsel; no page number), the tables of contents and authorities (lower-case
// roman from i), the body (arabic from 1) with the signature block and service list, the word-count certification on
// a page of its own.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // 202.5(a) and CPLR 2101(a) name no typeface; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt              // NYSUPCT-FORM-003: 22 NYCRR 202.5(a) print no smaller than 12-point
#let note-size = 11pt              // NYSUPCT-FORM-003: 22 NYCRR 202.5(a) footnotes no smaller than 10-point; 11-point for legibility
#let page-margin = 1in             // NYSUPCT-FORM-004: 22 NYCRR 202.5(a) margins no smaller than one inch
#let footer-distance = 0.5in       // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in           // convention: text paragraphs begin with a first-line indent
#let caption-box = 3.6in           // the bordered party box at the left of the caption
#let caption-gutter = 0.2in        // the party box's text from its sides, and the box to the right column
#let cover-gap = 1.6in             // the cover: the caption to the title, and the title to the counsel block
#let counsel-width = 3.6in         // the counsel block on the cover
#let quote-indent = 0.5in          // block quotations: indented on both sides
#let toc-indent = 0.4in            // contents: each level this much further in
#let toc-col = 0.5in               // contents: the page column the rows wrap before
#let toa-col = 1in                 // authorities: the page column ("11, 19, 22" fits)
#let toa-hang = 0.5in              // an authority's later lines hang this far in
#let toa-above = 6pt               // above each authority (a group title has a blank single line above it)
#let lead-slack = 4pt              // a row keeps its last word before the leader only with this much to spare (LibreOffice
                                   // wants about 4 pt free after the leader's three spaces; docs/EVAL-LOOP.md)
#let sig-col = 3.2in               // the signature column at the right
#let rule-short = 0.6in            // the "By:" rule ends this far before the signature column's right edge
#let toc-depth = 4
#let passim-threshold = 7          // convention (as in the ca9 template): an authority on 7 or more pages prints "passim"
#let word-limit-in-chief = 7000    // NYSUPCT-LEN-001: 22 NYCRR 202.8-b(a)(i)
#let word-limit-reply = 4200       // NYSUPCT-LEN-001: 22 NYCRR 202.8-b(a)(ii)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nysupct-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 24pt             // NYSUPCT-FORM-002: 22 NYCRR 202.5(a) double-spaced, two 12 pt lines
#let pitch-single = 13.8pt         // caption, cover, headings, quotations, tables, signature block (202.5(a) excepts
                                   // quotations and the names and addresses of attorneys): Word's 1.15 x 12 pt
#let pitch-note = 12.65pt          // footnote lines: single spacing at 11 pt
#let gap = 24pt                    // a blank double line: before the signature, the service list, the certification
#let heading-gap = 12pt            // above and below a heading, above and below a block quotation
#let note-gap = 6pt                // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 7.8pt        // the text to the footnote rule

// Table of authorities: groups in order, with the heading each prints under.
#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysupct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nysupct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each; "" is a blank single line. `above`: space above the first line.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  for (k, i) in items.enumerate() {
    let a = if k == 0 { above } else { 0pt }
    if i == "" { block(width: 100%, above: a, below: 0pt, height: pitch-single) }
    else { block(width: 100%, above: a, below: 0pt, if type(i) == str { inl(i) } else { i }) }
  }
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

/// Word count of markdown source, whitespace-delimited like a word processor (NYSUPCT-LEN-002: the caption, tables
/// and signature block are not in the body). Markup characters are removed first; links keep their text. Footnote
/// text counts. docx/nysupct-motion-brief.lua counts the same way, rule for rule.
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
// Cover (NYSUPCT-FORM-006, NYSUPCT-CONT-004): court, county, the party box with the index number, judge and motion
// sequence at its right; the title; the counsel block (CPLR 2101)
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let parties = need(meta, "parties")
  line-stack((
    align(center, strong[SUPREME COURT OF THE STATE OF NEW YORK]),
    strong[COUNTY OF #upper(need(meta, "county"))],
  ))
  // The party box: a blank single line inside its top and bottom rules; the names 0.2 in from its sides; a blank
  // single line, "-against-" and a blank single line between the sides; each side's designation at the right, a
  // blank single line under its names.
  let left = ("",)
  for (i, group) in parties.enumerate() {
    if i > 0 { left += ("", align(center, emph[-against-]), "") }
    left += group.names.map(n => pad(left: caption-gutter, right: caption-gutter, inl(n)))
    left += ("", pad(right: caption-gutter, align(right, inl(group.designation))))
  }
  left.push("")
  let right = ("", need(meta, "index_no"))
  if "judge" in meta { right.push(meta.judge) }
  if "motion_seq" in meta { right.push(meta.motion_seq) }
  block(width: 100%, above: heading-gap, below: 0pt, breakable: false, grid(
    columns: (caption-box, 1fr),
    stroke: (x, y) => if x == 0 { (top: 0.75pt, right: 0.75pt, bottom: 0.75pt) } else { none },
    line-stack(left),
    pad(left: caption-gutter, line-stack(right)),
  ))
}

#let cover(meta) = {
  caption-block(meta)
  block(width: 100%, above: cover-gap, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, strong(inl(need(meta, "title"))))
  })
  let c = need(meta, "counsel")
  let lines = c.names + c.lines
  if "on_brief" in c { lines += ("", "On the Memorandum of Law:") + c.on_brief }
  block(width: counsel-width, above: cover-gap, below: 0pt, breakable: false, line-stack(lines))
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (front matter, lower-case roman)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title, then the column label at the right.
#let table-head(title, col) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: heading-gap, sticky: true, align(center, strong(title)))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(right, col))
}

#let toc-section() = {
  table-head[TABLE OF CONTENTS][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading) {
      if hd.level > toc-depth { continue }
      let ind = (hd.level - 1) * toc-indent
      listing-row(hd.location(), [#h(ind)#hd.body#h(lead-slack)], page-label(hd.location()), toc-col,
        ind + toc-indent, 0pt)
    }
  }
}

#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: "") + " " + a.cite)).replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-head[TABLE OF AUTHORITIES][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nysupct-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let keys = authorities.keys().filter(k => authorities.at(k).kind == kind and hits.any(h => h.value == k))
      keys = keys.sorted(key: k => sort-key(authorities.at(k)))
      if keys.len() == 0 { continue }
      block(width: 100%, above: pitch-single, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for k in keys {
        let a = authorities.at(k)
        // distinct printed page labels, in document order
        let pages = ()
        for h in hits.filter(h => h.value == k) {
          let l = page-label(h.location())
          if l not in pages { pages.push(l) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let t = if "name" in a {
          [#if kind == "case" { emph(a.name) } else { a.name }, #a.cite]
        } else { a.cite }
        listing-row(none, [#t#h(lead-slack)], page-text, toa-col, toa-hang, toa-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block, service list, and word-count certification
// (CPLR 2101(a): the signer's name printed beneath the signature; NYSUPCT-LEN-003: 202.8-b(c))
// ---------------------------------------------------------------------------

#let rule-line(c, top: false) = block(width: 100%, above: 0pt, below: 0pt,
  stroke: if top { (top: 0.5pt) } else { (bottom: 0.5pt) }, c)

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let right = ("Respectfully submitted,", "") + sig.firm + ("",)
  right += (pad(right: rule-short, rule-line[By:]), inl(sig.signer))
  right += sig.at("lines", default: ())
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (1fr, sig-col),
    line-stack(("Dated:", need(meta, "place"), need(meta, "date"))),
    line-stack(right),
  ))
}

#let service-block(meta) = {
  if "to" not in meta { return }
  let lines = ("TO:",)
  for group in meta.to {
    lines += ("",) + group.names + group.lines   // as typed: the sample marks its own italics
  }
  block(width: 100%, above: gap, below: 0pt, breakable: false, line-stack(lines))
}

#let certificate-block(meta, words, filing) = {
  let clause = if filing == "reply" { "202.8-b(a)(ii)" } else { "202.8-b(a)(i)" }
  pagebreak()
  block(width: 100%, above: 0pt, below: gap, sticky: true, {
    set text(..edges(pitch-single))
    align(center, strong[CERTIFICATION OF COMPLIANCE WITH WORD COUNT LIMIT])
  })
  block(width: 100%, above: 0pt, below: 0pt, par[I hereby certify pursuant to 22 NYCRR 202.8-b(c) that the total
    number of words in the foregoing memorandum of law, exclusive of the caption, table of contents, table of
    authorities, and signature block, is #group-digits(words), according to the word count of the document as
    prepared, and thus that the document complies with the word count limit set forth in 22 NYCRR #clause.])
  block(width: 100%, above: gap, below: 0pt, breakable: false, {
    line-stack(("Dated: " + need(meta, "place") + ", " + need(meta, "date"), "", ""))
    grid(columns: (1fr, sig-col), [], line-stack((rule-line(top: true, inl(need(meta, "signature").signer)),)))
  })
}

// ---------------------------------------------------------------------------
// The memorandum of law
// ---------------------------------------------------------------------------

#let nysupct-motion-brief(meta, body) = {
  let title = need(meta, "title")
  let _ = need(meta, "parties")
  let filing = meta.at("filing", default: "in-chief")
  if filing not in ("in-chief", "reply") {
    panic("nysupct-motion-brief: `filing` must be `in-chief` or `reply`, not `" + filing + "`")
  }
  let limit = if filing == "reply" { word-limit-reply } else { word-limit-in-chief }
  let words = count-words(body)
  assert(
    words <= limit,
    message: "nysupct-motion-brief: " + str(words) + " words exceeds the 22 NYCRR 202.8-b(a) limit of " + str(limit),
  )

  // the page number centered at the foot, 12 pt, in a single-pitch line box that ends footer-distance above the
  // page edge; none on the cover
  let footer = context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display()))
  set document(title: title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: none,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number; list labels in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 3211(a)(1)"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Lists: the label half an inch in (the paragraph indent), the text an inch in.
  show enum: it => pad(left: para-indent, it)
  show list: it => pad(left: para-indent, it)

  // Headings, single-spaced and kept with the text after them (the author types the numbering, as the exemplar
  // does): level 1 centered bold; levels 2 and 3 bold; level 4 bold italic; level 5 italic.
  show heading.where(level: 6): it => panic("nysupct-motion-brief: headings deeper than level 5 are not supported")
  show heading: it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
    set text(size: type-size, weight: "regular", ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(it.body)) }
    else if it.level <= 3 { par(strong(it.body)) }
    else if it.level == 4 { par(strong(emph(it.body))) }
    else { par(emph(it.body)) }
  })

  // Footnotes at 11 pt (202.5(a): no smaller than 10-point), single-spaced; the mark, a space, the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false)[#super(num) #note.body]
  }

  // Block quotations: single-spaced (202.5(a) excepts quotations), indented on both sides.
  show quote.where(block: true): it => block(width: 100%, above: heading-gap, below: heading-gap,
    pad(left: quote-indent, right: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))

  // Citations: a link whose target is `toa:KEY` is recorded for the table of authorities. Links print as their text.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { text(fill: black, it.body) }
  }

  // ---- cover (page 1, unnumbered) ----
  cover(meta)

  // ---- front matter (lower-case roman from i) ----
  set page(numbering: "i", footer: footer)
  counter(page).update(1)
  if meta.at("toc", default: true) {
    toc-section()
    pagebreak()
  }
  toa-section(need(meta, "authorities"))

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  service-block(meta)
  certificate-block(meta, words, filing)
}
