// Adversary complaint for the United States Bankruptcy Court, D. Massachusetts (mab).
// Rules (see ../README.md): Fed. R. Bankr. P. 7001, 7003 and MLBR 7003-1 (cover sheet, attached by the filer),
// 7008(a) (consent statement), 7010 (caption conforms to Form 416D; Fed. R. Civ. P. 10(a)), Fed. R. Civ. P. 10(b)
// (numbered paragraphs), MLBR Appendix 8 (paper, margins, double spacing, 12-point body, 10-point footnotes, numbering).
// Content-agnostic: every case word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md (fonts/); Appendix 8(c) asks for a plain roman type
#let type-size = 12pt                   // Appendix 8(c): not less than 12-point for the body
#let footnote-size = 10pt               // Appendix 8(c): not less than 10-point for footnotes
#let margin = 1in                       // Appendix 8(a): at least one inch on all four sides (8.5 x 11-inch paper)
#let para-indent = 0.5in                // first-line indent of paragraphs; the allegation number's box
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case column
#let caption-right-inset = 0.1in        // the adversary number stands off the rule
#let caption-pad-right = 10pt           // the party text stands off the rule at its right
#let caption-pad-bottom = 8pt           // and above the rule below it (the rule then takes its own width below, as Word draws it)
#let rule = 0.75pt
#let sig-indent = 3.1in                 // the signature groups, as in the filed complaint
#let table-col = 1.5in                  // a body table (the transfer schedule): fixed columns, centered
#let table-inset-x = 8pt
#let table-inset-y = 2pt
// Level-1 headings after which paragraphs are not numbered (the certificate and the service list are not allegations).
#let unnumbered-sections = ("CERTIFICATE OF SERVICE", "SERVICE LIST")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // Appendix 8(a): double-spaced (twice the 12-point size)
#let pitch-single = 13.8pt              // a single line (caption, signature; Appendix 8(a) exceptions): 1.15 x the type size
#let pitch-note = 11.5pt                // a footnote line: 1.15 x the footnote size
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let gap = pitch-single                 // a blank single line between the parts of the caption
#let sig-gap = pitch-single / 2         // between the groups of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mab-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// Footnote definitions (`[^key]: text`), keyed by name. Each is rendered with the paragraph that cites it.
#let footnote-defs(body) = {
  let defs = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  defs
}

/// A chunk's markdown, with the definitions of the footnotes it cites appended.
#let with-notes(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  if keys.len() == 0 { t } else {
    t + "\n\n" + keys.map(k => "[^" + k + "]: " + defs.at(k)).join("\n\n")
  }
}

// ---------------------------------------------------------------------------
// Cover: court (Form 416D), caption, title of the paper
// ---------------------------------------------------------------------------

#let caption(meta) = {
  for l in ("UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF MASSACHUSETTS", upper(meta.division)) {
    line-block(align(center, strong(l)))
  }
  // Debtor (left) and case identification (right): "In re:", then the debtor and its designation.
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    {
      line-block[In re:]
      for (i, n) in meta.debtor_names.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(n)) }
      line-block(inl(meta.debtor_designation))
    },
    [],
    {
      line-block[CHAPTER #meta.chapter]
      line-block(above: gap)[CASE NO. #meta.case_number]
    },
  ))
  // Adversary parties (left, bounded on the right and bottom) and the adversary number (right).
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: caption-pad-right, bottom: caption-pad-bottom + rule), {
      for n in meta.plaintiffs.names { line-block(inl(n)) }
      line-block(inl(meta.plaintiffs.designation))
      line-block(above: gap)[v.]
      for (i, n) in meta.defendants.names.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(n)) }
      line-block(inl(meta.defendants.designation))
    }),
    [],
    line-block(indent: caption-right-inset,
      if meta.adv_number == "" [ADV. PROC. NO. \_\_\_\_\_\_\_\_\_\_\_\_] else [Adv. Proc. No. #meta.adv_number]),
  ))
  block(sticky: true, width: 100%, above: pitch-double, below: pitch-single,
    line-block(align(center, strong(inl(meta.title)))))
}

// ---------------------------------------------------------------------------
// Signature: groups of lines at the signature indent, half a line between groups, then the date at the margin
// (Appendix 8(a): counsel identification single-spaced). One block that never breaks across a page.
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  for (k, g) in meta.signature.enumerate() {
    for (i, l) in g.enumerate() {
      line-block(above: if i == 0 and k > 0 { sig-gap } else { 0pt }, indent: sig-indent, inl(l))
    }
  }
  line-block(above: pitch-single)[Date: #meta.date]
})

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)); headings; tables; lists.
// Each blank-line-separated chunk of markdown is one unit: a heading, a table, a list, a paragraph, or a footnote
// definition (rendered with the paragraph that cites it).
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: the first line half an inch in, then (numbered) the number in a box of
/// the paragraph indent before the text.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))

/// A markdown table (the transfer schedule): unruled, centered, single-spaced, fixed columns, a single line above
/// and below it.
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

/// A heading at the body size and pitch: level 1 centered bold capitals, level 2 centered bold. Sticky: a heading
/// never ends a page.
#let body-heading(level, content) = block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt)
  align(center, strong(if level == 1 { upper(content) } else { content }))
})

#let allegations(body, meta) = {
  let defs = footnote-defs(body)
  let n = 0
  let numbered = false                  // the lead-in before the first heading is not numbered
  let signed = false
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      let title = t.slice(lvl).trim()
      if lvl == 1 {
        if upper(title) == "CERTIFICATE OF SERVICE" and not signed {
          signature-block(meta)
          signed = true
        }
        numbered = not (upper(title) in unnumbered-sections)
      }
      body-heading(lvl, inl(title))
    } else if t.starts-with("|") {
      body-table(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // List items: the label half an inch in, in a half-inch box, the text hanging after it.
      pad(left: para-indent, cmarker.render(with-notes(t, defs), raw-typst: false, smart-punctuation: true))
    } else if numbered and not t.starts-with("WHEREFORE") {
      // "WHEREFORE" paragraphs are the prayer: not numbered.
      n += 1
      body-par(n, inl(with-notes(t, defs)))
    } else {
      body-par(none, inl(with-notes(t, defs)))
    }
  }
  if not signed { signature-block(meta) }
}

#let mab-adversary-complaint(meta, body) = {
  // FRBP 7008(a): the complaint must state whether the pleader does or does not consent to final orders or judgment.
  assert(body.contains("consent to the entry of final orders"),
    message: "mab-adversary-complaint: FRBP 7008(a) requires a statement of consent to the entry of final orders or judgment by the bankruptcy court")

  set document(title: meta.title)
  // Appendix 8(b): every page is numbered, the first need not be. The number centered in a single-spaced line box,
  // so it sits at the same place on every page (Word's footer).
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
  // the body pitch (double-spaced); list labels in a half-inch box, the text hanging after it.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set enum(numbering: "a.")
  // A doubled section sign stays with its number ("§§ 547"), as the Word filter binds it (xengine binds a single one).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at 10 pt, single-spaced, the mark and a space before the note (Word's Footnote Text), kept whole.
  set footnote.entry(gap: note-gap, clearance: 12.6pt, indent: 0pt, separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  caption(meta)
  allegations(body, meta)
}
