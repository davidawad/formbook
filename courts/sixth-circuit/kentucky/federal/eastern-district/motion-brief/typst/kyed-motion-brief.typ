// U.S. District Court, Eastern District of Kentucky: memorandum in support of a motion (Fed. R. Civ. P.
// 12(b)), with optional certificate of service.
//
// Rule-driven and content-agnostic. Requirement IDs (KYED-...) refer to ../README.md, which quotes the
// rule text (E.D. Ky. LR 5.2(a), 7.1; Fed. R. Civ. P. 5(d)(1)(B), 7(b), 12(b)). No case-specific text,
// no coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the caption, signature and certificate come from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // KYED-FORM-002: proportionally spaced font; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // KYED-FORM-002: at least 12-point type, footnotes included.
#let line-pitch = 24pt                  // KYED-FORM-001: text double spaced. Measured on the render (README.md).
#let body-leading = 1.345em             // gap between lines of body text, tuned so the baseline pitch is line-pitch.
#let single-leading = 0.495em            // caption, headings, block quotes, footnotes, signature block: single spaced.
#let margin-all = 1in                   // KYED-FORM-001: at least one inch on all sides.
#let para-indent = 0.5in                // first-line indent of body paragraphs.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, bold, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("kyed-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines in a single-spaced stack.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper (KYED-FIRST-001, KYED-FIRST-002)
// ---------------------------------------------------------------------------

/// Court title, centered and bold, one line per entry in the frontmatter `court` list.
#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, strong(for l in need(meta, "court") { [#upper(l)] + linebreak() }))
}

/// Parties: each party's names, then its designation right-aligned; "v." between the parties.
#let party-column(meta) = {
  let parties = need(meta, "caption")
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for (i, p) in parties.enumerate() {
    if i > 0 {
      v(line-pitch * 0.5)
      pad(left: 1.2in, [v.])
      v(line-pitch * 0.5)
    }
    for n in p.names { inl(n); linebreak() }
    if p.designation != "" {
      v(single-leading)
      align(right, pad(right: 0.3in, inl(p.designation)))
    }
  }
}

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  let label = meta.at("case_label", default: "Civil Action No.")
  align(center)[#label #need(meta, "case_number")]
  v(line-pitch * 0.5)
  block(width: 100%, stroke: (bottom: 0.75pt), height: 0pt)
  v(line-pitch * 0.5)
  party-column(meta)
  v(line-pitch * 0.5)
  block(width: 100%, stroke: (bottom: 0.75pt), height: 0pt)
}

// ---------------------------------------------------------------------------
// Signature block (KYED-SIG-001) and certificate of service (KYED-SIG-002)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(columns: (1fr, 3.1in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(single-leading * 2)
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(single-leading * 2)
      inl(sig.sign_line)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

/// Optional certificate of service: starts on a new page, as the exemplar does. Not required here:
/// Fed. R. Civ. P. 5(d)(1)(B) says none is needed for a paper served through the court's e-filing
/// system, so the sample supplies it only because the exemplar carries one.
#let certificate-block(meta) = {
  let c = meta.at("certificate", default: none)
  if c == none { return }
  pagebreak(weak: true)
  block(width: 100%, above: 0pt, below: line-pitch * 0.5, align(center, strong("CERTIFICATE OF SERVICE")))
  par(first-line-indent: para-indent, inl(c.text))
  v(line-pitch * 0.5)
  for s in c.services {
    block(breakable: false, width: 100%, above: 0pt, below: single-leading * 1.5, line-stack(s))
  }
  block(breakable: false, above: line-pitch, grid(columns: (1fr, 3.1in), [], {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    inl(c.sign_line)
    linebreak()
    inl(c.designation)
  }))
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let kyed-motion-brief(meta, md) = {
  for k in ("court", "caption", "case_number", "title", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set document(title: need(meta, "title") + ", No. " + str(need(meta, "case_number")))
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)

  // Headings, typed by the author with their own numbers ("I.", "A.", "1.", "a."). Level 1: centered caps.
  // Level 2: bold, at the margin. Level 3: bold, indented. Level 4: bold italic, indented further.
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, text(size: type-size, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    pad(left: 0.5in, par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, text(size: type-size, strong(it.body)))))
  show heading.where(level: 4): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    pad(left: 1in, par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, text(size: type-size, strong(emph(it.body))))))

  // Block quotations: single spaced, indented both sides, not first-line indented.
  show quote.where(block: true): it => pad(left: 0.75in, right: 0.75in, bottom: line-pitch * 0.5,
    par(first-line-indent: 0pt, leading: single-leading, it.body))

  // Footnotes: single spaced, the form size.
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // ---- first page ----
  court-title(meta)
  v(line-pitch)
  caption(meta)
  align(center, block(above: line-pitch, below: line-pitch, strong(upper(need(meta, "title")))))

  // ---- body (the memorandum text, rendered from markdown) ----
  // The conclusion and the signature block are kept together in one unbreakable block, so a signature
  // never starts a page on its own. Footnote definitions must come before "# CONCLUSION" in the sample
  // (they are rendered with the body, which holds every reference).
  let split = md.split(regex("\\r?\\n# CONCLUSION\\r?\\n"))
  if split.len() == 2 {
    cmarker.render(split.at(0), raw-typst: false, smart-punctuation: true, h1-level: 1)
    block(breakable: false, {
      cmarker.render("# CONCLUSION\n" + split.at(1), raw-typst: false, smart-punctuation: true, h1-level: 1)
      signature-block(meta)
    })
  } else {
    cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
    signature-block(meta)
  }
  certificate-block(meta)
}
