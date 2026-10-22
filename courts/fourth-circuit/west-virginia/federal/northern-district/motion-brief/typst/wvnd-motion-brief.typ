// Memorandum of law supporting a motion to dismiss, for the U.S. District Court for the Northern
// District of West Virginia (wvnd). Rules: LR Civ P 7.02(a) (memorandum: not more than 25 pages,
// double spaced, 8 1/2 x 11, one-inch margins on all four sides, page numbers only in the margins,
// Times New Roman, Courier New or Arial at 12 point proportional, footnotes and indented quotations
// may be single spaced, footnotes at least 11 point proportional); LR Civ P 12.02 (a motion to dismiss
// is designated prominently and filed as a separate pleading; the memorandum is its own paper);
// LR Gen P 5.03(c) (signature "s/ name"); LR Gen P 5.06(e) (certificate of service on every filing,
// stating who was served and how); Fed. R. Civ. P. 11(a) (signer's address, e-mail, telephone).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR Civ P 7.02(a) names Times New Roman, Courier New or Arial; Liberation Serif is the vendored, metric-compatible Times New Roman
#let type-size = 12pt              // LR Civ P 7.02(a): 12 point proportionally spaced type
#let note-size = 11pt              // LR Civ P 7.02(a): footnote text no smaller than 11 point proportional
#let margin = 1in                  // LR Civ P 7.02(a): one inch on all four sides, 8 1/2 by 11 inch paper; page numbers only in the margin
#let page-limit = 25               // LR Civ P 7.02(a): a supporting memorandum of not more than 25 pages
#let para-indent = 0.5in           // first-line indent of body paragraphs; the heading labels' box
#let caption-left = 3.4in          // width of the party column of the caption
#let caption-paren = 0.3in         // the ")" column of the caption
#let served-indent = 0.5in         // the certificate's list of counsel served
#let sig-left = 3.25in             // the signature block starts at the middle of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt             // LR Civ P 7.02(a) double spacing: a 24 pt pitch at 12 pt (headings, titles, court title too)
#let pitch-single = 13.8pt         // single spacing (caption rows, signature, served counsel, page number): Word's single line, 1.15 x 12 pt
#let pitch-note = 12.65pt          // footnotes single spaced at 11 pt (LR Civ P 7.02(a)): Word's single line, 1.15 x 11 pt
#let cover-gap = 12pt              // the court title to the caption, the caption to the title
#let note-gap = 6pt                // between two footnotes
#let note-clearance = 12.6pt       // the body text to the footnote rule (where LibreOffice sets Word's)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, links, footnote marks). Smart punctuation keeps the author's characters.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split the body into blank-line-separated chunks.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// Footnote definitions ("[^key]: text") are set aside and attached to the chunk that cites them,
/// because cmarker resolves a footnote only inside the markdown that contains its definition.
#let body-chunks(body) = {
  let defs = (:)
  let out = ()
  for c in chunks-of(body) {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { defs.insert(m.captures.at(0), c) } else { out.push(c) }
  }
  out.map(c => {
    let keys = c.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    let extra = keys.filter(k => k in defs).map(k => defs.at(k))
    if extra.len() > 0 { c + "\n\n" + extra.join("\n\n") } else { c }
  })
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: left, body)
})

/// A line or paragraph at the body pitch.
#let body-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, { set par(first-line-indent: 0pt); body })

// ---------------------------------------------------------------------------
// Caption (LR Civ P 7.02 does not set it; the court's papers use this court title and a ")" column)
// ---------------------------------------------------------------------------

/// Court title, then the caption: every row is one single-spaced line, so the ")" column lines up with the party
/// names; the case number stands on row `case_row`.
#let caption(meta) = {
  let title = ("UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF WEST VIRGINIA")
  if "division" in meta { title.push(meta.division) }
  for l in title { body-block(align(center, l)) }
  let case-row = meta.caption.at("case_row", default: 0)
  let cells = ()
  for (i, item) in meta.caption.lines.enumerate() {
    let r = if type(item) == str { (text: item) } else { item }
    cells.push(line-block(left: r.at("indent", default: 0.0) * 1in, r.text))
    cells.push(line-block[)])
    cells.push(line-block(if i == case-row { "No. " + meta.case_number } else { [] }))
  }
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (caption-left, caption-paren, 1fr),
    rows: (pitch-single,) * meta.caption.lines.len(),
    ..cells,
  ))
}

