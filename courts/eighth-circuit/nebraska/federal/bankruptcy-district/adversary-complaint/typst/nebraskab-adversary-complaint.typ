// Adversary complaint for the United States Bankruptcy Court, District of Nebraska (nebraskab).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008 (pleading: jurisdiction, core/non-core,
// consent to final orders), 7010 (caption substantially conforms to Official Form 416), 9004(a)-(b)
// (legible; caption: court, title, case and adversary numbers, designation), 9011(a) (signer's address
// and telephone number); Fed. R. Civ. P. 10(b) (numbered paragraphs, as applied by 7010). Local Rules
// (2026 text): LR 1015-1(B) (captions of jointly administered cases), LR 9011-1 (signatures). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no Nebraska font rule; Times New Roman, the exemplars' face, vendored in fonts/
#let type-size = 12pt                   // legible (FRBP 9004(a)); no rule sets a size; 12 pt, the exemplars' body size
#let footnote-size = 11pt               // footnotes: not body text; no rule sets a size
#let margin = 1in                       // no Nebraska margin rule; 1 inch on every side (conventional)
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it (text at 1 in)
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-indent = 0.5in             // "v." in the party column
#let designation-indent = 1in           // "Plaintiff," / "Defendant." in the party column
#let letter-box = 0.4in                 // the "(a)" label of a prayer item, after the paragraph indent

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double spacing: the exemplar's body lines are 27.6 pt apart
#let pitch-note = 12.65pt               // a single line of an 11 pt footnote (1.15 x)

// Court name (Official Form 416 caption, FRBP 9004(b)(1)). Constant for this court; not case-specific.
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nebraskab-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown rendered as inline content (names, lines, the title): italics and smart quotes, no paragraphs.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A markdown chunk rendered as body text. h1-level 1 keeps the heading levels the sample uses.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Footnote definitions `[^key]: text`, collected from the body (one per line).
#let footnote-defs(body) = {
  let defs = (:)
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// An empty single-spaced line (a blank row of the caption).
#let blank-line = block(width: 100%, height: pitch-single, above: 0pt, below: 0pt)

// ---------------------------------------------------------------------------
// Cover: court name, caption, title (Official Form 416; FRBP 9004(b))
// ---------------------------------------------------------------------------

/// The caption, one grid row per entry: the party column, a gutter, the case-number column. Above the rule the
/// "In re:" block with the chapter and case lines; under the rule the parties with "v." between them, the adversary
/// line at the first party's designation. The rule is the bottom edge of the last party-column cell above it.
#let caption(meta) = {
  let left-a = ("In re:",) + meta.in_re
  let right-a = ("", meta.chapter) + meta.case_lines
  let n = calc.max(left-a.len(), right-a.len() + 0)
  // rows: (left text, right text, left indent, rule under the left cell)
  let rows = range(n).map(i => (left-a.at(i, default: ""), right-a.at(i, default: ""), 0pt, i == n - 1))
  rows.push(("", "", 0pt, false))
  for (k, p) in meta.parties.enumerate() {
    if k > 0 {
      rows.push(("", "", 0pt, false))
      rows.push(("v.", "", caption-indent, false))
      rows.push(("", "", 0pt, false))
    }
    for nm in p.names { rows.push((nm, "", 0pt, false)) }
    rows.push(("", "", 0pt, false))
    rows.push((p.designation, if k == 0 { meta.adversary_line } else { "" }, designation-indent, false))
  }
  let cell(s, indent) = if s == "" { blank-line } else { line-block(indent: indent, inl(s)) }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    ..rows.map(((l, r, ind, rule)) => (
      grid.cell(stroke: if rule { (bottom: 0.5pt) } else { none }, cell(l, ind)),
      blank-line,
      cell(r, 0pt),
    )).flatten(),
  ))
}

#let cover(meta) = {
  for (i, l) in court-name.enumerate() { line-block(align(center, text(weight: "bold", l))) }
  caption(meta)
  // the title: bold capitals, single spaced, a blank double line above it and a single line below it
  line-block(above: pitch-double, below: pitch-single, align(center, text(weight: "bold", inl(upper(meta.title)))))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, lettered prayer items
// ---------------------------------------------------------------------------

/// A heading: one centered bold line at the body pitch (level 1 in capitals), kept with the text after it.
#let heading-block(level, text-md) = block(width: 100%, sticky: true, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", inl(if level == 1 { upper(text-md) } else { text-md })))
})

/// A body paragraph at the double pitch, first-line indented; a numbered one (Fed. R. Civ. P. 10(b)) has its number
/// in a box of the paragraph indent after the indent.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))

/// Lettered items (a), (b), ... for the prayer: the label after the paragraph indent, the text hanging after it.
#let lettered(items) = {
  let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p")
  for (k, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
      par(first-line-indent: 0pt, hanging-indent: letter-box, [#box(width: letter-box, [(#letters.at(k))])#inl(it)])))
  }
}

/// Body text. Each blank-line-separated chunk is one block. Numbering: allegations are numbered from
/// the first heading to the prayer; the intro paragraph and the prayer are unnumbered (Fed. R. Civ. P. 10(b)).
#let body-chunks(body, notes) = {
  let numbering-on = false
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") {
      // footnote definitions are attached to the chunk that cites them (see below)
      continue
    }
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \t]+(.*)$"))
      let level = m.captures.at(0).len()
      let title = m.captures.at(1)
      if level == 1 and upper(title) == "PRAYER FOR RELIEF" {
        numbering-on = false
      } else if not numbering-on and level == 1 {
        numbering-on = true
      }
      heading-block(level, title)
    } else if t.starts-with(regex("^[-*+][ \t]")) {
      let items = t.split("\n").filter(l => l.trim().starts-with(regex("^[-*+][ \t]"))).map(l => l.trim().slice(2))
      lettered(items)
    } else {
      // cite-and-define: the footnote definitions this chunk uses are rendered with it
      let extra = ""
      for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
        let key = m.captures.at(0)
        extra += "\n\n[^" + key + "]: " + notes.at(key)
      }
      let content = md(t + extra)
      if numbering-on {
        n += 1
        body-par(n, content)
      } else {
        body-par(none, content)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (FRBP 9011(a): signer's address and telephone number; LR 9011-1: /s/ signature)
// ---------------------------------------------------------------------------

/// "Dated" at the left; "Respectfully submitted," and each signer's lines at the right, a blank line between them.
/// One unbreakable block, a double line below the text.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  line-block[Dated: #inl(meta.date)],
  [],
  {
    line-block[Respectfully submitted,]
    for b in meta.signature {
      for (j, l) in b.enumerate() { line-block(above: if j == 0 { pitch-single } else { 0pt }, inl(l)) }
    }
  },
))

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nebraskab-complaint(meta, body) = {
  // FRBP 7008(a): the complaint must state whether the pleader does or does not consent to final orders.
  assert(body.find("consent to the entry of final orders") != none, message: "nebraskab-adversary-complaint: the complaint must state consent to the entry of final orders (FRBP 7008(a))")
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced), footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // "§§ 547" stays whole: the shared rule binds the last sign to the number, and a line could otherwise end
  // between the two signs (Word never breaks there).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes: 11 pt, single spaced; the footnote area costs what LibreOffice gives it, so a note moves to the
  // next page in both engines alike.
  set footnote.entry(gap: 7pt, clearance: 9pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // a note is never split across pages (Word keeps its lines together)
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  cover(meta)
  body-chunks(body, footnote-defs(body))
  signature-block(meta)
}
