// Complaint for the United States District Court for the Western District of Tennessee (tnwd).
// Rules: W.D. Tenn. LR 7.1(a)-(d) (paper, margins, double spacing, 12 point type, the JURY DEMAND legend),
// LR 3.1 (civil cover sheet: a separate filing, not generated); LR 11.1(b) (signature block);
// Fed. R. Civ. P. 7(a), 8(a), 10(a)-(c) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file. No
// coordinates measured off the exemplar, no forced line breaks.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // the W.D. Tenn. CM/ECF manual allows Times New Roman (README.md, typeface row); vendored in /fonts
#let type-size = 12pt                  // LR 7.1(b): no smaller than 12 point, footnotes included
#let margin = 1in                      // LR 7.1(a): one-inch margins on all sides, 8 1/2 by 11 inch paper
#let para-indent = 0.5in               // first-line indent; a paragraph's number stands in a box this wide after it (Fed. R. Civ. P. 10(b))
#let item-indent = 0.5in               // prayer items: the letter stands half an inch in ...
#let item-label = 0.5in                // ... in a box this wide; the text hangs after it
#let caption-left = 3.3in              // the party column of the caption
#let caption-marks = 0.4in             // the column of ")" marks
#let caption-right = 0.1in             // the case number and JURY DEMAND stand this far right of the marks
#let designation-indent = 1.25in       // "Plaintiffs," / "Defendant." under the party names
#let blank-width = 1.6in               // the case number's blank before the clerk assigns one
#let sig-indent = 3.25in               // signature block and verification signatures from the middle of the page
#let sig-rule = 2.75in                 // a verification's signature line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt               // LR 7.1(b): double-spaced; Word's double line at 12 pt (2 x 1.15 x 12 pt)
#let pitch-single = 13.8pt             // single spacing (LR 7.1(b) allows it for quotations, headings, footnotes): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                // a blank single line: caption rows, around headings, between signature groups
#let head-below = 6.9pt                // under a heading: half a single line
#let quote-gap = 6.9pt                 // around a block quotation
#let note-gap = 7pt                    // between footnotes
#let note-clearance = 12.6pt           // between the text and the footnote rule (the room LibreOffice keeps above a note)
#let sign-room = 2 * pitch-body        // room to sign a verification above its line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italic case names, footnote marks).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// A paragraph at the body pitch; `last` keeps it whole and with the signature block after it.
#let body-par(above: 0pt, last: false, content) = block(width: 100%, above: above, below: 0pt, sticky: last,
  breakable: not last, par(first-line-indent: 0pt, hanging-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a); LR 7.1(c))
// ---------------------------------------------------------------------------

/// The court title, single-spaced, centered (the first page of a W.D. Tenn. filing), a blank double line below.
#let court-title(division) = {
  line-block(align(center)[IN THE UNITED STATES DISTRICT COURT])
  line-block(align(center)[FOR THE WESTERN DISTRICT OF TENNESSEE])
  if division != none and division != "" { line-block(align(center, inl(division))) }
}

/// The caption: one row per party line (names, the designation, a blank line, "v.", a blank line, ...), a column of
/// ")" marks (one per line of text: a name can wrap), the case number opposite the first designation and the
/// JURY DEMAND legend opposite "v." (LR 7.1(c): "immediately opposite the style of the case").
#let caption(sides, case-number, jury) = {
  let rows = ()   // (content or none, indent, kind)
  for (i, side) in sides.enumerate() {
    for n in side.names { rows.push((inl(n), 0pt, "name")) }
    rows.push((inl(side.designation), designation-indent, if i == 0 { "first" } else { "designation" }))
    if i < sides.len() - 1 {
      rows.push((none, 0pt, "blank"))
      rows.push(([v.], 0pt, "v"))
      rows.push((none, 0pt, "blank"))
    }
  }
  let cells = ()
  for (c, ind, kind) in rows {
    let text-cell = if c == none { line-block[] } else { line-block(left: ind, c) }
    let marks = context {
      let n = if c == none { 1 } else { calc.max(1, int(calc.round(measure(width: caption-left, text-cell).height / pitch-single))) }
      for _ in range(n) { line-block(align(center)[)]) }
    }
    let right = if kind == "first" {
      line-block(left: caption-right, if case-number != "" [Case No. #case-number] else [Case No. #box(width: blank-width, height: 0.6em, stroke: (bottom: 0.5pt))])
    } else if kind == "v" and jury {
      line-block(left: caption-right)[JURY DEMAND]
    } else { [] }
    cells += (text-cell, marks, right)
  }
  grid(columns: (caption-left, caption-marks, 1fr), ..cells)
}

