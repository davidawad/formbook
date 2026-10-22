// Brief in support of a motion, for the U.S. District Court for the District of Nebraska (ned).
// Rules: NECivR 7.1(a)(1)(A) (a supporting brief, separate from the motion; no facts unless supported);
// NECivR 7.1(d)(1)(A) (13,000-word limit, caption and headings included) and 7.1(d)(3) (certificate of compliance:
// the word count and the name and version of the software used); NECivR 11.1(a)(1)(A) (signature format);
// NECivR 10.1(a)(3) (caption shows the paper's description). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // NECivR names no face (checked 2026-10-14): the house standard, as the exemplar is set
#let type-size = 12pt
#let page-w = 8.5in                     // NECivR 10.1(b)(1): 8 1/2 by 11 inch paper (paper filings)
#let page-h = 11in
#let margin = 1in
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-indent = 0.5in                // facts lists: the number half an inch in, the text a box after it
#let heading-hang = 0.5in               // level 2 and 3 headings: the lines after the first hang by this
#let quote-indent = 0.5in               // block quotations: indented on both sides
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let right-inset = 0.1in                // the case-number column stands off the gutter
#let designation-indent = 1.5in         // each party's designation ("Plaintiff,") stands in from the names
#let sig-indent = 3.25in                // the signature lines stand at the right half of the page
#let recipient-indent = 0.5in           // certificate of service: each recipient's block
#let footer-size = 10pt
#let word-limit = 13000                 // NECivR 7.1(d)(1)(A): a supporting brief may not exceed 13,000 words

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double-spaced body (no NECivR spacing rule; the exemplar is Word's double)
#let pitch-footer = 11.5pt              // a footer line: 1.15 x the footer size
#let footer-gap = 3pt                   // between the page number and the title / case-number line
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line off the text

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ned-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  })

/// A body paragraph at the double pitch with the first-line indent. `keep`: kept whole and on the page of the block
/// after it (the paragraph before a signature: a signature never starts a page alone).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A block of single lines at a left indent, above it a blank single line; it never breaks across a page.
/// `sticky`: kept on the page of the block after it.
#let line-group(indent, lines, sticky: false) = block(width: 100%, above: pitch-single, below: 0pt, breakable: false,
  sticky: sticky,
  pad(left: indent, for l in lines { line-block(l) }))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page after the first: the page number centered, then the paper's title in capitals at the left
/// and "Case No." with the number at the right.
#let footer-block(title, case-number) = context {
  if counter(page).get().first() > 1 {
    set text(size: footer-size, ..edges(pitch-footer))
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, align(center, counter(page).display()))
    block(width: 100%, above: footer-gap, below: 0pt, grid(columns: (1fr, auto), upper(title), [Case No. #case-number]))
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE DISTRICT OF NEBRASKA")))
}

#let caption(meta) = block(above: pitch-double, below: pitch-single, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation)))
    }
  }),
  pad(left: right-inset, {
    line-block[Case No. #meta.case_number]
    line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
  }),
))

// ---------------------------------------------------------------------------
// Body, signature and certificates
// ---------------------------------------------------------------------------

/// A heading as its own sticky block (a heading never ends a page). Level 1: a centered section in bold capitals,
/// a line of the double pitch. Levels 2 (bold) and 3 (bold italic): single-spaced, the lines after the first hanging
/// by heading-hang, a blank single line above (the double line box of the text after it sets it off below).
#let heading-block(t) = {
  let lvl = t.match(regex("^#+")).text.len()
  let txt = t.replace(regex("^#+[ \\t]*"), "")
  if lvl == 1 {
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
      set par(first-line-indent: 0pt)
      align(center, text(weight: "bold", inl(upper(txt))))
    })
  } else {
    let style = if lvl == 2 { "normal" } else { "italic" }
    line-block(above: pitch-single, below: 0pt, sticky: true,
      par(hanging-indent: heading-hang, text(weight: "bold", style: style, inl(txt))))
  }
}

/// Block quotations: single-spaced, indented on both sides, a blank single line above, below and between their
/// paragraphs.
#let block-quote(t) = {
  let src = t.split(regex("\\r?\\n")).map(l => l.replace(regex("^>[ \\t]?"), "")).join("\n")
  let paras = src.split(regex("\\n[ \\t]*\\n")).filter(c => c.trim() != "")
  for q in paras {
    line-block(above: pitch-single, below: pitch-single, pad(left: quote-indent, right: quote-indent, md(q.trim())))
  }
}

/// Signature block in NECivR 11.1(a)(1)(A) order: "s/ name", bar number, attorney for, firm and contact lines.
#let signature-block(meta) = {
  let sig = meta.signature
  line-group(sig-indent, ([s/ #inl(sig.signer)], [Bar Number: #inl(sig.bar_number)],
    [Attorney for #inl(sig.attorney_for)]) + sig.firm.map(inl))
}

/// The short signature under a certificate: "s/ name", then the name and bar number.
#let certificate-signature(meta) = {
  let sig = meta.signature
  line-group(sig-indent, ([s/ #inl(sig.signer)], [#inl(sig.signer), \##inl(sig.bar_number)]))
}

/// A certificate heading: centered bold capitals in a line of the double pitch, a blank single line above.
#let certificate-heading(title) = block(width: 100%, above: pitch-single, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", upper(title)))
})

/// Certificate of compliance, NECivR 7.1(d)(3): the word count, and the name and version of the software used.
/// The count is the filer's; the template checks the 13,000-word limit of NECivR 7.1(d)(1)(A).
/// The heading, the text and the signature stay together.
#let compliance-certificate(meta) = {
  if "compliance" not in meta {
    panic("ned-motion-brief: NECivR 7.1(d)(3) requires a certificate of compliance; add a `compliance` block")
  }
  let words = meta.compliance.word_count
  let count = int(words.replace(",", ""))
  assert(count <= word-limit, message: "ned-motion-brief: NECivR 7.1(d)(1)(A) limits a supporting brief to 13,000 words; this one states " + words)
  certificate-heading("Certificate of Compliance")
  body-par(keep: true)[I hereby certify that this Brief complies with NECivR 7.1(d)(1). It contains #words words, including the caption, headings, footnotes, and quotations, as calculated by the word-count function of #inl(meta.compliance.software).]
  certificate-signature(meta)
}

/// Certificate of service: the filer's sentence, then each recipient's block. CM/ECF filing is the service
/// (no certificate is required for it under Fed. R. Civ. P. 5(d)(1)(B)); the exemplar files one anyway. The heading,
/// the text, the recipients and the signature stay together.
#let service-certificate(meta) = {
  if "service" in meta {
    let svc = meta.service
    certificate-heading("Certificate of Service")
    body-par(inl(svc.text), keep: true)
    for r in svc.recipients { line-group(recipient-indent, r.map(inl), sticky: true) }
    certificate-signature(meta)
  }
}

/// Body paragraphs are not numbered (a brief is not pleading under Fed. R. Civ. P. 10(b)). Each blank-line-separated
/// chunk is one paragraph (first-line indent), a heading, a block quotation, or a list (numbered 1., 2., ...).
/// The last chunk is kept with the signature.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // a block quotation's paragraphs are separated by ">" lines, so a quotation is one chunk
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if t.starts-with(">") {
      block-quote(t)
    } else {
      body-par(md(t), keep: last)
    }
  }
}

#let ned-motion-brief(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); list items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  set enum(numbering: "1.")

  court-title(meta)
  caption(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  body-chunks(body)
  signature-block(meta)
  compliance-certificate(meta)
  service-certificate(meta)
}
