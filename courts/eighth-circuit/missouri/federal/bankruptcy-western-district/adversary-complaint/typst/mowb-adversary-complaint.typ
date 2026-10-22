// U.S. Bankruptcy Court, Western District of Missouri: adversary complaint (FRBP 7001).
//
// Rule-driven and content-agnostic. Requirement IDs (MOWB-...) refer to ../README.md, which quotes
// the rule text: Fed. R. Bankr. P. 7008(a), 7010, 9004(a)-(b); W.D. Mo. Bankr. L.R. 17004-1, 9011-4,
// 9013-3. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // Vendored in /fonts. No Missouri or FRBP type rule; see ../README.md, gap 2.
#let type-size = 12pt                    // Tier 2: the exemplars are 12 pt Times New Roman.
#let page-margin = 1in                   // Tier 2: 1 inch on all sides, as in the exemplars.
#let para-indent = 0.5in                 // First-line indent of body paragraphs; the paragraph number's box after it.
#let item-indent = 0.5in                 // Lettered items: the label half an inch in, the text a box after it.
#let heading-label = 0.5in               // The roman numeral of a level-2 heading, in a box of this width.
#let caption-left = 3.8in                // Party column of the caption; the ")" column follows.
#let caption-paren = 0.35in              // The ")" column.
#let label-indent = 1.5in                // "Debtor.", "Plaintiff,", "Defendant." in the party column.
#let sig-left = 3.3in                    // The signature column: 3.2 in wide at the right margin of the 6.5 in text.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt               // A single line: 1.15 x the type size (Word's single line in this face).
#let pitch-double = 2 * pitch-single     // Tier 2: double spacing, 27.6 pt, as in the Carlson exemplar.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

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

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 with Official Form 416D; FRBP 9004(b); W.D. Mo. L.R. 17004-1(A))
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
    "Adv. Pro. No. " + meta.adv_number
  } else {
    "Adv. Pro. No. ____________"
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
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b), applied by FRBP 7010 and 7008(a))
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (the number in a box of the
/// paragraph indent after the first-line indent, the text after it).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))

/// Body chunks: a heading is rendered as is; a list is lettered (a), (b) ...; a paragraph before
/// the first heading (the lead-in) and a paragraph beginning WHEREFORE are unnumbered; every other
/// paragraph is numbered from 1 in one continuous sequence. The consent statement FRBP 7008(a)
/// requires (whether the pleader consents to final orders) is printed once, before the first
/// heading, as an unnumbered paragraph.
#let body-content(meta, body) = {
  let seen-heading = false
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      if not seen-heading { body-par(none, inl(need(meta, "consent"))) }
      seen-heading = true
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if not seen-heading or t.starts-with("WHEREFORE") {
      body-par(none, inl(t))
    } else {
      n += 1
      body-par(n, inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (W.D. Mo. L.R. 9011-4, 9013-3)
// ---------------------------------------------------------------------------

/// A group of single-spaced signature lines in the signature column at the right margin.
#let sig-group(above: 0pt, lines) = block(width: 100%, above: above, below: 0pt, pad(left: sig-left,
  for l in lines { line-block(l) }))

/// The date, then the signature column: "Respectfully submitted,", the firm, the signer, the address and
/// role, a blank line between the groups. It never breaks across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    if "date" in meta and meta.date != "" { line-block[Dated: #meta.date] }
    sig-group(above: pitch-double, ([Respectfully submitted,],))
    sig-group(above: pitch-single, sig.firm.map(l => upper(l)))
    sig-group(above: pitch-single, ("By: /s/ " + sig.signer, sig.signer + ", " + sig.bar))
    sig-group(above: pitch-single, sig.lines + (emph(inl(sig.role)),))
  })
}

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
    body-par(none, inl("I certify that on " + cert.date + ", " + cert.manner + "."))
    sig-group(above: pitch-double, ("/s/ " + sig.signer, sig.signer))
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mowb-adversary-complaint(meta, body) = {
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
  // body pitch (double-spaced); lettered items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)

  // Headings at the body size and pitch, no space of their own (the double pitch sets them off); sticky, so a
  // heading never ends a page. Level 1 is a centered caps heading (unnumbered); level 2 a bold sub-heading with
  // roman numerals I., II., ... counted through the document, as in the Carlson exemplar; level 3 bold italic.
  let sub = counter("sub")
  show heading: it => {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, upper(it.body)) } else if it.level == 2 {
      sub.step()
      [#box(width: heading-label, context numbering("I.", sub.get().first()))#it.body]
    } else { emph(it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  // Lists: lettered (a), (b), ... as in the prayer for relief.
  set enum(numbering: "(a)")

  court-title(meta)
  block(above: pitch-double, below: 0pt, caption-block(meta))
  line-block(above: pitch-double, below: pitch-double, align(center, strong(upper(inl(need(meta, "title"))))))

  body-content(meta, body)

  signature-block(meta)
  certificate-block(meta)
}
