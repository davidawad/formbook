// Motion with memorandum (memorandum brief in support) for the U.S. Bankruptcy Court, S.D. Mississippi (mssb).
// Doc type: motion-brief. Rules: Fed. R. Bankr. P. 9013 (motions), 9004(b) (caption; 9004-1(b) docket reference),
// 9011 and Miss. Bankr. L.R. 9011-1(a) (signature); Miss. Bankr. L.R. 9013-1(a) (rules and statutes relied on),
// 9013-1(b) (service); 5005-1(a)(2)(G) (8 1/2 x 11, no smaller than 12 point, double-spaced; quotations and
// footnotes may be single-spaced), 5005-1(a)(2)(H)(i) (counsel identification), 5005-1(a)(2)(I) (titles in the
// caption), 5005-1(a)(2)(D)(i) (a proposed order is a separate attachment; see ../README.md). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the house face (the rules name none; the exemplar is set in it)
#let type-size = 12pt                   // 5005-1(a)(2)(G): no smaller than 12 point; footer, footnotes and captions included
#let page-w = 8.5in                     // 5005-1(a)(2)(G): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // the rules set no margin; one inch is the usual minimum (README.md)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.6in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case column
#let quote-left = 0.75in                // block quotations: indented on both sides
#let quote-right = 0.5in
#let signature-indent = 3.25in          // the signature block sits in the right half of the page
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the body and the footnote rule

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // 5005-1(a)(2)(G): double-spaced (Word's double, as the exemplar is spaced)
#let gap = pitch-single                 // one blank single line: around the caption and the title, after a quotation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, footnote-free text).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    body
  })

/// A body paragraph at the double pitch with the first-line indent. `keep`: not split, and on the page of the block
/// after it (the last paragraph before the signature: a signature never starts a page alone). `noted`: the
/// paragraph anchors a footnote; unless kept, it has no widow or orphan control, as Word sets it (the docx Note
/// styles), so a line and its note stay on one page in both engines (typst would otherwise move the note on).
#let body-par(keep: false, noted: false, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, {
    let c = if noted and not keep { 0% } else { 100% }
    set text(costs: (widow: c, orphan: c))
    par(first-line-indent: (amount: para-indent, all: true), body)
  })

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

// ---------------------------------------------------------------------------
// Rule checks: the frontmatter must carry what the rules require, or the build stops here.
// ---------------------------------------------------------------------------

#let check-meta(meta) = {
  assert("caption" in meta, message: "mssb-motion-brief: frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  let c = meta.caption
  assert("case_number" in c and "chapter" in c and "adversary_number" in c and "debtor" in c, message: "mssb-motion-brief: caption needs debtor, case_number, chapter and adversary_number (FRBP 9004(b)(3))")
  assert(c.parties.len() == 2, message: "mssb-motion-brief: caption.parties needs exactly two entries (plaintiff, defendant)")
  assert("title" in meta and meta.title.len() > 0, message: "mssb-motion-brief: frontmatter needs title: every content of the paper goes in the caption (5005-1(a)(2)(I); FRBP 9004(b)(4))")
  assert("related_docket" in meta and meta.related_docket.len() > 0, message: "mssb-motion-brief: frontmatter needs related_docket: a paper that relates to a filed document states its docket number, (Dkt. # ___) (Miss. Bankr. L.R. 9004-1(b))")
  let s = meta.signature
  let lines = s.counsel
  assert(lines.any(l => l.contains("@")), message: "mssb-motion-brief: counsel needs an e-mail address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("MS Bar") or l.contains("MSB") or l.contains("Bar #")), message: "mssb-motion-brief: counsel needs a Mississippi Bar number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("Telephone") or l.contains("Phone")), message: "mssb-motion-brief: counsel needs a telephone number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.match(regex("^\\d+ ")) != none), message: "mssb-motion-brief: counsel needs a street address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
}

// ---------------------------------------------------------------------------
// Cover: court name, caption (FRBP 9004(b)), title of the paper (5005-1(a)(2)(I)), docket reference (9004-1(b))
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
  line-block(above: gap, align(center, text(weight: "bold", upper(meta.title))))
  line-block(below: gap, align(center, inl("(Dkt. # " + meta.related_docket + ")")))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: the date line at the left; the party, "/s/" and the counsel lines in the right half; one
/// unbreakable block a double line below the text.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  let s = meta.signature
  line-block(inl(s.date))
  let party = if "party" in s and s.party != none { (s.party,) } else { () }
  block(width: 100%, above: pitch-double, below: 0pt, pad(left: signature-indent,
    for l in party + ("/s/ " + s.signer,) + s.counsel { line-block(inl(l)) }))
})

/// A heading, one line at the double pitch, kept with the block after it: level 1 centered bold capitals, level 2
/// bold at the left, level 3 bold italic at the left. `page`: the heading starts a new page (the certificate).
#let heading-block(t, page: false) = {
  let lvl = t.match(regex("^#+")).text.len()
  let s = t.replace(regex("^#+[ \\t]*"), "")
  let b = if lvl == 1 { align(center, text(weight: "bold", upper(inl(s)))) } else if lvl == 2 {
    text(weight: "bold", inl(s))
  } else { text(weight: "bold", style: "italic", inl(s)) }
  if page { pagebreak(weak: true) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, { set par(first-line-indent: 0pt); b })
}

/// A block quotation: single-spaced, indented on both sides, a blank single line after each of its paragraphs.
#let block-quote(t, defs) = {
  let src = t.split(regex("\\r?\\n")).map(l => l.replace(regex("^>[ \\t]?"), "")).join("\n")
  for q in src.split(regex("\\n[ \\t]*\\n")).map(c => c.trim()).filter(c => c != "") {
    line-block(below: gap, pad(left: quote-left, right: quote-right, with-notes(q, defs)))
  }
}

/// Lines set with hard breaks (an address block): single-spaced, kept together, a blank single line around them.
#let address-block(t, keep: false) = block(width: 100%, above: gap, below: gap, breakable: false, sticky: keep,
  for l in t.split(regex("\\\\\\r?\\n")) { line-block(inl(l.trim())) })

/// Body chunks (blank-line separated markdown), none numbered (a memorandum brief):
///  - `#`, `##`, `###`: headings, each kept with the chunk after it;
///  - `> ...`: a quotation, single-spaced and indented;
///  - a chunk with hard line breaks (an address block): single-spaced;
///  - anything else: a body paragraph with a first-line indent, double-spaced.
/// The signature block follows the text and keeps the last block before it on its page. The certificate of
/// service starts a new page after the signature, as in the filing.
#let body-text(body, meta) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let chunks = ()
  for c in all {
    let m = c.match(regex("^\\[\\^(\\w+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) } else { chunks.push(c) }
  }
  // the chunk the signature follows: the one before the certificate, or the last
  let cert = chunks.position(c => c.starts-with("# CERTIFICATE"))
  let sign-after = if cert == none { chunks.len() - 1 } else { cert - 1 }
  for (i, t) in chunks.enumerate() {
    let keep = i == sign-after
    if t.starts-with("#") {
      heading-block(t, page: i == cert)
    } else if t.starts-with(">") {
      block-quote(t, defs)
    } else if t.contains("\\\n") {
      address-block(t, keep: keep)
    } else {
      body-par(keep: keep, noted: t.contains("[^"), with-notes(t, defs))
    }
    if keep { signature-block(meta) }
  }
}

#let mssb-motion-brief(meta, body) = {
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
  body-text(body, meta)
}
