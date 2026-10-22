// U.S. Court of Appeals for the District of Columbia Circuit: appellant's principal brief.
//
// Rule-driven and content-agnostic. Requirement IDs (DC-...) refer to ../README.md. No case-specific
// text, no coordinates measured off a filed brief, no forced line breaks. The body is markdown rendered
// by cmarker; the metadata is the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a stated choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"  // FRAP 32(a)(5)(A): a serif, proportional face. Handbook IX.A.6 names Century; substitute per docs/FONTS.md (Century Schoolbook -> TeX Gyre Schola).
#let type-size = 14pt                  // FRAP 32(a)(5)(A): 14-point or larger, everywhere.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-body = 25pt                 // FRAP 32(a)(4): double-spaced body; the pitch of the filed exemplar (about 24 pt), a spacing choice, see README.
#let pitch-single = 21pt               // single spacing: block quotations, footnotes, tables, signature and certificate blocks, level-3 headings (at least 1.5 em: a tighter box puts the face's ascenders above the box in LibreOffice, which keeps the descent; see README)
#let pitch-cover = 16.4pt              // the cover's lines, set closer (FRAP 32(a)(2) fills one page)
#let h1-size = 19.5pt                  // section headings: bold capitals, centered (whole half points: Word has no others)
#let pitch-h1 = 29pt
#let h2-size = 17pt                    // level-2 headings: bold, flush left
#let pitch-h2 = 25pt
#let page-margin = 1in                 // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let counsel-gutter = 16.8pt           // cover: the gap between the two counsel columns
#let cover-gap = 10pt                  // cover: the space between its parts (FRAP 32(a)(2)(A)-(F)), a third more around the caption, two fifths more around the title (the longest sample cover fills the page)
#let counsel-columns = 2               // cover counsel groups per row (a layout choice; FRAP 32(a)(2)(F) sets only the contents)
#let toc-page-col = 36pt               // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 36pt               // TOA: the page list's column (a longer list widens its own row's column)
#let glossary-col = 1in                // glossary: the abbreviation's column
#let word-limit = 13000                // FRAP 28.1(e)(2)(A)(i) and 32(a)(7)(B)(i), applied through Circuit Rule 32(e).

#let kind-order = ("case", "constitution", "statute", "regulation", "rule", "other")
#let kind-title = (
  case: "Cases",
  constitution: "Constitutional Provisions",
  statute: "Statutes",
  regulation: "Regulations",
  rule: "Rules",
  other: "Other Authorities",
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The markdown body: cmarker output (the paragraph settings are set by the caller).
#let inl-body(md) = cmarker.render(md, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("dc-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dc-brief: the sample must start with a YAML frontmatter block") }
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

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it. A tag in front of a
/// citation that opens a line is filed under the previous line, which may be on the previous page.
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

/// Single-spaced lines (cover, signature and certificate blocks, tables).
#let single(body) = { set text(..edges(pitch-single)); body }

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); Circuit Rule 28(a)(8))
// ---------------------------------------------------------------------------

#let counsel-group(g) = block(width: 100%, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  for n in g.names { par(inl(n)) }
  for l in g.lines { par(emph(inl(l))) }
})

#let cover-body(meta) = { set text(..edges(pitch-cover)); {
  set par(first-line-indent: 0pt)
  set align(center)
  let major = cover-gap * 1.4        // around the brief's title and before the date
  let caption-gap = cover-gap * 1.12 // around the caption
  // Circuit Rule 28(a)(8): capital letters at the top of the front cover.
  par(strong(inl(upper(need(meta, "oral_argument")))))
  v(cover-gap)
  par[No. #need(meta, "case_number")]
  v(cover-gap)
  par[UNITED STATES COURT OF APPEALS]
  v(2.8pt)
  par[FOR THE DISTRICT OF COLUMBIA CIRCUIT]
  v(caption-gap)
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 {
      v(5.6pt)
      par[v.]
      v(5.6pt)
    }
    for n in side.names { par(inl(n)) }
    v(4.2pt)
    par(inl(side.designation))
  }
  v(caption-gap)
  par(inl(need(meta, "proceeding")))
  if "district_court_case" in meta { v(4.2pt); par(inl(meta.district_court_case)) }
  if "judge" in meta { v(4.2pt); par(inl(meta.judge)) }
  v(major)
  par(strong(upper(inl(need(meta, "brief_title")))))
  v(major)
  set align(left)
  for (ri, row) in need(meta, "counsel").chunks(counsel-columns).enumerate() {
    if ri > 0 { v(8.4pt) }
    grid(
      columns: (1fr,) * counsel-columns,
      column-gutter: counsel-gutter,
      ..row.map(counsel-group),
    )
  }
  if "date" in meta { v(major); par(inl(meta.date)) }
}}

