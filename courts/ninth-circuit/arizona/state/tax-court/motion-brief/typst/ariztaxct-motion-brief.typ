// Arizona Tax Court (ariztaxct): motion with memorandum (motion-brief).
//
// Content-agnostic. The cover is generated from the metadata (court names, caption, judge, title,
// counsel block); the body is the motion and memorandum. No case-specific text, no coordinates
// measured off the filed exemplar, no forced line breaks. The layout follows the one filed
// exemplar (usage/FILED-EXAMPLE-motion-brief.pdf) for the cover and the body; the court's form
// rules are NOT yet recorded (see ../../rules.md: BLOCKED), so the numbers below are the exemplar's
// face and spacing, not a mandated form. Replace them when the rules are retrieved.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // the exemplar's face; Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 13pt                    // the exemplar's body size (not yet tied to a rule; see rules.md).
#let body-leading = 1.65em               // double spacing at this size.
#let single-leading = 0.45em             // headings, block quotations, footnotes, caption and counsel blocks.
#let page-margin = 1in
#let para-indent = 0.5in
#let caption-gutter = 0.15in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ariztaxct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ariztaxct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: its names on lines of their own, then the designation indented.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  for n in side.names [ #inl(n) \ ]
  v(0.6em)
  pad(left: 1.4in, emph(side.designation))
}

/// Counsel block: the names and the lines beneath them, single-spaced.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block after the body: the closing line, the /s/ signer and the lines beneath.
#let signature-block(sig) = {
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "lines" in sig {
      for l in sig.lines [ #inl(l) \ ]
    }
  ]
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ariztaxct-motion-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)
  // Bullets in the face's own glyphs (the default nested marker is a glyph Liberation Serif lacks).
  set list(marker: ([•], [–]))

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left, hanging). The author types the numbering.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: body size, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Cover (unnumbered) ----
  // Counsel block at the top left, the court names centred, then the caption: parties at left,
  // case number, title and judge at right, the party column ruled on its right and bottom.
  {
    set par(leading: single-leading, first-line-indent: 0pt)
    for g in need(meta, "counsel") { counsel-group(g) }
    if "attorneys_for" in meta { emph(inl(meta.attorneys_for)) }
    v(0.7in)
    align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #for c in need(meta, "court") [ #strong(inl(c)) \ ]
    ]
    v(0.5in)
    grid(
      columns: (3.95in, 1fr),
      column-gutter: caption-gutter,
      block(
        width: 100%,
        stroke: (right: 0.75pt + black, bottom: 0.75pt + black),
        inset: (right: 0.12in, bottom: 0.12in),
        {
          let sides = need(meta, "caption")
          for (i, side) in sides.enumerate() {
            if i > 0 { pad(left: 0.7in, [ v. ]); v(0.6em) }
            caption-side(side)
          }
          v(0.4em)
        },
      ),
      block(inset: (left: 0.15in), {
        set par(leading: single-leading, first-line-indent: 0pt)
        [ Case No. #inl(need(meta, "case_number")) ]
        v(1.2em)
        strong(upper(inl(need(meta, "brief_title"))))
        if "judge" in meta {
          v(1.2em)
          [ (#inl(meta.judge)) ]
        }
      }),
    )
  }

  pagebreak()

  // ---- Body (numbered from 1) ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the body ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: 0pt)[
      RESPECTFULLY SUBMITTED this #inl(need(meta, "date")) by:
    ]
    #v(0.5em)
    #pad(left: 0in)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #underline[/s/ #emph(need(meta, "signature").signer)]
      #v(0.3em)
      #signature-block(need(meta, "signature"))
    ]
  ]

  // ---- Certificates (generated from metadata) ----
  for c in meta.at("certificates", default: ()) {
    if c.type == "service" {
      pagebreak()
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      v(0.8em)
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
      cmarker.render(c.text, raw-typst: false, smart-punctuation: true)
    }
  }
}
