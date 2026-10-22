// U.S. District Court, Middle District of Tennessee: memorandum of law supporting a motion (Fed. R. Civ. P. 7(b), 12(b);
// M.D. Tenn. LR 7.01(a)(2), 7.03). The memorandum is one of the "motion and supporting memorandum" documents of LR 7.01(a)(2).
//
// Rule-driven and content-agnostic. Requirement IDs (TNMD-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman substitute, vendored (docs/FONTS.md)
#let type-size = 12pt                      // TNMD-FORM-002: at least 12-point type (LR 7.03(a)); footnotes too
#let page-margin = 1in                     // TNMD-FORM-001: one-inch margins (LR 7.03(a))
#let para-indent = 0.5in                   // first-line indent of body paragraphs (TNMD-MEMO-002)
#let heading-tab = 0.5in                   // a heading's typed label ("I.", "A.") in a box this wide, the text hanging after it
#let caption-left = 3.3in                  // party column of the caption
#let caption-marks = 0.3in                 // the column of ")" marks
#let designation-indent = 0.5in            // "Plaintiff," / "Defendants." under the party names (as filed)
#let signature-indent = 3.25in             // signature block starts at the middle of the page
#let service-indent = 0.5in                // the certificate's service entries

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                   // TNMD-FORM-003: double spacing (LR 7.03(a)), Word's double line at 12 pt (2 x 1.15 x 12 pt), the exemplar's pitch
#let pitch-single = 13.8pt                 // single lines (court name, caption, title, headings, signature, certificate entries, footnotes, page number): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                    // a blank single line
#let head-above = pitch-single             // a heading: a blank single line above ...
#let head-below = 6.9pt                    // ... and half of one below
#let sig-gap = 6.9pt                       // between the signer and the counsel lines
#let note-gap = 7pt                        // between footnotes
#let note-clearance = 7pt                  // between the text and the footnote rule: with the 7 pt gap, the room LibreOffice keeps above a note

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (italics, footnotes, etc.) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnmd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// A blank single line.
#let blank-line = block(width: 100%, height: pitch-single, above: 0pt, below: 0pt)

/// A body paragraph at the body pitch, first line half an inch in.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, [#h(para-indent)#content]))

// ---------------------------------------------------------------------------
// Court heading and caption (TNMD-CAP-001: Fed. R. Civ. P. 10(a), LR 7.03(a); TNMD-CONT-002: JURY DEMAND, LR 7.03(c))
// ---------------------------------------------------------------------------

/// One row per party line (names, a blank line, the designation, a blank line, "v.", a blank line, ...), a column of
/// ")" marks (one per line of text: a name can wrap), and on the right, line by line from the "v." row down:
/// "Case No.", a blank line, "JURY DEMAND", a blank line, the judges (LR 7.03(a): below the case number).
#let caption-block(meta) = context {
  let cap = need(meta, "caption")
  let left = ()
  for (i, p) in cap.parties.enumerate() {
    if i > 0 {
      left.push(none)
      left.push(([v.], 0pt, true))
      left.push(none)
    }
    left.push((inl(p.names), 0pt, false))
    left.push(none)
    left.push((emph(inl(p.designation)), designation-indent, false))
  }
  let v = if cap.parties.len() > 1 { left.position(l => l != none and l.at(2)) } else { 0 }

  let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "_" * 16 }
  let right = ([Case No. #case-no],)
  if meta.at("jury_demand", default: false) { right += (none, [JURY DEMAND]) }
  let judges = meta.at("judges", default: ())
  if judges.len() > 0 { right.push(none); right += judges.map(j => inl(j)) }

  // the lines each row takes, and the right column's lines from the "v." row on
  let cell(l) = if l == none { [] } else { line-block(left: l.at(1), l.at(0)) }
  let lines = left.map(l => if l == none { 1 } else {
    calc.max(1, int(calc.round(measure(width: caption-left, cell(l)).height / pitch-single)))
  })
  let total = lines.slice(v).sum()
  if total < right.len() { left += (none,) * (right.len() - total); lines += (1,) * (right.len() - total) }

  let cells = ()
  let at = 0
  for (k, l) in left.enumerate() {
    let n = lines.at(k)
    let r = ()
    if k >= v {
      for j in range(at, at + n) {
        r.push(if j < right.len() and right.at(j) != none { line-block(right.at(j)) } else { blank-line })
      }
      at += n
    }
    cells += (cell(l), range(n).map(_ => line-block[)]).join(), r.join())
  }
  grid(columns: (caption-left, caption-marks, 1fr), ..cells)
}

