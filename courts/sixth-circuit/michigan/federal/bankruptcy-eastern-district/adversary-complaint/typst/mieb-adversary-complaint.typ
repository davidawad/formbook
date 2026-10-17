// U.S. Bankruptcy Court, E.D. Michigan: adversary complaint (Fed. R. Bankr. P. 7001, 7008, 7010;
// Local Bankruptcy Rules 9004-1 and 9029-1(h)).
//
// Rule-driven and content-agnostic. Requirement IDs (MIEB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file
// (schema: ../README.md). Paragraphs are numbered by the template (Fed. R. Civ. P. 10(b)); a paragraph
// that begins with WHEREFORE is a prayer and is not numbered.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // MIEB-FORM-002: proportional serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                    // MIEB-FORM-002: LBR 9029-1(h) "14 point (proportional)" for all text and footnotes.
#let body-leading = 1.345em             // MIEB-FORM-003: double-spaced text; tuned so body pitch is about 2 x single spacing (see ../README.md).
#let single-leading = 0.3em              // caption, counsel and signature blocks (MIEB-FORM-004: single spacing is an accepted convention).
#let margins = 1in                       // MIEB-FORM-001: LBR 9029-1(h) "at least 1 inch on the top, sides and bottom".
#let para-indent = 0.5in                 // first-line indent of numbered paragraphs and prayers.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, links, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mieb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mieb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines of text, one per line, single-spaced.
#let lines-of(items) = items.map(x => [#x]).join(linebreak())

// ---------------------------------------------------------------------------
// Document setup: applied with `#show: complaint-doc.with(meta)` in main.typ
// ---------------------------------------------------------------------------

#let complaint-doc(meta, doc) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: type-size, counter(page).display("1 of 1", both: true))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, first-line-indent: 0pt, spacing: body-leading)
  // Footnotes are text too (MIEB-FORM-002): same size as the body.
  show footnote.entry: set text(size: type-size)
  doc
}

// ---------------------------------------------------------------------------
// Cover: court, caption, title (MIEB-CAP-001 to MIEB-CAP-003)
// ---------------------------------------------------------------------------

/// One block of single-spaced text, full width.
#let single-block(c) = block(width: 100%, par(leading: single-leading, first-line-indent: 0pt, c))

/// The court name lines, centered and in capitals (the court's name as printed in the caption).
#let court-head(meta) = align(center, single-block(lines-of(need(meta, "court"))))


/// Caption table: left, the debtor in the bankruptcy case; right, the case number, chapter and judge
/// (MIEB-CAP-001, LBR 9004-1(a)(1) and (2)).
#let bankruptcy-caption(meta) = {
  let ir = need(meta, "in_re")
  let cs = need(meta, "case")
  grid(
    columns: (1fr, 1fr),
    gutter: 0pt,
    single-block([
      In re: #h(0.25em) #lines-of(ir.names) \
      #align(right, [#ir.role])
    ]),
    single-block([
      Case No. #cs.number \
      Chapter #cs.chapter \
      #cs.judge
    ]),
  )
}

/// Party block of the adversary proceeding, left; the adversary number and chapter, right
/// (MIEB-CAP-002, Fed. R. Bankr. P. 7010: the caption conforms to Official Form 416).
#let adversary-caption(meta) = {
  let parties = need(meta, "caption")
  let cs = need(meta, "case")
  let left = ()
  let i = 0
  for p in parties {
    if i > 0 { left.push(align(center, [vs.])) }
    left.push(single-block([
      #lines-of(p.names) \
      #align(right, [#p.designation])
    ]))
    i += 1
  }
  grid(
    columns: (1fr, 1fr),
    gutter: 0pt,
    stack(dir: ttb, spacing: 0.6em, ..left),
    single-block([
      Chapter #cs.chapter \
      Adversary Proceeding No. #{
        let an = need(meta, "adversary_number")
        if an == "" { box(width: 1.2in, height: 1em, stroke: (bottom: 0.5pt)) } else { an }
      }
    ]),
  )
}

#let rule-line = line(length: 100%, stroke: 0.5pt)

#let cover(meta) = {
  court-head(meta)
  v(1.2em)
  rule-line
  bankruptcy-caption(meta)
  rule-line
  v(0.6em)
  adversary-caption(meta)
  rule-line
  v(1.2em)
  align(center, strong(need(meta, "title")))
  v(0.8em)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayers (MIEB-BODY-001 to MIEB-BODY-003)
// ---------------------------------------------------------------------------

/// The body, chunk by chunk. `# ` is a centered bold heading, `## ` a centered bold subheading,
/// a chunk beginning WHEREFORE is an unnumbered prayer, any other chunk is a numbered paragraph.
#let body(meta, md) = {
  // Footnotes are not supported by this chunked body (each chunk is rendered alone); fail loudly.
  if md.contains("[^") { panic("mieb-adversary-complaint: footnotes are not supported in a complaint body") }
  let chunks = md.split("\n\n").map(c => c.trim()).filter(c => c != "")
  let n = 0
  // The lead-in (the opening paragraph before the first heading) is unnumbered.
  block(width: 100%, inl(need(meta, "lead_in")))
  for c in chunks {
    if c.starts-with("# ") {
      block(width: 100%, sticky: true, above: 1.1em, below: body-leading, align(center, strong(c.slice(2))))
    } else if c.starts-with("## ") {
      block(width: 100%, sticky: true, above: 0pt, below: body-leading, align(center, strong(c.slice(3))))
    } else if c.starts-with("WHEREFORE") {
      block(width: 100%, inl(c))
    } else {
      n += 1
      block(width: 100%, inl(str(n) + "\\. " + c))
    }
  }
}

/// The signature block after the prayer (MIEB-SIG-001): the date at left, the signer at right.
#let signature(meta) = {
  let sig = need(meta, "signature")
  v(1.2em)
  grid(
    columns: (1fr, 3.2in),
    gutter: 0pt,
    [Dated: #need(meta, "date")],
    single-block([
      #sig.signer \
      #lines-of(sig.lines)
    ]),
  )
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let complaint-body(meta, md) = {
  cover(meta)
  body(meta, md)
  signature(meta)
}
