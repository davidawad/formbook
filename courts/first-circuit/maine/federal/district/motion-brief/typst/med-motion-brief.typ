// Motion to dismiss with incorporated memorandum of law, for the United States District Court for the
// District of Maine (med). Rules: D. Me. Local Rule 7(a) (every motion incorporates a memorandum of law),
// 7(d)(1) (20-page limit for a memorandum supporting a motion to dismiss), 10(a) (caption and title), 10(b)
// (form: 12-point or larger type, footnotes 10-point or larger; text double-spaced; 8 1/2 x 11 inch paper; page
// numbers at the bottom; 1-inch margins). Fed. R. Civ. P. 7(b), 10(a), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no face named by D. Me. LR 10(b)(1), so docs/FONTS.md "No face named": Times New Roman substitute (README.md)
#let type-size = 12pt                   // LR 10(b)(1): 12-point or larger; 12 pt, as the filed exemplars (README.md)
#let footnote-size = 11pt               // LR 10(b)(1): footnotes 10-point or larger
#let margin = 1in                       // LR 10(b)(5): 1-inch margins on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs; the hanging indent of headings
#let quote-indent = 0.5in               // block quotations, indented on both sides
#let caption-left = 3.4in               // width of the party block of the caption
#let caption-gap = 0.3in                // between the party block's rule and the case number column
#let caption-pad = 12pt                 // inside the party block: its text stops this far from the rule at its right
#let caption-foot = 8pt                 // and its last line stands this far above the rule at its foot
#let case-indent = 0.1in                // the case number column's text, in from the column
#let rule-w = 1.6in                     // the blank for the clerk when the case number is not yet known
#let designation-indent = 1.5in         // "Defendants." set in from the party names
#let date-w = 3.0in                     // signature: the date at the margin, the signer's lines from 3 inches

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt              // LR 10(b)(2): double-spaced (Word double spacing for 12 pt Times; the filed exemplars measure 27.6 pt)
#let pitch-single = 13.8pt              // caption, title, headings, block quotes, signature: single-spaced, 1.15 x the type size
#let pitch-note = 12.65pt               // a footnote line (LR 10(b)(2): footnotes may be single-spaced): 1.15 x the footnote size
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 12.6pt            // body to the first note: with note-gap, Word's separator paragraph

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("med-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (names, paragraphs, headings, footnotes; smart quotes).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 10(a); FRCP 10(a))
// ---------------------------------------------------------------------------

/// The court's name, two centered bold lines (LR 10(a): the caption names the court).
#let court-title() = for l in ("UNITED STATES DISTRICT COURT", "DISTRICT OF MAINE") {
  line-block(align(center, text(weight: "bold", l)))
}

/// The party column (each party's names, then its designation set in from the names; "v." between parties),
/// closed by a rule at its right and bottom; the case number (or a blank for the clerk) at right, in the middle
/// rows of the party column (counted by entries: a name that wraps counts as one).
#let caption(meta) = {
  let rows = meta.caption.parties.map(p => p.names.len() + 1).sum() + meta.caption.parties.len() - 1
  let skip = calc.max(0, calc.floor((rows - if meta.case_number == "" { 2 } else { 1 }) / 2))
  let party = {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for n in p.names { line-block(md(n)) }
      line-block(indent: designation-indent, md(p.designation))
    }
  }
  let case = {
    line-block[Civil Action No.#if meta.case_number != "" [ #meta.case_number]]
    // With no case number yet, a blank is left for the clerk to fill in.
    if meta.case_number == "" {
      line-block(box(width: rule-w, height: 0.8 * pitch-single, stroke: (bottom: 0.6pt), outset: (bottom: 1.5pt)))
    }
  }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-foot),
      party),
    pad(left: caption-gap + case-indent, top: skip * pitch-single, case),
  ))
}

/// The title of the motion in bold capitals, single-spaced, under the caption (LR 10(a)).
#let title-block(meta) = line-block(above: pitch-double, align(center, text(weight: "bold", upper(md(meta.title)))))

