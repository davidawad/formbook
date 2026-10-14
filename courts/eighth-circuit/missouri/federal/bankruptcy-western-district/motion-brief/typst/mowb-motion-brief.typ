// U.S. Bankruptcy Court, Western District of Missouri: memorandum in support of a motion
// (FRBP 9013; W.D. Mo. Bankr. L.R. 9013-1).
//
// Rule-driven and content-agnostic. Requirement IDs (MOWB-...) refer to ../README.md, which quotes
// the rule text: Fed. R. Bankr. P. 9004(a)-(b); W.D. Mo. Bankr. L.R. 9011-4, 9013-1, 9013-3, 17004-1.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same
// file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Vendored in /fonts. No Missouri or FRBP type rule; see ../README.md, gap 2.
#let type-size = 13pt                    // Tier 2: the exemplars are 12 pt Times; EB Garamond needs 13 pt for the same apparent size.
#let body-leading = 0.55em               // Tier 2: single spacing within a paragraph, as in both memorandum exemplars.
#let body-spacing = 1.0em                // Tier 2: one blank line between paragraphs, as in both memorandum exemplars.
#let single-leading = 0.5em              // Caption, signature block, certificate, headings.
#let line-pitch = 1.0em + body-leading   // A blank line of the body text, for spacing around headings and blocks.
#let page-margin = 1in                   // Tier 2: 1 inch on all sides, as in the exemplars.
#let para-indent = 0.5in                 // First-line indent of body paragraphs.
#let caption-left = 3.8in                // Party column of the caption; the ")" column follows.
#let caption-line = 16pt                 // Height of one caption line (single spacing for 13 pt EB Garamond).
#let footer-size = 11pt                  // Page number at the foot of each page.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mowb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mowb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), 7010 with Official Form 416D; W.D. Mo. L.R. 9013-1, 17004-1(A))
// ---------------------------------------------------------------------------

/// Court title, centered, one line per entry of `court` (FRBP 9004(b): name of the court).
#let court-title(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, for l in need(meta, "court") { upper(l); linebreak() })
  if "division" in meta and meta.division != "" {
    align(center, upper(meta.division))
  }
}

/// The caption as one row per line: left (names and labels), ")" (the separator), right (numbers
/// and judge). Each row is one line, so the ")" column stays aligned without measuring anything.
#let caption-block(meta) = {
  let plaintiffs = need(meta, "plaintiffs")
  let defendants = need(meta, "defendants")
  let adv = if "adv_number" in meta and meta.adv_number != "" {
    "Adv. No. " + meta.adv_number
  } else {
    "Adv. No. ____________"
  }
  let rows = ()
  rows.push(([In re:], ""))
  rows.push(("", ""))
  rows.push((upper(need(meta, "debtor")), "Case No. " + need(meta, "case_number")))
  rows.push(("", "Chapter " + str(need(meta, "chapter"))))
  if "judge" in meta and meta.judge != "" { rows.push(("", meta.judge)) }
  rows.push(([#h(1.5in)Debtor.], ""))
  rows.push(("", ""))
  let first = true
  for p in plaintiffs {
    rows.push((upper(p), if first { adv } else { "" }))
    first = false
  }
  rows.push(([#h(1.5in)#if plaintiffs.len() > 1 [Plaintiffs,] else [Plaintiff,]], ""))
  rows.push(("", ""))
  rows.push(([v.], ""))
  rows.push(("", ""))
  for d in defendants { rows.push((upper(d), "")) }
  rows.push(([#h(1.5in)#if defendants.len() > 1 [Defendants.] else [Defendant.]], ""))
  // An empty cell has no height, so a blank caption line would collapse; it holds a space instead.
  let cell(x) = if x == "" { [ ] } else { x }
  let cells = ()
  for r in rows { cells += (cell(r.at(0)), [)], cell(r.at(1))) }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  // Each caption line is one row of fixed height: the font's own line box is shorter than its glyphs.
  grid(columns: (caption-left, 0.35in, 1fr), rows: (caption-line,) * rows.len(), ..cells)
}

/// Document title under the caption: bold, centered, capitals.
#let doc-title(meta) = {
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs with a first-line indent (memorandum form)
// ---------------------------------------------------------------------------

/// Body chunks: a heading is rendered as is; a list is numbered 1., 2., ... (as in the Issues
/// section); every other paragraph is set with a first-line indent. Memoranda carry no paragraph
/// numbers (Fed. R. Civ. P. 10(b) does not apply to a memorandum of law).
#let body-content(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      out += cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      out += cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else {
      out += [#h(para-indent)#inl(t)#parbreak()]
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (W.D. Mo. L.R. 9011-4, 9013-3)
// ---------------------------------------------------------------------------

/// One block of single-spaced, left-aligned signature lines, set in a fixed-width column.
#let sig-col(lines) = block(width: 3.2in, {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  set align(left)
  lines.map(l => [#l]).join(linebreak())
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, {
    if "date" in meta and meta.date != "" { [Dated: #meta.date] }
    v(line-pitch)
    grid(columns: (1fr, 3.2in), [], stack(dir: ttb, spacing: line-pitch * 0.5,
      sig-col(sig.firm.map(l => upper(l))),
      sig-col(("/s/ " + sig.signer, sig.signer + ", " + sig.bar)),
      sig-col(sig.lines + (emph(inl(sig.role)),)),
    ))
  })
}

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  let sig = need(meta, "signature")
  block(breakable: false, {
    // Not a heading: a level-1 heading here would take a roman numeral from the section counter.
    block(above: body-spacing, below: body-leading, sticky: true, strong(upper("Certificate of Service")))
    set par(leading: body-leading, spacing: body-spacing, first-line-indent: para-indent)
    inl("I certify that on " + cert.date + ", " + cert.manner + ".")
    v(line-pitch)
    align(right, sig-col(("/s/ " + sig.signer, sig.signer)))
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mowb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-spacing, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a bold caps heading with roman numerals (I., II., ...); level 2 a bold
  // sub-heading with capital letters (A., B., ...). Counters "sec" and "sub" reset per section.
  show heading.where(level: 1): it => block(above: body-spacing, below: body-leading, sticky: true, {
    counter("sub").update(0)
    counter("sec").step()
    text(size: type-size, weight: "bold", context numbering("I.", counter("sec").get().first()) + h(0.4in) + upper(it.body))
  })
  show heading.where(level: 2): it => block(above: body-leading, below: body-leading, sticky: true, {
    counter("sub").step()
    text(size: type-size, weight: "bold", context numbering("A.", counter("sub").get().first()) + h(0.4in) + it.body)
  })
  show heading.where(level: 3): it => block(above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", emph(it.body)))

  // Lists: numbered 1., 2., ... with the same spacing as the paragraphs.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-spacing)

  court-title(meta)
  v(line-pitch)
  caption-block(meta)
  doc-title(meta)

  body-content(meta, body)

  signature-block(meta)
  v(line-pitch)
  certificate-block(meta)
}
