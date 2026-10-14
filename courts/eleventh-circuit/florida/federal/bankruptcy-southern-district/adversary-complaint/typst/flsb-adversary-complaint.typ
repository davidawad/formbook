// Adversary complaint for the United States Bankruptcy Court, Southern District of Florida.
// Rules (verified 2026-10-14; see ../README.md): Fed. R. Bankr. P. 7001 (adversary proceedings), 7008(a)
// (jurisdiction, core/non-core and consent to final orders), 7010 (Fed. R. Civ. P. 10 applies: numbered
// paragraphs, caption), 9004(b) (caption contents); S.D. Fla. Bankr. L.R. 9004-1(a)(2)-(4) (1-inch margins,
// 12-point type, double spacing except captions, headings, quotations over 50 words, footnotes and signature
// blocks), 9004-1(e)(2) (adversary caption form).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // L.R. 9004-1(a)(3): 12-point font; the vendored serif face
#let type-size = 12pt                   // L.R. 9004-1(a)(3)
#let footnote-size = 10pt               // L.R. 9004-1(a)(3): footnotes may be 10-point
#let margin = 1in                       // L.R. 9004-1(a)(2): at least one inch on every side
#let page-w = 8.5in                     // US Letter
#let page-h = 11in
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // L.R. 9004-1(a)(4): double spacing; with EB Garamond's 0.65em line box this is a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing for caption, signature block and certificate (about 13.8 pt)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let quote-inset = 0.5in                // block quotations are indented on both sides
#let pitch-gap = 24pt                   // one double-spaced line: the unit of vertical space between parts of the cover and signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading kept with the paragraph after it (a heading never ends a page).
#let heading-block(c) = block(width: text-width, above: 0.5 * pitch-gap, below: body-leading, sticky: true, c)

// ---------------------------------------------------------------------------
// Caption (Form 416 / L.R. 9004-1(e)(2)): court, division, debtor and case, party and adversary number
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  align(center, text(weight: "bold", stack(dir: ttb, spacing: single-leading,
    "UNITED STATES BANKRUPTCY COURT",
    meta.district,
  )))
  v(pitch-gap)
  // The division is printed as a blank line when the sample does not name one (L.R. 9004-1(e)(2)).
  let division = if "division" in meta { upper(meta.division) } else { "___________" }
  align(center, text(weight: "bold", division + " DIVISION"))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, {
    set par(leading: single-leading, spacing: 0pt)
    line-stack(("In re:", ..meta.debtor.names, meta.debtor.designation))
    v(pitch-gap * 0.5)
    line-stack(("_" * 36 + "/",))
    v(pitch-gap * 0.5)
    let rows = ()
    for (k, p) in meta.parties.enumerate() {
      if k > 0 { rows.push("vs.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
    v(pitch-gap * 0.5)
    line-stack(("_" * 36 + "/",))
  }),
  block({
    set par(leading: single-leading, spacing: 0pt)
    line-stack(("CASE NO.: " + meta.case_number, "CHAPTER " + meta.chapter))
    v(pitch-gap * 2)
    line-stack(("ADV. CASE NO.: " + meta.adv_number,))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch-gap)
  caption(meta)
  v(pitch-gap)
  align(center, text(weight: "bold", inl(meta.title)))
  v(pitch-gap)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Civil Rule 10(b), via Rule 7010); headings, block quotations, lettered items
// and the WHEREFORE clause are not numbered.
// ---------------------------------------------------------------------------

/// Only the paragraph's own text is passed to cmarker; its numbering is added around it.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let n = 0
  let seen-heading = false
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    let piece = none
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      seen-heading = true
      has-pending = true
      continue
    } else if t.starts-with(">") {
      piece = block(width: text-width, inset: (left: quote-inset, right: quote-inset), {
        set par(leading: single-leading, spacing: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      piece = block(width: text-width, above: pitch-gap * 0.5, below: pitch-gap * 0.5, piece)
    } else if not seen-heading {
      // The opening paragraph before the first heading is not numbered (Slott exemplar; Rule 10(b) numbers allegations).
      piece = block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(regex("^\\([a-z]\\)[ \\t]")) or t.starts-with("WHEREFORE") or t.starts-with("Dated") {
      piece = block(width: text-width, inset: (left: 0.5in), below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      n += 1
      piece = block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt)
        h(para-indent)
        [#str(n)#h(0.3in)]
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
    if has-pending {
      block(breakable: false, width: text-width, below: body-leading, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let signature-block(meta) = block(width: text-width, breakable: false, above: pitch-gap, grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch-gap * 0.5)
    line-stack(meta.signature.firm)
    v(pitch-gap * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  },
))

#let flsb-adversary-complaint(meta, body) = {


  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)

  // Headings: level 1 is a centered bold section; level 2 is a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  cover(meta)
  allegations(body)
  signature-block(meta)
}
