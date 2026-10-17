// U.S. Bankruptcy Court, W.D. Ky.: adversary complaint (Fed. R. Bankr. P. 7001, 7008, 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (KYWB-...) refer to ../README.md, which quotes
// or paraphrases the rule text. No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The body is rendered by cmarker from the markdown below the YAML
// frontmatter of the sample. Allegations are numbered here, one per blank-line-separated chunk.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No W.D. Ky. type rule; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // 12 pt, the exemplar's size; Liberation Serif has Times metrics (docs/FONTS.md) (style choice).
#let pitch = 24pt                        // Double spacing: the convention of the filed exemplar (style choice).
#let body-leading = pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is `pitch`.
#let single-leading = 0.398em            // Caption, counsel, signature, table text.
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let para-indent = 0.5in                 // First-line indent of numbered allegations.
#let number-gap = 0.3in                  // Gap between the allegation number and its text.
#let page-size = "us-letter"             // Fed. R. Bankr. P. 9004(a) (legibility) and Form 416 layout; letter paper is the convention.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("kywb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kywb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010: substantially Form 416; Fed. R. Bankr. P. 9004(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(for l in need(meta, "court") { upper(inl(l)); linebreak() }))
}

/// The debtor block (In re) and the bankruptcy identifiers, side by side.
#let debtor-block(meta) = {
  let c = need(meta, "caption")
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  table(
    columns: (3.5in, 1fr),
    inset: 0pt,
    stroke: none,
    pad(right: 1.2em, bottom: 0.4em, {
      for (i, l) in c.debtor_names.enumerate() {
        if i == 0 { inl(l) } else { pad(left: 0.5in, inl(l)) }
        linebreak()
      }
      v(pitch * 0.5)
      pad(left: 1.8in, inl(c.debtor_designation))
    }),
    pad(left: 1.2em, bottom: 0.4em, {
      for l in c.bankruptcy_lines { inl(l); linebreak() }
    }),
  )
}

/// The adversary block: parties on the left, the adversary number on the right.
#let adversary-block(meta) = {
  let c = need(meta, "caption")
  let number = if c.adversary_number == "" { "Adv. Proc. No. " + "_" * 12 } else { "Adv. Proc. No. " + c.adversary_number }
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  table(
    columns: (3.5in, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 0.6em, top: 0.4em, {
      for (i, side) in c.parties.enumerate() {
        for n in side.names { inl(n); parbreak() }
        pad(left: 1.8in, inl(side.designation))
        if i < c.parties.len() - 1 { v(pitch * 0.5); pad(left: 0.9in, [v.]); v(pitch * 0.5) }
      }
    }),
    pad(left: 1.2em, top: 0.4em, number),
  )
}

#let caption(meta) = {
  court-title(meta)
  v(pitch)
  debtor-block(meta)
  adversary-block(meta)
  v(pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Allegations: one numbered paragraph per chunk (Fed. R. Civ. P. 10(b)). A chunk that starts with
// "# " is a heading; "~ " is an unnumbered paragraph; a markdown list is unnumbered (the prayer).
// ---------------------------------------------------------------------------

#let heading-line(c) = block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true, c)

#let allegations(body, para-counter) = {
  for raw in body.split("\n\n") {
    let t = raw.trim()
    if t == "" { continue }
    if t.starts-with("# ") {
      heading-line(align(center, strong(upper(inl(t.slice(2))))))
    } else if t.starts-with("~ ") {
      block(width: 100%, above: body-leading, below: 0pt, {
        set par(first-line-indent: para-indent, leading: body-leading)
        inl(t.slice(2))
      })
    } else if t.match(regex("^\\d+\\. ")) != none or t.starts-with("- ") {
      block(width: 100%, above: body-leading, below: 0pt, {
        set par(leading: body-leading)
        inl(t)
      })
    } else {
      para-counter.step()
      block(width: 100%, above: body-leading, below: 0pt, context {
        set par(leading: body-leading)
        h(para-indent)
        numbering("1.", ..para-counter.get())
        h(number-gap)
        inl(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (no local rule sets its form; LBR 9004-1 requires the filer's address, telephone
// and email; LBR 9011-4 requires a proper signature). See ../README.md.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 3.0in, {
      for l in sig.at("firm_lines", default: (sig.firm,)) { strong(inl(l)); linebreak() }
      v(pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// Exhibits: one per page, each a table of the transfers or documents the complaint refers to.
// ---------------------------------------------------------------------------

#let exhibit(ex) = {
  pagebreak(weak: true)
  align(center, strong(underline(upper(inl(ex.title)))))
  v(pitch)
  let ncols = ex.header.len()
  let body-rows = ex.rows.map(r => r.map(c => inl(c)))
  table(
    columns: ex.at("widths", default: (1,) * ncols).map(w => w * 1fr),
    inset: 5pt,
    stroke: 0.6pt,
    align: (x, y) => if x in ex.at("right", default: ()) { right } else { left },
    table.header(..ex.header.map(h => strong(inl(h)))),
    ..body-rows.flatten(),
    ..ex.at("total", default: ()).map(c => if c == "" { [] } else { strong(inl(c)) }),
  )
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let kywb-adversary-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: page-size, margin: margins, numbering: "1", footer: context {
    set text(size: 11pt)
    align(center, counter(page).display())
  })
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Only the exhibit tables use enum/table styling; the prayer's lettered items are set here.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set table(stroke: 0.6pt)

  let para-counter = counter("allegation")

  caption(meta)
  allegations(body, para-counter)
  signature-block(meta)
  for ex in meta.at("exhibits", default: ()) { exhibit(ex) }
}
