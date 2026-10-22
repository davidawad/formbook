// Adversary complaint for the United States Bankruptcy Court, Middle District of Florida (flmb).
// Rules: Fed. R. Bankr. P. 7010 (form of adversary pleadings), 9004(b) (caption), 7008(a) (jurisdiction
// allegation, core or non-core, consent to final orders); Fed. R. Civ. P. 10(a)-(b) as applied by 7010
// (caption, numbered paragraphs); Local Rules 9004-1(a)-(c) (party designation, jury demand, injunctive
// relief in the title) and 7001-1(b) (injunctive relief); the Court's Style Guide II.A and Local Rule
// 5005-1(d) (paper, margins, font, page numbers). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Style Guide II.A asks for Times New Roman 12 point; Liberation Serif is the metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt              // Style Guide II.A: 12-point font
#let para-indent = 0.5in           // first-line indent of numbered and unnumbered paragraphs; the number's box
#let margin = 1in                  // Style Guide II.A; Local Rule 5005-1(d): one-inch margins on 8 1/2 x 11 paper
#let caption-left = 3.4in          // width of the party column of the caption
#let caption-gutter = 0.2in        // between the party column and the case-number column
#let slash-col = 0.2in             // the "/" that closes each caption rule stands in this box at the column's right
#let sig-right = 3.1in             // signature grid: "Dated" at the left, counsel in this column at the right
#let sig-gutter = 0.2in
#let table-col = 1.25in            // a body table (the transfer chart): fixed columns, centered
#let table-inset-x = 10pt
#let table-inset-y = 3pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single  // the body, double-spaced (Word's double)
#let note-gap = 7pt                // between two footnotes

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flmb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// The title as printed: capitals, with the words the Local Rules require when they apply.
#let full-title(meta) = {
  let parts = (upper(meta.title),)
  if "injunctive_relief" in meta and meta.injunctive_relief { parts.push("INJUNCTIVE RELIEF SOUGHT") } // LR 7001-1(b), 9004-1(c)
  if "jury_demand" in meta and meta.jury_demand { parts.push("DEMAND FOR JURY TRIAL") } // LR 9004-1(b)
  parts.join("; ")
}

/// Footnote definitions (`[^key]: text`), keyed by name. Each is rendered with the paragraph that cites it.
#let footnote-defs(body) = {
  let defs = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  defs
}

/// A paragraph's markdown, with the definitions of the footnotes it cites appended.
#let with-notes(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  if keys.len() == 0 { t } else {
    t + "\n\n" + keys.map(k => "[^" + k + "]: " + defs.at(k)).join("\n\n")
  }
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b), 7010; Local Rule 9004-1(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  for l in ("UNITED STATES BANKRUPTCY COURT", "MIDDLE DISTRICT OF FLORIDA", upper(meta.division) + " DIVISION") {
    line-block(align(center, strong(l)))
  }
}

/// The rule that closes a caption side: a line of its own, ruled below, with "/" at its right end.
#let slash-rule() = block(width: 100%, above: 0pt, below: 0pt, stroke: (bottom: 0.75pt),
  line-block(align(right, box(width: slash-col, align(right, [/])))))

/// One side of the caption: its names, its designation half an inch in, and the closing rule when asked.
#let side(names, designation, slash: false) = {
  for n in names { line-block(inl(n)) }
  if designation != none { line-block(indent: 0.5in, inl(designation)) }
  if slash { slash-rule() }
}

/// The caption, in four rows a single line apart: the case (In re, the debtor), the plaintiff, "v.", the defendant.
#let caption(meta) = block(above: pitch-double, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  row-gutter: pitch-single,
  { line-block[In re:]; side(meta.in_re, "Debtor.", slash: true) },
  { line-block[Case No. #meta.case_number]; line-block(inl(meta.chapter)) },
  side(meta.caption.at(0).names, meta.caption.at(0).designation),
  [],
  line-block[v.],
  line-block[#meta.at("adversary_label", default: "Adv. Case No.") #meta.adversary_number],
  side(meta.caption.at(1).names, meta.caption.at(1).designation, slash: true),
  [],
))

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a) as applied; Local Rule 9004-1)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, grid(
  columns: (1fr, sig-right),
  column-gutter: sig-gutter,
  if "date" in meta { line-block[Dated: #meta.date] } else { [] },
  {
    line-block[Respectfully submitted,]
    for (i, n) in meta.signature.firm.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(n)) }
    line-block(above: pitch-single, inl("By: /s/ " + meta.signature.signer))
    line-block(inl(meta.signature.signer))
    for n in meta.signature.lines { line-block(inl(n)) }
  },
))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); unnumbered paragraphs are marked with a leading ^
// in the sample (the reservation of rights, the prayer for relief); lists are lettered a., b., ...
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: the first line half an inch in, then (numbered) the number in a box of
/// the paragraph indent before the text.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num])#content]
  }))

/// A markdown table (the transfer chart): unruled, centered, single-spaced, fixed columns, a single line above and
/// below it.
#let body-table(t) = {
  let rows = t.split("\n").map(l => l.trim()).filter(l => l.starts-with("|"))
  let cells(l) = l.slice(1, -1).split("|").map(c => c.trim())
  let aligns = cells(rows.at(1)).map(c => if c.starts-with(":") and c.ends-with(":") { center } else if c.ends-with(":") { right } else { left })
  let data = (rows.at(0),) + rows.slice(2)
  block(width: 100%, above: pitch-single, below: pitch-single, breakable: false, align(center, table(
    columns: aligns.len() * (table-col,),
    stroke: none,
    inset: (x: table-inset-x, y: table-inset-y),
    align: (x, _) => aligns.at(x),
    ..data.map(cells).flatten().map(c => { set text(..edges(pitch-single)); set par(first-line-indent: 0pt); inl(c) }),
  )))
}

#let body-chunks(body, defs) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("|") {
      body-table(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered items: the letter half an inch in, in a half-inch box, the text hanging after it.
      pad(left: para-indent, cmarker.render(with-notes(t, defs), raw-typst: false, smart-punctuation: true))
    } else if t.starts-with("^") {
      body-par(none, inl(with-notes(t.slice(1).trim(), defs)))
    } else {
      n += 1
      body-par(n, inl(with-notes(t, defs)))
    }
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let flmb-adversary-complaint(meta, body) = {
  let defs = footnote-defs(body)

  // Page numbers centered in the footer on every page except the first (Style Guide II.A), in a single-spaced line
  // box, so the number sits at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context if counter(page).get().first() > 1 {
      align(center, text(..edges(pitch-single), counter(page).display()))
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; lettered items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set enum(numbering: "a.")
  // A doubled section sign stays with its number ("§§ 157"; the docx filter binds it with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Footnotes: 12 pt in single line boxes, under a 30 % rule, 7 pt between notes; the mark and a space before the
  // text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: pitch-single, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body size and pitch, centered and bold: level 1 in capitals, level 3 italic too. No space of
  // their own (the double pitch sets them off). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { upper(it.body) } else if it.level == 3 { emph(it.body) } else { it.body }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(b)))
  }

  court-title(meta)
  caption(meta)
  block(sticky: true, width: 100%, above: pitch-double, below: pitch-single, {
    set par(first-line-indent: 0pt)
    align(center, strong(full-title(meta)))
  })

  body-chunks(body, defs)

  signature-block(meta)
}
