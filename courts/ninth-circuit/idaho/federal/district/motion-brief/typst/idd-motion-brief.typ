// Memorandum in support of a motion for the U.S. District Court for the District of Idaho (idd).
// Rules: Dist. Idaho Loc. Civ. R. 7.1(a)(2) (memorandum at most 20 pages; no small fonts or minimal spacing to
// comply with the limit), 7.1(a)(3) (the motion's docket number in the caption), 7.1(b)(1) (a separate brief);
// Loc. Civ. R. 5.2 (8 1/2 x 11, double-spaced, 1-inch margins, 12-point type including footers and footnotes,
// numbered pages, counsel block, caption four inches down, CM/ECF file number). See ../README.md and ../../rules.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.2(a) and 7.1(a)(2) name no face; Times New Roman is the house standard (docs/FONTS.md), Liberation Serif its vendored metric twin
#let type-size = 12pt                   // LR 5.2(a): at least 12 point, footnotes and footer included
#let margin = 1in                       // LR 5.2(a): top, bottom and side margins at least one inch
#let para-indent = 0.5in                // first-line indent of body paragraphs; the hanging indent of a level-3 heading
#let item-indent = 0.5in                // bulleted items: the bullet at this indent
#let item-label = 0.5in                 // the bullet's box; the item's text hangs after it
#let caption-top = 4in                  // LR 5.2(b): caption commences four inches below the top of the first page
#let caption-left = 3.25in              // width of the party column of the caption (ruled right and below)
#let caption-pad = 10pt                 // the party text stops this far left of the caption's rule
#let caption-bottom = 8pt               // and this far above its bottom rule
#let caption-right = 0.35in             // the right column's text starts this far right of the rule
#let sig-left = 3.1in                   // the signature grid: the date column, then the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (counsel, caption, signature, footer, footnotes)
#let pitch-double = 2 * pitch-single    // LR 5.2(a): double-spaced (Times New Roman 12 pt, double in Word)
#let gap = pitch-single                 // one blank single line: around the caption, inside the signature block
#let cover-gap = 12pt                   // the least space between the counsel block and the court title
#let note-gap = 7pt                     // between two footnotes
#let note-clearance = 3.5pt             // from the last text line to the separator: with note-gap, the 10.5 pt LibreOffice keeps between the text and the first note

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("idd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, right: right, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number and paper title, each page (LR 5.2(a): each page numbered consecutively; 12 point).
#let footer-block(title) = context {
  set text(size: type-size, ..edges(pitch-single))
  align(left, [#counter(page).display() - #upper(inl(title))])
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title and caption (four inches down), title with the motion's docket number
// ---------------------------------------------------------------------------

#let counsel-block(meta) = for l in meta.counsel {
  // An empty item is a blank single line (between counsel groups).
  if l.trim() == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) } else { line-block(inl(l)) }
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
  pad(right: caption-pad, bottom: caption-bottom, {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  {
    // LR 5.2(b)(3): the file number as it appears in CM/ECF; (5): the title of the paper.
    line-block(left: caption-right)[Case No. #meta.case_number]
    line-block(above: gap, left: caption-right, strong(inl(meta.brief_title)))
    if meta.at("motion_docket", default: none) != none {
      // LR 7.1(a)(3): a paper filed in support of a motion carries that motion's docket number in the caption.
      line-block(above: gap, left: caption-right, strong("[" + meta.motion_docket + "]"))
    }
  },
)

/// LR 5.2(b): the caption starts four inches below the top of the page; counsel that needs more room pushes it
/// down ("except where additional space is required for identification"), at least `cover-gap` below the counsel.
#let cover(meta) = {
  block(width: 100%, above: 0pt, below: 0pt, context {
    let c = counsel-block(meta)
    let used = measure(width: page.width - 2 * margin, c).height
    block(width: 100%, height: calc.max(caption-top - margin, used + cover-gap), above: 0pt, below: 0pt, c)
  })
  for l in meta.caption.court { line-block(align(center, strong(inl(l)))) }
  block(width: 100%, above: gap, below: 0pt, caption(meta))
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

/// The signature grid: `left` beside the lines of the signature column, one block that never breaks.
#let sig-grid(left, lines) = block(width: 100%, breakable: false, above: gap, below: 0pt, grid(
  columns: (sig-left, 1fr),
  left,
  for l in lines { line-block(above: l.at(0), inl(l.at(1))) },
))

#let signature-block(meta) = sig-grid(
  line-block[Dated: #inl(meta.date)],
  ((0pt, "Respectfully submitted,"),)
    + meta.signature.firm.enumerate().map(((i, l)) => (if i == 0 { gap } else { 0pt }, l))
    + ((gap, "/s/ " + meta.signature.signer),)
    + meta.signature.lines.map(l => (0pt, l)),
)

/// A level-1 heading's look (bold centered capitals on the body pitch), for the certificate's title too.
#let head-1(body) = align(center, strong(upper(body)))

/// A body paragraph at the double pitch, first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Certificate of service: its own page (convention; LR 5.2 is silent), signed by the filer.
#let certificate-block(meta) = {
  pagebreak(weak: true)
  block(width: 100%, sticky: true, above: 0pt, below: 0pt, head-1[Certificate of Service])
  body-par(inl(meta.certificate.text))
  sig-grid([], ((0pt, "/s/ " + meta.certificate.signer),) + meta.certificate.lines.map(l => (0pt, l)))
}

