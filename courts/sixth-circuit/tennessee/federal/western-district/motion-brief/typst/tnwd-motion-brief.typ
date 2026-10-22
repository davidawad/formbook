// Memorandum in support of a motion to dismiss under Fed. R. Civ. P. 12(b), for the United States District
// Court for the Western District of Tennessee (tnwd). Rules: W.D. Tenn. LR 7.1(a)-(d) (paper, margins,
// double spacing, 12 point type including footnotes, page limits excluding caption, signature and
// certificates), LR 7.2(a)(1) (a motion is accompanied by a memorandum "so identified"), LR 7.2(e) and
// LR 12.1(a) (20 pages), LR 11.1(b) (signature block); Fed. R. Civ. P. 5(b), 7(b), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file. No
// coordinates measured off the exemplar, no forced line breaks.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // the W.D. Tenn. CM/ECF manual allows Times New Roman (README.md, typeface row); vendored in /fonts
#let type-size = 12pt                  // LR 7.1(b): no smaller than 12 point, footnotes included
#let margin = 1in                      // LR 7.1(a): one-inch margins on all sides, 8 1/2 by 11 inch paper
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let point-label = 0.5in               // the label of a point heading (I., A.) stands in a box this wide, the text hangs after it
#let caption-left = 3.3in              // the party column of the caption
#let caption-marks = 0.4in             // the column of ")" marks
#let caption-right = 0.1in             // the file number stands this far right of the marks
#let designation-indent = 1.25in       // "Plaintiff," / "Defendants." under the party names
#let blank-width = 1.6in               // the file number's blank before the clerk assigns one
#let sig-indent = 3.25in               // signature block from the middle of the page
#let served-indent = 0.5in             // the persons served, in the certificate

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt               // LR 7.1(b): double-spaced; Word's double line at 12 pt (2 x 1.15 x 12 pt)
#let pitch-single = 13.8pt             // single spacing (LR 7.1(b) allows it for quotations, headings, footnotes): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                // a blank single line: caption rows, around headings, between signature groups
#let head-below = 6.9pt                // under a heading: half a single line
#let quote-gap = 6.9pt                 // around a block quotation
#let note-gap = 7pt                    // between footnotes
#let note-clearance = 12.6pt           // between the text and the footnote rule (the room LibreOffice keeps above a note)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, footnote marks, smart punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// A paragraph at the body pitch; `last` keeps it whole and with the signature block after it.
#let body-par(above: 0pt, last: false, content) = block(width: 100%, above: above, below: 0pt, sticky: last,
  breakable: not last, par(first-line-indent: 0pt, hanging-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The court title, single-spaced, centered (the first page of a W.D. Tenn. filing).
#let court-title(division) = {
  line-block(align(center)[IN THE UNITED STATES DISTRICT COURT])
  line-block(align(center)[FOR THE WESTERN DISTRICT OF TENNESSEE])
  if division != none and division != "" { line-block(align(center, inl(division))) }
}

/// The caption: one row per party line (names, the designation, a blank line, "v.", a blank line, ...), a column of
/// ")" marks (one per line of text: a name can wrap), the file number opposite "v." (the style of the case).
#let caption(sides, case-number) = {
  let rows = ()   // (content or none, indent, is "v.")
  for (i, side) in sides.enumerate() {
    for n in side.names { rows.push((inl(n), 0pt, false)) }
    rows.push((inl(side.designation), designation-indent, false))
    if i < sides.len() - 1 {
      rows.push((none, 0pt, false))
      rows.push(([v.], 0pt, true))
      rows.push((none, 0pt, false))
    }
  }
  let cells = ()
  for (c, ind, is-v) in rows {
    let text-cell = if c == none { line-block[] } else { line-block(left: ind, c) }
    let marks = context {
      let n = if c == none { 1 } else { calc.max(1, int(calc.round(measure(width: caption-left, text-cell).height / pitch-single))) }
      for _ in range(n) { line-block(align(center)[)]) }
    }
    let right = if is-v {
      line-block(left: caption-right, if case-number != "" [No. #case-number] else [No. #box(width: blank-width, height: 0.6em, stroke: (bottom: 0.5pt))])
    } else { [] }
    cells += (text-cell, marks, right)
  }
  grid(columns: (caption-left, caption-marks, 1fr), ..cells)
}

// ---------------------------------------------------------------------------
// Body blocks
// ---------------------------------------------------------------------------

/// A section heading (level 1): centered bold, single-spaced, a blank single line above and half a line below, kept
/// with what follows.
#let section-heading(s) = line-block(above: gap, below: head-below, sticky: true, align(center, strong(inl(s))))

/// A point heading (level 2 and deeper): bold, single-spaced; a typed label ("I.", "A.", "1.") in a half-inch box,
/// the text hanging after it. A heading without a label is set bold at the left.
#let point-heading(s) = {
  let m = s.match(regex("^([IVXLC]+|[A-Z]|[0-9]+)\\.\\s+(.*)$"))
  block(width: 100%, above: gap, below: head-below, sticky: true, {
    set text(..edges(pitch-single))
    if m == none {
      par(first-line-indent: 0pt, hanging-indent: 0pt, strong(inl(s)))
    } else {
      par(first-line-indent: 0pt, hanging-indent: point-label,
        strong[#box(width: point-label)[#m.captures.at(0).]#inl(m.captures.at(1))])
    }
  })
}

/// A block quotation: single-spaced, half an inch in on both sides.
#let quote-block(t) = block(width: 100%, above: quote-gap, below: quote-gap, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: para-indent, right: para-indent,
    inl(t.split("\n").map(l => l.trim().replace(regex("^>\\s?"), "")).join("\n")))
})

