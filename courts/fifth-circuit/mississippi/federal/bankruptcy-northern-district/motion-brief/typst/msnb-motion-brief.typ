// Motion (with memorandum brief) for the United States Bankruptcy Court for the Northern District of Mississippi (msnb).
// Rules (../rules.md): Fed. R. Bankr. P. 9013 and ULR 9013-1(b)(1) (a motion states the rules and statutes it rests
// on, its grounds with particularity and the relief requested), 9004(b) (caption: court, case title, case number, a
// brief designation of the paper), ULR 5005-1(K) (8 1/2 by 11 inches, no font smaller than 12 point, double-spaced;
// quotations, footnotes and legal descriptions may be single-spaced), ULR 5005-1(L)(i) and 9011-1(a) (counsel's
// identification and signature), ULR 9004-1(c) (certificate of service). No ULR sets a face, margin or page limit.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // the house face; data/exemplar-fonts.json audits the exemplar as Times New Roman
#let type-size = 12pt                   // ULR 5005-1(K): no smaller than 12 point (footnotes and the page number too)
#let page-w = 8.5in                     // ULR 5005-1(K): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // no ULR sets a margin; one inch, as the exemplar
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number's box after the indent: the text starts at 1 in
#let item-left = 1in                    // lettered items: the letter at 1 in ...
#let item-box = 0.5in                   // ... in a box of 0.5 in, the text hanging after it
#let role-indent = 1in                  // the debtor designation stands in from the names
#let caption-right = 3in               // the caption's right column (case number, chapter), its text flush right
#let signature-indent = 2.75in          // the signature block sits in the right half of the page
#let signer-title-indent = 0.5in        // "One of Its Attorneys" under the signature line
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the body and the footnote rule

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // ULR 5005-1(K): double-spaced (Word's double, as the exemplar is spaced)
#let gap = pitch-single                 // one blank single line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    body
  })

/// A chunk's text with its footnote references (`[^id]`) placed as typst footnotes (cmarker has none).
/// cmarker trims a piece at its ends, so the spaces around a reference are put back here.
#let with-notes(t, defs) = {
  let piece(s) = {
    if s.starts-with(regex("\\s")) { " " }
    if s.trim() != "" { inl(s.trim()) }
    if s.ends-with(regex("\\s")) and s.trim() != "" { " " }
  }
  let at = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    piece(t.slice(at, m.start))
    footnote(inl(defs.at(m.captures.at(0))))
    at = m.end
  }
  piece(t.slice(at))
}

/// A body paragraph at the double pitch. `keep`: not split, and on the page of the block after it (the last
/// paragraph before the signature). `noted`: the paragraph anchors a footnote; unless kept, it has no widow or orphan
/// control, as Word sets it (the docx Note styles), so a line and its note stay on one page in both engines.
/// `left`, `hang`: a left indent and a hanging indent (lettered items); otherwise the first line is indented.
#let body-par(keep: false, noted: false, left: 0pt, hang: none, body) = block(width: 100%, above: 0pt, below: 0pt,
  sticky: keep, breakable: not keep, {
    let c = if noted and not keep { 0% } else { 100% }
    set text(costs: (widow: c, orphan: c))
    pad(left: left, if hang == none { par(first-line-indent: (amount: para-indent, all: true), body) } else {
      par(first-line-indent: 0pt, hanging-indent: hang, body)
    })
  })

// ---------------------------------------------------------------------------
// Cover: court name, caption (FRBP 9004(b)), title of the paper
// ---------------------------------------------------------------------------