/// The cover is one page; the type size never shrinks, and its spacing does not give (the latex and docx engines set
/// the same gaps).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  if measure(block(width: size.width, cover-body(meta))).height > size.height {
    panic("dc-brief: the cover does not fit on one page; shorten the counsel or party lines")
  }
  cover-body(meta)
}))
// ---------------------------------------------------------------------------
// Certificates and signature (Circuit Rule 28(a)(1); FRAP 32(g); FRAP 25(d))
// ---------------------------------------------------------------------------

/// Date at the margin, the signer in the right half (the columns of a 1fr 1fr grid with a 1 em gutter).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: 12pt, below: 0pt, single({
    set par(first-line-indent: 0pt)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 14pt,
      par(if "date" in meta { inl(meta.date) }),
      {
        par[Respectfully submitted,]
        v(7pt)
        par[/s/ #sig.signer]
        par[#sig.signer]
        v(1pt)
        for l in sig.lines { par(emph(inl(l))) }
      },
    )
  }))
}

/// "/s/ Name" and the name, under a certificate: the right 55 % of the text width.
#let cert-signature(meta) = block(width: 100%, breakable: false, above: 12pt, below: 0pt, single({
  set par(first-line-indent: 0pt)
  pad(left: 45%, {
    par[/s/ #need(meta, "signature").signer]
    par[#need(meta, "signature").signer]
  })
}))

// ---------------------------------------------------------------------------
// Tables of contents and authorities (FRAP 28(a)(2)-(3); Circuit Rule 28(a)(2): every page, no "passim")
// ---------------------------------------------------------------------------

/// One table-of-contents row (listing-row): level 1 at the margin, level 2 half an inch in; a title that wraps hangs
/// half an inch under its first line.
#let toc-entry(it) = {
  let hd = it.element
  let ind = if hd.level == 1 { 0pt } else { para-indent }
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind + para-indent, 4pt)
}

#let toc-section() = single({
  heading(level: 1, outlined: false)[TABLE OF CONTENTS]
  show outline.entry: toc-entry
  outline(title: none, depth: 2, indent: 0pt)
})

/// Sort key: case-insensitive, with runs of digits compared as numbers ("8 U.S.C." before "26 U.S.C.").
#let sort-key(s) = lower(s).replace(regex("\\d+"), m => "0" * calc.max(0, 8 - m.text.len()) + m.text)

#let authority-text(a) = {
  if a.kind == "case" { inl("*" + a.name + "*, " + a.cite) }
  else if "name" in a { inl(a.name + ", " + a.cite) }
  else { inl(a.cite) }
}

