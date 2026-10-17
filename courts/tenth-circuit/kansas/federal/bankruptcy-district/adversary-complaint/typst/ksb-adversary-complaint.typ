// U.S. Bankruptcy Court, District of Kansas: adversary complaint (FRBP 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (KSB-...) refer to ../README.md, which quotes
// the rule text (Fed. R. Bankr. P. 7001, 7003, 7008, 7010, 9004, 9011; Fed. R. Civ. P. 8, 10;
// D. Kan. LBR 7003.1, 9004.1). No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 16pt                    // KSB-FORM-002: 12 pt or larger, and an average of no more than 12 characters per inch (LBR 9004.1(a)(1)). Measured in Liberation Serif on the sample text (typst 0.15.0, 2026-10-17): 12.8 cpi at 14 pt, 11.9 at 15 pt, 11.2 at 16 pt; 16 pt keeps a margin under 12.
#let line-pitch = 2 * type-size           // KSB-FORM-003: double-spaced where practicable (LBR 9004.1(a)(1)): two type sizes per line.
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines; 1.107 em is Liberation Serif's line box (hhea ascender 0.891em to descender 0.216em), so the pitch is line-pitch.
#let single-leading = 0.448em            // caption, counsel block, block quotations, tables.
#let page-margin = 1in                   // style choice: 1 inch on all sides (no margin figure in the rules).
#let para-indent = 0.5in                 // first-line indent of unnumbered paragraphs.
#let number-indent = 0.5in               // numbered paragraphs: the number sits at this indent (the first line starts here).
#let number-gap = 0.5in                  // numbered paragraphs: space between the number and the text.
#let sig-left = 3.2in                    // signature block: the right half of the page.
#let caption-left = 3.6in                // caption: width of the party column.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ksb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ksb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Numbered paragraphs run through the whole complaint (FRCP 10(b)); the template numbers them,
// so the markdown list numbers do not matter.
#let para-num = counter("para-num")

// ---------------------------------------------------------------------------
// Caption (Form 416D, adversary caption; FRBP 7010, 9004(b))
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let adv = meta.at("adversary_number", default: "Adv. Proc. No. " + "_" * 14)
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    text(weight: "regular", "In re:")
    linebreak()
    v(line-pitch * 0.5)
    for n in debtor.names { inl(n); linebreak() }
    pad(left: 2in, inl(debtor.designation))
    v(line-pitch * 0.5)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); linebreak() }
      pad(left: 2in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
    }
    v(line-pitch * 0.5)
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    v(line-pitch * 1.5)
    inl(need(meta, "bankruptcy_case"))
    linebreak()
    inl(need(meta, "chapter"))
    v(line-pitch * 2.5)
    adv
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 0.5em, left),
    pad(left: 1.2em, right),
  )
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a): signed in the attorney's name, with address and telephone)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, sig-left), [#meta.at("date", default: "")], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      [By: /s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      if "bar" in sig { [, ] ; inl(sig.bar) }
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      strong(inl(sig.at("role", default: "")))
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ksb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",                  // LBR 9004.1(a)(1): 8-1/2 x 11 inch paper.
    margin: page-margin,
    numbering: "1",                      // LBR 9004.1(a)(2): numbered from the first page.
    number-align: center,
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
  set enum(spacing: 0pt)
  set table(stroke: none, inset: (x: 6pt, y: 3pt))
  show table: set par(leading: single-leading, first-line-indent: 0pt)

  // Numbered paragraphs: "1." at the number indent, text after it, wrapped lines to the margin.
  // The markdown list is rendered as one enum per run of items; each item is a paragraph here,
  // numbered by the counter so the numbers run on across headings.
  show enum: it => {
    for item in it.children {
      para-num.step()
      context {
        let n = para-num.get().first()
        // The paragraph's first line already starts at the number indent (see para-indent above).
        [#n.#h(number-gap)#item.body]
        parbreak()
      }
    }
  }

  // Headings: level 1 is a centered section in capitals; level 2 is a centered sub-title.
  show heading: it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, align(center, if it.level == 1 { strong(upper(it.body)) } else { strong(it.body) })))

  // The table of exhibits: header row in bold.
  show table.cell.where(y: 0): set text(weight: "bold")

  // ---- the first page: court title, caption, document title ----
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(line-pitch)
  caption-block(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  // ---- the body, with the signature block where the author puts [[signature]] ----
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  let parts = md.split("[[signature]]")
  if parts.len() != 2 { panic("ksb-adversary-complaint: the body must contain exactly one [[signature]] marker") }
  cmarker.render(parts.at(0), raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  // Anything after the signature (exhibits) starts on its own page.
  pagebreak(weak: true)
  set par(first-line-indent: 0pt)
  cmarker.render(parts.at(1), raw-typst: false, smart-punctuation: true)
}
