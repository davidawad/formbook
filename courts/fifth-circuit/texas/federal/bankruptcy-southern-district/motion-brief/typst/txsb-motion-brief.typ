// Motion with integrated memorandum, United States Bankruptcy Court, Southern District of Texas (txsb).
// Rules (see ../README.md): FRBP 9004(a)-(b) (legibility, caption), FRBP 9013 (written motion stating its
// grounds and the relief), FRCP 10(b) (numbered paragraphs), BLR 7007-1 and 9013-1 (motions in adversary
// proceedings: title, the notice below the title, emergency motions, hearing, certificate of service, proposed
// order), LR10.1 (caption), LR10.2 (8 1/2 x 11, double spaced, paginated).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no typeface is set by the S.D. Tex. rules; Times New Roman, the exemplar's face (docs/FONTS.md)
#let type-size = 12pt                   // no point size is set by the S.D. Tex. rules; 12 pt is the usual minimum
#let note-size = 10pt                   // the debtor footnote
#let page-w = 8.5in                     // LR10.2: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // not set by the rules; a 1 inch convention (see README.md)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number's box after it
#let item-indent = 0.5in                // lettered items: the letter half an inch in
#let item-label = 0.4in                 // ... in a box of this width, the text hanging after it
#let caption-left = 3.25in              // width of the party column of the caption; the certificate's signer column
#let caption-gutter = 0.25in            // between the party column and the case block
#let caption-inset = 12pt               // the party column's text stands off its right rule
#let caption-pad = 10pt                 // the party column's bottom rule stands off its last line
#let right-inset = 0.1in                // the case block stands off the gutter
#let designation-indent = 1.25in        // "Debtor.", "Plaintiff,", "Defendant"
#let versus-indent = 0.5in              // "v."
#let notice-gap = 6pt                   // between the paragraphs of the BLR 9013-1 notice
#let note-gap = 6pt                     // between two footnotes
#let note-clearance = 7.8pt             // between the text and the footnote rule: with note-gap, Word's separator line (13.8 pt)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // LR10.2 double spacing: twice the 12 pt type size (the template's pitch)
#let pitch-single = 13.8pt              // caption, title, notice, signature and footer lines: 1.15 x the type size
#let pitch-note = 11.5pt                // the footnote: 1.15 x its size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (lead-in, body).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. Caption, notice and
/// signature text is set as written (no markdown).
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

// ---------------------------------------------------------------------------
// Cover: court, division, caption, title
// ---------------------------------------------------------------------------

/// Right column of the caption: chapter, case number, adversary number; "" is a blank line.
#let right-rows(meta) = {
  let rows = (meta.chapter, "", meta.case_number)
  if "joint_admin" in meta { rows.push(meta.joint_admin) }
  rows + ("", "", meta.adversary_number)
}

#let caption(meta) = {
  let c = meta.caption
  block(width: 100%, above: pitch-single, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
      line-block("In re:")
      // The debtor names, the debtor footnote (a page-foot note) on the last one.
      for (i, n) in c.debtor_names.enumerate() {
        let last = i == c.debtor_names.len() - 1
        line-block(if last and "debtor_footnote" in c { [#n#footnote(c.debtor_footnote)] } else { n })
      }
      line-block(indent: designation-indent, c.debtor_designation)
      for (i, n) in c.plaintiff_names.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, n) }
      line-block(indent: designation-indent, c.plaintiff_designation)
      line-block(indent: versus-indent, "v.")
      for n in c.defendant_names { line-block(n) }
      line-block(indent: designation-indent, c.defendant_designation)
    }),
    pad(left: right-inset, for r in right-rows(meta) { line-block(if r == "" { [~] } else { r }) }),
  ))
}

#let cover(meta) = {
  for l in ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS", upper(meta.division)) {
    line-block(align(center, text(weight: "bold", l)))
  }
  caption(meta)
  line-block(above: pitch-single, below: pitch-single, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// BLR 9013-1 notices. The text of the rule is fixed here; the case words come from the sample.
// ---------------------------------------------------------------------------

/// BLR 9013-1(b): required immediately below the title of every pleading that seeks an order (verbatim).
#let negative-notice = (
  "This motion seeks an order that may adversely affect you. If you oppose the motion, you should immediately contact the moving party to resolve the dispute. If you and the moving party cannot agree, you must file a response and send a copy to the moving party. You must file and serve your response within 21 days of the date this was served on you. Your response must state why the motion should not be granted. If you do not file a timely response, the relief may be granted without further notice to you. If you oppose the motion and have not reached an agreement, you must attend the hearing. Unless the parties agree otherwise, the court may consider evidence at the hearing and may decide the motion at the hearing.",
  "Represented parties should act through their attorney.",
)

