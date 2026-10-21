// Complaint commencing an adversary proceeding, United States Bankruptcy Court, W.D. Virginia (vawb).
// Rules: FRBP 7001 (adversary proceedings), 7008(a) (jurisdiction allegation names the case, number, chapter,
// district and division; the pleader states whether it consents to final orders by the bankruptcy court),
// 7010 (caption substantially conforms to Official Form 416; Fed. R. Civ. P. 10(b) numbered paragraphs).
// W.D. Va. Local Rules (effective 3/14/2025): LR 5005-3(C) and LR 7001-1(C)(3) (letter size, top margin
// of not less than 1 1/2 in), LR 7001-1(C)(4) (name, address, telephone and e-mail lower left of the
// signature page), LR 7001-1(D) (filing fee and Form B-104 cover sheet, not generated here). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/word-compat.typ": word-compat

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored in fonts/liberation-serif; the W.D. Va. rules name no typeface or size
#let type-size = 12pt              // convention: 12 pt body, the size the filed complaint uses
#let body-leading = 1.345em        // about 24 pt pitch at 12 pt: double spacing, as in the filed complaint
#let single-leading = 0.5em        // counsel, caption and signature blocks
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
  if m == none { panic("vawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
// Caption: court title, then the "In re" block and the parties on the left,
// chapter, case number and adversary number on the right (LR 9013-1(I) layout, Form 416).
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT]))
  align(center, text(weight: "bold", [WESTERN DISTRICT OF VIRGINIA]))
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division)))
  }
  v(body-leading)
}

#let caption-left-rows(meta) = {
  let rows = ()
  for (k, d) in meta.caption.in_re.enumerate() {
    rows.push(if k == 0 { "In re:" } else { "" })
    rows += d.names
    rows.push(d.designation)
    rows.push("")
  }
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names
    rows.push(p.designation)
  }
  rows
}

#let caption-right-rows(meta) = {
  let rows = ()
  for d in meta.caption.in_re {
    rows.push("Chapter " + d.chapter)
    rows.push("Case No. " + d.case_number)
    rows.push("")
  }
  // A blank number stays a blank to be filled in by the filer.
  let value = meta.caption.number.value
  rows.push(meta.caption.number.label + " " + (if value == "" { "________" } else { value }))
  rows
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt),
    line-stack(caption-left-rows(meta))),
  block(inset: (left: 0.1in), line-stack(caption-right-rows(meta))),
)

// ---------------------------------------------------------------------------
// Signature page: counsel lower left (LR 7001-1(C)(4)), party and signer lower right.
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

/// Service addresses under the signature, when the sample gives them.
#let service-block(meta) = if "service" in meta and meta.service != none {
  block(breakable: false, width: text-width, {
    v(body-leading)
    line-stack(("Service:",))
    v(single-leading)
    for g in meta.service {
      line-stack(g.names + g.lines)
      v(single-leading)
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let vawb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    footer: context align(center, text(size: 10pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  // Word paragraph composition (lib/typst/word-compat.typ); the INPUT's `word:` map sets justify/shrink.
  show: word-compat.with(meta.at("word", default: (:)))

  // Headings: level 1 is a centered section; level 2 and 3 are bold sub-headings.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  // Numbered allegations (Fed. R. Civ. P. 10(b)): markdown ordered lists become 1., 2., ...
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in),
    par(leading: single-leading, spacing: body-leading, it.body))

  court-title(meta)
  caption(meta)
  v(body-leading)
  if "salutation" in meta and meta.salutation != none {
    par(meta.salutation)
  }
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  service-block(meta)
}
