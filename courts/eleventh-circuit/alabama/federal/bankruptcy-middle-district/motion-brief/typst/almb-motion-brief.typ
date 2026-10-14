// U.S. Bankruptcy Court, M.D. Alabama: motion with its grounds in numbered paragraphs (contested matter).
//
// Rule-driven and content-agnostic. Requirement IDs (ALMB-MOT-...) refer to ../README.md, which quotes the
// rule text (FRBP 9013(b), 9004, 9011; LBR 9011-1). No case-specific text, no coordinates measured off an
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Vendored in /fonts. No M.D. Ala. typography rule exists (see ../README.md, gaps).
#let type-size = 13pt                    // Style choice, matched to the adversary complaint in this court.
#let line-pitch = 24pt                   // Double spacing (convention; no local rule).
#let body-leading = 0.54em               // Gap between lines of body text; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // Caption, counsel block, signature, headings.
#let page-margin = 1in                   // Style choice (FRBP 9004(a) requires legibility only).
#let margins = (top: page-margin, bottom: page-margin, x: page-margin)
#let para-indent = 0.5in
#let footer-size = 11pt
#let caption-col = 3.3in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("almb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b): court, title, case number, designation; FRBP 9013 motions in a main case: no
// adversary-proceeding number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "court").map(l => [#l]).join(linebreak())))
}

#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [IN RE:]
    v(line-pitch * 0.5)
    for n in debtor.name { pad(left: 0.5in, inl(n)); linebreak() }
    v(line-pitch * 0.5)
    line(length: 100%, stroke: 0.7pt)
  }
  let rightcol = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    v(line-pitch * 1.2)
    [CASE NO. #debtor.case_number]
    v(line-pitch * 0.5)
    inl(debtor.chapter)
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
// Signature block (LBR 9011-1(a): full name, a mailing address, a telephone number and an email address for
// each signer; LBR 9011-1(b): /s/ is an acceptable signature)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), if "date" in meta [Dated: #meta.date] else [], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      inl(sig.firm)
      linebreak()
      v(line-pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

/// Numbered paragraph: "N. text" (the number is the one written in the markdown).
#let numbered(b) = {
  let m = b.match(regex("^(\\d+)\\.\\s+([\\s\\S]*)$"))
  if m == none { return none }
  par(first-line-indent: para-indent, [#m.captures.at(0).#h(0.5em)#inl(m.captures.at(1))])
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let almb-motion-brief(meta, md) = {
  for k in ("court", "debtor", "title", "signature") {
    let _ = need(meta, k)
  }

  set page(paper: "us-letter", margin: margins, numbering: "-1-", footer: context {
    set text(size: footer-size)
    align(center, numbering("-1-", ..counter(page).get()))
  })
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0.9em,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  show heading: it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, strong(if it.level == 1 { upper(it.body) } else { it.body })))
  show table: it => block(above: line-pitch * 0.5, below: line-pitch * 0.5, breakable: false, {
    set text(size: type-size)
    it
  })

  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  // Body: each markdown block is its own block-level item; "# " lines are headings; "N. " lines are numbered.
  let blocks = md.trim().split("\n\n")
  for b in blocks.slice(0, -1) {
    let t = b.trim()
    if t.starts-with("#") {
      heading(level: 1, t.trim("#").trim())
    } else {
      let a = numbered(t)
      let body = cmarker.render(t, raw-typst: false, smart-punctuation: true)
      block(width: 100%, above: 0pt, below: 0pt, if a != none { a } else if t.starts-with(">") { body } else { h(para-indent) + body })
    }
  }
  // The prayer stays with the signature block that follows it.
  let last = blocks.last().trim()
  let a = numbered(last)
  block(sticky: true, width: 100%, if a != none { a } else { par(first-line-indent: para-indent, inl(last)) })
  signature-block(meta)

  // Certificate of service: text from frontmatter, filed with the motion (service under FRBP 9014(b); see README).
  if "certificate" in meta {
    pagebreak(weak: true)
    align(center, strong[CERTIFICATE OF SERVICE])
    v(line-pitch * 0.5)
    par(first-line-indent: para-indent, inl(meta.certificate))
  }
}
