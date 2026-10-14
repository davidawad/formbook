// U.S. Bankruptcy Court, N.D. Alabama: adversary complaint (Fed. R. Bankr. P. 7001, 7008, 7010).
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
#let body-leading = 1.0em               // gap between body lines; with glyph-bounds line boxes (see text edges below) the body is double-spaced (~24 pt pitch)
#let single-leading = 0.4em             // caption, counsel block, headings, signature block
#let para-indent = 0.5in                // first-line indent of text paragraphs
#let number-width = 0.5in               // width of the paragraph-number box that follows the indent
#let designation-indent = 2.25in        // "Plaintiff," / "Debtor." lines in the caption sit this far in
#let caption-left = 3.35in              // width of the caption column that holds the party names
#let caption-mid = 0.4in                // width of the ")" column
#let sig-indent = 3.25in                // signature block starts this far in (right half of the page)
#let para-gap = 0.9em                  // space after each body paragraph; each paragraph is a block so its first line cannot collide with the previous one

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, citations) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alnb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Designations in the caption ("Plaintiff,", "Defendants.") are indented; other caption lines are not.
#let designation-re = regex("^(Plaintiffs?|Defendants?|Debtors?|Movants?|Respondents?|Counter-?\\w*)[,.]$")

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010, Fed. R. Civ. P. 10(a); Form 416)
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
// Signature block (Fed. R. Bankr. P. 9011(a): name, address and telephone of the signer)
// ---------------------------------------------------------------------------

#let signature-block(sig) = block(breakable: false)[
  #set par(leading: single-leading)
  #v(1.2em)
  #grid(columns: (sig-indent, 1fr), [Dated: #sig.date], [])
  #v(0.9em)
  #pad(left: sig-indent)[
    Respectfully submitted,
    #v(1.5em)
    #for (i, s) in sig.signers.enumerate() [
      #if i == 0 [/s/ ]#s\
    ]
    #v(0.6em)
    #for l in sig.firm [#l\ ]
    #v(0.6em)
    #for l in sig.address [#l\ ]
    #v(0.6em)
    #for l in sig.contact [#l\ ]
    #v(0.6em)
    #for l in sig.role [#l\ ]
  ]
]

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let alnb-adversary-complaint(meta, body) = {
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
  show heading: it => block(above: 1.1em, below: 0.9em, sticky: true, width: 100%, align(
    center,
    text(weight: "bold", it.body),
  ))

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

  // Body. Blocks are separated by blank lines. "#" blocks are headings; "[^n]:" blocks are footnote
  // definitions and attach to the paragraph before them; "WHEREFORE" paragraphs are prayers, not
  // numbered allegations. Every other block is a numbered allegation (Fed. R. Civ. P. 10(b)).
  {
    let blocks = body.split("\n\n").map(s => s.trim()).filter(s => s != "")
    let grouped = blocks.fold((), (acc, b) => if b.starts-with("[^") and acc.len() > 0 {
      acc.slice(0, -1) + (acc.last() + "\n\n" + b,)
    } else {
      acc + (b,)
    })

    // Lead-in: the sentence that opens the complaint, not numbered.
    if "lead_in" in meta {
      block(width: 100%, above: 0.4em, below: para-gap)[#h(para-indent)#inl(meta.lead_in)]
    }

    // Consent statement (Fed. R. Bankr. P. 7008(a)): the first numbered allegation.
    let n = 0
    if "consent" in meta {
      n += 1
      block(width: 100%, below: para-gap)[#h(para-indent)#box(width: number-width)[#n.]#inl(meta.consent)]
    }

    for b in grouped {
      if b.starts-with("#") {
        let lvl = b.match(regex("^#+")).text.len()
        heading(level: lvl, numbering: none, outlined: false)[#inl(b.slice(lvl).trim())]
      } else if b.starts-with("WHEREFORE") {
        block(width: 100%, below: para-gap)[#h(para-indent)#inl(b)]
      } else {
        n += 1
        block(width: 100%, below: para-gap)[#h(para-indent)#box(width: number-width)[#n.]#inl(b)]
      }
    }
  }

  // Signature block, after the prayer.
  signature-block(need(meta, "signature"))
}
