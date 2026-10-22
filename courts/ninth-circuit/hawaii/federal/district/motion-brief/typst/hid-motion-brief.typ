// U.S. District Court for the District of Hawaii: motion with memorandum in support (FRCP 12;
// LR 7.1, 7.3, 7.4, 7.8, 10.2). The form is the motion, then the memorandum with a table of
// contents and a table of authorities (LR 7.4(f)), then the signature and any certificate.
//
// Rule-driven and content-agnostic. Requirement references are to ../README.md (the rules, with
// URLs and the date they were verified). No case-specific text, no coordinates measured off any
// filed document, no forced line breaks. The body is rendered by cmarker; the metadata is the
// YAML frontmatter of the sample.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit (Word's exact
// line spacing; docx/hid.lua and docx/reference.xml set the same twips).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// LR 10.2(a)(2): "All memoranda, including footnotes, shall utilize 14-point Times New Roman plain
// style". Times New Roman (vendored); Liberation Serif is its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 14pt                      // LR 10.2(a)(2): 14 pt, footnotes included
#let pitch-double = 32.2pt                 // LR 10.2(a)(4) double spacing: 2.3 x the size (the exemplar's 32.3 pt)
#let pitch-single = 16.1pt                 // headings, quotations, footnotes, caption, tables, signature: single
#let counsel-size = 12pt                   // the counsel block (LR 10.2(b)), smaller than the body
#let pitch-counsel = 13.8pt                // its single spacing, 1.15 x 12 pt
#let page-margin = 1in                     // LR 10.2(a)(1): one-inch margins
#let para-indent = 0.5in                   // first-line indent; a heading's label box
#let caption-left = 3.1in                  // the parties box
#let caption-pad = 0.125in                 // the parties box's text stands this far off its right rule
#let caption-foot = 8pt                    // and its last line this far above its bottom rule
#let caption-gap = 0.2in                   // the case column stands this far off the parties box
#let signature-indent = 3in                // the signature lines start 3 in from the margin
#let h1-above = 16.1pt                     // space above a level-1 heading (one single line)
#let h-above = 8pt                         // above a level-2 or level-3 heading
#let h-below = 8pt                         // below every heading
#let quote-gap = 14pt                      // above and below a block quotation
#let note-gap = 7pt                        // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt                // from the text to the footnote rule (the space LibreOffice keeps above it)
#let row-gap = 8pt                         // between two rows of the contents or authorities
#let group-gap = 16.1pt                    // above a group of the authorities
#let toc-step = 0.5in                      // contents: each level steps in half an inch
#let toc-page-col = 36pt                   // contents: the page numbers keep the last 36 pt of the line
#let toa-page-col = 72pt                   // authorities: the page lists keep the last 72 pt of the line
#let toa-hang = 0.35in                     // authorities: an entry's lines after the first
#let court-title = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII")  // LR 10.2(c)(1)
#let page-limit = 25                       // LR 7.4(a): a memorandum shall not exceed 25 pages ...
#let word-limit = 6250                     // LR 7.4(b): ... unless it contains no more than 6,250 words
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim"

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hid-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Plain text of a piece of content, for sorting only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// (A tag placed before a citation that starts a line can land on the previous page.)
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
      else {
        let r = tag-after-first-word(ch, tag)
        out.push(r.first())
        placed = r.last()
      }
    }
    return (out.join(), placed)
  }
  (c, false)
}

/// Word count of the markdown source (LR 7.4(d)), whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text. Headings, footnotes and quotations
/// count; the table of contents, table of authorities and certificates are not in the source.
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


/// One line block at `pitch` (a paragraph of its own); an empty line keeps its height.
#let line-block(pitch: pitch-single, above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch } else { auto }, {
  set text(..edges(pitch))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

/// A centered bold title line (TABLE OF CONTENTS, MEMORANDUM ...), a single line below it.
#let title-line(t) = block(width: 100%, above: 0pt, below: pitch-single, sticky: true,
  line-block(align(center, strong(t))))

/// A paragraph at the double pitch with the first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Caption (LR 10.2(b), (c); LR 7.3 for the first page of a motion)
// ---------------------------------------------------------------------------

// Counsel columns, by how many the frontmatter gives (`counsel.columns`). Widths sum to 6.5 inches.
#let counsel-widths = (
  "1": (6.5in,),
  "2": (3.25in, 3.25in),
  "3": (2.3in, 2.2in, 2.0in),
)

