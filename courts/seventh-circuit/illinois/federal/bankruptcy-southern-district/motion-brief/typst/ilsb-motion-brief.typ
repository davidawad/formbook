// U.S. Bankruptcy Court, Southern District of Illinois: brief in support of a motion (S.D. Ill. L.R. 9013-5).
//
// The brief is a separate document from the motion (L.R. 9013-1(A), 9013-5(D)). Rule-driven and
// content-agnostic. Requirement IDs (ILSB-...) refer to ../README.md, which quotes the rule text. No
// case-specific text, no coordinates measured off an exemplar, no forced line breaks. The body is markdown
// rendered by cmarker; the caption, counsel and certificate data come from the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // No S.D. Ill. rule names a typeface (ILSB-FORM-002 gap); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                   // Style choice. No S.D. Ill. type-size rule. Footnotes too (as filed).
#let footer-size = 10pt                 // Page number only; not body text.
#let page-margin = 1in                  // ILSB-FORM-001 (L.R. 5005-2): 8 1/2 by 11 inch paper; 1 in margins (style choice).
#let para-indent = 0.5in                // First-line indent of every body paragraph.
#let quote-indent = 0.5in               // A block quotation, both sides.
#let list-indent = 0.5in                // A bullet's box at the margin; the item's text hangs after it.
#let caption-left = 3.6in               // Width of the party column of the caption.
#let caption-inset = 10pt               // The party text stands off the caption's right rule; the bottom rule stands this far below it.
#let caption-rule = 0.75pt              // The caption's rules; Word adds the bottom rule's width to the caption's height.
#let case-inset = 0.35in                // The case information stands this far right of the party column.
#let sig-column = 3in                   // The signature's right-hand column starts this far in.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // Double spacing for the body (convention, not a rule), as filed.
#let pitch-single = 13.8pt              // A single line: Word's single line in this face at 12 pt (1.15 x the type size).
#let pitch-footer = 12pt                // The 10 pt page-number line.
#let gap = pitch-body / 2               // Around headings and block quotations, in the signature.
#let note-gap = 7pt                     // After each footnote (Word: Footnote Text's space after).
#let note-clearance = 6.8pt             // Between the text and the footnote rule: with note-gap, the 13.8 pt single line of Word's separator.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, *Id.*), as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// Lines of the frontmatter, one single-spaced paragraph each; an empty line is a single line of space before the
/// next one.
#let line-list(items, left: 0pt, above: 0pt) = {
  let skip = above
  for i in items {
    if i == none or i == "" { skip = calc.max(skip, pitch-single) } else {
      line-block(above: skip, left: left, inl(i))
      skip = 0pt
    }
  }
}

/// A body paragraph: the body pitch, the first-line indent, no space of its own (double spacing runs on).
#let body-par(body) = block(width: 100%, above: 0pt, below: 0pt, par(body))

// ---------------------------------------------------------------------------
// Caption (the same form as the adversary complaint: court, debtor and chapter, parties, adversary number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF ILLINOIS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

#let caption(meta) = {
  // Left: the debtor (In re), then the parties to the adversary proceeding, "v." between the sides, a single line
  // of space between the groups.
  let left = {
    line-block[In re:]
    for d in meta.debtors { line-block(inl(d)) }
    line-block(inl(meta.debtor_designation))
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: pitch-single)[v.] }
      for (j, n) in p.names.enumerate() { line-block(above: if j == 0 { pitch-single } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }
  // Right: the bankruptcy case number and chapter (L.R. 5005-1(B)(2)), then the adversary number.
  let adv = if meta.adversary_no != none and meta.adversary_no != "" { inl(meta.adversary_no) } else { "_" * 10 }
  let right = {
    line-block[Case No. #inl(meta.bankruptcy_case_no)]
    line-block[Chapter #inl(meta.chapter)]
    line-block(above: gap)[Adversary No. #adv]
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: caption-inset + caption-rule), left),
    pad(left: case-inset, right),
  ))
}

// ---------------------------------------------------------------------------
// Signature, attorney block and certificate of service
// (L.R. 9011(A) attorney block; L.R. 9013-2 certificate of service; Electronic Filing Rules, Rule 5)
// ---------------------------------------------------------------------------

/// "Dated" at the margin and "Respectfully submitted," in the right-hand column on the same line; the party, the
/// signer and the attorney block in that column (as filed; L.R. 9011(A)). Kept together.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block[#box(width: sig-column)[Dated: #inl(meta.date)]Respectfully submitted,]
    line-list(sig.party, left: sig-column, above: gap)
    line-list(("/s/ " + sig.signer, sig.signer, sig.signer_title), left: sig-column, above: gap)
    line-list(sig.attorney, left: sig-column, above: pitch-body)
  })
}

#let certificate-of-service(meta) = {
  // L.R. 9013-2(A): a paper filed under Rule 9013 or 9014 must comply with Rule 7005(d), and L.R. 9013-2(B)
  // lets the court strike a paper without it. The statement and the list of recipients are the author's.
  pagebreak()
  line-block(below: pitch-body, align(center, strong("CERTIFICATE OF SERVICE")))
  body-par(inl(meta.service.statement))
  line-list(meta.service.parties, above: pitch-body)
  line-list(meta.service.signature, above: gap)
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ilsb-motion-brief(meta, body) = {
  // "Page x of y", centered, in a 12 pt line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-footer),
      [Page #counter(page).get().first() of #counter(page).final().first()])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; a bullet in a box at the margin, the text hanging after it.
  show: xengine.with(pitch: pitch-body, list-indent: list-indent)
  // A doubled sign stays with its number ("§§ 2313"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt, single-spaced (the entry sets its own leading: it does not inherit the body's); the mark, a
  // space, the note (Word's footnote layout). LibreOffice splits a note anywhere (it keeps no widow or orphan line
  // in a footnote): so does typst here.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Headings, as the author types them (no numbers are generated): single-spaced and bold, half a body line from the
  // text on either side, kept with the text after them; level 1 centered capitals, level 2 centered, level 3 at the
  // margin.
  show heading: it => block(width: 100%, above: gap, below: gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) }
    else if it.level == 2 { align(center, strong(it.body)) }
    else { strong(it.body) }
  })

  // Block quotations: single-spaced, indented on both sides, half a body line around them and between their
  // paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: gap, below: gap, pad(x: quote-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: gap)
    it.body
  }))

  court-title(meta)
  caption(meta)
  line-block(above: pitch-body, below: pitch-body, align(center, strong(upper(meta.title))))

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)

  if "service" in meta and meta.service != none {
    certificate-of-service(meta)
  }
}
