// M.D. Ala. complaint: content-agnostic. Everything case-specific comes from the sample's frontmatter;
// everything here is either a rule (FRCP 10, FRCP 11, LR 5.6) or a named parameter below.
// Entry point: main.typ calls almd-complaint(meta, body).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- Parameters -------------------------------------------------------------------------------
// Rules: FRCP 10(a) caption, FRCP 10(b) numbered paragraphs, FRCP 11(a) signature block, LR 5.6
// (8-1/2 x 11 white paper, double-spaced except quoted material, every page numbered consecutively).
// The Middle District's local rules set no typeface, size or margin; the values below follow the
// filed exemplars (tier 2, convention: 14 pt, double-spaced, one-inch margins).
#let page-margin = 1in
#let type-size = 14pt
#let font-name = ("Times New Roman", "Liberation Serif")       // Times New Roman substitute, the default per docs/FONTS.md
#let para-indent = 0.5in                  // first-line indent of body paragraphs; the caption's "v." and designations

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt                // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single      // LR 5.6: double-spaced (32.2 pt, the Allstate exemplar's pitch)

// Caption grid: left (party names), ")" column, right (case number, jury demand).
#let cap-left = 3.4in
#let cap-paren = 0.15in
#let cap-gutter = 4pt                     // a full-width party line stands off the ")" column

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almd-complaint: the sample must start with a YAML frontmatter block") }
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

/// The court title: each line of `meta.court`, centered and bold, as the exemplars print it.
#let court-title(meta) = for line in meta.court { line-block(align(center, strong(inl(line)))) }

/// FRCP 10(a) caption: parties on the left with a ")" column, the file number and the jury demand on the right.
/// Each side is its names (one row each) and its designation; a "v." row separates the sides. "Civil Action No."
/// stands on the "v." row, "JURY DEMAND" on the first defendant row.
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
  let case-no = meta.at("case_number", default: "")
  let cells = ()
  for (k, r) in rows.enumerate() {
    let right = []
    if k == sep { right = if case-no == "" [Civil Action No.] else [Civil Action No. #case-no] }
    if meta.at("jury_demand", default: false) and k == defendant-row { right = [JURY DEMAND] }
    cells += (r, line-block[)], line-block(right))
  }
  block(above: pitch-single, below: 0pt, grid(columns: (cap-left, cap-paren, 1fr), column-gutter: (cap-gutter, 0pt), ..cells))
}

/// The signature block (FRCP 11(a): signer's name, address, e-mail and telephone). Each group is a
/// signer: `signer` is the name, `esign` (default true) prints the "/s/" electronic signature,
/// `note` is printed after the name, `lines` are the address and contact lines. The lines that follow
/// (`service_note`, the service address) go with it; the whole block never breaks across a page.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-single, below: 0pt, {
  line-block[Respectfully submitted,]
  for g in meta.signature {
    let sig = if g.at("esign", default: true) [/s/ #inl(g.signer)] else { inl(g.signer) }
    let note = g.at("note", default: none)
    line-block(above: pitch-single, if note != none [#sig (#inl(note))] else { sig })
    for line in g.lines { line-block(inl(line)) }
  }
  for (i, line) in meta.at("service_note", default: ()).enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(line))
  }
})

#let almd-complaint(meta, body) = {
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

  // Headings at the body size and pitch, bold: levels 1 and 2 centered (the exemplars' section heads), level 3 at
  // the margin; no space of their own (the double pitch sets them off). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = strong(it.body)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, if it.level <= 2 { align(center, b) } else { b })
  }

  court-title(meta)
  caption(meta)
  block(sticky: true, above: pitch-double, below: 0pt, line-block(strong(inl(meta.title))))

  // Lettered items ("a. ...") are paragraphs in commonmark: they print as typed, with the first-line indent.
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
}
