// California Supreme Court: petition for review.
//
// Rule-driven and content-agnostic. Requirement IDs (CAL-...) refer to ../README.md, which
// cites the Cal. Rules of Court (rules 8.504, 8.204, 8.74, 8.25). No case-specific text, no
// coordinates measured off any filed petition, no forced line breaks. The markdown body is
// rendered by cmarker; the metadata comes from the YAML frontmatter of the same file
// (schema: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other. docx/cal.lua and docx/reference.xml set the same numbers in twips (20 x pt), so
// the Word render breaks every line and every page where this one does.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// CAL-FORM-002: a proportionally spaced serif face; rule 8.74(b)(1) and 8.204(b)(2) prefer Century Schoolbook but
// require none: Times New Roman, the house face (docs/FONTS.md), vendored in fonts/. The certificate names it.
#let font-family = ("Times New Roman", "Liberation Serif")
#let font-named = "Times New Roman"        // the face the certificate of compliance states
#let type-size = 13pt                      // CAL-FORM-003: 13-point or larger, footnotes included (rules 8.204(b)(4), 8.74(b)(1))
#let margin-x = 1.5in                      // CAL-FORM-006: left and right (rules 8.204(b)(6), 8.74(b)(3))
#let margin-y = 1in                        // CAL-FORM-006: top and bottom
#let footer-distance = 0.5in               // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                   // first-line indent of every body paragraph
#let label-box = 0.5in                     // a heading or list label in a box this wide; each deeper heading level starts this far further in
#let quote-inset = 0.5in                   // block quotations: indented on both sides
#let toc-step = 0.35in                     // contents: each deeper level starts this far further in
#let toc-col = 0.5in                       // contents: the page column the rows wrap before
#let toa-col = 1.25in                      // authorities: the page column ("4, 5, 6, 7, 10" fits)
#let toa-hang = 0.35in                     // an authority's citation and later lines start this far in
#let counsel-left = 2in                    // the cover's counsel block and the signature column start this far from the margin
#let service-indent = 0.5in                // the proof of service's list of persons served
#let rule-length = 2in                     // the short rules between the cover's parts
#let toc-depth = 4
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim"
#let word-limit = 8400                     // CAL-LEN-003: rule 8.504(d)(1), computer-prepared petition, footnotes included.
#let lead-slack = 4pt                      // a table row keeps its last word before the leader only with this much to spare: LibreOffice
                                           // wants about 4 pt free after the leader's three spaces (docs/EVAL-LOOP.md), so typst asks for it too

// Pitches and spaces (twips in docx/cal.lua and docx/reference.xml: 20 x pt).
#let pitch-body = 24pt                     // CAL-FORM-005: the text is at least 1.5-spaced (rule 8.204(b)(5); 1.5 x 14.95 pt = 22.4 pt); double, as filed
#let pitch-single = 14.95pt                // single spacing of the face at 13 pt (1.15 em): headings, cover, tables, quotations, footnotes, certificates
#let cover-gap = 18pt                      // between the cover's parts
#let h1-above = 24pt                       // above a section heading
#let heading-above = 12pt                  // above a sub-heading
#let heading-below = 12pt                  // below every heading, before its text
#let quote-gap = 12pt                      // above and below a block quotation
#let toc-row-gap = 6pt                     // above a contents row (level 1: toc-h1-gap)
#let toc-h1-gap = 12pt
#let toa-group-gap = 14.95pt               // above a group title of the authorities (a blank single line)
#let toa-row-gap = 9pt                     // above an authority
#let sig-above = 24pt                      // the text to the signature block, "Dated:" to "Respectfully submitted,"
#let signer-above = 24pt                   // "Respectfully submitted," to "/s/"
#let cert-gap = 12pt                       // between the paragraphs of a certificate
#let service-gap = 12pt                    // above each person served
#let note-gap = 6.5pt                      // between two footnotes
#let note-clearance = 8.45pt               // the text to the footnote rule: with note-gap, Word's single-line separator

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = unloose(render(s))

#let need(meta, key) = {
  if key not in meta { panic("cal-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cal-petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-pitch paragraph with explicit spaces above and below it; `left`/`right` inset it, `hang` indents its
/// later lines, `align` places it. `c` is markdown or content.
#let sline(above: 0pt, below: 0pt, left: 0pt, right: 0pt, hang: 0pt, align: left, sticky: false, c) = block(
  width: 100%, above: above, below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set std.align(align)
    pad(left: left, right: right, par(first-line-indent: 0pt, hanging-indent: hang,
      if type(c) == str { inl(c) } else { c }))
  })

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

