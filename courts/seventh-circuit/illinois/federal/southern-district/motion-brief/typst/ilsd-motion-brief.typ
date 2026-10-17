// U.S. District Court, Southern District of Illinois: motion to dismiss with a brief in support
// (Fed. R. Civ. P. 12(b)(6); SDIL-LR 7.1).
//
// Rule-driven and content-agnostic. Requirement IDs (ILSD-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"       // Times New Roman substitute per docs/FONTS.md, vendored in /fonts; no system font can be used (tools/render.sh)
#let type-size = 12pt                  // ILSD-FORM-002: "12-point font" (SDIL-LR 7.1(a)(3)); footnotes too
#let body-leading = 16.14pt            // gap between lines of body text; with the natural line height of Liberation Serif 12 pt (0.655em, 7.86 pt) the pitch is 24 pt, double spacing (SDIL-LR 7.1(a)(3))
#let single-leading = 6.14pt           // single spacing: 7.86 pt natural + 6.14 pt is a 14 pt pitch. Caption, signature, certificate, footnotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)   // 1-inch margins (convention; the exemplar's are the same; see README)
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let heading-tab = 0.5in               // label of a level 2 or 3 heading hangs at this indent
#let caption-line = 14pt               // one single-spaced caption line
#let sig-indent = 3.0in                // signature block starts here; 3.0 in keeps "LAW OFFICES OF IWANA RADEMAEKERS, P.C." on one line
#let line-pitch-gap = 24pt             // one double-spaced line between the court name, caption and title

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ilsd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Render an inline markdown string (italics, links) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline markdown with no first-line indent (caption names, designations, the "v.").
#let plain(s) = {
  set par(first-line-indent: 0pt)
  inl(s)
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles (SDIL-LR 7.1(a)(2): a brief states its position with citations)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 1 "I.", 2 "A.", 3 "1.", 4 "a.".
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a): court name, title, file number)
// ---------------------------------------------------------------------------

/// The caption: parties on the left, a column of ")" marks, and the civil action number on the right.
#let caption(parties, case-number) = {
  let left = ()
  for (i, p) in parties.enumerate() {
    for n in p.names { left.push(plain(n)) }
    left.push([])
    left.push(pad(left: 1.4in, plain(p.designation)))
    if i < parties.len() - 1 {
      left.push([])
      left.push(align(center, plain("v.")))
      left.push([])
    }
  }
  let rows = left.map(l => box(height: caption-line, width: 100%, align(horizon, l)))
  let marks = left.map(_ => box(height: caption-line, align(horizon, [)])))
  grid(
    columns: (3.5in, 0.4in, 1fr),
    column-gutter: 0pt,
    stack(dir: ttb, spacing: 0pt, ..rows),
    stack(dir: ttb, spacing: 0pt, ..marks),
    align(horizon, pad(left: 0.25in, [Civil Action No. #case-number])),
  )
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let line(body) = par(leading: single-leading, first-line-indent: 0pt, body)

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.2em, stack(
    dir: ttb,
    spacing: 0pt,
    line[#need(meta, "date_line")],
    v(1.2em),
    pad(left: sig-indent, stack(
      dir: ttb,
      spacing: single-leading,
      line[Respectfully submitted,],
      v(0.6em),
      line[By: /s/ #sig.signer],
      ..sig.lines.map(l => line[#l]),
      ..if "role" in sig { (v(0.3em), line(strong(sig.role))) } else { () },
    )),
  ))
}

#let certificate(meta) = {
  let svc = need(meta, "service")
  pagebreak(weak: true)
  align(center, strong[CERTIFICATE OF SERVICE])
  v(12pt)
  par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, [
    I certify that a true and correct copy of the foregoing pleading was electronically filed with the clerk for the U.S. District Court, Southern District of Illinois, using the electronic case filing system of the court, and the electronic case filing system sent a "Notice of Electronic Filing" to the following attorneys of record who have consented in writing to accept this Notice as service of this document by electronic means, as follows:
  ])
  v(6pt)
  for r in svc.recipients {
    pad(left: 1in, line[#r.name \ Email: #r.email])
    v(6pt)
  }
  v(12pt)
  block(breakable: false, grid(
    columns: (1fr, 1fr),
    line[#svc.date],
    align(right, line[/s/ #svc.signer]),
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let ilsd-motion-brief(meta, body) = {
  set document(title: need(meta, "title") + " (Civil Action No. " + need(meta, "case_number") + ")")
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, first-line-indent: (amount: para-indent, all: true))
  set block(spacing: 0pt)
  set heading(numbering: (..n) => heading-num(..n))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Level 1 (I., II., III.): centered, bold; the label on its own line above the heading text.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: 18pt, below: 12pt, text(size: type-size, align(center, context {
    let nums = counter(heading).at(it.location())
    [#strong(heading-num(..nums.slice(0, 1))) \ #strong(it.body)]
  })))

  // Level 2 (A., B.) and level 3 (1., 2.): bold, the label hanging at the heading tab.
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: 12pt, below: 12pt, text(size: type-size, context {
    let nums = counter(heading).at(it.location())
    grid(columns: (heading-tab, 1fr), strong(heading-num(..nums.slice(0, 2))), strong(it.body))
  }))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: 12pt, below: 12pt, pad(left: heading-tab, text(size: type-size, context {
    let nums = counter(heading).at(it.location())
    grid(columns: (heading-tab, 1fr), strong(heading-num(..nums.slice(0, 3))), strong(it.body))
  })))

  // Court name (Fed. R. Civ. P. 10(a))
  align(center, par(leading: single-leading, first-line-indent: 0pt)[
    IN THE UNITED STATES DISTRICT COURT \
    FOR THE SOUTHERN DISTRICT OF ILLINOIS
  ])
  v(line-pitch-gap)

  caption(need(meta, "caption"), need(meta, "case_number"))

  v(line-pitch-gap)
  align(center, block(width: 80%, par(leading: single-leading, first-line-indent: 0pt, strong(need(meta, "title")))))
  v(12pt)

  // The body: headings, paragraphs and footnotes, rendered as one document.
  inl(body)

  signature(meta)
  certificate(meta)
}
