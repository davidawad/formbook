// U.S. Bankruptcy Court, M.D. Alabama: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (ALMB-ADV-...) refer to ../README.md, which quotes
// the rule text (FRBP 7008(a), 7010, 9004; FRCP 10; LBR 7005-1, 9011-1). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata
// comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Vendored in /fonts. No M.D. Ala. typography rule exists (see ../README.md, gaps).
#let type-size = 13pt                    // Style choice: EB Garamond sits smaller than Times, so 13 pt reads like the filed 12 pt Times.
#let line-pitch = 24pt                   // Double spacing, as the filed complaint (convention, see ../README.md).
#let body-leading = 0.54em               // Gap between lines of body text; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // Caption, counsel block, signature, headings, tables.
#let page-margin = 1in                   // Style choice (no local margin rule; FRBP 9004(a) requires legibility only).
#let margins = (top: page-margin, bottom: page-margin, x: page-margin)
#let para-indent = 0.5in
#let footer-size = 11pt                  // Page number only.
#let caption-col = 3.3in                 // Width of the boxed party column of the Form 416D-style caption.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("almb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 7010: caption must substantially conform to Form 416D; FRBP 9004(b): court, title, case
// number, adversary number, designation of the document)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "court").map(l => [#l]).join(linebreak())))
}

#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [IN RE:]
    v(line-pitch * 0.5)
    for n in debtor.name { pad(left: 0.5in, inl(n)); linebreak() }
    v(line-pitch * 0.5)
    line(length: 100%, stroke: 0.7pt)
    v(line-pitch * 0.5)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); linebreak() }
      pad(left: 0.5in, inl(side.designation))
      v(line-pitch * 0.5)
      if i < sides.len() - 1 { align(center)[v.]; v(line-pitch * 0.5) }
    }
  }
  let rightcol = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    v(line-pitch * 2.2)
    [CASE NO. #debtor.case_number]
    v(line-pitch * 2.5)
    // FRBP 9004(b): the adversary number is assigned by the clerk; the blank is printed when none is given.
    let adv = meta.at("adversary_number", default: "")
    if adv == "" [ADV. PROC. NO. #box(width: 1.2in, line(length: 100%, stroke: 0.5pt))] else [ADV. PROC. NO. #adv]
  }
  table(
    columns: (caption-col, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { 0.7pt } else { none },
    pad(x: 0.12in, top: 0.6em, bottom: 1em, left),
    pad(left: 1.2em, rightcol),
  )
}

// ---------------------------------------------------------------------------
// Consent statement (FRBP 7008(a): a complaint must state whether the pleader does or does not consent
// to the entry of final orders or judgment by the bankruptcy court). Placed under the caption so a
// reviewer finds it on page 1; the body does not repeat it.
// ---------------------------------------------------------------------------

#let consent-block(meta) = {
  let j = need(meta, "jurisdiction")
  let debtor = need(meta, "debtor")
  let name = debtor.name.first()
  block(breakable: false, width: 100%, above: line-pitch * 0.5, below: body-leading, {
    set par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, justify: false)
    align(center, strong[Jurisdiction and Consent])
    v(0.4em)
    par({
      [This adversary proceeding arises in and relates to the #inl(debtor.chapter) case of #inl(name), Case No. #debtor.case_number, pending in the United States Bankruptcy Court for the #j.district.]
    })
    par(inl(need(j, "consent")))
  })
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9011-1(a): full name, at least one mailing address, at least one telephone number,
// and an email address for each signer; LBR 9011-1(b): /s/ is an acceptable signature)
// ---------------------------------------------------------------------------

#let signer-lines(sig) = {
  [/s/ #sig.signer]
  linebreak()
  for l in sig.at("lines", default: ()) { inl(l); linebreak() }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  // Unbreakable (about half a page), so the firm name never separates from its signers.
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), if "date" in meta [Dated: #meta.date] else [], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      inl(sig.firm)
      linebreak()
      v(line-pitch * 0.5)
      signer-lines(sig)
      for also in sig.at("also", default: ()) {
        v(line-pitch * 0.5)
        [-and-]
        v(line-pitch * 0.5)
        signer-lines(also)
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

/// Numbered allegation: "N. text" (FRCP 10(b): each averment in numbered paragraphs). The number is the one
/// written in the markdown, so a paragraph keeps its number whatever the page break.
#let allegation(b) = {
  let m = b.match(regex("^(\\d+)\\.\\s+([\\s\\S]*)$"))
  if m == none { return none }
  par(first-line-indent: para-indent, [#m.captures.at(0).#h(0.5em)#inl(m.captures.at(1))])
}

#let almb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "caption", "title", "jurisdiction", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "-1-", footer: context {
    set text(size: footer-size)
    align(center, numbering("-1-", ..counter(page).get()))
  })
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0.9em,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  show heading: it => {
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(it.body)))
    }
  }
  show table: it => block(above: line-pitch * 0.5, below: line-pitch * 0.5, breakable: false, {
    set text(size: type-size)
    it
  })

  // ---- first page: court, caption, title, consent ----
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  // ---- consent statement, then the body (lead-in, headings, numbered allegations) and the signature ----
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  consent-block(meta)
  // The last block (the prayer) is kept with the signature block so the signature never stands alone.
  let blocks = md.trim().split("\n\n")
  // Each markdown block becomes its own block-level item, so consecutive paragraphs never run together.
  for b in blocks.slice(0, -1) {
    let t = b.trim()
    if t.starts-with("#") {
      heading(level: 1, t.trim("#").trim())
    } else {
      let a = allegation(t)
      // A block starts its first paragraph without a first-line indent, so the indent is drawn as a leading space.
      let body = cmarker.render(t, raw-typst: false, smart-punctuation: true)
      block(width: 100%, above: 0pt, below: 0pt, if a != none { a } else if t.starts-with(">") { body } else { h(para-indent) + body })
    }
  }
  // The prayer is sticky to the signature block that follows it; the signature block is unbreakable on its own.
  let last = blocks.last().trim()
  let a = allegation(last)
  block(sticky: true, width: 100%, if a != none { a } else { par(first-line-indent: para-indent, inl(last)) })
  signature-block(meta)
}
