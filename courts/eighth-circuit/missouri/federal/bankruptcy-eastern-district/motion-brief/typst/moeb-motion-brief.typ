// Motion (with an optional supporting memorandum) for the United States Bankruptcy Court, E.D. Missouri (moeb).
// Governing text: E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"
// (PDF fetched 2026-10-14 from https://www.moeb.uscourts.gov/sites/moeb/files/Local_Rules_Dec_1_2025.pdf; see ../README.md):
//   L.R. 9004(A): caption; top left the debtor, and for a motion the movant and respondent; top right the case
//   number with judge code, chapter, motion number, current hearing date, time and location, and the response date.
//   L.R. 9004(B): descriptive title of the relief sought.
//   L.R. 9004(C): letter paper, margins no less than 1 inch, one side, standard 12-point font, numbered paragraphs
//   (memoranda excepted), and no motion or memorandum over 15 pages without leave, exclusive of the signature
//   page, certificate of service and attachments.
//   L.R. 9004(D): every filing has a certificate of service stating who was served, the date, and the manner.
//   L.R. 9013-1(E): a memorandum of law is optional; if filed, it is filed with the motion or 7 days before hearing.
//   L.R. 9013-1(F): a consent motion's title must say so.
// Content-agnostic: every case word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")       // Vendored in fonts/. L.R. 9004(C) names no typeface; see README.md.
#let type-size = 12pt                  // L.R. 9004(C): standard 12-point font, headings, footnotes and footer included.
#let margin = 1in                      // L.R. 9004(C): margins no less than 1 inch.
#let para-indent = 0.5in               // First-line indent; the paragraph number's box after it; quotations both sides.
#let caption-left = 3.6in              // Width of the left (debtor, movant, respondent) column of the caption.
#let caption-gutter = 0.25in           // Between the left column and the case block.
#let caption-inset = 10pt              // The left column's text stands off its right rule.
#let caption-pad = 8pt                 // The left column's bottom rule stands off its last line.
#let right-inset = 0.1in               // The case block stands off the gutter.
#let sig-left = 3in                    // Signature grid: the "Date" column, a gutter, the signature column.
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt             // A single line: 1.15 x the type size (Word's single line in this face).
#let pitch-double = 2 * pitch-single   // Double spacing (27.6 pt, as in the filed exemplars).
#let note-gap = 6pt                    // Between two footnotes.
#let note-clearance = 7.8pt            // Between the text and the footnote rule: with note-gap, Word's separator line (13.8 pt).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Non-breaking spaces keep "11 U.S.C. § 548" together and "§ 548" on one line (the docx filter binds the same).
#let joins(s) = s.replace(" U.S.C.", "\u{00A0}U.S.C.").replace("U.S.C. §", "U.S.C.\u{00A0}§").replace("§ ", "§\u{00A0}")

/// Inline markdown (for names with *et al.*, section signs, and so on).
#let inl(s) = cmarker.render(joins(s), raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Footnote definitions (`[^key]: text`) are collected from the body. Each is attached to the paragraph that uses
/// its marker, because cmarker resolves a footnote only within the string it renders.
#let footnote-defs(body) = {
  let defs = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// The text of one paragraph with the definitions of the footnotes it cites appended.
#let attach-notes(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
  t + keys.map(k => {
    assert(k in defs, message: "moeb-motion-brief: footnote [^" + k + "] has no definition")
    "\n\n[^" + k + "]: " + joins(defs.at(k))
  }).join("")
}

// ---------------------------------------------------------------------------
// Caption and first page (L.R. 9004(A); Local Form 22)
// ---------------------------------------------------------------------------

