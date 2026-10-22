// U.S. Bankruptcy Court, Western District of Missouri: memorandum in support of a motion
// (FRBP 9013; W.D. Mo. Bankr. L.R. 9013-1).
//
// Rule-driven and content-agnostic. Requirement IDs (MOWB-...) refer to ../README.md, which quotes
// the rule text: Fed. R. Bankr. P. 9004(a)-(b); W.D. Mo. Bankr. L.R. 9011-4, 9013-1, 9013-3, 17004-1.
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same
// file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // Vendored in /fonts. No Missouri or FRBP type rule; see ../README.md, gap 2.
#let type-size = 12pt                    // Tier 2: the exemplars are 12 pt.
#let page-margin = 1in                   // Tier 2: 1 inch on all sides, as in the exemplars.
#let para-indent = 0.5in                 // First-line indent of body paragraphs.
#let item-indent = 0.5in                 // List items: the number half an inch in, the text a box after it.
#let heading-label = 0.5in               // The numeral or letter of a heading, in a box of this width.
#let caption-left = 3.8in                // Party column of the caption; the ")" column follows.
#let caption-paren = 0.35in              // The ")" column.
#let label-indent = 1.5in                // "Debtor.", "Plaintiff,", "Defendants." in the party column.
#let sig-left = 3.3in                    // The signature column: 3.2 in wide at the right margin of the 6.5 in text.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt               // Tier 2: single spacing within a paragraph (1.15 x the type size, Word's single line).
#let para-gap = pitch-single             // Tier 2: one blank line between paragraphs, as in the Barnhart exemplar.
#let blank = 2 * pitch-single            // The space around the caption, the title and the signature block.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

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

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), 7010 with Official Form 416D; W.D. Mo. L.R. 9013-1, 17004-1(A))
// ---------------------------------------------------------------------------

/// Court title, centered, one line per entry of `court` (FRBP 9004(b): name of the court).
#let court-title(meta) = {
  for l in need(meta, "court") { line-block(align(center, upper(l))) }
  if "division" in meta and meta.division != "" { line-block(align(center, upper(meta.division))) }
}

/// The caption as one line per row: left (names and labels), ")" (the separator), right (numbers
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
  rows.push(("In re:", ""))
  rows.push(("", ""))
  rows.push((upper(need(meta, "debtor")), "Case No. " + need(meta, "case_number")))
  rows.push(("", "Chapter " + str(need(meta, "chapter"))))
  if "judge" in meta and meta.judge != "" { rows.push(("", meta.judge)) }
  rows.push(((label: "Debtor."), ""))
  rows.push(("", ""))
  let first = true
  for p in plaintiffs {
    rows.push((upper(p), if first { adv } else { "" }))
    first = false
  }
  rows.push(((label: if plaintiffs.len() > 1 { "Plaintiffs," } else { "Plaintiff," }), ""))
  rows.push(("", ""))
  rows.push(("v.", ""))
  rows.push(("", ""))
  for d in defendants { rows.push((upper(d), "")) }
  rows.push(((label: if defendants.len() > 1 { "Defendants." } else { "Defendant." }), ""))
  for r in rows {
    let l = r.at(0)
    let left = if type(l) == dictionary { pad(left: label-indent, l.label) } else { l }
    line-block(grid(columns: (caption-left, caption-paren, 1fr), left, [)], r.at(1)))
  }
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs with a first-line indent (memorandum form)
// ---------------------------------------------------------------------------

/// A body paragraph: single-spaced, a first-line indent, a blank line above it.
#let body-par(content) = block(width: 100%, above: para-gap, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Body chunks: a heading is rendered as is; a list is numbered 1., 2., ... (as in the Issues
/// section); every other paragraph is set with a first-line indent. Memoranda carry no paragraph
/// numbers (Fed. R. Civ. P. 10(b) does not apply to a memorandum of law).
#let body-content(meta, body) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, above: para-gap, below: 0pt, pad(left: item-indent, md(t)))
    } else {
      body-par(inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (W.D. Mo. L.R. 9011-4, 9013-3)
// ---------------------------------------------------------------------------

/// A group of single-spaced signature lines in the signature column at the right margin.
#let sig-group(above: 0pt, lines) = block(width: 100%, above: above, below: 0pt, pad(left: sig-left,
  for l in lines { line-block(l) }))

/// The date (when given), then the signature column: the firm, the signer, the address and role, a blank line
/// between the groups. It never breaks across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: blank, below: 0pt, {
    if "date" in meta and meta.date != "" { line-block[Dated: #meta.date] }
    sig-group(above: blank, sig.firm.map(l => upper(l)))
    sig-group(above: pitch-single, ("/s/ " + sig.signer, sig.signer + ", " + sig.bar))
    sig-group(above: pitch-single, sig.lines + (emph(inl(sig.role)),))
  })
}

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: blank, below: 0pt, {
    // Not a heading: a level-1 heading here would take a roman numeral from the section counter.
    line-block(strong(upper("Certificate of Service")))
    body-par(inl("I certify that on " + cert.date + ", " + cert.manner + "."))
    sig-group(above: blank, ("/s/ " + sig.signer, sig.signer))
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mowb-motion-brief(meta, body) = {
  // The page number centered at the foot of each page, in a single-spaced line box, so it sits at the same place
  // on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // single pitch; list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-single, list-indent: item-indent)

  // Headings at the body size and pitch, bold, at the margin, a blank line above them; sticky, so a heading never
  // ends a page. Level 1 in capitals with roman numerals (I., II., ...); level 2 with capital letters (A., B., ...),
  // restarted in each section. The numeral or letter stands in a box of heading-label.
  let (sec, sub) = (counter("sec"), counter("sub"))
  show heading: it => {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 {
      sub.update(0)
      sec.step()
      [#box(width: heading-label, context numbering("I.", sec.get().first()))#upper(it.body)]
    } else if it.level == 2 {
      sub.step()
      [#box(width: heading-label, context numbering("A.", sub.get().first()))#it.body]
    } else { emph(it.body) }
    block(sticky: true, width: 100%, above: para-gap, below: 0pt, b)
  }

  // Lists: numbered 1., 2., ...
  set enum(numbering: "1.")

  court-title(meta)
  block(above: blank, below: 0pt, caption-block(meta))
  line-block(above: blank, below: blank, align(center, strong(upper(inl(need(meta, "title"))))))

  body-content(meta, body)

  signature-block(meta)
  certificate-block(meta)
}
