// New York Supreme, Appellate Division: a respondent's (answering) brief (22 NYCRR 1250.8(c)), any of the four departments.
// Built from the reply-brief template of this court (same cover, tables and printing statement);
// the word limit and the heading scheme outside the Argument differ.
//
// Rule-driven and content-agnostic. Rule references (22 NYCRR Part 1250) are in ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). docx/nyappdiv-answering-brief.lua and
// docx/reference.xml set the same numbers in twips (20 x pt), so the Word render breaks every line and page here.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // 1250.8(f)(1): serifed, proportionally spaced; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 14pt                      // 1250.8(f)(1)(i): body in 14-point type; footnotes at the same size (at least 12).
#let page-margin = 1in                     // 1250.8(h): one inch on all sides.
#let footer-distance = 0.5in               // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in
#let heading-tab = 0.5in                   // a heading label in a half-inch box, its text hanging after it
#let toc-depth = 4
#let toc-col = 0.5in                       // contents: the page column the rows wrap before
#let toa-col = 1in                         // authorities: the page column ("9, 12" and "passim" fit)
#let toa-hang = 0.5in                      // an authority's later lines hang this far in
#let lead-slack = 4pt                      // a row keeps its last word before the leader only with this much to spare
                                           // (LibreOffice wants about 4 pt after the leader's three spaces)
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim".
#let word-limit = 14000                    // 1250.8(f)(2): computer-generated respondent's brief.
#let caption-separator = [– against –]
#let docket-col = 3.1in                    // the cover's top row: the docket at the left, the argument notice at the right
#let arg-col = 3.1in
#let designation-left = 3.25in             // a party's designation, from the middle of the line
#let counsel-left = 3.1in                  // the filing attorneys at the lower right (1250.8(b))
#let rule-gap = 2.5pt                      // between the two lines of the cover's double rule
#let short-rule = 2in
#let closing-left = 3.25in                 // "Respectfully submitted," from the middle of the line
#let sig-gutter = 0.4in                    // between two firms' signature columns
#let oath-col = 3in                        // the affidavit's venue: the ")" column
#let notary-left = 3.25in

// Pitches (line boxes) and the spaces between blocks.
#let pitch-body = 28pt                     // 1250.8(h): double-spaced text, two 14 pt lines
#let pitch-single = 16.1pt                 // single spacing (cover, headings, quotations, tables, footnotes, signature, page number): Word's 1.15 x 14 pt
#let blank = pitch-single                  // a blank single line
#let cover-gap = 8pt                       // between the cover's parts (it must fit one page)
#let heading-above = 16pt                  // above a section heading
#let heading-below = 12pt                  // below it
#let sub-above = 12pt                      // above a numbered heading
#let sub-below = 6pt                       // below it
#let quote-gap = 14pt                      // above and below a block quotation
#let quote-par = 12pt                      // between two paragraphs of a quotation
#let toc-above = 8pt                       // above a level 1 row of the contents
#let toa-above = 4pt                       // above each authority
#let group-above = 16pt                    // above an authorities group's title
#let group-below = 4pt
#let note-gap = 6pt                        // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 16.1pt               // the body text to the footnote rule (Word's separator line)
#let sig-gap = 16pt                        // between the parts of the signature block

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
  if key not in meta { panic("nyappdiv-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyappdiv-answering-brief: the sample must start with a YAML frontmatter block") }
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

/// 6915 -> "6,915"
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
/// Markup characters are removed first; links keep their text. (The docx filter counts the same way, rule for rule.)
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

/// A blank to fill in by hand: a run of `n` underscores (text, so every engine sets it alike).
#let fill-in(n) = "_" * n

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading. Under the Argument the points are I. / A. / 1. / a.
/// (level 2 to 5); in the other sections (e.g. the counterstatement of facts) A. / 1. / a. / (1).
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  let scheme = if in-argument(h.location()) { ("I.", "A.", "1.", "a.") } else { ("A.", "1.", "a.", "(1)") }
  if h.level < 2 or h.level > 5 { panic("nyappdiv-answering-brief: headings deeper than level 5 are not supported") }
  numbering(scheme.at(h.level - 2), n)
}

/// Point headings (level 2 under the Argument) are set in capitals, as the exemplar does.
#let is-point(h) = h.level == 2 and in-argument(h.location())

