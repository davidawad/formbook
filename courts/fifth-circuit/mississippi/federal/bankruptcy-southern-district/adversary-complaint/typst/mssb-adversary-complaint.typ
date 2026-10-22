// Adversary complaint for the U.S. Bankruptcy Court, S.D. Mississippi (mssb). Doc type: adversary-complaint.
// Rules: Fed. R. Bankr. P. 7001, 7008(a) (consent statement; jurisdiction allegation), 7010 (Fed. R. Civ. P. 10
// applies: numbered paragraphs, 10(b)), 9004(b) (caption); Miss. Bankr. L.R. 5005-1(a)(2)(G) (8 1/2 x 11, no
// smaller than 12 point, double-spaced), 5005-1(a)(2)(H)(i) (counsel identification), 5005-1(a)(2)(I) (titles),
// 7008-1 (consent statement). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the house face (the rules name none; both exemplars are set in it)
#let type-size = 12pt                   // 5005-1(a)(2)(G): no smaller than 12 point; footer, footnotes and captions included
#let page-w = 8.5in                     // 5005-1(a)(2)(G): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // the rules set no margin; one inch is the usual minimum (README.md)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs and unnumbered lead-ins
#let label-box = 0.5in                  // a paragraph number or sub-item letter stands in a box of this width
#let caption-left = 3.6in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case column
#let signature-indent = 3.25in          // the signature block sits in the right half of the page
#let table-indent = 1in                 // a table in the body is indented 1 in
#let table-col = 2.25in                 // each column of a body table
#let cell-inset = 8.65pt                // a table cell's text stands this far in from its column (173 twips, 0.12 in)
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the body and the footnote rule

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // 5005-1(a)(2)(G): double-spaced (Word's double, as both exemplars are spaced)
#let gap = pitch-single                 // one blank single line: around the caption, the title and the signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with &, *et al.*, footnote-free text).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    body
  })

/// A body block at the double pitch. `keep`: not split, and on the page of the block after it (the last paragraph
/// before the signature: a signature never starts a page alone).
/// `noted`: the paragraph anchors a footnote; unless kept, it has no widow or orphan control, as Word sets it (the docx
/// Note styles), so a line and its note stay on one page in both engines (typst would otherwise move the note on).
#let body-block(keep: false, noted: false, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, {
    let c = if noted and not keep { 0% } else { 100% }
    set text(costs: (widow: c, orphan: c))
    body
  })

/// An unnumbered paragraph: the first line indented by para-indent.
#let indented(keep: false, noted: false, body) = body-block(keep: keep, noted: noted, par(first-line-indent: (amount: para-indent, all: true), body))

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the number at para-indent in a box of label-box, the text after
/// it, the lines after the first at the margin.
#let numbered(keep: false, noted: false, label, body) = body-block(keep: keep, noted: noted,
  par(first-line-indent: 0pt, { h(para-indent); box(width: label-box, label); body }))

/// A lettered sub-item: the letter at para-indent in a box of label-box, the text hanging after it.
#let lettered(keep: false, noted: false, label, body) = body-block(keep: keep, noted: noted, pad(left: para-indent,
  par(first-line-indent: 0pt, hanging-indent: label-box, { box(width: label-box, label); body })))

// ---------------------------------------------------------------------------
// Rule checks: the frontmatter must carry what the rules require, or the build stops here.
// ---------------------------------------------------------------------------

#let check-meta(meta) = {
  assert("caption" in meta, message: "mssb-adversary-complaint: frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  let c = meta.caption
  assert("case_number" in c and "chapter" in c and "adversary_number" in c and "debtor" in c, message: "mssb-adversary-complaint: caption needs debtor, case_number, chapter and adversary_number (FRBP 9004(b)(3); 7008(a) requires the bankruptcy case reference)")
  assert(c.parties.len() == 2, message: "mssb-adversary-complaint: caption.parties needs exactly two entries (plaintiff, defendants)")
  assert("title" in meta and meta.title.len() > 0, message: "mssb-adversary-complaint: frontmatter needs title (FRBP 9004(b)(4); 5005-1(a)(2)(I))")
  assert("consent" in meta and meta.consent.len() > 0, message: "mssb-adversary-complaint: frontmatter needs consent (FRBP 7008(a); Miss. Bankr. L.R. 7008-1)")
  let s = meta.signature
  let lines = s.counsel
  assert(lines.any(l => l.contains("@")), message: "mssb-adversary-complaint: counsel needs an e-mail address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("MSB") or l.contains("Bar")), message: "mssb-adversary-complaint: counsel needs a Mississippi Bar number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("Telephone") or l.contains("Phone")), message: "mssb-adversary-complaint: counsel needs a telephone number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("Pass") or l.contains("Street") or l.contains("Avenue") or l.contains("Drive") or l.contains("Suite") or l.contains("Road") or l.contains("Boulevard") or l.contains("Place") or l.contains("Capitol") or l.contains("Broadway")), message: "mssb-adversary-complaint: counsel needs a street address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
}

// ---------------------------------------------------------------------------
// Cover: court name, caption (FRBP 9004(b)), title of the paper (5005-1(a)(2)(I))
// ---------------------------------------------------------------------------

