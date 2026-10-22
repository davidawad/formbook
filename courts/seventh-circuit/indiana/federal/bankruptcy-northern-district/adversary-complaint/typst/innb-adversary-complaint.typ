// U.S. Bankruptcy Court, N.D. Indiana (innb): complaint commencing an adversary proceeding.
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
#let para-indent = 0.5in                 // first line of a paragraph; a paragraph number stands here
#let number-box = 0.5in                  // the paragraph number's box: the text starts an inch in and wraps to the margin
#let footer-size = 11pt                  // page number only (INNB-FORM-003); not body text.
#let caption-left = 3.25in               // caption: the left column (debtors; parties, ruled), half the text width
#let caption-inset = 0.2in               // the left column's text stands off its rule; the right column's off the rule
#let caption-rule = 0.75pt               // the parties' rules; Word adds the bottom rule's width to the row's height
#let name-indent = 0.5in                 // a debtor's name under "In re:"
#let designation-indent = 1.6in          // a designation ("DEBTOR", "PLAINTIFF") under its names
#let sig-column = 3.2in                  // signature: the right-hand column
#let by-rule = 3in                       // signature: "By:" and the rule after it
#let quote-inset = 0.5in                 // block quotations, both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                   // INNB-FORM-001: double spacing (2 x 12 pt), between paragraphs too.
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face): caption, headings, quotations, footnotes, signature, footer
#let gap = pitch-body / 2                // between the caption's groups, around headings and quotations
#let note-gap = 7pt                      // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 12.6pt             // between the text and the footnote rule

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("innb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("innb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

#let para-counter = counter("innb-para")

// ---------------------------------------------------------------------------
// Caption (INNB-CAP-001 to 003: FRBP 9004(b); FRBP 7010 and Official Form 416D)
// ---------------------------------------------------------------------------

/// Court title, centred bold, one line per entry of `court`.
#let court-title(meta) = {
  let court = need(meta, "court")
  for (i, l) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { pitch-body } else { 0pt }, align(center, strong(inl(l))))
  }
}

/// Debtor block (upper left: "In re:", each debtor's names and designation) beside the case number and
/// chapter (upper right, from the line of the first name).
#let debtor-table(meta) = {
  let left = {
    line-block[In re:]
    for (i, d) in need(meta, "debtors").enumerate() {
      line-block(above: if i > 0 { gap } else { 0pt }, left: name-indent, inl(d.names))
      line-block(left: designation-indent, inl(d.designation))
    }
  }
  let right = {
    line-block(above: pitch-single)[Case No. #need(meta, "case_number")]
    line-block[Chapter #need(meta, "chapter")]
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    pad(right: caption-inset, left),
    pad(left: caption-inset, top: pitch-single, right),
  ))
}

/// Plaintiff and defendant block (left, closed by a rule on the right and below) beside the adversary
/// number (right).
#let parties-table(meta) = {
  let sides = need(meta, "caption")
  let left = for (i, side) in sides.enumerate() {
    if i > 0 { line-block(above: gap, below: gap)[v.] }
    line-block(inl(side.names))
    line-block(left: designation-indent, inl(side.designation))
  }
  block(above: gap, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: gap + caption-rule), left),
    pad(left: caption-inset, line-block[Adv. Proc. No. #need(meta, "adv_number")]),
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
// Body (INNB-CMP-001: numbered paragraphs, FRCP 10(b) via FRBP 7010)
// ---------------------------------------------------------------------------

/// A heading: single-spaced, half a body line above and below, kept with the text after it; `#` centred
/// bold capitals, `##` bold at the margin.
#let heading-block(t, centred) = block(width: 100%, above: gap, below: gap, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if centred { align(center, strong(upper(inl(t)))) } else { strong(inl(t)) }
})

/// A chunk plus the footnote definitions it cites, so cmarker can build the footnotes in the same call.
#let with-notes(c, defs) = {
  let keys = c.matches(regex("\\[\\^(\\w+)\\]")).map(m => m.captures.at(0)).dedup()
  c + keys.map(k => "\n\n" + defs.at(k)).join("")
}

