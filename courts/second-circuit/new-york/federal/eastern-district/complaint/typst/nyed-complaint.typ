// U.S. District Court, Eastern District of New York: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NYED-...) refer to ../README.md, which quotes
// the rule text: Fed. R. Civ. P. 5.2(a), 8(a), 10(a)-(b); Local Civil Rule 7.1(b) (typeface,
// margins, spacing; it applies to all documents presented for filing). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // No EDNY rule names a face (NYED-FORM-002); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // NYED-FORM-002: LCR 7.1(b)(1), 12-point type or larger.
#let line-pitch = 24pt                   // NYED-FORM-003: LCR 7.1(b)(3), double-spaced body text.
#let body-leading = line-pitch - 0.909em // Gap between body lines: text edges are ascender/descender (below), a 0.909em line box in Liberation Serif, so the baseline pitch is line-pitch (double spacing).
#let single-leading = 0.241em            // 0.909em + 0.241em = 1.15em (13.8 pt), single spacing: Caption, counsel block, headings, signature block (7.1(b)(3) exceptions for headings).
#let margins = (top: 1in, bottom: 1in, x: 1in)  // NYED-FORM-004: LCR 7.1(b)(2), at least one inch on all sides.
#let para-indent = 0.5in                 // First-line indent of numbered paragraphs.
#let number-tab = 0.5in                  // Distance from paragraph number to text.
#let prayer-tab = 0.5in                  // Hanging indent of lettered prayer items.
#let footer-size = 12pt                  // Page number; same size as text (NYED-FORM-002 applies to all text).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, bold, links) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nyed-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a): court name, title, file number)
// ---------------------------------------------------------------------------

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      if i > 0 {
        v(line-pitch * 0.5)
        pad(left: 1.2in, [-against-])
        v(line-pitch * 0.5)
      }
      for n in side.names { inl(n); linebreak() }
      pad(left: 1.9in, inl(side.designation))
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Docket No. #need(meta, "case_number")]
    if meta.at("jury_demand", default: false) {
      v(line-pitch * 0.5)
      strong[JURY TRIAL DEMANDED]
    }
  }
  table(
    columns: (3.4in, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (top: 0.7pt, bottom: 0.7pt) } else { none },
    pad(top: 0.7em, bottom: 0.9em, right: 1em, left),
    pad(left: 1.2em, right),
  )
}

// ---------------------------------------------------------------------------
// Headings and body
// ---------------------------------------------------------------------------

/// A heading block. `#` is a centered bold capital heading, `##` a centered bold heading, `###` a
/// left-aligned bold heading. Headings are single-spaced (LCR 7.1(b)(3)).
#let heading-block(level, text) = block(
  width: 100%, above: body-leading * 1.5, below: body-leading * 1.5, sticky: true,
  {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if level == 1 { align(center, strong(upper(inl(text)))) }
    else if level == 2 { align(center, strong(inl(text))) }
    else { strong(inl(text)) }
  },
)

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph. Numbering is applied per chunk, not with a
/// `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      if m == none { panic("nyed-complaint: malformed heading: " + t) }
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.starts-with("- ") {
      // Prayer items: lettered A., B., ... in a label column. A list may break across pages.
      let items = t.split(regex("\\r?\\n")).filter(l => l.trim() != "")
      set par(first-line-indent: 0pt, leading: body-leading, spacing: body-leading, justify: false)
      for (i, it) in items.enumerate() {
        let txt = it.trim().slice(2)
        block(breakable: true, width: 100%, pad(left: para-indent, grid(
          columns: (prayer-tab, 1fr),
          [#numbering("A.", i + 1)],
          inl(txt),
        )))
      }
      v(body-leading)
    } else if t.starts-with("WHEREFORE") {
      // The prayer lead-in is an unnumbered paragraph (Fed. R. Civ. P. 10(b) numbers allegations only).
      par(first-line-indent: para-indent, leading: body-leading, spacing: body-leading, justify: false, inl(t))
    } else {
      // Paragraph number at the first-line indent; text starts one number-tab further in.
      n += 1
      par(first-line-indent: 0pt, leading: body-leading, spacing: body-leading, justify: false, [
        #h(para-indent)#box(width: number-tab)[#n.]#inl(t)
      ])
    }
  }
}

// ---------------------------------------------------------------------------
// Counsel block, signature (Fed. R. Civ. P. 11(a): signed by at least one attorney of record)
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in meta.at("counsel", default: ()) { inl(l); linebreak() }
  v(line-pitch)
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      [By: /s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nyed-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "title", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter", margin: margins,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: body-leading, justify: false)

  // ---- first page: counsel, court, caption, title ----
  counsel-block(meta)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  // Unnumbered lead-in paragraph (the "Plaintiff ... states as follows:" opening), if given.
  if "lead_in" in meta {
    par(first-line-indent: para-indent, leading: body-leading, spacing: body-leading, justify: false, inl(meta.lead_in))
  }
  allegations(md)
  signature-block(meta)
}
