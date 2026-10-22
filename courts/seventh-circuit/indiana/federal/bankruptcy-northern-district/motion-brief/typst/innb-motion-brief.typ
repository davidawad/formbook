// U.S. Bankruptcy Court, N.D. Indiana (innb): supporting brief (memorandum) for a motion in a contested
// matter or adversary proceeding. The motion itself is a separate filing (INNB-BRF-001).
//
// Rule-driven and content-agnostic. Requirement IDs (INNB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same
// file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // INNB-FORM-005: no typeface is named in B-5005-2; Times New Roman substitute per docs/FONTS.md, vendored in /fonts. See ../README.md.
#let type-size = 12pt                    // INNB-FORM-005: no size is named in B-5005-2; 12 pt is a style choice. See ../README.md.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // INNB-FORM-004: 8 1/2 x 11 paper; margins are a style choice (no margin figure in B-5005-2).
#let para-indent = 0.5in
#let footer-size = 11pt                  // page number only (INNB-FORM-003); not body text.
#let caption-left = 3.25in               // caption: the debtor column (ruled on its right and below), half the text width
#let caption-inset = 0.2in               // the debtor text stands off the rule; the case information off the rule
#let caption-rule = 0.75pt               // the debtor column's rules; Word adds the bottom rule's width to the row's height
#let name-indent = 0.5in                 // a debtor's name under "In re:"
#let designation-indent = 1.6in          // a designation ("Debtor.") under the names
#let sig-column = 3.2in                  // signature: the right-hand column
#let quote-inset = 0.5in                 // block quotations, both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                   // INNB-FORM-001: double spacing (2 x 12 pt), between paragraphs too.
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face): caption, title, headings, quotations (INNB-FORM-001: quoted material), footnotes, signature, footer
#let gap = pitch-body / 2                // between the caption and the title's last line and the text, around headings and quotations
#let note-gap = 7pt                      // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 12.6pt             // between the text and the footnote rule

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("innb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("innb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Caption (INNB-CAP-001: FRBP 9004(b); the title names the request, INNB-CAP-003: B-9013-1(a))
// ---------------------------------------------------------------------------

/// Court title, centred bold, one line per entry of `court`.
#let court-title(meta) = {
  let court = need(meta, "court")
  for (i, l) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { pitch-body } else { 0pt }, align(center, strong(inl(l))))
  }
}

/// Debtor block (upper left: "In re:", each debtor's names and designation; closed by a rule on its right and
/// below) beside the case number and chapter (upper right, from the line of the first name).
#let debtor-table(meta) = {
  let left = {
    line-block[In re:]
    for (i, d) in need(meta, "debtors").enumerate() {
      line-block(above: if i > 0 { gap } else { 0pt }, left: name-indent, inl(d.names))
      line-block(left: designation-indent, inl(d.designation))
    }
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: gap + caption-rule), left),
    pad(left: caption-inset, top: pitch-single, {
      line-block[Case No. #need(meta, "case_number")]
      line-block[Chapter #need(meta, "chapter")]
    }),
  ))
}

/// Title of the paper, centred bold capitals, one line per entry of `title` (INNB-FORM-002).
#let title-block(meta) = {
  let t = need(meta, "title")
  for (i, l) in t.enumerate() {
    line-block(above: if i == 0 { pitch-body } else { 0pt }, below: if i == t.len() - 1 { gap } else { 0pt },
      align(center, strong(upper(inl(l)))))
  }
}

// ---------------------------------------------------------------------------
// Body (INNB-BRF-002: no numbered paragraphs; headings as written)
// ---------------------------------------------------------------------------

/// A chunk plus the footnote definitions it cites, so cmarker can build the footnotes in the same call.
#let with-notes(c, defs) = {
  let keys = c.matches(regex("\\[\\^(\\w+)\\]")).map(m => m.captures.at(0)).dedup()
  c + keys.map(k => "\n\n" + defs.at(k)).join("")
}

/// The body without its last paragraph, and that paragraph with the footnotes it cites (it is kept with the
/// signature). A body that ends in a heading or a quotation keeps it: (body, none).
#let split-last(src) = {
  let chunks = src.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let is-def(c) = c.starts-with("[^") and c.contains("]:")
  let defs = (:)
  for c in chunks.filter(is-def) {
    defs.insert(c.match(regex("^\\[\\^(\\w+)\\]:")).captures.at(0), c)
  }
  let i = chunks.len() - 1
  while i >= 0 and is-def(chunks.at(i)) { i -= 1 }
  if i < 0 or chunks.at(i).starts-with("#") or chunks.at(i).starts-with(">") { return (src, none) }
  let rest = chunks.slice(0, i) + chunks.slice(i + 1)
  (rest.join("\n\n"), with-notes(chunks.at(i), defs))
}

// ---------------------------------------------------------------------------
// Signature block (convention: no local rule cites the form; see ../README.md)
// ---------------------------------------------------------------------------

/// The date at the margin and the signature in the right-hand column, a body line below the last paragraph
/// (`last`), which it is kept with on one page.
#let signature-block(meta, last) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    last
    block(width: 100%, above: pitch-body, below: 0pt, grid(columns: (1fr, sig-column),
      line-block[Dated: #inl(need(meta, "date"))],
      {
        for l in sig.at("preamble", default: ()) { line-block(inl(l)) }
        line-block(above: pitch-body, inl(sig.signer))
        for l in sig.at("lines", default: ()) { line-block(inl(l)) }
      }))
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let innb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtors", "case_number", "chapter", "title", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",                                  // INNB-FORM-004: 8 1/2 x 11, one side
    margin: margins,
    numbering: "1",
    footer-descent: 30%,
    // INNB-FORM-003: a centred page number on every page, in a single-spaced line box (Word's footer)
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set document(
    title: need(meta, "title").join(" ") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (INNB-FORM-001).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 105"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt, single-spaced (the entry sets its own leading: it does not inherit the body's); the mark, a
  // space, the note (Word's footnote layout); a note is kept whole on one page (Word keeps Footnote Text's lines together).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    block(breakable: false)[#super(num) #note.body]
  }

  // Headings, as the author types them (no numbers are generated): single-spaced, half a body line above and
  // below, kept with the text; `#` centred bold capitals, `##` bold at the margin.
  show heading: it => block(width: 100%, above: gap, below: gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) } else { strong(it.body) }
  })

  // Block quotations (INNB-FORM-001: quoted material single spaced): inset on both sides, half a body line around
  // them and between their paragraphs.
  set quote(block: true)
  show quote: it => block(width: 100%, above: gap, below: gap, pad(x: quote-inset, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: gap)
    it.body
  }))

  // INNB-FORM-002: the title is set out on the first page (B-5005-2(a)(2)).
  court-title(meta)
  debtor-table(meta)
  title-block(meta)

  let (body, last) = split-last(md)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta, if last != none { block(width: 100%, above: 0pt, below: 0pt, par(inl(last))) })
}