/// Markdown to content, with its `[^n]` references turned into typst footnotes (the definitions are `[^n]: text`
/// chunks, collected by `body-text`). The mark stands against the word before it (no space, as Word's filter sets it);
/// a space after the mark is kept.
#let with-notes(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    let key = m.captures.at(0)
    assert(key in notes, message: "idd-motion-brief: footnote [^" + key + "] has no definition in the sample")
    out += inl(t.slice(pos, m.start).trim(at: end))
    out += footnote(md(notes.at(key)))
    pos = m.end
  }
  let rest = t.slice(pos)
  if pos > 0 and rest.starts-with(regex("\\s")) { out += [ ] }
  out + inl(rest.trim(at: start))
}

/// The items of a markdown bullet list; a line without a bullet continues the item before it.
#let bullet-items(t) = {
  let items = ()
  for line in t.split("\n") {
    let l = line.trim()
    if l.starts-with(regex("^[-*+][ \t]")) {
      items.push(l.slice(2).trim())
    } else if l != "" and items.len() > 0 {
      items.at(items.len() - 1) = items.at(items.len() - 1) + " " + l
    }
  }
  items
}

/// Body paragraphs are not numbered (a memorandum, not a pleading). Each blank-line-separated chunk of markdown is
/// one paragraph unless it is a heading, a list, a section break or a footnote definition.
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions, keyed by their number; they are placed where their reference is.
  let notes = (:)
  for c in chunks {
    let m = c.trim().match(regex("^\\[\\^(\\d+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  for c in chunks {
    let t = c.trim()
    if t.match(regex("^\\[\\^(\\d+)\\]:")) != none {
      continue
    } else if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^[-*+][ \t]")) {
      // Bulleted items, each a paragraph of its own at the body pitch (no pad or block around it: typst would set
      // its footnote where the item starts): the bullet at the item indent in a box, the text hanging after it.
      for i in bullet-items(t) {
        par(hanging-indent: item-indent + item-label, first-line-indent: (amount: item-indent, all: true),
          [#box(width: item-label)[•]#with-notes(i, notes)])
      }
    } else if t == "\\* \\* \\*" {
      // A section break, centered on its own line.
      block(width: 100%, above: 0pt, below: 0pt, align(center, [\* \* \*]))
    } else {
      body-par(with-notes(t, notes))
    }
  }
}

#let idd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title),
    footer-descent: 30%,
  )
  set document(title: meta.brief_title)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none, footnote-widows: false)
  // A doubled sign stays with its number too ("§§ 7501"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // Footnotes (LR 5.2(a)): 12 point, single-spaced; the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body pitch, on the line grid, kept with the text after them: level 1 a centered bold section
  // title in capitals; level 2 a centered bold sub-heading; level 3 an argument heading, bold, hanging.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { head-1(it.body) } else if it.level == 2 { align(center, strong(it.body)) } else {
      par(hanging-indent: para-indent, strong(it.body))
    }
  })

  cover(meta)
  block(width: 100%, above: gap, below: 0pt, [])

  body-text(body)

  signature-block(meta)

  if meta.at("certificate", default: none) != none { certificate-block(meta) }
}
