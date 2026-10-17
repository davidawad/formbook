// U.S. Army Court of Criminal Appeals: brief on behalf of the appellant (opening brief).
//
// Governing rules: U.S. Army Court of Criminal Appeals Rules of Appellate Procedure, effective
// 15 January 2019 (published with the Joint Rules of Appellate Procedure), read 2026-10-16 from
// https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf (Wayback capture 20250729125903):
//   Rule 13.2 / 17.1(b): single PDF, typed, double-spaced, Times New Roman 14-point, 8.5 x 11 in,
//                        1-inch margins on all four sides.
//   Rule 17.1(a) and Appendix A ("Format for Brief on Behalf of Appellant"): caption at the top of the
//                        first page (court line; UNITED STATES, Appellee / v. / rank, NAME, United States
//                        Army, Appellant on the left; title, docket number, "Tried at ..." on the right),
//                        "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES ARMY COURT OF CRIMINAL
//                        APPEALS", then the body; "Panel X" at the foot of the first page; signature
//                        block; Certificate of Service on its own page.
//   Rule 17.3: TOC and table of authorities over 30 pages; 50-page limit (not enforced here).
// Times New Roman is mapped to Liberation Serif (docs/FONTS.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters
// ---------------------------------------------------------------------------

#let doc-kind = "opening-brief"
#let brief-title = "BRIEF ON BEHALF OF APPELLANT"                       // Appendix A
#let court-line = "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS"  // Appendix A
#let address-line = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS" // Appendix A
#let default-recipient = "the Government Appellate Division"           // Appendix A blank: the opposing party

// ---------------------------------------------------------------------------
// Rule parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"      // Rule 13.2 / 17.1(b): Times New Roman (substitute, docs/FONTS.md)
#let type-size = 14pt                      // Rule 13.2 / 17.1(b): 14-point
#let body-leading = 1.65em                 // Rule 13.2 / 17.1(b): double-spaced (baseline pitch ~2.3 x size)
#let single-leading = 0.45em               // caption, headings, block quotes, footnotes, signature
#let page-margin = 1in                     // Rule 13.2 / 17.1(b): 1 inch on all four sides
#let para-indent = 0.5in
#let para-spacing = body-leading           // no extra gap between double-spaced paragraphs

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("acca-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("acca-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A column of lines, one block each (no forced breaks).
#let lines-block(lines, align-to: left) = stack(
  dir: ttb,
  spacing: 0.45em,
  ..lines.map(l => if l == "" { v(0.9em) } else { align(align-to, text(l)) }),  // "" = gap between signers
)

// ---------------------------------------------------------------------------
// Caption (Appendix A): at the top of page 1, followed directly by the body
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let app = need(meta, "appellant")
  let trial = need(meta, "trial")
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.45em, justify: false)
  align(center, court-line)
  v(1.2em)
  let left-col = {
    [UNITED STATES]
    v(0.2em)
    pad(left: 1.2in, [Appellee])
    v(1.0em)
    pad(left: 0.8in, [v.])
    v(1.0em)
    app.rank
    linebreak()
    text(weight: "bold", app.name)
    linebreak()
    app.service
    v(0.2em)
    pad(left: 1.2in, [Appellant])
  }
  let right-col = {
    text(weight: "bold", brief-title)
    v(1.0em)
    [Docket No. #need(meta, "docket")]
    v(1.0em)
    [Tried at #trial.place, on #trial.dates, before a #trial.court-type court-martial appointed by #trial.convening#if "judge" in trial [, #trial.judge presiding].]
  }
  grid(columns: (1fr, 1fr), column-gutter: 0.3in, left-col, right-col)
  v(1.4em)
  align(center, box(width: 5in, align(center, address-line)))
  v(0.6em)
}

// ---------------------------------------------------------------------------
// Closing: signature block, certificate of service, optional appendix list
// ---------------------------------------------------------------------------

#let closing(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.45em)
  v(2.4em)
  block(breakable: false, {
    line(length: 3in, stroke: 0.5pt)
    lines-block(need(meta, "signature"))
  })
  if "appendix" in meta and meta.appendix.len() > 0 {
    pagebreak(weak: true)
    align(center, text(weight: "bold", "Appendix"))
    v(1.0em)
    for item in meta.appendix { block(item) }
  }
  pagebreak(weak: true)
  align(center, text(weight: "bold", "Certificate of Service"))
  v(1.0em)
  let cert = need(meta, "certificate")
  let method = cert.at("method", default: "sent via electronic submission")
  let recipient = cert.at("recipient", default: default-recipient)
  set par(leading: body-leading, first-line-indent: para-indent, spacing: para-spacing)
  [I certify that a copy of the foregoing was #method to #recipient on #cert.date.]
  v(2.4em)
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.45em)
  pad(left: 3.0in, block(breakable: false, {
    line(length: 100%, stroke: 0.5pt)
    lines-block(cert.signature)
  }))
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let acca-brief(meta, body) = {
  set document(title: brief-title, author: need(meta, "appellant").name)
  set page(paper: "us-letter", margin: page-margin, numbering: "1", footer: context {
    // Page 1 carries the panel designation at the foot (Appendix A, "Panel X");
    // later pages print their number, centered.
    let n = counter(page).get().first()
    if n == 1 {
      if "panel" in meta { align(right, text(meta.panel)) }
    } else { align(center, text(counter(page).display())) }
  })
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: para-spacing, justify: false, first-line-indent: (amount: para-indent, all: true))

  // Section headings (Appendix A): centered; errors (level 2) in bold capitals, flush left.
  show heading: set text(size: type-size)
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(sticky: true, width: 100%, above: 1.2em, below: 1.0em, align(center, text(weight: "bold", it.body)))
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(sticky: true, width: 100%, above: 1.2em, below: 1.0em, text(weight: "bold", it.body))
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(sticky: true, width: 100%, above: 1.0em, below: 0.8em, align(center, text(weight: "bold", it.body)))
  }
  // Block quotations: single-spaced, indented on both sides.
  show quote.where(block: true): it => {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
    block(above: 0.9em, below: 1.4em, pad(x: 0.5in, it.body))
  }
  // Synthesized superscripts: Liberation Serif lacks superscript glyphs for some digits, and
  // mixed typographic/synthesized markers would differ in size.
  set super(typographic: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    set text(size: type-size)          // Rule 13.2: 14-point throughout
    it
  }

  caption(meta)
  cmarker.render(body, smart-punctuation: true)
  closing(meta)
}
