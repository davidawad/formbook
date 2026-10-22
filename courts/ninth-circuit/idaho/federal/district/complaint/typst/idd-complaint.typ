// Complaint for the U.S. District Court for the District of Idaho (idd).
// Rules: Dist. Idaho Loc. Civ. R. 5.2 (8 1/2 x 11, double-spaced, 1-inch margins, 12-point type including
// footers and footnotes, numbered pages, counsel block, caption four inches down, CM/ECF file number);
// Loc. Civ. R. 38.1 (jury demand notation after the title); Fed. R. Civ. P. 10(b) (numbered paragraphs).
// See ../README.md and ../../rules.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.2(a) names no face; Times New Roman is the house standard (docs/FONTS.md), Liberation Serif its vendored metric twin
#let type-size = 12pt                   // LR 5.2(a): at least 12 point, footnotes and footer included
#let margin = 1in                       // LR 5.2(a): top, bottom and side margins at least one inch
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number's box after it
#let item-indent = 0.5in                // lettered prayer items: the label at this indent
#let item-label = 0.5in                 // the label's box; the item's text hangs after it
#let caption-top = 4in                  // LR 5.2(b): caption commences four inches below the top of the first page
#let caption-left = 3.25in              // width of the party column of the caption (ruled right and below)
#let caption-pad = 10pt                 // the party text stops this far left of the caption's rule
#let caption-bottom = 8pt               // and this far above its bottom rule
#let caption-right = 0.35in             // the right column's text starts this far right of the rule
#let sig-left = 3.1in                   // the signature grid: the date column, then the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (counsel, caption, signature, footer)
#let pitch-double = 2 * pitch-single    // LR 5.2(a): double-spaced (Times New Roman 12 pt, double in Word)
#let gap = pitch-single                 // one blank single line: around the caption, inside the signature block
#let cover-gap = 12pt                   // the least space between the counsel block and the court title

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("idd-complaint: the sample must start with a YAML frontmatter block") }
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
// Cover: counsel (upper left), court title and caption (four inches down), title and jury notation
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
    // LR 5.2(b)(3): the file number as it appears in CM/ECF; (5): the title of the pleading.
    line-block(left: caption-right)[Case No. #meta.case_number]
    line-block(above: gap, left: caption-right, strong(inl(meta.brief_title)))
    if meta.at("jury_demand", default: false) == true {
      // LR 38.1: the notation goes on the front page immediately following the title.
      line-block(above: gap, left: caption-right, strong[DEMAND FOR JURY TRIAL])
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
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: gap, below: 0pt, grid(
  columns: (sig-left, 1fr),
  line-block[DATED this #inl(meta.date).],
  {
    line-block[Respectfully submitted,]
    for (i, l) in meta.signature.firm.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(l)) }
    line-block(above: gap, inl("/s/ " + meta.signature.signer))
    for l in meta.signature.lines { line-block(inl(l)) }
  },
))

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the number in a box of the
/// paragraph indent after the first-line indent, then the text).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// Prayer items (a markdown list), lettered (a), (b), ...: the label at the item indent in a box, the text hanging
/// after it.
#let lettered(t) = {
  let items = t.split(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")).filter(s => s.trim() != "")
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
      par(hanging-indent: item-label, first-line-indent: 0pt,
        [#box(width: item-label, numbering("(a)", i + 1))#inl(it.trim().replace(regex("\\s*\\n\\s*"), " "))])))
  }
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; headings and lists are unnumbered. Numbering is per chunk, not
/// with a `show par` rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let chunks(body) = {
  let n = 0
  let out = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      out.push(lettered(t))
    } else {
      n += 1
      out.push(body-par(n, inl(t)))
    }
  }
  out
}

#let idd-complaint(meta, body) = {
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
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 201"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the body pitch, on the line grid, kept with the text after them: level 1 a centered bold section
  // title in capitals; level 2 a centered bold sub-heading (the count and its title); level 3 bold, left.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
      align(center, strong(it.body))
    } else { strong(it.body) }
  })

  cover(meta)

  if "lead_in" in meta { block(width: 100%, above: gap, below: 0pt, body-par(none, inl(meta.lead_in))) }

  // The body, then the signature block. The last chunk (the jury demand) and the signature block stay on one page,
  // so a signature never stands alone at the top of a page.
  let cs = chunks(body)
  for c in cs.slice(0, -1) { c }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, { cs.last(); signature-block(meta) })
}
