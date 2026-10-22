// M.D. Ala. brief in support of a Rule 12(b) motion: content-agnostic. Everything case-specific comes
// from the sample's frontmatter; everything here is a rule (FRCP 7(b), FRCP 10(a), FRCP 11(a), FRCP 5(b)
// and (d), LR 5.6) or a named parameter below. Entry point: main.typ calls almd-motion-brief(meta, body).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- Parameters -------------------------------------------------------------------------------
// Rules: FRCP 10(a) caption, FRCP 11(a) signature block, FRCP 5(d)(1)(B) certificate (required only for
// service not made through the electronic-filing system; included as the exemplars print it), LR 5.6
// (8-1/2 x 11 white paper, double-spaced except quoted material, every page numbered consecutively).
// The Middle District's local rules set no typeface, size, margin or page limit for briefs; the values
// below follow the filed exemplars (tier 2, convention: 14 pt, double-spaced, one-inch margins).
#let page-margin = 1in
#let type-size = 14pt
#let font-name = ("Times New Roman", "Liberation Serif")       // Times New Roman substitute, the default per docs/FONTS.md
#let para-indent = 0.5in                  // first-line indent of body paragraphs; heading hang; quotation inset

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt                // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single      // LR 5.6: double-spaced (32.2 pt)
#let quote-gap = pitch-single / 2         // around and between the paragraphs of a block quotation

// Caption grid: left (party names), ")" column, right (case number, jury demand).
#let cap-left = 3.3in                     // leaves the right column room for a full case number with its judges' initials
#let cap-paren = 0.15in
#let cap-gutter = 4pt                     // a full-width party line stands off the ")" column

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (a frontmatter string), with the same smart punctuation as the body.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// A body paragraph at the double pitch with the first-line indent.
#let body-par(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, par(body))

/// The court title: each line of `meta.court`, centered and bold, as the exemplars print it.
#let court-title(meta) = for line in meta.court { line-block(align(center, strong(inl(line)))) }

/// FRCP 10(a) caption: parties on the left with a ")" column, the case number and jury demand on the
/// right. Each side is its names (one row each) and its designation, and the sides are separated by
/// "v."; the case label and number stand on the "v." row, "JURY DEMAND" on the first defendant row.
#let caption(meta) = {
  let rows = ()
  let sep = none
  let defendant-row = none
  for (i, side) in meta.caption.sides.enumerate() {
    if i > 0 {
      sep = rows.len()
      rows.push(line-block(indent: para-indent, "v."))
      defendant-row = rows.len()
    }
    for name in side.names { rows.push(line-block(inl(name))) }
    rows.push(line-block(indent: para-indent, inl(side.designation)))
  }
  let label = meta.caption.at("case_label", default: "Civil Action No.")
  let case-no = meta.caption.at("case_number", default: "")
  let cells = ()
  for (k, r) in rows.enumerate() {
    let right = []
    if k == sep { right = if case-no == "" { inl(label) } else [#inl(label) #case-no] }
    if meta.at("jury_demand", default: false) and k == defendant-row { right = [JURY DEMAND] }
    cells += (r, line-block[)], line-block(right))
  }
  block(above: pitch-single, below: 0pt, grid(columns: (cap-left, cap-paren, 1fr), column-gutter: (cap-gutter, 0pt), ..cells))
}

/// The date line and the signature block (FRCP 11(a): signer's name, address, e-mail and telephone),
/// never broken across a page. Each group is a signer: `signer` is the name, `esign` (default true)
/// prints the "/s/" electronic signature, `note` is printed after the name, `lines` are the contact
/// and role lines.
#let signature-block(meta) = block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
  let date-line = meta.at("signature_date", default: none)
  if date-line != none { body-par(inl(date-line)) }
  for g in meta.signature {
    let sig = if g.at("esign", default: true) [/s/ #inl(g.signer)] else { inl(g.signer) }
    let note = g.at("note", default: none)
    line-block(above: pitch-single, if note != none [#sig (#inl(note))] else { sig })
    for line in g.lines { line-block(inl(line)) }
  }
})

/// The "OF COUNSEL" block, single-spaced, after the signature; never broken across a page.
#let of-counsel(meta) = {
  let lines = meta.at("of_counsel", default: ())
  if lines.len() > 0 {
    block(breakable: false, width: 100%, above: pitch-single, below: 0pt, for line in lines { line-block(inl(line)) })
  }
}

/// The certificate of service: heading, the certificate text, the list of those served, and the
/// signature of the person certifying; one block that moves to the next page whole.
#let certificate(meta) = {
  let cert = meta.at("certificate", default: none)
  if cert != none {
    block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
      line-block(align(center, strong(inl(cert.heading))))
      body-par(above: pitch-single, inl(cert.text))
      for (i, line) in cert.served.enumerate() {
        line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(line))
      }
      line-block(above: pitch-single, [/s/ #inl(cert.signer)])
      for line in cert.lines { line-block(inl(line)) }
    })
  }
}

#let almd-motion-brief(meta, body) = {
  set document(title: meta.title)
  // Page numbers centered, arabic, on every page (LR 5.6); the number in a single-spaced line box, so it sits at
  // the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-name, size: type-size, fill: black, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (LR 5.6: double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings, bold at the body size. Level 1 (INTRODUCTION, ARGUMENT, CONCLUSION) centered in a line of the body
  // pitch; levels 2 and 3 single-spaced at the margin, a wrapped line hanging after its number ("I.", "A."), a
  // single line above them. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    if it.level == 1 {
      block(sticky: true, width: 100%, above: 0pt, below: 0pt,
        align(center, par(first-line-indent: 0pt, strong(it.body))))
    } else {
      set text(..edges(pitch-single))
      block(sticky: true, width: 100%, above: pitch-single, below: 0pt,
        par(first-line-indent: 0pt, hanging-indent: para-indent, strong(it.body)))
    }
  }

  // Block quotations single-spaced and indented half an inch on both sides (quoted material, LR 5.6), half a single
  // line around and between their paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap,
    inset: (left: para-indent, right: para-indent), {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, spacing: quote-gap)
      it.body
    })

  court-title(meta)
  caption(meta)
  block(sticky: true, above: pitch-double, below: pitch-single,
    line-block(align(center, strong(inl(meta.title)))))

  // Lettered items ("a. ...") are paragraphs in commonmark: they print as typed, with the first-line indent.
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // The date line, then the signature, the "OF COUNSEL" block and the certificate, in the exemplar's order.
  signature-block(meta)
  of-counsel(meta)
  certificate(meta)
}