/// One counsel column: single-spaced lines at the counsel size; "" a blank line.
#let counsel-column(lines) = {
  set text(size: counsel-size)
  for l in lines { line-block(pitch: pitch-counsel, l) }
}

#let caption(meta) = {
  let columns = meta.at("counsel", default: (:)).at("columns", default: ())
  grid(
    columns: counsel-widths.at(str(columns.len())),
    ..columns.map(counsel-column),
  )
  if "counsel_for" in meta {
    line-block(above: pitch-single, emph(inl(meta.counsel_for)))
  }
  block(above: 2 * pitch-single, below: pitch-single, for t in court-title { line-block(align(center, strong(t))) })
  // The parties box (a rule at its right and bottom) and the case column: one single line each, a blank line
  // between the parts. Never split.
  let left = ()
  for p in need(meta, "parties") {
    for n in p.names { left.push(line-block(n)) }
    left.push(line-block(""))
    left.push(line-block(align(right, emph(inl(p.designation)))))
    if p != meta.parties.last() {
      left.push(line-block(""))
      left.push(line-block[v.])
      left.push(line-block(""))
    }
  }
  let right = (line-block(""), line-block("No. " + need(meta, "case_number")), line-block(""),
    line-block(strong(upper(inl(need(meta, "title"))))), line-block(""),
    line-block("Judge: " + need(meta, "judge")))
  if "hearing" in meta { right.push(line-block("Hearing: " + meta.hearing)) }
  if "trial_date" in meta { right.push(line-block("Trial Date: " + meta.trial_date)) }
  block(breakable: false, above: 0pt, below: pitch-single, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, inset: (right: caption-pad, bottom: caption-foot), stroke: (right: 0.75pt, bottom: 0.75pt),
      left.join()),
    pad(left: caption-gap, right.join()),
  ))
}

// ---------------------------------------------------------------------------
// Motion (the paragraphs before the memorandum; unnumbered) and the signature block
// ---------------------------------------------------------------------------

#let motion-paragraphs(meta) = {
  for p in meta.at("motion", default: ()) { body-par(inl(p)) }
}

/// Dated line at the left, a blank line, the signature lines from 3 in; never split. A blank line between blocks.
#let signature-block(meta) = {
  let sig = meta.at("signature", default: (:))
  block(breakable: false, above: pitch-single, below: 0pt, {
    if "date" in meta { line-block(meta.date) }
    line-block("")
    let blocks = sig.at("blocks", default: ())
    for (i, b) in blocks.enumerate() {
      for l in b.lines { line-block(if l == "" { "" } else { pad(left: signature-indent, inl(l)) }) }
      if i < blocks.len() - 1 { line-block("") }
    }
  })
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles (level 1 roman, level 2 letter, level 3 arabic)
// ---------------------------------------------------------------------------

#let heading-numbering(..n) = {
  let lvl = n.pos().len()
  let k = n.pos().last()
  if lvl == 1 { numbering("I.", k) }
  else if lvl == 2 { numbering("A.", k) }
  else { numbering("1.", k) }
}

/// A heading: bold, single-spaced at the type size, the label in a half-inch box and the text hanging after it;
/// kept with the next block.
#let style-heading(it) = {
  let num = if it.numbering != none { numbering(it.numbering, ..counter(heading).at(it.location())) } else { none }
  block(width: 100%, breakable: false, sticky: true, above: if it.level == 1 { h1-above } else { h-above },
    below: h-below, {
    set text(size: type-size, ..edges(pitch-single))
    par(first-line-indent: 0pt, hanging-indent: para-indent,
      strong[#if num != none { box(width: para-indent, num) }#it.body])
  })
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (LR 7.4(f))
// ---------------------------------------------------------------------------

/// A contents row: the label in a half-inch box after the level's step, the title hanging after it, a dot leader
/// to the page in the page column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  let num = numbering(heading-numbering, ..counter(heading).at(hd.location()))
  block(width: 100%, above: row-gap, below: 0pt, {
    set text(..edges(pitch-single))
    listing-row(hd.location(), { h(ind); box(width: para-indent, num); hd.body }, it.page(), toc-page-col,
      ind + para-indent, 0pt)
  })
}

#let toc-section() = {
  title-line[TABLE OF CONTENTS]
  show outline.entry: toc-entry
  outline(title: none, depth: 3, indent: 0pt)
}

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
  .replace(regex("[^a-z0-9 ]"), "")

