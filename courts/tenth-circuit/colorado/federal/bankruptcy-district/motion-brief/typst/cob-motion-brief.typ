// United States Bankruptcy Court, District of Colorado: motion with memorandum (FRBP 9013).
//
// Rule-driven and content-agnostic. Requirement IDs (COB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"    // COB-FORM-002: proportionally spaced; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                    // COB-FORM-002: 12 point or larger.
#let line-pitch = 24pt                   // COB-FORM-003: double spacing (proxy rule, see README).
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is line-pitch.
#let single-leading = 0.398em            // caption, headings that wrap, block quotations, footnotes, signature block.
#let margin-top = 1.5in                  // COB-FORM-004 (proxy): 1.5 in top, 1 in elsewhere.
#let margin-other = 1in
#let para-indent = 0.5in
#let footer-size = 11pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("cob-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cob-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Caption (COB-FIRST-001, FRBP 9004(b), FRBP 7010 for adversary proceedings)
// ---------------------------------------------------------------------------

/// Court title, centered, two lines of the form given in the frontmatter.
#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
}

/// One caption block: the party names on the left, a reference column on the right.
#let caption-block(left-body, right-body) = grid(
  columns: (1fr, 2.6in),
  column-gutter: 0.3in,
  {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    left-body
  },
  {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    right-body
  },
)

#let caption(meta) = {
  // Debtor block: the bankruptcy case (FRBP 9004(b)(3)).
  let debtor = need(meta, "debtor")
  caption-block(
    {
      [IN RE:]
      v(single-leading * 2)
      for n in debtor.names { pad(left: 0.4in, [#n]); linebreak() }
      v(single-leading * 2)
      pad(left: 0.8in, [Debtor.])
    },
    {
      [Case No. #debtor.case_number]
      linebreak()
      if "chapter" in debtor { inl(debtor.chapter) }
    },
  )

  // Adversary block (only for a motion filed in an adversary proceeding).
  if "adversary" in meta {
    let adv = meta.adversary
    v(line-pitch * 0.5)
    caption-block(
      {
        for (i, side) in adv.parties.enumerate() {
          for n in side.names { [#n]; linebreak() }
          pad(left: 0.8in, [#side.designation])
          if i < adv.parties.len() - 1 { v(single-leading * 2) }
        }
      },
      [Adv. Proc. No. #adv.case_number],
    )
  }
}

/// The title of the paper: bold capitals, centered, one or more lines (FRBP 9004(b)(4)).
#let title-block(meta) = {
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Signature block (no local rule cited for the form; see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      for l in sig.at("firm", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", level 3 "A.", level 4 "1.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else { "" }
}

#let heading-tab = 0.5in

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let cob-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "title", "signature", "date") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-other, x: margin-other),
    numbering: "1",
    footer: context align(center, text(size: footer-size, numbering("1", ..counter(page).get()))),
  )
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Block quotations (the operative contract language): single spaced, indented both sides.
  show quote.where(block: true): it => block(
    width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5,
    pad(left: 0.5in, right: 0.5in, par(first-line-indent: 0pt, leading: single-leading, justify: false, it.body)),
  )

  // Headings: level 1 centered bold capitals; level 2+ bold with the label hung at the margin.
  // Headings keep the body size: typst scales heading text by default.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    set text(size: type-size)
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = (it.level - 2) * heading-tab
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  // Caption and title on page 1; the memorandum continues on the same pages.
  court-title(meta)
  v(line-pitch * 0.5)
  caption(meta)
  title-block(meta)

  // Body: markdown from the sample (paragraphs, headings, lists, block quotations, footnotes).
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)

  // Certificate of service (FRBP 9013(b) service; the exemplar places it after the signature).
  if "certificate" in meta {
    let cert = meta.certificate
    block(breakable: false, above: line-pitch, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      align(center, strong(upper[Certificate of Service]))
      v(line-pitch * 0.5)
      par(first-line-indent: para-indent, leading: body-leading, inl(cert.text))
      v(line-pitch * 0.5)
      grid(columns: (1fr, 3.2in), [Dated: #cert.date], [/s/ #cert.signer])
    })
  }
}
