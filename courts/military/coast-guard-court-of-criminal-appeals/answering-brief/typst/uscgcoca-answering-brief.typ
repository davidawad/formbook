// uscgcoca answering brief: the United States' "Answer to Appellant's Assignments of Error".
//
// Governing rules: United States Coast Guard Rules of Appellate Procedure, Rev. 03/25 (published with the
// Joint Rules of Appellate Procedure, eff. 27 May 2024), read 2026-10-16 from the Wayback capture
// https://web.archive.org/web/20250428115614id_/https://www.uscg.mil/Portals/0/Headquarters/Legal/cca/CGCCA%20Rules%20of%20Appellate%20Procedure%20with%20JRAP%20(March%202025).pdf
//   Rule 17.1: proportional type such as Times New Roman, at least 12-point, at least 15-point spacing,
//              8.5 x 11 in white paper, margins at least one inch on all four sides.
//   Rule 17.2(a): Statement of the Case (with jurisdiction), Assignments of Error or Issues Presented,
//              Statement of Facts, Argument (standard of review, contentions, authority, relief),
//              Certificate of Service.
//   Rule 17.3: TOC/TOA and summary of argument over 30 pages; 20,000-word limit; a certificate that the
//              word count complies (index, tables and certificates excluded).
//   Rule 14:   signature with name, grade, email address and capacity.
// Caption layout (two columns, "TO THE HONORABLE, THE JUDGES ..." line) follows the filed exemplars
// (US v. Steen, Dkt. 1464, 2019); the rules prescribe no caption form.
// Times New Roman is vendored (pinned, docs/FONTS.md); Liberation Serif is its metric twin.
// No case-specific text, no coordinates measured off a filed PDF, no forced line breaks.
//
// Cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/typst/xengine.typ): the docx render
// (docx/uscgcoca.lua) breaks every line and page where this one does. Every line is a box of its pitch with the
// baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the two blocks' spacings
// (dropped at the top of a page). The pitches and spaces below are the docx filter's too (in twips there).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges
#import "/lib/typst/typography.typ": footnote-body

// ---- rule parameters ----
#let typeface = ("Times New Roman", "Liberation Serif")   // R. 17.1: Times New Roman
#let body-size = 12pt                // R. 17.1: at least 12-point, everywhere (body, headings, footnotes)
#let margin = 1in                    // R. 17.1: at least one inch on all four sides
#let pitch-body = 28pt               // R. 17.1: at least 15-point spacing; double-spaced body, as filed
#let pitch-single = 15pt             // R. 17.1: caption, headings, quotations, footnotes, signature (still 15-point)
#let para-indent = 0.5in
#let word-limit = "20,000"           // R. 17.3: briefs and answers

// ---- spaces between blocks (the larger of two adjacent ones applies) ----
#let sp-h1 = 12pt                    // above a section heading (#)
#let sp-h = 8pt                      // above an issue or sub-heading (##, ###)
#let sp-quote = 6pt                  // above and below a block quotation and between its paragraphs
#let sp-caption = 12pt               // between the groups of the caption ("v.", title, docket, proceeding)
#let sp-desig = 4pt                  // above a party's designation
#let sp-block = 18pt                 // above a signature block and between the certificates
#let sp-cert = 6pt                   // below a certificate title
#let sig-left = 3.2in                // a lone signature block starts here
#let sig-rule = 2.8in                // the signature line
#let col-gutter = 0.4in              // caption and signature columns

#let court-name = "IN THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS"
#let address-line = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS"
#let brief-title = "ANSWER TO APPELLANT'S ASSIGNMENTS OF ERROR ON BEHALF OF THE UNITED STATES"  // as filed (Steen, 2019)
#let default-recipient = "the Court and opposing counsel"

/// Words in the markdown body, for the R. 17.3 certificate: markup and footnote labels removed,
/// every whitespace-separated token with a letter or digit counted (headings, footnotes and quotations
/// count; the caption, signature and certificates are outside the body). `word_count` overrides it.
/// The docx filter counts the same way.
#let count-words(body) = {
  let s = body.replace(regex("\[\^[^\]]+\]:?"), " ")
  s.split(regex("\s+")).filter(w => w.match(regex("[\p{L}\p{N}]")) != none).len()
}

/// One single-spaced block with `above` space over it.
#let line-block(above, body, inset: 0pt, align-to: left) = block(above: above, below: 0pt, width: 100%,
  pad(left: inset, align(align-to, body)))

// A horizontal rule in a block of its own height (Word: an empty exact-height paragraph with a bottom border).
#let rule-block(above, width, height) = block(above: above, below: 0pt, width: 100%, height: height,
  align(left + bottom, line(length: width, stroke: 0.5pt)))

