// New York Court of Appeals: answering brief (brief for respondent).
//
// Rule-driven and content-agnostic. Rule IDs (NY-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// NY-TYPE-001: serif, proportional; 22 NYCRR 500.1(i) names Times New Roman as its example face (vendored in /fonts;
// Liberation Serif is its metric twin, declared so the docx, which names Times New Roman, passes DEF-FONT-002).
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt                      // NY-TYPE-002: 14-point body for a proportional font.
#let note-size = 12pt                      // NY-TYPE-002: footnotes at least 12-point.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (docx/ny-answering.lua and docx/reference.xml set the same twips: 20 x pt).
#let pitch-double = 31.4pt                 // NY-FORM-002: double spacing, 31.4 pt line pitch at 14 pt.
#let pitch-single = 19pt                   // block quotations, headings, cover, tables and signatures: single spaced.
#let pitch-note = 16.3pt                   // footnotes at 12 pt, single spaced (NY-FORM-003).
#let note-gap = 7pt                        // between two footnotes
#let note-clearance = 12.6pt               // the body text to the footnote rule (LibreOffice's separator)
#let page-margin = 1in                     // NY-FORM-001: one inch on all sides.
#let para-indent = 0.5in
#let sig-indent = 3.25in                   // the signature column: the right half of the text
#let toc-col = 36pt                        // the contents' page numbers keep the last 36 pt of the line
#let cover-gaps = (4.4, 4, 3.6, 3.2, 2.8, 2.4, 2, 1.6, 1.3, 1, 0.8, 0.6, 0.4, 0.2, 0) // the gap between the cover's parts, in lines

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ny-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ny-answering-brief: the sample must start with a YAML frontmatter block") }
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

/// Word count of the markdown body, whitespace-delimited like a word processor.
/// Footnote definitions are removed; markup characters are counted as they are
/// (a known approximation, see README "Known gaps").
#let count-words(md) = {
  let s = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:.*$"), "")
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// One single-spaced line (or paragraph) of the front and back matter, `above` pt above it.
#let line-par(body, above: 0pt, align-to: left, indent: 0pt) = block(above: above, below: 0pt, width: 100%,
  pad(left: indent, align(align-to, par(first-line-indent: 0pt, body))))

// ---------------------------------------------------------------------------
// Cover (NY-COVER-001..003; no colour, no plastic cover: NY-FORM-005)
// ---------------------------------------------------------------------------

#let cover-body(meta, g) = {
  let gap = g * pitch-single
  let c(body, above: 0pt) = line-par(body, above: above, align-to: center)
  // 22 NYCRR 500.13(b): the argument request (time and presenter) goes in the upper right corner.
  if "argued_by" in meta {
    line-par([To be argued by:], align-to: right)
    line-par(inl(meta.argued_by), align-to: right)
  }
  c(strong[Court of Appeals], above: if "argued_by" in meta { gap } else { 0pt })
  c(strong[of the State of New York])
  c(need(meta, "apl_docket"), above: gap)
  if "county_clerk_index" in meta { c(meta.county_clerk_index) }
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    // the first name: a gap below the docket; after "against": as far below it as it stands below the designation
    for (k, name) in side.names.enumerate() {
      c(inl(name), above: if k > 0 { 0pt } else if i == 0 { gap } else { 8.4pt + gap / 4 })
    }
    c(inl(side.designation), above: 4.2pt)
    if i < sides.len() - 1 { c(emph("\u{2013}against\u{2013}"), above: 8.4pt + gap / 4) }
  }
  c(strong(upper(need(meta, "brief_title"))), above: gap)
  if "proceeding" in meta { c(inl(meta.proceeding), above: gap / 2) }
  // Counsel, side by side (500.13(b): name, address, telephone and facsimile numbers).
  let groups = need(meta, "counsel")
  block(above: gap, below: 0pt, grid(
    columns: groups.map(g => 1fr),
    column-gutter: 0.3in,
    ..groups.map(g => {
      for n in g.at("names") { line-par(inl(n)) }
      for l in g.at("lines", default: ()) { line-par(emph(inl(l))) }
    })
  ))
  line-par(need(meta, "phone"), above: 11.2pt)
  // 500.13(b): counsel's facsimile number is printed under the telephone line when given.
  if "fax" in meta { line-par(meta.fax) }
  if "date" in meta { line-par(meta.date, above: 5.6pt) }
}

/// The cover is one page. The space between its parts is the only thing that gives: the largest gap (in single
/// lines) at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g))).height <= size.height
  let g = cover-gaps.find(fits)
  if g == none { panic("ny-answering-brief: the cover does not fit on one page; shorten the caption or counsel") }
  cover-body(meta, g)
}))

// ---------------------------------------------------------------------------
// Front and back matter headings, double-spaced text
// ---------------------------------------------------------------------------

/// The heading of a front or back page (not a heading element: it is not in the table of contents).
#let page-heading(title) = block(width: 100%, above: 0pt, below: 14pt, sticky: true,
  align(center, par(first-line-indent: 0pt, strong(title))))

#let double-spaced(body) = {
  set text(..edges(pitch-double))
  set par(first-line-indent: (amount: para-indent, all: true))
  body
}

// ---------------------------------------------------------------------------
// Disclosure statement (NY-DISC-001: 22 NYCRR 500.1(f); shown only when given)
// ---------------------------------------------------------------------------

#let disclosure-page(meta) = {
  if "disclosure" not in meta { return }
  page-heading[DISCLOSURE STATEMENT]
  double-spaced(inl(meta.disclosure))
  pagebreak()
}

// ---------------------------------------------------------------------------
// Tables: contents and authorities (NY-TOC-001; authorities without page numbers: known gap)
// ---------------------------------------------------------------------------

