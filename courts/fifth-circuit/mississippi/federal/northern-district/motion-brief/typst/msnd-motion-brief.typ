// Memorandum brief in support of a motion (the "motion-brief" doc type) for the U.S. District Court for the
// Northern District of Mississippi (msnd). Rules: L.U.Civ.R. 7(b)(2) (the memorandum is a separate docket item),
// 7(b)(5)(A) (8 1/2 by 11 paper, double-spaced text, margins of at least 1 inch, page numbers only in the margins),
// 7(b)(5)(B) (proportional serif face; text 12-point or larger; footnotes 11-point or larger), 7(b)(5)(C) (plain roman
// type; case names italicized or underlined); L.U.Civ.R. 11(a) (signed papers carry counsel's name, address,
// telephone, fax, e-mail and bar number); Fed. R. Civ. P. 10(a) (caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.U.Civ.R. 7(b)(5)(B): a proportionally spaced face with serifs; the house standard, as the exemplar is set
#let type-size = 12pt                   // L.U.Civ.R. 7(b)(5)(B): text 12-point or larger
#let footnote-size = 11pt               // L.U.Civ.R. 7(b)(5)(B): footnotes 11-point or larger
#let page-w = 8.5in                     // L.U.Civ.R. 7(b)(5)(A): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // L.U.Civ.R. 7(b)(5)(A): at least 1 inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations: indented on both sides
#let item-indent = 0.5in                // list items: the number half an inch in ...
#let item-box = 0.4in                   // ... in a box of 0.4 in, the text hanging after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-inset = 12pt               // the party text stands off the caption's right rule
#let right-inset = 0.2in                // the case-number column stands off the gutter
#let sig-indent = 3in                   // the signing party, signer and counsel lines
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 10pt              // between the body and the footnote rule: where LibreOffice's separator leaves the body

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // L.U.Civ.R. 7(b)(5)(A): double-spaced text (the exemplar is Word's double, 27.6 pt)
#let pitch-note = 12.65pt               // a footnote line: 1.15 x the footnote size
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line below the last party line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, designations, signature lines, footnote text).
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

/// A markdown piece in running text. A piece that starts with a space keeps it (the markdown renderer
/// trims it), so the word after a footnote mark is spaced.
#let text-piece(s) = {
  let lead = if s.starts-with(regex("\\s")) { " " } else { "" }
  lead + inl(s)
}

/// Markdown inline text, with each "[^key]" mark replaced by a typst footnote of the definition.
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

/// A body paragraph at the double pitch, with the first-line indent (none after a block quotation, where the
/// paragraph goes on with the citation). Straight in the flow, so that typst moves a line with its footnote to the
/// next page. `last`: the paragraph before the signature, kept whole and with it.
#let body-par(content, indent: true, last: false) = {
  let p = par(first-line-indent: (amount: if indent { para-indent } else { 0pt }, all: true), content)
  if last { block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, p) } else { p }
}

// ---------------------------------------------------------------------------
// Cover: court (FRCP 10(a)), caption, title of the paper
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
  }),
))

/// The title of the paper: centered, bold, in a line of the body pitch, a single line below the caption.
#let title-block(meta) = block(width: 100%, above: pitch-single, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", inl(meta.title)))
})

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A heading as its own sticky block (a heading never ends a page), in a line of the body pitch: level 1 centered
/// bold capitals, level 2 bold, level 3 bold italic.
#let heading-block(lvl, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if lvl == 1 { align(center, text(weight: "bold", upper(content))) } else if lvl == 2 {
    text(weight: "bold", content)
  } else { text(weight: "bold", style: "italic", content) }
})

/// Body text: each blank-line-separated chunk that is neither a heading, a quotation, a list nor a footnote
/// definition is one paragraph, with a first-line indent. Briefs are not numbered. The last paragraph stays with
/// the signature block.
#let body-text(body, defs) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  let after-quote = false
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      // a heading that opens with a number ("1. The ...") is a heading, not a list item: the period is escaped
      heading-block(lvl, inl(t.replace(regex("^#+[ \\t]*"), "").replace(regex("^(\\d+)([.)])"), m => m.captures.at(0) + "\\" + m.captures.at(1))))
      after-quote = false
    } else if t.starts-with(">") {
      // A block quotation: single-spaced, indented on both sides, a blank single line above and below it.
      block(width: 100%, above: pitch-single, below: pitch-single, pad(left: quote-indent, right: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        inl(t.replace(regex("(?m)^>[ \\t]?"), ""))
      }))
      after-quote = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list: the number half an inch in, in its box, the text hanging after it; double-spaced.
      pad(left: item-indent, md(t))
      after-quote = false
    } else {
      body-par(with-footnotes(t, defs), indent: not after-quote, last: last)
      after-quote = false
    }
  }
}

/// Signature block: the date line at the paragraph indent; "Respectfully submitted,", then the signing party,
/// the signer and counsel (L.U.Civ.R. 11(a)) at 3 inches; then the OF COUNSEL block at the margin. It never breaks
/// across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  body-par(inl(meta.date_line))
  let sig = meta.signature
  // the space above sits on the indented group (a container drops the space above its first block)
  block(width: 100%, above: pitch-single, below: 0pt, pad(left: sig-indent, {
    line-block[Respectfully submitted,]
    line-block(above: pitch-single, inl(sig.party))
    line-block(inl(sig.signer))
    for l in sig.counsel { line-block(inl(l)) }
  }))
  for (k, l) in sig.of_counsel.enumerate() { line-block(above: if k == 0 { pitch-single } else { 0pt }, inl(l)) }
})

#let msnd-motion-brief(meta, body) = {
  // Page numbers centered on every page (L.U.Civ.R. 7(b)(5)(A): in the margin), in a single-spaced line box
  // (Word's footer at the same place).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); list items as a number box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  set enum(numbering: "1.")

  // Footnotes single-spaced at 11 pt (L.U.Civ.R. 7(b)(5)(B)): the mark, a space, the note; the rule as long as
  // Word's separator in LibreOffice (30 % of the measure).
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
  body-text(body, footnote-defs(body))
  signature-block(meta)
}
