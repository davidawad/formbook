// Motion with memorandum, United States Bankruptcy Court, Western District of North Carolina.
// Rules (text read 2026-10-14; see ../README.md): Fed. R. Bankr. P. 9013 (a motion states its grounds with
// particularity and the relief requested; served on the trustee); W.D.N.C. LR 7007-1(a) (motions in an
// adversary proceeding state the facts and the relief; the memorandum follows LR 9013-2), LR 7007-1(d) and
// LR 9013-1 (a separate notice of hearing accompanies each motion), LR 9013-1(c) (a certificate of service
// with each pleading), LR 9013-2(a) (12 point minimum, double-spaced, one-inch margins, numbered pages,
// 25-page limit: not counted by the template). Caption: Fed. R. Bankr. P. 9004(b), 7010 (Official Form 416).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 9013-2(a) names no face; Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt              // LR 9013-2(a): font size a minimum of 12 point
#let margin = 1in                  // LR 9013-2(a): margins one inch on all sides
#let para-indent = 0.5in           // first-line indent of each paragraph (exemplar convention)
#let caption-left = 3.6in          // width of the party column of the caption boxes
#let box-pad = 0.12in              // the party column's text stands this far from its right and bottom rules
#let box-gutter = 0.2in            // the right column's text starts this far right of the rule
#let sig-col = 2.8in               // signature lines: the 2.6 in "Dated" column and a 0.2 in gutter
#let quote-inset = 0.5in           // block quotations are indented on both sides
#let service-indent = 0.5in        // the parties served

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt           // LR 9013-2(a): double-spaced, two 12 pt lines
#let pitch-single = 14pt           // the caption, the signature block, block quotations and the service list
#let gap = 16pt                    // between paragraphs, headings and the parts of the cover
#let quote-gap = 6pt               // around and between the paragraphs of a block quotation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, bar numbers with \*, and so on).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// Single lines, one per item; an empty item is a blank line.
#let lines(items, left: 0pt) = for i in items {
  if i == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) } else { line-block(left: left, md(i)) }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (Form 416 style: debtor box, then adversary box), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = for t in (meta.court, meta.district, meta.division) {
  line-block(align(center, text(weight: "bold", upper(t))))
}

/// The party column of a caption: each party's names, its designation, and "v." and a blank line between parties.
#let parties-rows(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows += ("v.", "") }
    rows += p.names
    rows.push(p.designation)
  }
  rows
}

/// One caption box: the party column ruled at its right and foot, the right column beside it.
#let caption-box(left-rows, right-rows, above) = block(width: 100%, above: above, below: 0pt, grid(
  columns: (caption-left, 1fr),
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: box-pad, bottom: box-pad),
    lines(left-rows)),
  pad(left: box-gutter, lines(right-rows)),
))

#let caption(meta) = {
  let d = meta.debtor
  // Box 1: the debtor, with the bankruptcy case number and chapter.
  caption-box(("In re:", "") + d.names + ("", d.designation), ("Case No. " + d.case_number, "", "Chapter " + d.chapter), gap)
  // Box 2: the parties to the adversary proceeding, with the adversary number.
  caption-box(parties-rows(meta.caption.parties), (meta.adversary.label + " " + meta.adversary.number,), gap)
}

#let title-block(t) = block(width: 100%, above: gap, below: gap, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", upper(t)))
})

// ---------------------------------------------------------------------------
// Body: paragraphs (the sample types its own paragraph numbers), headings, block quotations
// ---------------------------------------------------------------------------

#let body-par(content) = block(width: 100%, above: gap, below: gap,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A block quotation: single-spaced, indented on both sides; its markers ("(a)", "a.") printed as written.
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for q in ps { line-block(above: quote-gap, below: quote-gap, pad(x: quote-inset, md(q.trim()))) }
}

#let chunks(body) = for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
  let t = c.trim()
  if t.starts-with("#") { md(t) } else if t.starts-with(">") { quotation(t) } else { body-par(md(t)) }
}

// ---------------------------------------------------------------------------
// Signature, notice of hearing, certificate of service
// ---------------------------------------------------------------------------

/// "Dated:" in the first column and the first signature line beside it; the other lines under it.
#let signature(date, sig) = {
  block(width: 100%, above: gap, below: 0pt, {
    set text(..edges(pitch-single))
    par(first-line-indent: 0pt, hanging-indent: sig-col,
      [#box(width: sig-col)[Dated: #date]#md(sig.at(0, default: ""))])
  })
  lines(sig.slice(calc.min(1, sig.len())), left: sig-col)
}

/// The notice of hearing is a separate paper with its own caption (LR 7007-1(d)); the exemplar prints it
/// after the memorandum, on new pages, with the caption repeated.
#let notice-page(meta, body) = {
  pagebreak()
  court-title(meta)
  caption(meta)
  title-block("NOTICE OF HEARING")
  chunks(body)
  signature(meta.signature.date, meta.signature.lines)
}

/// Certificate of service (LR 9013-1(c)): the names and addresses of the parties served, the method, the date.
#let certificate(meta) = if "service" in meta and meta.service != none {
  let s = meta.service
  pagebreak()
  block(width: 100%, above: 0pt, below: gap, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  body-par([I certify that on #s.date, a copy of the #md(s.document) was served by #md(s.method), on the following:])
  lines(s.parties, left: service-indent)
  signature(s.date, s.signature)
}

// ---------------------------------------------------------------------------
// Entry: the page, the caption, the memorandum (markdown), the signature block, the notice, the certificate
// ---------------------------------------------------------------------------

#let doc(meta, body) = {
  // LR 9013-2(a): numbered pages; the number centered in a single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 4-7"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads an unmatched one as
  // opening; pandoc, the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")

  // Section headings (I., II., ...): centered, bold, capitals. Sub-headings (A., B., ...): bold, flush left;
  // level 3 bold italic. At the body pitch, a paragraph gap above and below, kept with the text after them.
  show heading: it => block(sticky: true, width: 100%, above: gap, below: gap, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(weight: "bold", style: "italic", it.body) }
  })

  court-title(meta)
  caption(meta)
  title-block(meta.title)

  // The memorandum runs up to the notice of hearing, which is a separate paper.
  let parts = body.split(regex("(?m)^# NOTICE OF HEARING[ \\t]*\\r?\\n?"))
  chunks(parts.at(0))
  signature(meta.signature.date, meta.signature.lines)
  if parts.len() > 1 { notice-page(meta, parts.at(1)) }
  certificate(meta)
}