/// 14000 -> "14,000"
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
/// Markup characters are removed first; links keep their text; footnote text is counted.
/// (docx/cal.lua count_words: the same rules, line by line.)
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
// Headings: numbering scheme (CAL-CONT-001)
// ---------------------------------------------------------------------------

/// I. / A. / 1. / a. / (1), by level. Roman numerals mark the sections (Issues, Introduction, ...).
#let heading-number(..n) = {
  let k = n.pos().last()
  let lvl = n.pos().len()
  if lvl == 1 { numbering("I.", k) }
  else if lvl == 2 { numbering("A.", k) }
  else if lvl == 3 { numbering("1.", k) }
  else if lvl == 4 { numbering("a.", k) }
  else if lvl == 5 { numbering("(1)", k) }
  else { panic("cal-petition: headings deeper than level 5 are not supported") }
}

/// Printed label of a numbered heading.
#let heading-label(h) = numbering(heading-number, ..counter(heading).at(h.location()))

/// Headings on the single pitch, bold, kept with their text. Level 1: centered capitals after its numeral ("I.");
/// an unnumbered one (front and back matter) the same without it. Deeper levels: the label in a box at the level's
/// indent, the later lines hanging after it.
#let style-heading(it) = {
  set text(size: type-size, weight: "bold", ..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if it.level == 1 {
    block(width: 100%, above: h1-above, below: heading-below, sticky: true, align(center,
      if it.numbering == none { upper(it.body) } else [#heading-label(it) #upper(it.body)]))
  } else {
    let ind = (it.level - 2) * label-box
    block(width: 100%, above: heading-above, below: heading-below, sticky: true,
      par(hanging-indent: ind + label-box, [#h(ind)#box(width: label-box, heading-label(it))#it.body]))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CAL-TOC-001, CAL-TOA-001)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title (an unnumbered level 1 heading, on a new page) and its column label at the right.
#let table-head(title, col) = {
  heading(level: 1, numbering: none, title)
  sline(align: right, sticky: true, strong(underline(col)))
}

/// Contents: every outlined heading from the Issues to the conclusion (the front matter and certificates are not
/// listed). A row: the label in a box at the level's indent, the title hanging after it, a leader to the page.
#let toc-section() = {
  table-head[Table of Contents][Page]
  context {
    set text(..edges(pitch-single))
    let hs = query(selector(heading.where(outlined: true)).after(<body-start>).before(<certs-start>))
    for hd in hs {
      if hd.level > toc-depth { continue }
      let ind = (hd.level - 1) * toc-step
      let lab = if hd.numbering != none { heading-label(hd) } else { none }
      let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
      listing-row(hd.location(),
        [#h(ind)#if lab != none { box(width: label-box, lab) }#title#h(lead-slack)],
        page-label(hd.location()), toc-col, ind + if lab != none { label-box } else { 0pt },
        if hd.level == 1 { toc-h1-gap } else { toc-row-gap })
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

/// Sort key of an authority: its `sort` field, else its name and citation, as lower-case letters, digits and spaces.
#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: "") + " " + a.cite)).replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body. An authority with a name: the name (a case
/// in italics) and a comma on its own line, then the citation toa-hang in with the leader and its pages; one without:
/// the citation alone.
#let toa-section(authorities) = {
  table-head[Table of Authorities][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cal-petition: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      sline(above: toa-group-gap, sticky: true, strong(title))
      for (key, a) in members {
        // Distinct printed page numbers, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let cite-above = toa-row-gap
        if "name" in a {
          sline(above: toa-row-gap, sticky: true, right: toa-col, hang: toa-hang,
            [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) },])
          cite-above = 0pt
        }
        pad(left: if "name" in a { toa-hang } else { 0pt },
          listing-row(none, [#inl(a.cite)#h(lead-slack)], page-text, toa-col,
            if "name" in a { 0pt } else { toa-hang }, cite-above))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (rules 8.504(b)(7), 8.74(a)(9), 8.74(c)(1); CAL-CONT-001 to -004)
// ---------------------------------------------------------------------------

#let short-rule = block(width: 100%, above: cover-gap, below: 0pt, align(center, line(length: rule-length, stroke: 0.7pt)))

#let cover-body(meta) = {
  sline(align: center, strong[No. #meta.at("supreme_court_case", default: "S__________")])
  // Fixed court heading for this document type (not case text).
  sline(above: cover-gap, align: center)[In the Supreme Court of the State of California]
  short-rule
  // Title and designation of the parties: identical to the Court of Appeal opinion (rule 8.504(b)(7)).
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for (k, name) in side.names.enumerate() {
      sline(above: if k == 0 { cover-gap } else { 0pt }, align: center, name)
    }
    sline(align: right, side.designation)
    if i < sides.len() - 1 { sline(above: cover-gap / 2, align: center)[v.] }
  }
  short-rule
  // Court below: the Court of Appeal and trial court numbers and judge (rule 8.74(c)(1)).
  sline(above: cover-gap, align: center, need(meta, "court_of_appeal"))
  sline(align: center, need(meta, "trial_court"))
  if "judge" in meta { sline(align: center, meta.judge) }
  short-rule
  sline(above: cover-gap, align: center, strong[PETITION FOR REVIEW])
  short-rule
  // Attorneys filing the petition: name, State Bar number, address, telephone (rule 8.74(a)(9)), and the party they
  // represent (rule 8.74(c)(1)).
  let groups = need(meta, "counsel")
  for (gi, g) in groups.enumerate() {
    let lines = g.names + g.at("lines", default: ())
    if gi == groups.len() - 1 { lines.push("Telephone: " + need(meta, "phone")) }
    for (k, l) in lines.enumerate() {
      sline(above: if k == 0 { cover-gap } else { 0pt }, left: counsel-left, l)
    }
  }
  sline(left: counsel-left, emph(inl(need(meta, "represents"))))
  sline(above: cover-gap, need(meta, "date"))
}

/// The cover is page 1, its number not shown (rule 8.204(b)(7)). It must fit one page: the type size never shrinks.
#let cover(meta) = page(footer: none, {
  // Bookmark for the first page of the petition (rule 8.74(a)(3)); placed, so it takes no room and prints nothing.
  place(top + left, hide(heading(level: 1, numbering: none)[Petition for Review]))
  layout(size => {
    if measure(block(width: size.width, cover-body(meta))).height > size.height {
      panic("cal-petition: the cover does not fit on one page; shorten the counsel or party lines")
    }
  })
  cover-body(meta)
})

// ---------------------------------------------------------------------------
// Signature, certificates, proof of service (CAL-LEN-007, rule 8.25(a))
// ---------------------------------------------------------------------------

/// "Dated:" at the margin; from counsel-left "Respectfully submitted,", "/s/" and the signer, the signer in
/// capitals, the lines (in italics). Single-spaced, kept on one page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    sline[Dated: #need(meta, "date")]
    sline(above: sig-above, left: counsel-left)[Respectfully submitted,]
    sline(above: signer-above, left: counsel-left)[/s/ #sig.signer]
    sline(left: counsel-left, upper(sig.signer))
    for l in sig.at("lines", default: ()) { sline(left: counsel-left, emph(inl(l))) }
  })
}

/// Certificate of compliance: font and word count (rule 8.504(d)(1), rule 8.204(c)(1)). On a new page.
#let certificate-of-compliance(meta, words) = {
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Certificate of Compliance]
  sline[I certify that the attached PETITION FOR REVIEW uses a 13-point #font-named font and contains #group-digits(words) words.]
  signature-block(meta)
}

/// Proof of service (rule 8.25(a)): each party and court served, the manner of service. On a new page.
#let proof-of-service(meta) = {
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Proof of Service]
  sline[I certify that the foregoing PETITION FOR REVIEW was electronically served on the following interested parties on #need(meta, "date"), in the manner described.]
  for s in need(meta, "service") {
    let lines = (s.party,) + s.at("names", default: ()) + s.at("lines", default: ()) + (s.method,)
    block(width: 100%, breakable: false, above: service-gap, below: 0pt,
      for l in lines { sline(left: service-indent, l) })
  }
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// The body, chunk by chunk
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of the body is rendered alone with the definitions of the footnotes it refers to:
/// a heading, a list item, a block quotation (each of its paragraphs single-spaced, quote-inset in on both sides) or
/// a paragraph on the body pitch, its first line indented. A paragraph that anchors a footnote has no widow or orphan
/// rule (docx: Body Text Note, Word's widow control off), so its line with the mark may move on with the note.
/// The last chunk, a paragraph, is kept on one page with `tail` (the signature block), so the signature never
/// stands alone (docx: Body Text Keep).
#let petition-body(body, tail) = {
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
    .filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    if t.starts-with("#") {
      render(t + defs)
    } else if t.starts-with(">") {
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      let ps = q.split(regex("\\n[ \\t]*\\n")).map(s => s.trim()).filter(s => s != "")
      for (k, s) in ps.enumerate() {
        sline(above: if k == 0 { quote-gap } else { 0pt }, below: if k == ps.len() - 1 { quote-gap } else { 0pt },
          left: quote-inset, right: quote-inset, s + defs)
      }
    } else if t.starts-with(regex("([-*+]|[0-9]+[.)])[ \\t]")) {
      render(t + defs)
    } else {
      set text(costs: (widow: 0%, orphan: 0%)) if defs != ""
      let p = par(unloose(render(t + defs)))
      if last { block(width: 100%, breakable: false, above: 0pt, below: 0pt, { p; tail }) } else { p }
    }
    if last and (t.starts-with("#") or t.starts-with(">") or t.starts-with(regex("([-*+]|[0-9]+[.)])[ \\t]"))) {
      panic("cal-petition: the body must end with a paragraph (the conclusion), kept with the signature block")
    }
  }
}

// ---------------------------------------------------------------------------
// The petition
// ---------------------------------------------------------------------------

#let cal-petition(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("caption", "court_of_appeal", "trial_court", "counsel", "phone", "represents", "signature", "date", "service") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- rule 8.504(b)(1): the body opens with a concise statement of the issues presented ----
  let opening = md.trim(at: start)
  let first-heading = opening.match(regex("^#[ \t]+(.*)"))
  if first-heading == none or not lower(first-heading.captures.at(0)).contains("issue") {
    panic("cal-petition: the body must open with the statement of issues presented (rule 8.504(b)(1))")
  }
  if md.match(regex("(?mi)^#[ \t]+conclusion[ \t]*$")) == none {
    panic("cal-petition: the body needs a Conclusion heading")
  }

  // ---- rule 8.504(d)(1): length, footnotes included; the tables and certificates are not counted ----
  let words = count-words(md)
  if words > word-limit {
    panic("cal-petition: the petition has " + str(words) + " words; rule 8.504(d)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: "Petition for Review, " + meta.at("supreme_court_case", default: "S__________"),
    author: need(meta, "signature").signer,
  )
  set page(
    paper: "us-letter", margin: (x: margin-x, y: margin-y),
    numbering: "1",
    // centered at the foot (rule 8.204(b)(7)), in a single-pitch line box that ends footer-distance above the page edge
    footer-descent: margin-y - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right (rule 8.74(b)(4): not justified), no kerning, ligatures
  // or hyphenation, line boxes of the body pitch, footnote marks at 58 %, a section sign kept with its number; list
  // labels in a half-inch box at the margin.
  show: xengine.with(pitch: pitch-body, list-indent: label-box)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A web address breaks only after a slash before a letter (where the docx filter lets Word break it).
  show regex("https?://\\S+"): it => {
    let s = it.text
    let (pieces, start) = ((), 0)
    for m in s.matches(regex("/[^/\\d\\s]")) {
      pieces.push(s.slice(start, m.start + 1))
      start = m.start + 1
    }
    pieces.push(s.slice(start))
    pieces.map(p => box(p)).join()
  }
  set heading(numbering: heading-number)
  show heading: style-heading
  // Footnotes at 13 pt (rule 8.204(b)(4)), single-spaced: the mark, a space, the note (docx: Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt) // the entry does not inherit the body's leading 0
    [#super(num) #note.body]
  }
  // Authority links print as text; a link whose target is `toa:KEY` is recorded on the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (page 1; its number is not printed) ----
  cover(meta)

  // ---- contents and authorities (pages 2 on; the same arabic sequence as the body) ----
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // ---- body ----
  [#metadata("body-start") <body-start>]
  petition-body(md, signature-block(meta))

  // ---- certificates and proof of service (rules 8.504(d)(1), 8.25(a)) ----
  [#metadata("certs-start") <certs-start>]
  certificate-of-compliance(meta, words)
  proof-of-service(meta)
}
