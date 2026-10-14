// U.S. Bankruptcy Court, M.D. Pennsylvania: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (PAMB-ADV-...) refer to ../README.md, which quotes
// the rule text (FRBP 7008, 7010, 9004; L.B.R. 7003-1, 9004-1). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata
// comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Vendored in /fonts. No M.D. Pa. font rule found (see ../README.md, gaps).
#let type-size = 13pt                    // Style choice: EB Garamond runs smaller than Times at the same point size, so 13 pt reads like the filed 12 pt Times.
#let line-pitch = 24pt                   // Double spacing, as the filed complaint (convention, see ../README.md).
#let body-leading = 0.54em               // Gap between lines of body text; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // Caption, counsel block, signature, headings, tables.
#let page-margin = 1in                   // Style choice (no local margin rule found).
#let margins = (top: page-margin, bottom: page-margin, x: page-margin)
#let para-indent = 0.5in
#let footer-size = 11pt                  // Page number only.
#let number-indent = 0.5in               // Where the allegation numbers sit (FRCP 10(b), numbered paragraphs).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("pamb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Caption (FRBP 7010; FRCP 10(a); L.B.R. 9004-1 and Official Form 416D)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
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
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    inl(debtor.chapter)
    v(line-pitch * 0.5)
    [Case No. #debtor.case_number]
    v(line-pitch * 0.5)
    // FRBP 7010 / Form 416D: the adversary number is supplied by the clerk; the blank is printed when none is given.
    let adv = meta.at("adversary_number", default: "")
    if adv == "" [Adversary No. #box(width: 1.6in, line(length: 100%, stroke: 0.5pt))] else [Adversary No. #adv]
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

// ---------------------------------------------------------------------------
// Statement of jurisdiction (FRBP 7008(a))
// ---------------------------------------------------------------------------

/// FRBP 7008(a): the jurisdiction allegation names the case (name, number, chapter) and the district, and
/// states whether the proceeding is core or non-core and whether the pleader consents to final orders.
/// The sentence that names the case is generated from the metadata; the core and consent statements are
/// written by the pleader and must be present (the template refuses to build without them).
#let jurisdiction-block(meta) = {
  let j = need(meta, "jurisdiction")
  let debtor = need(meta, "debtor")
  let name = debtor.name.first()
  block(above: line-pitch * 0.5, below: 0pt, sticky: true, align(center, strong[Statement of Jurisdiction]))
  par(first-line-indent: para-indent, {
    [This adversary proceeding arises in and relates to the #inl(debtor.chapter) case of #inl(name), Case No. #debtor.case_number, pending in the United States Bankruptcy Court for the #j.district.]
  })
  par(first-line-indent: para-indent, inl(need(j, "core")))
  par(first-line-indent: para-indent, inl(need(j, "consent")))
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011; convention: no rule prescribes the layout)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), if "date" in meta [Dated: #meta.date] else [], {
      [Respectfully submitted,]
      v(line-pitch)
      inl(sig.firm)
      linebreak()
      v(line-pitch)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      if "id" in sig { inl(sig.id); linebreak() }
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let pamb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "caption", "title", "jurisdiction", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: context {
    set text(size: footer-size)
    align(center, numbering("1", ..counter(page).get()))
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
  // Numbered allegations (FRCP 10(b)): each paragraph is numbered from 1, number at the left, text after it.
  set enum(numbering: "1.", indent: number-indent, body-indent: 0.5em)
  show enum: set par(first-line-indent: 0pt)
  show enum.item: it => block(breakable: true, above: 0pt, below: 0pt, leading: body-leading, it)
  show table: it => block(above: line-pitch * 0.5, below: line-pitch * 0.5, breakable: false, {
    set text(size: type-size)
    it
  })
  show heading: it => {
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, strong(it.body))
    }
  }

  // ---- first page: court, caption, title ----
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  // ---- statement of jurisdiction (FRBP 7008(a)), then the lead-in and the numbered allegations (cmarker), then the signature ----
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  jurisdiction-block(meta)
  // The last paragraph (the prayer) is sticky with the signature block so the signature never stands alone.
  let paras = md.trim().split("\n\n")
  cmarker.render(paras.slice(0, -1).join("\n\n"), raw-typst: false, smart-punctuation: true)
  // A block starts its first paragraph without a first-line indent; the indent is drawn as a leading space.
  block(sticky: true, h(para-indent) + cmarker.render(paras.last(), raw-typst: false, smart-punctuation: true))
  signature-block(meta)
}
