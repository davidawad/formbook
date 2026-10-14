// U.S. Bankruptcy Court, Western District of Missouri: adversary complaint (FRBP 7001).
//
// Rule-driven and content-agnostic. Requirement IDs (MOWB-...) refer to ../README.md, which quotes
// the rule text: Fed. R. Bankr. P. 7008(a), 7010, 9004(a)-(b); W.D. Mo. Bankr. L.R. 17004-1, 9011-4,
// 9013-3. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Vendored in /fonts. No Missouri or FRBP type rule; see ../README.md, gap 2.
#let type-size = 13pt                    // Tier 2: the exemplars are 12 pt Times; EB Garamond needs 13 pt for the same apparent size.
#let line-pitch = 24pt                   // Tier 2: double spacing, as in the Carlson exemplar (complaint).
#let body-leading = 1.2em                // Gap between lines of body text: with the 13 pt line box, the line pitch is 24 pt (double spacing).
#let single-leading = 0.5em              // Caption, signature block, certificate, headings.
#let body-spacing = body-leading          // Space between paragraphs: one full line pitch. Typst adds it after the last line, which has no leading of its own.
#let page-margin = 1in                   // Tier 2: 1 inch on all sides, as in the exemplars.
#let para-indent = 0.5in                 // First-line indent of numbered paragraphs.
#let label-gap = 0.25in                  // Gap between a paragraph number and its text.
#let caption-left = 3.8in                // Party column of the caption; the ")" column follows.
#let caption-line = 16pt                 // Height of one caption line (single spacing for 13 pt EB Garamond).
#let footer-size = 11pt                  // Page number at the foot of each page.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mowb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mowb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 with Official Form 416D; FRBP 9004(b); W.D. Mo. L.R. 17004-1(A))
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
    "Adv. Pro. No. " + meta.adv_number
  } else {
    "Adv. Pro. No. ____________"
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
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b), applied by FRBP 7010 and 7008(a))
// ---------------------------------------------------------------------------

/// The consent statement FRBP 7008(a) requires: whether the pleader consents to final orders.
/// It is printed once, after the lead-in and before the first heading, as an unnumbered paragraph.
#let consent-paragraph(meta) = [#h(para-indent)#inl(need(meta, "consent"))#parbreak()]

/// Body chunks: a heading is rendered as is; a list is lettered (a), (b) ...; a paragraph before
/// the first heading (the lead-in) and a paragraph beginning WHEREFORE are unnumbered; every other
/// paragraph is numbered from 1 in one continuous sequence. The number is a plain integer, not a
/// counter: a numbered paragraph built inside `context` lays out on top of the one before it.
#let body-content(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let seen-heading = false
  let consent-done = false
  let n = 0
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      if not consent-done {
        out += consent-paragraph(meta)
        consent-done = true
      }
      seen-heading = true
      out += cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      out += cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if not seen-heading or t.starts-with("WHEREFORE") {
      out += [#h(para-indent)#inl(t)#parbreak()]
    } else {
      n += 1
      out += [#h(para-indent)#n.#h(label-gap)#inl(t)#parbreak()]
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
      sig-col(([Respectfully submitted,],)),
      sig-col(sig.firm.map(l => upper(l))),
      sig-col(("By: /s/ " + sig.signer, sig.signer + ", " + sig.bar)),
      sig-col(sig.lines + (emph(inl(sig.role)),)),
    ))
  })
}

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  let sig = need(meta, "signature")
  block(breakable: false, {
    heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
    set par(leading: body-leading, spacing: body-spacing, first-line-indent: para-indent)
    inl("I certify that on " + cert.date + ", " + cert.manner + ".")
    v(line-pitch)
    align(right, sig-col(("/s/ " + sig.signer, sig.signer)))
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mowb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-spacing, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps heading (unnumbered); level 2 is a bold sub-heading with
  // roman numerals I., II., ... (counter "sub"), as in the Carlson exemplar.
  show heading.where(level: 1): it => block(above: line-pitch, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: body-leading, below: body-leading, sticky: true, {
    counter("sub").step()
    text(size: type-size, weight: "bold", context numbering("I.", counter("sub").get().first()) + h(0.4in) + it.body)
  })
  show heading.where(level: 3): it => block(above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", emph(it.body)))

  // Lists: lettered (a), (b), ... as in the prayer for relief.
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-spacing)

  court-title(meta)
  v(line-pitch)
  caption-block(meta)
  doc-title(meta)

  body-content(meta, body)

  signature-block(meta)
  v(line-pitch)
  certificate-block(meta)
}
