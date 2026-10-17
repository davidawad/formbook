// uscgcoca opening brief: the appellant's "Assignments of Error and Brief".
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
// Times New Roman is mapped to Liberation Serif (docs/FONTS.md).
// No case-specific text, no coordinates measured off a filed PDF, no forced line breaks.
#import "@preview/cmarker:0.1.10"

// ---- rule parameters ----
#let typeface = "Liberation Serif"   // R. 17.1: Times New Roman (substitute, docs/FONTS.md)
#let body-size = 12pt                // R. 17.1: at least 12-point
#let margin = 1in                    // R. 17.1: at least one inch on all four sides
#let body-leading = 1.64em           // R. 17.1: at least 15-point spacing; double-spaced (27.6 pt pitch), as filed
#let single-leading = 0.5em          // caption, headings, block quotes, footnotes, signature
#let para-indent = 0.5in
#let word-limit = "20,000"           // R. 17.3: briefs and answers

#let court-name = "IN THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS"
#let address-line = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS"
#let brief-title = "ASSIGNMENTS OF ERROR AND BRIEF ON BEHALF OF APPELLANT"
#let default-recipient = "the Court and opposing counsel"

/// Words in the markdown body, for the R. 17.3 certificate: markup and footnote labels removed,
/// every whitespace-separated token with a letter or digit counted (headings, footnotes and quotations
/// count; the caption, signature and certificates are outside the body). `word_count` overrides it.
#let count-words(body) = {
  let s = body.replace(regex("\[\^[^\]]+\]:?"), " ")
  s.split(regex("\s+")).filter(w => w.match(regex("[\p{L}\p{N}]")) != none).len()
}

#let stack-lines(lines) = stack(dir: ttb, spacing: 0.5em, ..lines.map(l => [#l]))

// Caption: two columns, parties on the left, filing data on the right.
#let caption-block(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false, spacing: 0.5em)
  align(center, text(weight: "bold", court-name))
  v(1.2em)
  let left-col = {
    for (i, side) in meta.caption.enumerate() {
      if i > 0 { v(1em); pad(left: 0.6in, [v.]); v(1em) }
      stack-lines(side.names)
      v(0.3em)
      pad(left: 0.4in, side.designation)
    }
  }
  let right-col = {
    if "date" in meta { [#meta.date]; v(1em) }
    text(weight: "bold", upper(meta.at("brief_title", default: brief-title)))
    v(1em)
    stack-lines((meta.at("docket_label", default: "Docket No.") + " " + meta.case_number,) + meta.at("case_lines", default: ()))
    if "proceeding" in meta { v(1em); [#meta.proceeding] }
  }
  grid(columns: (1fr, 1fr), column-gutter: 0.4in, left-col, right-col)
  v(0.4em)
  line(length: 100%, stroke: 0.5pt)
  v(0.4em)
  align(center, box(width: 5.2in, align(center, address-line)))
  v(0.8em)
}

#let signer-block(s) = block(breakable: false, {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.5em)
  line(length: 2.8in, stroke: 0.5pt)
  stack-lines((s.signer,) + s.at("lines", default: ()))
})

#let uscgcoca-brief(meta, body) = {
  set document(title: meta.at("brief_title", default: brief-title), author: "")
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer: context align(center, text(size: body-size, counter(page).display())),
  )
  set text(font: typeface, size: body-size, lang: "en", hyphenate: false)
  set par(justify: false, first-line-indent: (amount: para-indent, all: true), leading: body-leading, spacing: body-leading)
  set super(typographic: false)  // Liberation Serif lacks some superscript digits; keep marks uniform

  show heading: set text(size: body-size)
  // sticky: a heading never ends a page, so it stays with the text that follows it.
  show heading.where(level: 1): it => block(sticky: true, width: 100%, above: 1.2em, below: 1.0em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(weight: "bold", it.body))
  })
  show heading.where(level: 2): it => block(sticky: true, width: 100%, above: 1.2em, below: 1.0em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(sticky: true, width: 100%, above: 1.0em, below: 0.8em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(weight: "bold", it.body))
  })
  show quote.where(block: true): it => block(above: 0.9em, below: 1.4em, pad(x: 0.5in, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
    it.body
  }))
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  caption-block(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // Signature (R. 14: name, grade, email address, capacity). One signer, or a list of signers.
  if "signature" in meta {
    let sigs = if type(meta.signature) == array { meta.signature } else { (meta.signature,) }
    v(1.5em)
    if sigs.len() == 1 { pad(left: 3.2in, signer-block(sigs.at(0))) } else {
      grid(columns: (1fr, 1fr), column-gutter: 0.4in, row-gutter: 1.5em, ..sigs.map(signer-block))
    }
  }

  // Certificate of compliance with the word limit (R. 17.3), then the certificate of service (R. 17.2(a)(5)).
  pagebreak(weak: true)
  let words = meta.at("word_count", default: count-words(body))
  align(center, text(weight: "bold", "CERTIFICATE OF COMPLIANCE"))
  v(0.6em)
  [This brief contains #words words, excluding the parts exempted by Rule 17.3, and so complies with the #(word-limit)-word limit of Rule 17.3.]
  v(1.6em)
  let cert = meta.at("certificate", default: (:))
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(0.6em)
  [I certify that a copy of the foregoing was #cert.at("method", default: "delivered") to #cert.at("recipient", default: default-recipient) on #meta.at("date", default: "__________").]
  v(1.5em)
  let certifier = cert.at("signer", default: {
    let s = meta.at("signature", default: (signer: "", lines: ()))
    if type(s) == array { s.last() } else { s }
  })
  pad(left: 3.2in, signer-block(certifier))
}
