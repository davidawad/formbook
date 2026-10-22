// United States Court of Federal Claims: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CFC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Vendored in /fonts (Liberation Serif: Times New Roman metrics).
#let type-size = 12pt                      // CFC-FORM-002: text and footnotes no smaller than 12 point.
#let page-margin = 1in                     // CFC-FORM-003: margins not less than 1 inch on each side.
#let para-indent = 0.5in                   // Style: first-line indent of numbered paragraphs.
#let block-indent = 0.5in                  // Style: lists (prayer for relief) and quoted material.
#let caption-gutter = 0.25in               // Style: space between the two caption columns.
#let caption-left = 3.4in                  // Style: width of the party block in the caption.
#let designation-indent = 1.5in            // Style: "Plaintiff," / "Defendant." step in under the names.
#let sig-col = 2.25in                      // Style: width of the signature column, at the right margin.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt                 // a single line: 1.15 x the type size (the Word convention).
#let pitch-double = 2 * pitch-single       // CFC-FORM-004: the text is double spaced.
#let heading-above = pitch-double          // a section heading: one double line above it ...
#let heading-below = pitch-single          // ... and a single line below (a heading takes two body lines).
#let court-below = 18pt                    // caption: court name to the party block
#let title-above = 24pt                    // caption: party block to the title
#let title-below = 12pt                    // caption: title to the text
#let caption-pad = pitch-single / 2        // caption: the rules stand half a line off the text

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("uscfc-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("uscfc-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// A signature line: the signer over a rule that runs to the end of the column (the rule takes no room).
#let signed(name) = box(width: 100%, stroke: (bottom: 0.5pt + black), outset: (bottom: 1pt))[/s/ #name]

// ---------------------------------------------------------------------------
// Caption (RCFC 10(a), 7(a) designation, 5.5(h) bid protest, 5.5(g) judge not required)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  // RCFC 10(a): the caption has the court's name, a title, a file number.
  line-block(align(center, text(weight: "bold", upper(need(meta, "court")))))
  // RCFC 5.5(h): "Bid Protest" directly below the name of the court, in every filing.
  if meta.at("bid_protest", default: false) {
    line-block(align(center, text(weight: "bold", "Bid Protest")))
  }

  // Left: the parties, each side's names then its designation (RCFC 7(a)).
  // Right: the file number, blank for the clerk where none is assigned yet.
  let sides = need(meta, "caption")
  let party-block = {
    for (i, side) in sides.enumerate() {
      if i > 0 { line-block(above: pitch-single, below: pitch-single, align(center, [v.])) }
      for name in side.names { line-block(inl(name)) }
      line-block(above: pitch-single, pad(left: designation-indent, inl(side.designation)))
    }
  }
  let blank = box(width: 1.2in, stroke: (bottom: 0.5pt + black))
  block(above: court-below, below: 0pt, grid(
    columns: (caption-left, 1fr),
    gutter: caption-gutter,
    block(
      width: 100%,
      inset: (right: caption-gutter, bottom: caption-pad),
      stroke: (right: 0.7pt + black, bottom: 0.7pt + black),
      party-block,
    ),
    align(bottom + left, pad(left: 0.2in, bottom: caption-pad, {
      line-block[Case No. #if meta.at("file_number", default: none) != none [#meta.file_number] else [#blank]]
      line-block[Judge #blank]
    })),
  ))
  line-block(above: title-above, below: title-below, align(center, text(weight: "bold", upper(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// (RCFC 5.5(d)(1) original signature; 5.5(e) date; 5.5(f) e-mail and telephone below
// the signature line; 5.5(g) no judge name is required in a complaint.)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(
      columns: (1fr, sig-col),
      line-block[Dated: #need(meta, "date")],
      {
        line-block[Respectfully submitted,]
        line-block(above: pitch-double, signed(need(sig, "signer")))
        line-block(need(sig, "signer"))
        for line in sig.at("lines", default: ()) { line-block(inl(line)) }
        line-block[Telephone: #need(sig, "phone")]
        line-block[E-mail: #need(sig, "email")]
      },
    )
  })
}

#let certificate-of-service(meta) = {
  pagebreak(weak: true)
  {
    set text(..edges(pitch-single))
    line-block(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  }
  // CFC-FORM-004: the certificate text is text, so it stays double spaced (body pitch).
  block(above: pitch-double, below: 0pt, par(first-line-indent: para-indent)[
    I hereby certify that on #need(meta, "date"), I caused a copy of the #lower(need(meta, "title")) to be served on all parties via the Court's electronic case filing system.
  ])
  // Same column as the signature block of the complaint.
  block(above: pitch-double, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(columns: (1fr, sig-col), [], {
      line-block(signed(need(need(meta, "signature"), "signer")))
      line-block(need(need(meta, "signature"), "signer"))
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let uscfc-complaint(meta, body) = {
  set document(title: need(meta, "title") + " (" + need(meta, "court") + ")")

  // CFC-FORM-005: every page numbered, bottom centre; the number in a single-spaced line box, so it sits at the
  // same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,                   // CFC-FORM-003
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )

  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, ragged right, no kerning, ligatures or
  // hyphenation, line boxes of the body pitch (CFC-FORM-004: double spaced), footnote marks at 58 %, a section
  // sign kept with its number. The prayer's lists keep typst's own layout (list-indent: none).
  show: xengine.with(pitch: pitch-double, list-indent: none)

  // Headings are centred and bold (section), or bold and left-aligned (sub-section), single spaced.
  // Neither is numbered: the complaint's own paragraph numbers are the author's.
  // Sticky: a heading never ends a page; it moves with the paragraph that follows it.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))   // headings at the body size, as the title.
    set par(first-line-indent: 0pt)
    let b = if it.level <= 2 { align(center, text(weight: "bold", upper(it.body))) } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: heading-above, below: heading-below, b)
  }

  // Prayer for relief: lettered and roman items (the author types the labels), hanging at the block indent.
  set list(marker: none, indent: block-indent, body-indent: 0.5em, spacing: 0pt)
  show list: set par(first-line-indent: 0pt)

  // Quoted material and footnotes are single spaced (CFC-FORM-004) and at least 12 point.
  show quote.where(block: true): it => block(above: pitch-single, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: block-indent, it.body)
  })
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: 6pt, clearance: 12pt, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  if meta.at("certificate_of_service", default: false) {
    certificate-of-service(meta)
  }
}
