// Supporting memorandum (brief) for a motion under Fed. R. Civ. P. 12 in the U.S. District Court for the
// Northern District of Indiana (innd). Rules: N.D. Ind. L.R. 5-4(a) (8.5 x 11 pages, 1-inch margins, 12-point body
// and 10-point footnotes, double spacing, consecutive page numbers, a title on the first page, the filer block);
// L.R. 7-1(b) (a Rule 12 motion is filed with a supporting brief) and 7-1(e) (supporting briefs ordinarily at most
// 25 pages, excluding tables of contents, tables of authorities and appendices); Fed. R. Civ. P. 10(a) (caption:
// court, title, file number). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // no face named by L.R. 5-4(a); Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                 // L.R. 5-4(a)(4): at least 12-point type in the body
#let note-size = 10pt                 // L.R. 5-4(a)(4): at least 10-point type in footnotes
#let margin = 1in                     // L.R. 5-4(a)(3): at least 1-inch margins
#let page-w = 8.5in                   // L.R. 5-4(a)(2)
#let page-h = 11in
#let footer-distance = 0.5in          // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in              // first-line indent of body paragraphs
#let caption-left = 3.2in             // width of the party column of the caption
#let caption-gutter = 0.3in           // between the party column's rule and the right column
#let caption-pad-right = 0.12in       // the party column's text stands this far from its right rule
#let caption-pad-bottom = 0.1in       // and this far above its bottom rule
#let caption-rule = 0.75pt
#let designation-indent = 1.2in       // a party's designation ("Plaintiff,") is indented in the party column
#let quote-inset = 0.5in              // block quotations are indented on both sides
#let list-text = 1in                  // a list item's text, after its number at the 0.5 in indent
#let sig-col = 3.2in                  // signature: "Dated:" in a 3 in column and a 0.2 in gutter, the signer after it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/innd.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 27.6pt              // L.R. 5-4(a)(5): double spaced; two single lines of 12 pt type (13.8 pt each)
#let pitch-single = 13.8pt            // single spacing: court title, caption, signature blocks, quotations
#let pitch-note = 11.5pt              // footnotes: 10 pt single-spaced (L.R. 5-4(a)(4), (5))
#let para-gap = 19.8pt                // below every body paragraph and heading
#let block-gap = 27.6pt               // above a heading, around the paper title and block quotations, above the signature
#let note-gap = 7pt                   // between two footnotes
#let note-clearance = 4pt            // between the text and the footnote rule: with note-gap, the space LibreOffice keeps above the notes (measured: every break agrees from 1.5 to 7 pt)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("innd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (case names with *italics*, etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Footnote definitions (`[^n]: text` chunks) by number. cmarker drops footnotes, so they are
/// rendered by `rich()` as real typst footnotes.
#let notes-of(chunks) = {
  let notes = (:)
  for c in chunks {
    let m = c.match(regex("^\\[\\^(\\d+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  notes
}

/// A markdown segment between footnote markers. cmarker trims spaces at its edges, so a space that sits
/// next to a marker is put back as a typst space.
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// A paragraph's markdown with its `[^n]` references turned into typst footnotes.
#let rich(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    if m.start > pos { out += seg(t.slice(pos, m.start)) }
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  if pos < t.len() { out += seg(t.slice(pos)) }
  out
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it; "" is a blank line.
#let sline(above: 0pt, left: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, if type(c) == str { inl(c) } else { c }))
  })
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let cover(meta) = {
  for l in meta.court { sline(centered: true, text(weight: "bold", l)) }
  if "division" in meta { sline(centered: true, text(weight: "bold", upper(meta.division))) }
}

/// The caption: the party column ruled at its right and foot (each party's names, then its designation indented;
/// "v." between the parties); beside it the case number and the judge.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += (("", 0pt), ("v.", 0pt), ("", 0pt)) }
    for n in p.names { rows.push((n, 0pt)) }
    rows.push((p.designation, designation-indent))
  }
  let right = ("Case No. " + meta.case_number,)
  if "judge" in meta { right += ("", "Judge " + meta.judge) }
  block(width: 100%, above: block-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if x == 0 { (right: caption-pad-right, bottom: caption-pad-bottom) } else { (bottom: caption-pad-bottom) },
    for (t, ind) in rows { sline(left: ind, t) },
    [],
    for t in right { sline(t) },
  ))
}

