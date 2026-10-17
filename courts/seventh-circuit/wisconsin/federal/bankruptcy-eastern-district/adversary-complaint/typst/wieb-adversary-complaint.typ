// U.S. Bankruptcy Court, E.D. Wis.: adversary complaint (FRBP 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // LR 9004-1(a) allows any proportional font; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                      // WIEB-FORM-001: proportional font not smaller than 12-point.
#let body-leading = 1.345em                // WIEB-FORM-002: double-spaced body; tuned by pdftotext -bbox (README).
#let single-leading = 0.55em               // caption, headings, blocks: single-spaced (pitch about 14 pt).
#let page-margin = 1in                     // WIEB-FORM-003: one-inch margin on all sides.
#let para-indent = 0.5in                   // numbered paragraphs (FRCP 10(b), via FRBP 7010).
#let consent-values = ("does", "does not") // WIEB-CONSENT-001: FRBP 7008(a) statement.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("wieb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wieb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A stack of lines, one per list entry, each rendered as inline markdown.
#let lines-of(items, spacing: 0.55em) = stack(
  dir: ttb, spacing: spacing,
  ..items.map(s => inl(s)),
)

// ---------------------------------------------------------------------------
// Caption (FRBP 7010: the caption must substantially conform to Form 416A)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading)
  let d = need(meta, "debtor")
  let p = need(meta, "plaintiff")
  let df = need(meta, "defendant")
  align(center)[
    #strong[UNITED STATES BANKRUPTCY COURT] \
    #strong[EASTERN DISTRICT OF WISCONSIN]
  ]
  v(1.2em)
  grid(
    columns: (1fr, 1fr), column-gutter: 0.4in,
    stack(dir: ttb, spacing: 0.3em,
      [In re:],
      v(0.3em),
      pad(left: 0.5in, inl(d.name)),
      pad(left: 0.5in, [#d.designation]),
    ),
    align(left + horizon, stack(dir: ttb, spacing: 0.3em,
      [#d.case_number],
      [#d.chapter],
    )),
  )
  v(0.6em)
  line(length: 100%, stroke: 0.6pt)
  v(0.6em)
  grid(
    columns: (1fr, 1fr), column-gutter: 0.4in,
    stack(dir: ttb, spacing: 0.3em,
      lines-of(p.names),
      pad(left: 2.2in, [#p.designation]),
      v(0.9em),
      pad(left: 0.9in, [v.]),
      v(0.9em),
      lines-of(df.names),
      pad(left: 2.2in, [#df.designation]),
    ),
    align(left + horizon, [#need(meta, "adversary_number")]),
  )
  v(0.6em)
  line(length: 100%, stroke: 0.6pt)
  v(1.2em)
  align(center)[#strong[#inl(need(meta, "title"))]]
  v(0.8em)
}

// ---------------------------------------------------------------------------
// Consent statement (FRBP 7008(a); LR 7008-1 forfeits a statement that is missing)
// ---------------------------------------------------------------------------

#let consent-statement(meta) = {
  let c = need(meta, "consent")
  if c not in consent-values {
    panic("wieb-adversary-complaint: `consent` must be one of " + repr(consent-values))
  }
  block(above: 0.6em, below: 1.2em, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    Pursuant to Fed. R. Bankr. P. 7008(a), the Plaintiff #c consent to the entry of final orders or judgment by the Bankruptcy Court.
  ]
}

// ---------------------------------------------------------------------------
// Signature block (LR 5005-2(a)(1)(A): "/s/" followed by the printed name)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let dated = need(meta, "dated")
  let signers = need(meta, "signers")
  block(breakable: false, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    Dated: #dated
    #v(1.2em)
    #for s in signers {
      pad(left: 3.25in, block(breakable: false)[
        /s/ #s.signer
        #v(0.2em)
        #lines-of(s.lines)
        #v(1.2em)
      ])
    }
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let wieb-adversary-complaint(meta, md) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter", margin: page-margin,
    numbering: "1",
    footer: context align(center)[#text(size: type-size)[#counter(page).display()]],
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, first-line-indent: 0pt)
  set enum(indent: para-indent, body-indent: 0.4em, numbering: "1.", spacing: body-leading)

  show heading.where(level: 1): it => block(above: 1.2em, below: 0.6em, width: 100%,
    align(center, text(size: type-size, weight: "bold")[#it.body]))
  show heading.where(level: 2): it => block(above: 1.0em, below: 0.6em, width: 100%,
    text(size: type-size, weight: "bold")[#it.body])
  show heading.where(level: 3): it => block(above: 0.8em, below: 0.5em, width: 100%,
    text(size: type-size, style: "italic")[#it.body])

  caption(meta)
  consent-statement(meta)

  // Body: the markdown is numbered by the drafter (FRCP 10(b): consecutive numbers).
  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature(meta)
}
