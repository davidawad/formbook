// Complaint for the U.S. District Court for the Northern District of Illinois (ilnd).
// Rules: N.D. Ill. LR 5.2(e) (8 1/2 x 11 paper; line spacing at least 2.0 lines; 12-point body type;
// footnotes at least 11 points; margins at least 1 inch on all four sides); Fed. R. Civ. P. 8(a), 10(a),
// 10(b), 11(a), 38(b). See ../README.md. Content-agnostic: every case-specific word comes from the
// sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no font is mandated by LR 5.2(e); Times New Roman (vendored in fonts/), the exemplar's face; Liberation Serif is its metric twin
#let type-size = 12pt                   // LR 5.2(e)(1): 12-point type in the body of the text
#let margin = 1in                       // LR 5.2(e)(2): each margin at least 1 inch; 8 1/2 x 11 inch paper
#let para-indent = 0.5in                // first-line indent of paragraphs, and the box of a paragraph's number after it
#let caption-left = 3.3in               // width of the party column of the caption (rule on its right and bottom)
#let caption-gutter = 0.25in            // between the party column and the case number
#let caption-pad = 10pt                 // the party column's text stands this far from its rules
#let caption-right-pad = 0.1in          // the case number column's text stands this far from the gutter
#let designation-indent = 0.5in         // "Plaintiff," / "Defendant." under the party names
#let versus-indent = 0.9in              // "v." between the sides
#let sig-left = 3in                     // the signature column ("Respectfully submitted," and below)
// Headings after which paragraphs are not numbered: a prayer and a jury demand are not claims, so Fed. R.
// Civ. P. 10(b) (numbered paragraphs for claims) does not reach them.
#let unnumbered-after = ("PRAYER FOR RELIEF", "DEMAND FOR JURY TRIAL")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                // LR 5.2(e): at least 2.0 lines; Word's double line at 12 pt (2 x 13.8 pt), the exemplar's pitch
#let pitch-single = 13.8pt              // single lines (court title, caption, headings, signature, page number): Word's single line at 12 pt
#let blank = 13.8pt                     // one blank single line: between the parts of the caption and of the signature
#let head-gap = 6.9pt                   // above and below a group of headings: a one-line heading takes one body line (13.8 + 2 x 6.9)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: left, body)
})

/// A paragraph at the body pitch; `keep`: not split, and kept with what follows.
#let body-par(keep: false, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper (Fed. R. Civ. P. 10(a); LR 5.2(e))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF ILLINOIS")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
}

#let caption(meta) = {
  // Left: the parties, each name and designation its own single line, "v." between the sides; the column is
  // closed by a rule on its right and bottom.
  let left = ()
  let parties = meta.caption.parties
  for (k, p) in parties.enumerate() {
    for (i, n) in p.names.enumerate() { left.push((inl(n), 0pt, if k > 0 and i == 0 { blank } else { 0pt })) }
    left.push((inl(p.designation), designation-indent, blank))
    if k < parties.len() - 1 { left.push(([v.], versus-indent, blank)) }
  }
  // Right: the case number, the judge when assigned, the title and any jury legend.
  let right = (([Case No.: #meta.case_number], 0pt),)
  if "judge" in meta and meta.judge != none { right.push(([Judge #meta.judge], 0pt)) }
  for (i, l) in meta.brief_title.enumerate() { right.push((text(weight: "bold", inl(l)), if i == 0 { blank } else { 0pt })) }
  if "jury_demand" in meta and meta.jury_demand { right.push((text(weight: "bold", "JURY TRIAL DEMANDED"), blank)) }
  block(width: 100%, above: blank, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-pad), {
      for (t, ind, above) in left { line-block(above: above, left: ind, t) }
    }),
    [],
    pad(left: caption-right-pad, { for (t, above) in right { line-block(above: above, t) } }),
  ))
}

// ---------------------------------------------------------------------------
// Signature (Fed. R. Civ. P. 11(a))
// ---------------------------------------------------------------------------

/// "Dated" at the margin and "Respectfully submitted," on the same line at the signature column; below it the
/// signer, the signer's lines, the firm and the party, a blank line between the groups. Not split.
#let signature-block(meta) = {
  let sig = meta.signature
  let rows = ((box(width: sig-left)[Dated: #meta.date] + [Respectfully submitted,], 0pt, 0pt),)
  rows.push(([/s/ #sig.signer], sig-left, blank))
  for l in sig.lines { rows.push((inl(l), sig-left, 0pt)) }
  for (i, l) in sig.firm.enumerate() { rows.push((inl(l), sig-left, if i == 0 { blank } else { 0pt })) }
  for (i, l) in sig.party.enumerate() { rows.push((inl(l), sig-left, if i == 0 { blank } else { 0pt })) }
  block(width: 100%, breakable: false, above: blank, below: 0pt, {
    for (t, left, above) in rows { line-block(above: above, left: left, t) }
  })
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Split the body into blank-line-separated chunks: headings, lettered lists, paragraphs.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

#let is-head(c) = c.starts-with("#")
#let is-list(c) = c.split("\n").all(l => l.match(regex("^[0-9]+\\. ")) != none)

#let ilnd-complaint(meta, body) = {
  // LR 5.2(e): letter paper, one-inch margins; the page number centered in the bottom margin (conventional; LR 5.2
  // sets none), in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 2201"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)

  // An unnumbered introductory paragraph, one blank single line under the caption.
  if "lead_in" in meta {
    block(width: 100%, above: blank, below: 0pt, par(first-line-indent: 0pt)[#h(para-indent)#inl(meta.lead_in)])
  }

  let chunks = chunks-of(body)
  // The last paragraph and the headings right before it are kept with the signature block (a signature alone at the
  // top of a page is not filed that way).
  let tail = chunks.len() - 1
  while tail > 0 and is-head(chunks.at(tail - 1)) { tail -= 1 }
  let n = 0
  let numbered = true
  for (k, c) in chunks.enumerate() {
    let keep = k >= tail
    if is-head(c) {
      let level = c.match(regex("^#+")).text.len()
      let t = c.replace(regex("^#+\\s*"), "")
      if level == 1 { numbered = upper(t) not in unnumbered-after }
      // Headings: single lines, bold; levels 1 and 2 centered and underlined (level 1 in capitals), level 3 at the
      // margin. A group of headings has head-gap above and below it, none inside it, and stays with what follows.
      let first = k == 0 or not is-head(chunks.at(k - 1))
      let last = k == chunks.len() - 1 or not is-head(chunks.at(k + 1))
      let txt = if level == 1 { upper(inl(t)) } else { inl(t) }
      block(width: 100%, sticky: true, breakable: false, above: if first { head-gap } else { 0pt },
        below: if last { head-gap } else { 0pt }, {
          set text(..edges(pitch-single), weight: "bold")
          set par(first-line-indent: 0pt)
          if level <= 2 { align(center, underline(txt)) } else { txt }
        })
    } else if is-list(c) {
      // prayer and other lists: lettered (a), (b), ... by the template; the label in the number's place
      let items = c.split("\n")
      for (i, l) in items.enumerate() {
        body-par(keep: keep)[#h(para-indent)#box(width: para-indent, numbering("(a)", i + 1))#inl(l.replace(regex("^[0-9]+\\. "), ""))]
      }
    } else if numbered {
      // a numbered paragraph (Fed. R. Civ. P. 10(b)); the number runs through the whole complaint
      n += 1
      body-par(keep: keep)[#h(para-indent)#box(width: para-indent)[#n.]#inl(c)]
    } else {
      body-par(keep: keep)[#h(para-indent)#inl(c)]
    }
  }

  signature-block(meta)
}