#let paper-title(meta) = block(width: 100%, above: block-gap, below: block-gap, sticky: true,
  align(center, par(first-line-indent: 0pt, text(weight: "bold", upper(inl(meta.title))))))

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs, headings, footnotes; signature and certificate
// ---------------------------------------------------------------------------

/// Blank-line-separated markdown chunks of the body; footnote definitions are removed (see `notes-of`).
#let body-chunks(body) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  all.filter(c => not c.starts-with("[^"))
}

/// A block quotation: single-spaced, indented on both sides (L.R. 5-4(a)(5): quoted material is excepted from
/// double spacing).
#let quotation(t, notes) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for (i, q) in ps.enumerate() {
    block(width: 100%, above: if i == 0 { block-gap } else { pitch-single }, below: block-gap,
      pad(x: quote-inset, sline(rich(q.trim(), notes))))
  }
}

/// The body: each chunk is a paragraph (first-line indent), a heading or a block quotation. The last paragraph is
/// kept with the signature after it: a signature never stands alone on a page.
#let body-blocks(body, notes) = {
  let chunks = body-chunks(body)
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(">") {
      quotation(t, notes)
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      // A list: each item's number as written ("1.", a bullet as "•") at the indent, its lines hanging at 1 in.
      let marks = t.matches(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")).map(m => if m.captures.at(0).ends-with(".") { m.captures.at(0) } else { "•" })
      let items = t.split(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")).map(s => s.trim()).filter(s => s != "")
      for (k, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: para-gap, par(first-line-indent: 0pt, hanging-indent: list-text,
          [#h(para-indent)#box(width: list-text - para-indent, [#marks.at(k)])#rich(item, notes)]))
      }
    } else {
      block(width: 100%, above: 0pt, below: para-gap, sticky: i == chunks.len() - 1, par(rich(t, notes)))
    }
  }
}

/// Single lines in the column from `sig-col`; `first` goes before the first line, in the column at the left.
/// Each item is (text, space above it); "" is a blank line.
#let sig-lines(lines, first: none) = {
  set text(..edges(pitch-single))
  for (i, (l, gap)) in lines.enumerate() {
    if l == "" {
      block(width: 100%, height: pitch-single, above: gap, below: 0pt)
    } else {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 and first != none { first })#inl(l)]))
    }
  }
}

#let signature-block(meta) = {
  let sig = meta.signature
  let lines = (("Respectfully submitted,", 0pt),)
  let gap = block-gap
  if "party" in sig {
    lines.push((upper(sig.party), gap))
    gap = pitch-single
  }
  lines.push(("By: " + sig.by, gap))
  if "role" in sig { lines.push((sig.role, 0pt)) }
  for (i, c) in sig.counsel.enumerate() { lines.push((c, if i == 0 { block-gap } else { 0pt })) }
  block(breakable: false, width: 100%, above: block-gap, below: 0pt,
    sig-lines(lines, first: [Dated: #sig.dated]))
}

/// Certificate of service (Fed. R. Civ. P. 5(b)): centered title, a single paragraph, then the signer.
#let certificate-block(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, width: 100%, above: block-gap, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt,
      align(center, par(first-line-indent: 0pt, text(weight: "bold", upper(c.title)))))
    block(width: 100%, above: block-gap, below: 0pt, par(inl(c.text)))
    block(width: 100%, above: block-gap, below: 0pt,
      sig-lines(c.counsel.enumerate().map(((i, l)) => (l, 0pt))))
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let innd-motion-brief(meta, body) = {
  let all-chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let notes = notes-of(all-chunks)

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // L.R. 5-4(a)(6): consecutive page numbers, centered at the foot of every page, in a single-pitch line box
    // that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings on the body pitch, a double line above and 19.8 pt below, kept with the text after them: level 1
  // centered bold capitals (I. INTRODUCTION); level 2 bold at the margin (A. ...); level 3 bold italic.
  show heading: it => block(width: 100%, above: block-gap, below: para-gap, sticky: true, {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, upper(it.body)) }
    else if it.level == 2 { it.body }
    else { text(style: "italic", it.body) }
  })

  // Footnotes at 10 pt, single spaced (L.R. 5-4(a)(4)): the mark, a space, the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: note-gap)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  caption(meta)
  paper-title(meta)
  body-blocks(body, notes)
  signature-block(meta)
  certificate-block(meta)
}