#let toa-section(authorities) = {
  title-line[TABLE OF AUTHORITIES]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("hid-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    set text(..edges(pitch-single))
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: if first { 0pt } else { group-gap }, below: 0pt, sticky: true,
        par(first-line-indent: 0pt, {
          strong(title)
          if first { h(1fr); strong(underline[Page(s)]) }
        }))
      first = false
      for (key, a) in members {
        // Distinct page labels of the memorandum, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let body = {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }
        listing-row(none, body, page-text, toa-page-col, toa-hang, row-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Certificates (LR 7.4(e) compliance; certificate of service)
// ---------------------------------------------------------------------------

/// Certificate of compliance with the word limit (LR 7.4(e)). Required only when the memorandum runs
/// past 25 pages, that is, when the 6,250-word alternative of LR 7.4(b) is the one being used.
#let certificate-of-compliance(meta, words) = {
  title-line[CERTIFICATE OF COMPLIANCE]
  body-par[The undersigned certifies that the foregoing memorandum complies with the word limit of LR 7.4(b) and
    contains #str(words) words, counted from the headings, text, quotations and footnotes of the memorandum. The
    caption, table of contents, table of authorities and certificates are not counted (LR 7.4(d)).]
  signature-block(meta)
}

#let certificate-of-service(meta) = {
  let svc = meta.service
  title-line[CERTIFICATE OF SERVICE]
  body-par[I hereby certify that on #inl(svc.date), the foregoing document was filed electronically through the
    CM/ECF system, which will send notice of the filing to all counsel of record.]
  block(breakable: false, above: pitch-single, below: 0pt, {
    for l in svc.signature { line-block(if l == "" { "" } else { pad(left: signature-indent, inl(l)) }) }
  })
}

/// The memorandum body, then the signature block. The last paragraph is kept on the same page as the
/// signature (a signature never stands alone on a page). Footnote definitions stay in the first part,
/// with their references.
#let body-with-signature(meta, body-md) = {
  let parts = body-md.trim(at: end).split(regex("\n[ \t]*\n"))
  let tail = none
  for (i, p) in parts.enumerate() {
    if not p.starts-with("[^") { tail = i }
  }
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if tail == none or parts.at(tail).starts-with("#") {
    render(body-md)
    signature-block(meta)
  } else {
    let head = parts.enumerate().filter(e => e.first() != tail).map(e => e.last()).join("\n\n")
    render(head)
    block(breakable: false, {
      render(parts.at(tail))
      signature-block(meta)
    })
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let hid-motion-brief(meta, body-md) = {
  set document(title: need(meta, "title") + " (No. " + need(meta, "case_number") + ")")
  // The page number centered at the foot in a single-spaced line box (Word's footer).
  let footer-num = context align(center, text(..edges(pitch-single), counter(page).display()))
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 10.2(a)(4): double spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number ("§§ 480-3.1"; xengine binds a single sign), as the docx binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: heading-numbering)
  // Footnotes at the text size (LR 10.2(a)(2)), single lines, under a 30 % rule, 7 pt between notes; the mark and
  // a space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Quotations single-spaced, half an inch in on both sides.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- the motion (LR 7.1, 7.3, 7.8, 10.2): page 1 unnumbered; a continuation page prints its number, "2" (DEF-COVER-001) ----
  set page(numbering: "1", footer: context if counter(page).get().first() > 1 { footer-num })
  caption(meta)
  motion-paragraphs(meta)
  signature-block(meta)

  // ---- front matter: table of contents, table of authorities (lowercase roman) ----
  pagebreak()
  set page(numbering: "i", footer: footer-num)
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(meta.at("authorities", default: (:)))

  // ---- memorandum: arabic from 1 (LR 7.4(a): 25 pages) ----
  pagebreak()
  set page(numbering: "1", footer: footer-num)
  counter(page).update(1)
  title-line[MEMORANDUM IN SUPPORT OF MOTION]
  [#metadata("start") <body-start>]
  body-with-signature(meta, body-md)
  [#metadata("end") <body-end>]

  // ---- certificates ----
  context {
    let s = query(<body-start>).first().location()
    let e = query(<body-end>).first().location()
    let pages = counter(page).at(e).first() - counter(page).at(s).first() + 1
    let words = count-words(body-md)
    if pages > page-limit {
      if words > word-limit {
        panic("hid-motion-brief: the memorandum is " + str(pages) + " pages and " + str(words) + " words; LR 7.4 allows 25 pages or 6,250 words")
      }
      pagebreak(weak: true)
      certificate-of-compliance(meta, words)
    }
  }
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
