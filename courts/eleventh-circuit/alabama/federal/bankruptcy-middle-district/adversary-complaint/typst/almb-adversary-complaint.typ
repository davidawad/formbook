// U.S. Bankruptcy Court, M.D. Alabama: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (ALMB-ADV-...) refer to ../README.md, which quotes
// the rule text (FRBP 7008(a), 7010, 9004; FRCP 10; LBR 7005-1, 9011-1). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata
// comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No M.D. Ala. typography rule exists; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Convention: 12 pt, the size of the filed complaint (no local rule sets a size).
#let page-margin = 1in                   // Style choice (no local margin rule; FRBP 9004(a) requires legibility only).
#let para-indent = 0.5in
#let footer-size = 11pt                  // Page number only.
#let caption-col = 3.3in                 // Width of the boxed party column of the Form 416D-style caption.
#let caption-inset = 0.12in              // The party text stands off the box's rules.
#let right-inset = 0.2in                 // The case-number column stands off the box.
#let sig-col = 3.2in                     // The signature block: a column at the right margin.
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // Double spacing, as the filed complaint (convention, see ../README.md).
#let pitch-single = 13.8pt               // A single line: 1.15 x the type size (Word's single line in this face).
#let pitch-footer = 1.15 * footer-size
#let gap = pitch-single                  // The space between the groups of the caption and the signature block.

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

/// One single-spaced paragraph of its own, with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Caption (FRBP 7010: caption must substantially conform to Form 416D; FRBP 9004(b): court, title, case
// number, adversary number, designation of the document)
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in need(meta, "court") { line-block(align(center, strong(inl(l)))) }

/// The boxed left column in two parts, "IN RE:" and the debtor above the rule, the parties below it; the case
/// number beside the first, the adversary number beside the second.
#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let top = {
    line-block[IN RE:]
    for (i, n) in debtor.name.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, indent: para-indent, inl(n)) }
  }
  let bottom = {
    for (i, side) in sides.enumerate() {
      for (k, n) in side.names.enumerate() { line-block(above: if k == 0 and i > 0 { gap } else { 0pt }, inl(n)) }
      line-block(indent: para-indent, inl(side.designation))
      if i < sides.len() - 1 { line-block(above: gap, align(center)[v.]) }
    }
  }
  // FRBP 9004(b): the adversary number is assigned by the clerk; a blank is printed when none is given.
  let adv = meta.at("adversary_number", default: "")
  let box-cell(c) = pad(x: caption-inset, y: pitch-single / 2, c)
  let right-cell(c) = align(horizon, pad(left: right-inset, c))
  block(above: pitch-double, below: 0pt, table(
    columns: (caption-col, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { rule } else { none },
    box-cell(top), right-cell(line-block[CASE NO. #debtor.case_number]),
    box-cell(bottom), right-cell(line-block(if adv == "" [ADV. PROC. NO. \_\_\_\_\_\_\_\_\_\_\_\_] else [ADV. PROC. NO. #adv])),
  ))
}

// ---------------------------------------------------------------------------
// Consent statement (FRBP 7008(a): a complaint must state whether the pleader does or does not consent
// to the entry of final orders or judgment by the bankruptcy court). Placed under the caption so a
// reviewer finds it on page 1; the body does not repeat it.
// ---------------------------------------------------------------------------

#let consent-block(meta) = {
  let j = need(meta, "jurisdiction")
  let debtor = need(meta, "debtor")
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong[Jurisdiction and Consent]))
  block(width: 100%, above: 0pt, below: 0pt, par[This adversary proceeding arises in and relates to the #inl(debtor.chapter) case of #inl(debtor.name.first()), Case No. #debtor.case_number, pending in the United States Bankruptcy Court for the #inl(j.district).])
  block(width: 100%, above: 0pt, below: 0pt, par(inl(need(j, "consent"))))
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9011-1(a): full name, at least one mailing address, at least one telephone number,
// and an email address for each signer; LBR 9011-1(b): /s/ is an acceptable signature)
// ---------------------------------------------------------------------------

#let signer-lines(sig, above) = {
  line-block(above: above)[/s/ #inl(sig.signer)]
  for l in sig.at("lines", default: ()) { line-block(inl(l)) }
}

/// The date (when given) at the margin, then the signature column at the right margin; one block that never
/// breaks across a page, so the firm name never separates from its signers.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-single, below: 0pt, {
    if "date" in meta { line-block[Dated: #inl(meta.date)] }
    grid(columns: (1fr, sig-col), [], {
      line-block[Respectfully submitted,]
      line-block(above: gap, inl(sig.firm))
      signer-lines(sig, gap)
      for also in sig.at("also", default: ()) {
        line-block(above: gap)[-and-]
        signer-lines(also, gap)
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

/// A body paragraph. "N. text" is a numbered allegation (FRCP 10(b)): the number is the one written in the
/// markdown, so a paragraph keeps its number whatever the page break.
#let body-par(t) = {
  let m = t.match(regex("^(\\d+)\\.\\s+([\\s\\S]*)$"))
  if t.starts-with(">") { return cmarker.render(t, raw-typst: false, smart-punctuation: true) }
  block(width: 100%, above: 0pt, below: 0pt, par(if m != none [#m.captures.at(0). #inl(m.captures.at(1))] else { inl(t) }))
}

#let almb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "caption", "title", "jurisdiction", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: page-margin, numbering: "-1-", footer-descent: 30%, footer: context {
    set text(size: footer-size, ..edges(pitch-footer))
    align(center, numbering("-1-", ..counter(page).get()))
  })
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number ("§§ 1408"), as the docx engine binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Headings at the body size and pitch, centered, bold capitals; no space of their own. Sticky: a heading never
  // ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(it.body))))
  }
  // Quotations single-spaced (convention), indented half an inch both sides, half a double line off the text.
  show quote.where(block: true): it => block(width: 100%, above: pitch-double / 2, below: pitch-double / 2, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })

  // ---- first page: court, caption, title, consent ----
  court-title(meta)
  caption-table(meta)
  block(above: pitch-double, below: pitch-single, line-block(align(center, strong(upper(inl(need(meta, "title")))))))
  consent-block(meta)

  // ---- the body (lead-in, headings, numbered allegations, quotations) and the signature ----
  for b in md.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(b => b.trim() != "") {
    let t = b.trim()
    if t.starts-with("#") { heading(level: 1, t.trim("#").trim()) } else { body-par(t) }
  }
  signature-block(meta)
}
