// U.S. Bankruptcy Court, Eastern District of Kentucky: adversary complaint (FRBP 7001).
//
// Rule-driven and content-agnostic. Requirement IDs (KYEB-...) refer to ../README.md, which quotes the
// rule text (FRBP 7001, 7003, 7008, 7010, 9004, 9011; FRCP 5.2 and 10). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // KYEB-FORM-001: no E.D. Ky. bankruptcy rule sets a typeface; vendored in /fonts.
#let type-size = 13pt                    // KYEB-FORM-001: a legible size (FRBP 9004(a)); 13 pt because EB Garamond sets smaller than Times at the same size.
#let line-pitch = 24pt                   // KYEB-FORM-003: double spacing for the body (a convention, see ../README.md).
#let body-leading = 0.54em               // gap between lines of body text; tuned so the line pitch is line-pitch.
#let single-leading = 0.2em              // caption, counsel, signature, headings, footnotes.
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let para-indent = 0.5in                 // first-line indent of paragraphs
#let footer-size = 12pt                  // page number at the foot of each page
#let caption-left = 3.3in                // width of the debtor and party column of the caption

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("kyeb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), 7010 and Official Form 416A, substantially conformed)
// ---------------------------------------------------------------------------

/// Court name lines, centered and bold, at the top of the first page (FRBP 9004(b)(1)).
#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "court").map(l => [#l]).join(linebreak())))
}

/// Caption: debtors (with the case number) on the left, the chapter and case number on the right, then
/// the parties, then the adversary number (FRBP 9004(b)(2)-(3)). A rule separates the blocks.
#let caption-table(meta) = {
  let cap = need(meta, "caption")
  let debtors = cap.debtors
  let left-top = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [In re:]
    v(line-pitch * 0.5)
    for (i, n) in debtors.names.enumerate() {
      inl(n)
      if i == 0 and "footnote" in debtors { footnote(inl(debtors.footnote)) }
      parbreak()
    }
    pad(left: 1.8in, inl(debtors.designation))
  }
  let right-top = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "chapter")]
    v(line-pitch * 0.5)
    [Case No. #need(meta, "case_number")]
    if need(meta, "jointly_administered") {
      linebreak()
      [(Jointly Administered)]
    }
  }
  let left-bottom = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in cap.parties.enumerate() {
      for n in side.names { inl(n); parbreak() }
      if "serve" in side {
        for l in side.serve { inl(l); linebreak() }
        v(line-pitch * 0.5)
      }
      pad(left: 1.8in, inl(side.designation))
      if i < cap.parties.len() - 1 {
        v(line-pitch * 0.5)
        [v.]
        v(line-pitch * 0.5)
      }
    }
  }
  let right-bottom = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    let adv = meta.at("adversary_number", default: "")
    if adv == "" {
      let blank = "_" * 12
      [Adv. No. #blank]
    } else {
      [Adv. No. #adv]
    }
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, top: 0.4em, bottom: 0.6em, left-top),
    pad(left: 1.2em, top: 0.4em, bottom: 0.6em, right-top),
    pad(right: 1.2em, top: 0.6em, bottom: 1em, left-bottom),
    pad(left: 1.2em, top: 1.6em, bottom: 1em, right-bottom),
  )
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b), applied by FRBP 7010)
// ---------------------------------------------------------------------------

#let footnote-def = regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$")
#let footnote-ref = regex("\\[\\^([^\\]]+)\\]")

/// Inline content of a paragraph. Each `[^key]` becomes a footnote whose text is the definition `key`.
#let with-notes(t, notes) = {
  let out = []
  let rest = t
  let m = rest.match(footnote-ref)
  while m != none {
    out += inl(rest.slice(0, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    rest = rest.slice(m.end)
    // Markdown trims the leading space of the text after a footnote mark, so the space is put back here.
    if rest.starts-with(" ") {
      out += [ ]
      rest = rest.slice(1)
    }
    m = rest.match(footnote-ref)
  }
  out + inl(rest)
}

/// The body, one blank-line-separated chunk at a time. Rules (also in ../README.md):
/// - a `#` heading is centered (level 1) or bold (level 2) and is kept with the chunk after it;
/// - a chunk in parentheses directly after a heading is its unnumbered subtitle (a Count's title);
/// - a list (`1. ` or `- `) is unnumbered; the template letters the items a., b., c.;
/// - paragraphs before the first heading (the lead-in), paragraphs starting WHEREFORE and paragraphs
///   ending in a colon (they introduce a list) are unnumbered;
/// - every other paragraph is numbered 1, 2, 3 ... in order; the author types no numbers.
#let body-blocks(body, para-counter, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbering-on = false
  let after-heading = false
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.match(footnote-def) != none { continue }
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      numbering-on = true
      after-heading = true
      continue
    }
    if after-heading and t.starts-with("(") and t.ends-with(")") {
      pending += align(center, inl(t))
      after-heading = false
      continue
    }
    after-heading = false
    if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: 100%, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      let para = with-notes(t, notes)
      // Each paragraph is its own block, so consecutive paragraphs never run together on one line.
      let piece = block(width: 100%, if numbering-on and not t.starts-with("WHEREFORE") and not t.ends-with(":") {
        para-counter.step()
        context [#h(para-indent)#(para-counter.display()).#h(0.3in)#para]
      } else {
        [#h(para-indent)#para]
      })
      if has-pending {
        block(breakable: false, width: 100%, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if has-pending { pending }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a): signed by an attorney in the attorney's name, with address and telephone)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [#sig.firm]
      v(line-pitch)
      [By: /s/ #sig.signer]
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let kyeb-adversary-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "chapter", "case_number", "jointly_administered", "title", "date", "signature") {
    let _ = need(meta, k)
  }
  // Footnote definitions, collected before the body is rendered (they may follow their reference).
  let notes = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(footnote-def)
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  let para-counter = counter("allegation")

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    footer: context align(center, text(size: footer-size, counter(page).display())),
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

  // Headings: level 1 centered capitals; level 2 centered bold (Count titles); level 3 bold at the margin.
  show heading: set text(size: type-size)
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    strong(it.body))

  // ---- first page: court, caption, title ----
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "title").map(l => [#l]).join(linebreak())))
  v(line-pitch * 0.5)

  // ---- body ----
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  body-blocks(body, para-counter, notes)

  signature-block(meta)
}