/// The court's name (fixed, not case-specific): three single-spaced lines, centered and bold.
#let court-title() = for l in ("UNITED STATES BANKRUPTCY COURT", "EASTERN DISTRICT OF MISSOURI", "EASTERN DIVISION") {
  line-block(align(center, text(weight: "bold", l)))
}

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Top left (L.R. 9004(A)): the debtor, a single line, then the movant and respondent, each with its names and
    // designation, "v." between them. A "" line is a blank line.
    for l in meta.caption.debtor { line-block(if l == "" { "\u{00A0}" } else { inl(l) }) }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for (j, n) in p.names.enumerate() { line-block(above: if k == 0 and j == 0 { pitch-single } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    // Top right (L.R. 9004(A)): case number with judge code, chapter, motion number, hearing and response date.
    // A motion is filed before a motion number or hearing is assigned, so those lines appear only when the sample
    // supplies them.
    line-block(inl("Case No. " + meta.case_number))
    if "judge" in meta { line-block(inl(meta.judge)) }
    if "chapter" in meta { line-block(inl(meta.chapter)) }
    if meta.at("motion_number", default: "") != "" { line-block(inl("Motion No. " + meta.motion_number)) }
    if "hearing" in meta and meta.hearing != none { for h in meta.hearing { line-block(inl(h)) } }
    if meta.at("response_date", default: "") != "" { line-block(inl(meta.response_date)) }
  }),
))

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, quotations, unnumbered paragraphs
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent), centered, or numbered (L.R. 9004(C)): the
/// number in a box of the paragraph indent after the first-line indent, the text after it.
#let body-par(num, content, centered: false) = block(width: 100%, above: 0pt, below: 0pt, if centered {
  align(center, par(first-line-indent: 0pt, content))
} else if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Each blank-line-separated chunk is one of:
///   `# ...`, `## ...`   heading (level 1 centered caps; level 2 centered bold; level 3 bold italic)
///   `1. ...` or `- ...` list
///   `> ...`             quotation: single-spaced, indented half an inch on both sides, unnumbered
///   `%%...`             centered, unnumbered
///   `%...`              unnumbered paragraph (for WHEREFORE clauses)
///   `[^key]: ...`       footnote definition (attached to the paragraph that cites it)
///   anything else       numbered paragraph
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15. The last chunk is kept in one unbreakable block with the signature
/// (`tail`), so a signature never stands alone.
#let allegations(body, tail) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = attach-notes(joins(c.trim()), defs)
    let piece = if t.starts-with("#") or t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else if t.starts-with(">") {
      md(t)
    } else if t.starts-with("%%") {
      body-par(none, md(t.slice(2).trim()), centered: true)
    } else if t.starts-with("%") {
      body-par(none, md(t.slice(1).trim()))
    } else {
      n += 1
      body-par(n, md(t))
    }
    if i == chunks.len() - 1 { block(breakable: false, width: 100%, { piece; tail }) } else { piece }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

/// "Date" at the left, level with "Respectfully Submitted,"; the firm a single line below, "By:" a single line
/// below that, then the attorneys and the address lines.
#let signature-block(meta) = {
  let s = meta.signature
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block(inl("Date: " + s.date)),
    {
      line-block[Respectfully Submitted,]
      line-block(above: pitch-single, inl(s.firm))
      line-block(above: pitch-single, inl("By: " + s.by))
      for l in s.attorneys + s.lines { line-block(inl(l)) }
    },
  ))
}

/// The certificate of service (L.R. 9004(D)). Required: every filing must include one, or be accompanied by one.
/// It names each person served, the date, and the manner (CM/ECF or first-class mail). Single-spaced, a single line
/// between its parts (as the filed certificates); the heading stays with the first paragraph, and each paragraph
/// and each person served is kept whole.
#let certificate-block(meta) = {
  assert("certificate" in meta, message: "moeb-motion-brief: every motion needs a certificate of service (L.R. 9004(D))")
  let c = meta.certificate
  let one(above, body) = block(width: 100%, above: above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    body
  })
  block(width: 100%, above: pitch-double, below: 0pt, sticky: true, line-block(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))))
  for (k, p) in c.paragraphs.enumerate() {
    one(pitch-single, par(first-line-indent: (amount: para-indent, all: true), inl(p)))
  }
  for entry in c.at("served", default: ()) {
    one(pitch-single, pad(left: para-indent, for l in entry { line-block(inl(l)) }))
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block(inl("Date: " + c.date)),
    line-block(inl(c.signature)),
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let moeb-motion(meta, body) = {
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced), footnote marks at 58 %.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // Footnotes at the type size (L.R. 9004(C): standard 12-point font) in single line boxes, the mark, a space, the
  // note; a 0.5 pt rule a third of the way across.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Quotations: single-spaced, indented half an inch on both sides, a single line above and below.
  show quote.where(block: true): it => block(above: pitch-single, below: pitch-single, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    it.body
  }))

  // Headings at the body size and pitch: level 1 centered bold capitals; level 2 centered bold; level 3 bold
  // italic at the margin. No space of their own (the double pitch sets them off); sticky, so a heading never
  // ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  court-title()
  caption(meta)
  // The title (L.R. 9004(B)): bold capitals, centered, single-spaced; a single line below it.
  block(width: 100%, above: 0pt, below: pitch-single, line-block(align(center, text(weight: "bold", upper(inl(meta.title))))))
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body, signature-block(meta))
  certificate-block(meta)
}