// ---------------------------------------------------------------------------
// Signature and certificate of service
// ---------------------------------------------------------------------------

/// The signature block (LR 11.1(b)): "s/" and the filing user's name, the attorney bar number, the firm, street
/// address, city, state and ZIP, telephone and primary e-mail, in that order, from the middle of the page, a blank
/// single line between the groups. Kept on one page.
#let signature-block(sig, date) = block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
  let s(above: 0pt, body) = line-block(above: above, left: sig-indent, body)
  if date != none and date != "" { line-block[Dated: #date] }
  s(above: if date != none and date != "" { gap } else { 0pt })[Respectfully submitted,]
  s(above: gap)[s/ #inl(sig.signer)]
  s[Attorney Bar No. #sig.bar_number]
  if sig.at("firm", default: none) != none { s(inl(sig.firm)) }
  for l in sig.lines { s(inl(l)) }
})

/// The certificate of service (Fed. R. Civ. P. 5(b)), on a page of its own: the method, the persons served, the
/// date, and the filing user's signature. Kept whole.
#let certificate-block(cert, title, sig) = {
  pagebreak(weak: true)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    line-block(below: gap, align(center, strong[CERTIFICATE OF SERVICE]))
    body-par[#h(para-indent)The undersigned hereby certifies that a true and correct copy of the foregoing #inl(cert.at("document", default: title)) was #inl(cert.method) upon:]
    for (i, l) in cert.served_on.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, left: served-indent, inl(l)) }
    if cert.at("date", default: none) != none { line-block(above: gap)[DATE: #inl(cert.date)] }
    if sig.at("firm", default: none) != none { line-block(above: gap, left: sig-indent, inl(sig.firm)) }
    line-block(above: gap, left: sig-indent)[s/ #inl(sig.signer)]
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let tnwd-motion-brief(meta, body) = {
  set document(title: meta.at("title", default: "Memorandum"))
  // LR 7.1(a): letter paper, one-inch margins; the page number centered in the bottom margin, in a single-spaced
  // line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("¶¶ 12-13"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // A web address breaks only after its "://" and after a "/", ".", "-", "_", "?", "=", "&" or "#" inside it (not
  // after one that follows another): each piece in a box, the line may break between them. Left alone, typst also
  // splits a long address inside a word, which no other engine does. The docx filter marks the same places with a
  // zero-width space.
  show regex("[A-Za-z]+://\\S+"): it => {
    let s = it.text
    let head = s.match(regex("^[A-Za-z]+://"))
    let pieces = (head.text,)
    let cur = ""
    let cs = s.slice(head.end).clusters()
    let skip = false
    for (i, ch) in cs.enumerate() {
      cur += ch
      if not skip and ch in ("/", ".", "-", "_", "?", "=", "&", "#") and i < cs.len() - 1 {
        // the piece ends with the character after the separator's (Lua's gsub "(sep)(.)" consumes it)
        skip = true
      } else if skip {
        skip = false
        pieces.push(cur.slice(0, cur.len() - ch.len()))
        cur = ch
      }
    }
    pieces.push(cur)
    pieces.filter(p => p != "").map(p => box(p)).join()
  }

  // Footnotes: 12 pt (LR 7.1(b)), single-spaced (the entry sets its own leading: it does not inherit the body's);
  // the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // LibreOffice splits a note anywhere (it keeps no widow or orphan line in a footnote): so does typst here.
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  court-title(meta.at("court_division", default: none))
  block(above: pitch-body, below: 0pt, caption(meta.caption, meta.at("case_number", default: "")))
  // LR 7.2(a)(1): the memorandum is "so identified" by its title
  line-block(above: pitch-body, below: pitch-body, sticky: true, align(center, strong(inl(meta.title))))

  // The body: blank-line-separated chunks; a chunk that cites a footnote carries the footnote definitions with it.
  // Paragraphs are not numbered (a brief).
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  let chunks = chunks.filter(c => not c.starts-with("[^"))
  let with-notes(s) = if defs != none and s.contains("[^") { s + "\n\n" + defs } else { s }
  for (k, c) in chunks.enumerate() {
    // the last block stays with the signature block, so the signature never stands alone on a page
    let last = k == chunks.len() - 1
    if c.starts-with("##") {
      point-heading(c.replace(regex("^#+\\s*"), ""))
    } else if c.starts-with("#") {
      section-heading(c.replace(regex("^#+\\s*"), ""))
    } else if c.starts-with(">") {
      quote-block(c)
    } else {
      body-par(last: last)[#h(para-indent)#inl(with-notes(c))]
    }
  }

  signature-block(meta.signature, meta.at("date", default: none))
  if "certificate" in meta {
    certificate-block(meta.certificate, meta.at("title", default: "motion"), meta.signature)
  }
}
