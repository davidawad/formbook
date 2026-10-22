// Brief in support of a motion for the U.S. District Court for the District of South Dakota (sdd).
// Rules: D.S.D. Civ. LR 7.1(B) (movant's brief: legal arguments, authorities, and the Federal Rules relied on;
// a motion raising a question of law needs one), LR 7.1(B)(1) (25 pages or 12,000 words; a certificate of
// compliance beyond 25 pages), LR 83.4 (form of papers: 8 1/2 x 11 inch, double-spaced text, headings and
// footnotes single-spaced, margins at least one inch on all four sides, type at least 12 point), LR 10.1 (caption;
// signature block), LR 5.1(A)(3) (certificate of service unless CM/ECF gives notice), LR 5.1(A)(4) ("/s/").
// See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // LR 83.4 names no face: the house standard, vendored in fonts/
#let type-size = 12pt                   // LR 83.4: type must be at least 12 point (footnotes too)
#let page-w = 8.5in                     // LR 83.4: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 83.4: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs; the label box of list items
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-inset = 12pt               // the party text stands off the caption's right rule
#let right-inset = 0.15in               // the case-number column stands off the gutter
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let heading-space = 12pt               // above and below a heading (LR 83.4: headings single-spaced)
#let recipient-space = 12pt             // certificate of service: between the persons served
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the body and the footnote rule

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // LR 83.4: double-spaced text (Word's double)
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line below the last party line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sdd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, *Id.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A body paragraph at the double pitch with the first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties on the left, case number and title on the right)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE DISTRICT OF SOUTH DAKOTA")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block("Case No. " + meta.case_number)
    line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
  }),
))

// ---------------------------------------------------------------------------
// Signature, certificate of service
// ---------------------------------------------------------------------------

/// The signer's lines (LR 10.1(B), LR 5.1(A)(4)): the firm, then "By: /s/" and the typed name, then the address,
/// telephone and e-mail beneath it.
#let signer-lines(sig) = {
  if "firm" in sig { for l in sig.firm { line-block(inl(l)) } }
  line-block(above: if "firm" in sig { pitch-single } else { 0pt }, inl("By: /s/ " + sig.signer))
  line-block(inl(sig.signer))
  for l in sig.at("lines", default: ()) { line-block(inl(l)) }
}

/// Signature block: "Dated" at the left, the signer at the right; it never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #inl(meta.date)],
  signer-lines(meta.signature),
))

/// Certificate of service (LR 5.1(A)(3)): on its own page, with the persons served and the manner of service.
#let certificate-block(cert) = {
  pagebreak(weak: true)
  heading(level: 1, "Certificate of Service")
  body-par(inl(cert.text))
  for (k, r) in cert.recipients.enumerate() {
    block(width: 100%, breakable: false, above: recipient-space, below: 0pt, for l in r { line-block(inl(l)) })
  }
  block(width: 100%, breakable: false, above: recipient-space, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    [],
    signer-lines((signer: cert.signer)),
  ))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   - a footnote definition (`[^id]: text`): collected, and placed at each `[^id]` reference;
///   - a heading (`#`, `##`, `###`);
///   - a list (`1.`, `-`): lettered (a), (b), ... ;
///   - a paragraph: set with a first-line indent, double-spaced, unnumbered (LR 83.4).
/// Footnotes are split out here because cmarker 0.1.10 has no footnote support.
/// The last paragraph stays on the page with the signature block (a signature alone on a page is not allowed).
#let brief-body(body, tail) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let chunks = ()
  for c in all {
    let m = c.match(regex("^\\[\\^(\\w+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) } else { chunks.push(c) }
  }
  let tail-used = false
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else {
      // Split the paragraph at footnote references: text, the footnote, text again.
      let pieces = ()
      let at = 0
      for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
        pieces.push(t.slice(at, m.start))
        pieces.push((note: m.captures.at(0)))
        at = m.end
      }
      pieces.push(t.slice(at))
      let para = body-par(for p in pieces {
        if type(p) == dictionary { footnote(inl(defs.at(p.note))) } else if p != "" { md(p) }
      })
      if i == chunks.len() - 1 {
        block(breakable: false, width: 100%, above: 0pt, below: 0pt, { para; tail })
        tail-used = true
      } else {
        para
      }
    }
  }
  if not tail-used { tail }
}

#let sdd-motion-brief(meta, body) = {
  // Page numbers centered on every page, in a single-spaced line box (Word's footer at the same place).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 83.4: double-spaced); list items as a label box (para-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set enum(numbering: "(a)")

  // Footnotes single-spaced at the text size (LR 83.4): the mark, a space, the note; the rule as long as Word's
  // separator in LibreOffice (30 % of the measure).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings single-spaced (LR 83.4): level 1 centered in capitals, bold; level 2 bold; level 3 bold italic; kept
  // with the block after them.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: heading-space, below: heading-space, b)
  }

  court-title(meta)
  caption(meta)
  brief-body(body, signature-block(meta))
  if "certificate_of_service" in meta and meta.certificate_of_service != none {
    certificate-block(meta.certificate_of_service)
  }
}