#let toa(meta) = single(context {
  set par(first-line-indent: 0pt)
  let hits = query(<toa-hit>)
  let reg = need(meta, "authorities")
  for h in hits {
    if h.value not in reg { panic("dc-brief: cited authority `" + h.value + "` is not in the authorities registry") }
  }
  let first = true
  for kind in kind-order {
    let items = reg.pairs().filter(p => p.at(1).kind == kind and hits.any(h => h.value == p.at(0)))
    if items.len() == 0 { continue }
    items = items.sorted(key: p => sort-key(p.at(1).at("sort", default: p.at(1).at("name", default: p.at(1).cite))))
    block(above: if first { 4pt } else { 16pt }, below: 2pt, sticky: true, par(strong(kind-title.at(kind))))
    first = false
    for p in items {
      // Distinct printed page labels, in document order.
      let pages = ()
      for h in hits.filter(h => h.value == p.at(0)) {
        let loc = h.location()
        let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
        if label not in pages { pages.push(label) }
      }
      let ps = pages.join(", ")
      listing-row(none, authority-text(p.at(1)), ps, calc.max(toa-page-col, measure(ps).width), 0.35in, 3pt)
    }
  }
})

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let dc-brief(meta, md) = {
  let parts = md.split(regex("(?m)^# Addendum[ \t]*$"))
  let main = parts.at(0)
  let addendum = if parts.len() > 1 { parts.at(1) } else { none }
  let words = count-words(main)
  if words > word-limit {
    panic("dc-brief: body is " + str(words) + " words; FRAP 28.1(e)(2)(A)(i) allows " + str(word-limit))
  }

  set document(title: "No. " + need(meta, "case_number") + " " + need(meta, "brief_title"))
  // The page number: centered in a single-spaced line box, at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, numbering: none, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, a section sign kept with its number, no break inside "6103(i)(2)".
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  show heading: it => {
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    if it.level == 1 {
      block(above: 24pt, below: 20pt, width: 100%, sticky: true,
        align(center, text(size: h1-size, ..edges(pitch-h1), strong(it.body))))
    } else if it.level == 2 {
      block(above: 17pt, below: 14pt, width: 100%, sticky: true,
        text(size: h2-size, ..edges(pitch-h2), strong(it.body)))
    } else {
      block(above: 12pt, below: 10pt, width: 100%, sticky: true,
        text(..edges(pitch-single), pad(left: para-indent, strong(it.body))))
    }
  }
  show quote.where(block: true): it => block(above: 10pt, below: 10pt, pad(left: para-indent, right: para-indent, single({
    set par(first-line-indent: 0pt)
    it.body
  })))
  set footnote.entry(gap: 3pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // typst's default is 0.85em; FRAP 32(a)(5) allows nothing under 14 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // Cover: no page number.
  cover(meta)

  // Front matter: lower-case roman, starting at the certificate.
  set page(numbering: "i")
  counter(page).update(1)

  // Circuit Rule 28(a)(1): the certificate comes immediately inside the cover.
  heading(level: 1)[CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE]
  let cert = need(meta, "certificate")
  let part(title, md) = {
    block(above: 11.2pt, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
    inl-body(md)
  }
  [Pursuant to Circuit Rule 28(a)(1) and Federal Rule of Appellate Procedure 26.1, the undersigned counsel certifies as follows:]
  part("A. Parties and Amici", cert.parties)
  part("B. Rulings Under Review", cert.rulings)
  part("C. Related Cases", cert.related)
  part("Rule 26.1 Disclosure", cert.disclosure)

  pagebreak()
  toc-section()

  pagebreak()
  heading(level: 1)[TABLE OF AUTHORITIES]
  toa(meta)

  if "glossary" in meta {
    pagebreak()
    heading(level: 1)[GLOSSARY]
    single({
      set par(first-line-indent: 0pt, hanging-indent: glossary-col)
      for (i, g) in meta.glossary.enumerate() {
        block(above: if i == 0 { 0pt } else { 5pt }, below: 0pt, par({ box(width: glossary-col, inl(g.abbr)); inl(g.meaning) }))
      }
    })
  }

  // Body: arabic numbers, starting at 1 on the first page of the argument.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  // The signature block never stands alone on a page: the body's last paragraph is kept together
  // with it (unless that last block is a heading or a footnote definition).
  let text-md = main.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  if tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^") {
    inl-body(text-md.slice(0, cut))
    block(breakable: false, { inl-body(tail); signature-block(meta) })
  } else {
    inl-body(text-md)
    signature-block(meta)
  }

  // Certificates (FRAP 32(g)(1), Form 6 wording; FRAP 25(d)).
  pagebreak()
  heading(level: 1)[CERTIFICATE OF COMPLIANCE]
  {
    set par(first-line-indent: 0pt)
    [This document complies with the type-volume limitations of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by the Federal Rules of Appellate Procedure and this Court's rules, this document contains #group-digits(words) words, as calculated by my word processing software.]
    block(above: 11.2pt, below: 0pt)[This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface, #int(type-size / 1pt)-point #font-family, using #need(meta, "word_processor").]
  }
  cert-signature(meta)

  pagebreak()
  heading(level: 1)[CERTIFICATE OF SERVICE]
  [I hereby certify that, on #need(meta, "date"), the foregoing document was served through the Court's ECF system on counsel for all parties.]
  cert-signature(meta)

  if addendum != none {
    pagebreak()
    inl-body(addendum)
  }
}
