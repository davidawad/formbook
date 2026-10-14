// U.S. Bankruptcy Court, N.D. Indiana (innb): complaint commencing an adversary proceeding.
//
// Rule-driven and content-agnostic. Requirement IDs (INNB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same
// file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // INNB-FORM-005: no typeface is named in B-5005-2; EB Garamond is the vendored font. See ../README.md.
#let type-size = 13pt                    // INNB-FORM-005: no size is named in B-5005-2; 13 pt matches the ca9 precedent (Garamond sets small). See ../README.md.
#let line-pitch = 24pt                   // INNB-FORM-001: double spacing. With the margins below, 27 lines fit per page.
#let body-leading = 0.54em               // gap between lines of body text; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // caption, counsel and debtor blocks, signature block, quotations.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // INNB-FORM-004: 8 1/2 x 11 paper; margins are a style choice (no margin figure in B-5005-2).
#let para-indent = 0.5in
#let footer-size = 11pt                  // page number only (INNB-FORM-003); not body text.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("innb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("innb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let para-counter = counter("para")

// ---------------------------------------------------------------------------
// Caption (INNB-CAP-001 to 003: FRBP 9004(b); FRBP 7010 and Official Form 416D)
// ---------------------------------------------------------------------------

/// Court title, centred, one line per entry of `court`.
#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "court").map(l => [#l]).join(linebreak())))
}

/// Debtor block (upper left) beside the case number and chapter (upper right).
#let debtor-table(meta) = {
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [In re:]
    v(single-leading * 2)
    for d in need(meta, "debtors") {
      pad(left: 0.5in, inl(d.names))
      linebreak()
      pad(left: 1.6in, inl(d.designation))
      v(single-leading * 2)
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    v(single-leading * 2)
    [Case No. #need(meta, "case_number")]
    linebreak()
    [Chapter #need(meta, "chapter")]
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    pad(right: 1.2em, left),
    pad(left: 1.2em, right),
  )
}

/// Plaintiff and defendant block (left, closed by a rule) beside the adversary number (right).
#let parties-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      inl(side.names)
      linebreak()
      pad(left: 1.6in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(left)[v.]; v(line-pitch * 0.5) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    v(line-pitch * 0.5)
    [Adv. Proc. No. #need(meta, "adv_number")]
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

/// Title of the paper, centred bold caps, one line per entry of `title`.
#let title-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "title").map(l => upper(inl(l))).join(linebreak())))
}

// ---------------------------------------------------------------------------
// Body (INNB-CMP-001: numbered paragraphs, FRCP 10(b) via FRBP 7010)
// ---------------------------------------------------------------------------

/// Heading, centred bold caps (`# ...`).
#let heading-centre(t) = block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
  align(center, strong(upper(inl(t)))))

/// Sub-heading, left, bold (`## ...`).
#let heading-left(t) = block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
  { set par(first-line-indent: 0pt); strong(inl(t)) })

/// A chunk plus the footnote definitions it cites, so cmarker can build the footnotes in the same call.
#let with-notes(c, defs) = {
  let keys = c.matches(regex("\\[\\^(\\w+)\\]")).map(m => m.captures.at(0)).dedup()
  c + keys.map(k => "\n\n" + defs.at(k)).join("")
}

/// Split the body into blank-line-separated chunks and render each one. Chunks are: headings (`#`,
/// `##`), footnote definitions (collected and attached to the chunk that cites them), block quotations
/// (`>`, single-spaced), lettered sub-items (`A.`, unnumbered), the prayer (`WHEREFORE`, unnumbered),
/// and everything else (numbered paragraphs).
#let render-body(src) = {
  let chunks = src.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  for c in chunks {
    if c.starts-with("[^") and c.contains("]:") {
      let m = c.match(regex("^\\[\\^(\\w+)\\]:"))
      defs.insert(m.captures.at(0), c)
    }
  }
  for c in chunks {
    if c.starts-with("[^") and c.contains("]:") { continue }
    if c.starts-with("## ") {
      heading-left(c.slice(3).trim())
    } else if c.starts-with("# ") {
      heading-centre(c.slice(2).trim())
    } else if c.starts-with(">") {
      pad(left: 0.5in, right: 0.5in, { set par(leading: single-leading, first-line-indent: 0pt); inl(with-notes(c, defs)) })
    } else if c.match(regex("^[A-Z]\\.\\s")) != none or c.starts-with("WHEREFORE") {
      { set par(first-line-indent: (amount: para-indent, all: true)); inl(with-notes(c, defs)) }
    } else {
      para-counter.step()
      { set par(first-line-indent: (amount: para-indent, all: true)); [#context [#para-counter.display()#"."] #h(0.3em) #inl(with-notes(c, defs))] }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (convention: no local rule cites the form; see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [#if "date" in meta [Dated: #meta.date]], {
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(line-pitch)
      [#sig.firm]
      linebreak()
      emph[#sig.role]
      v(line-pitch)
      [By: #box(width: 2.8in, line(length: 100%))]
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

#let innb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtors", "case_number", "chapter", "caption", "adv_number", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",                                  // INNB-FORM-004: 8 1/2 x 11, one side
    margin: margins,
    numbering: "1",
    footer: context align(center, text(size: footer-size, counter(page).display("1"))),  // INNB-FORM-003
  )
  set document(
    title: need(meta, "title").join(" ") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: 0pt, justify: false,
  )
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // INNB-FORM-002: the title is set out on the first page (B-5005-2(a)(2)); the caption is the first thing on it.
  court-title(meta)
  v(line-pitch)
  debtor-table(meta)
  v(line-pitch * 0.5)
  parties-table(meta)
  v(line-pitch * 0.5)
  title-block(meta)
  v(line-pitch * 0.5)

  if "lead_in" in meta {
    par(first-line-indent: para-indent, inl(meta.lead_in))
  }
  render-body(md)
  signature-block(meta)
}
