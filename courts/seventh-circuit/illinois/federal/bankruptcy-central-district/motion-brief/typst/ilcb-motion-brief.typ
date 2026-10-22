// U.S. Bankruptcy Court, Central District of Illinois: motion with memorandum of law.
//
// Rule-driven and content-agnostic. Governing sources (see ../README.md):
//   FRBP 9013(a)-(b) (written motion; grounds stated with particularity), FRBP 7012(b) (Civil Rule 12(b)
//   motions in an adversary proceeding), FRBP 7010 (caption: Rule 10 Civil; Form 416),
//   FRBP 9004(a)-(b) (legible; caption contents), ILCB LR 9013-1 (motion practice),
//   Practice Guide (Dec. 1, 2025): certificate of service for each paper served, signature "/s/".
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").
// The docx engine (../docx/ilcb-motion-brief.lua) sets the same lines and pages from the same numbers.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-lines = ("UNITED STATES BANKRUPTCY COURT", "CENTRAL DISTRICT OF ILLINOIS")  // FRBP 7010, Form 416
#let font-family = ("Times New Roman", "Liberation Serif")          // no court rule names a face (README, ILCB-TYPE-1); Times New Roman substitute per docs/FONTS.md, vendored in /fonts
#let type-size = 12pt                      // no CDIL typography rule (FRBP 9004(a): legible only); 12 pt, the size the
                                           // exemplars use (see README, gaps).
#let note-size = 11pt                      // footnotes, one point under the text
#let page-margin = 1in                     // exemplars all use 1 in; no rule sets it (tier 2)
#let para-indent = 0.5in                   // first-line indent of body paragraphs
#let caption-left-width = 3.4in            // the party column
#let caption-paren-width = 0.3in           // the ")" column between the parties and the case lines
#let title-inset = 0.5in                   // the title wraps half an inch inside each margin
#let sig-indent = 2.925in                  // the signature block's column (45 % of the 6.5 in text width)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                   // double spacing: Word's double line at 12 pt (2 x 13.8 pt), as in all three
                                           // exemplars (README, tier 2)
#let pitch-single = 13.8pt                 // a single line: 1.15 x the type size (court lines, caption, title, headings,
                                           // signature, counsel, quotations, certificate)
