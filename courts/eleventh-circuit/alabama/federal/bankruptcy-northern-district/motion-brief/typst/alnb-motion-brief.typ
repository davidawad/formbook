// U.S. Bankruptcy Court, N.D. Alabama: motion with memorandum (Fed. R. Bankr. P. 9013, 9014, 7012(b)).
//
// Rule-driven and content-agnostic. Requirement IDs (ALNB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // vendored in fonts/; the only font typst can see (tools/render.sh)
#let type-size = 12pt                   // style choice: N.D. Ala. local rules set no type size (see ../README.md)
#let body-leading = 1.0em               // gap between body lines; with glyph-bounds line boxes (see text edges in the entry point) the body is double-spaced (~24 pt pitch)
#let single-leading = 0.4em             // caption, counsel block, signature block, certificate of service
#let para-gap = 0.9em                   // space after each body paragraph; each paragraph is a block so its first line cannot collide with the previous one
#let para-indent = 0.5in                // first-line indent of text paragraphs
#let designation-indent = 2.25in        // "Plaintiff," / "Debtor." lines in the caption sit this far in
#let caption-left = 3.35in              // width of the caption column that holds the party names
#let caption-mid = 0.4in                // width of the ")" column
#let sig-indent = 3.25in                // signature block starts this far in (right half of the page)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, citations) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alnb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Designations in the caption ("Plaintiff,", "Defendants.") are indented; other caption lines are not.
#let designation-re = regex("^(Plaintiffs?|Defendants?|Debtors?|Movants?|Respondents?|Counter-?\\w*)[,.]$")

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b): court, title, case number, designation of the paper)
// ---------------------------------------------------------------------------

/// One caption row: left party text, the ")" column, right case text.
#let caption-row(l, r) = grid(
  columns: (caption-left, caption-mid, 1fr),
  align: (left + top, center + top, left + top),
  {
    set par(leading: single-leading)
    pad(left: if l.match(designation-re) != none { designation-indent } else { 0pt }, inl(l))
  },
  [)],
  {
    set par(leading: single-leading)
    inl(r)
  },
)

/// A caption block: `left` lines and `right` lines are paired row by row; the ")" column runs down
/// every row, so the block closes on the same line as the last party name.
#let caption-block(blk) = {
  let left = blk.at("left", default: ())
  let right = blk.at("right", default: ())
  let n = calc.max(left.len(), right.len())
  for i in range(n) {
    caption-row(
      if i < left.len() { left.at(i) } else { "" },
      if i < right.len() { right.at(i) } else { "" },
    )
  }
}

// ---------------------------------------------------------------------------
// Signature block (the signer's name, firm or agency, address, telephone and email, as both exemplars set it out)
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(breakable: false)[
  #set par(leading: single-leading)
  #v(1.2em)
  Dated: #sig.date
  #v(0.9em)
  #pad(left: sig-indent)[
    Respectfully submitted,
    #v(1.5em)
    #for l in sig.lead [#l\ ]
    #v(0.6em)
    /s/ #sig.signer\
    #for l in sig.lines [#l\ ]
    #if "of_counsel" in sig [
      #v(0.6em)
      #for l in sig.of_counsel [#l\ ]
    ]
  ]
]

// ---------------------------------------------------------------------------
// Certificate of service: the parties served by CM/ECF, by name and address, as both motion exemplars
// set it out (Fed. R. Civ. P. 5(b)(2) is the service rule the Wright exemplar cites; see ../README.md)
// ---------------------------------------------------------------------------

#let certificate-block(cert) = block(breakable: false)[
  #set par(leading: single-leading)
  #v(1.4em)
  #align(center, text(weight: "bold", upper("Certificate of Service")))
  #v(0.9em)
  #block(width: 100%, below: para-gap)[#h(para-indent)#inl(cert.text)]
  #for party in cert.served [
    #pad(left: para-indent)[
      #for l in party [#l\ ]
    ]
    #v(0.6em)
  ]
  #v(0.6em)
  #pad(left: sig-indent)[
    /s/ #cert.signer\
    #for l in cert.signer_lines [#l\ ]
  ]
]

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let alnb-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
    footer: context align(center, text(size: 11pt, counter(page).display())),
  )
  // Glyph-bounds line boxes: EB Garamond's default line box is shorter than its glyphs, so stacked
  // caption rows collide without them.
  set text(font: font-family, size: type-size, lang: "en", top-edge: "bounds", bottom-edge: "bounds")
  set par(leading: body-leading, justify: false, spacing: 0pt)

  // Court title, centered, one line per entry (Fed. R. Bankr. P. 9004(b): caption).
  for l in need(meta, "court") {
    block(width: 100%, below: single-leading, align(center, upper(l)))
  }
  v(1.6em)

  // Caption: debtor block, then the adversary proceeding block.
  for blk in need(meta, "caption") {
    caption-block(blk)
    v(1.1em)
  }

  // Title of the paper, centered and bold.
  align(center, block(above: 0.8em, below: 1.4em, text(weight: "bold", upper(need(meta, "title")))))

  // Body. Blocks are separated by blank lines. "#" blocks are section headings (Roman numerals, level
  // one centered, level two flush left with a hanging letter); "[^n]:" blocks are footnote definitions
  // and attach to the paragraph before them. Every other block is an unnumbered paragraph: a motion
  // states its grounds in prose, not in numbered allegations (Fed. R. Bankr. P. 9013).
  {
    let blocks = body.split("\n\n").map(s => s.trim()).filter(s => s != "")
    let grouped = blocks.fold((), (acc, b) => if b.starts-with("[^") and acc.len() > 0 {
      acc.slice(0, -1) + (acc.last() + "\n\n" + b,)
    } else {
      acc + (b,)
    })

    for b in grouped {
      if b.starts-with("#") {
        let lvl = b.match(regex("^#+")).text.len()
        let txt = b.slice(lvl).trim()
        if lvl == 1 {
          block(width: 100%, above: 1.1em, below: 0.9em, sticky: true, align(center, text(weight: "bold", inl(txt))))
        } else {
          block(width: 100%, above: 0.9em, below: 0.9em, sticky: true, pad(left: 0.5in, text(weight: "bold", inl(txt))))
        }
      } else {
        block(width: 100%, below: para-gap)[#h(para-indent)#inl(b)]
      }
    }
  }

  // Signature block, after the prayer.
  signature-block(need(meta, "signature"))

  // Certificate of service: the parties served through CM/ECF, by name and address.
  if "certificate" in meta {
    certificate-block(meta.certificate)
  }
}
