// Complaint for the U.S. District Court for the Northern District of Indiana (innd).
// Rules: N.D. Ind. L.R. 5-4(a) (8.5 x 11 pages, 1-inch margins, 12-point body and 10-point footnotes, double
// spacing, consecutive page numbers, a title on the first page, the filer block); Fed. R. Civ. P. 10(a)
// (caption: court, title, file number) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // no N.D. Ind. face rule; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                 // L.R. 5-4(a)(4): at least 12-point type in the body
#let note-size = 10pt                 // L.R. 5-4(a)(4): at least 10-point type in footnotes
#let margin = 1in                     // L.R. 5-4(a)(3): at least 1-inch margins
#let page-w = 8.5in                   // L.R. 5-4(a)(2)
#let page-h = 11in
#let footer-distance = 0.5in          // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in              // first-line indent of numbered paragraphs; a paragraph number starts here
#let number-box = 0.5in               // a paragraph number (or prayer letter) in a box after the indent: the text starts 1 in from the margin
#let list-label = 0.5in               // a list item's letter at the 0.5 in indent, in a 0.5 in box; its lines hang at 1 in
#let caption-left = 3.2in             // width of the party column of the caption
#let caption-gutter = 0.3in           // between the party column's rule and the right column
#let caption-pad-right = 0.12in       // the party column's text stands this far from its right rule
#let caption-pad-bottom = 0.1in       // and this far above its bottom rule
#let caption-rule = 0.75pt
#let designation-indent = 1.2in       // a party's designation ("Plaintiff,") is indented in the party column
#let quote-inset = 0.5in              // block quotations are indented 0.5 in on both sides
#let sig-col = 3.2in                  // signature: "Dated:" in a 3 in column and a 0.2 in gutter, the signature lines after it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/innd.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 27.6pt              // L.R. 5-4(a)(5): double spaced; two single lines of 12 pt type
#let pitch-single = 13.8pt            // single spacing: court title, caption, block quotations, signature
#let pitch-note = 11.5pt              // footnotes: 10 pt type, single spaced (L.R. 5-4(a)(4), (5))
#let para-gap = 19.8pt                // below every body paragraph, list item and heading (the template's 1.645 em)
#let cover-gap = 27.6pt               // court title to caption, caption to title, title to the body
#let heading-above = 27.6pt           // above a heading
#let quote-gap = 27.6pt               // above and below a block quotation
#let sig-above = 27.6pt               // the last paragraph to the signature block
#let sig-gap = 27.6pt                 // "Respectfully submitted," to the party, the role to the counsel lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("innd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (case names with *italics*, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let inl(s) = unloose(md(s))

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
  let lines = meta.court
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { sline(centered: true, text(weight: "bold", l)) }
}

/// The party column: each party's names, then its designation (indented); "v." between the parties.
#let party-lines(parties) = {
  for (k, p) in parties.enumerate() {
    if k > 0 { sline(""); sline("v."); sline("") }
    for n in p.names { sline(n) }
    sline(left: designation-indent, p.designation)
  }
}

#let caption(meta) = block(width: 100%, above: cover-gap, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
  inset: (x, y) => if x == 0 { (right: caption-pad-right, bottom: caption-pad-bottom) } else { (bottom: caption-pad-bottom) },
  party-lines(meta.caption.parties),
  [],
  {
    sline("Case No.: " + meta.case_number)
    if "jury_demand" in meta and meta.jury_demand {
      sline(above: pitch-single, text(weight: "bold", "JURY TRIAL DEMANDED"))
    }
  },
))

#let paper-title(meta) = block(width: 100%, above: cover-gap, below: cover-gap, sline(centered: true,
  text(weight: "bold", upper(meta.title))))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), lettered subparagraphs, headings
// ---------------------------------------------------------------------------

/// Blank-line-separated markdown chunks of the body; footnote definitions are removed (see `notes-of`).
#let body-chunks(body) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  all.filter(c => not c.starts-with("[^"))
}