// Caption: the court, then two columns (parties on the left, filing data on the right), a rule, the address line.
#let caption-block(meta) = {
  set par(first-line-indent: 0pt)
  set text(..edges(pitch-single))
  line-block(0pt, text(weight: "bold", court-name), align-to: center)
  let left-col = {
    for (i, side) in meta.caption.enumerate() {
      if i > 0 { line-block(sp-caption, [v.], inset: 0.6in) }
      for (j, n) in side.names.enumerate() { line-block(if i > 0 and j == 0 { sp-caption } else { 0pt }, [#n]) }
      line-block(sp-desig, [#side.designation], inset: 0.4in)
    }
  }
  let right-col = {
    if "date" in meta { line-block(0pt, [#meta.date]) }
    line-block(if "date" in meta { sp-caption } else { 0pt },
      text(weight: "bold", upper(meta.at("brief_title", default: brief-title))))
    let docket = (meta.at("docket_label", default: "Docket No.") + " " + meta.case_number,) + meta.at("case_lines", default: ())
    for (j, l) in docket.enumerate() { line-block(if j == 0 { sp-caption } else { 0pt }, [#l]) }
    if "proceeding" in meta { line-block(sp-caption, [#meta.proceeding]) }
  }
  block(above: sp-caption, below: 0pt, grid(columns: (1fr, 1fr), column-gutter: col-gutter, left-col, right-col))
  rule-block(0pt, 100%, 10pt)
  line-block(sp-caption, block(width: 5.2in, align(center, address-line)), align-to: center)
}

// A signature block: the line, the signer, the signer's lines (R. 14).
#let signer-block(s) = {
  set par(first-line-indent: 0pt)
  set text(..edges(pitch-single))
  rule-block(0pt, sig-rule, 10pt)
  line-block(0pt, [#s.signer])
  for l in s.at("lines", default: ()) { line-block(0pt, [#l]) }
}

#let signature-block(meta) = {
  let sigs = if type(meta.signature) == array { meta.signature } else { (meta.signature,) }
  if sigs.len() == 1 { block(above: sp-block, below: 0pt, breakable: false, pad(left: sig-left, signer-block(sigs.at(0)))) } else {
    block(above: sp-block, below: 0pt, breakable: false,
      grid(columns: (1fr, 1fr), column-gutter: col-gutter, row-gutter: sp-block, ..sigs.map(signer-block)))
  }
}

#let uscgcoca-brief(meta, body) = {
  set document(title: meta.at("brief_title", default: brief-title), author: "")
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: typeface, size: body-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, body lines in boxes of
  // pitch-body, footnote marks at 58 %, lists with the number in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // Lists: the number or bullet in a half-inch box, the text hanging after it, no space between items (as
  // xengine's lists, but as a grid row, so a loose item, one with a paragraph break, is laid out too).
  let list-row(lab, body) = block(above: 0pt, below: 0pt, grid(columns: (para-indent, 1fr), lab, {
    set par(first-line-indent: 0pt)
    body
  }))
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      list-row(numbering(it.numbering, n), item.body)
      n += 1
    }
  }
  show list: it => for item in it.children { list-row([•], item.body) }
  set super(typographic: false)  // the marks are scaled glyphs, as Word and LibreOffice set them

  show heading: set text(size: body-size)
  // sticky: a heading never ends a page, so it stays with the text that follows it.
  show heading: it => {
    set par(first-line-indent: 0pt)
    set text(..edges(pitch-single))
    let (above, al) = if it.level == 1 { (sp-h1, center) } else if it.level == 2 { (sp-h, left) } else { (sp-h, center) }
    block(sticky: true, width: 100%, above: above, below: 0pt, align(al, strong(it.body)))
  }
  show quote.where(block: true): it => block(above: sp-quote, below: sp-quote, pad(x: para-indent, {
    set par(first-line-indent: 0pt, spacing: sp-quote)
    set text(..edges(pitch-single))
    it.body
  }))
  // The footnote area: 8 pt above the separator and 7 pt below it and between the notes, 15 pt in all over the
  // notes as LibreOffice sets a Word footnote separator (one Normal line, 15 pt), so the pages break alike.
  set footnote.entry(gap: 7pt, clearance: 8pt, indent: 0pt, separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(..edges(pitch-single))
    footnote-body(note.body, num, body-size, 0pt, 7pt)
  }

  caption-block(meta)
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  // Signature (R. 14: name, grade, email address, capacity). One signer, or a list of signers side by side.
  // The brief's last paragraph stays with the signature (unless it is a heading or a footnote definition).
  if "signature" in meta {
    let md = body.trim(at: end)
    let breaks = md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = md.slice(cut)
    if tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^") and not tail.starts-with(">") {
      render(md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(md)
      signature-block(meta)
    }
  } else {
    render(body)
  }

  // Certificate of compliance with the word limit (R. 17.3), then the certificate of service (R. 17.2(a)(5)).
  pagebreak(weak: true)
  let words = meta.at("word_count", default: count-words(body))
  let cert-title(above, t) = {
    set text(..edges(pitch-single))
    block(above: above, below: sp-cert, sticky: true, width: 100%, align(center, text(weight: "bold", t)))
  }
  cert-title(0pt, "CERTIFICATE OF COMPLIANCE")
  [This brief contains #words words, excluding the parts exempted by Rule 17.3, and so complies with the #(word-limit)-word limit of Rule 17.3.]
  let cert = meta.at("certificate", default: (:))
  cert-title(sp-block, "CERTIFICATE OF SERVICE")
  [I certify that a copy of the foregoing was #cert.at("method", default: "delivered") to #cert.at("recipient", default: default-recipient) on #meta.at("date", default: "__________").]
  let certifier = cert.at("signer", default: {
    let s = meta.at("signature", default: (signer: "", lines: ()))
    if type(s) == array { s.last() } else { s }
  })
  block(above: sp-block, below: 0pt, breakable: false, pad(left: sig-left, signer-block(certifier)))
}