#let pitch-note = 12.65pt                  // a footnote line: 1.15 x 11 pt
#let gap = pitch-single                    // a blank single line: around headings, in the signature block
#let note-gap = 7pt                        // between footnotes
#let note-clearance = 7pt                  // between the text and the footnote rule (with the gap, the room LibreOffice
                                           // keeps above a note)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ilcb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilcb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else { "" }
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Court lines, caption (FRBP 7010: name of court, parties, bankruptcy case number and chapter,
// adversary number; the ")" column is the convention in the exemplars) and title
// ---------------------------------------------------------------------------

/// The court's name, centered bold capitals (as printed in the rule's own form), a body line above the caption.
#let court-heading() = {
  for (i, l) in court-lines.enumerate() {
    line-block(below: if i == court-lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

/// One row per frontmatter line: the party line, ")", the case line; an empty string is an empty line.
#let caption(meta) = {
  let cap = need(meta, "caption")
  let party-lines = cap.at("left")
  let case-lines = cap.at("right")
  let rows = calc.max(party-lines.len(), case-lines.len())
  let cell(s) = line-block(if s == "" { [] } else { inl(s) })
  block(above: 0pt, below: 0pt, breakable: false, grid(
    columns: (caption-left-width, caption-paren-width, 1fr),
    ..range(rows).map(i => (
      cell(party-lines.at(i, default: "")),
      line-block(align(center, ")")),
      cell(case-lines.at(i, default: "")),
    )).flatten(),
  ))
}

/// The title of the document (centered, bold), a body line below the caption. Wraps naturally: no forced line breaks.
#let title-block(meta) = line-block(above: pitch-body, below: gap,
  pad(x: title-inset, align(center, strong(inl(need(meta, "document_title"))))))

// ---------------------------------------------------------------------------
// Headings, single-spaced, a single line from the text on either side, kept with the text after them.
// Level 1: centered bold (section, e.g. "I. INTRODUCTION"). Level 2: bold, left (numbered by the author,
// e.g. "A. ..."). Level 3: bold italic, left. Level 4: italic, left.
// ---------------------------------------------------------------------------

#let style-heading(h) = block(width: 100%, above: gap, below: gap, sticky: true, {
  set text(size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if h.level == 1 { align(center, strong(h.body)) }
  else if h.level == 2 { strong(h.body) }
  else if h.level == 3 { strong(emph(h.body)) }
  else { emph(h.body) }
})

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011 and the court's signature guidance: "/s/" then the typed name)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let above = pitch-body
  if "dated" in meta {
    line-block(above: above)[Dated: #inl(meta.dated)]
    above = gap
  }
  line-block(above: above, left: sig-indent)[Respectfully submitted,]
  line-block(above: gap, left: sig-indent, strong(inl(sig.firm)))
  line-block(above: gap, left: sig-indent)[By: /s/ #inl(sig.signer)]
  line-block(left: sig-indent)[One of Its Attorneys]
  // counsel of record: left margin, one line each (as the exemplars print it)
  for (i, l) in sig.at("counsel", default: ()).enumerate() {
    line-block(above: if i == 0 { gap } else { 0pt }, inl(l))
  }
}

// ---------------------------------------------------------------------------
// Certificate of service (Practice Guide: "a signed certificate of service must be included or
// filed with all documents required to be served"; it must name each party served in full,
// identify the document served and include the case caption). Single-spaced, a single line between
// its parts, kept together, a body line below the signature block.
// ---------------------------------------------------------------------------

#let certificate-of-service(meta) = {
  let svc = meta.at("service", default: none)
  if svc == none { return }
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch-body, below: 0pt, {
    line-block(below: gap, align(center, strong[CERTIFICATE OF SERVICE]))
    line-block[The undersigned certifies that on #inl(svc.date), a copy of the foregoing #inl(svc.document) was filed and thereafter served using the Court’s electronic filing system on the following counsel of record:]
    for r in svc.recipients {
      for (i, l) in r.lines.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(l)) }
    }
    line-block(above: gap, left: sig-indent)[/s/ #inl(sig.signer)]
  })
}

// ---------------------------------------------------------------------------
// Entry: the motion with memorandum
// ---------------------------------------------------------------------------

#let ilcb-motion-brief(meta, md) = {
  let _ = need(meta, "caption")
  let _ = need(meta, "document_title")
  let _ = need(meta, "signature")

  set document(
    title: plain(inl(need(meta, "document_title"))),
    author: need(meta, "signature").signer,
  )
  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 157"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 11 pt, single-spaced (1.15 x 11 pt boxes), the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }
  // Block quotations: single-spaced, half an inch in on both sides, a single line around them and between their
  // paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: gap, below: gap, pad(x: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: gap)
    it.body
  }))
  show heading: style-heading

  // ---- first page: court, caption, title (no cover page; the caption starts page 1) ----
  court-heading()
  caption(meta)
  title-block(meta)

  // ---- body: introduction, argument, conclusion ----
  // Footnote definitions sit at the end of the file, but a reference and its definition must be in
  // the same cmarker call, so the definitions travel with every call (they print only where referenced).
  // The signature block never stands alone on a page: the last paragraph is kept with it.
  let defs-at = md.match(regex("(?m)^\\[\\^[^\\]]+\\]:"))
  let defs = if defs-at == none { "" } else { md.slice(defs-at.start) }
  let main = (if defs-at == none { md } else { md.slice(0, defs-at.start) }).trim(at: end)
  let breaks = main.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let head = main.slice(0, cut)
  let tail = main.slice(cut)
  let keep = tail.len() > 0 and not tail.starts-with("#")
  let render(s) = cmarker.render(s + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if keep {
    render(head)
    block(breakable: false, { render(tail); signature-block(meta) })
  } else {
    render(main)
    block(breakable: false, signature-block(meta))
  }

  // ---- certificate of service (the document served is named in the certificate) ----
  certificate-of-service(meta)
}
