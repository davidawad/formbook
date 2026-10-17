// Motion with memorandum in support, United States Bankruptcy Court, W.D. Virginia (vawb).
// Rules: FRBP 9013 (a motion must state its grounds with particularity and set out the relief requested),
// 9014(a) (relief in a contested matter is requested by motion), 7012 and 7056 where the motion is in an
// adversary proceeding. W.D. Va. Local Rules (effective 3/14/2025): LR 9013-1(A)-(C) (written motion, grounds
// and relief stated, counsel's name, address, telephone and e-mail lower left of the signature page),
// LR 9013-1(E) (proof of service at the end of each motion, signed by counsel, with date, manner and names
// and addresses), LR 9013-1(I) (caption: court, debtor, case number, motion number, and the Movant,
// Respondent or Trustee designation), LR 5005-3(C) and LR 7001-1(C)(3) (letter size, top margin of not less
// than 1 1/2 in). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored in fonts/liberation-serif; the W.D. Va. rules name no typeface or size
#let type-size = 12pt              // convention: 12 pt body, the size the filed motion uses
#let body-leading = 1.345em        // about 24 pt pitch at 12 pt: double spacing, as in the filed motion
#let single-leading = 0.5em        // counsel, caption, block quotations and signature blocks
#let page-w = 8.5in                // LR 5005-3(C), LR 7001-1(C)(3): standard letter size
#let page-h = 11in
#let top-margin = 1.5in            // LR 5005-3(C), LR 7001-1(C)(3): top margin of not less than 1 1/2 inches
#let side-margin = 1in             // convention: one inch left and right
#let bottom-margin = 1in
#let text-width = page-w - 2 * side-margin
#let para-indent = 0.5in           // first-line indent of prose paragraphs
#let caption-left = 4in            // width of the party column of the caption; wide enough that "(n/k/a" does not break

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (LR 9013-1(I)): court title; "In re" block and parties on the left;
// chapter, case number and motion or adversary number on the right.
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT]))
  align(center, text(weight: "bold", [WESTERN DISTRICT OF VIRGINIA]))
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division)))
  }
  v(body-leading)
}

/// Each debtor's names beside that debtor's chapter and case number, so the two columns stay in step.
#let caption(meta) = {
  let groups = ()
  for (k, d) in meta.caption.in_re.enumerate() {
    groups.push(grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.25in,
      line-stack(((if k == 0 { "In re:" } else { "" }),) + d.names + (d.designation,)),
      block(inset: (left: 0.1in), line-stack(("Chapter " + d.chapter, "Case No. " + d.case_number))),
    ))
  }
  // The parties sit in the bordered left column; a blank number stays a blank for the filer to fill in.
  let value = meta.caption.number.value
  let party-rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { party-rows.push("v.") }
    party-rows += p.names
    party-rows.push(p.designation)
  }
  groups.push(grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt),
      line-stack(party-rows)),
    block(inset: (left: 0.1in), line-stack((meta.caption.number.label, if value == "" { "________" } else { value }))),
  ))
  stack(dir: ttb, spacing: single-leading * 2, ..groups)
}

// ---------------------------------------------------------------------------
// Signature block (counsel lower left, LR 9013-1(C)) and certificate of service (LR 9013-1(E))
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  if "date" in meta.signature and meta.signature.date != none {
    line-stack(("Dated: " + meta.signature.date,))
    v(single-leading)
  }
  grid(
    columns: (1fr, 2.9in),
    column-gutter: 0.2in,
    line-stack(meta.counsel.names + meta.counsel.lines),
    line-stack(
      ("Respectfully submitted,", "", upper(meta.signature.party), "", "BY: /s/ " + meta.signature.signer)
        + meta.signature.lines,
    ),
  )
})

#let certificate-of-service(meta) = if "service" in meta and meta.service != none {
  block(breakable: false, width: text-width, {
    v(body-leading)
    align(center, text(weight: "bold", [CERTIFICATE OF SERVICE]))
    v(body-leading)
    par(meta.service.statement)
    v(body-leading)
    for g in meta.service.parties {
      line-stack(g.names + g.lines)
      v(body-leading)
    }
    v(body-leading * 0.5)
    line-stack(("/s/ " + meta.service.signer,) + meta.service.lines)
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let vawb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    footer: context align(center, text(size: 10pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section (Conclusion, Argument and Citations of Authority).
  // Level 2 to 5 are numbered automatically, I. / A. / 1. / a.; the sample writes no numbers.
  let h2 = counter("vawb-h2")
  let h3 = counter("vawb-h3")
  let h4 = counter("vawb-h4")
  let h5 = counter("vawb-h5")
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => {
    h2.step()
    h3.update(0)
    h4.update(0)
    h5.update(0)
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      grid(columns: (0.5in, 1fr), column-gutter: 0pt,
        text(size: type-size, weight: "bold", context h2.display("I.")),
        text(size: type-size, weight: "bold", it.body)))
  }
  show heading.where(level: 3): it => {
    h3.step()
    h4.update(0)
    h5.update(0)
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      grid(columns: (0.5in, 1fr), column-gutter: 0pt,
        text(size: type-size, weight: "bold", context h3.display("A.")),
        text(size: type-size, weight: "bold", it.body)))
  }
  show heading.where(level: 4): it => {
    h4.step()
    h5.update(0)
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      grid(columns: (0.5in, 1fr), column-gutter: 0pt,
        text(size: type-size, context h4.display("1.")),
        text(size: type-size, style: "italic", it.body)))
  }
  show heading.where(level: 5): it => {
    h5.step()
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      grid(columns: (0.5in, 1fr), column-gutter: 0pt,
        text(size: type-size, context h5.display("a.")),
        text(size: type-size, it.body)))
  }

  // Numbered paragraphs: markdown ordered lists become 1., 2., ... (the sample sets each list's first number).
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in),
    par(leading: single-leading, spacing: body-leading, it.body))

  court-title(meta)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate-of-service(meta)
}
