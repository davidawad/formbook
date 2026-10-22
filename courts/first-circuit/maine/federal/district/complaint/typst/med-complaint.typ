// Complaint for the United States District Court for the District of Maine (med).
// Rules: D. Me. Local Rule 3 (filing items), 10(a) (caption and title), 10(b) (form): 12-point or larger type;
// text double-spaced; 8 1/2 x 11 inch paper; page numbers at the bottom; 1-inch margins. Fed. R. Civ. P. 10(a)
// (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no face named by D. Me. LR 10(b)(1), so docs/FONTS.md "No face named": Times New Roman substitute (README.md)
#let type-size = 12pt                   // LR 10(b)(1): 12-point or larger; 12 pt, as the filed exemplars (README.md)
#let margin = 1in                       // LR 10(b)(5): 1-inch margins on all four sides
#let para-indent = 0.5in                // first-line indent of paragraphs; the paragraph number's box after it
#let item-indent = 0.5in                // prayer items: the letter stands half an inch in
#let item-label = 0.5in                 // the letter's box; the item text hangs after it (at 1 inch)
#let quote-indent = 0.5in               // block quotations, indented on both sides
#let caption-left = 3.4in               // width of the party block of the caption
#let caption-gap = 0.3in                // between the party block's rule and the case number column
#let caption-pad = 12pt                 // inside the party block: its text stops this far from the rule at its right
#let caption-foot = 8pt                 // and its last line stands this far above the rule at its foot
#let case-indent = 0.1in                // the case number column's text, in from the column
#let rule-w = 1.6in                     // the blank for the clerk when the case number is not yet known
#let designation-indent = 1.5in         // "Plaintiff," / "Defendants." set in from the party names
#let date-w = 3.0in                     // signature: the date at the margin, the signer's lines from 3 inches

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt              // LR 10(b)(2): double-spaced (Word double spacing for 12 pt Times; the filed exemplars measure 27.6 pt)
#let pitch-single = 13.8pt              // caption, title, headings, block quotes, signature: single-spaced, 1.15 x the type size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("med-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (names, paragraphs, headings; smart quotes).
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
    // With no case number yet (a new complaint), a blank is left for the clerk to fill in.
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

/// The title of the paper in bold capitals, and its subtitle, under the caption (LR 10(a)).
#let title-block(meta) = {
  line-block(above: pitch-double, align(center, text(weight: "bold", upper(meta.title))))
  if "subtitle" in meta and meta.subtitle != none { line-block(align(center, md(meta.subtitle))) }
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), headings, lettered lists, block quotes; signature
// ---------------------------------------------------------------------------

/// Signature block: the date at the margin, the signing attorney's /s/ line beside it at 3 inches, the lines of the
/// block under it; a double line off the text.
#let signature-lines(meta) = {
  line-block(above: pitch-double, [#box(width: date-w)[Dated: #meta.date]/s/ #meta.signature.signer])
  for l in meta.signature.lines { line-block(indent: date-w, md(l)) }
}

/// A body paragraph at the double pitch, its first line indented: numbered (the number in a box after the indent),
/// or not.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else [#box(width: para-indent, [#num.])#content]))

/// Walk the markdown body. Blank lines separate chunks. `#` headings are styled by show rules below;
/// `N.` list items are lettered A., B., ... by the template (the prayer); `>` block quotes are single-spaced
/// and unnumbered; `~ ` paragraphs are unnumbered (the WHEREFORE clause); every other paragraph is numbered.
#let body-pieces(body) = {
  let n = 0
  let out = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Lettered A., B., ...: the letter half an inch in, the text hanging after it, at the double pitch.
      out.push(pad(left: item-indent, md(t)))
    } else if t.starts-with(">") {
      // Block quote: single-spaced (LR 10(b)(2)), indented on both sides, a single line off the text.
      let q = t.split("\n").map(l => l.trim().trim(">", at: start).trim()).join("\n")
      out.push(block(width: 100%, above: pitch-single, below: pitch-single, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: quote-indent, right: quote-indent, md(q))
      }))
    } else if t.starts-with("~ ") {
      out.push(body-par(none, md(t.slice(2))))
    } else {
      n += 1
      out.push(body-par(n, md(t)))
    }
  }
  out
}

#let med-complaint(meta, body) = {
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
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set enum(numbering: "A.")

  // Headings, single-spaced (LR 10(b)(2)) at the type size: level 1 a centered bold section in capitals, a single
  // line above it; level 2 a centered bold sub-heading right under it (a bracketed statute line under a claim);
  // level 3 bold italic at the left. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: if it.level == 2 { 0pt } else { pitch-single }, below: 0pt, b)
  }

  court-title()
  caption(meta)
  title-block(meta)
  let pieces = body-pieces(body)
  // the text a single line under the title
  block(width: 100%, above: pitch-single, below: 0pt, pieces.remove(0))
  let last = pieces.pop()
  for p in pieces { p }
  // The last paragraph (the jury demand) stays on the page with the signature block.
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    last
    signature-lines(meta)
  })
}