/// The caption: each block of names on the left; the case facts and the designation on the right; a blank single
/// line between the blocks. One grid, every line a single-pitch line.
#let caption(meta) = {
  let c = meta.caption
  let cells = ()
  let stack(items, flush: false) = for i in items { line-block(if flush { align(right, inl(i)) } else { inl(i) }) }
  let row(left, right, right-align: false) = (stack(left), stack(right, flush: right-align))
  let spacer = (grid.cell(colspan: 2, block(height: gap)),)
  cells += row(c.debtor.names, ("CASE NO. " + c.case_number, c.chapter))
  cells += spacer
  for (k, p) in c.parties.enumerate() {
    if k > 0 {
      cells += spacer
      cells += row(("V.",), ("ADV. PROC. NO. " + c.adversary_number,))
      cells += spacer
    }
    cells += row(p.names, (p.designation,), right-align: true)
  }
  block(width: 100%, above: gap, below: gap, grid(columns: (caption-left, 1fr), column-gutter: caption-gutter,
    inset: 0pt, ..cells))
}

#let cover(meta) = {
  let court = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF MISSISSIPPI")
  if "division" in meta and meta.division != none { court.push(upper(meta.division)) }
  for l in court { line-block(align(center, text(weight: "bold", l))) }
  caption(meta)
  line-block(above: gap, below: gap, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: the date line, "Respectfully submitted," and the counsel lines in the right half; one
/// unbreakable block a double line below the text.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  let s = meta.signature
  line-block(inl(s.date))
  block(width: 100%, above: pitch-double, below: 0pt, pad(left: signature-indent, {
    line-block[Respectfully submitted,]
    line-block(above: gap, inl("/s/ " + s.signer))
    for l in (s.signer, s.role) + s.counsel { line-block(inl(l)) }
  }))
})

/// A heading, one line at the double pitch, kept with the block after it: level 1 centered bold capitals, level 2
/// centered bold, level 3 bold italic at the left.
#let heading-block(t) = {
  let lvl = t.match(regex("^#+")).text.len()
  let s = t.replace(regex("^#+[ \\t]*"), "")
  let b = if lvl == 1 { align(center, text(weight: "bold", upper(inl(s)))) } else if lvl == 2 {
    align(center, text(weight: "bold", inl(s)))
  } else { text(weight: "bold", style: "italic", inl(s)) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, { set par(first-line-indent: 0pt); b })
}

/// A pipe table: single-spaced, indented table-indent, columns of table-col, each cell aligned as the markdown's
/// alignment row says; a blank single line after it.
#let pipe-table(t) = {
  let rows = t.split("\n").map(l => l.trim()).filter(l => l.starts-with("|"))
  let cells-of(l) = l.trim("|").split("|").map(c => c.trim())
  let aligns = cells-of(rows.at(1)).map(a => if a.ends-with(":") and not a.starts-with(":") { right } else if a.starts-with(":") and a.ends-with(":") { center } else { left })
  let body = (rows.at(0),) + rows.slice(2)
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, pad(left: table-indent, grid(
    columns: aligns.len() * (table-col,),
    inset: (x: cell-inset, y: 0pt),
    ..body.map(cells-of).flatten().enumerate().map(((i, c)) => line-block(align(aligns.at(calc.rem(i, aligns.len())), inl(c)))),
  )))
  block(width: 100%, height: gap, above: 0pt, below: 0pt)
}

/// A chunk's text with its footnote references (`[^id]`) placed as typst footnotes (cmarker has none).
/// cmarker trims a piece at its ends, so the spaces around a reference are put back here.
#let with-notes(t, defs) = {
  let piece(s) = {
    if s.starts-with(regex("\\s")) { " " }
    if s.trim() != "" { inl(s.trim()) }
    if s.ends-with(regex("\\s")) and s.trim() != "" { " " }   // a string: typst drops a space element before a footnote
  }
  let at = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    piece(t.slice(at, m.start))
    footnote(inl(defs.at(m.captures.at(0))))
    at = m.end
  }
  piece(t.slice(at))
}

/// Body chunks (blank-line separated markdown):
///  - `#`, `##`, `###`: headings (centered caps, centered bold, bold italic left), kept with the next chunk;
///  - `- item`: lettered sub-items (a), (b), ...;
///  - `| row |`: a table, single-spaced, not numbered;
///  - `WHEREFORE` / `COMES NOW`: unnumbered lead-in paragraphs;
///  - anything else: a numbered paragraph (Fed. R. Civ. P. 10(b)).
/// The last block stays with the signature.
#let allegations(body) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let chunks = ()
  for c in all {
    let m = c.match(regex("^\\[\\^(\\w+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) } else { chunks.push(c) }
  }
  let n = 0
  for (ci, t) in chunks.enumerate() {
    let last = ci == chunks.len() - 1
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with("- ") {
      let items = t.split(regex("\\r?\\n")).filter(l => l.trim().starts-with("- "))
      for (i, l) in items.enumerate() {
        lettered(keep: last and i == items.len() - 1, noted: l.contains("[^"), numbering("(a)", i + 1), with-notes(l.trim().slice(2), defs))
      }
    } else if t.starts-with("|") {
      pipe-table(t)
    } else if t.starts-with("WHEREFORE") or t.starts-with("COMES NOW") {
      indented(keep: last, noted: t.contains("[^"), with-notes(t, defs))
    } else {
      n += 1
      numbered(keep: last, noted: t.contains("[^"), [#n.], with-notes(t, defs))
    }
  }
}

#let mssb-adversary-complaint(meta, body) = {
  check-meta(meta)
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)

  // Footnotes single-spaced at the type size (5005-1(a)(2)(G)): the mark, a space, the note; the rule as long as
  // Word's separator in LibreOffice (30 % of the measure).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  if "lead_in" in meta and meta.lead_in != none { indented(inl(meta.lead_in)) }
  // Consent statement (FRBP 7008(a); Miss. Bankr. L.R. 7008-1): an unnumbered paragraph after the lead-in.
  indented(inl(meta.consent))
  allegations(body)
  signature-block(meta)
}
