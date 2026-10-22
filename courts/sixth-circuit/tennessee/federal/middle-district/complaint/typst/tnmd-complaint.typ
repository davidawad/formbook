// U.S. District Court, Middle District of Tennessee: complaint (Fed. R. Civ. P. 8, 10; M.D. Tenn. LR 3.01, 3.03, 7.03).
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
#let type-size = 12pt                      // TNMD-FORM-002: at least 12-point type (LR 7.03(a)).
#let page-margin = 1in                     // TNMD-FORM-001: one-inch margins (LR 7.03(a)).
#let para-indent = 0.5in                   // first-line indent; a paragraph's number stands in a box this wide after it (TNMD-COMP-002)
#let item-indent = 0.5in                   // prayer items: the letter half an inch in ...
#let item-label = 0.5in                    // ... in a box this wide; the text hangs after it (TNMD-COMP-004)
#let caption-left = 3.3in                  // party column of the caption
#let caption-marks = 0.3in                 // the column of ")" marks
#let designation-indent = 1in              // "Plaintiff," / "Defendants." under the party names
#let signature-indent = 3.25in             // signature block starts at the middle of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                   // TNMD-FORM-003: double spacing (LR 7.03(a)), Word's double line at 12 pt (2 x 1.15 x 12 pt), the exemplar's pitch
#let pitch-single = 13.8pt                 // single lines (court name, caption, title, headings, signature, page number): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                    // a blank single line
#let head-above = pitch-single             // a heading (or a stack of count headings): a blank single line above ...
#let head-below = 6.9pt                    // ... and half of one below
#let sig-gap = 6.9pt                       // between the signer and the counsel lines

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnmd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// A paragraph at the body pitch; `last` keeps it whole and with the signature block after it.
#let body-par(last: false, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: last,
  breakable: not last, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Caption (TNMD-COMP-001: Fed. R. Civ. P. 10(a); TNMD-COMP-005: JURY DEMAND legend, LR 7.03(c))
// ---------------------------------------------------------------------------

/// One row per party line (names, a blank line, the designation, a blank line, "v.", a blank line, ...), a column of
/// ")" marks (one per line of text: a name can wrap), and on the right, from the "v." row down, one line per row:
/// "Case No.", a blank line and "JURY DEMAND" (opposite the style of the case), a blank line and the judges.
#let caption-block(meta) = {
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
    left.push((inl(p.designation), designation-indent, false))
  }
  let v = if cap.parties.len() > 1 { left.position(l => l != none and l.at(2)) } else { 0 }

  let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "_" * 16 }
  let right = ([Case No. #case-no],)
  if meta.at("jury_demand", default: false) { right += (none, [JURY DEMAND]) }
  let judges = meta.at("judges", default: ())
  if judges.len() > 0 { right.push(none); right += judges.map(j => inl(j)) }
  // the right column may run past the party lines: blank party rows carry it on
  while left.len() < v + right.len() { left.push(none) }

  let cells = ()
  for (k, l) in left.enumerate() {
    let text-cell = if l == none { [] } else { line-block(left: l.at(1), l.at(0)) }
    let marks = context {
      let n = if l == none { 1 } else { calc.max(1, int(calc.round(measure(width: caption-left, text-cell).height / pitch-single))) }
      for _ in range(n) { line-block[)] }
    }
    let r = if k >= v and k - v < right.len() and right.at(k - v) != none { line-block(right.at(k - v)) } else { [] }
    cells += (text-cell, marks, r)
  }
  grid(columns: (caption-left, caption-marks, 1fr), ..cells)
}

// ---------------------------------------------------------------------------
// Signature block (TNMD-COMP-006: Fed. R. Civ. P. 11(a); LR 7.03(a))
// ---------------------------------------------------------------------------

/// At the middle of the page: the date or "Respectfully submitted,", a blank line, the signer, half a line, the
/// typed name and counsel lines. Kept on one page.
#let signature-block(sig) = {
  let s(above: 0pt, body) = line-block(above: above, left: signature-indent, body)
  block(width: 100%, breakable: false, above: gap, below: 0pt, {
    s(if "date" in sig { inl(sig.date) } else [Respectfully submitted,])
    s(above: gap, inl(sig.signer))
    for (i, l) in sig.lines.enumerate() { s(above: if i == 0 { sig-gap } else { 0pt }, inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let tnmd-complaint(meta, body) = {
  set document(title: need(meta, "title"))
  // TNMD-FORM-004: every page numbered at the bottom, centered, in a single line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  // (with a no-break space: xengine would box the inner "§ 106" again, and pdftotext reads the bold pair apart)
  show regex("[§¶]{2} \\S+"): it => box(it.text.replace(" ", "\u{a0}"))

  // Court name and division, each line its own block (no forced breaks).
  line-block(align(center, strong[IN THE UNITED STATES DISTRICT COURT]))
  line-block(align(center, strong[FOR THE MIDDLE DISTRICT OF TENNESSEE]))
  line-block(below: pitch-body, align(center, strong(inl(need(meta, "division")))))

  caption-block(meta)

  line-block(above: pitch-body, sticky: true, align(center, strong(inl(need(meta, "title")))))

  // Unnumbered lead-in paragraph (the opening paragraph before paragraph 1).
  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }

  // Body: blank-line-separated chunks. "#" chunks are headings; "1. " chunks are lettered prayer items; "~ " chunks
  // are unnumbered paragraphs; any other chunk is a numbered paragraph (Fed. R. Civ. P. 10(b)), counted here.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let is-head(c) = c != none and c.starts-with("#")
  let n = 0
  for (k, c) in chunks.enumerate() {
    let last = k == chunks.len() - 1
    let prev = if k > 0 { chunks.at(k - 1) } else { none }
    let next = if not last { chunks.at(k + 1) } else { none }
    if is-head(c) {
      // single-spaced, bold, centered, kept with what follows; a stack of headings (a count) has no space inside
      line-block(above: if is-head(prev) { 0pt } else { head-above }, below: if is-head(next) { 0pt } else { head-below },
        sticky: true, align(center, strong(inl(c.replace(regex("^#+\\s*"), "")))))
    } else if c.starts-with("1. ") {
      let lines = c.split("\n").map(l => l.trim()).filter(l => l != "")
      for (i, l) in lines.enumerate() {
        let is-last = last and i == lines.len() - 1
        block(width: 100%, above: 0pt, below: 0pt, sticky: is-last, breakable: not is-last,
          par(hanging-indent: item-indent + item-label, first-line-indent: 0pt,
            [#h(item-indent)#box(width: item-label, numbering("A.", i + 1))#inl(l.replace(regex("^\\d+\\.\\s+"), ""))]))
      }
    } else if c.starts-with("~ ") {
      body-par(last: last)[#h(para-indent)#inl(c.slice(2))]
    } else {
      n += 1
      body-par(last: last)[#h(para-indent)#box(width: para-indent)[#n.]#inl(c)]
    }
  }

  signature-block(need(meta, "signature"))
}
