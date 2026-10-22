// Memorandum of law supporting a motion in the U.S. Bankruptcy Court, E.D.N.C. (nceb), adversary proceeding.
// Rules: FRBP 9004(a) (legible), 9004(b) (caption: court, division, case and adversary numbers, designation);
// LBR 9004-2 (caption states the court, division and chapter); LBR 7007-1(a) (motion filed with a memorandum);
// FRBP 9013(b) (motion states its grounds); LBR 9011-4 (signature block: name, firm, address, phone, email, State Bar no.);
// Admin Guide Rule 5005-4(8) ("s/" signature); LBR 9013-3 (certificate of service). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no E.D.N.C. typeface rule; Times New Roman, the house standard (docs/FONTS.md), as in the exemplar
#let type-size = 12pt                   // no E.D.N.C. type-size rule (FRBP 9004(a): "clearly legible"); exemplar is 12 pt
#let margin = 1in                       // no E.D.N.C. margin rule; 1 inch as in the exemplar
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-hang = 0.5in               // a level-2 heading's lines after the first
#let caption-left = 3.4in               // the party column, ruled on its right and bottom
#let caption-gutter = 0.2in             // between the party column and the case numbers
#let caption-inset = 0.1in              // the case numbers' own inset
#let rule-pad-right = 10pt              // the party text stops this far left of the rule
#let rule-pad-bottom = 8pt              // and the rule this far below the last party's space
#let quote-inset = 1in                  // block quotations: indented 1 inch on both sides
#let quote-item = 0.25in                // a numbered item in a quotation: the number in a box of this width
#let sig-indent = 3in                   // the signature column
#let served-indent = 1in                // the certificate's list of those served

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing as in the exemplar
#let pitch-single = 13.8pt              // caption, headings, quotations, signature, certificate lists: 1.15 x 12 pt
#let gap = 12pt                         // the unit of the spaces between single-spaced blocks

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nceb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (smart punctuation: the author's characters are kept).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Body chunks: blank-line-separated blocks of the markdown body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, right: right, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption: court (centered caps), then the parties on the left and the case numbers on the right.
// FRBP 9004(b) and LBR 9004-2 require the court, the division, the case and adversary numbers, the chapter,
// and a designation of the paper; the title below states that designation.
// ---------------------------------------------------------------------------

/// A party: its names, the designation at the right, a gap after it.
#let party-block(p) = {
  for n in p.names { line-block(md(n)) }
  line-block(below: gap, align(right, md(p.designation)))
}

#let caption(meta) = {
  for l in meta.court { line-block(align(center, text(weight: "bold", upper(l)))) }
  line-block(align(center, text(weight: "bold", upper(meta.division))))
  block(width: 100%, above: 1.5 * gap, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: rule-pad-right, bottom: rule-pad-bottom), {
      line-block(below: gap / 2)[In re:]
      for p in meta.caption.in_re { party-block(p) }
      for p in meta.caption.parties { party-block(p) }
      v(gap)   // the last party's gap too (a block's last `below` is not kept)
    }),
    pad(left: caption-gutter + caption-inset, {
      // the case numbers on the lines of the first party, the adversary number on the second party's first line
      v(pitch-single + gap / 2)
      line-block[Case No. #meta.case_number]
      line-block[Chapter #meta.chapter]
      if "adversary_number" in meta { line-block(above: gap)[Adversary Proceeding No. #meta.adversary_number] }
    }),
  ))
  line-block(above: 1.5 * gap, below: gap, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(width: 100%, breakable: false, above: gap, below: 0pt, {
  if "date" in sig { line-block[Dated: #sig.date] }
  line-block(above: gap, left: sig-indent)[Respectfully submitted,]
  for s in sig.signers {
    line-block(above: gap, left: sig-indent, md(s.sign))
    for l in s.lines { line-block(left: sig-indent, md(l)) }
  }
  if "role" in sig { line-block(above: gap, left: sig-indent, text(style: "italic", sig.role)) }
})

/// The certificate of service (LBR 9013-3), on a page of its own.
#let certificate(c) = {
  pagebreak()
  line-block(align(center, text(weight: "bold", upper(c.title))))
  block(width: 100%, above: 1.5 * gap, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(c.text)))
  for (i, l) in c.served.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, left: served-indent, md(l)) }
  line-block(above: 1.5 * gap, left: sig-indent)[Dated: #c.date]
  line-block(above: gap, left: sig-indent, md(c.signer.sign))
  for l in c.signer.lines { line-block(left: sig-indent, md(l)) }
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, block quotations
// ---------------------------------------------------------------------------

/// A block quotation: single-spaced, indented on both sides, its paragraphs and numbered items a gap apart (an
/// item's number in a box, the text hanging after it).
#let quotation(c) = {
  let ps = c.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).map(s => s.trim()).filter(s => s != "")
  for (i, q) in ps.enumerate() {
    let m = q.match(regex("^(\\d+\\.)[ \\t]+"))
    let body = if m == none { md(q) } else {
      par(hanging-indent: quote-item, [#box(width: quote-item, m.captures.at(0))#md(q.slice(m.end))])
    }
    line-block(above: if i == 0 { gap / 2 } else { gap }, below: if i == ps.len() - 1 { gap } else { 0pt },
      left: quote-inset, right: quote-inset, body)
  }
}

#let body-style(body) = {
  // Level 1: centered, bold, capitals (INTRODUCTION, ARGUMENT, CONCLUSION, ...), 24 pt above and 12 below.
  // Level 2: bold at the margin, its later lines hanging (numbered argument points, e.g. "I. ..."), 12 pt above and
  // below. Single-spaced, kept with the text after them.
  show heading: it => {
    let above = if it.level == 1 { 2 * gap } else { gap }
    block(width: 100%, above: above, below: gap, sticky: true, {
      set text(size: type-size, ..edges(pitch-single))
      if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else {
        par(first-line-indent: 0pt, hanging-indent: heading-hang, text(weight: "bold", it.body))
      }
    })
  }
  for c in chunks(body) {
    if c.starts-with("#") {
      md(c)
    } else if c.starts-with(">") {
      quotation(c)
    } else {
      block(width: 100%, par(first-line-indent: (amount: para-indent, all: true), md(c)))
    }
  }
}

#let nceb-motion-brief(meta, body) = {
  set document(title: meta.title)
  // The page number centered at the foot of every page, in a single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 105(a)"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  caption(meta)
  body-style(body)
  signature-block(meta.signature)
  if "certificate" in meta { certificate(meta.certificate) }
}
