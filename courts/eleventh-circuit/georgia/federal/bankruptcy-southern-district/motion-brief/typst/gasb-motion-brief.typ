// U.S. Bankruptcy Court, S.D. Georgia: motion with memorandum of law (FRBP 9013; FRBP 7012 for a
// Rule 12 motion in an adversary proceeding). One document: the motion and the memorandum together,
// as S.D. Ga. LR 7.1(b) allows (where the judge so directs; see ../README.md).
//
// Rule-driven and content-agnostic. Requirement IDs (GASB-...) refer to ../README.md, which quotes
// the rules and records the dates verified. No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes
// from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Font: not set by any S.D. Ga. rule found (see ../README.md). Vendored in /fonts.
#let type-size = 13pt                    // Style choice: 13 pt EB Garamond chosen by eye to approximate 12 pt Times (not measured).
#let line-pitch = 24pt                   // GASB-FORM-002: double-spaced (LR 10.1, incorporated by the Uniformity of Practice clause).
#let body-leading = 0.54em               // gap between lines of body text; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // caption, counsel block, headings, footnotes, certificate.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // Style choice: no margin rule in the S.D. Ga. rules found; 1 inch is the usual floor.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let page-number-size = 11pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gasb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gasb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: I., A., 1., a. (the author types no numbers; FRBP 9013 requires none)
// ---------------------------------------------------------------------------

/// Printed label of a heading: level 1 "I.", 2 "A.", 3 "1.", 4 "a.".
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 1 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 1) * heading-tab

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b); FRCP 10(a) through FRBP 7010)
// ---------------------------------------------------------------------------

/// Court title, centered, one line per entry of `court` (FRBP 9004(b)(1)).
#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(for l in need(meta, "court") { upper(inl(l)); linebreak() }))
}

/// Left cell: the debtor ("In re") block with the trustee if any, then the adversary parties.
#let caption-left(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "in_re") { inl(l); linebreak() }
  pad(left: 1.2in, inl(meta.at("debtor_role", default: "Debtor.")))
  if "trustee" in meta {
    v(line-pitch * 0.5)
    for l in meta.trustee { inl(l); linebreak() }
  }
  v(line-pitch * 0.5)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for n in side.names { inl(n); linebreak() }
    pad(left: 1.8in, inl(side.designation))
    if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
  }
}

/// Right cell: chapter, case number, judge (if any) and adversary number (FRBP 9004(b)(3)).
/// A blank adversary number is printed as a blank to be filled in by the clerk.
#let caption-right(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [CHAPTER #need(meta, "chapter")]
  v(line-pitch * 0.5)
  [CASE NO. #need(meta, "case_number")]
  v(line-pitch * 0.5)
  if "judge" in meta { inl(meta.judge); v(line-pitch * 0.5) }
  let adv = meta.at("adversary_number", default: "")
  [ADV. PRO. NO. #if adv == "" { "_" * 11 } else { adv }]
}

#let caption-table(meta) = table(
  columns: (3.4fr, 2fr),
  inset: 0pt,
  stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
  pad(right: 1.2em, bottom: 1em, caption-left(meta)),
  pad(left: 1.2em, top: 0.3em, caption-right(meta)),
)

// ---------------------------------------------------------------------------
// Signature block (LR 11.1: counsel name, address, telephone, State Bar number; FRBP 9011)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [This #need(meta, "submitted_on").], {
      strong(sig.firm)
      v(line-pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("signer_lines", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      emph(inl(need(sig, "role")))
      linebreak()
      for l in need(sig, "address") { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (LR 5.1, as incorporated: date, method and address of service)
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(center, strong[CERTIFICATE OF SERVICE])
    v(line-pitch * 0.5)
    par(first-line-indent: para-indent, leading: body-leading, [
      This is to certify that on this date, I caused a copy of the foregoing #inl(need(cert, "document")) to be served by #inl(need(cert, "method")), as set forth below:
    ])
    v(line-pitch * 0.5)
    for l in need(cert, "service") { align(center, inl(l)); linebreak() }
    v(line-pitch * 0.5)
    grid(columns: (1fr, 3.2in), [This #need(meta, "submitted_on").], {
      strong(sig.firm)
      v(line-pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("signer_lines", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      emph(inl(need(sig, "role")))
      linebreak()
      for l in need(sig, "address") { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let gasb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "chapter", "in_re", "caption", "title", "signature", "submitted_on", "certificate") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: context align(center, text(
    size: page-number-size, counter(page).display("1"),
  )))  // LR 10.1: every page is numbered from the first, the caption page included.
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set enum(numbering: "1.", indent: para-indent, body-indent: 0.4em)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    let ind = label-indent(it.level)
    block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
      text(size: type-size, hang(ind + heading-tab, {
        h(ind)
        box(width: heading-tab, lab)
        strong(it.body)
      })))
  }

  // ---- caption page: the motion starts on page 1 under the caption ----
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  v(line-pitch)
  certificate-block(meta)
}
