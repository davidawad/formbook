// U.S. Bankruptcy Court, E.D. Wis.: adversary complaint (FRBP 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced
// line breaks. The markdown body is rendered by cmarker chunk by chunk; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // LR 9004-1(a) allows any proportional font; Times New Roman, the house standard (docs/FONTS.md). Vendored in /fonts.
#let type-size = 12pt                      // WIEB-FORM-001: proportional font not smaller than 12-point.
#let page-margin = 1in                     // WIEB-FORM-003: one-inch margin on all sides.
#let footer-distance = 0.5in               // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                   // numbered paragraphs (FRCP 10(b), via FRBP 7010): the number at 0.5 in
#let number-box = 0.4in                    // the drafter's number in a box after the indent: the text, and its other lines, from 0.9 in
#let consent-values = ("does", "does not") // WIEB-CONSENT-001: FRBP 7008(a) statement.
#let caption-gutter = 0.4in                // the caption's two columns, each half the text width less the gutter
#let caption-indent = 0.5in                // the debtor's name and designation under "In re:"
#let designation-indent = 2.2in            // a party's designation in the adversary caption
#let versus-indent = 0.9in                 // "v." between the parties
#let caption-rule = 0.75pt                 // the rules under the bankruptcy and the adversary caption
#let sig-indent = 3.25in                   // LR 5005-2(a)(1)(A): "/s/" and the printed name, from 3.25 in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wieb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                     // WIEB-FORM-002: double-spaced body (24 pt pitch at 12 pt; README)
#let pitch-single = 14.4pt                 // caption, headings, consent, signature: single-spaced
#let title-gap = 14.4pt                    // court title to caption, the second rule to the title
#let caption-pad = 7.2pt                   // the caption rows' text stands this far from the rules
#let in-re-gap = 7.2pt                     // "In re:" to the debtor's name
#let versus-gap = 10.8pt                   // above and below "v."
#let title-below = 9.6pt                   // the title to the consent statement
#let consent-below = 14.4pt                // the consent statement to the body
#let h1-above = 14.4pt                     // headings: level 1 centered bold, level 2 bold, level 3 bold italic
#let h2-above = 12pt
#let h3-above = 9.6pt
#let h-below = 7.2pt
#let h3-below = 6pt
#let sig-above = 28.8pt                    // the last paragraph to "Dated:"
#let signer-above = 14.4pt                 // "Dated:" to the first signer, one signer to the next
#let signer-gap = 2.4pt                    // "/s/" to the signer's lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Markdown (italics etc.) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let inl(s) = unloose(md(s))

#let need(meta, key) = {
  if key not in meta { panic("wieb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wieb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, if type(c) == str { inl(c) } else { c }))
})

// ---------------------------------------------------------------------------
// Caption (FRBP 7010: the caption must substantially conform to Form 416A)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let d = need(meta, "debtor")
  let p = need(meta, "plaintiff")
  let df = need(meta, "defendant")
  sline(centered: true, strong[UNITED STATES BANKRUPTCY COURT])
  sline(centered: true, strong[EASTERN DISTRICT OF WISCONSIN])
  // Two rows, each ruled at its foot: the bankruptcy case, then the adversary proceeding; the numbers beside them,
  // centered on the row (docx: a table, the cells' bottom borders and vertical centering).
  block(width: 100%, above: title-gap, below: 0pt, grid(
    columns: (1fr, caption-gutter, 1fr),
    stroke: (x, y) => (bottom: caption-rule),
    inset: (x, y) => (top: if y == 1 { caption-pad } else { 0pt }, bottom: caption-pad),
    align: (x, y) => if x == 2 { left + horizon } else { left + top },
    {
      sline[In re:]
      sline(above: in-re-gap, left: caption-indent, d.name)
      sline(left: caption-indent, d.designation)
    },
    [],
    {
      sline(d.case_number)
      sline(d.chapter)
    },
    {
      for n in p.names { sline(n) }
      sline(left: designation-indent, p.designation)
      sline(above: versus-gap, left: versus-indent, [v.])
      block(width: 100%, above: versus-gap, below: 0pt, for n in df.names { sline(n) })
      sline(left: designation-indent, df.designation)
    },
    [],
    sline(need(meta, "adversary_number")),
  ))
  block(width: 100%, above: title-gap, below: title-below, sline(centered: true, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Consent statement (FRBP 7008(a); LR 7008-1 forfeits a statement that is missing)
// ---------------------------------------------------------------------------

#let consent-statement(meta) = {
  let c = need(meta, "consent")
  if c not in consent-values {
    panic("wieb-adversary-complaint: `consent` must be one of " + repr(consent-values))
  }
  block(width: 100%, above: 0pt, below: consent-below, sline[
    Pursuant to Fed. R. Bankr. P. 7008(a), the Plaintiff #c consent to the entry of final orders or judgment by the Bankruptcy Court.
  ])
}

// ---------------------------------------------------------------------------
// Body: chunks between blank lines; the drafter numbers the paragraphs (FRCP 10(b): consecutive numbers)
// ---------------------------------------------------------------------------

/// A body paragraph on the body pitch: with the drafter's number in a box after the indent, its other lines hanging
/// at the text; without one, at the margin.
#let body-par(c, label: none) = block(width: 100%, above: 0pt, below: 0pt, if label == none {
  par(first-line-indent: 0pt, c)
} else {
  par(first-line-indent: 0pt, hanging-indent: para-indent + number-box,
    [#h(para-indent)#box(width: number-box, label)#c])
})

#let body-blocks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for t in chunks {
    let num = t.match(regex("^(\\d+\\.)[ \\t]+([\\s\\S]*)$"))
    if t.starts-with("#") {
      md(t)
    } else if num != none {
      body-par(inl(num.captures.at(1)), label: num.captures.at(0))
    } else {
      body-par(inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 5005-2(a)(1)(A): "/s/" followed by the printed name)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let dated = need(meta, "dated")
  let signers = need(meta, "signers")
  block(breakable: false, width: 100%, above: sig-above, below: 0pt, {
    sline[Dated: #dated]
    for s in signers {
      sline(above: signer-above, left: sig-indent)[/s/ #s.signer]
      block(width: 100%, above: signer-gap, below: 0pt, for l in s.lines { sline(left: sig-indent, l) })
    }
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let wieb-adversary-complaint(meta, md-body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter", margin: page-margin,
    numbering: "1",
    // The page number centered at the foot of every page, in a single-pitch line box that ends footer-distance
    // above the page edge.
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("§§ 727"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings single-spaced at the type size, kept with the text after them.
  show heading: it => block(width: 100%, sticky: true,
    above: (h1-above, h2-above, h3-above).at(calc.min(it.level, 3) - 1),
    below: if it.level >= 3 { h3-below } else { h-below }, {
      set text(size: type-size, weight: "bold", ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, it.body) }
      else if it.level == 2 { it.body }
      else { text(style: "italic", it.body) }
    })

  caption(meta)
  consent-statement(meta)
  body-blocks(md-body)
  signature(meta)
}
