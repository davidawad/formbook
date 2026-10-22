// Complaint for the U.S. District Court for the Northern District of Mississippi (msnd).
// Rules: Fed. R. Civ. P. 8(a), 10(a)-(c) (caption, numbered paragraphs), 38 (jury demand),
// 5(d)(1)(B) (no certificate of service for e-filed papers); L.U.Civ.R. 11(a) (name, address, telephone,
// fax, e-mail and bar number on signed papers). L.U.Civ.R. 5(a)(1) (civil cover sheet) and 7(c) (corporate
// disclosure) are separate filings and are not produced here. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no local rule sets a complaint typeface: the house standard, as the exemplar is set
#let type-size = 12pt                   // the memorandum rule (L.U.Civ.R. 7(b)(5)(B)) is the court's only typeface rule; used here too
#let footnote-size = 11pt               // L.U.Civ.R. 7(b)(5)(B) (footnotes 11-point or larger), applied for consistency
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (L.U.Civ.R. 7(b)(5)(A), applied for consistency)
#let page-h = 11in
#let margin = 1in                       // at least 1 inch on all four sides (L.U.Civ.R. 7(b)(5)(A))
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.4in                 // a paragraph number's box after the indent; the text follows it
#let item-indent = 0.5in                // prayer items: the number half an inch in ...
#let item-box = 0.4in                   // ... in a box of 0.4 in, the text hanging after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-inset = 12pt               // the party text stands off the caption's right rule
#let right-inset = 0.2in                // the case-number column stands off the gutter
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 10pt             // between the body and the footnote rule: where LibreOffice's separator leaves the body

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double-spaced body (L.U.Civ.R. 7(b)(5)(A); the exemplar is Word's double, 27.6 pt)
#let pitch-note = 12.65pt               // a footnote line: 1.15 x the footnote size
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line below the last party line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, designations, signature lines).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  })

/// Footnote definitions in the body ("[^key]: text" in its own chunk), keyed by the key.
#let footnote-defs(body) = {
  let defs = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// Markdown inline text, with each "[^key]" mark replaced by a typst footnote of the definition.
/// A piece that starts with a space keeps it (the markdown renderer trims it), so the word after a mark is spaced.
#let text-piece(s) = {
  let lead = if s.starts-with(regex("\\s")) { " " } else { "" }
  lead + inl(s)
}
#let with-footnotes(t, defs) = {
  let refs = t.matches(regex("\\[\\^([^\\]]+)\\]"))
  if refs.len() == 0 { return inl(t) }
  let out = []
  let pos = 0
  for r in refs {
    out += text-piece(t.slice(pos, r.start))
    out += footnote(inl(defs.at(r.captures.at(0))))
    pos = r.end
  }
  out + text-piece(t.slice(pos))
}

// ---------------------------------------------------------------------------
// Cover: court (FRCP 10(a)), caption, title of the pleading
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE NORTHERN DISTRICT OF MISSISSIPPI")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division) + " DIVISION")))
  }
}

#let caption(meta) = block(above: pitch-single, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block("CIVIL ACTION NO.:")
    line-block(inl(meta.case_number))
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, "JURY TRIAL DEMANDED")
    }
  }),
))

/// The title of the pleading: centered, bold, in a line of the body pitch, a single line below the caption.
#let title-block(meta) = block(width: 100%, above: pitch-single, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", inl(meta.title)))
})

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b)): the
/// first-line indent, the number in a box, the text after it. `last`: the paragraph before the signature, kept whole
/// and on the page of the signature (a signature never starts a page alone).
#let body-par(num, content, last: false) = {
  let p = par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-box, [#num.])#content] })
  // a paragraph straight in the flow, so that typst moves a line with its footnote to the next page (inside a
  // block it leaves the line and moves the note alone)
  if last { block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, p) } else { p }
}

/// A heading as its own sticky block (a heading never ends a page), in a line of the body pitch: level 1 centered
/// bold capitals, level 2 centered bold.
#let heading-block(lvl, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", if lvl == 1 { upper(content) } else { content }))
})

/// Signature block: "Dated" at the left; "Respectfully submitted," then "By: /s/" and the counsel lines
/// (L.U.Civ.R. 11(a)) at the right. It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #inl(meta.date)],
  {
    line-block[Respectfully submitted,]
    line-block(above: pitch-single, inl("By: /s/ " + meta.signature.signer))
    for l in meta.signature.counsel { line-block(inl(l)) }
  },
))

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph, except a paragraph that starts with "WHEREFORE", which is
/// the unnumbered lead-in of the prayer. Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15. `has-tail`: a jury demand follows, so no chunk here is the last.
#let allegations(body, defs, has-tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  let n = 0
  for (i, t) in chunks.enumerate() {
    let last = not has-tail and i == chunks.len() - 1
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      // a heading that opens with a number ("1. The ...") is a heading, not a list item: the period is escaped
      heading-block(lvl, inl(t.replace(regex("^#+[ \\t]*"), "").replace(regex("^(\\d+)([.)])"), m => m.captures.at(0) + "\\" + m.captures.at(1))))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // The prayer: the number half an inch in, in its box, the text hanging after it; double-spaced.
      pad(left: item-indent, md(t))
    } else if t.starts-with("WHEREFORE") {
      body-par(none, with-footnotes(t, defs), last: last)
    } else {
      n += 1
      body-par(n, with-footnotes(t, defs), last: last)
    }
  }
}

#let msnd-complaint(meta, body) = {
  // Page numbers centered on every page, in a single-spaced line box (Word's footer at the same place).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); prayer items as a number box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  set enum(numbering: "1.")

  // Footnotes single-spaced at 11 pt: the mark, a space, the note; the rule as long as Word's separator in
  // LibreOffice (30 % of the measure).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    [#super(num)#h(0.25em)#note.body]
  }

  court-title(meta)
  caption(meta)
  title-block(meta)

  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  let jury = "jury_demand_text" in meta
  allegations(body, footnote-defs(body), jury)

  if jury {
    heading-block(1, "JURY DEMAND")
    body-par(none, inl(meta.jury_demand_text), last: true)
  }

  signature-block(meta)
}
