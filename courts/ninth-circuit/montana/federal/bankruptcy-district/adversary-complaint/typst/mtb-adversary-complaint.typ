// U.S. Bankruptcy Court, D. Montana: adversary proceeding complaint (FRBP 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (MTB-...) refer to ../README.md, which quotes
// the rule text: Mont. LBR 5005-2 (format), LBR 9004-1 (case numbers), Fed. R. Bankr. P. 7008,
// 7010 (Fed. R. Civ. P. 10 applies to the form of an adversary complaint) and 9004(b) (caption).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // Not fixed by the LBR; the repo vendors this font. See README.md.
#let type-size = 13pt                    // MTB-FORM-002: at least 12 point. 13 pt because EB Garamond sets smaller than Times.
#let line-pitch = 24pt                   // MTB-FORM-003: double spacing. 27 lines per page at these margins.
#let body-leading = 0.54em               // gap between body lines; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // counsel block, caption, certificate, block quotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // MTB-FORM-004: no less than one-inch margins.
#let para-indent = 0.5in
#let caption-left = 3.6in                // width of the party column of the caption

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mtb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A stack of single-spaced lines. An empty string in the list is a blank line.
#let lines-block(lines) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false, spacing: 0pt)
  stack(dir: ttb, spacing: 0.15em, ..lines.map(l => if l == "" { v(1em) } else { inl(l) }))
}

// ---------------------------------------------------------------------------
// Counsel block, court title, caption, title (MTB-FIRST-001..003)
// ---------------------------------------------------------------------------

/// Attorney or party identification, upper left of the first page (LBR 5005-2(b)).
#let counsel-block(meta) = {
  lines-block(need(meta, "counsel"))
  if "counsel_role" in meta and meta.counsel_role != "" {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    emph(inl(meta.counsel_role))
  }
}

/// Court name, centered, all capitals (FRBP 9004(b)(1)).
#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "court").map(l => upper(l)).join(linebreak())))
}

/// Caption (FRBP 9004(b)(2)-(3)): one row per caption block, parties left, case number right.
/// Each party cell carries a right and a bottom rule, as the filed caption does.
#let caption-table(meta) = {
  let cells = ()
  for block in need(meta, "caption") {
    cells.push(pad(right: 1em, top: 0.6em, bottom: 0.6em, lines-block(block.left)))
    cells.push(pad(left: 1em, top: 0.6em, bottom: 0.6em, lines-block(block.right)))
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    ..cells,
  )
}

// ---------------------------------------------------------------------------
// Signature block and certificate (MTB-SIG-001, MTB-CERT-001)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [#sig.date], {
      lines-block(sig.at("preamble", default: ()))
      v(line-pitch * 0.5)
      [By /s/ #sig.signer]
      linebreak()
      [#sig.signer_role]
    })
  })
}

#let certificate(meta) = {
  let c = meta.at("certificate", default: none)
  if c != none {
    block(breakable: false, above: line-pitch * 1.5, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      align(center, strong(upper(c.title)))
      v(line-pitch * 0.5)
      par(leading: body-leading, first-line-indent: para-indent, justify: false, inl(c.text))
      v(line-pitch * 0.5)
      pad(left: 0.5in, lines-block(c.addressees))
      v(line-pitch)
      align(right, block(width: 3.2in, {
        [/s/ #c.signer]
        linebreak()
        [#c.signer]
        linebreak()
        [Dated: #c.date]
      }))
    })
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mtb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "adversary_number", "court", "counsel", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins)   // MTB-FORM-001: 8 1/2 x 11 inch, one-sided
  set document(
    title: need(meta, "title") + ", Adv. No. " + need(meta, "adversary_number"),
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
  set heading(numbering: none)
  // Footnotes and quotations are single-spaced (MTB-FORM-003), set at the footnote's text size.
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings in the body: centered, bold, capitals (the sample's section headings).
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5,
    sticky: true, align(center, strong(upper(it.body))))

  // ---- page 1: counsel block, court title, caption, title of the paper ----
  page(numbering: "1", footer: align(center, context counter(page).display()), {
    // Each `set par` is scoped to its own block so the body keeps double spacing and indents.
    {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      counsel-block(meta)
      v(line-pitch * 1.5)
      court-title(meta)
      v(line-pitch)
    }
    caption-table(meta)
    v(line-pitch)
    align(center, strong(upper(need(meta, "title"))))
    v(line-pitch * 0.5)
    {
      set par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, spacing: 0pt, justify: false)
      cmarker.render(md, raw-typst: false, smart-punctuation: true)
    }
    signature-block(meta)
    certificate(meta)
  })
}
