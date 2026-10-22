// U.S. Bankruptcy Court, Northern District of Illinois: memorandum of law in support of a motion
// (Fed. R. Bankr. P. 9013, 9014; N.D. Ill. Bankr. L.R. 5005-2, 9013-1, 9014-1).
//
// Rule-driven and content-agnostic. Requirement IDs (ILNB-...) refer to ../README.md, which quotes the rule
// text (effective Sept. 1, 2024). No case-specific text, no coordinates measured off the exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // ILNB-FORM-002: a proportionally spaced font; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // ILNB-FORM-002: at least 12 point, footnotes included (the rule floor).
#let page-margin = 1in                   // ILNB-FORM-004: no margin less than one inch.
#let para-indent = 0.5in                 // first-line indent of body paragraphs.
#let heading-tab = 0.5in                 // a heading's label box; each deeper level starts this much further in.
#let quote-inset = 0.5in                 // block quotations, both sides.
#let caption-left = 3.4in                // width of the party column of the caption (its rules on the right and bottom).
#let caption-inset = 0.15in              // the party text stands off the column's right rule.
#let caption-rule = 0.75pt               // the caption's rules; Word adds the bottom rule's width to the caption's height.
#let caption-gutter = 0.3in              // the case column stands off the rule.
#let designation-indent = 1.4in          // "Debtor." under the debtor's name.
#let sig-column = 2.7in                  // the signature column starts this far in ("Dated" to its left).
#let max-pages = 15                      // ILNB-LIMIT-001: no memorandum may exceed 15 pages without leave of court (LBR 5005-2(D)).

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                 // ILNB-FORM-003: double spacing, Word's double line in this face at 12 pt (2 x 13.8 pt), as in the filed memorandum.
#let pitch-single = 13.8pt               // a single line, 1.15 x the type size: court lines, caption, title, headings, quotations, footnotes, signature (ILNB-FORM-003 exception, README.md).
#let gap = pitch-single                  // around headings and quotations, between the court lines and the division, the caption's groups and the signature's.
#let small-gap = gap / 2                 // between the rows of the case column and between quoted paragraphs.
#let big-gap = pitch-body                // around the caption and the title, before the signature.
#let note-gap = 7pt                      // after each footnote (Word: Footnote Text's space after).
#let note-clearance = 12.6pt             // between the text and the footnote rule (Word's separator line).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Stop with a message when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("ilnb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (a frontmatter value): smart quotes and emphasis, as pandoc reads it in the docx engine.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Headings: numbering and styles (ILNB-HEAD-001). Level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a.".
// ---------------------------------------------------------------------------

/// Printed label of a heading. The numbering function is what steps the heading counter.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 1 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 1) * heading-tab

// ---------------------------------------------------------------------------
// Court heading and caption (ILNB-CAP-001..003)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, strong[IN THE UNITED STATES BANKRUPTCY COURT]))
  line-block(below: gap, align(center, strong[FOR THE NORTHERN DISTRICT OF ILLINOIS]))
  line-block(below: big-gap, align(center, strong(upper(inl(need(meta, "division"))))))
}

/// The caption: the party column (the debtor, and the adversary parties when there are any) and the case
/// column (chapter, case number, adversary number, judge). The rule requires the case number, chapter,
/// judge and the division (ILNB-CAP-001..003).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let party(p) = {
    for n in p.names { line-block(inl(n)) }
    line-block(left: designation-indent, inl(p.designation))
  }
  let left = {
    line-block(below: gap)[In re:]
    party(cap.in_re)
    if "adversary" in cap and cap.adversary != none {
      for (k, p) in cap.adversary.parties.enumerate() {
        if k > 0 { line-block(above: gap)[v.] }
        block(above: gap, below: 0pt, party(p))
      }
    }
  }
  let rows = ()
  if "chapter" in cap { rows.push(inl(cap.chapter)) }
  rows.push[Case No. #inl(cap.case_number)]
  if "adversary" in cap and cap.adversary != none { rows.push[Adv. Pro. No. #inl(cap.adversary.number)] }
  if "judge" in cap { rows.push(inl(cap.judge)) }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: gap + caption-rule), left),
    pad(left: caption-gutter, for (i, r) in rows.enumerate() {
      line-block(below: if i < rows.len() - 1 { small-gap } else { 0pt }, r)
    }),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(above: big-gap, below: big-gap, align(center, strong(upper(inl(need(meta, "title"))))))
}

// ---------------------------------------------------------------------------
// Signature block (ILNB-SIG-001..002): signed by counsel, with the signing attorney's name, mailing
// address, email and telephone on the last page (LBR 5005-2(C)(6)). Single spaced, as in the exemplar:
// "Dated" at the margin, the signature column to its right, counsel at the margin below; kept together.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: big-gap, below: 0pt, {
    line-block[#box(width: sig-column)[Dated: #inl(sig.date)]Respectfully submitted,]
    line-block(above: gap, left: sig-column, inl(sig.party))
    line-block(above: gap, left: sig-column)[/s/ #inl(sig.signer)]
    line-block(left: sig-column, inl(sig.role))
    for (k, g) in sig.counsel.enumerate() {
      if k > 0 { line-block(above: gap)[#"- and -"] }
      block(above: gap, below: 0pt, for l in g.names + g.lines { line-block(inl(l)) })
    }
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ilnb-motion-brief(meta, md) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // ILNB-FORM-005: a centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 707"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt (ILNB-FORM-002), single-spaced (the entry sets its own leading: it does not inherit the
  // body's); the mark, a space, the note (Word's footnote layout). LibreOffice splits a note anywhere (it keeps no
  // widow or orphan line in a footnote): so does typst here.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Block quotations: indented on both sides, single spaced (ILNB-FORM-003 exception, README.md), half a line
  // between their paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: gap, below: gap, pad(x: quote-inset, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: small-gap)
    it.body
  }))

  // Headings (ILNB-HEAD-001): bold, single-spaced, a single line from the text on either side, kept with the text;
  // the label in a half-inch box at the level's indent, the text hanging after it.
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule.
  set heading(numbering: heading-num)
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    let ind = label-indent(it.level)
    block(width: 100%, above: gap, below: gap, sticky: true, {
      set text(size: type-size, ..edges(pitch-single))
      pad(left: ind, par(hanging-indent: heading-tab, first-line-indent: 0pt,
        strong[#box(width: heading-tab, lab)#it.body]))
    })
  }

  cover(meta)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  signature-block(meta)

  // The page limit (ILNB-LIMIT-001): every page of the memorandum counts. Stops the build when exceeded.
  context {
    let n = counter(page).final().first()
    assert(n <= max-pages, message: "ilnb-motion-brief: the memorandum is " + str(n) + " pages; N.D. Ill. Bankr. L.R. 5005-2(D) allows " + str(max-pages) + " without leave of court")
  }
}
