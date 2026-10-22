// Complaint for the U.S. District Court for the Central District of Illinois (ilcd).
// Rules: Civil LR 5.1 (format: letter paper, one-inch margins, numbered pages, double spacing, 12- or 14-point body),
// 38.1 (title words for a jury demand), 40.1(E)(1) (division in the caption), 5.11(A) (s/name signatures),
// 11.1 (telephone number and typed name); Fed. R. Civ. P. 8(a), 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1(B)(2) asks for a plain roman style and names no face; Times New Roman, with Liberation Serif its vendored metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt                   // LR 5.1(B)(2): body text 12-point or 14-point
#let page-margin = 1in                  // LR 5.1(A): approximately one-inch margins on each side, top and bottom
#let para-indent = 0.5in                // first-line indent of paragraphs, and the box of a paragraph's number after it
#let item-indent = 0.5in                // prayer items: the label stands half an inch in ...
#let item-label = 0.5in                 // ... in a box of this width; the text hangs after it
#let caption-left = 3.2in               // party column of the caption
#let paren-col = 0.3in                  // column of ")" marks between the party column and the case column
#let case-indent = 0.15in               // the case number and jury legend stand this far right of the ")" marks
#let designation-indent = 1.25in        // "Plaintiff," and "v." sit under the party names
#let sig-left = 3.25in                  // the signature blocks stand in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // LR 5.1(B)(1): double spacing, a 24 pt pitch at 12 pt (body, headings, prayer)
#let pitch-single = 13.8pt              // single spacing (court title, caption, title, signature, page number): Word's single line, 1.15 x 12 pt
#let gap = 24pt                         // one blank double-spaced line: around the caption, title and signature parts

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilcd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split the body into blank-line-separated chunks: headings, lettered lists, paragraphs.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// One single-spaced line block with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, centered: false, sticky: false, body) = block(width: 100%,
  above: above, below: below, sticky: sticky, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: left, if centered { align(center, body) } else { body })
})

/// A paragraph at the body pitch.
#let body-par(sticky: false, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  breakable: not sticky, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the footer in a single-spaced line box (LR 5.1(A): pages must be numbered).
#let page-footer() = context align(center, text(..edges(pitch-single), counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ([UNITED STATES DISTRICT COURT], [CENTRAL DISTRICT OF ILLINOIS],
    // LR 40.1(E)(1): the caption must identify the division in which the case is pending.
    upper(meta.division))
  for l in lines { line-block(centered: true, text(weight: "bold", l)) }
}

/// Caption: one single-spaced row per line, a ")" mark on every row, a blank row between the entries (the names of
/// a party, its designation, "v."). The case number stands on the row of the first designation, the jury legend
/// on the row of the last one. A long name is typed as several `names` entries, one per line.
#let caption(meta) = {
  let rows = ()   // (left content, left indent, is a designation)
  let parties = meta.caption.parties
  for (k, p) in parties.enumerate() {
    if k > 0 { rows.push(([v.], designation-indent, false)); rows.push(([], 0pt, false)) }
    for n in p.names { rows.push((inl(n), 0pt, false)) }
    rows.push(([], 0pt, false))
    rows.push((inl(p.designation), designation-indent, true))
    if k < parties.len() - 1 { rows.push(([], 0pt, false)) }
  }
  let desig = range(rows.len()).filter(i => rows.at(i).at(2))
  let jury = "jury_demand" in meta and meta.jury_demand
  let case-row = desig.first()
  let jury-row = if desig.last() != case-row { desig.last() } else { case-row + 2 }
  if jury { while jury-row >= rows.len() { rows.push(([], 0pt, false)) } }
  let cells = ()
  for (i, (t, ind, _)) in rows.enumerate() {
    let rt = if i == case-row { [Case No. #meta.case_number] } else if jury and i == jury-row { [Jury Trial Demanded] } else { [] }
    cells.push(line-block(left: ind, t))
    cells.push(line-block(align(right, [)])))
    cells.push(line-block(left: case-indent, rt))
  }
  block(width: 100%, above: gap, below: 0pt, breakable: false,
    grid(columns: (caption-left, paren-col, 1fr), ..cells))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  let relief = "equitable_relief" in meta and meta.equitable_relief
  line-block(above: gap, below: if relief { 0pt } else { gap }, centered: true, sticky: true,
    text(weight: "bold", upper(meta.brief_title)))
  // LR 38.1: a complaint that prays for equitable relief says so under its title.
  if relief { line-block(below: gap, centered: true, sticky: true, text(weight: "bold", [EQUITABLE RELIEF IS SOUGHT])) }
}

