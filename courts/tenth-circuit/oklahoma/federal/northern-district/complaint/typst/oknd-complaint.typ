// U.S. District Court, Northern District of Oklahoma: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (OKND-...) refer to ../README.md, which quotes the
// rule text: LGnR2-4 (format of papers; Local Rules, effective 2026-07-31), LCvR38-1 (jury demand notation),
// LCvR3-1 (civil cover sheet is a separate filing), Fed. R. Civ. P. 8(a) and 10(a)-(b). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Caladea"    // OKND-FORM-002: proportional font; matches the audited exemplar (docs/FONTS.md)
#let type-size = 12pt                    // OKND-FORM-002: not smaller than 12 pt.
#let footer-size = 12pt                  // page number, at the 12 pt floor.
#let line-pitch = 24pt                   // OKND-FORM-001: double spacing. The page holds 27 such lines between the margins.
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is line-pitch.
#let single-leading = 0.398em            // caption and signature block (single-spaced, as in both exemplars); see ../README.md.
#let margins = (top: 1in, bottom: 1in, x: 1in)   // OKND-FORM-003: at least one inch on the top, bottom and sides.
#let para-indent = 0.5in                 // first-line indent of a numbered paragraph.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oknd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Render an inline markdown string (italics, bold, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("oknd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Cover: court name, caption, title (FRCP 10(a); OKND-CAP-001) and the jury notation (OKND-CAP-002)
// ---------------------------------------------------------------------------

/// The court's own name, on two centered lines (the same wording the court uses on every paper).
#let court-title() = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong[UNITED STATES DISTRICT COURT])
  v(single-leading)
  align(center, strong[NORTHERN DISTRICT OF OKLAHOMA])
}

/// Parties on the left (each side: its names, then its designation; "v." between sides), the
/// file number on the right, closed by a rule on the right and bottom.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      stack(dir: ttb, spacing: 0pt, ..side.names.map(n => inl(n)))
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
    }
  }
  let right = align(horizon, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
  })
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, bottom: 0.3em, right),
  )
}

#let cover(meta) = {
  court-title()
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  // The title of the pleading, then (OKND-CAP-002) the notation that a jury is demanded, directly under it.
  align(center, strong(inl(need(meta, "title"))))
  if meta.at("jury_demand", default: false) {
    v(single-leading * 2)
    align(center, strong[Jury Trial Demanded])
  }
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), lettered lists, headings
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      stack(dir: ttb, spacing: 0pt,
        [/s/ #inl(sig.signer)],
        ..sig.at("lines", default: ()).map(l => inl(l)),
      )
    })
  })
}

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading: its show rule keeps it with the block after it (sticky).
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list (prayer items, subparagraphs): lettered (a), (b), ... by the enum numbering below.
      // A list may break across pages.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is an indented paragraph, not a numbered allegation.
      block(width: 100%, breakable: true, {
        set par(leading: body-leading, first-line-indent: para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      para-counter.step()
      block(width: 100%, breakable: true, {
        set par(leading: body-leading, first-line-indent: 0pt)
        context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
  }
}

#let oknd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "title", "signature", "date") {
    let _ = need(meta, k)
  }
  let para-counter = counter("allegation")

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context {
      set text(size: footer-size)
      align(center, counter(page).display("1"))
    },
  )
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 centered bold caps; level 2 centered bold; level 3 bold italic at the margin.
  // Sticky, so a heading is never the last line on a page.
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    strong(emph(it.body)))

  cover(meta)

  // Unnumbered lead-in ("COMES NOW ...") before the numbered paragraphs.
  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)

  signature-block(meta)
}
