// U.S. District Court, District of New Jersey: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NJD-...) refer to ../README.md, which quotes the
// rule text (Fed. R. Civ. P. 8, 10, 38; D.N.J. L.Civ.R. 10.1, 11.1, 11.2, 38.1; the D.N.J. ECF
// Policies ¶ 12(a) on the "s/" signature line). No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // NJD-FORM-002: a standard proportional serif; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                   // NJD-FORM-002: 12 point, the size both filed exemplars use
#let pitch = 27.6pt                     // NJD-FORM-003: double spacing, measured in the exemplars (DGL p.3: 27.6 pt)
#let body-leading = pitch - 0.909em     // gap between lines of body text: the ascender-to-descender line box set below is 0.909em in Liberation Serif, so the line pitch is `pitch`
#let single-leading = 0.596em           // 0.909em + 0.596em = about 18 pt at 12 pt: counsel block, caption, signature blocks, certification
#let page-margin = 1in                  // NJD-FORM-001: no complaint margin rule; 1 inch, as in both exemplars
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-gap = 0.3in                 // gap between a paragraph number and its text
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("njd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, italic attorney lines, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("njd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: counsel (first page, upper left), court title, caption, title of the paper (L.Civ.R. 10.1(b))
// ---------------------------------------------------------------------------

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in need(meta, "caption").parties.enumerate() {
      if k > 0 { rows.push("v.") }
      for n in p.names { rows.push(n) }
      rows.push(("pad", p.designation))
    }
    set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
    stack(dir: ttb, spacing: single-leading, ..rows.map(r => {
      if type(r) == array { pad(left: 1.8in, inl(r.at(1))) } else { inl(r) }
    }))
  }),
  block(inset: (left: 0.1in), {
    // Civil Action No. is the Clerk's number, so a new complaint leaves it blank (L.Civ.R. 10.1(b)).
    let cn = need(meta, "case_number")
    let judge = need(meta, "judge")
    let rows = ("Civil Action No. " + (if cn == "" { "_" * 14 } else { cn }),)
    if judge != "" { rows.push("Hon. " + judge + ", U.S.D.J.") }
    rows.push(v(pitch * 0.5))
    rows.push(strong(upper(need(meta, "title"))))
    set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
    stack(dir: ttb, spacing: single-leading, ..rows.map(r => if type(r) == str { inl(r) } else { r }))
  }),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  line-stack(need(meta, "counsel"))
  v(pitch)
  align(center, stack(dir: ttb, spacing: 0pt, ..need(meta, "court").map(l => strong(upper(l)))))
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph, except a chunk that starts with one of `unnumbered_prefixes` in the
/// frontmatter (WHEREFORE clauses and the jury demand). Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, meta, para-counter) = {
  let prefixes = meta.at("unnumbered_prefixes", default: ())
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Headings are sticky blocks (see the show rules in njd-complaint), so each stays with the first line
  // of the chunk after it and never ends a page. Paragraphs break across pages like any text.
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are lettered (a., b., ...) by the enum setting.
      block(width: 100%, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else if prefixes.any(p => t.starts-with(p)) {
      block(width: 100%, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      para-counter.step()
      // Only the number needs context (the counter's value at this place); the text stays a breakable paragraph.
      block(width: 100%, {
        set par(leading: body-leading)
        h(para-indent)
        context [#(para-counter.display()).]
        h(number-gap)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature blocks (L.Civ.R. 10.1(b), 11.1; "s/" line per the D.N.J. ECF Policies ¶ 12(a))
// ---------------------------------------------------------------------------

#let signature-block(date, sig) = block(breakable: false, above: pitch, {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  grid(columns: (3in, 1fr), column-gutter: 0.2in,
    [Dated: #date],
    stack(dir: ttb, spacing: single-leading,
      line-stack(sig.firm),
      v(pitch * 0.5),
      inl("By: /s/ " + sig.signer),
      line-stack(sig.lines),
    ),
  )
})

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let njd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("counsel", "court", "caption", "case_number", "judge", "title", "jury_demand", "date", "signature") {
    let _ = need(meta, k)
  }
  // L.Civ.R. 38.1: a jury demand endorsed on a pleading puts "and Demand for Jury Trial" in its title.
  if meta.jury_demand and not lower(meta.title).contains("demand for jury trial") {
    panic("njd-complaint: a jury demand needs `and Demand for Jury Trial` in the title (L.Civ.R. 38.1)")
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: page-margin, numbering: "1")
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false) // NJD-FORM-003: a paragraph break keeps the double-spaced pitch
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 a centered bold caps section; level 2 a centered bold sub-heading.
  show heading.where(level: 1): it => block(width: 100%, above: pitch * 0.75, below: pitch * 0.25, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.75, below: pitch * 0.25, sticky: true,
    align(center, strong(it.body)))

  cover(meta)
  let para-counter = counter("allegation")
  allegations(body, meta, para-counter)
  signature-block(need(meta, "date"), need(meta, "signature"))

  // Certification (L.Civ.R. 11.2): a separate section with its own signature, on its own page.
  if "certification" in meta {
    let cert = meta.certification
    pagebreak(weak: true)
    block(width: 100%, above: 0pt, below: pitch * 0.5, sticky: true,
      align(center, strong(upper(cert.title))))
    set par(leading: body-leading, first-line-indent: para-indent)
    cmarker.render(cert.text.trim(), raw-typst: false, smart-punctuation: true)
    signature-block(cert.date, cert.signature)
  }
}