// ---------------------------------------------------------------------------
// Signature blocks
// ---------------------------------------------------------------------------

/// Dated line, then "Respectfully submitted," and one "/s/ name" block per signer (LR 5.11(A)(2)), in the right half.
/// Each signer's name, bar number, firm, address, telephone and email are typed below the signature (LR 11.1).
#let signature-block(meta) = block(breakable: false, width: 100%, above: gap, below: 0pt, {
  line-block(inl("Dated: " + meta.date))
  line-block(above: gap, left: sig-left, [Respectfully submitted,])
  for s in meta.signature {
    line-block(above: gap, left: sig-left, inl("/s/ " + s.signer))
    for l in s.lines { line-block(left: sig-left, inl(l)) }
  }
})

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ilcd-complaint(meta, body) = {
  assert("division" in meta, message: "ilcd-complaint: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)")
  if meta.jury_demand {
    // LR 38.1: where a jury demand is endorsed, the title of the pleading must include "and demand for jury trial".
    assert(lower(meta.brief_title).contains("and demand for jury trial"), message: "ilcd-complaint: LR 38.1: a jury demand needs 'and demand for jury trial' in the title")
  }

  // LR 5.1(A): letter paper, one-inch margins, the page number centered in the bottom margin (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%, footer: page-footer())
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  cover(meta)

  // The unnumbered lead-in paragraph (the opening sentence before paragraph 1).
  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }

  let n = 0
  let chunks = chunks-of(body)
  for (k, c) in chunks.enumerate() {
    // the last paragraph stays with the signature block, so the signature never stands alone on a page
    let last = k == chunks.len() - 1
    if c.starts-with("#") {
      // Headings: level 1 a centered bold section title in capitals; levels 2 and 3 centered bold (count headings
      // and their subtitles). Each stays with the text after it.
      let level = c.match(regex("^#+")).text.len()
      let t = c.replace(regex("^#+\\s*"), "")
      block(width: 100%, sticky: true, above: 0pt, below: 0pt,
        align(center, text(weight: "bold", if level == 1 { upper(inl(t)) } else { inl(t) })))
    } else if c.split("\n").all(l => l.match(regex("^([0-9]+\\.|[-*+])[ \\t]")) != none) {
      // prayer items (a markdown list): (a), (b), ...
      let items = c.split("\n")
      for (i, l) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, sticky: last, breakable: not last,
          par(hanging-indent: item-indent + item-label, first-line-indent: 0pt,
            [#h(item-indent)#box(width: item-label, numbering("(a)", i + 1))#inl(l.replace(regex("^([0-9]+\\.|[-*+])[ \\t]+"), ""))]))
      }
    } else if c.starts-with("~ ") {
      // an indented paragraph outside the numbering (the WHEREFORE clause, the jury demand sentence)
      body-par(sticky: last)[#h(para-indent)#inl(c.slice(2))]
    } else {
      // a numbered paragraph (Fed. R. Civ. P. 10(b)); the number runs through the whole complaint
      n += 1
      body-par(sticky: last)[#h(para-indent)#box(width: para-indent)[#n.]#inl(c)]
    }
  }

  signature-block(meta)
}
