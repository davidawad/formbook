// Motion with supporting memorandum (or the memorandum alone) for the U.S. Bankruptcy Court, District of
// New Hampshire (nhb), filed in a bankruptcy case (a contested matter, not an adversary proceeding).
// Rules: Fed. R. Bankr. P. 9013 (a motion must state its grounds with particularity), 9004(b) (caption:
// court, title, case number and a brief designation of the document); D.N.H. LBR 7102(a) (caption shows the
// character of the paper and the party's relationship to the estate; chapter and judge's initials after the
// case number), LBR 7102(b)(2) (memorandum page limits: 15 pages nondispositive, 25 pages dispositive),
// LBR 9004-1 (BNH number after the signature), LBR 7103 (certificate of service). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; no NH rule sets a typeface (README.md, gap 1)
#let type-size = 12pt                   // no NH or federal minimum found for the body; 12 pt is the working standard
#let note-size = 10pt                   // footnotes
#let para-indent = 0.5in                // first-line indent of body paragraphs (memoranda are not numbered); quotations in by as much on both sides
#let page-margin = 1in                  // letter paper, one-inch margins (no NH rule found; common practice)
#let sig-indent = 3.25in                // the signature block: the right half of the page
#let rule = 0.5pt                       // the caption's rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // the body, double-spaced (27.6 pt, Word's double spacing at 12 pt)
#let pitch-note = 11.5pt                // a footnote line: 1.15 x the footnote size
#let note-gap = 5pt                     // between two footnotes (Word: Footnote Text's space after)
#let cap-gap = 12pt                     // between the groups of the caption and of a signature block; around a quotation
#let head-above = 6pt                   // above a section heading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold, footnote references) in text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph of its own, with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// The bankruptcy caption: the debtor, the chapter and the case number with the judge's initials (LBR 7102(a)(2),
/// (3)); two equal columns, the left one ruled at its right and foot, the right one standing off the rule.
#let bankruptcy-caption(meta) = {
  let b = meta.bankruptcy
  block(above: 18pt, below: 0pt, grid(
    columns: (1fr, 1fr),
    column-gutter: 0pt,
    block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: 10pt, bottom: 8pt, top: 2pt), {
      line-block[In re:]
      line-block(above: cap-gap, strong(inl(b.debtor)))
      line-block(above: cap-gap, align(right, inl(b.designation)))
    }),
    block(width: 100%, inset: (left: 18pt, top: 2pt), {
      line-block(inl(b.chapter))
      line-block(above: cap-gap)[Case No. #inl(b.case_number)]
    }),
  ))
}

/// A signature block, one block that never breaks: the date at the left, then the firm or party, the signer and
/// the counsel lines at the signature indent.
#let signature-block(date-label, date, intro, signer, lines) = block(breakable: false, width: 100%, above: cap-gap, below: 0pt, {
  line-block[#date-label #inl(date)]
  for (i, l) in intro.enumerate() { line-block(above: if i == 0 { cap-gap } else { 0pt }, indent: sig-indent, inl(l)) }
  line-block(above: 2 * cap-gap, indent: sig-indent, inl(signer))
  for (i, l) in lines.enumerate() { line-block(above: if i == 0 { cap-gap } else { 0pt }, indent: sig-indent, inl(l)) }
})

/// Footnotes: cmarker does not render markdown footnotes, so `[^n]` references in a paragraph become typst
/// footnotes, with the text of the `[^n]: ...` definition (`notes`, keyed by n).
#let with-footnotes(c, notes) = {
  // cmarker drops leading spaces, so a space after a marker is put back as typst content
  let seg(s) = if s.starts-with(" ") { [ ] + inl(s.slice(1)) } else { inl(s) }
  let out = []
  let pos = 0
  for m in c.matches(regex("\\[\\^([0-9]+)\\]")) {
    out += seg(c.slice(pos, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(c.slice(pos))
}

/// A heading at the body pitch, kept with what follows.
#let head(above, body) = block(sticky: true, width: 100%, above: above, below: 0pt, {
  set par(first-line-indent: 0pt)
  body
})

/// Body: `#` headings are centered bold (sections), `##` headings are bold, left, with a hanging indent (lettered
/// sub-sections), `###` headings bold italic; `>` blocks are quotations, single-spaced and indented both sides.
/// Every other chunk is an unnumbered, first-line-indented paragraph; the last one stays whole and on the page of
/// the signature block. Footnote definitions (`[^n]: ...`) are not body text; they are read into `notes`.
#let body(src, notes) = {
  let chunks = src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "" and not s.starts-with("[^"))
  let last = chunks.len() - 1
  for (i, c) in chunks.enumerate() {
    if c.starts-with("### ") {
      head(0pt, strong(emph(inl(c.slice(4)))))
    } else if c.starts-with("## ") {
      head(0pt, par(hanging-indent: para-indent, strong(inl(c.slice(3)))))
    } else if c.starts-with("# ") {
      head(head-above, align(center, strong(inl(c.slice(2)))))
    } else if c.starts-with("> ") {
      block(width: 100%, above: cap-gap, below: cap-gap, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(x: para-indent, par(with-footnotes(c.slice(2), notes)))
      })
    } else {
      block(width: 100%, above: 0pt, below: 0pt, sticky: i == last, breakable: i != last, par(with-footnotes(c, notes)))
    }
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------
#let nhb-motion-brief(meta, src) = {
  // The page number centered at the foot, in a single-spaced line box (where Word's footer sets it).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number ("§§ 329"), as the Word filter binds it (xengine binds a single one).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at 10 pt, single-spaced, the mark and a space before the note (Word's Footnote Text).
  set footnote.entry(gap: note-gap, clearance: 12.6pt, indent: 0pt, separator: line(length: 1.5in, stroke: rule))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  let notes = (:)
  for m in src.matches(regex("(?m)^\\[\\^([0-9]+)\\]: (.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }

  // court title, centered bold, one line per entry; the caption; the title
  for l in meta.court { line-block(align(center, strong(inl(l)))) }
  bankruptcy-caption(meta)
  block(width: 100%, above: 18pt, below: 12pt, line-block(align(center, strong(inl(meta.title)))))
  body(src, notes)
  let s = meta.signature
  signature-block(meta.at("date_label", default: "Date:"), meta.date, s.intro, s.signer, s.lines)
  // Certificate of service (LBR 7103): its heading kept with its text, the text at the body pitch, its own signature.
  let c = meta.at("certificate", default: none)
  if c != none {
    block(sticky: true, width: 100%, above: 2 * cap-gap, below: head-above, line-block(align(center, strong(inl(c.title)))))
    for p in c.paragraphs { block(width: 100%, above: 0pt, below: 0pt, par(inl(p))) }
    signature-block(c.at("date_label", default: "Date:"), c.date, (), c.signer, c.lines)
  }
}
