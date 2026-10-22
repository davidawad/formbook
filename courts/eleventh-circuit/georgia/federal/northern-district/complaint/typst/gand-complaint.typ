// Complaint for the U.S. District Court for the Northern District of Georgia (gand).
// Rules (N.D. Ga. Local Rules, LR 5.1): (C) type and spacing, (D) margins, (E) page numbers bottom center,
// (G) counsel identification, (J) captions per Fed. R. Civ. P. 7, (K) case number with judge suffix.
// Fed. R. Civ. P. 10(a) caption, 10(b) numbered paragraphs. See ../README.md for the rule text and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-name = ("Times New Roman", "Liberation Serif")     // LR 5.1(C) names Times New Roman (14 pt); substitute per docs/FONTS.md, metric-compatible.
#let font-family = font-name
#let type-size = 14pt                   // LR 5.1(C): Times New Roman at least 14 point
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // LR 5.1(D): top, bottom, left and right margins at least one inch
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-box = 0.5in                 // the paragraph number's box after the indent
#let caption-party-w = 3.2in            // width of the party column of the caption
#let caption-paren-w = 0.35in           // the column of ")" marks between the parties and the case number
#let designation-indent = 1.5in         // "Plaintiff," and "Defendant." in the party column
#let list-indent = 0.5in                // lettered prayer items: the letter half an inch in, the text a box after it
#let sig-left = 2.7in                   // the signature lines stand 2.7 in from the margin
#let sig-gap = 4pt                      // between the groups of the signature block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-body = 2 * pitch-single      // LR 5.1(C): double-spaced; 32.2 pt, the filed exemplar's body pitch (Serveco p.2)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gand-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field. A missing one stops the render: the form cannot be left incomplete.
#let need(meta, key) = {
  assert(key in meta, message: "gand-complaint: frontmatter field `" + key + "` is required")
  meta.at(key)
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE NORTHERN DISTRICT OF GEORGIA")))
  line-block(align(center, text(weight: "bold", upper(need(meta, "division")) + " DIVISION")))
}

/// The caption: party names on the left, a column of ")" marks, and the case number on the right, one single
/// line per row. The case number stands on the middle row, the jury demand two rows below it. A name that is wider
/// than its column is a render error (split the name over two lines in the frontmatter, as the filed caption does).
#let caption(meta) = {
  let lines = ()
  for (k, p) in need(meta, "caption").at("parties").enumerate() {
    if k > 0 { lines.push(("v.", 0pt)) }
    for n in need(p, "names") { lines.push((n, 0pt)) }
    lines.push((need(p, "designation"), designation-indent))
  }
  let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "______________" }
  let mid = calc.quo(lines.len() - 1, 2)
  let right = ((str(mid)): [Civil Action No. #case-no])
  if "jury_demand" in meta and meta.jury_demand { right.insert(str(mid + 2), [JURY TRIAL DEMANDED]) }
  let rows = calc.max(lines.len(), mid + if "jury_demand" in meta and meta.jury_demand { 3 } else { 1 })
  let cell(body) = block(width: 100%, height: pitch-single, { set text(..edges(pitch-single)); body })
  let cells = ()
  for i in range(rows) {
    let (s, indent) = lines.at(i, default: ("", 0pt))
    cells.push(cell(context {
      assert(measure(inl(s)).width + indent <= caption-party-w,
        message: "gand caption: a party line is wider than its column; split it in the frontmatter: " + s)
      pad(left: indent, inl(s))
    }))
    cells.push(cell(if i < lines.len() [)]))
    cells.push(cell(right.at(str(i), default: none)))
  }
  block(above: pitch-single, below: pitch-single, grid(columns: (caption-party-w, caption-paren-w, 1fr), ..cells))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(below: pitch-single, align(center, text(weight: "bold", upper(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lists, signature block
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = need(meta, "signature")
  let attorneys = need(s, "attorneys")
  assert(attorneys.len() > 0, message: "gand-complaint: LR 5.1(G) needs at least one attorney block")
  for a in attorneys {
    // LR 5.1(G): name, complete address, telephone, email and bar number on every document.
    for k in ("name", "bar", "email") {
      assert(k in a, message: "gand-complaint: LR 5.1(G) needs `" + k + "` for every attorney")
    }
  }
  block(breakable: false, above: pitch-body, below: 0pt, {
    line-block[Dated: #need(meta, "date")]
    line-block(above: pitch-body, left: sig-left)[/s/ #need(s, "signer")]
    for a in attorneys { line-block(left: sig-left)[#a.name, Georgia Bar No. #a.bar] }
    for (i, l) in need(s, "firm").enumerate() { line-block(above: if i == 0 { sig-gap } else { 0pt }, left: sig-left, inl(l)) }
    for l in need(s, "address") { line-block(left: sig-left, inl(l)) }
    line-block(left: sig-left)[Telephone: #need(s, "phone")]
    for a in attorneys { line-block(left: sig-left, a.email) }
    line-block(above: sig-gap, left: sig-left, inl(need(s, "role")))
  })
}

/// A body paragraph at the double pitch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, content))

/// The body. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one numbered
/// paragraph (Fed. R. Civ. P. 10(b)); a chunk starting with "~ " is unnumbered text (a WHEREFORE clause, a jury
/// demand). A footnote definition is merged into the chunk before it, so its reference and text are rendered
/// together. A list is lettered (A., B., ...).
#let allegations(body) = {
  let raw = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "").map(c => c.trim())
  let chunks = ()
  for t in raw {
    if t.starts-with("[^") and chunks.len() > 0 {
      chunks = chunks.slice(0, -1) + (chunks.last() + "\n\n" + t,)
    } else {
      chunks.push(t)
    }
  }
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: list-indent, md(t))
    } else if t.starts-with("~ ") {
      body-par[#h(para-indent)#md(t.slice(2))]
    } else {
      n += 1
      body-par[#h(para-indent)#box(width: number-box)[#n.]#md(t)]
    }
  }
}

#let gand-complaint(meta, body) = {
  // LR 5.1(E): page numbers at the bottom center of every page, in a single-spaced line box (Word's footer).
  set page(width: page-w, height: page-h, margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (LR 5.1(C): double-spaced); prayer items as a label box (list-indent) with the text hanging.
  show: xengine.with(pitch: pitch-body, list-indent: list-indent)
  // A doubled sign stays with its number ("§§ 2201"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  set enum(numbering: "A.")
  // Footnotes (LR 5.1(C): single-spaced, 14 pt): the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings (LR 5.1(C): may be single-spaced): level 1 a centered section in capitals; level 2 centered bold;
  // level 3 bold at the margin; a single line above and below, kept with the text after them.
  show heading: it => block(width: 100%, sticky: true, above: pitch-single, below: pitch-single, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if it.level == 2 { align(center, text(weight: "bold", it.body)) }
    else { text(weight: "bold", it.body) }
  })

  cover(meta)
  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }
  allegations(body)
  signature-block(meta)
}