/// The kind of a body chunk: a heading (`#`, `##`), a block quotation (`>`), a lettered sub-item (`A.`)
/// or the prayer (`WHEREFORE`), both unnumbered, or a numbered paragraph.
#let kind(c) = {
  if c.starts-with("## ") { "h2" }
  else if c.starts-with("# ") { "h1" }
  else if c.starts-with(">") { "quote" }
  else if c.match(regex("^[A-Z]\\.\\s")) != none or c.starts-with("WHEREFORE") { "plain" }
  else { "numbered" }
}

/// A paragraph chunk: a numbered one carries its number in a half-inch box at the first-line indent.
#let para-chunk(c, defs) = {
  if kind(c) == "numbered" {
    para-counter.step()
    par[#box(width: number-box, context [#para-counter.display()#"."])#inl(with-notes(c, defs))]
  } else {
    par(inl(with-notes(c, defs)))
  }
}

/// Split the body into blank-line-separated chunks. Footnote definitions (`[^key]: ...`) are collected and
/// attached to the chunk that cites them. Returns (defs, chunks).
#let body-chunks(src) = {
  let chunks = src.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  for c in chunks {
    if c.starts-with("[^") and c.contains("]:") {
      let m = c.match(regex("^\\[\\^(\\w+)\\]:"))
      defs.insert(m.captures.at(0), c)
    }
  }
  (defs, chunks.filter(c => not (c.starts-with("[^") and c.contains("]:"))))
}

#let render-chunk(c, defs) = {
  let k = kind(c)
  if k == "h2" { heading-block(c.slice(3).trim(), false) }
  else if k == "h1" { heading-block(c.slice(2).trim(), true) }
  else if k == "quote" {
    // single-spaced, inset on both sides, half a body line around it
    let q = c.split("\n").map(l => l.trim(regex("^>\\s?"), at: start)).join("\n")
    block(width: 100%, above: gap, below: gap, pad(x: quote-inset, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, spacing: gap)
      inl(with-notes(q, defs))
    }))
  } else { block(width: 100%, above: 0pt, below: 0pt, para-chunk(c, defs)) }
}

// ---------------------------------------------------------------------------
// Signature block (convention: no local rule cites the form; see ../README.md)
// ---------------------------------------------------------------------------

/// The date (when given) at the margin and the signature in the right-hand column, a body line below the last
/// paragraph (`last`, the prayer), which it is kept with on one page.
#let signature-block(meta, last) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    last
    block(width: 100%, above: pitch-body, below: 0pt, grid(columns: (1fr, sig-column),
      if "date" in meta { line-block[Dated: #inl(meta.date)] },
      {
        for l in sig.at("preamble", default: ()) { line-block(inl(l)) }
        line-block(above: pitch-body, inl(sig.firm))
        line-block(emph(inl(sig.role)))
        line-block(above: pitch-body, box(width: by-rule)[By: #box(width: 1fr, line(length: 100%, stroke: 0.5pt))])
        line-block(inl(sig.signer))
        for l in sig.at("lines", default: ()) { line-block(inl(l)) }
      }))
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let innb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtors", "case_number", "chapter", "caption", "adv_number", "title", "signature") {
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
  // A doubled sign stays with its number ("§§ 523"), as a single one does in xengine.
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

  // INNB-FORM-002: the title is set out on the first page (B-5005-2(a)(2)); the caption is the first thing on it.
  court-title(meta)
  debtor-table(meta)
  parties-table(meta)
  title-block(meta)

  if "lead_in" in meta {
    block(width: 100%, above: 0pt, below: 0pt, par(inl(meta.lead_in)))
  }
  let (defs, chunks) = body-chunks(md)
  // the last chunk, a paragraph (the prayer), is kept with the signature
  let last = none
  if chunks.len() > 0 and kind(chunks.last()) in ("plain", "numbered") {
    last = block(width: 100%, above: 0pt, below: 0pt, para-chunk(chunks.last(), defs))
    chunks = chunks.slice(0, -1)
  }
  for c in chunks { render-chunk(c, defs) }
  signature-block(meta, last)
}
