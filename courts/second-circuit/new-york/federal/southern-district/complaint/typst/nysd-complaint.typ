// U.S. District Court, Southern District of New York: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NYSD-...) refer to ../README.md, which quotes the
// rules: Fed. R. Civ. P. 8(a), 10(a)-(c); S.D.N.Y. Joint Local Civil Rules (Jan. 2, 2026) 7.1(b)
// (typeface, margins, spacing for all papers). No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The body is markdown rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // NYSD-FORM-002: the joint rules name no typeface; Times New Roman, the house standard. Vendored in /fonts.
#let type-size = 12pt                    // NYSD-FORM-001: 12-point type or larger (Local Civ. R. 7.1(b)(1)); footnotes too.
#let margin = 1in                        // NYSD-FORM-004: at least one-inch margins on all sides (Local Civ. R. 7.1(b)(2)).
#let para-indent = 0.5in                 // first-line indent of paragraphs.
#let number-box = 0.5in                  // the paragraph number in a box of this width after the indent; the text after it.
#let list-indent = 0.5in                 // lettered items (prayer for relief, class questions): the label this far in,
#let list-label = 0.4in                  // in a box of this width, the text hanging after it.
#let quote-left = 0.75in                 // block quotations: indented on the left
#let quote-right = 0.5in                 // and on the right.
#let caption-inset = 0.2in               // the caption's text stands off the rule between its columns,
#let caption-pad = 12pt                  // and the party column's last line this far above its bottom rule.
#let designation-indent = 1.8in          // a party's designation under its names.
#let sig-column = 3.2in                  // the signature column, at the right.
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after).
#let note-clearance = 7.5pt              // from the text to the footnote rule: with note-gap, the space LibreOffice keeps above its separator.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // NYSD-FORM-003: double-spaced (Local Civ. R. 7.1(b)(3)).
#let pitch-single = 13.8pt               // single spacing, 1.15 x the size: caption, headings, block quotations, footnotes,
                                         // signature block (single-spaced where the rule allows).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, footnote references) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nysd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, if type(body) == str { inl(body) } else { body })
})

// ---------------------------------------------------------------------------
// Cover: court title and caption (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The caption: the parties on the left (closed by a rule on the right and bottom), the file number, judge, legends
/// and title on the right. Rule 10(a): court name, title naming all the parties, file number, and the Rule 7(a)
/// designation (the title "COMPLAINT"). Never split.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 {
        line-block("")
        line-block(align(center)[v.])
        line-block("")
      }
      for n in side.names { line-block(n) }
      line-block(indent: designation-indent, side.designation)
    }
  }
  let right = {
    if meta.at("electronic", default: false) {
      line-block[ELECTRONICALLY FILED]
      line-block("")
    }
    line-block[No. #need(meta, "case_number")]
    if "judge" in meta { line-block(meta.judge) }
    line-block("")
    for l in meta.at("legends", default: ()) { line-block(strong(upper(inl(l)))) }
    line-block("")
    line-block(strong(upper(inl(need(meta, "title")))))
    for l in meta.at("legends-after", default: ()) { line-block(strong(upper(inl(l)))) }
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (1fr, 1fr),
    block(width: 100%, inset: (right: caption-inset, bottom: caption-pad), stroke: (right: 0.75pt, bottom: 0.75pt),
      left),
    pad(left: caption-inset, right),
  ))
}

#let cover(meta) = {
  for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (Rule 10(b)), lettered lists, block quotations
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, Fed. R. Civ. P. 10(b)) the
/// number in a box and the text after it. `keep`: kept whole on the page of the block after it (the last block
/// stays with the signature).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-box, [#num.])#content] }))

/// A heading, single-spaced at the type size (the rule allows it), bold, sticky; a single line above it, and below
/// it unless another heading follows. Level 1: centered capitals; level 2: centered; level 3: italic at the left.
#let heading-block(level, content, below) = block(width: 100%, above: pitch-single, below: below, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(content))) }
  else if level == 2 { align(center, strong(content)) }
  else { strong(emph(content)) }
})

/// Lettered items (a), (b), ...: the label half an inch in, in a box of list-label, the text hanging after it, at
/// the double pitch.
#let list-chunk(c, keep) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none { items.push(m.captures.at(1)) } else if items.len() > 0 { items.last() += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    let k = keep and i == items.len() - 1
    block(width: 100%, above: 0pt, below: 0pt, sticky: k, breakable: not k, pad(left: list-indent,
      par(first-line-indent: 0pt, hanging-indent: list-label,
        [#box(width: list-label, numbering("(a)", i + 1))#inl(it)])))
  }
}

/// Each blank-line-separated chunk of markdown is one unit of the body:
///  - a heading ("#", "##", "###"), sticky, so it never ends a page;
///  - a list, lettered (a), (b), ... (each item its own block);
///  - a block quotation (">"), indented and single-spaced, a single line above and below, not numbered;
///  - a footnote definition ("[^label]: text") is not printed here: it is attached to each chunk that refers to it;
///  - a paragraph starting "WHEREFORE" or under a "JURY TRIAL" heading is not numbered;
///  - any other paragraph is numbered 1, 2, ... (Fed. R. Civ. P. 10(b)).
/// The last unit stays whole with the signature block.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  // cmarker renders a chunk on its own, so a footnote reference cannot see a definition in another chunk.
  let notes = chunks.filter(c => c.starts-with("[^"))
  let with-notes(t) = t + notes
    .filter(n => t.contains("[^" + n.slice(2, n.position("]")) + "]"))
    .map(n => "\n\n" + n).join("")
  let render(t) = cmarker.render(with-notes(t), raw-typst: false, smart-punctuation: true)
  let cs = chunks.filter(c => not c.starts-with("[^"))
  let n = 0
  let unnumbered-section = false
  for (i, t) in cs.enumerate() {
    let last = i == cs.len() - 1
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      if m == none { panic("nysd-complaint: malformed heading: " + t) }
      unnumbered-section = t.contains("JURY TRIAL")
      let next-heading = not last and cs.at(i + 1).starts-with("#")
      heading-block(m.captures.at(0).len(), render(m.captures.at(1)), if next-heading { 0pt } else { pitch-single })
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      list-chunk(t, last)
    } else if t.starts-with(">") {
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: last, breakable: not last, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: quote-left, right: quote-right, render(t.replace(regex("(?m)^>[ \\t]?"), "")))
      })
    } else if t.starts-with("WHEREFORE") or unnumbered-section {
      body-par(none, render(t), keep: last)
    } else {
      n += 1
      body-par(n, render(t), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (no local rule cites the form; the exemplar's form is used: see ../README.md)
// ---------------------------------------------------------------------------

/// A double line below the body: "Dated:" at the left, the signature column at the right; single-spaced, never
/// broken across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (1fr, sig-column),
    line-block[Dated: #inl(need(meta, "date"))],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-double)[By: /s/ #inl(sig.signer)]
      line-block(sig.signer)
      for l in sig.at("lines", default: ()) { line-block(l) }
    },
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nysd-complaint(meta, md) = {
  for k in ("court", "case_number", "caption", "title", "signature", "date") {
    let _ = need(meta, k)
  }

  // The page number centered at the foot, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (Local Civ. R. 7.1(b)(3): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the text size (NYSD-FORM-001), single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  // The lead-in, unnumbered, a double line below the caption.
  if "lead_in" in meta {
    block(width: 100%, above: pitch-double, below: 0pt, body-par(none, inl(meta.lead_in)))
  }
  allegations(md)
  signature-block(meta)
}