// ---------------------------------------------------------------------------
// Headings (typed labels: "I." at the margin, "A." half an inch in)
// ---------------------------------------------------------------------------

/// Level 1 centered bold; level 2 the label at the margin in a half-inch box, the text bold and underlined, hanging;
/// level 3 the same half an inch in, bold italic (as filed). Single-spaced, kept with what follows.
#let heading-block(level, s, above: head-above) = {
  let m = s.match(regex("^(\\S+\\.)\\s+"))
  let (lab, rest) = if m == none or level == 1 { (none, s) } else { (m.captures.at(0), s.slice(m.end)) }
  if level == 1 {
    line-block(above: above, below: head-below, sticky: true, align(center, strong(inl(s))))
  } else {
    let deco(c) = if level == 2 { underline(strong(c)) } else { strong(emph(c)) }
    line-block(above: above, below: head-below, sticky: true, left: if level >= 3 { heading-tab } else { 0pt },
      par(hanging-indent: heading-tab, [#box(width: heading-tab, deco(if lab == none { [] } else { lab }))#deco(inl(rest))]))
  }
}

// ---------------------------------------------------------------------------
// Signature and certificate of service (Fed. R. Civ. P. 11(a); LR 7.03(a); LR 5.01)
// ---------------------------------------------------------------------------

/// At the middle of the page: "Respectfully submitted," (a signature; a certificate's signer has none), a blank line,
/// the signer, half a line, the typed name and counsel lines.
#let signature-lines(sig, opening: true) = {
  let s(above: 0pt, body) = line-block(above: above, left: signature-indent, body)
  if opening { s[Respectfully submitted,] }
  s(above: if opening { gap } else { 0pt }, inl(sig.signer))
  for (i, l) in sig.lines.enumerate() { s(above: if i == 0 { sig-gap } else { 0pt }, inl(l)) }
}

/// The certificate's service entries, single-spaced, a blank line apart, each kept whole; then its signer.
#let service-block(cert) = {
  for s in cert.service {
    block(width: 100%, breakable: false, above: gap, below: 0pt, for l in s { line-block(left: service-indent, inl(l)) })
  }
  block(width: 100%, breakable: false, above: gap, below: 0pt, signature-lines(cert, opening: false))
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let tnmd-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // TNMD-FORM-004: every page numbered at the bottom, centered, in a single line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 26, 84"), as a single one does in xengine (a no-break space: xengine
  // would box the inner "¶ 26" again).
  show regex("[§¶]{2} \\S+"): it => box(it.text.replace(" ", "\u{a0}"))

  // Footnotes: 12 pt, single-spaced (TNMD-FORM-003; the entry sets its own leading: it does not inherit the body's);
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

  // Court name and division, each line its own block (no forced breaks).
  line-block(align(center)[IN THE UNITED STATES DISTRICT COURT])
  line-block(align(center)[FOR THE MIDDLE DISTRICT OF TENNESSEE])
  line-block(below: pitch-body, align(center, inl(need(meta, "division"))))

  caption-block(meta)

  line-block(above: pitch-body, below: gap, sticky: true, align(center, strong(inl(need(meta, "title")))))

  // Body: blank-line-separated chunks; "#" chunks are headings, "<!-- signature -->" and "<!-- service -->" place the
  // signature block and the certificate's service list; a heading after the signature (the certificate of service)
  // opens a new page. A chunk that cites a footnote carries the footnote definitions with it. The paragraph before
  // the signature is kept with it on one page.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  let chunks = chunks.filter(c => not c.starts-with("[^"))
  let with-notes(s) = if defs != none and s.contains("[^") { s + "\n\n" + defs } else { s }
  let after-sig = false
  for (k, c) in chunks.enumerate() {
    let next = chunks.at(k + 1, default: none)
    if c == "<!-- signature -->" {
      after-sig = true
    } else if c == "<!-- service -->" {
      service-block(need(meta, "certificate"))
    } else if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      if after-sig {
        pagebreak(weak: true)
        heading-block(level, c.replace(regex("^#+\\s*"), ""), above: 0pt)
        after-sig = false
      } else {
        heading-block(level, c.replace(regex("^#+\\s*"), ""))
      }
    } else if next == "<!-- signature -->" {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        body-par(inl(with-notes(c)))
        block(width: 100%, above: gap, below: 0pt, signature-lines(need(meta, "signature")))
      })
    } else {
      body-par(inl(with-notes(c)))
    }
  }
}
