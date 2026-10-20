// U.S. Bankruptcy Court, S.D. West Virginia: adversary complaint (FRBP 7001; FRBP 7010 applies FRCP 10).
//
// Rule-driven and content-agnostic. Requirement IDs (WVSB-...) refer to ../README.md, which quotes the
// rule text and gives the date verified. No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The body is rendered by cmarker from the markdown sample; the court
// title, caption, document title and signature block come from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // WVSB-FORM-002: no rule names a typeface (see ../README.md); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // WVSB-FORM-002: no rule sets a size; the 12 pt convention (docs/FONTS.md).
#let line-pitch = 24pt                   // WVSB-FORM-003: double spacing, as in the exemplar.
#let body-leading = line-pitch - 1.15em // gap between lines of body text: the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em), so the line pitch is line-pitch.
#let single-leading = 0.2em              // caption, counsel block, headings, footnotes, quotations.
#let margins = (top: 1in, bottom: 1in, x: 1in)   // WVSB-FORM-004: a style choice (the exemplar uses 1 in).
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let footer-size = 11pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("wvsb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A stack of single-spaced lines, one per list item (no forced breaks).
#let lines(items) = stack(dir: ttb, spacing: 0pt, ..items.map(l => {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  inl(l)
}))

// ---------------------------------------------------------------------------
// Caption (WVSB-CAP-001 to WVSB-CAP-003; FRBP 9004(b); FRCP 10(a))
// ---------------------------------------------------------------------------

/// Two-column caption. Left: each side of the case (debtors, plaintiffs, defendants), with `v.`
/// printed before a side that has `sep`. Right: the case information (chapter, case number,
/// adversary number). A side's `footnote` is attached to its designation.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let info = need(meta, "case_info")
  let notes = ()
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      if "sep" in side {
        v(line-pitch * 0.5)
        pad(left: 1.2in, inl(side.sep))
        v(line-pitch * 0.5)
      } else if i > 0 {
        v(line-pitch * 0.5)
      }
      lines(side.names)
      pad(left: 1.8in, {
        inl(side.designation)
        if "footnote" in side { super[\*]; notes.push(inl(side.footnote)) }
      })
    }
  }
  let right = pad(left: 1.2em, top: 0.3em, lines(info))
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    right,
  )
  // The debtors note sits under the caption, in the flow (not a page-foot footnote).
  for n in notes { v(0.4em); block(text(size: 10pt, [\* #n])) }
}

// ---------------------------------------------------------------------------
// Signature block (WVSB-CMP-005: FRBP 9011(a); LR 9011-4 for the /s/ form)
// ---------------------------------------------------------------------------

/// Date and preamble on the top row; each counsel block in its own column (so the signature stays
/// short enough to sit under the last paragraph instead of alone on a page).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let counsel = sig.blocks.map(blk => stack(dir: ttb, spacing: 0pt, ..blk.map(l => inl(l))))
  let preamble = sig.at("preamble", default: ())
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(
      columns: (1fr, 3.2in),
      if "dated" in sig { [Dated: #sig.dated] } else { [] },
      stack(dir: ttb, spacing: 0pt, ..preamble.map(l => inl(l))),
    )
    v(line-pitch * 0.5)
    grid(columns: counsel.map(_ => 1fr), column-gutter: 0.3in, row-gutter: line-pitch * 0.5, ..counsel)
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let wvsb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "case_info", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings (WVSB-FORM-001: letter paper; WVSB-FORM-002 to 004 style) ----
  set page(
    paper: "us-letter", margin: margins,
    numbering: "1",
    footer: context {
      set text(size: footer-size)
      align(center, counter(page).display("1"))
    },
  )
  set document(title: need(meta, "title"))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)
  set quote(block: true)
  show quote: set par(first-line-indent: 0pt, leading: single-leading)
  show quote: set block(spacing: line-pitch * 0.5)
  show quote: pad.with(x: 0.5in)

  // Section headings: level 1 centred capitals; level 2 centred (count headings); level 3 at the margin.
  show heading: it => {
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(text(size: type-size, upper(it.body)))))
    } else if it.level == 2 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(text(size: type-size, it.body))))
    } else {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        strong(text(size: type-size, it.body)))
    }
  }

  // ---- first page: court title, caption, document title ----
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, lines(need(meta, "court")))
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, strong(upper(need(meta, "title"))))
  v(line-pitch * 0.5)

  // ---- body (numbered paragraphs are typed in the sample, escaped as `1\.`) ----
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  // ---- consent to final orders (WVSB-CMP-004; FRBP 7008(a)): required, and the author states the position ----
  par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, spacing: 0pt,
    inl(need(meta, "consent")))

  signature-block(meta)
}
