// Motion with incorporated memorandum for the U.S. District Court for the Northern District of Florida (flnd).
// Rules: N.D. Fla. Loc. R. 5.1(B) (case style and heading), 5.1(C) (double spaced, 14-point font, one-inch
// margins, numbered pages), 5.1(D) (attorney signature block), 5.1(F) (certificate of service), 7.1(A)-(F)
// (motion in writing, conference statement or exception under 7.1(D), memorandum in the same document,
// 8,000-word limit with a certificate of word count); Fed. R. Civ. P. 10(a)-(b), 12(b), 12(f). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // no face named by Loc. R. 5.1(C); Times New Roman, the house default (docs/FONTS.md), as filed
#let type-size = 14pt                  // Loc. R. 5.1(C): at least 14-point font, everywhere (footer included)
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let heading-hang = 0.5in              // level-2 headings: "A." then the text, the lines after it hanging
#let list-box = 0.5in                  // list items: the label's box at the margin, the text hanging after it
#let caption-left = 3.3in              // width of the party column of the caption
#let caption-gutter = 0.3in            // between the party column and the case-number column
#let caption-inset = 0.2in             // the party text stands off the column's right edge
#let caption-pad = 0.1in               // the closing rule stands off the last party line
#let right-inset = 0.1in               // the case-number column stands off the gutter
#let sig-left = 3.0in                  // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt             // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single   // Loc. R. 5.1(C): double spaced (32.2 pt, the pitch measured on the filed exemplar)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown chunk to content, with a level-1 heading for `#`.
#let md(t) = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court name, centered, single spaced (Loc. R. 5.1(B): the case style begins the first page).
#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "NORTHERN DISTRICT OF FLORIDA")))
  line-block(align(center, text(weight: "bold", upper(meta.division))))
}

/// Case style (Loc. R. 5.1(B)): the parties on the left, the case number with the judges' initials on the
/// right. The party column is closed by a rule at its foot. Each party: its names, then its designation;
/// "v." between the parties, a single line clear of each (as filed).
#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, inset: (right: caption-inset, bottom: caption-pad), stroke: (bottom: 0.75pt), {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: pitch-single, below: pitch-single, "v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block("CASE NO.")
    line-block(inl(meta.case_number))
  }),
))

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block (Loc. R. 5.1(D)): the date, then "Respectfully submitted," and the signing attorney's
/// electronic signature, typed name, bar number, street and email addresses, telephone, and the party served. A
/// single line clear before the firm and before the signer; the block never breaks across a page.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: pitch-double, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    let firm = meta.signature.at("firm", default: ())
    for (k, l) in firm.enumerate() { line-block(above: if k == 0 { pitch-single } else { 0pt }, inl(l)) }
    line-block(above: pitch-single, inl(meta.signature.by))
    for l in meta.signature.at("lines", default: ()) { line-block(inl(l)) }
  },
))

/// A body paragraph at the double pitch with a first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Body paragraphs are unnumbered (a memorandum, Loc. R. 7.1(E)): each blank-line-separated chunk of markdown
/// is one paragraph with a first-line indent; a list is set as its own block. Headings come from the chunks
/// that start with `#`. The signature block closes the memorandum: it is set before a certificate of service
/// (Loc. R. 5.1(F)) when the sample has one, and at the end otherwise.
#let body(text-body, meta) = {
  let chunks = text-body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let signed = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      if t.contains("CERTIFICATE OF SERVICE") and not signed {
        signature-block(meta)
        signed = true
      }
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else {
      body-par(md(t))
    }
  }
  if not signed { signature-block(meta) }
}

#let flnd-motion-brief(meta, text-body) = {
  // Page numbers centered on every page (Loc. R. 5.1(C)), at the type size, in a single-spaced line box.
  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (Loc. R. 5.1(C): double spaced); list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: list-box)

  // Headings at the type size, bold. Level 1 (I. INTRODUCTION; the statements and certificates): centered
  // capitals at the body pitch, no space of their own, as filed. Level 2 (A. ...): at the margin, single spaced
  // with the lines after the first hanging, a single line clear above and below (as filed). Sticky: a heading never
  // ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", upper(it.body))))
    } else {
      block(sticky: true, width: 100%, above: pitch-single, below: pitch-single, {
        set text(..edges(pitch-single))
        par(hanging-indent: heading-hang, text(weight: "bold", it.body))
      })
    }
  }

  court-title(meta)
  caption(meta)
  // The title of the paper (Loc. R. 5.1(B)): centered bold, a double line clear of the caption and the text.
  block(width: 100%, above: pitch-double, below: pitch-double, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", inl(meta.brief_title)))
  })

  // The lead-in paragraph is unnumbered and states the relief sought.
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  body(text-body, meta)
}
