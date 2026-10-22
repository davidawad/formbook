// Motion with memorandum for the United States Bankruptcy Court, District of Guam (gub).
// Rules: GNLR 5.1 (8 1/2 x 11, page numbers at the bottom, double spacing except counsel, title, footnotes,
// quotations; counsel block upper left; court title at least 3 inches from the top; right-hand case
// information including the designation and a mention of the memorandum in support); Fed. R. Bankr. P. 9013
// (written motion, grounds stated with particularity), 9011(a) (signer's address and telephone), 7010 (caption).
// Local Bankruptcy Rule 9013-1(b): a motion with its memorandum is limited to 15 pages (not checked here).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // GNLR 5.1 names no face; the house standard, as the exemplar is set
#let type-size = 12pt                   // GNLR 5.1 names no size; the exemplar's 12 pt
#let footnote-size = 11pt               // footnotes are exempt from double spacing (GNLR 5.1(a)); the size is a layout choice
#let page-w = 8.5in                     // GNLR 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // all four sides (the exemplar's ECF page has 1 in margins)
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations: indented on both sides
#let head-hang = 0.5in                  // level 2 and 3 headings: the author's number, the text hanging after it
#let counsel-height = 2in               // GNLR 5.1(b): the court title starts 3 in from the top; the counsel block fills the first 2 in below the margin
#let caption-left = 3.3in               // the party column, left of the page's centre (GNLR 5.1(c)(1))
#let caption-gutter = 0.25in            // between the party column and the case information
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let caption-pad = 8pt                  // the caption's bottom rule below the last party line
#let right-inset = 0.15in               // the case information stands off the gutter
#let sig-left = 2.8in                   // the signature column (GNLR 5.1(d))
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 10pt              // between the body and the footnote rule: where LibreOffice's separator leaves the body

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // GNLR 5.1(a): double-spaced (the exemplar is Word's double, 27.6 pt)
#let pitch-note = 12.65pt               // a footnote line: 1.15 x the footnote size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gub-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line
/// keeps its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if type(body) == str { inl(body) } else { body }
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

/// A markdown piece in running text. A piece that starts with a space keeps it (the markdown renderer trims it),
/// so the word after a footnote mark is spaced.
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
// Cover: counsel (upper left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel identification, upper left (GNLR 5.1(c)(1)), single-spaced. Its height is fixed, so the court title below
/// it starts exactly 3 in from the top of the page (GNLR 5.1(b)).
#let counsel-block(meta) = block(width: 100%, height: counsel-height, above: 0pt, below: 0pt, clip: true,
  for l in meta.counsel { line-block(l) })

/// GNLR 5.1(b): the court title, centred and bold, single-spaced. Not case-specific.
#let court-title() = {
  for l in ("DISTRICT COURT OF GUAM", "TERRITORY OF GUAM", "BANKRUPTCY DIVISION") {
    line-block(align(center, text(weight: "bold", l)))
  }
}

/// The caption's party column: the lead lines, then each party with "vs." between the parties.
#let party-rows(caption) = {
  let rows = caption.lead
  for (k, p) in caption.parties.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  rows
}

/// The right-hand case information (GNLR 5.1(c)(3)): case number, chapter, the designation "Adversary
/// Proceeding", the adversary number, the title of the paper, and the memorandum in support; a single line between
/// the groups.
#let case-info(meta) = {
  line-block("Case No. " + meta.case_number)
  if "chapter" in meta { line-block(meta.chapter) }
  line-block(above: pitch-single, "Adversary Proceeding")
  line-block("Adv. Proc. No. " + meta.adversary_number)
  line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
  if "memorandum" in meta and meta.memorandum {
    line-block(above: pitch-single, text(weight: "bold", "With Memorandum in Support"))
  }
}

/// The caption a single line below the court title: the party column ruled at its right and foot (the rule as tall
/// as the row, as Word draws a cell's border), the case information beside it.
#let caption(meta) = block(width: 100%, above: pitch-single, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) },
  // the rule's width sits below every cell of the row, as LibreOffice adds a cell's bottom border to the row height
  inset: (x, y) => if x == 0 { (right: caption-inset, bottom: caption-pad) } else { (left: right-inset, bottom: 0.75pt) },
  { for r in party-rows(meta.caption) { line-block(r) } },
  case-info(meta),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A heading as its own sticky block (a heading never ends a page), in lines of the body pitch: level 1 centred bold
/// capitals; level 2 bold at the margin, level 3 bold half an inch in, the author's number first and the lines after
/// the first hanging half an inch.
#let heading-block(lvl, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if lvl == 1 { align(center, text(weight: "bold", upper(content))) } else {
    pad(left: if lvl >= 3 { head-hang } else { 0pt }, par(hanging-indent: head-hang, text(weight: "bold", content)))
  }
})

/// A block quotation: single-spaced, indented on both sides, a single line above and below it (GNLR 5.1(a) exempts
/// quotations from double spacing); its paragraphs follow each other without space.
#let block-quote(t) = block(width: 100%, above: pitch-single, below: pitch-single, pad(left: quote-indent,
  right: quote-indent, {
    let paras = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).map(s => s.trim())
      .filter(s => s != "")
    for q in paras { line-block(inl(q.replace("\n", " "))) }
  }))

/// Body text: each blank-line-separated chunk that is neither a heading, a quotation nor a footnote definition is
/// one paragraph, with a first-line indent. The last paragraph stays with the signature block.
#let body-text(body, defs) = {
  // a quotation's paragraphs are one chunk: split at blank lines unless both sides are quotation lines
  let chunks = ()
  let cur = none
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "") {
    if cur != none and cur.starts-with(">") and c.starts-with(">") { cur += "\n\n" + c } else {
      if cur != none { chunks.push(cur) }
      cur = c
    }
  }
  if cur != none { chunks.push(cur) }
  let chunks = chunks.filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  let after-quote = false
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      // a heading that opens with a number ("1. The ...") is a heading, not a list item: the period is escaped
      heading-block(lvl, inl(t.replace(regex("^#+[ \\t]*"), "").replace(regex("^(\\d+)([.)])"),
        m => m.captures.at(0) + "\\" + m.captures.at(1))))
      after-quote = false
    } else if t.starts-with(">") {
      block-quote(t)
      after-quote = true
    } else {
      body-par(with-footnotes(t, defs), indent: not after-quote, last: last)
      after-quote = false
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (GNLR 5.1(d): typed names below the signature line; Fed. R. Bankr. P. 9011(a))
// ---------------------------------------------------------------------------

/// A single line below the body, in the right column: the date line, a single line, "/s/" and the signer, the
/// signer's name and lines; never broken across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, pad(left: sig-left, {
  line-block[Respectfully submitted this #meta.date.]
  line-block(above: pitch-single, "/s/ " + meta.signature.signer)
  line-block(meta.signature.signer)
  for l in meta.signature.lines { line-block(l) }
}))

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let gub-motion-brief(meta, body) = {
  // Page numbers centred at the bottom (GNLR 5.1(a)), in a single-spaced line box (Word's footer at the same place).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

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

  cover(meta)
  // the body a double line below the caption
  v(pitch-double)
  body-text(body, footnote-defs(body))
  signature-block(meta)
}