// ---------------------------------------------------------------------------
// Body blocks
// ---------------------------------------------------------------------------

/// A heading, single-spaced (LR 7.1(b)), a blank single line above and half a line below, kept with what follows:
/// level 1 centered bold; level 2 bold at the left (the author types the letter); level 3 bold italic at the left.
#let heading-block(level, s) = line-block(above: gap, below: head-below, sticky: true,
  if level == 1 { align(center, strong(inl(s))) } else if level == 2 { strong(inl(s)) } else { strong(emph(inl(s))) })

/// A block quotation: single-spaced, half an inch in on both sides.
#let quote-block(t) = block(width: 100%, above: quote-gap, below: quote-gap, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: para-indent, right: para-indent,
    inl(t.split("\n").map(l => l.trim().replace(regex("^>\\s?"), "")).join("\n")))
})

/// The prayer for relief: "1." items lettered (a), (b), ... by the template; the letter in a half-inch box half an
/// inch in, the text hanging after it, double-spaced.
#let list-block(t, last) = {
  let items = t.split("\n").map(l => l.trim()).filter(l => l != "")
  for (i, it) in items.enumerate() {
    let m = it.match(regex("^\\d+\\.\\s+(.*)$"))
    assert(m != none, message: "tnwd-complaint: a list item must start with a number and a period")
    let letter = "abcdefghijklmnopqrstuvwxyz".at(i)
    let is-last = last and i == items.len() - 1
    block(width: 100%, above: 0pt, below: 0pt, sticky: is-last, breakable: not is-last,
      par(hanging-indent: item-indent + item-label, first-line-indent: 0pt,
        [#h(item-indent)#box(width: item-label)[(#letter)]#inl(m.captures.at(0))]))
  }
}

// ---------------------------------------------------------------------------
// Signature and verification
// ---------------------------------------------------------------------------

/// The signature block (LR 11.1(b)): "s/" and the filing user's name, the attorney bar number, the firm, street
/// address, city, state and ZIP, telephone and primary e-mail, in that order; "Dated:" at the margin, the rest from
/// the middle of the page, a blank single line between the groups. Kept on one page.
#let signature-block(sig, date) = block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
  let s(above: 0pt, body) = line-block(above: above, left: sig-indent, body)
  if date != none and date != "" { line-block[Dated: #date] }
  s(above: if date != none and date != "" { gap } else { 0pt })[Respectfully submitted,]
  s(above: gap)[s/ #inl(sig.signer)]
  s[Attorney Bar No. #sig.bar_number]
  if sig.at("firm", default: none) != none { s(inl(sig.firm)) }
  for l in sig.lines { s(inl(l)) }
})

/// A verification (28 U.S.C. § 1746), one per verifying party, kept whole: the heading, the declaration
/// double-spaced, room to sign, the signature line, the name and the date. The first starts a page.
#let verifications-block(list) = {
  pagebreak(weak: true)
  for (i, ver) in list.enumerate() {
    block(width: 100%, breakable: false, above: if i == 0 { 0pt } else { pitch-body }, below: 0pt, {
      line-block(below: gap, align(center, strong[VERIFICATION]))
      body-par[#h(para-indent)I, #inl(ver.name), declare under penalty of perjury that the foregoing is true and correct.]
      // the signature line: a line box of its own with no text, the rule just under its baseline (Word: an
      // underlined tab)
      block(above: sign-room, below: 0pt, height: pitch-single, width: 100%,
        place(top + left, dx: sig-indent, dy: 0.8 * pitch-single + 1pt, line(length: sig-rule, stroke: 0.5pt)))
      line-block(left: sig-indent, inl(ver.name))
      if ver.at("executed", default: none) != none { line-block(left: sig-indent)[Executed on: #ver.executed] }
    })
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let tnwd-complaint(meta, body) = {
  set document(title: meta.at("title", default: "Complaint"))
  // LR 7.1(a): letter paper, one-inch margins; the page number centered in the bottom margin, in a single-spaced
  // line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // A web address breaks only after its "://" and after a "/", ".", "-", "_", "?", "=", "&" or "#" inside it (not
  // after one that follows another): each piece in a box, the line may break between them. Left alone, typst also
  // splits a long address inside a word, which no other engine does. The docx filter marks the same places with a
  // zero-width space.
  show regex("[A-Za-z]+://\\S+"): it => {
    let s = it.text
    let head = s.match(regex("^[A-Za-z]+://"))
    let pieces = (head.text,)
    let cur = ""
    let cs = s.slice(head.end).clusters()
    let skip = false
    for (i, ch) in cs.enumerate() {
      cur += ch
      if not skip and ch in ("/", ".", "-", "_", "?", "=", "&", "#") and i < cs.len() - 1 {
        // the piece ends with the character after the separator's (Lua's gsub "(sep)(.)" consumes it)
        skip = true
      } else if skip {
        skip = false
        pieces.push(cur.slice(0, cur.len() - ch.len()))
        cur = ch
      }
    }
    pieces.push(cur)
    pieces.filter(p => p != "").map(p => box(p)).join()
  }

  // Footnotes: 12 pt (LR 7.1(b)), single-spaced (the entry sets its own leading: it does not inherit the body's);
  // the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // LibreOffice splits a note anywhere (it keeps no widow or orphan line in a footnote): so does typst here.
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  court-title(meta.at("court_division", default: none))
  block(above: pitch-body, below: 0pt,
    caption(meta.caption, meta.at("case_number", default: ""), meta.at("jury_demand", default: false)))
  line-block(above: pitch-body, below: pitch-body, sticky: true, align(center, strong(inl(meta.title))))

  // The body: blank-line-separated chunks; a chunk that cites a footnote carries the footnote definitions with it.
  // Paragraphs before the first heading are the lead-in (unnumbered), and so is any paragraph that starts "~ " (the
  // WHEREFORE paragraph, the jury demand sentence); every other paragraph is numbered (Fed. R. Civ. P. 10(b)).
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  let chunks = chunks.filter(c => not c.starts-with("[^"))
  let with-notes(s) = if defs != none and s.contains("[^") { s + "\n\n" + defs } else { s }
  let first = chunks.position(c => c.starts-with("#"))
  let n = 0
  for (k, c) in chunks.enumerate() {
    // the last block stays with the signature block, so the signature never stands alone on a page
    let last = k == chunks.len() - 1
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      heading-block(level, c.replace(regex("^#+\\s*"), ""))
    } else if c.starts-with(">") {
      quote-block(c)
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      list-block(c, last)
    } else if c.starts-with("~ ") {
      body-par(last: last)[#h(para-indent)#inl(with-notes(c.slice(2)))]
    } else if first == none or k < first {
      body-par(last: last)[#h(para-indent)#inl(with-notes(c))]
    } else {
      n += 1
      body-par(last: last)[#h(para-indent)#box(width: para-indent)[#n.]#inl(with-notes(c))]
    }
  }

  signature-block(meta.signature, meta.at("date", default: none))
  if "verifications" in meta { verifications-block(meta.verifications) }
}