/// The caption, bold, as the filed exemplar sets it: "IN RE:", the debtor names with the case number beside the
/// last one, the designation with the chapter beside it; a blank single line between the blocks.
#let caption(meta) = {
  let d = meta.debtor
  let n = d.names.len()
  let cells = ([IN RE:], [])
  let spacer = (grid.cell(colspan: 2, block(height: gap)),)
  cells += spacer
  for (i, name) in d.names.enumerate() {
    cells += (inl(name), if i == n - 1 { align(right, [CASE NO. #meta.case_number]) } else { [] })
  }
  cells += spacer
  cells += (pad(left: role-indent, inl(d.role)),
    if "chapter" in d { align(right, [CHAPTER #d.chapter]) } else { [] })
  block(width: 100%, above: gap, below: gap, {
    set text(weight: "bold", ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(columns: (1fr, caption-right), inset: 0pt, ..cells)
  })
}

#let cover(meta) = {
  for l in ("IN THE UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF MISSISSIPPI") {
    line-block(align(center, text(weight: "bold", l)))
  }
  caption(meta)
  line-block(below: gap, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Signature blocks
// ---------------------------------------------------------------------------

/// "Respectfully submitted,", the party, "By:" and the signer, the signer's title: in the right half, a double line
/// below the text; then OF COUNSEL and the counsel lines (ULR 5005-1(L)(i)) flush left.
#let signature-block(meta) = {
  let s = meta.signature
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, pad(left: signature-indent, {
    line-block[Respectfully submitted,]
    line-block(above: gap, text(weight: "bold", inl(s.firm)))
    line-block(above: gap, [By: #underline(emph(inl(s.signer)))])
    line-block(pad(left: signer-title-indent, inl(s.title)))
  }))
  if meta.at("counsel", default: ()).len() > 0 {
    block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
      line-block[OF COUNSEL:]
      for l in meta.counsel { line-block(inl(l)) }
    })
  }
}

/// The certificate's signature: its lines ("/s/ ..." and the name) single-spaced in the right half, kept together,
/// a double line below the text.
#let cert-signature(lines) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt,
  pad(left: signature-indent, for l in lines { line-block(inl(l)) }))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A heading, one line at the double pitch, kept with the block after it: level 1 centered bold underlined
/// capitals, level 2 bold at the left, level 3 bold italic at the left.
#let heading-block(t) = {
  let lvl = t.match(regex("^#+")).text.len()
  let s = t.replace(regex("^#+[ \\t]*"), "")
  let b = if lvl == 1 { align(center, text(weight: "bold", underline(upper(inl(s))))) } else if lvl == 2 {
    text(weight: "bold", inl(s))
  } else { text(weight: "bold", style: "italic", inl(s)) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, { set par(first-line-indent: 0pt); b })
}

/// The lines of a list chunk, each item one line of markdown, its marker removed.
#let items(t, marker) = t.split(regex("\\r?\\n")).map(l => l.trim()).filter(l => l != "").map(l => l.replace(regex(marker), ""))

/// Body chunks (blank-line separated markdown):
///  - `#`, `##`, `###`: headings, each kept with the chunk after it;
///  - `1.` lines: numbered motion paragraphs (one count through the paper, as the exemplar numbers them);
///  - `- ` lines: lettered items a., b., ... (the letter at 1 in, the text hanging at 1.5 in);
///  - anything else: a body paragraph with a first-line indent.
/// The signature block follows the chunk before the certificate of service (or the last chunk) and keeps it on its
/// page. In the certificate, a chunk that starts with "/s/" or "s/" opens its signature: it and the chunks after it.
#let body-text(body, meta) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let chunks = ()
  for c in all {
    let m = c.match(regex("^\\[\\^(\\w+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) } else { chunks.push(c) }
  }
  let cert = chunks.position(c => c.match(regex("^#+\\s*(?i)certificate of service\\s*$")) != none)
  let sign-after = if cert == none { chunks.len() - 1 } else { cert - 1 }
  let cert-sig = if cert == none { none } else {
    range(cert + 1, chunks.len()).find(i => chunks.at(i).starts-with(regex("/?s/ ")))
  }
  let n = 0
  for (i, t) in chunks.enumerate() {
    if cert-sig != none and i >= cert-sig {
      if i == cert-sig { cert-signature(chunks.slice(cert-sig)) }
      continue
    }
    let keep = i == sign-after
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(regex("\\d+\\.[ \\t]")) {
      let list = items(t, "^\\d+\\.[ \\t]*")
      for (k, it) in list.enumerate() {
        n += 1
        body-par(keep: keep and k == list.len() - 1, noted: it.contains("[^"),
          box(width: number-box, str(n) + ".") + with-notes(it, defs))
      }
    } else if t.starts-with(regex("-[ \\t]")) {
      let list = items(t, "^-[ \\t]*")
      for (k, it) in list.enumerate() {
        body-par(keep: keep and k == list.len() - 1, noted: it.contains("[^"), left: item-left, hang: item-box,
          [#box(width: item-box, numbering("a.", k + 1))#with-notes(it, defs)])
      }
    } else {
      body-par(keep: keep, noted: t.contains("[^"), with-notes(t, defs))
    }
    if keep { signature-block(meta) }
  }
}

#let msnb-motion-brief(meta, body) = {
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

  // Footnotes single-spaced at the type size (ULR 5005-1(K)): the mark, a space, the note; the rule as long as
  // Word's separator in LibreOffice (30 % of the measure).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  body-text(body, meta)
}
