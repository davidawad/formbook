// U.S. Bankruptcy Court, M.D. La.: adversary complaint (FRBP 7001; FRBP 7010 applies
// Fed. R. Civ. P. 10 with the Form 416 caption; FRBP 7008 jurisdiction and consent).
//
// Rule-driven and content-agnostic. Requirement IDs (LAMB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed pleading, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LAMB-FORM-002: LR 5005-2(b), 12-point font
#let body-leading = 1.503em             // LAMB-FORM-003: LR 5005-2(b), double-spaced = twice the single line pitch (single pitch 1.305em: Liberation Serif line box 1.107em hhea ascender to descender + the single leading); see README
#let single-leading = 0.198em             // caption, headings and signature block: single-spaced
#let page-margin = 1in                  // LAMB-FORM-001: 8.5 x 11 page (LR 5005-2(a)); margins are a style choice
#let para-indent = 0.5in                // first-line indent; the paragraph number sits at this indent
#let caption-stroke = 0.7pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fail loudly when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("lamb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption (Form 416 style): court, debtor, parties, case numbers. Every string comes from metadata.
#let caption(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  set block(spacing: single-leading)
  align(center)[#strong[UNITED STATES BANKRUPTCY COURT]]
  align(center)[#strong[MIDDLE DISTRICT OF LOUISIANA]]
  v(0.25in)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.25in,
    block(width: 100%, stroke: (right: caption-stroke, bottom: caption-stroke), inset: (right: 0.12in, bottom: 0.12in))[
      #block[In re:]
      #v(single-leading)
      #block[#need(meta, "debtor")]
      #block[#h(1.5in) Debtor.]
      #v(0.9em)
      #for line in need(meta, "plaintiff") [
        #block[#line]
      ]
      #block[#h(1.5in) Plaintiff,]
      #v(0.45em)
      #block[#h(0.75in) v.]
      #v(0.45em)
      #for line in need(meta, "defendants") [
        #block[#line]
      ]
      #block[#h(1.5in) Defendant.]
    ],
    block(width: 100%, inset: (left: 0.1in))[
      #block[Case No. #need(meta, "case_no")]
      #v(single-leading)
      #block[#need(meta, "chapter")]
      #v(single-leading)
      #block[Adversary Proceeding No. #need(meta, "adv_no")]
    ],
  )
  v(0.35in)
}

/// Paragraph counter for the allegations (FRCP 10(b): numbered paragraphs).
#let para-count = counter("lamb-para")

/// One numbered allegation. The number is generated; the author never types it.
#let numbered(c) = block(width: 100%, sticky: false)[
  #para-count.step()
  #h(para-indent)#context [#para-count.display().] #h(0.3em) #inl(c)
]

/// Section heading: "# TEXT" centred, bold, capitals (the author writes it in any case).
#let section-heading(c) = block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
  #align(center)[#strong(upper(c))]
]

/// Sub-heading: "## Text" bold, left; "### Text" bold italic, left.
#let sub-heading(c) = block(width: 100%, above: single-leading, below: single-leading, sticky: true)[
  #strong(c)
]

#let sub-sub-heading(c) = block(width: 100%, above: single-leading, below: single-leading, sticky: true)[
  #strong(emph(c))
]

/// Prayer or other lettered list: "(a)", "(b)", ... (FRCP 10 practice; the author writes "1." items).
#let lettered(c) = block(width: 100%)[
  #set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.5em)
  #inl(c)
]

/// Split the body into blank-line-separated chunks and typeset each by its first characters.
/// Convention (LAMB-CONT-002): a chunk starting "WHEREFORE" is an unnumbered prayer lead-in.
/// The opening chunk, when it is not a heading, is an unnumbered lead-in too: both filed
/// M.D. La. complaints in exemplars/ leave it unnumbered (Hoven; Criss), and the
/// numbered allegations start after it.
#let body-blocks(body) = {
  let chunks = body.replace("\r\n", "\n").split("\n\n").map(s => s.trim()).filter(s => s != "")
  for (i, c) in chunks.enumerate() {
    if c.starts-with("### ") { sub-sub-heading(c.slice(4)) }
    else if c.starts-with("## ") { sub-heading(c.slice(3)) }
    else if c.starts-with("# ") { section-heading(c.slice(2)) }
    else if c.starts-with("- ") or c.match(regex("^\\d+\\. ")) != none { lettered(c) }
    else if c.starts-with("WHEREFORE") or i == 0 { block(width: 100%)[#h(para-indent)#inl(c)] }
    else { numbered(c) }
  }
}

/// Signature block: "Dated" on the left; "Respectfully submitted", the signer and counsel lines on the right.
#let signature(meta) = {
  let sig = need(meta, "signature")
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  block(width: 100%, sticky: true, above: body-leading)[
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.25in,
      [Dated: #need(meta, "date")],
      [
        #block[Respectfully submitted,]
        #v(body-leading)
        #block[/s/ #sig.signer]
        #for line in sig.lines [
          #block[#emph(line)]
        ]
      ],
    )
  ]
}

// ---------------------------------------------------------------------------
// Entry: the whole complaint
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("title", "debtor", "case_no", "chapter", "adv_no", "plaintiff", "defendants", "date", "signature") {
    let _ = need(meta, k)
  }
  // LAMB-CONT-001: the statement of consent is required (FRBP 7008(a)); the body must state it.
  if not md.contains("consent") {
    panic("lamb-adversary-complaint: the body must state whether the pleader consents to the entry of final orders (FRBP 7008(a))")
  }

  // ---- document-wide settings ----
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: 0pt, justify: false,
  )
  set block(spacing: body-leading)
  set heading(numbering: none)
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.5em)
    it
  }

  // ---- first page: caption and title ----
  caption(meta)
  align(center)[#strong(upper(need(meta, "title")))]
  v(body-leading)

  // ---- body: numbered allegations, headings, prayer ----
  body-blocks(md)

  // ---- signature ----
  signature(meta)
}
