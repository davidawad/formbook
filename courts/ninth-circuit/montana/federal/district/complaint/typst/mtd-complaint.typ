// U.S. District Court, District of Montana: complaint.
//
// Rule-driven and content-agnostic. Rule IDs (MT-...) refer to ../README.md, which quotes the rule
// text: D. Mont. L.R. 1.5 (form of documents), 3.1 (filing a new case), 38.1 (jury demand); Fed. R.
// Civ. P. 8, 10 and 11. No case-specific text, no coordinates measured off the exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md).
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // MT-FORM-002: a proportionally spaced serif; the only face vendored in fonts/
#let type-size = 14pt                   // MT-FORM-002: typewritten in 14-point font (L.R. 1.5(a)(2))
#let line-pitch = 32pt                  // MT-FORM-003: double-spaced (L.R. 1.5(a)(2)); 2 x 16 pt at 14 pt type, see README.md
#let body-leading = 1.64em              // gap between lines of body text: EB Garamond's line box is 0.65 em, so 1.64 em gives a 32 pt baseline pitch at 14 pt (measured, README.md)
#let single-leading = 0.6em             // counsel block, caption, signature, footnotes: single-spaced (about 17.5 pt at 14 pt)
// The vertical gap between two blocks, so that the first line of the next block lands one line-pitch
// below the last line of the previous one: the pitch minus EB Garamond's 0.65 em line box (measured).
#let gap = line-pitch - 0.65em
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)   // MT-FORM-001 (L.R. 1.5(a)(1)): one-inch margins
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let heading-tab = 0.5in
#let footer-size = 14pt                 // page number at the foot of every page (MT-FORM-004, L.R. 1.5(a)(3))
#let caption-cols = (1.1fr, 1fr)        // style choice: party column a little wider than the case column

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italic role lines, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mtd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}


// ---------------------------------------------------------------------------
// Cover: counsel block (upper left), court title, caption, title of the paper (Appendix C, Form A)
// ---------------------------------------------------------------------------

/// One counsel group: its lines, single-spaced.
#let counsel-group(lines) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in lines { inl(l); linebreak() }
}

/// Counsel groups in two columns (as the exemplar sets them), so the cover fits on page 1.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    stack(dir: ttb, spacing: line-pitch * 0.5, ..groups.slice(0, 1).map(counsel-group)),
    stack(dir: ttb, spacing: line-pitch * 0.5, ..groups.slice(1).map(counsel-group)),
  )
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  emph(inl(need(meta, "counsel_role")))
}

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  // One centred line each: the court, the district, the division (Appendix C, Form A).
  align(center, strong(stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE DISTRICT OF MONTANA],
    upper(need(meta, "division")),
  )))
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); linebreak() }
      v(line-pitch * 0.5)
      pad(left: 1.4in, inl(side.designation))
      if i < sides.len() - 1 {
        v(line-pitch * 0.5)
        [v.]
        v(line-pitch * 0.5)
      }
    }
  }
  let case-no = need(meta, "case_number")
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #if case-no == "" { "______________" } else { case-no }]
    v(line-pitch * 1.5)
    strong(upper(inl(need(meta, "title"))))
  }
  table(
    columns: caption-cols,
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = {
  counsel-block(meta)
  v(line-pitch)
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered prayer, signature
// ---------------------------------------------------------------------------

/// Signature block: the date, the firm, and "/s/" over the printed name (L.R. 1.5(b), 11.1).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.1in), [DATED: #need(meta, "date")], {
      if "firm" in sig { strong(upper(inl(sig.firm))); linebreak() }
      v(line-pitch)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph; the template numbers them, so the author
/// types no numbers. Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let paragraphs(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A footnote definition is not a paragraph of its own: its text is printed at the reference. cmarker
  // binds a reference only to a definition in the same call, so every chunk that holds a reference is
  // rendered together with all the definitions.
  let defs = chunks.map(c => c.trim()).filter(t => t.starts-with("[^")).join("\n\n")
  // Every chunk is a top-level block with its own gap below, so no gap is lost to a wrapper.
  // A heading is `sticky`, so it is kept with the block after it and never ends a page.
  for c in chunks {
    let t = c.trim()
    let src = if t.contains("[^") and not t.starts-with("[^") { t + "\n\n" + defs } else { t }
    if t.starts-with("[^") {
      // A footnote definition: printed at its reference, so it is not a paragraph of its own.
      continue
    } else if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if t.starts-with("%") {
      // A paragraph the rules leave unnumbered (the prayer's lead-in, the jury demand): `%` marks it.
      // sticky: the paragraph stays with the signature block after it, so a signature never stands alone.
      block(width: 100%, below: gap, sticky: true, {
        set par(leading: body-leading, first-line-indent: 0pt)
        cmarker.render(t.slice(1).trim(), raw-typst: false, smart-punctuation: true)
      })
    } else if t.starts-with(regex("^[-*+][ \\t]|^\\d+\\.[ \\t]")) {
      // Lists (the prayer's lettered items) are not numbered as paragraphs. A list may break across pages.
      block(width: 100%, below: gap, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      })
    } else {
      para-counter.step()
      block(width: 100%, below: gap, {
        set par(leading: body-leading, first-line-indent: 0pt)
        context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(src, raw-typst: false, smart-punctuation: true)]
      })
    }
  }
}

#let mtd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "division", "counsel", "counsel_role", "caption", "title", "signature", "date") {
    let _ = need(meta, k)
  }
  // L.R. 38.1: a pleading that incorporates a jury demand must say so in its title.
  if need(meta, "jury_demand") {
    assert(upper(meta.title).contains("JURY TRIAL"), message: "mtd-complaint: L.R. 38.1: the title must indicate the jury demand")
  }
  assert(need(meta, "caption").len() >= 2, message: "mtd-complaint: FRCP 10(a): the title must name all parties on both sides")

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section; level 2 a bold sub-heading at the margin; level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: 0pt, below: gap, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: gap, sticky: true,
    strong(it.body))
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: gap, sticky: true,
    strong(emph(it.body)))

  cover(meta)
  pagebreak()

  // The lead-in (FRCP 10(b) does not number it) is printed unnumbered before the numbered paragraphs.
  if "lead_in" in meta {
    block(width: 100%, below: gap, {
      set par(leading: body-leading, first-line-indent: para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered paragraphs (Fed. R. Civ. P. 10(b)).
  let para-counter = counter("paragraph")
  paragraphs(body, para-counter)

  signature-block(meta)
}
