// Adversary complaint, United States Bankruptcy Court, Western District of North Carolina.
// Rules (text read 2026-10-14; see ../README.md): Fed. R. Bankr. P. 7001 (what is an adversary
// proceeding), 7008(a) (jurisdiction allegation, core statement, consent to final orders), 7010 (caption
// substantially conforms to Official Form 416), 9004(a)-(b) (legible; caption: court, title, case and
// adversary numbers, designation). W.D.N.C. LR 7003-1: the Adversary Proceeding Cover Sheet (Form B 1040)
// accompanies the complaint as a separate filing; it is not generated here.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no face named in the local rules; Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt              // no bankruptcy-court type rule for complaints; 12 pt is the LR 9013-2(a) floor for briefs
#let margin = 1in                  // LR 9013-2(a): one inch on all sides (stated for briefs; applied to the complaint too)
#let para-indent = 0.5in           // first-line indent of each paragraph (exemplar convention)
#let caption-left = 3.6in          // width of the party column of the caption boxes
#let box-pad = 0.12in              // the party column's text stands this far from its right and bottom rules
#let box-gutter = 0.2in            // the right column's text starts this far right of the rule
#let sig-col = 2.8in               // signature lines: the 2.6 in "Dated" column and a 0.2 in gutter
#let quote-inset = 0.5in           // block quotations are indented on both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt           // double spacing (the exemplar; LR 9013-2(a) for briefs), two 12 pt lines
#let pitch-single = 14pt           // the caption, the signature block and block quotations
#let gap = 16pt                    // between paragraphs, headings and the parts of the cover
#let quote-gap = 6pt               // around and between the paragraphs of a block quotation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
  caption-box(parties-rows(meta.caption.parties), ("Adv. Proc. No. " + meta.adversary.number,), gap)
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
// Signature
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

// ---------------------------------------------------------------------------
// Entry: the page, the caption, the body (markdown) and the signature block
// ---------------------------------------------------------------------------

#let doc(meta, body) = {
  // Numbered pages (LR 9013-2(a) for briefs); the number centered in a single-spaced line box, where Word's footer sets it.
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
  // A doubled sign stays with its number too ("§§ 2201"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads an unmatched one as
  // opening; pandoc, the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")

  // Section and count headings centered, bold, capitals (level 1); level 2 centered bold; level 3 bold at the
  // margin. At the body pitch, a paragraph gap above and below, kept with the text after them.
  show heading: it => block(sticky: true, width: 100%, above: gap, below: gap, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", it.body) }
  })

  court-title(meta)
  caption(meta)
  title-block(meta.title)

  chunks(body)
  signature(meta.signature.date, meta.signature.lines)
}
