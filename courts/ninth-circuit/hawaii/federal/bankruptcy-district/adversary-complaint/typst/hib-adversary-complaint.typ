// U.S. Bankruptcy Court, District of Hawaii: complaint initiating an adversary proceeding.
// Fed. R. Bankr. P. 7010 (FRCP 10 applies; the caption follows Form 416), 7008 (jurisdiction and
// consent to final orders), LBR 9004-1 (form of papers), LBR 7003-1 (cover sheet, filed separately).
//
// Rule-driven and content-agnostic. Requirement IDs (HIB-ADV-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // vendored in /fonts; the local rules name no typeface (HIB-ADV-FONT-001): the house face
#let type-size = 12pt                    // HIB-ADV-FORM-002: no local rule sets the type size of a complaint
                                         // (LBR 9004-1(b)(1) covers memoranda only); tier 2: a clerk's 12-point convention
#let margin = 1in                        // HIB-ADV-FORM-004: LBR 9004-1(b)(3): margins 1 inch from the edge
#let para-indent = 0.5in
#let quote-inset = 0.5in                 // block quotations stand in this far on both sides (Word: Block Text)
#let caption-inset = 0.2in               // the caption's text stands off the rule between its columns
#let caption-pad = 12pt                  // the bottom rule stands off the last party line
#let designation-indent = 1.8in          // a party's designation ("Plaintiff,") under its names
#let sig-column = 3.2in                  // the signature column, at the right
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt              // from the text to the footnote rule: with note-gap, the space LibreOffice keeps above its separator

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt               // HIB-ADV-FORM-003: double spacing, two single lines
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face); counsel,
                                         // caption, quotations, footnotes, signature (LBR 9004-1(b)(2))

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hib-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own) with explicit space above it; an empty string is a blank
/// single line.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  if body == "" { block(height: pitch-single) } else {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: indent, if type(body) == str { inl(body) } else { body })
  })

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption, title of the paper (HIB-ADV-FORM-001, -005)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (identification of counsel is exempt from double spacing;
/// LBR 9004-1(b)(2)).
#let counsel-block(meta) = {
  for l in need(meta, "counsel") { line-block(l) }
  if "counsel_role" in meta { line-block(emph(inl(meta.counsel_role))) }
}

/// One party: its names, then its designation.
#let caption-side(side) = {
  for n in side.names { line-block(n) }
  line-block(indent: designation-indent, side.designation)
}

/// Caption (FRBP 7010; FRCP 10(a); FRBP 9004(b)). Row 1: the bankruptcy case lines (if any), the first
/// party, and on the right the adversary number and the title of the paper. Row 2: the remaining
/// parties ("v."), with the rule closing the party column. Each row is unbreakable, so a row moves whole
/// to the next page and no cell is torn.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let bankruptcy = meta.at("bankruptcy", default: ())
  let row(left, right, last) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (1fr, 1fr),
    block(width: 100%, stroke: if last { (right: 0.75pt, bottom: 0.75pt) } else { (right: 0.75pt) },
      inset: (right: caption-inset, bottom: caption-pad), left),
    pad(left: caption-inset, right),
  ))
  let left1 = {
    for l in bankruptcy { line-block(l) }
    if bankruptcy.len() > 0 { line-block("") }
    caption-side(sides.at(0))
  }
  let right1 = {
    line-block(need(meta, "adversary_number"))
    line-block("")
    line-block(strong(upper(inl(need(meta, "paper_title")))))
  }
  row(left1, right1, sides.len() == 1)
  for (i, side) in sides.slice(1).enumerate() {
    row({
      line-block(align(center)[v.])
      line-block("")
      caption-side(side)
    }, [], i == sides.len() - 2)
  }
}

#let cover(meta) = {
  counsel-block(meta)
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, align(center, strong(upper(inl(l)))))
  }
  block(width: 100%, above: pitch-single, below: 0pt, caption-table(meta))
  line-block(above: pitch-single, align(center, strong(upper(inl(need(meta, "paper_title"))))))
}

// ---------------------------------------------------------------------------
// Signature block (HIB-ADV-FORM-010: convention; no local rule text on signatures)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
    columns: (1fr, sig-column),
    line-block("DATED: " + need(meta, "date")),
    {
      for (i, b) in blocks.enumerate() {
        if i > 0 { line-block("") }
        for l in b { line-block(l) }
      }
    },
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let running-footer = context {
  let p = counter(page).get().first()
  // The caption page carries no number (the first page is page 1, as in the filed exemplar).
  if p > 1 { align(center, text(..edges(pitch-single), numbering("1", p))) }
}

#let hib-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "counsel", "adversary_number", "paper_title", "signature", "date") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margin, footer-descent: 30%, footer: running-footer)   // LBR 9004-1(a)(2)
  set document(title: need(meta, "paper_title"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch; bulleted lists as a half-inch label box with the text hanging.
  show: xengine.with(pitch: pitch-double)
  // A doubled sign stays with its number ("§§ 157"; the docx filter binds it with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the text size, single lines, under a 30 % rule, 7 pt between notes; the mark and a space before
  // the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings: centered and bold at the body size and pitch (the filed exemplar's section and count headings), no
  // space of their own; level 1 a title in capitals. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, sticky: true,
      align(center, strong(if it.level == 1 { upper(it.body) } else { it.body })))
  }

  // Block quotations of a lease or statute: single-spaced, indented both sides, a single line off the text
  // (HIB-ADV-FORM-003).
  show quote.where(block: true): it => block(width: 100%, above: pitch-single, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-inset, it.body)
  })

  cover(meta)
  // The body; its last paragraph stays whole with the signature block. Footnote definitions are read with both
  // parts, so a mark in either finds its note.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^"))
  let text-chunks = chunks.filter(c => not c.trim().starts-with("[^"))
  let render(cs) = cmarker.render((cs + defs).join("\n\n"), raw-typst: false, smart-punctuation: true)
  block(width: 100%, above: pitch-single, below: 0pt, render(text-chunks.slice(0, -1)))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, [#render(text-chunks.slice(-1))#parbreak()])
  signature-block(meta)
}
