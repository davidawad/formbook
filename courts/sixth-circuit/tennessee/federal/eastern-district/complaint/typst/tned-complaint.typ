// Complaint for the U.S. District Court for the Eastern District of Tennessee (tned).
//
// Rule-driven and content-agnostic. Governing rules: E.D. Tenn. LR 5.1 (paper, type size, spacing,
// margins, page numbers) and LR 3.1 (civil cover sheet, a separate filing); Fed. R. Civ. P. 8(a),
// 10(a), 10(b), 11(a). Rule text, verification dates and known gaps: ../README.md.
// Every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1 names no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR 5.1: no smaller than 12, footnotes included
#let page-margin = 1in                  // LR 5.1: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent; a paragraph's number stands in a box this wide after it (Fed. R. Civ. P. 10(b))
#let caption-left = 3.2in               // the party column of the caption, closed by rules on the right and below
#let caption-inset = 10pt               // the party column's text to its rules
#let caption-gap = 0.25in               // the rule to the case number and title
#let designation-indent = 1in           // "Plaintiff," / "Defendants." under the party names
#let versus-indent = 0.5in              // "v." between the parties
#let sig-indent = 3.25in                // the signature block stands at the middle of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // LR 5.1: double-spaced at 12 pt (body paragraphs, headings, lettered items)
#let pitch-single = 13.8pt              // LR 5.1: single-spaced (court title, caption, signature, footnotes, page number): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                 // a blank single line: between the caption's groups and the signature's
#let caption-below = 12pt               // the caption to the lead-in
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the text and the footnote rule (the room LibreOffice keeps above a note)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tned-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// A paragraph at the body pitch; `last` keeps it whole and with the signature block after it.
#let body-par(last: false, hang: 0pt, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: last,
  breakable: not last, par(first-line-indent: 0pt, hanging-indent: hang, content))

// ---------------------------------------------------------------------------
// Cover: court title, caption (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF TENNESSEE")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

/// The caption: the parties on the left (names, a blank line, the designation; "v." a blank line from each side) in a
/// column closed by rules on the right and below; the case number and, a body line below it, the title on the right.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset,
    bottom: caption-inset), {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: gap, left: versus-indent)[v.] }
      for (j, n) in p.names.enumerate() { line-block(above: if k > 0 and j == 0 { gap } else { 0pt }, inl(n)) }
      line-block(above: gap, left: designation-indent, inl(p.designation))
    }
  }),
  block(inset: (left: caption-gap), {
    line-block[Case No. #meta.case_number]
    line-block(above: pitch-body, strong(inl(meta.title)))
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered items, unnumbered WHEREFORE paragraphs
// ---------------------------------------------------------------------------

/// Headings in a body line, kept with the block after them: level 1 centered bold capitals underlined (as filed),
/// level 2 centered bold, level 3 bold at the left.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(underline(upper(inl(s))))) }
  else if level == 2 { align(center, strong(inl(s))) }
  else { strong(inl(s)) }
})

/// List items: "1." items lettered (a), (b), ...; "-" items a bullet. The label in a half-inch box half an inch in,
/// the text hanging an inch in; the last item of the body is kept with the signature block.
#let items(c, last) = {
  let lines = c.split(regex("\\r?\\n"))
  let starts = regex("^(\\d+[.)]|[-*+])[ \\t]+")
  let its = ()
  for l in lines {
    if l.match(starts) != none { its.push(l.replace(starts, "")) }
    else if its.len() > 0 { its.at(-1) = its.at(-1) + " " + l.trim() }
  }
  let ordered = c.trim().match(regex("^\\d")) != none
  for (i, s) in its.enumerate() {
    let lab = if ordered { "(" + numbering("a", i + 1) + ")" } else { "•" }
    let is-last = last and i == its.len() - 1
    body-par(last: is-last, hang: 2 * para-indent)[#h(para-indent)#box(width: para-indent, lab)#inl(s)]
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 5.1: the filing attorney's name, address, telephone and BPR number; Fed. R. Civ. P. 11(a))
// ---------------------------------------------------------------------------

/// "Dated:" at the margin with "Respectfully submitted," at the middle of the page; then the firm (bold), the
/// e-signature, the signer, the BPR number, the address lines and the role (italic), a blank single line between
/// the groups. Kept on one page.
#let signature-block(meta) = {
  let sig = meta.signature
  let s(above: 0pt, body) = line-block(above: above, left: sig-indent, body)
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    let dated = if "date" in sig and sig.date != none [Dated: #sig.date] else []
    line-block[#box(width: sig-indent, dated)Respectfully submitted,]
    for (i, f) in sig.at("firm", default: ()).enumerate() { s(above: if i == 0 { gap } else { 0pt }, strong(inl(f))) }
    s(above: gap)[By: /s/ #inl(sig.signer)]
    s(inl(sig.signer))
    // the BPR line when the filer has one (a pro hac vice filer's Tennessee counsel supplies it)
    if "bpr" in sig and sig.bpr != none { s(inl(sig.bpr)) }
    for l in sig.at("lines", default: ()) { s(inl(l)) }
    if "role" in sig and sig.role != none { s(above: gap, emph(inl(sig.role))) }
  })
}

#let tned-complaint(meta, body) = {
  set document(title: meta.title + " (" + meta.case_number + ")")
  // LR 5.1: page numbers consecutively at the bottom; no other text in the bottom margin. The number centered in a
  // single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1681n"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt (LR 5.1), single-spaced; the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  court-title(meta)
  caption(meta)
  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, above: caption-below, below: 0pt, par(first-line-indent: 0pt)[#h(para-indent)#inl(meta.lead_in)])
  }

  // Body: blank-line-separated chunks (Fed. R. Civ. P. 10(b): each paragraph numbered); a chunk that cites a
  // footnote carries the footnote definitions with it.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  let chunks = chunks.filter(c => not c.starts-with("[^"))
  let with-notes(s) = if defs != none and s.contains("[^") { s + "\n\n" + defs } else { s }
  let n = 0
  for (k, c) in chunks.enumerate() {
    let last = k == chunks.len() - 1
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      heading-block(level, c.replace(regex("^#+\\s*"), ""))
    } else if c.match(regex("^(\\d+[.)]|[-*+])[ \\t]")) != none {
      items(c, last)
    } else if c.starts-with("WHEREFORE") {
      body-par(last: last)[#h(para-indent)#inl(with-notes(c))]
    } else {
      n += 1
      body-par(last: last)[#h(para-indent)#box(width: para-indent)[#n.]#inl(with-notes(c))]
    }
  }

  signature-block(meta)
}