#let toc-page() = {
  page-heading[TABLE OF CONTENTS]
  // Page column heading, as filed contents pages print it.
  line-par(strong(underline[Page]), align-to: right)
  show outline.entry: it => {
    let ind = (it.element.level - 1) * para-indent
    listing-row(it.element.location(), [#h(ind)#it.element.body], it.page(), toc-col, ind,
      if it.element.level == 1 { 8.4pt } else { 4.2pt })
  }
  outline(title: none, depth: 2, indent: 0pt)
}

#let toa-groups = (
  (kind: "case", title: "Cases"),
  (kind: "constitution", title: "Constitutional Provisions"),
  (kind: "statute", title: "Statutes"),
  (kind: "regulation", title: "Regulations"),
  (kind: "rule", title: "Rules"),
  (kind: "other", title: "Other Authorities"),
)

#let toa-page(meta) = {
  if "authorities" not in meta { return }
  pagebreak()
  page-heading[TABLE OF AUTHORITIES]
  let auths = meta.authorities.values()
  let first = true
  for g in toa-groups {
    // Alphabetical within each group, as filed tables of authorities list them.
    let items = auths.filter(a => a.kind == g.kind).sorted(key: a => lower(a.name + " " + a.cite))
    if items.len() == 0 { continue }
    block(above: if first { 0pt } else { 19pt }, below: 0pt, sticky: true,
      par(first-line-indent: 0pt, strong(g.title)))
    first = false
    for a in items {
      let shown = if a.kind == "case" { "*" + a.name + "*" } else { a.name }
      block(above: 7pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: para-indent, inl(shown + ", " + a.cite)))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature and certificates (NY-SIG-001, NY-CERT-001, NY-CERT-002)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 21pt, below: 0pt, {
    line-par([Respectfully submitted,], indent: sig-indent)
    line-par(sig.signer, above: 25.2pt, indent: sig-indent)
    for l in sig.lines { line-par(inl("*" + l + "*"), indent: sig-indent) }
    if "date" in meta { line-par(meta.date, indent: sig-indent) }
  })
}

#let signer-block(meta) = block(breakable: false, above: 21pt, below: 0pt, {
  line-par(need(meta, "signature").signer, indent: sig-indent)
  if "date" in meta { line-par(meta.date, indent: sig-indent) }
})

#let certificate-of-compliance(meta, words) = {
  pagebreak()
  page-heading[CERTIFICATE OF COMPLIANCE]
  double-spaced[I certify that this brief complies with the word limit of 22 NYCRR 500.13(c)(1), that it contains #group-digits(words) words in the body of the brief, excluding the caption, tables and signature block, and that the count was made by the word-processing system used to prepare it.]
  signer-block(meta)
}

#let certificate-of-service(meta) = {
  if "service" not in meta { return }
  pagebreak()
  page-heading[CERTIFICATE OF SERVICE]
  double-spaced[I certify that on the date below I served copies of this brief on counsel for all parties by #meta.service.method.]
  for u in meta.service.at("unregistered", default: ()) {
    block(above: 14pt, below: 0pt, breakable: false, { line-par(inl(u.name)); line-par(inl(u.address)) })
  }
  signer-block(meta)
}

// ---------------------------------------------------------------------------
// Main entry
// ---------------------------------------------------------------------------

#let ny-answering-brief(meta, md) = {
  set document(title: need(meta, "brief_title"))
  // Front matter (cover unnumbered, tables in roman); the body restarts at 1 (set below). The page number: centred
  // in a single-pitch line box whatever the text around it (Word's footer), at the same place on every page.
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "i",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  // No punctuation hanging into the margin (typst overhang), which Word does not do.
  set text(font: font-family, size: body-size, lang: "en", fallback: false, overhang: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, ragged right, no kerning or ligatures, no
  // hyphenation, line boxes of the pitch, footnote marks at 58 %, a section sign kept with its number, no break
  // inside "120.10(1)(a)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number too ("§§ 110.00": xengine binds a single one; the docx filter binds both).
  show regex("[§¶]+ \\S+"): it => box(it)
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 1.5in, stroke: 0.5pt))
  // NY-TYPE-002: footnotes at least 12-point; single spaced (NY-FORM-003). The note number is followed by a space,
  // as a word processor sets it.
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Section headings (NY-HEAD-001): level 1 centered, bold, capitals. Sub-headings: bold, left, with the letters and
  // numerals typed in the markdown; level 3 half an inch in, level 4 italic an inch in. Single spaced, kept with the
  // text after them.
  show heading: it => {
    let (above, below, ind) = (
      (19.6pt, 16.8pt, 0pt), (16.8pt, 12.6pt, 0pt), (18.2pt, 15.4pt, 0.5in), (16.8pt, 14pt, 1in),
    ).at(calc.min(it.level, 4) - 1)
    block(width: 100%, above: above, below: below, sticky: true, {
      set text(size: body-size, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, strong(upper(it.body))) }
      else if it.level == 4 { pad(left: ind, emph(it.body)) }
      else { pad(left: ind, strong(it.body)) }
    })
  }

  // Block quotations (NY-FORM-003): indented half an inch on both sides, single-spaced.
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    it.body
  }))

  { set text(..edges(pitch-single)); cover(meta) }
  {
    set text(..edges(pitch-single))
    disclosure-page(meta)
    toc-page()
    toa-page(meta)
  }

  // Body: starts on a new page, numbered from 1; the first heading begins the argument.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  {
    set text(..edges(pitch-single))
    signature-block(meta)
    certificate-of-compliance(meta, count-words(md))
    certificate-of-service(meta)
  }
}