/// A centered bold title at the body pitch (the brief's title, the certificate's heading).
#let title-block(t) = body-block(above: cover-gap, sticky: true, align(center, text(weight: "bold", t)))

/// The signature block, after the conclusion (LR Gen P 5.03(c); Fed. R. Civ. P. 11(a)), kept on one page.
#let signature-block(meta) = {
  let sig = meta.signature
  assert(sig.lines.any(l => l.contains("@")), message: "wvnd-motion-brief: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(sig.lines.any(l => l.match(regex("\\(?\\d{3}\\)?[ .-]?\\d{3}[ .-]?\\d{4}")) != none), message: "wvnd-motion-brief: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    body-block[DATED: #meta.date]
    body-block(above: pitch-body, pad(left: sig-left)[Respectfully submitted,])
    line-block(above: pitch-body, left: sig-left, "s/ " + sig.signer)
    for (i, l) in sig.lines.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-left, inl(l)) }
  })
}

/// The certificate of service (LR Gen P 5.06(e)): on its own page, with the caption repeated.
#let certificate(meta) = {
  let c = meta.certificate_of_service
  assert("served" in c, message: "wvnd-motion-brief: the certificate needs served (who was served, LR Gen P 5.06(e))")
  pagebreak()
  caption(meta)
  [#title-block[CERTIFICATE OF SERVICE] <wvnd-cert>]
  body-block[#h(para-indent)I hereby certify that on #c.date, I electronically filed the foregoing with the Clerk of the District Court using the CM/ECF system, which will send notification of such filing electronically to the following counsel of record, who are served by that means:]
  for s in c.served { line-block(above: pitch-single, left: served-indent, inl(s)) }
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block(left: sig-left, "s/ " + c.signer)
    line-block(above: pitch-single, left: sig-left, inl(c.role))
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let wvnd-motion-brief(meta, body) = {
  assert("case_number" in meta, message: "wvnd-motion-brief: frontmatter needs case_number")
  assert("caption" in meta, message: "wvnd-motion-brief: frontmatter needs caption (lines and case_row)")
  assert("brief_title" in meta, message: "wvnd-motion-brief: frontmatter needs brief_title")
  assert("signature" in meta, message: "wvnd-motion-brief: frontmatter needs signature")
  assert("certificate_of_service" in meta, message: "wvnd-motion-brief: frontmatter needs certificate_of_service")

  // LR Civ P 7.02(a): letter paper, one-inch margins, the page number centered in the bottom margin, in a single-
  // spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("¶¶ 7–8"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Footnotes: at least 11 point, single spaced (LR Civ P 7.02(a)): the mark, a space, the note (Word's footnote
  // layout), note-gap between notes.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }

  caption(meta)
  title-block(inl(meta.brief_title))

  // Headings: level 1 centered bold underlined; level 2 "I." in a half-inch box, bold; level 3 "A." half an inch
  // in, bold; level 4 "1." an inch in, italic; the text hangs after the label. Each restarts under the one above.
  let (h2, h3, h4) = (0, 0, 0)
  for c in body-chunks(body) {
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      let t = inl(c.replace(regex("^#+\\s*"), ""))
      let head = if level == 1 {
        (h2, h3, h4) = (0, 0, 0)
        align(center, text(weight: "bold", underline(t)))
      } else {
        let (lab, at, style) = if level == 2 {
          h2 += 1
          (h3, h4) = (0, 0)
          (numbering("I.", h2), 0pt, (weight: "bold"))
        } else if level == 3 {
          h3 += 1
          h4 = 0
          (numbering("A.", h3), para-indent, (weight: "bold"))
        } else {
          h4 += 1
          (numbering("1.", h4), 2 * para-indent, (style: "italic"))
        }
        par(hanging-indent: at + para-indent, [#h(at)#box(width: para-indent, lab)#text(..style, t)])
      }
      body-block(sticky: true, head)
    } else {
      body-block[#h(para-indent)#inl(c)]
    }
  }

  signature-block(meta)

  certificate(meta)

  // LR Civ P 7.02(a): the memorandum (everything before the certificate of service) is at most 25 pages.
  context {
    let pg = counter(page).at(query(<wvnd-cert>).first().location()).first()
    assert(pg - 1 <= page-limit, message: "wvnd-motion-brief: the memorandum runs " + str(pg - 1) + " pages; LR Civ P 7.02(a) allows " + str(page-limit) + " without leave")
  }
}
