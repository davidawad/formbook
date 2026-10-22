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
// Times New Roman (Liberation Serif, its metric twin, where it is absent; docs/FONTS.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
//
// The cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx engine
// (docx/acca-brief.lua on docx/reference.xml) breaks every line and page where this render does. Every line is a
// box of its pitch with the baseline at 0.8 of it, the boxes touching; every space between blocks is explicit, and
// between two blocks the larger of the one's below and the next one's above applies (as in Word).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

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

#let font-family = ("Times New Roman", "Liberation Serif")      // Rule 13.2 / 17.1(b): Times New Roman (substitute, docs/FONTS.md)
#let type-size = 14pt                      // Rule 13.2 / 17.1(b): 14-point (footnotes included)
#let pitch-body = 32.8pt                   // Rule 13.2 / 17.1(b): double-spaced (2.34 x the type size)
#let pitch-single = 16pt                   // caption, headings, block quotes, footnotes, signature, footer
#let page-margin = 1in                     // Rule 13.2 / 17.1(b): 1 inch on all four sides
#let page-margin-bottom = page-margin + 4pt  // the last line's descenders stay clear of the 1 inch margin (DEF-FORM-002)
#let para-indent = 0.5in
#let caption-gutter = 0.3in                // between the caption's two columns
#let sig-gap = 8pt                         // an empty signature line ("") between signers

// Spaces between blocks (Word: twips = 20 x pt)
#let space-court = 16.8pt                  // below the court line
#let space-tight = 2.8pt                   // above "Appellee" and "Appellant"
#let space-caption = 14pt                  // between the parts of a caption column
#let space-address = (19.6pt, 8.4pt)       // above and below the "TO THE HONORABLE ..." line
#let space-h1 = (16.8pt, 14pt)             // section headings (level 1, centered) and errors (level 2, flush left)
#let space-h3 = (14pt, 11.2pt)             // sub-headings (level 3, centered)
#let space-quote = (12.6pt, 19.6pt)        // block quotations: above (and between their paragraphs), below
#let space-signature = 33.6pt              // above a signature rule
#let space-title = 14pt                    // below the Certificate of Service and Appendix titles
#let rule-box = 6pt                        // a signature rule is drawn under a box of this height

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

/// One line (a paragraph of its own), the space above it, indented from the left.
#let line-par(body, above: 0pt, left: 0pt) = block(above: above, below: 0pt, pad(left: left, par(body)))

/// A column of lines, one paragraph each (no forced breaks); "" is a gap between signers.
#let lines-block(lines) = {
  let gap = 0pt
  for l in lines {
    if l == "" { gap = sig-gap } else {
      line-par(l, above: gap)
      gap = 0pt
    }
  }
}

/// A rule under a box of `rule-box` (Word: an empty paragraph of that exact height with a bottom border).
#let rule(length, above) = block(above: above, below: 0pt, height: rule-box, width: length,
  place(bottom, line(length: 100%, stroke: 0.5pt)))

// ---------------------------------------------------------------------------
// Caption (Appendix A): at the top of page 1, followed directly by the body
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let app = need(meta, "appellant")
  let trial = need(meta, "trial")
  set par(first-line-indent: 0pt)
  block(width: 100%, below: space-court, align(center, par(court-line)))
  let left-col = {
    line-par[UNITED STATES]
    line-par([Appellee], above: space-tight, left: 1.2in)
    line-par([v.], above: space-caption, left: 0.8in)
    line-par(app.rank, above: space-caption)
    line-par(text(weight: "bold", app.name))
    line-par(app.service)
    line-par([Appellant], above: space-tight, left: 1.2in)
  }
  let right-col = {
    line-par(text(weight: "bold", brief-title))
    line-par([Docket No. #need(meta, "docket")], above: space-caption)
    line-par([Tried at #trial.place, on #trial.dates, before a #trial.court-type court-martial appointed by #trial.convening#if "judge" in trial [, #trial.judge presiding].], above: space-caption)
  }
  block(above: space-court, below: 0pt,
    grid(columns: (1fr, 1fr), column-gutter: caption-gutter, left-col, right-col))
  block(width: 100%, above: space-address.at(0), below: space-address.at(1),
    pad(x: 0.75in, align(center, par(address-line))))
}

// ---------------------------------------------------------------------------
// Closing: signature block, certificate of service, optional appendix list
// ---------------------------------------------------------------------------

#let signature(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  rule(3in, space-signature)
  lines-block(need(meta, "signature"))
}

#let closing(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if "appendix" in meta and meta.appendix.len() > 0 {
    pagebreak(weak: true)
    block(width: 100%, below: space-title, align(center, par(text(weight: "bold", "Appendix"))))
    for item in meta.appendix { line-par(item) }
  }
  pagebreak(weak: true)
  block(width: 100%, below: space-title, align(center, par(text(weight: "bold", "Certificate of Service"))))
  let cert = need(meta, "certificate")
  let method = cert.at("method", default: "sent via electronic submission")
  let recipient = cert.at("recipient", default: default-recipient)
  {
    set text(..edges(pitch-body))
    set par(first-line-indent: (amount: para-indent, all: true))
    par[I certify that a copy of the foregoing was #method to #recipient on #cert.date.]
  }
  block(breakable: false, width: 100%, above: space-signature, pad(left: 3.0in, {
    rule(100%, 0pt)
    lines-block(cert.signature)
  }))
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let acca-brief(meta, body) = {
  set document(title: brief-title, author: need(meta, "appellant").name)
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin-bottom),
    numbering: "1", footer-descent: 30%, footer: context {
      // Page 1 carries the panel designation at the foot (Appendix A, "Panel X"); later pages print their
      // number, centered. A single-spaced line box, as Word's footer.
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      let n = counter(page).get().first()
      if n == 1 {
        if "panel" in meta { align(right, par(meta.panel)) }
      } else { align(center, par(counter(page).display())) }
    })
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, line boxes of the body pitch,
  // footnote marks at 58 %, lists with the number in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  set block(spacing: 0pt)   // every space between blocks is explicit

  // Section headings (Appendix A): centered; errors (level 2) flush left; sub-headings (level 3) centered; bold.
  show heading: set text(size: type-size, weight: "bold", ..edges(pitch-single))
  show heading: set par(first-line-indent: 0pt)
  show heading: it => {
    let (above, below) = if it.level <= 2 { space-h1 } else { space-h3 }
    let body = if it.level == 2 { par(it.body) } else { align(center, par(it.body)) }
    block(sticky: true, width: 100%, above: above, below: below, body)
  }
  // Block quotations: single-spaced, indented on both sides.
  show quote.where(block: true): it => block(above: space-quote.at(0), below: space-quote.at(1),
    pad(x: para-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, spacing: space-quote.at(0))
      it.body
    }))
  // Footnotes: 14 pt (Rule 13.2), single-spaced; the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: 7pt, clearance: 10.1pt, indent: 0pt, separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // Rule 13.2: 14-point in footnotes too
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 7pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  { set text(..edges(pitch-single)); caption(meta) }
  // The signature block never stands alone on a page: the brief's last paragraph is kept together with it
  // (unless that last block is a heading, a quotation, a footnote definition, or refers to a footnote).
  let text-md = body.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  let keep = (tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with(">")
    and not tail.contains("[^"))
  let render(s) = cmarker.render(s, smart-punctuation: true)
  if keep {
    render(text-md.slice(0, cut))
    block(breakable: false, { render(tail); signature(meta) })
  } else {
    render(text-md)
    signature(meta)
  }
  closing(meta)
}