/// A body paragraph on the body pitch, para-gap below it; `label` in a box after the indent.
#let body-par(c, label: none, last: false) = block(width: 100%, above: 0pt, below: para-gap,
  breakable: not last, sticky: last,
  par(first-line-indent: (amount: para-indent, all: true),
    if label == none { c } else [#box(width: number-box, label)#c]))

/// The body. Each chunk that is neither a heading nor a list is one numbered paragraph; numbers are
/// counted here in code, so the sample never carries them. Two markers keep a paragraph unnumbered:
/// a leading "^ " (lead-in, jury demand), and a capital letter and period ("A. ") for prayer items,
/// which keep their letter. The last chunk is kept whole with the signature block after it (docx: keep
/// lines, keep with next): a signature never stands alone on a page.
#let body-blocks(body, notes) = {
  let num = 0
  let chunks = body-chunks(body)
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list: each item lettered (a., b., ...) at the indent, its lines hanging at 1 in, para-gap below; it may
      // break across pages.
      let items = t.split(regex("(?m)^(?:\\d+\\.|[-*+])[ \\t]+")).map(s => s.trim()).filter(s => s != "")
      for (k, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: para-gap, par(first-line-indent: 0pt,
          hanging-indent: para-indent + list-label,
          [#h(para-indent)#box(width: list-label, numbering("a.", k + 1))#rich(item, notes)]))
      }
    } else if t.starts-with(">") {
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      block(width: 100%, above: quote-gap, below: quote-gap, pad(x: quote-inset, sline(rich(q, notes))))
    } else if t.starts-with("^ ") {
      body-par(rich(t.slice(2), notes), last: last)
    } else if t.starts-with(regex("^[A-Z]\\.[ \\t]")) {
      let m = t.match(regex("^([A-Z])\\.[ \\t]+([\\s\\S]*)$"))
      body-par(rich(m.captures.at(1), notes), label: m.captures.at(0) + ".", last: last)
    } else {
      num += 1
      body-par(rich(t, notes), label: str(num) + ".", last: last)
    }
  }
}

/// The signature block, single-spaced and kept on one page: "Dated:" at the left of the first line, the signature
/// lines in a column from `sig-col` (docx: a tab and a hanging indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = (("Respectfully submitted,", 0pt),)
  let gap = sig-gap
  if "party" in sig { lines.push((upper(sig.party), gap)); gap = pitch-single }
  lines.push(("By: " + sig.by, gap))
  if "role" in sig { lines.push((sig.role, 0pt)) }
  for (k, c) in sig.counsel.enumerate() { lines.push((c, if k == 0 { sig-gap } else { 0pt })) }
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, g)) in lines.enumerate() {
      block(width: 100%, above: g, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [Dated: #sig.dated])#inl(l)]))
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let innd-complaint(meta, body) = {
  let all-chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let notes = notes-of(all-chunks)

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // L.R. 5-4(a): consecutive page numbers, centered at the foot from page 1, in a single-pitch line box that
    // ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("§§ 1332"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the type size on the body pitch, kept with the text after them: level 1 centered bold capitals;
  // level 2 centered bold (COUNT I); level 3 bold at the margin (sub-section).
  show heading: it => block(width: 100%, above: heading-above, below: para-gap, sticky: true, {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, upper(it.body)) }
    else if it.level == 2 { align(center, it.body) }
    else { it.body }
  })

  // Footnotes at 10 pt, single spaced (L.R. 5-4(a)(4)), in line boxes of pitch-note, no space between them.
  set footnote.entry(gap: 0pt)
  show footnote.entry: set text(size: note-size, ..edges(pitch-note))
  show footnote.entry: set par(first-line-indent: 0pt, hanging-indent: 0pt)

  cover(meta)
  caption(meta)
  paper-title(meta)
  body-blocks(body, notes)
  signature-block(meta)
}
