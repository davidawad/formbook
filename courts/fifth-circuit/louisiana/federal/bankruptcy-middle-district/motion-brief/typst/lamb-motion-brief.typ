// U.S. Bankruptcy Court, M.D. La.: motion with incorporated memorandum (FRBP 9013; the court's
// Local Rules 9013-1 (motions), 9013-2 (memoranda), 5005-2 (format), 9013-4 (service), 9013-5 (orders)).
//
// Rule-driven and content-agnostic. Requirement IDs (LAMB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed pleading, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // vendored in /fonts (no system font is used)
#let type-size = 12pt                   // LAMB-FORM-002: LR 5005-2(b), 12-point font (footnotes too)
#let body-leading = 0.7em               // LAMB-FORM-003: LR 5005-2(b), double-spaced; calibrated, see README
#let single-leading = 0em               // caption, block quotations, notice and signature: single-spaced
#let page-margin = 1in                  // LAMB-FORM-001: 8.5 x 11 page (LR 5005-2(a)); margins are a style choice
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-stroke = 0.7pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// Fail loudly when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("lamb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption (Form 416 style for an adversary proceeding; the main-case caption when no parties are given).
#let caption(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  set block(spacing: single-leading)
  align(center)[#strong[UNITED STATES BANKRUPTCY COURT]]
  align(center)[#strong[MIDDLE DISTRICT OF LOUISIANA]]
  v(0.25in)
  let adversary = "plaintiff" in meta
  grid(
    columns: (1fr, 1fr),
    gutter: 0.25in,
    block(width: 100%, stroke: (right: caption-stroke, bottom: caption-stroke), inset: (right: 0.12in, bottom: 0.12in))[
      #block[In re:]
      #v(single-leading)
      #block[#need(meta, "debtor")]
      #block[#h(1.5in) Debtor.]
      #if adversary [
        #v(0.9em)
        #for line in meta.plaintiff [
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
      ]
    ],
    block(width: 100%, inset: (left: 0.1in))[
      #block[Case No. #need(meta, "case_no")]
      #v(single-leading)
      #block[#need(meta, "chapter")]
      #if "adv_no" in meta [
        #v(single-leading)
        #block[Adversary Proceeding No. #meta.adv_no]
      ]
    ],
  )
  v(0.35in)
}

/// Notice of motion and opportunity for hearing (LR 9013-1(b)(2)(i)-(iii)). The wording of the
/// objection deadline follows the rule; the hearing details come from metadata.
#let notice(meta) = {
  let h = need(meta, "hearing")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))
  set block(spacing: body-leading)
  block(width: 100%, sticky: true)[
    #align(center)[#strong[NOTICE OF MOTION AND OPPORTUNITY FOR HEARING]]
  ]
  block(width: 100%)[PLEASE TAKE NOTICE that the motion titled "#need(meta, "title")" has been filed. The motion seeks #need(meta, "relief")]
  block(width: 100%)[A hearing on the motion is set for #need(h, "date") at #need(h, "time"), in #need(h, "place").]
  block(width: 100%)[Any party opposing the motion must file an objection or response no later than eight days before the scheduled hearing and must at the same time serve a copy of the objection or response on the mover or its counsel, and on all other parties entitled to notice of the objection.]
  v(body-leading)
}

/// Signature block with the contact details LR 9013-1(a) requires on a motion.
#let signature(meta) = {
  let sig = need(meta, "signature")
  let contact = need(meta, "contact")
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
        #v(single-leading)
        #block[#emph(need(contact, "address"))]
        #block[#emph("Telephone: " + need(contact, "phone"))]
        #block[#emph("Email: " + need(contact, "email"))]
      ],
    )
  ]
}

// ---------------------------------------------------------------------------
// Entry: the whole motion
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("title", "relief", "hearing", "debtor", "case_no", "chapter", "date", "signature", "contact") {
    let _ = need(meta, k)
  }
  if "plaintiff" in meta { let _ = need(meta, "defendants") }

  // ---- document-wide settings ----
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set quote(block: true)
  show quote: it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: body-leading, below: body-leading)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Headings are body size (LAMB-FORM-002): typst's built-in heading sizes are not used.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    #set text(size: type-size)
    #align(center)[#strong(upper(plain(it.body)))]
  ]
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    #set text(size: type-size)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true)[
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    #set text(size: type-size)
    #strong(emph(it.body))
  ]
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.5em)
    it
  }

  // ---- first page: caption, title, notice ----
  caption(meta)
  align(center)[#strong(upper(need(meta, "title")))]
  v(body-leading)
  notice(meta)

  // ---- body: the motion and the incorporated memorandum (LR 9013-2) ----
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  // ---- signature ----
  signature(meta)
}