// Headings are single-spaced (1250.8(h)), bold, at the body size, and kept with the text after them.
#let style-heading(it) = {
  set text(size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  if it.level == 1 or it.numbering == none {
    // Section headings: bold, capitals, centered (1250.8(f)(1): capitals and bold only in headings).
    block(width: 100%, sticky: true, breakable: false, above: heading-above, below: heading-below,
      align(center, strong(upper(it.body))))
  } else {
    // Numbered sub-headings: the label in a half-inch box at its level's indent; the text wraps under itself.
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, breakable: false, above: sub-above, below: sub-below,
      pad(left: ind, par(hanging-indent: heading-tab, {
        box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
        if is-point(it) { strong(upper(it.body)) }
        else if it.level >= 4 { strong(emph(it.body)) }
        else { strong(it.body) }
      })))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// Table of contents: every outlined heading (point headings, sections, the printing statement).
#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(..edges(pitch-single))
    align(right, strong(underline[Page]))
  })
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      if hd.level > toc-depth { continue }
      let loc = hd.location()
      let numbered = hd.numbering != none and hd.level >= 2
      let row = if not numbered {
        (upper(hd.body), heading-tab, toc-above)
      } else {
        let ind = (hd.level - 2) * heading-tab
        let title = if is-point(hd) { upper(hd.body) } else { hd.body }
        ([#h(ind)#box(width: heading-tab, heading-label(hd))#title], ind + heading-tab, 0pt)
      }
      listing-row(loc, [#row.at(0)#h(lead-slack)], page-label(loc), toc-col, row.at(1), row.at(2))
    }
  }
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
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nyappdiv-answering-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      // The first group's title carries the column label at the right.
      block(width: 100%, above: if first { 0pt } else { group-above }, below: group-below, sticky: true, {
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let text = if "name" in a {
          [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }, #inl(a.cite)]
        } else { inl(a.cite) }
        listing-row(none, [#text#h(lead-slack)], page-text, toa-col, toa-hang, toa-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (1250.8(b))
// ---------------------------------------------------------------------------

/// The cover's double rule (a heavy line over a light one) and the short rule under the title.
#let double-rule(above) = block(width: 100%, above: above, below: cover-gap, height: 1.6pt + rule-gap + 0.5pt, {
  place(top, line(length: 100%, stroke: 1.6pt))
  place(bottom, line(length: 100%, stroke: 0.5pt))
})
#let title-rule = block(width: 100%, above: cover-gap, below: cover-gap, height: 0.7pt,
  align(center, line(length: short-rule, stroke: 0.7pt)))

/// The cover: the docket and the argument notice on one row (upper right: 1250.8(b)), the court,
/// the caption, the title, and the filing attorney's name, address, telephone and email (lower right).
#let cover(meta) = {
  let arg = need(meta, "argument")
  // The docket is printed as the filer writes it, label included (e.g. "Appellate No. ...", "Docket No. CA ...").
  let docket-lines = (inl(need(meta, "docket")),)
  if "county_clerk_index" in meta { docket-lines.push(meta.county_clerk_index) }
  let arg-lines = if "presenter" in arg {
    ([To be Argued by:], strong(upper(inl(arg.presenter))), [(Time Requested: #arg.time_requested)])
  } else { ([Submitted without oral argument],) }
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
    columns: (docket-col, 1fr, arg-col),
    line-stack(docket-lines), [], line-stack(arg-lines)))
  line-stack((strong[New York Supreme Court], [Appellate Division—#need(meta, "department")]), above: cover-gap,
    align-to: center)
  double-rule(cover-gap)
  // A side may name the word that joins it to the side above (`joiner`, e.g. "– and –" for a
  // second group of defendants); the default is the "against" separator.
  let cap = ()
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 { cap.push(align(center, if "joiner" in side { inl(side.joiner) } else { caption-separator })) }
    cap += side.names.map(n => align(center, inl(n)))
    cap.push(pad(left: designation-left, inl(side.designation)))
  }
  if "caption_note" in meta { cap.push(align(center, inl(meta.caption_note))) }
  line-stack(cap)
  double-rule(cover-gap)
  line-stack((strong(upper(inl(need(meta, "brief_title")))),), align-to: center)
  title-rule
  // Lower right: the filing attorneys, name, address, telephone and email; whom they represent.
  let c = ()
  for g in need(meta, "counsel") {
    c.push(strong(upper(inl(g.firm))))
    c += g.lines.map(inl)
    c.push("")
  }
  c.push(emph(inl(need(meta, "attorneys_for"))))
  line-stack(c, inset-l: counsel-left)
  double-rule(cover-gap)
}

// ---------------------------------------------------------------------------
// Signature, printing statement, proof of service
// ---------------------------------------------------------------------------

/// Signature block after the Conclusion. Each firm's block is a column; the block marked `by`
/// carries the "By:" signature line. The block stays on one page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  line-stack((sig.date, sig.place), above: heading-above)
  if "closing" in sig { line-stack((inl(sig.closing),), inset-l: closing-left) }
  let cells = ()
  for b in sig.blocks {
    let l = (strong(upper(inl(b.firm))),)
    if "by" in b { l.push([By: #fill-in(18)]) }
    l += b.names.map(inl)
    l += b.lines.map(x => emph(inl(x)))
    cells.push(line-stack(l))
  }
  block(width: 100%, above: sig-gap, below: 0pt, breakable: false,
    grid(columns: sig.blocks.map(b => 1fr), column-gutter: sig-gutter, ..cells))
  line-stack((emph(inl(sig.attorneys_for)),), above: sig-gap)
}

/// Printing Specifications Statement (1250.8(j)): the brief's last page. The typeface named is the
/// one this file sets (the vendored face), so the statement is true of the PDF it sits in.
#let printing-statement(words) = {
  heading(level: 1, numbering: none)[Printing Specifications Statement]
  par[I hereby certify pursuant to 22 NYCRR 1250.8(j) that the foregoing brief was prepared on a computer.]
  par[A proportionally spaced typeface was used, as follows:]
  line-stack((
    [Name of typeface: #font-family.first()],
    [Point size: #str(int(type-size.pt()))],
    [Line spacing: Double],
  ), above: quote-gap, inset-l: para-indent)
  block(width: 100%, above: quote-gap, below: 0pt,
    par[*Word Count.* The total number of words in this brief, inclusive of point headings and footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, and this statement, is #group-digits(words).])
}

/// Proof of service: blanks only. Nothing case-specific is printed here.
#let affidavit-of-service() = {
  heading(level: 1, numbering: none, outlined: false)[Affidavit of Service]
  let venue(a, b) = grid(columns: (oath-col, 1fr), a, b)
  line-stack((venue([STATE OF NEW YORK], [)]), venue([], [) ss.:]), venue([COUNTY OF #fill-in(14)], [)])))
  block(width: 100%, above: blank, below: 0pt)[
    #par[#fill-in(26), being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years of age, and resides at #fill-in(24).]
    #par[On the #fill-in(7) day of #fill-in(12), 20#fill-in(4), deponent served the within brief upon each attorney for each party to this appeal, at the address designated by that attorney for that purpose, by #fill-in(24), and by #fill-in(14).]
  ]
  line-stack((fill-in(24), [Sworn to before me this], [#fill-in(7) day of #fill-in(12), 20#fill-in(4)], "", fill-in(24),
    [Notary Public]), above: 2 * blank, inset-l: notary-left)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let nyappdiv-answering-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("docket", "department", "argument", "caption", "brief_title", "counsel",
            "attorneys_for", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- word limit (1250.8(f)(2)): the body, inclusive of point headings and footnotes ----
  let words = count-words(md)
  if words > word-limit {
    panic("nyappdiv-answering-brief: the brief has " + str(words) + " words; 22 NYCRR 1250.8(f)(2) allows " + str(word-limit) + " for a respondent's brief")
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", " + need(meta, "docket"),
    author: need(meta, "signature").blocks.first().firm,
  )
  set page(paper: "us-letter", margin: page-margin, numbering: none,
    // 1250.8(h): pages numbered consecutively; centred at the foot in a single-pitch line box that ends
    // footer-distance above the page edge; the cover carries none.
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context {
      let n = here().page-numbering()
      if n != none { align(center, text(..edges(pitch-single), counter(page).display(n))) }
    })
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number, no break inside ")(".
  show: xengine.with(pitch: pitch-body)
  set heading(numbering: none)
  // Footnotes at the body size (1250.8(f)(1)(i): at least 12 points) in single lines: the mark, a space, the note
  // (docx: Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }
  // Block quotations: single-spaced and indented half an inch on both sides (1250.8(h)).
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: quote-par)
    pad(left: para-indent, right: para-indent, it.body)
  })
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)
  pagebreak()

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it. Footnote definitions are not paragraphs of the text and never take part.
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    let parts = md.trim(at: end).split(regex("\n[ \t]*\n"))
    let k = parts.len() - 1
    while k > 0 and parts.at(k).starts-with("[^") { k -= 1 }
    let first = if k > 0 and parts.at(k - 1).starts-with("#") { k - 1 } else { k }
    let notes = parts.slice(k + 1)
    let head = parts.slice(0, first) + notes
    let tail = parts.slice(first, k + 1)
    if tail.len() == 0 or tail.first().starts-with("[^") {
      render(parts.join("\n\n"))
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, signature-block(meta))
    } else {
      render(head.join("\n\n"))
      // (a heading that opens the block: its space above is the block's)
      block(width: 100%, breakable: false, above: if tail.first().starts-with("#") { heading-above } else { 0pt },
        below: 0pt, { render(tail.join("\n\n")); signature-block(meta) })
    }
  }

  // ---- printing specifications statement (1250.8(j)), then proof of service ----
  pagebreak(weak: true)
  printing-statement(words)
  pagebreak(weak: true)
  affidavit-of-service()
}
