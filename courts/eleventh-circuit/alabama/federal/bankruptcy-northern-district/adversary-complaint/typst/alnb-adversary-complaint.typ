// U.S. Bankruptcy Court, N.D. Alabama: adversary complaint (Fed. R. Bankr. P. 7001, 7008, 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (ALNB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // style choice: N.D. Ala. local rules set no type size (see ../README.md)
#let note-size = 10pt                   // footnotes, as both exemplars set them
#let para-indent = 0.5in                // first-line indent of text paragraphs
#let number-width = 0.5in               // width of the paragraph-number box that follows the indent
#let designation-indent = 2.25in        // "Plaintiff," / "Debtor." lines in the caption sit this far in
#let caption-left = 3.35in              // width of the caption column that holds the party names
#let caption-mid = 0.4in                // width of the ")" column
#let sig-indent = 3.25in                // signature block starts this far in (right half of the page)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // the body, double-spaced (style choice, as both exemplars)
#let pitch-note = 11.5pt                // a footnote line: 1.15 x the footnote size
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, citations) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alnb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Designations in the caption ("Plaintiff,", "Defendants.") are indented; other caption lines are not.
#let designation-re = regex("^(Plaintiffs?|Defendants?|Debtors?|Movants?|Respondents?|Counter-?\\w*)[,.]$")

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010, Fed. R. Civ. P. 10(a); Form 416)
// ---------------------------------------------------------------------------

/// A caption block: `left` lines and `right` lines are paired row by row; the ")" column runs down
/// every row, so the block closes on the same line as the last party name.
#let caption-block(blk, above) = {
  let left = blk.at("left", default: ())
  let right = blk.at("right", default: ())
  let cells = ()
  for i in range(calc.max(left.len(), right.len())) {
    let l = if i < left.len() { left.at(i) } else { "" }
    let r = if i < right.len() { right.at(i) } else { "" }
    cells += (
      line-block(indent: if l.match(designation-re) != none { designation-indent } else { 0pt }, inl(l)),
      line-block(align(center, [)])),
      line-block(inl(r)),
    )
  }
  block(above: above, below: 0pt, grid(columns: (caption-left, caption-mid, 1fr), ..cells))
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011(a): name, address and telephone of the signer)
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  line-block[Dated: #inl(sig.date)]
  line-block(above: pitch-single, indent: sig-indent)[Respectfully submitted,]
  for (i, s) in sig.signers.enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, indent: sig-indent,
      if i == 0 [/s/ #inl(s)] else { inl(s) })
  }
  for group in (sig.firm, sig.address, sig.contact, sig.role) {
    for (i, l) in group.enumerate() {
      line-block(above: if i == 0 { pitch-single } else { 0pt }, indent: sig-indent, inl(l))
    }
  }
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let alnb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"))
  // Page numbers centered on every page; the number in a single-spaced line box, so it sits at the same place on
  // every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled section sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds a single one).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at 10 pt, single-spaced, the mark and a space before the note (Word's Footnote Text).
  set footnote.entry(gap: note-gap, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Court title, centered, one line per entry (Fed. R. Bankr. P. 9004(b): caption).
  for l in need(meta, "court") { line-block(align(center, upper(inl(l)))) }

  // Caption: debtor block, then the adversary proceeding block.
  for (i, blk) in need(meta, "caption").enumerate() {
    caption-block(blk, if i == 0 { pitch-double } else { pitch-single })
  }

  // Title of the paper, centered and bold.
  block(width: 100%, above: pitch-double, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", upper(inl(need(meta, "title")))))
  })

  // A body paragraph at the double pitch with the first-line indent; numbered: the number in a box after it.
  let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
    par(if num == none { content } else [#box(width: number-width)[#num.]#content]))

  // Body. Blocks are separated by blank lines. "#" blocks are headings; "[^n]:" blocks are footnote
  // definitions and attach to the paragraph before them; "WHEREFORE" paragraphs are prayers, not
  // numbered allegations. Every other block is a numbered allegation (Fed. R. Civ. P. 10(b)).
  let blocks = body.split("\n\n").map(s => s.trim()).filter(s => s != "")
  let grouped = blocks.fold((), (acc, b) => if b.starts-with("[^") and acc.len() > 0 {
    acc.slice(0, -1) + (acc.last() + "\n\n" + b,)
  } else {
    acc + (b,)
  })

  // Lead-in: the sentence that opens the complaint, not numbered.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  // Consent statement (Fed. R. Bankr. P. 7008(a)): the first numbered allegation.
  let n = 0
  if "consent" in meta {
    n += 1
    body-par(n, inl(meta.consent))
  }

  for b in grouped {
    if b.starts-with("#") {
      // Headings: centered and bold, single-spaced, a single line above and below; never at the foot of a page.
      let lvl = b.match(regex("^#+")).text.len()
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        align(center, text(weight: "bold", inl(b.slice(lvl).trim())))
      })
    } else if b.starts-with("WHEREFORE") {
      body-par(none, inl(b))
    } else {
      n += 1
      body-par(n, inl(b))
    }
  }

  // Signature block, after the prayer.
  signature-block(need(meta, "signature"))
}