/// BLR 9013-1(i): added to the notice of an emergency motion, which must also have "Emergency" in its title (verbatim).
#let emergency-notice = "Emergency relief has been requested. If the Court considers the motion on an emergency basis, then you will have less than 21 days to answer. If you object to the requested relief or if you believe that the emergency consideration is not warranted, you should file an immediate response."

/// The notice paragraphs: BLR 9013-1(b) always; BLR 9013-1(i) for an emergency motion; BLR 9013-1(c) hearing
/// line when the judge's web page allows self-calendaring.
#let notice-paragraphs(meta) = {
  let ps = negative-notice
  if "emergency" in meta and meta.emergency { ps += (meta.relief_by, emergency-notice) }
  if "hearing" in meta {
    let h = meta.hearing
    ps.push("There will be a hearing on this motion on " + h.date + " at " + h.time + " in courtroom " + h.courtroom + ", " + h.address + ".")
  }
  ps
}

/// The notice block: single spaced, its paragraphs a little apart, a blank single line below it.
#let notice-block(meta) = {
  let ps = notice-paragraphs(meta)
  for (i, p) in ps.enumerate() {
    line-block(above: if i == 0 { 0pt } else { notice-gap }, below: if i == ps.len() - 1 { pitch-single } else { 0pt }, p)
  }
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (FRCP 10(b): the number in a
/// box of the paragraph indent after the first-line indent, the text after it). `keep`: kept whole on the page of
/// the block after it (the last paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Numbered paragraphs (FRCP 10(b)). Each blank-line-separated chunk that is neither a heading, a list nor a ">"
/// chunk is one numbered paragraph; headings and lists are not numbered. Numbering is applied per chunk, not with
/// a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let n = 0
  let chunks = body-chunks(body)
  for (i, c) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if c.starts-with("#") {
      md(c)
    } else if c.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A list: lettered (a), (b), ... by the template, the letter half an inch in, the text hanging after it.
      pad(left: item-indent, md(c))
    } else if c.starts-with(">") {
      // An unnumbered paragraph (a WHEREFORE or prayer clause the filing does not number): markdown "> text".
      body-par(none, inl(c.slice(1).trim()), keep: last)
    } else {
      n += 1
      body-par(n, inl(c), keep: last)
    }
  }
}

/// "Dated:" at the left; "Respectfully submitted," and the first signing block at the right, a blank single line
/// below the last paragraph; each further block at the signature column, a single line apart around "-and-". Each
/// part is kept whole on one page (a page may fall between two signing blocks, as in a filed motion).
#let signature(meta) = {
  let blocks = meta.signature.blocks
  let lines(b) = for (i, l) in b.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, l) }
  block(breakable: false, width: 100%, above: pitch-single, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    line-block([Dated: #meta.dated]),
    { line-block[Respectfully submitted,]; lines(blocks.first()) },
  ))
  for b in blocks.slice(1) {
    block(breakable: false, width: 100%, above: pitch-single, below: 0pt, pad(left: caption-left + caption-gutter, {
      line-block("-and-")
      lines(b)
    }))
  }
}

/// BLR 9013-1(f): certificate of service, filed with the motion. The wording is the ECF service form; the date
/// and signer come from the sample. A blank double line above it; the heading and the statement at the double
/// pitch, the signer's lines a single line below at the signature column. It never breaks across a page.
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, text(weight: "bold")[CERTIFICATE OF SERVICE])))
    body-par(none, [I certify that on #c.date, I caused a copy of the foregoing document to be served by the Electronic Case Filing System for the United States Bankruptcy Court for the Southern District of Texas.])
    for (i, l) in c.signature.enumerate() {
      line-block(above: if i == 0 { pitch-single } else { 0pt }, indent: caption-left + caption-gutter, l)
    }
  })
}

#let txsb-motion-brief(meta, body) = {
  // Page numbers centered, arabic, on every page (LR10.2 "paginated"); the number in a single-spaced line box, so
  // it sits at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced), footnote marks at 58 %; lists as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  set enum(numbering: "(a)")
  // The footnote at its size in single line boxes: the mark, a space, the note; a 0.5 pt rule a third of the way
  // across.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body size and pitch, as written: level 1 and 2 centered bold; level 3 bold at the margin
  // (A., B., ...). No space of their own (the double pitch sets them off); sticky, so a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level <= 2 { align(center, text(weight: "bold", it.body)) } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  cover(meta)
  notice-block(meta)

  // Unnumbered lead-in paragraph, if the filing has one.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  allegations(body)
  signature(meta)
  certificate(meta)
}