// ---------------------------------------------------------------------------
// Signature, certificate, body
// ---------------------------------------------------------------------------

/// Signature block: the date at the margin, the signing attorney's /s/ line beside it at 3 inches, the lines of the
/// block under it; a double line off the text.
#let signature-lines(meta) = {
  line-block(above: pitch-double, [#box(width: date-w)[Dated: #meta.date]/s/ #meta.signature.signer])
  for l in meta.signature.lines { line-block(indent: date-w, md(l)) }
}

/// A body paragraph at the double pitch, its first line indented half an inch. One that carries a footnote mark may
/// leave a single line at the foot or the head of a page (`notes: true`), as the Word style for it ("Body Text Note",
/// no widow control) does.
#let body-par(content, notes: false) = block(width: 100%, above: 0pt, below: 0pt, {
  set text(costs: (widow: 0%, orphan: 0%)) if notes
  par(first-line-indent: (amount: para-indent, all: true), content)
})

/// Walk the markdown body. Blank lines separate chunks. `#` headings are styled by show rules below;
/// `>` block quotes are single-spaced; every other paragraph is a double-spaced body paragraph with a
/// first-line indent. A briefing paragraph is not numbered (FRCP 10(b) numbers claims in a pleading only).
#let body-pieces(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions (`[^n]: text`) are not paragraphs: they are handed to cmarker with the chunk that
  // refers to them, so each reference resolves to its text. A definition chunk is not printed itself.
  let notes = chunks.map(c => c.trim()).filter(t => t.starts-with("[^")).join("\n\n")
  let out = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") {
      continue
    } else if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(">") {
      // Block quote: single-spaced (LR 10(b)(2)), indented on both sides, a single line off the text.
      let q = t.split("\n").map(l => l.trim().trim(">", at: start).trim()).join("\n")
      out.push(block(width: 100%, above: pitch-single, below: pitch-single, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: quote-indent, right: quote-indent, md(q))
      }))
    } else {
      let n = t.contains("[^")
      out.push(body-par(notes: n, md(if n { t + "\n\n" + notes } else { t })))
    }
  }
  out
}

#let med-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LR 10(b)(4): each page numbered at the bottom, centered, in a single-spaced line box.
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (LR 10(b)(2): double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 10"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings, single-spaced (LR 10(b)(2)) at the type size, a single line above: level 1 a centered bold section
  // (INTRODUCTION, ARGUMENT, CONCLUSION); level 2 a bold section heading at the left (I., II.); level 3 an
  // underlined sub-heading (i., ii.), as in the filing; levels 2 and 3 hang half an inch. Sticky: a heading never
  // ends a page.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    let b = if it.level == 1 {
      align(center, par(first-line-indent: 0pt, text(weight: "bold", upper(it.body))))
    } else if it.level == 2 {
      par(first-line-indent: 0pt, hanging-indent: para-indent, text(weight: "bold", it.body))
    } else {
      par(first-line-indent: 0pt, hanging-indent: para-indent, underline(it.body))
    }
    block(sticky: true, width: 100%, above: pitch-single, below: 0pt, b)
  }

  // Footnotes: 11-point, single-spaced (LR 10(b)(1), (2)), the mark and a space before the note (Word's Footnote
  // Text), above a short rule.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  court-title()
  caption(meta)
  title-block(meta)
  let pieces = body-pieces(body)
  // the text a single line under the title
  block(width: 100%, above: pitch-single, below: 0pt, pieces.remove(0))
  let last = pieces.pop()
  for p in pieces { p }
  // The last paragraph stays on the page with the signature, so a signature block never stands alone.
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    last
    signature-lines(meta)
  })
  // A certificate of service, when the sample has one (FRCP 5(d)(1)(B): none is needed for CM/ECF service): its
  // heading a double line below the signature, the text, the signature again; kept together.
  if "certificate" in meta and meta.certificate != none {
    block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
      line-block(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
      block(width: 100%, above: pitch-single, below: 0pt, body-par(md(meta.certificate)))
      signature-lines(meta)
    })
  }
}
